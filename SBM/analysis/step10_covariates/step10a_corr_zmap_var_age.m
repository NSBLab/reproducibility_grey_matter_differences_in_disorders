function step10a_corr_zmap_var_age(config, hemi, iter, type)
% STEP10A: Age confound (mean and variance ratios between sites vs z-map correlation).
%
% Usage: step10a_corr_zmap_var_age('config_hpc.json')
%        step10a_corr_zmap_var_age(config, 'rh', 5000, 'spearman')
% Prereq: step9a_corr_zmap (corr_zmap_combat*_<hemi>_all.mat on dataset_root).
% Reads:  metadataSBM_extended.csv, corr mat from results/SBM/analysis/output/.
% Writes: confound_age.mat (same output folder).
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
smoothKernel = config.analysis_settings.sbm_smoothing_kernel;
data_root = config.data_directories.dataset_root;
output_dir = fullfile(data_root, 'results', 'SBM', 'analysis', 'output');
if ~exist(output_dir, 'dir'); mkdir(output_dir); end

% --- Analysis parameters ---
hemi = char(local_default(hemi, 'lh'));
iter = local_default(iter, 5000);
type = char(local_default(type, 'spearman'));
diagnosisString = {'BD', 'SCA', 'SCZ', 'ASD', 'MDD', 'AD'};
nDiag = length(diagnosisString);

% --- Load metadata and cross-site correlation matrices ---
metadata = readtable(fullfile(data_root, 'metadataSBM_extended.csv'), 'VariableNamingRule', 'preserve');
corrMat = fullfile(output_dir, ['corr_zmap_combat', num2str(iCOMBAT), '_smooth', num2str(smoothKernel), '_', hemi, '_all.mat']);
load(corrMat, 'map', 'corDiag', 'corSig', 'siteList');

% --- Mantel test per diagnosis ---
varTable = cell(nDiag, 1);
nSite = cell(nDiag, 1);
for iDiag = 1:nDiag
    [varTable{iDiag}, meanAge{iDiag}, stdAge{iDiag}, nSite{iDiag}] = cor_var_age(metadata, diagnosisString(iDiag), corDiag{iDiag}, siteList{iDiag}, iter, type);
    if ~isempty(varTable{iDiag})
        disp(char(diagnosisString(iDiag)));
        disp(varTable{iDiag});
        disp(' ');
    end
end
% --- Save confound results ---
warning('off', 'last');
save(fullfile(output_dir, 'confound_age.mat'), 'varTable', 'meanAge', 'stdAge', 'nSite');
end

function out = local_default(value, fallback)
if nargin < 1 || isempty(value)
    out = fallback;
else
    out = value;
end
end
