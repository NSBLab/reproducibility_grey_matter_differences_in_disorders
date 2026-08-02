function step9b_corr_tmap_var_sex(config, iter, type)
% STEP9B: Sex counts and sex ratio between sites vs t-map correlation.
% Usage: step9b_corr_tmap_var_sex(config [, iter, type]). Prereq: step8a.
% Writes: confound_sex.mat under results/VBM/analysis/output/.
% --- Load config and set paths ---
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

% --- Paths from config ---
iCOMBAT = config.analysis_settings.harmonize;
smoothKernel = config.analysis_settings.vbm_smoothing_kernel;
data_root = config.data_directories.dataset_root;
output_dir = fullfile(data_root, 'results', 'VBM', 'analysis', 'output');
if ~exist(output_dir, 'dir'); mkdir(output_dir); end

% --- Analysis parameters ---
iter = local_default(iter, 5000);
type = char(local_default(type, 'spearman'));
diagnosisString = {'BD', 'SCA', 'SCZ', 'ASD', 'MDD', 'AD'};
nDiag = length(diagnosisString);

% --- Load metadata and cross-site correlation matrices ---
metadata = readtable(fullfile(data_root, 'metadataVBM_extended.csv'));
corrMat = fullfile(output_dir, ['corr_tmap_combat', num2str(iCOMBAT), '_smooth', num2str(smoothKernel), '.mat']);
load(corrMat, 'cor1', 'cor2', 'siteList');

% --- Mantel test per diagnosis ---
varTable = cell(nDiag, 1);
nSite = cell(nDiag, 1);
for iDiag = 1:nDiag
    [varTable{iDiag}, nSite{iDiag}] = cor_var_sex(metadata, diagnosisString(iDiag), cor1{iDiag}, cor2{iDiag}, siteList{iDiag}, iter, type);
    if ~isempty(varTable{iDiag})
        disp(char(diagnosisString(iDiag)));
        disp(varTable{iDiag});
        disp(' ');
    end
end
% --- Save confound results ---
warning('off', 'last');
save(fullfile(output_dir, 'confound_sex.mat'), 'varTable', 'nSite');
end

function out = local_default(value, fallback)
if nargin < 1 || isempty(value)
    out = fallback;
else
    out = value;
end
end
