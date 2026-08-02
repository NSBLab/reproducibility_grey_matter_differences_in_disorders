function step10f_corr_zmap_var_ageonset(config, hemi, iter, type)
% STEP10F: Age of onset mean/variance between sites vs z-map correlation.
% Usage: step10f_corr_zmap_var_ageonset(config [, hemi, iter, type])
% Prereq: step9a. Writes: confound_ageonset.mat under results/SBM/analysis/output/.
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
    [varTable{iDiag}, meanAgeOnset{iDiag}, stdAgeOnset{iDiag}, nSite{iDiag}] = ...
        cor_var_ageonset(metadata, diagnosisString(iDiag), corDiag{iDiag}, siteList{iDiag}, iter, type);
    if ~isempty(varTable{iDiag})
        disp(char(diagnosisString(iDiag)));
        disp(varTable{iDiag});
        disp(' ');
    end
end
% --- Save confound results ---
warning('off', 'last');
save(fullfile(output_dir, 'confound_ageonset.mat'), 'varTable', 'meanAgeOnset', 'stdAgeOnset', 'nSite');
end

function out = local_default(value, fallback)
if nargin < 1 || isempty(value)
    out = fallback;
else
    out = value;
end
end
