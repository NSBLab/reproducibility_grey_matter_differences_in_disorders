function step4b_make_mask(dataset_root, smoothKernel)
% STEP4B: Create masks for COMBAT processing
% This function creates masks for each combat group using SPM statistical approach
% This function use SPM to make a group mask for all the subject so need to have the package installed
%
% Input: 
%   dataset_root - Root directory containing the datasets
%   smoothKernel - Smoothing kernel size in mm

% Validate inputs
if nargin < 2
    error('Both dataset_root and smoothKernel are required');
end

if isempty(dataset_root)
    error('dataset_root cannot be empty');
end

if isempty(smoothKernel)
    error('smoothKernel cannot be empty');
end

fprintf('=== STEP4B: MAKE MASKS ===\n');
fprintf('Dataset root: %s\n', dataset_root);
fprintf('Smoothing kernel: %dmm\n', smoothKernel);

% Process each combat group by reading existing metadata files
group_names = {'psy', 'AD'}; % Known combat groups

for g = 1:length(group_names)
    group_name = group_names{g};
    metadataFilename = fullfile(dataset_root, ['metadataVBM_', group_name, '.csv']);
    
    if ~exist(metadataFilename, 'file')
        fprintf('  Skipping group %s - metadata file not found: %s\n', group_name, metadataFilename);
        continue;
    end
    
    fprintf('Creating mask for combat group: %s\n', group_name);
    
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

% Create output directory if it doesnt exist
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
% Only set ses options if the column exists
if ismember('ses', opts.VariableNames)
    opts = setvaropts(opts, 'ses', 'FillValue', '');
end
metadata = readtable(metadataFilename, opts);

% Get list of smoothed images for this group
subNiftiSmooth_cell = {};
for i = 1:height(metadata)
    subj_id = metadata.subj_id{i};
    dataset = metadata.dataset{i};
    
     % Check if ses column exists and get session info
    if ismember('ses', metadata.Properties.VariableNames)
        ses = metadata.ses{i};
        if ~strcmp(ses, '')
            % Multiple sessions
            subNiftiSmooth = fullfile(inDir, dataset, subj_id, ses, 'anat', ...
                ['s', num2str(smoothKernel), 'mwp1', subj_id, '_', ses, '_T1w.nii']);
        else
            % Single session
            subNiftiSmooth = fullfile(inDir, dataset, subj_id, 'anat', ...
                ['s', num2str(smoothKernel), 'mwp1', subj_id, '_T1w.nii']);
        end
    else
        % No ses column - single session
        subNiftiSmooth = fullfile(inDir, dataset, subj_id, 'anat', ...
            ['s', num2str(smoothKernel), 'mwp1', subj_id, '_T1w.nii']);
    end
    
    if exist(subNiftiSmooth, 'file')
        subNiftiSmooth_cell{end+1,1} = subNiftiSmooth;
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

