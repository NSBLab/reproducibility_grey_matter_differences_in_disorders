function step4b_make_mask(config)
% STEP4B: Create masks for COMBAT processing
% This function creates masks for each combat group using SPM statistical approach
%
% Input: config - Configuration structure containing paths and settings

% Use config passed as parameter, or load from file if not provided
if nargin < 1 || isempty(config)
    % Fallback: Load configuration from config.json file
    config = jsondecode(fileread('../../config.json'));
end

fprintf('=== STEP4B: MAKE MASKS ===\n');

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
    
    fprintf('Creating mask for combat group: %s (%d datasets)\n', group_name, length(datasets));
    
    % Process this group
    process_mask_group(config, group_name, dataset_root, smoothKernel);
end

fprintf('=== STEP4B COMPLETED ===\n');
end

function process_mask_group(config, group_name, dataset_root, smoothKernel)
% Process mask creation for a single combat group using SPM approach

% Set up directories
inDir = dataset_root;
outDir = fullfile(inDir, 'derivatives', ['s', num2str(smoothKernel)], ['mask_', group_name]);

% Create output directory if it doesn't exist
if ~exist(outDir, 'dir')
    mkdir(outDir);
    fprintf('  Created mask directory: %s\n', outDir);
end

% Load metadata for this group
metadataFilename = fullfile(inDir, ['metadataVBM_', group_name, '.csv']);
if ~exist(metadataFilename, 'file')
    error('Metadata file not found: %s', metadataFilename);
end

fprintf('  Reading metadata from: %s\n', metadataFilename);
opts = detectImportOptions(metadataFilename);
opts = setvaropts(opts, 'ses', 'FillValue', '');
metadata = readtable(metadataFilename, opts);

% Get list of smoothed images for this group
subNiftiSmooth_cell = {};
for i = 1:height(metadata)
    subj_id = metadata.subj_id{i};
    ses = metadata.ses{i};
    dataset = metadata.dataset{i};
    
    % Construct smoothed image path
    if ~strcmp(ses, '')
        % Multiple sessions
        subNiftiSmooth = fullfile(inDir, dataset, subj_id, ses, 'anat', ...
            ['s', num2str(smoothKernel), 'mwp1', subj_id, '_', ses, '_T1w.nii']);
    else
        % Single session
        subNiftiSmooth = fullfile(inDir, dataset, subj_id, 'anat', ...
            ['s', num2str(smoothKernel), 'mwp1', subj_id, '_T1w.nii']);
    end
    
    if exist(subNiftiSmooth, 'file')
        subNiftiSmooth_cell{end+1} = subNiftiSmooth;
    else
        warning('Smoothed image not found: %s', subNiftiSmooth);
    end
end

if isempty(subNiftiSmooth_cell)
    error('No valid smoothed images found for group: %s', group_name);
end

fprintf('  Found %d valid smoothed images for group: %s\n', length(subNiftiSmooth_cell), group_name);

% Prepare covariates for SPM analysis
numCovs = 2;
unique_siteIDs = unique(metadata.site);

% Get healthy controls and patients
hcCell = subNiftiSmooth_cell(metadata.diagnosis == 1);
patCell = subNiftiSmooth_cell(metadata.diagnosis ~= 1);

% Prepare covariates
hc_covs = zeros(length(hcCell), numCovs);
hc_covs(:, 1) = metadata.age(metadata.diagnosis == 1);
hc_covs(:, 2) = metadata.sex(metadata.diagnosis == 1);

pat_covs = zeros(length(patCell), numCovs);
pat_covs(:, 1) = metadata.age(metadata.diagnosis ~= 1);
pat_covs(:, 2) = metadata.sex(metadata.diagnosis ~= 1);

% Concatenate covariates
covariates = [hc_covs; pat_covs];
age = covariates(:, 1);
sex = covariates(:, 2);

fprintf('  Running SPM factorial design for mask creation...\n');

% Run SPM factorial design
try
    factorial_design_make_mask(outDir, hcCell, patCell, age, sex);
    
    % Estimate the model
    spm_file = fullfile(outDir, 'SPM.mat');
    if exist(spm_file, 'file')
        model_estimation_job(spm_file);
        fprintf('  SPM model estimation completed\n');
    else
        error('SPM.mat file not created');
    end
    
    fprintf('  Mask creation completed for group: %s\n', group_name);
    
catch ME
    fprintf('  Error in SPM mask creation: %s\n', ME.message);
    error('Failed to create mask for group: %s', group_name);
end
end

function datasets_by_group = get_datasets_by_combat_group(config)
% Helper function to group datasets by combat_group
datasets_by_group = struct();

% Get enabled datasets
enabled_datasets = {};
for i = 1:length(config.datasets)
    if config.datasets(i).enabled
        enabled_datasets{end+1} = config.datasets(i).name;
    end
end

% Group by combat_group
for i = 1:length(enabled_datasets)
    dataset_name = enabled_datasets{i};
    
    % Find the dataset in config
    dataset_config = [];
    for j = 1:length(config.datasets)
        if strcmp(config.datasets(j).name, dataset_name)
            dataset_config = config.datasets(j);
            break;
        end
    end
    
    if ~isempty(dataset_config) && isfield(dataset_config, 'combat_group')
        group_name = dataset_config.combat_group;
        if ~isfield(datasets_by_group, group_name)
            datasets_by_group.(group_name) = {};
        end
        datasets_by_group.(group_name){end+1} = dataset_name;
    end
end
end
