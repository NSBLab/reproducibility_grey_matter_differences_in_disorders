function step8a_corr_tmap(config)
if nargin < 1 || isempty(config)
    config = 'config_hpc.json';
end
this_dir = fileparts(mfilename('fullpath'));
repo_root = fullfile(this_dir, '..', '..', '..');
addpath(genpath(fullfile(repo_root, 'utils')));
if ischar(config) || isstring(config)
    config = pipeline_load_config(char(config));
end

iCOMBAT = config.analysis_settings.harmonize;
smoothKernel = config.analysis_settings.vbm_smoothing_kernel;
diagString = {'HC', 'BD', 'SCA', 'SCZ', 'ASD', 'MDD', 'AD'};
data_root = config.data_directories.dataset_root;
if iCOMBAT == 1
    address = fullfile(data_root, 'derivatives', ['s', num2str(smoothKernel), 'COMBAT']);
else
    address = fullfile(data_root, 'derivatives', ['s', num2str(smoothKernel)]);
end
address = [address, filesep];

metadata = readtable(fullfile(data_root, 'metadataVBM_psy.csv'));
metadataAD = readtable(fullfile(data_root, 'metadataVBM_AD.csv'));
mask = logical(niftiread(fullfile(data_root, 'derivatives', ['s', char(num2str(smoothKernel)), 'COMBAT'], 'mask_psy', 'mask.nii')));
maskAD = logical(niftiread(fullfile(data_root, 'derivatives', ['s', char(num2str(smoothKernel)), 'COMBAT'], 'mask_AD', 'mask.nii')));
output_dir = fullfile(data_root, 'results', 'VBM', 'analysis', 'output');
if ~exist(output_dir, 'dir'); mkdir(output_dir); end



for iSite = 1:length(diagString)-1

    if iSite==6
        [cor1{iSite}, cor2{iSite}, t1All{iSite}, t2All{iSite}, siteList{iSite}] = cal_corr_tmap(address, metadataAD, diagString(iSite+1), maskAD);
    [corThres1{iSite}, corThres2{iSite}, repThres1{iSite}, repThres2{iSite},siteThresList{iSite},thresmap1{iSite},thresmap2{iSite}] = cal_corr_tmap_thres(address, metadataAD, diagString(iSite+1), maskAD);
[corThresFWE1{iSite}, corThresFWE2{iSite},repThresFWE1{iSite}, repThresFWE2{iSite}, siteThresFWEList{iSite},thresmapFWE1{iSite},thresmapFWE2{iSite}] = cal_corr_tmap_thres_fwe(address, metadataAD, diagString(iSite+1), maskAD);

    else
        [cor1{iSite}, cor2{iSite}, t1All{iSite}, t2All{iSite}, siteList{iSite}] = cal_corr_tmap(address, metadata, diagString(iSite+1), mask);
    [corThres1{iSite}, corThres2{iSite}, repThres1{iSite}, repThres2{iSite}, siteThresList{iSite},thresmap1{iSite},thresmap2{iSite}] = cal_corr_tmap_thres(address, metadata, diagString(iSite+1), mask);
[corThresFWE1{iSite}, corThresFWE2{iSite},repThresFWE1{iSite}, repThresFWE2{iSite}, siteThresFWEList{iSite},thresmapFWE1{iSite},thresmapFWE2{iSite}] = cal_corr_tmap_thres_fwe(address, metadata, diagString(iSite+1), mask);
 
    end
end

save(fullfile(output_dir, ['corr_tmap_combat', num2str(iCOMBAT), '_smooth', num2str(smoothKernel), '.mat']), ...
    'cor1', 'cor2','corThres1','corThres2','repThres1','repThres2','corThresFWE1','corThresFWE2', ...
    'repThresFWE1','repThresFWE2',"siteList",'siteThresList','siteThresFWEList','t1All','t2All','thresmap1','thresmap2','thresmapFWE1','thresmapFWE2')
end