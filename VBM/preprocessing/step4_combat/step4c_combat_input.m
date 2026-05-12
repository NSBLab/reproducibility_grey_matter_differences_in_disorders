function step4c_combat_input(config, group_filter)
% Prepare masked data matrix for COMBAT: reads smoothed images, applies group mask,
% and writes anat_s<k>mwp1_T1w_masked.txt per combat group.
%
% Usage:
%   step4c_combat_input(config)              % all groups
%   step4c_combat_input(config, 'psy')       % one group only
%   step4c_combat_input('config_hpc.json')   % load from file, all groups
%   step4c_combat_input('config_hpc.json', 'psy')

if nargin < 1 || isempty(config)
    error('No config passed');
end
if nargin < 2; group_filter = ''; end

if ischar(config) || isstring(config)
    this_dir = fileparts(mfilename('fullpath'));
    addpath(genpath(fullfile(this_dir, '..', '..', '..')));
    config = pipeline_load_config(char(config));
end

fprintf('=== STEP4C: COMBAT INPUT PREPARATION ===\n');

dataset_root = config.data_directories.dataset_root;
smoothKernel = config.analysis_settings.vbm_smoothing_kernel;

datasets_by_group = get_datasets_by_combat_group(config);
group_names = fieldnames(datasets_by_group);

if isempty(group_names)
    error('No combat groups found in config. Please add combat_group field to datasets.');
end

for g = 1:length(group_names)
    group_name = group_names{g};
    if ~isempty(group_filter) && ~strcmp(group_name, group_filter)
        continue;
    end
    datasets = datasets_by_group.(group_name);
    if isempty(datasets); continue; end
    fprintf('Processing combat group: %s (%d datasets)\n', group_name, length(datasets));
    process_combat_group(config, group_name, datasets, dataset_root, smoothKernel);
end

fprintf('=== STEP4C COMPLETED ===\n');
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


% Read metadata for this group
metadataFilename = fullfile(dataDir, ['metadataVBM_', group_name, '.csv']);
if ~exist(metadataFilename, 'file')
    error('Metadata file not found: %s', metadataFilename);
end

fprintf('  Reading metadata from: %s\n', metadataFilename);
opts = detectImportOptions(metadataFilename);
if ismember('ses', opts.VariableNames)
    opts = setvaropts(opts, 'ses', 'FillValue', '');
end
metadata = readtable(metadataFilename, opts);
has_ses = ismember('ses', metadata.Properties.VariableNames);

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
    dataset = metadata.dataset{iSub};
    ses = '';
    if has_ses; ses = metadata.ses{iSub}; end

    if isempty(ses)
        mapFile = fullfile(dataDir, dataset, subj_id, 'anat', ...
            sprintf('s%dmwp1%s_T1w.nii', smoothKernel, subj_id));
    else
        mapFile = fullfile(dataDir, dataset, subj_id, ses, 'anat', ...
            sprintf('s%dmwp1%s_%s_T1w.nii', smoothKernel, subj_id, ses));
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
        datasets_by_group.(group){end+1} = name_k;
    end
end
end