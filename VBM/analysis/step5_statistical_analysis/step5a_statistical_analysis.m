function step5a_statistical_analysis(inDir, dataset, isses, smoothKernel, maskDiag, harmonize)
% STEP5A: Statistical Analysis - GLM Analysis
% This function performs GLM analysis for VBM data, with or without COMBAT harmonization
%
% Inputs:
%   inDir - Dataset root directory
%   dataset - Dataset name to process
%   isses - Session flag (1 or 0)
%   smoothKernel - Smoothing kernel size
%   maskDiag - Mask diagnostic group ('psy' or 'AD')
%   harmonize - Harmonization flag (1 for COMBAT, 0 for no harmonization)

% Validate required parameters
if nargin < 1 || isempty(inDir)
    error('Data root directory is required');
end
if nargin < 2 || isempty(dataset)
    error('Dataset name is required');
end
if nargin < 3 || isempty(isses)
    error('Session flag (isses) is required');
end
if nargin < 4 || isempty(smoothKernel)
    error('Smoothing kernel is required');
end
if nargin < 5 || isempty(maskDiag)
    error('Mask diagnostic group is required');
end
if nargin < 6 || isempty(harmonize)
    error('Harmonization flag is required');
end

fprintf('=== STEP5A: STATISTICAL ANALYSIS ===\n');
fprintf('Dataset: %s\n', dataset);
fprintf('Sessions: %d\n', isses);
fprintf('Smoothing kernel: %d\n', smoothKernel);
fprintf('Mask diagnostic group: %s\n', maskDiag);
fprintf('Harmonization: %d\n', harmonize);

% Initialize SPM
fprintf('Initializing SPM...\n');
spm('defaults', 'FMRI');
spm_jobman('initcfg');

% Set random seed for reproducibility
rng('default');

% Define output directories based on harmonization flag
if harmonize == 1
    outDir = fullfile(inDir, 'derivatives', ['s', num2str(smoothKernel), 'COMBAT']);
    fprintf('Using COMBAT harmonized data\n');
else
    outDir = fullfile(inDir, 'derivatives', ['s', num2str(smoothKernel)]);
    fprintf('Using non-harmonized data\n');
end

% Create output directory if it doesn't exist
if ~exist(outDir, 'dir')
    mkdir(outDir);
end

% Define mask directory
maskDir = fullfile(inDir, 'derivatives', ['s', num2str(smoothKernel)], ['mask_', maskDiag,'/']);

% Define TIV directory and filename
TIVDir = fullfile(inDir, 'derivatives', ['s', num2str(smoothKernel)]);
tiv_filename = fullfile(TIVDir, [dataset, '_TIV.txt']);

% Load metadata
metadataFilename = fullfile(inDir, dataset, [dataset, '_dems.csv']);
if ~exist(metadataFilename, 'file')
    error('Metadata file not found: %s', metadataFilename);
end

fprintf('Loading metadata from: %s\n', metadataFilename);
metadata = readtable(metadataFilename, 'delimiter', ',');

% Read TIV data
if ~exist(tiv_filename, 'file')
    error('TIV file not found: %s', tiv_filename);
end

fprintf('Loading TIV data from: %s\n', tiv_filename);
tiv = readtable(tiv_filename, 'ReadVariableNames', false);
tiv_all = table2array(tiv);

% Get smoothed nifti file names
subNiftiSmooth_cell = {};
for i = 1:size(metadata, 1)
    subj_id = metadata.subj_id{i};
    if isses == 1
        ses = metadata.ses{i};
        if harmonize == 1
            subNiftiSmooth = fullfile(inDir, dataset, subj_id, ses, 'anat', ...
                ['s', num2str(smoothKernel), 'mwp1', subj_id, '_', ses, '_T1w_combat.nii']);
        else
            subNiftiSmooth = fullfile(inDir, dataset, subj_id, ses, 'anat', ...
                ['s', num2str(smoothKernel), 'mwp1', subj_id, '_', ses, '_T1w.nii']);
        end
    else
        if harmonize == 1
            subNiftiSmooth = fullfile(inDir, dataset, subj_id, 'anat', ...
                ['s', num2str(smoothKernel), 'mwp1', subj_id, '_T1w_combat.nii']);
        else
            subNiftiSmooth = fullfile(inDir, dataset, subj_id, 'anat', ...
                ['s', num2str(smoothKernel), 'mwp1', subj_id, '_T1w.nii']);
        end
    end
    subNiftiSmooth_cell{i,1} = subNiftiSmooth;
end

% Prepare to run model for each specific site
numCovs = 3;
unique_siteIDs = unique(metadata.site);
numSite = size(unique_siteIDs, 1);

fprintf('Processing %d sites for dataset %s\n', numSite, dataset);

for s = 1:numSite
    fprintf('  Processing site %d of %d (site ID: %d)\n', s, numSite, unique_siteIDs(s));
    
    % Get a list of all smoothed hc niftis from site X
    hcCell = subNiftiSmooth_cell(metadata.diagnosis == 1 & metadata.site == unique_siteIDs(s));
    
    % Prepare hc covariates
    hc_covs = zeros(size(hcCell, 1), numCovs);
    hc_covs(:, 1) = metadata.age(metadata.diagnosis == 1 & metadata.site == unique_siteIDs(s));
    hc_covs(:, 2) = metadata.sex(metadata.diagnosis == 1 & metadata.site == unique_siteIDs(s));
    hc_covs(:, 3) = tiv_all(metadata.diagnosis == 1 & metadata.site == unique_siteIDs(s));
    
    % Get a list of the unique diagnoses
    patients = metadata(metadata.diagnosis ~= 1 & metadata.site == unique_siteIDs(s), :);
    unique_patIDs = unique(patients.diagnosis);
    numPatGroups = size(unique_patIDs, 1);
    
    for i = 1:numPatGroups % For each unique patient group
        patCell = subNiftiSmooth_cell(metadata.diagnosis == unique_patIDs(i) & metadata.site == unique_siteIDs(s));
        
        % Prepare patient covariates
        pat_covs = zeros(size(patCell, 1), numCovs);
        pat_covs(:, 1) = metadata.age(metadata.diagnosis == unique_patIDs(i) & metadata.site == unique_siteIDs(s));
        pat_covs(:, 2) = metadata.sex(metadata.diagnosis == unique_patIDs(i) & metadata.site == unique_siteIDs(s));
        pat_covs(:, 3) = tiv_all(metadata.diagnosis == unique_patIDs(i) & metadata.site == unique_siteIDs(s));
        
        % Concatenate hc and pat covariates
        covariates = [hc_covs; pat_covs];
        
        % Define each covariate
        age = covariates(:, 1);
        sex = covariates(:, 2);
        tiv = covariates(:, 3);
        
        % The name of the specific site we running the model on
        siteName = metadata.site_string(metadata.site == unique_siteIDs(s));
        siteName = char(siteName(1));
        
        % The diagnostic category of diagnosis we are running for model on
        diagnosisName = metadata.diagnosis_string(metadata.diagnosis == unique_patIDs(i));
        diagnosisName = char(diagnosisName(1));
        
        % The output folder
        newSubFolder = fullfile(outDir, diagnosisName, siteName);
        
        if ~exist(newSubFolder, 'dir')
            mkdir(newSubFolder); % Create new output directory for model output
        end
        
        % Clear existing files in the output folder
        delete(fullfile(newSubFolder, '*'));
        
        fprintf('    Processing: %s vs %s\n', diagnosisName, siteName);
        
        % Run the appropriate GLM analysis based on harmonization flag
        if harmonize == 1
            % Use COMBAT-specific functions
            factorial_design_ttest_combat_job(newSubFolder, hcCell, patCell, age, sex, tiv, maskDir);
            
            % Estimate the model
            spm_file = fullfile(newSubFolder, 'SPM.mat');
            model_estimation_combat_job(spm_file);
        else
            % Use standard functions
            factorial_design_ttest_job(newSubFolder, hcCell, patCell, age, sex, tiv, maskDir);
            
            % Estimate the model
            spm_file = fullfile(newSubFolder, 'SPM.mat');
            model_estimation_job(spm_file);
        end
        
        % Run contrast and reporting jobs (common for both harmonized and non-harmonized)
        spm_file = fullfile(newSubFolder, 'SPM.mat');
        contr_job(spm_file);
        spm('defaults', 'PET');
        report_thres_job(spm_file);
        
        % Add path for additional functions
        addpath(fullfile(fileparts(mfilename('fullpath')), '..', '..', '..', 'utils'));
        report_fwe_job(spm_file);
    end
end

fprintf('=== STEP5A COMPLETED ===\n');
fprintf('Statistical analysis completed for dataset: %s\n', dataset);
fprintf('Harmonization: %s\n', harmonize == 1 ? 'Yes' : 'No');
fprintf('Output directory: %s\n', outDir);
end