function step8b_binarize_tmap_brainsmash_null(config)
% Function to compute correlation matrices for surrogate null maps.
% Inputs:
%   iNull       - Index for selecting a specific surrogate null map.
%   iCOMBAT     - Flag indicating if COMBAT harmonization is applied (1 = yes, 0 = no).
%   smoothKernel - Smoothing kernel size used in preprocessing.
if nargin < 1 || isempty(config)
    config = 'config_hpc.json';
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
nNull = 10;
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

    for iSite = 1:nSite
            % Initialize sigsurr as zeros
    sigmapSurrs_HC_P = zeros(sum( mask>0,'all'),1);
    sigmapSurrs_P_HC = zeros(sum( mask>0,'all'),1);
    sigFwemapSurrs_HC_P = zeros(sum( mask>0,'all'),1);
    sigFwemapSurrs_P_HC = zeros(sum( mask>0,'all'),1);
        % read the tmap
        binarymap1 = niftiread(fullfile(data_root, 'derivatives', ['s', char(num2str(smoothKernel)), 'COMBAT'], char(diagnosisString), char(siteString(iSite)), 'spmT_0001_binary.nii'));
        fwemap1 = niftiread(fullfile(data_root, 'derivatives', ['s', char(num2str(smoothKernel)), 'COMBAT'], char(diagnosisString), char(siteString(iSite)), 'spmT_0001_binary_fwe.nii'));
        binarymap2 = niftiread(fullfile(data_root, 'derivatives', ['s', char(num2str(smoothKernel)), 'COMBAT'], char(diagnosisString), char(siteString(iSite)), 'spmT_0002_binary.nii'));
        fwemap2 = niftiread(fullfile(data_root, 'derivatives', ['s', char(num2str(smoothKernel)), 'COMBAT'], char(diagnosisString), char(siteString(iSite)), 'spmT_0002_binary_fwe.nii'));

        % Count number of significant points
        N_HC_P = sum( binarymap1,'all');
        N_P_HC = sum( binarymap2,'all');
        Nfwe_HC_P = sum( fwemap1,'all');
        Nfwe_P_HC = sum( fwemap2,'all');
        countSite = 0;
        for iNull = 1:nNull
            file1 = fullfile(address, char(diagnosisString), char(siteString(iSite)), ['spmT_0001_surrogate_', char(num2str(iNull)), '.nii.gz'])
            % file1 = ([address,'/',char(diagnosisString),'/',char(siteString(iSite)),'/spmT_0001_surrogate_',char(num2str(iNull)),'.txt'])
            % Construct the file path for the surrogate map of the current site.
            if exist(file1,'file')
                surrogateMap = niftiread(file1);
                % surrogateMap = dlmread(file1);
                % Read and reshape the surrogate masked map into a matrix with 1000 columns.
                countSite = countSite + 1;
                mapAllNull(:,countSite) = double(surrogateMap(mask>0)) ;




                % Find indices of the N largest values in zmap
                [~, idx_sorted_HC_P] = sort( mapAllNull(:,countSite), 'descend');
                top_indices_HC_P = idx_sorted_HC_P(1:N_HC_P,:);
                [~, idx_sorted_P_HC] = sort( mapAllNull(:,countSite), 'ascend');
                top_indices_P_HC = idx_sorted_P_HC(1:N_P_HC,:);

                top_indices_fweHC_P = idx_sorted_HC_P(1:Nfwe_HC_P,:);
                top_indices_fweP_HC = idx_sorted_P_HC(1:Nfwe_P_HC,:);
                % Set the top N points to 1
                sigmapSurrs_HC_P(top_indices_HC_P,countSite) = 1;
                sigmapSurrs_P_HC(top_indices_P_HC,countSite) = 1;
                sigFwemapSurrs_HC_P(top_indices_fweHC_P,countSite) = 1;
                sigFwemapSurrs_P_HC(top_indices_fweP_HC,countSite) = 1;
            end

        end
        size(sigFwemapSurrs_HC_P)
        size(sigFwemapSurrs_P_HC)
        save(fullfile(address, char(diagnosisString), char(siteString(iSite)), 'binary_surrogate_maps.mat'), ...
            'mapAllNull', 'sigmapSurrs_HC_P', 'sigmapSurrs_P_HC', 'sigFwemapSurrs_HC_P', 'sigFwemapSurrs_P_HC')
        clear mapAllNull sigmapSurrs_HC_P sigmapSurrs_P_HC sigFwemapSurrs_HC_P sigFwemapSurrs_P_HC
    end

    % corNull{iDiag} = corr(mapAllNull');
    % corsigmapSurrs_HC_P{iDiag} = bin_corr_mat_account_zero(sigmapSurrs_HC_P);
    % corsigmapSurrs_P_HC{iDiag} = bin_corr_mat_account_zero(sigmapSurrs_P_HC);
    % repsigmapSurrs_HC_P{iDiag} = replication_mat(sigmapSurrs_HC_P);
    % repsigmapSurrs_P_HC{iDiag} = replication_mat(sigmapSurrs_P_HC);
    % corsigFwemapSurrs_HC_P{iDiag} = bin_corr_mat_account_zero(sigFwemapSurrs_HC_P);
    % corsigFwemapSurrs_P_HC{iDiag} = bin_corr_mat_account_zero(sigFwemapSurrs_P_HC);
    % repsigFwemapSurrs_HC_P{iDiag} = replication_mat(sigFwemapSurrs_HC_P);
    % repsigFwemapSurrs_P_HC{iDiag} = replication_mat(sigFwemapSurrs_P_HC);
    % Compute the correlation matrix across all surrogate maps for the current diagnosis.

    % Clear the temporary variable to free memory.
end

% save(['output/corr_null_tmap_brainsmash_combat',char(num2str(iCOMBAT)),'_smooth',char(num2str(smoothKernel)),'_',char(num2str(iNull)),'.mat'], 'corNull', ...
%     'corsigmapSurrs_HC_P','corsigmapSurrs_P_HC','repsigmapSurrs_HC_P','repsigmapSurrs_P_HC',...
%     'corsigFwemapSurrs_HC_P','corsigFwemapSurrs_P_HC','repsigFwemapSurrs_HC_P','repsigFwemapSurrs_P_HC');
% Save the resulting correlation matrices to a MAT file, with a name that includes COMBAT, smoothing kernel, and null index information.


end
