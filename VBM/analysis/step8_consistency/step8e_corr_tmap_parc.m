function step8e_corr_tmap_parc(config)
if nargin < 1 || isempty(config)
    config = 'config_hpc.json';
end
this_dir = fileparts(mfilename('fullpath'));
repo_root = fullfile(this_dir, '..', '..', '..');
addpath(genpath(fullfile(repo_root, 'utils')));
if ischar(config) || isstring(config)
    config = pipeline_load_config(char(config));
end

diagString = {'HC', 'BD', 'SCA', 'SCZ', 'ASD', 'MDD', 'AD'};
data_root = config.data_directories.dataset_root;
address = fullfile('derivatives', 'roi');
metadata = readtable(fullfile(data_root, 'metadataVBM.csv'));
output_dir = fullfile(data_root, 'results', 'VBM', 'analysis', 'output');
if ~exist(output_dir, 'dir'); mkdir(output_dir); end
nParc = [100 200 300 400 500 600 700 800 900 1000];

for iParc = 1:length(nParc)
    nDiag = length(diagString) - 1;
    cor1 = cell(1, nDiag);
    corThres1 = cell(1, nDiag);
    rep1 = cell(1, nDiag);
    t1All = cell(1, nDiag);
    t1Thres = cell(1, nDiag);
    siteList = cell(1, nDiag);

    for iDiag = 1:nDiag
        nDiagSites = numel(unique(metadata.site_string(ismember(metadata.diagnosis_string, diagString{iDiag + 1}))));
        if nDiagSites < 2
            fprintf('Skipping %s (parc=%d): found %d site(s); need >=2 to compute correlation.\n', ...
                diagString{iDiag + 1}, nParc(iParc), nDiagSites);
            continue;
        end

        [cor1{iDiag} corThres1{iDiag} rep1{iDiag} t1All{iDiag} t1Thres{iDiag} siteList{iDiag}] = ...
            cal_corr_tmap_parcel(data_root, address, metadata, diagString(iDiag+1), nParc(iParc));

    end

    save(fullfile(output_dir, ['corr_tmap_parc_', num2str(nParc(iParc)), '.mat']), ...
        'cor1', 'corThres1', 'rep1', 't1All', 't1Thres', 'siteList')
    clear cor1 corThres1 rep1 siteList t1All  t1Thres
end
end