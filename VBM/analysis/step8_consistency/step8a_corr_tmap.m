function step8a_corr_tmap(config)
if nargin < 1 || isempty(config)
    config = 'config_hpc.json';
end
this_dir = fileparts(mfilename('fullpath'));
repo_root = fullfile(this_dir, '..', '..', '..');
addpath(this_dir);
addpath(genpath(fullfile(repo_root, 'utils')));
if ischar(config) || isstring(config)
    config = pipeline_load_config(char(config));
end

iCOMBAT = config.analysis_settings.harmonize;
smoothKernel = config.analysis_settings.vbm_smoothing_kernel;
maskDiagGroup = config.analysis_settings.mask_diagnostic_group;
diagString = {'HC', 'BD', 'SCA', 'SCZ', 'ASD', 'MDD', 'AD'};
data_root = config.data_directories.dataset_root;
if iCOMBAT == 1
    derivDir = fullfile(data_root, 'derivatives', ['s', num2str(smoothKernel), 'COMBAT']);
else
    derivDir = fullfile(data_root, 'derivatives', ['s', num2str(smoothKernel)]);
end
address = [derivDir, filesep];
maskFile = fullfile(derivDir, ['mask_', char(maskDiagGroup)], 'mask.nii');
if ~isfile(maskFile)
    error('VBM mask not found: %s', maskFile);
end
mask = logical(niftiread(maskFile));

metadata = readtable(fullfile(data_root, 'metadataVBM_psy.csv'));
metadataAD = readtable(fullfile(data_root, 'metadataVBM_AD.csv'));
output_dir = fullfile(data_root, 'results', 'VBM', 'analysis', 'output');
if ~exist(output_dir, 'dir'); mkdir(output_dir); end



nDiag = length(diagString) - 1;
cor1 = cell(1, nDiag);
cor2 = cell(1, nDiag);
corThres1 = cell(1, nDiag);
corThres2 = cell(1, nDiag);
repThres1 = cell(1, nDiag);
repThres2 = cell(1, nDiag);
corThresFWE1 = cell(1, nDiag);
corThresFWE2 = cell(1, nDiag);
repThresFWE1 = cell(1, nDiag);
repThresFWE2 = cell(1, nDiag);
siteList = cell(1, nDiag);
siteThresList = cell(1, nDiag);
siteThresFWEList = cell(1, nDiag);
t1All = cell(1, nDiag);
t2All = cell(1, nDiag);
thresmap1 = cell(1, nDiag);
thresmap2 = cell(1, nDiag);
thresmapFWE1 = cell(1, nDiag);
thresmapFWE2 = cell(1, nDiag);

for iSite = 1:nDiag
    diagName = diagString{iSite + 1};
    if iSite == 6
        meta_use = metadataAD;
    else
        meta_use = metadata;
    end
    nDiagSites = numel(unique(meta_use.site_string(ismember(meta_use.diagnosis_string, diagName))));
    if nDiagSites < 2
        fprintf('Skipping %s: found %d site(s); need >=2 to compute correlation.\n', diagName, nDiagSites);
        continue;
    end
    fprintf('Computing correlations for %s: %d sites.\n', diagName, nDiagSites);

    [cor1{iSite}, cor2{iSite}, t1All{iSite}, t2All{iSite}, siteList{iSite}] = cal_corr_tmap(address, meta_use, diagName, mask);
    [corThres1{iSite}, corThres2{iSite}, repThres1{iSite}, repThres2{iSite}, siteThresList{iSite}, thresmap1{iSite}, thresmap2{iSite}] = cal_corr_tmap_thres(address, meta_use, diagName, mask);
    [corThresFWE1{iSite}, corThresFWE2{iSite}, repThresFWE1{iSite}, repThresFWE2{iSite}, siteThresFWEList{iSite}, thresmapFWE1{iSite}, thresmapFWE2{iSite}] = cal_corr_tmap_thres_fwe(address, meta_use, diagName, mask);
end

save(fullfile(output_dir, ['corr_tmap_combat', num2str(iCOMBAT), '_smooth', num2str(smoothKernel), '.mat']), ...
    'cor1', 'cor2','corThres1','corThres2','repThres1','repThres2','corThresFWE1','corThresFWE2', ...
    'repThresFWE1','repThresFWE2',"siteList",'siteThresList','siteThresFWEList','t1All','t2All','thresmap1','thresmap2','thresmapFWE1','thresmapFWE2')
end