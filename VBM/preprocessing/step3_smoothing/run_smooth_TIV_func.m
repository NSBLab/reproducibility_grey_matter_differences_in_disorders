function run_smooth_TIV_func(config_file, dataset)
% Smooth GM images (mwp1) and estimate TIV for one dataset.
%
% Smoothed files are written alongside originals with prefix s<kernel>.
% TIV is written to <dataset_root>/derivatives/s<kernel>/<dataset>_TIV.txt.
%
% Trang Cao, Neural Systems and Behaviour Lab, Monash University, 2024.

if nargin < 2 || isempty(config_file) || isempty(dataset)
    error('Usage: run_smooth_TIV_func(config_file, dataset)');
end

this_dir = fileparts(mfilename('fullpath'));
repo_main = fullfile(this_dir, '..', '..', '..');
addpath(genpath(repo_main));
pipeline_ensure_paths();

config = pipeline_load_config(config_file);

dataset_root  = config.data_directories.dataset_root;
smoothKernel  = config.analysis_settings.smoothing_kernel;
is_longitudinal = isfield(config.datasets, dataset) && ...
                  isfield(config.datasets.(dataset), 'longitudinal') && ...
                  config.datasets.(dataset).longitudinal;

fprintf('=== STEP 3 VBM: SMOOTH + TIV for %s ===\n', dataset);
fprintf('Smoothing kernel: %dmm\n', smoothKernel);

% TIV output directory
tiv_dir = fullfile(dataset_root, 'derivatives', sprintf('s%d', smoothKernel));
if ~exist(tiv_dir, 'dir')
    mkdir(tiv_dir);
end

% Load metadata
metadata_file = fullfile(dataset_root, dataset, sprintf('%s_dems.csv', dataset));
if ~exist(metadata_file, 'file')
    error('Metadata file not found: %s', metadata_file);
end
metadata = readtable(metadata_file, 'Delimiter', ',');

% Build image and CAT12 report file lists
n = size(metadata, 1);
subNifti_cell  = cell(n, 1);
subReport_cell = cell(n, 1);

for i = 1:n
    subj_id = metadata.subj_id{i};
    if is_longitudinal && ismember('ses', metadata.Properties.VariableNames)
        ses = metadata.ses{i};
        subNifti_cell{i}  = fullfile(dataset_root, dataset, subj_id, ses, 'anat', sprintf('mwp1%s_%s_T1w.nii', subj_id, ses));
        subReport_cell{i} = fullfile(dataset_root, dataset, subj_id, ses, 'anat', sprintf('cat_%s_%s_T1w.xml',  subj_id, ses));
    else
        subNifti_cell{i}  = fullfile(dataset_root, dataset, subj_id, 'anat', sprintf('mwp1%s_T1w.nii', subj_id));
        subReport_cell{i} = fullfile(dataset_root, dataset, subj_id, 'anat', sprintf('cat_%s_T1w.xml',  subj_id));
    end
end

% Smooth
smooth_job(subNifti_cell, smoothKernel);

% Estimate TIV
tiv_file = fullfile(tiv_dir, sprintf('%s_TIV.txt', dataset));
estimate_tiv_job(subReport_cell, tiv_file);

fprintf('TIV written to: %s\n', tiv_file);
fprintf('=== DONE %s ===\n', dataset);
end
