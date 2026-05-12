function step5_statistical_analysis(config, dataset, perm_id)
% VBM GLM analysis for one dataset (one site-diagnosis pair per call).
%
% Usage:
%   step5_statistical_analysis(config, 'Myelin')
%   step5_statistical_analysis('config_hpc.json', 'Myelin')
%   step5_statistical_analysis(config, 'Myelin', 3)   % permutation 3

if nargin < 2 || isempty(config) || isempty(dataset)
    error('Usage: step5_statistical_analysis(config, dataset [, perm_id])');
end
if nargin < 3; perm_id = []; end

if ischar(config) || isstring(config)
    this_dir = fileparts(mfilename('fullpath'));
    addpath(genpath(fullfile(this_dir, '..', '..', '..')));
    config = pipeline_load_config(char(config));
end

fprintf('=== STEP5: VBM STATISTICAL ANALYSIS ===\n');
fprintf('Dataset: %s\n', dataset);

dataset_root = config.data_directories.dataset_root;
smoothKernel = config.analysis_settings.vbm_smoothing_kernel;
harmonize    = config.analysis_settings.harmonize;
maskDiag     = config.analysis_settings.mask_diagnostic_group;

is_longitudinal = isfield(config.datasets, dataset) && ...
                  isfield(config.datasets.(dataset), 'longitudinal') && ...
                  config.datasets.(dataset).longitudinal;

fprintf('Smoothing kernel: %d\n', smoothKernel);
fprintf('Harmonization: %d\n', harmonize);
fprintf('Mask diagnostic group: %s\n', maskDiag);
fprintf('Longitudinal: %d\n', is_longitudinal);
if ~isempty(perm_id)
    fprintf('Permutation ID: %d\n', perm_id);
end

addpath(fileparts(mfilename('fullpath')));
rng('default');

% Output directory
if ~isempty(perm_id)
    if harmonize == 1
        outDir = fullfile(dataset_root, 'derivatives', ['s', num2str(smoothKernel), 'COMBAT_perm', num2str(perm_id)]);
    else
        outDir = fullfile(dataset_root, 'derivatives', ['s', num2str(smoothKernel), '_perm', num2str(perm_id)]);
    end
else
    if harmonize == 1
        outDir = fullfile(dataset_root, 'derivatives', ['s', num2str(smoothKernel), 'COMBAT']);
    else
        outDir = fullfile(dataset_root, 'derivatives', ['s', num2str(smoothKernel)]);
    end
end
if ~exist(outDir, 'dir'); mkdir(outDir); end

maskDir      = fullfile(dataset_root, 'derivatives', ['s', num2str(smoothKernel)], ['mask_', maskDiag, '/']);
tiv_filename = fullfile(dataset_root, 'derivatives', ['s', num2str(smoothKernel)], [dataset, '_TIV.txt']);

% Load metadata
if ~isempty(perm_id)
    metadataFilename = fullfile(outDir, [dataset, '_dems_perm', num2str(perm_id), '.csv']);
else
    metadataFilename = fullfile(dataset_root, dataset, [dataset, '_dems.csv']);
end
if ~exist(metadataFilename, 'file')
    error('Metadata file not found: %s', metadataFilename);
end
fprintf('Loading metadata from: %s\n', metadataFilename);
metadata = readtable(metadataFilename, 'delimiter', ',');

% Load TIV
if ~exist(tiv_filename, 'file')
    error('TIV file not found: %s', tiv_filename);
end
tiv_all = table2array(readtable(tiv_filename, 'ReadVariableNames', false));

% Build smoothed NIfTI file list
has_ses = is_longitudinal && ismember('ses', metadata.Properties.VariableNames);
subNiftiSmooth_cell = cell(height(metadata), 1);
for i = 1:height(metadata)
    subj_id = metadata.subj_id{i};
    ses = '';
    if has_ses; ses = metadata.ses{i}; end

    if ~isempty(ses)
        if harmonize == 1
            subNiftiSmooth_cell{i} = fullfile(dataset_root, dataset, subj_id, ses, 'anat', ...
                ['s', num2str(smoothKernel), 'mwp1', subj_id, '_', ses, '_T1w_combat.nii']);
        else
            subNiftiSmooth_cell{i} = fullfile(dataset_root, dataset, subj_id, ses, 'anat', ...
                ['s', num2str(smoothKernel), 'mwp1', subj_id, '_', ses, '_T1w.nii']);
        end
    else
        if harmonize == 1
            subNiftiSmooth_cell{i} = fullfile(dataset_root, dataset, subj_id, 'anat', ...
                ['s', num2str(smoothKernel), 'mwp1', subj_id, '_T1w_combat.nii']);
        else
            subNiftiSmooth_cell{i} = fullfile(dataset_root, dataset, subj_id, 'anat', ...
                ['s', num2str(smoothKernel), 'mwp1', subj_id, '_T1w.nii']);
        end
    end
end

numCovs = 3;
unique_siteIDs = unique(metadata.site);
numSite = length(unique_siteIDs);
fprintf('Processing %d sites for dataset %s\n', numSite, dataset);

for s = 1:numSite
    site_mask = metadata.site == unique_siteIDs(s);
    fprintf('  Site %d/%d (ID: %d)\n', s, numSite, unique_siteIDs(s));

    hcCell = subNiftiSmooth_cell(metadata.diagnosis == 1 & site_mask);
    hc_covs = zeros(length(hcCell), numCovs);
    hc_covs(:,1) = metadata.age(metadata.diagnosis == 1 & site_mask);
    hc_covs(:,2) = metadata.sex(metadata.diagnosis == 1 & site_mask);
    hc_covs(:,3) = tiv_all(metadata.diagnosis == 1 & site_mask);

    patients = metadata(metadata.diagnosis ~= 1 & site_mask, :);
    unique_patIDs = unique(patients.diagnosis);

    for p = 1:length(unique_patIDs)
        pat_mask = metadata.diagnosis == unique_patIDs(p) & site_mask;

        patCell = subNiftiSmooth_cell(pat_mask);
        pat_covs = zeros(length(patCell), numCovs);
        pat_covs(:,1) = metadata.age(pat_mask);
        pat_covs(:,2) = metadata.sex(pat_mask);
        pat_covs(:,3) = tiv_all(pat_mask);

        age = [hc_covs(:,1); pat_covs(:,1)];
        sex = [hc_covs(:,2); pat_covs(:,2)];
        tiv = [hc_covs(:,3); pat_covs(:,3)];

        siteName      = char(metadata.site_string(find(site_mask, 1)));
        diagnosisName = char(metadata.diagnosis_string(find(pat_mask, 1)));

        newSubFolder = fullfile(outDir, diagnosisName, siteName);
        if ~exist(newSubFolder, 'dir'); mkdir(newSubFolder); end
        delete(fullfile(newSubFolder, '*'));

        fprintf('    %s vs HC @ %s\n', diagnosisName, siteName);

        factorial_design_ttest_job(newSubFolder, hcCell, patCell, age, sex, tiv, maskDir);
        spm_file = fullfile(newSubFolder, 'SPM.mat');
        model_estimation_job(spm_file);
        contr_job(spm_file);
        spm('defaults', 'PET');
        report_thres_job(spm_file);
        report_fwe_job(spm_file);
    end
end

fprintf('=== STEP5 COMPLETED: %s ===\n', dataset);
end
