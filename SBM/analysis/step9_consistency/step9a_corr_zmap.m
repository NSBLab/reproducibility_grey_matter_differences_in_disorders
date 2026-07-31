function step9a_corr_zmap(config, hemi, iCOMBAT, smoothKernel)
% read all the z-maps and correlate them
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
% list of disorders
diagString = {'HC', 'BD', 'SCA',...
    'SCZ', 'ASD', 'MDD' ,'AD'};

dataDir = config.data_directories.dataset_root;
dataList = pipeline_get_enabled_datasets(config);
% dataFileAD = readtable(fullfile(dataDir,'dataset_list_AD.txt'),'ReadVariableNames',false);
% dataListAD = dataFileAD.Var1;
% dataList = [dataListPS;dataListAD];

iCOMBAT = local_default(iCOMBAT, config.analysis_settings.harmonize);
measureShort = 'thick';
measure = 'thickness';
hemi = char(local_default(hemi, 'lh'));
smoothKernel = local_default(smoothKernel, config.analysis_settings.sbm_smoothing_kernel);
thres=0.05;

% find all sites
map.numericFolders = {};
map.dataSet = {};
for iData = 1:length(dataList)
    diagInSet = dir(fullfile(dataDir, char(dataList(iData))));
    diagName = {diagInSet.name};
    pat = "qdec_" + wildcardPattern+ ".dat";
    isQdecFile = contains(diagName,pat);
    numericFolderInSet = diagName(isQdecFile);

    map.numericFolders((end+1):(end+length(numericFolderInSet))) = numericFolderInSet;
    map.dataSet((end+1):(end+length(numericFolderInSet))) = {char(dataList(iData))};


end

% sort sites  by diagnosis
nSite = length(map.numericFolders);
map.diag = arrayfun(@(x) {map.numericFolders{x}(end-4)}, 1:nSite);

[map.diag iSort] = sort(map.diag);
map.dataSet = map.dataSet(iSort);
map.numericFolders = map.numericFolders(iSort);
for iSite = 1:nSite

    % find site name
    % Split the string using '_' as the delimiter
    parts = strsplit(map.numericFolders{iSite}, '_');

    % Check if there are at least two parts
    if numel(parts) >4
        % Extract the substring between the first and second underscores
        map.site{iSite} = [parts{3},'_',parts{4}];
    else
        % Handle the case where there are not enough underscores
        map.site{iSite} = parts{3};
    end
    if iCOMBAT==0
        qdecFolder = [map.diag{iSite},'_',map.site{iSite}, '_',measureShort,'_smooth',char(num2str(smoothKernel)),'_',hemi,'_sex_age'];
    else
        qdecFolder = [map.diag{iSite},'_',map.site{iSite}, '_',measureShort,'_smooth',char(num2str(smoothKernel)),'_',hemi,'_sex_age_combat'];
    end

    % read maps
    map.zmap(iSite,:) = load_mgh(fullfile(dataDir, char(map.dataSet(iSite)), 'derivatives','freesurfer', ...
        'qdec', qdecFolder, [hemi,'-Diff-1-', char(map.diag(iSite)),'-Intercept-',measure], 'z.mgh'));

    temp = load_mgh(fullfile(dataDir, char(map.dataSet(iSite)), 'derivatives','freesurfer', ...
        'qdec', qdecFolder, [hemi,'-Diff-1-', char(map.diag(iSite)),'-Intercept-',measure], 'sig.mgh'));
    map.sigmapHC_P(iSite,:) = double((10.^(-(temp)))<=thres);
    map.sigmapP_HC(iSite,:) = double((10.^((temp)))<=thres);
    map.polemap(iSite,:) = map.sigmapHC_P(iSite,:)-map.sigmapP_HC(iSite,:);

    [h, crit_p, adj_ci_cvrg, adj_p] = fdr_bh(10.^(-(temp)).*(temp>0)+10.^((temp)).*(temp<=0));
    map.sigFdrmapHC_P(iSite,:) = double((adj_p<=thres).*(temp>0));
    map.sigFdrmapP_HC(iSite,:) = double((adj_p<=thres).*(temp<=0));
    map.poleFdrmap(iSite,:) = sign(temp).*double(adj_p<=thres);

 temp = load_mgh(fullfile(dataDir, char(map.dataSet(iSite)), 'derivatives','freesurfer', ...
        'qdec', qdecFolder, [hemi,'-Diff-1-', char(map.diag(iSite)),'-Intercept-',measure], 'perm.th13.abs.sig.cluster.mgh'));
map.sigClustermapHC_P(iSite,:) = double((temp>0));
    map.sigClustermapP_HC(iSite,:) = double(temp<0);
end
% correlation between sites (need >=2 sites/datasets per disorder)
nDiag = length(diagString) - 1; % exclude HC
corDiag = cell(1, nDiag);
siteList = cell(1, nDiag);
corSigHC_P = cell(1, nDiag);
corSigP_HC = cell(1, nDiag);
repSigHC_P = cell(1, nDiag);
repSigP_HC = cell(1, nDiag);
corSigFdrHC_P = cell(1, nDiag);
corSigFdrP_HC = cell(1, nDiag);
repSigFdrHC_P = cell(1, nDiag);
repSigFdrP_HC = cell(1, nDiag);
corSigClusterHC_P = cell(1, nDiag);
corSigClusterP_HC = cell(1, nDiag);
repSigClusterHC_P = cell(1, nDiag);
repSigClusterP_HC = cell(1, nDiag);

for iDiag = 1:nDiag
    isDiagSite = strcmp(map.diag, num2str(iDiag + 1));
    nDiagSites = sum(isDiagSite);
    if nDiagSites < 2
        fprintf('Skipping %s (diag=%d): found %d site(s); need >=2 to compute correlation.\n', ...
            diagString{iDiag + 1}, iDiag + 1, nDiagSites);
        continue;
    end
    fprintf('Computing correlations for %s (diag=%d): %d sites.\n', ...
        diagString{iDiag + 1}, iDiag + 1, nDiagSites);

    corDiag{iDiag} = corr(map.zmap(isDiagSite,:)');
    siteList{iDiag} = map.site(isDiagSite);

    sigMapHC_P = map.sigmapHC_P(isDiagSite,:);
    sigMapP_HC = map.sigmapP_HC(isDiagSite,:);
    corSigHC_P{iDiag} = bin_corr_mat_account_zero(sigMapHC_P');
    corSigP_HC{iDiag} = bin_corr_mat_account_zero(sigMapP_HC');
    repSigHC_P{iDiag} = replication_mat(sigMapHC_P');
    repSigP_HC{iDiag} = replication_mat(sigMapP_HC');

    sigFdrMapHC_P = map.sigFdrmapHC_P(isDiagSite,:);
    sigFdrMapP_HC = map.sigFdrmapP_HC(isDiagSite,:);
    corSigFdrHC_P{iDiag} = bin_corr_mat_account_zero(sigFdrMapHC_P');
    corSigFdrP_HC{iDiag} = bin_corr_mat_account_zero(sigFdrMapP_HC');
    repSigFdrHC_P{iDiag} = replication_mat(sigFdrMapHC_P');
    repSigFdrP_HC{iDiag} = replication_mat(sigFdrMapP_HC');

    sigClusterMapHC_P = map.sigClustermapHC_P(isDiagSite,:);
    sigClusterMapP_HC = map.sigClustermapP_HC(isDiagSite,:);
    corSigClusterHC_P{iDiag} = bin_corr_mat_account_zero(sigClusterMapHC_P');
    corSigClusterP_HC{iDiag} = bin_corr_mat_account_zero(sigClusterMapP_HC');
    repSigClusterHC_P{iDiag} = replication_mat(sigClusterMapHC_P');
    repSigClusterP_HC{iDiag} = replication_mat(sigClusterMapP_HC');
end

output_dir = fullfile(dataDir, 'results', 'SBM', 'analysis', 'output');
if ~exist(output_dir, 'dir'); mkdir(output_dir); end
save(fullfile(output_dir, ['corr_zmap_combat',num2str(iCOMBAT),'_smooth',num2str(smoothKernel),'_',hemi,'_all.mat']),...
    'map', 'corDiag','corSigHC_P', 'corSigP_HC','corSigFdrHC_P','corSigFdrP_HC', ...
    'repSigHC_P','repSigP_HC','repSigFdrHC_P','repSigFdrP_HC','corSigClusterHC_P','corSigClusterP_HC','repSigClusterHC_P','repSigClusterP_HC','siteList');
end

function out = local_default(value, fallback)
if nargin < 1 || isempty(value)
    out = fallback;
else
    out = value;
end
end
