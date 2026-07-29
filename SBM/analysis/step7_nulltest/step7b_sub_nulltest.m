function step7b_sub_nulltest(config, iCOMBAT, hemi, smoothKernel, nTrap, inJob)
% Eigentrapping null test for one job index.
%
% Usage:
%   step7b_sub_nulltest('config_hpc.json', 1, 'lh', 10, 10, 1)
%   step7b_sub_nulltest(config, iCOMBAT, hemi, smoothKernel, nTrap, inJob)

if nargin < 6
    error('Usage: step7b_sub_nulltest(config, iCOMBAT, hemi, smoothKernel, nTrap, inJob)');
end

this_dir = fileparts(mfilename('fullpath'));
repo_root = fullfile(this_dir, '..', '..', '..');
utils_dir = fullfile(repo_root, 'utils');
addpath(this_dir);
addpath(genpath(utils_dir));   % utils/ + utils/modes/ (calc_eigenstrap, ...)


if ischar(config) || isstring(config)
    config = pipeline_load_config(char(config));
end

dataDir = config.data_directories.dataset_root;
dataList = pipeline_get_enabled_datasets(config);

if isempty(iCOMBAT)
    iCOMBAT = config.analysis_settings.harmonize;
end
if isempty(smoothKernel)
    smoothKernel = config.analysis_settings.sbm_smoothing_kernel;
end

fprintf('=== STEP7B: EIGENTRAPPING ===\n');
fprintf('dataDir=%s  hemi=%s  smooth=%d  combat=%d  inJob=%d\n', ...
    dataDir, hemi, smoothKernel, iCOMBAT, inJob);

measureShort = 'thick';
measure = 'thickness';
thres = 0.05;

eigenFile = fullfile(dataDir, ['eigenStruct_', hemi, '.mat']);
if ~exist(eigenFile, 'file')
    error('eigenStruct not found: %s\nRun step7a_precal_eigenmode first.', eigenFile);
end
load(eigenFile); %#ok<LOAD>
rng(inJob);

% find all sites from enabled datasets
map.numericFolders = {};
map.dataSet = {};
for iData = 1:length(dataList)
    diagInSet = dir(fullfile(dataDir, char(dataList{iData})));
    diagName = {diagInSet.name};
    pat = "qdec_" + wildcardPattern + ".dat";
    isQdecFile = contains(diagName, pat);
    numericFolderInSet = diagName(isQdecFile);

    map.numericFolders((end+1):(end+length(numericFolderInSet))) = numericFolderInSet;
    map.dataSet((end+1):(end+length(numericFolderInSet))) = dataList(iData);
end

nSite = length(map.numericFolders);
if nSite < 1
    error('No qdec_*.dat site tables found under enabled datasets in %s', dataDir);
end

map.diag = arrayfun(@(x) {map.numericFolders{x}(end-4)}, 1:nSite);
[map.diag, iSort] = sort(map.diag);
map.dataSet = map.dataSet(iSort);
map.numericFolders = map.numericFolders(iSort);

for iSite = 1:nSite
    parts = strsplit(map.numericFolders{iSite}, '_');
    if numel(parts) > 4
        map.site{iSite} = [parts{3}, '_', parts{4}];
    else
        map.site{iSite} = parts{3};
    end
    if iCOMBAT == 0
        qdecFolder = [map.diag{iSite}, '_', map.site{iSite}, '_', measureShort, '_smooth', ...
            char(num2str(smoothKernel)), '_', hemi, '_sex_age'];
    else
        qdecFolder = [map.diag{iSite}, '_', map.site{iSite}, '_', measureShort, '_smooth', ...
            char(num2str(smoothKernel)), '_', hemi, '_sex_age_combat'];
    end

    map.zmap(iSite, :) = load_mgh(fullfile(dataDir, char(map.dataSet(iSite)), 'derivatives', 'freesurfer', ...
        'qdec', qdecFolder, [hemi, '-Diff-1-', char(map.diag(iSite)), '-Intercept-', measure], 'z.mgh'));

    temp = load_mgh(fullfile(dataDir, char(map.dataSet(iSite)), 'derivatives', 'freesurfer', ...
        'qdec', qdecFolder, [hemi, '-Diff-1-', char(map.diag(iSite)), '-Intercept-', measure], 'sig.mgh'));
    map.sigmapHC_P(iSite, :) = double((10.^(-(temp))) <= thres);
    map.sigmapP_HC(iSite, :) = double((10.^((temp))) <= thres);

    [~, ~, ~, adj_p] = fdr_bh(10.^(-(temp)).*(temp > 0) + 10.^((temp)).*(temp <= 0));
    map.sigFdrmapHC_P(iSite, :) = double((adj_p <= thres).*(temp > 0));
    map.sigFdrmapP_HC(iSite, :) = double((adj_p <= thres).*(temp <= 0));

    temp = load_mgh(fullfile(dataDir, char(map.dataSet(iSite)), 'derivatives', 'freesurfer', ...
        'qdec', qdecFolder, [hemi, '-Diff-1-', char(map.diag(iSite)), '-Intercept-', measure], ...
        'perm.th13.abs.sig.cluster.mgh'));
    map.sigClustermapHC_P(iSite, :) = double((temp > 0));
    map.sigClustermapP_HC(iSite, :) = double(temp < 0);
end

outRoot = fullfile(dataDir, 'derivatives', 'eigentrap');
if ~exist(outRoot, 'dir'); mkdir(outRoot); end

for iSite = 1:nSite
    [s, zmapSurrs] = calc_eigenstrap(s, 'map', map.zmap(iSite, s.mask == 1)', ...
        'nSurrogates', nTrap, 'save', false); %#ok<ASGLU>

    N_HC_P = sum(map.sigmapHC_P(iSite, :));
    N_P_HC = sum(map.sigmapP_HC(iSite, :));
    Nfdr_HC_P = sum(map.sigFdrmapHC_P(iSite, :));
    Nfdr_P_HC = sum(map.sigFdrmapP_HC(iSite, :));
    NCluster_HC_P = sum(map.sigClustermapHC_P(iSite, :));
    NCluster_P_HC = sum(map.sigClustermapP_HC(iSite, :));

    sigmapSurrs_HC_P = zeros(size(zmapSurrs));
    sigmapSurrs_P_HC = zeros(size(zmapSurrs));
    sigFdrmapSurrs_HC_P = zeros(size(zmapSurrs));
    sigFdrmapSurrs_P_HC = zeros(size(zmapSurrs));
    sigClustermapSurrs_HC_P = zeros(size(zmapSurrs));
    sigClustermapSurrs_P_HC = zeros(size(zmapSurrs));

    [~, idx_sorted_HC_P] = sort(zmapSurrs, 'descend');
    top_indices_HC_P = idx_sorted_HC_P(1:N_HC_P, :);
    [~, idx_sorted_P_HC] = sort(zmapSurrs, 'ascend');
    top_indices_P_HC = idx_sorted_P_HC(1:N_P_HC, :);

    top_indices_fdrHC_P = idx_sorted_HC_P(1:Nfdr_HC_P, :);
    top_indices_fdrP_HC = idx_sorted_P_HC(1:Nfdr_P_HC, :);
    top_indices_ClusterHC_P = idx_sorted_HC_P(1:NCluster_HC_P, :);
    top_indices_ClusterP_HC = idx_sorted_P_HC(1:NCluster_P_HC, :);

    for iCol = 1:nTrap
        sigmapSurrs_HC_P(top_indices_HC_P(:, iCol), iCol) = 1;
        sigmapSurrs_P_HC(top_indices_P_HC(:, iCol), iCol) = 1;
        sigFdrmapSurrs_HC_P(top_indices_fdrHC_P(:, iCol), iCol) = 1;
        sigFdrmapSurrs_P_HC(top_indices_fdrP_HC(:, iCol), iCol) = 1;
        sigClustermapSurrs_HC_P(top_indices_ClusterHC_P(:, iCol), iCol) = 1;
        sigClustermapSurrs_P_HC(top_indices_ClusterP_HC(:, iCol), iCol) = 1;
    end

    siteOut = fullfile(outRoot, char(map.site{iSite}));
    if ~exist(siteOut, 'dir'); mkdir(siteOut); end
    outFile = fullfile(siteOut, [map.numericFolders{iSite}(1:end-4), ...
        '_combat', char(num2str(iCOMBAT)), '_', hemi, '_smooth', char(num2str(smoothKernel)), ...
        '_', char(num2str(inJob)), '.mat']);
    save(outFile, 'zmapSurrs', 'sigmapSurrs_HC_P', 'sigmapSurrs_P_HC', ...
        'sigFdrmapSurrs_HC_P', 'sigFdrmapSurrs_P_HC', ...
        'sigClustermapSurrs_HC_P', 'sigClustermapSurrs_P_HC');
    fprintf('Saved: %s\n', outFile);
end

fprintf('=== STEP7B COMPLETED (inJob=%d) ===\n', inJob);
end
