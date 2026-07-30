function runGLM_parc_func(config, datasets, nParc)
% GLM on parcellated GM maps for one dataset and parcel scale.
%
% Usage:
%   runGLM_parc_func('config_hpc.json', 'Myelin', 100)
%   runGLM_parc_func(config, 'Myelin', 100)

if nargin < 3 || isempty(config) || isempty(datasets) || isempty(nParc)
    error('Usage: runGLM_parc_func(config, dataset, nParc)');
end

this_dir = fileparts(mfilename('fullpath'));
repo_root = fullfile(this_dir, '..', '..', '..');
addpath(this_dir);
addpath(genpath(fullfile(repo_root, 'utils')));

if ischar(config) || isstring(config)
    config = pipeline_load_config(char(config));
end

rng('default')

dataset = char(datasets);
dataset_root = config.data_directories.dataset_root;
smoothKernel = config.analysis_settings.vbm_smoothing_kernel;

isses = isfield(config.datasets, dataset) && ...
        isfield(config.datasets.(dataset), 'longitudinal') && ...
        logical(config.datasets.(dataset).longitudinal);

inDir = dataset_root;
outDir = fullfile(inDir, 'derivatives', 'roi');
if ~exist(outDir, 'dir'); mkdir(outDir); end

fprintf('=== ROI GLM: %s nParc=%d longitudinal=%d ===\n', dataset, nParc, isses);

metadataFilename = fullfile(inDir, dataset, [dataset, '_dems.csv']);
metadata = readtable(metadataFilename, 'delimiter', ',');

subNifti_cell = [];
for i = 1:size(metadata, 1)
    subj_id = metadata.subj_id{i};
    if isses
        ses = metadata.ses{i};
        subNifti = fullfile(inDir, dataset, subj_id, ses, 'anat', ...
            ['mwp1', subj_id, '_', ses, '_T1w_Buckner-whole_1mm_Tian_Subcortex_S1_3T_2009cAsym_Schaefer2018_', char(num2str(nParc)), 'Parcels_7Networks_order_CAT12MNI.mat']);
    else
        subNifti = fullfile(inDir, dataset, subj_id, 'anat', ...
            ['mwp1', subj_id, '_T1w_Buckner-whole_1mm_Tian_Subcortex_S1_3T_2009cAsym_Schaefer2018_', char(num2str(nParc)), 'Parcels_7Networks_order_CAT12MNI.mat']);
    end
    parMap = load(subNifti);
    subNifti_cell(i, :) = parMap.volParc;
end

% TIV from derivatives/s{K}/
tiv_src = fullfile(inDir, 'derivatives', ['s', num2str(smoothKernel)], [dataset, '_TIV.txt']);
tiv_filename = fullfile(outDir, [dataset, '_TIV.txt']);
if ~exist(tiv_filename, 'file')
    if ~exist(tiv_src, 'file')
        error('TIV file not found: %s', tiv_src);
    end
    copyfile(tiv_src, tiv_filename);
end
tiv = readtable(tiv_filename, 'ReadVariableNames', false);
tiv_all = table2array(tiv);

numCovs = 4;
unique_siteIDs = unique(metadata.site);
numSite = size(unique_siteIDs, 1);

for s = 1:numSite
    hcCell = subNifti_cell(metadata.diagnosis == 1 & metadata.site == unique_siteIDs(s), :);

    hc_covs = ones(size(hcCell, 1), numCovs);
    hc_covs(:, 2) = metadata.age(metadata.diagnosis == 1 & metadata.site == unique_siteIDs(s));
    hc_covs(:, 3) = metadata.sex(metadata.diagnosis == 1 & metadata.site == unique_siteIDs(s));
    hc_covs(:, 4) = tiv_all(metadata.diagnosis == 1 & metadata.site == unique_siteIDs(s));

    patients = metadata(metadata.diagnosis ~= 1 & metadata.site == unique_siteIDs(s), :);
    unique_patIDs = unique(patients.diagnosis);
    numPatGroups = size(unique_patIDs, 1);

    for i = 1:numPatGroups
        patCell = subNifti_cell(metadata.diagnosis == unique_patIDs(i) & metadata.site == unique_siteIDs(s), :);

        pat_covs = zeros(size(patCell, 1), numCovs);
        pat_covs(:, 2) = metadata.age(metadata.diagnosis == unique_patIDs(i) & metadata.site == unique_siteIDs(s));
        pat_covs(:, 3) = metadata.sex(metadata.diagnosis == unique_patIDs(i) & metadata.site == unique_siteIDs(s));
        pat_covs(:, 4) = tiv_all(metadata.diagnosis == unique_patIDs(i) & metadata.site == unique_siteIDs(s));

        covariates = [hc_covs; pat_covs];
        inputMap = [hcCell; patCell];

        siteName = metadata.site_string(metadata.site == unique_siteIDs(s));
        siteName = char(siteName(1));

        diagnosisName = metadata.diagnosis_string(metadata.diagnosis == unique_patIDs(i));
        diagnosisName = char(diagnosisName(1));

        newSubFolder = fullfile(outDir, diagnosisName, siteName);
        if ~exist(newSubFolder, 'dir')
            mkdir(newSubFolder);
        end

        stat.thres = 0.05;
        for iRoi = 1:size(inputMap, 2)
            mdl = fitlm(covariates, inputMap(:, iRoi));
            % Coefficients row 2 is the group (intercept is 1; age/sex/tiv follow in design)
            stat.tMap(iRoi) = mdl.Coefficients.tStat(2);
            pValue(iRoi) = mdl.Coefficients.pValue(2);
        end
        stat.thresMap = zeros(size(stat.tMap));
        stat.thresMap(pValue <= stat.thres) = 1;
        save(fullfile(newSubFolder, [char(num2str(nParc)), '_parcCon.mat']), 'stat');
    end
end

fprintf('=== ROI GLM DONE: %s nParc=%d ===\n', dataset, nParc);
end
