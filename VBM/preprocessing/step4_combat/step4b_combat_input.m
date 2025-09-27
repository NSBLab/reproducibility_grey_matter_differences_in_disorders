function step4b_combat_input(config)
% STEP4B: Create metadata and combine surface inputs for COMBAT
% This function prepares the data for COMBAT harmonization by:
% 1. Reading metadata and creating COMBAT input files
% 2. Loading smoothed images and applying mask
% 3. Creating the masked data matrix for COMBAT processing
%
% Input: config - Configuration structure containing paths and settings

% Use config passed as parameter, or load from file if not provided
if nargin < 1 || isempty(config)
    % Fallback: Load configuration from config.json file
    config = jsondecode(fileread('../../config.json'));
end

fprintf('=== STEP4B: COMBAT INPUT PREPARATION ===\n');

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
    process_combat_group(config, group_name, datasets, dataset_root, smoothKernel);
end

fprintf('=== STEP4B COMPLETED ===\n');
end

function process_combat_group(config, group_name, datasets, dataset_root, smoothKernel)
% Process a single combat group

% Set up directories
dataDir = dataset_root;
demoDir = fullfile(dataDir, 'derivatives', ['s', num2str(smoothKernel)], ['mask_', group_name]);
outDir = fullfile(dataDir, 'derivatives', ['s', num2str(smoothKernel), 'COMBAT'], ['mask_', group_name]);

% Create output directory if it doesn't exist
if ~exist(outDir, 'dir')
    mkdir(outDir);
    fprintf('  Created output directory: %s\n', outDir);
end

% Add required paths
addpath(fullfile(fileparts(mfilename('fullpath')), '..', '..', '..', 'func'));

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
copyfile(maskFile, fullfile(outDir, 'mask.nii'));

% Combine maps for all subjects in this group
fprintf('  Processing %d subjects...\n', height(metadata));
map = zeros(sum(mask(:)), height(metadata));

for iSub = 1:height(metadata)
    subj_id = metadata.subj_id{iSub};
    ses = metadata.ses{iSub};
    dataset = metadata.dataset{iSub};
    
    fprintf('    Processing subject %d/%d: %s\n', iSub, height(metadata), subj_id);
    
    % Determine file path based on session
    if strcmp(ses, '')
        % Single session
        mapFile = fullfile(dataDir, dataset, subj_id, 'anat', ...
            ['s', num2str(smoothKernel), 'mwp1', subj_id, '_T1w.nii']);
    else
        % Multiple sessions
        mapFile = fullfile(dataDir, dataset, subj_id, ses, 'anat', ...
            ['s', num2str(smoothKernel), 'mwp1', subj_id, '_', ses, '_T1w.nii']);
    end
    
    % Check if file exists
    if ~exist(mapFile, 'file')
        warning('    File not found: %s', mapFile);
        continue;
    end
    
    % Load and mask the image
    mapnifti = niftiread(mapFile);
    map(:, iSub) = mapnifti(logical(mask));
end

% Save the masked data matrix
outputFile = fullfile(outDir, ['anat_s', num2str(smoothKernel), 'mwp1_T1w_masked.txt']);
fprintf('  Saving masked data matrix to: %s\n', outputFile);
writematrix(map, outputFile, 'Delimiter', ' ');

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