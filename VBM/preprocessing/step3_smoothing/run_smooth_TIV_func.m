function run_smooth_TIV_func
% This script
%   1.SPM: Smooth (8mm) - voxel intensities become a weighted average of the
%       surrounding voxels. This is required to render the data more normally
%       distributed and to correct for some error in the registration process.
%   2. SPM: Estimate TIV - Total intracanial volume(TIV) interates GM, VM, and
%       CSF, or attempts to measure the skull volume directly. TIV is modelled
%       as a confounding parameter. Note: We want it to be orthogonal
%       (independent) to any other parameter of interest (ie no correlation).
%       Othwewise not only the ariance explained by TIV is removed from your
%       data, but also parts of the variance of your parameter of interest.
%       The larger the correlation between TIV and any parameter of interest
%       the more the need to not use TIV as nuisance parameter. In this case
%       an alternative approach is to use global scaling with TIV.
%   3. SPM: Basic Models - specific a design matric that explains how the preprocessed
%       data are cause
%   5. SPM: Estiamte - To actually fit the GLM to the data

% Additional steps required not avaliable through batch:
%   4. SPM: Review - to see what is in the design matrix and generally poke about.
%   6. SPM: Results - to identify any significant differences and to generate tmap files

% Input: datasets - dataset name, isses - session flag, smoothKernel - smoothing kernel size, data_root - data root directory

rng('default')

% ------------------------------------------------------------
% Prep
% ------------------------------------------------------------

smoothData = true;
calculateTIV = true;
isses = 1;
smoothKernel =6;
dataset = 'Myelin';
data_root = '/projects/kg98/trangc/VBM/data_exemplar';

% dataset = char(datasets);

% Use provided data_root or fallback to environment variable
if nargin < 4 || isempty(data_root)
    data_root = getenv('DATA_ROOT');
    if isempty(data_root)
        error('data_root parameter not provided and DATA_ROOT environment variable not set.');
    end
end

% Directories
inDir = data_root;
outDir = fullfile(inDir, 'derivatives', ['s', num2str(smoothKernel)]);

% Load in metadata
metadataFilename = fullfile(inDir, dataset, [dataset, '_dems.csv']);
metadata = readtable(metadataFilename, 'delimiter',',');

% Get list of preprocessed nifti images and cat12 reports
subNifti_cell = {};
subReport_cell = {};

for i=1:size(metadata,1)
    subj_id = metadata.subj_id{i};
    if isses == 1
        ses = metadata.ses{i};
        subNifti = fullfile(inDir, dataset, subj_id, ses, 'anat', ['mwp1', subj_id, '_', ses, '_T1w.nii']);
        subReport = fullfile(inDir, dataset, subj_id, ses, 'anat', ['cat_', subj_id, '_', ses, '_T1w.xml']);
    else
        subNifti = fullfile(inDir, dataset, subj_id, 'anat', ['mwp1', subj_id, '_T1w.nii']);
        subReport = fullfile(inDir, dataset, subj_id, 'anat', ['cat_', subj_id, '_T1w.xml']);
    end

    subNifti_cell{i} = subNifti;
    subReport_cell{i} = subReport;
end

subNifti_cell = subNifti_cell'; % transpose so its in the correct format for functions
subReport_cell = subReport_cell';

% Smooth nifti images
if smoothData == 1
    smooth_job(subNifti_cell, smoothKernel)
end

% Calculate TIV
tiv_filename = fullfile(outDir, [dataset, '_TIV.txt']);
if calculateTIV == 1
    estimate_tiv_job(subReport_cell, tiv_filename);
end


end
