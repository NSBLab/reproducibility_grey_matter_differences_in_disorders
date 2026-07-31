function corr_tmap_brainsmash_null_func(config, iNull)
% Function to compute correlation matrices for surrogate null maps.
% Inputs:
%   iNull       - Index for selecting a specific surrogate null map.
%   iCOMBAT     - Flag indicating if COMBAT harmonization is applied (1 = yes, 0 = no).
%   smoothKernel - Smoothing kernel size used in preprocessing.

if nargin < 2 || isempty(config) || isempty(iNull)
    error('Usage: corr_tmap_brainsmash_null_func(config, iNull)');
end
this_dir = fileparts(mfilename('fullpath'));
repo_root = fullfile(this_dir, '..', '..', '..');
addpath(genpath(fullfile(repo_root, 'utils')));
if ischar(config) || isstring(config)
    config = pipeline_load_config(char(config));
end

diagString = {'HC', 'BD', 'SCA',...
    'SCZ', 'ASD', 'MDD' ,'AD'};
% Define diagnostic labels for analysis. First one ('HC') is excluded from `nDiag`.
iCOMBAT = config.analysis_settings.harmonize;
smoothKernel = config.analysis_settings.vbm_smoothing_kernel;
data_root = config.data_directories.dataset_root;
nNull = 100;
nDiag = length(diagString)-1;
% Number of diagnostic groups to process, excluding 'HC'.

if iCOMBAT == 1
    address = fullfile(data_root, 'nulltest', 'surrogateVBM', ['s', num2str(smoothKernel), 'COMBAT']);
else
    address = fullfile(data_root, 'nulltest', 'surrogateVBM', ['s', num2str(smoothKernel)]);
end
% Construct the directory path based on the smoothing kernel and COMBAT flag.

metadata = readtable(fullfile(data_root, 'metadataVBM.csv'));
% metadataAD = readtable(['/projects/kg98/trangc/VBM/data/metadataVBM_AD.csv']);
% % Load metadata for psychiatric and Alzheimer's datasets.


corNull = cell(nDiag,1);
corsigmapSurrs_HC_P = cell(nDiag,1);
corsigmapSurrs_P_HC = cell(nDiag,1);
repsigmapSurrs_HC_P = cell(nDiag,1);
repsigmapSurrs_P_HC = cell(nDiag,1);
corsigFwemapSurrs_HC_P = cell(nDiag,1);
corsigFwemapSurrs_P_HC = cell(nDiag,1);
repsigFwemapSurrs_HC_P = cell(nDiag,1);
repsigFwemapSurrs_P_HC = cell(nDiag,1);
% Initialize a cell array to store correlation matrices for each diagnosis.

for iDiag = 1:nDiag
    iDiag
    % Display the current diagnostic group index (for debugging/monitoring).

    if iDiag ~= nDiag
        mask = logical(niftiread(fullfile(data_root, 'derivatives', ['s', char(num2str(smoothKernel)), 'COMBAT'], 'mask_psy', 'mask.nii')));
    else
        mask = logical(niftiread(fullfile(data_root, 'derivatives', ['s', char(num2str(smoothKernel)), 'COMBAT'], 'mask_AD', 'mask.nii')));
    end
    % % Load binary masks for region selection.


    [LaDiag LbDiag] = ismember(metadata.diagnosis,(iDiag+1));
    % Logical index for matching the current diagnosis in metadata.

    [siteString ia ic] = unique(metadata.site_string(LaDiag));
    % Identify unique site strings for individuals in the current diagnostic group.

    [diagnosisString ia ic] = unique(metadata.diagnosis_string(LaDiag));
    % Identify unique diagnosis strings (stratified by diagnosis).

    nSite = length(siteString);

    % Determine the number of unique sites for the current diagnostic group.
    if nSite < 2
        fprintf('Skipping %s (diag=%d): found %d site(s); need >=2 to compute correlation.\n', ...
            diagString{iDiag + 1}, iDiag + 1, nSite);
        continue;
    end
    mapAllNullall = zeros(sum( mask>0,'all'),nSite);
    sigFwemapSurrs_HC_Pall = zeros(sum( mask>0,'all'),nSite);
    sigmapSurrs_P_HCall = zeros(sum( mask>0,'all'),nSite);
    sigFwemapSurrs_HC_Pall = zeros(sum( mask>0,'all'),nSite);
    sigFwemapSurrs_P_HCall = zeros(sum( mask>0,'all'),nSite);
    for iSite = 1:nSite
        char(siteString(iSite))
        map = load(fullfile(address, char(diagnosisString), char(siteString(iSite)), 'binary_surrogate_maps.mat'), ...
            'mapAllNull', 'sigmapSurrs_HC_P', 'sigmapSurrs_P_HC', 'sigFwemapSurrs_HC_P', 'sigFwemapSurrs_P_HC');
        mapAllNullall(:,iSite) = map.mapAllNull(:,iNull);
        sigmapSurrs_HC_Pall(:,iSite) = map.sigmapSurrs_HC_P(:,iNull);
        sigmapSurrs_P_HCall(:,iSite) = map.sigmapSurrs_P_HC(:,iNull);
        if size(map.sigFwemapSurrs_HC_P,1) > 0
            sigFwemapSurrs_HC_Pall(:,iSite) = map.sigFwemapSurrs_HC_P(:,iNull);
        end
        if size(map.sigFwemapSurrs_P_HC,1) > 0
            sigFwemapSurrs_P_HCall(:,iSite) = map.sigFwemapSurrs_P_HC(:,iNull);
        end

    end
    corNull{iDiag} = corr(mapAllNullall);
    corsigmapSurrs_HC_P{iDiag} = bin_corr_mat_account_zero(sigmapSurrs_HC_Pall);
    corsigmapSurrs_P_HC{iDiag} = bin_corr_mat_account_zero(sigmapSurrs_P_HCall);
    repsigmapSurrs_HC_P{iDiag} = replication_mat(sigmapSurrs_HC_Pall);
    repsigmapSurrs_P_HC{iDiag} = replication_mat(sigmapSurrs_P_HCall);
    corsigFwemapSurrs_HC_P{iDiag} = bin_corr_mat_account_zero(sigFwemapSurrs_HC_Pall);
    corsigFwemapSurrs_P_HC{iDiag} = bin_corr_mat_account_zero(sigFwemapSurrs_P_HCall);
    repsigFwemapSurrs_HC_P{iDiag} = replication_mat(sigFwemapSurrs_HC_Pall);
    repsigFwemapSurrs_P_HC{iDiag} = replication_mat(sigFwemapSurrs_P_HCall);
    % Compute the correlation matrix across all surrogate maps for the current diagnosis.

    clear mapAllNullall sigmapSurrs_HC_Pall  sigmapSurrs_P_HCall  sigFwemapSurrs_HC_Pall  sigFwemapSurrs_P_HCall
    % Clear the temporary variable to free memory.
end

output_dir = fullfile(data_root, 'results', 'VBM', 'analysis', 'output');
if ~exist(output_dir, 'dir'); mkdir(output_dir); end
save(fullfile(output_dir, ['corr_null_tmap_brainsmash_combat', char(num2str(iCOMBAT)), '_smooth', char(num2str(smoothKernel)), '_', char(num2str(iNull)), '.mat']), 'corNull', ...
    'corsigmapSurrs_HC_P','corsigmapSurrs_P_HC','repsigmapSurrs_HC_P','repsigmapSurrs_P_HC',...
    'corsigFwemapSurrs_HC_P','corsigFwemapSurrs_P_HC','repsigFwemapSurrs_HC_P','repsigFwemapSurrs_P_HC');
% Save the resulting correlation matrices to a MAT file, with a name that includes COMBAT, smoothing kernel, and null index information.

end
% End of the function.
