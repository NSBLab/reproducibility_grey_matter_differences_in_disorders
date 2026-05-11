function step4e_combat_output(config)
% Write COMBAT-harmonized NIfTI files per subject per combat group.

if nargin < 1 || isempty(config)
    error('No config passed');
end

fprintf('=== STEP4E: COMBAT OUTPUT CREATION ===\n');

% Get paths from config
dataset_root = config.data_directories.dataset_root;
smoothKernel = config.analysis_settings.smoothing_kernel;

% Get datasets grouped by combat group
datasets_by_group = get_datasets_by_combat_group(config);
group_names = fieldnames(datasets_by_group);

if isempty(group_names)
    error('No combat groups found in config. Please add combat_group field to datasets.');
end

% Process each combat group
for g = 1:length(group_names)
    group_name = group_names{g};
    datasets = datasets_by_group.(group_name);
    
    if isempty(datasets)
        continue;
    end
    
    fprintf('Processing combat group: %s (%d datasets)\n', group_name, length(datasets));
    
    % Process this group
    process_combat_group(config, group_name, dataset_root, smoothKernel);
end

fprintf('=== STEP4E COMPLETED ===\n');
end

function process_combat_group(config, group_name, dataset_root, smoothKernel)
% Process COMBAT output creation for a single combat group

% Set up directories
dataDir = dataset_root;
demoDir = fullfile(dataDir, 'derivatives', ['s', num2str(smoothKernel)], ['mask_', group_name]);
outDir = fullfile(dataDir, 'derivatives', ['s', num2str(smoothKernel), 'COMBAT'], ['mask_', group_name]);

% Read metadata for this group
metadataFilename = fullfile(dataDir, ['metadataVBM_', group_name, '.csv']);
if ~exist(metadataFilename, 'file')
    error('Metadata file not found: %s', metadataFilename);
end

fprintf('  Reading metadata from: %s\n', metadataFilename);
opts = detectImportOptions(metadataFilename);
opts = setvaropts(opts, 'ses', 'FillValue', '');
metadata = readtable(metadataFilename, opts);

% Load mask
maskFile = fullfile(demoDir, 'mask.nii');
if ~exist(maskFile, 'file')
    error('Mask file not found: %s', maskFile);
end

fprintf('  Loading mask from: %s\n', maskFile);
mask = niftiread(maskFile);

% Load COMBAT harmonized data
combatFile = fullfile(outDir, ['anat_s', num2str(smoothKernel), 'mwp1_T1w_masked_combat.txt']);
if ~exist(combatFile, 'file')
    error('COMBAT harmonized data file not found: %s', combatFile);
end

fprintf('  Loading COMBAT harmonized data from: %s\n', combatFile);
combatMap = readmatrix(combatFile);

% Create individual NIfTI files for each subject
fprintf('  Creating individual COMBAT harmonized NIfTI files for %d subjects...\n', height(metadata));

for iSub = 1:height(metadata)
    subj_id = metadata.subj_id{iSub};
    ses = metadata.ses{iSub};
    dataset = metadata.dataset{iSub};
    
    fprintf('    Processing subject %d/%d: %s\n', iSub, height(metadata), subj_id);
    
    % Create empty volume with same dimensions as mask
    mapnifti = zeros(size(mask));
    
    % Fill with COMBAT harmonized data
    mapnifti(mask == 1) = combatMap(:, iSub);
    
    % Determine output file path based on session
    if strcmp(ses, '')
        % Single session
        originalFile = fullfile(dataDir, dataset, subj_id, 'anat', ...
            ['s', num2str(smoothKernel), 'mwp1', subj_id, '_T1w.nii']);
        outputFile = fullfile(dataDir, dataset, subj_id, 'anat', ...
            ['s', num2str(smoothKernel), 'mwp1', subj_id, '_T1w_combat.nii']);
    else
        % Multiple sessions
        originalFile = fullfile(dataDir, dataset, subj_id, ses, 'anat', ...
            ['s', num2str(smoothKernel), 'mwp1', subj_id, '_', ses, '_T1w.nii']);
        outputFile = fullfile(dataDir, dataset, subj_id, ses, 'anat', ...
            ['s', num2str(smoothKernel), 'mwp1', subj_id, '_', ses, '_T1w_combat.nii']);
    end
    
    % Check if original file exists to get header information
    if ~exist(originalFile, 'file')
        warning('    Original file not found: %s', originalFile);
        continue;
    end
    
    % Get header information from original file
    mapinfo = niftiinfo(originalFile);
    
    % Write COMBAT harmonized NIfTI file
    niftiwrite(single(mapnifti), outputFile, mapinfo);
    
    fprintf('      Created: %s\n', outputFile);
end

fprintf('  Group %s processing completed\n', group_name);
end

function datasets_by_group = get_datasets_by_combat_group(config)
% Return structure with datasets grouped by combat_group
datasets_by_group = struct();
if ~isfield(config, 'datasets') || isempty(fieldnames(config.datasets))
    return;
end

dataset_names = fieldnames(config.datasets);
for k = 1:numel(dataset_names)
    name_k = dataset_names{k};
    ds = config.datasets.(name_k);
    if isfield(ds, 'enabled') && logical(ds.enabled) && isfield(ds, 'combat_group')
        group = ds.combat_group;
        if ~isfield(datasets_by_group, group)
            datasets_by_group.(group) = {};
        end
        datasets_by_group.(group){end+1} = name_k; %#ok<AGROW>
    end
end
end