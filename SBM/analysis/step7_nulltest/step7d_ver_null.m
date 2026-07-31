function step7d_ver_null(config, hemi)
% Combine vertex-level eigentrapping null maps across step7b jobs.
%
% Usage:
%   step7d_ver_null('config_hpc.json')
%   step7d_ver_null('config_hpc.json', 'lh')
%   step7d_ver_null(config, 'rh')

if nargin < 1 || isempty(config)
    error('Usage: step7d_ver_null(config [, hemi])');
end
if nargin < 2 || isempty(hemi)
    hemi = 'lh';
end
hemi = char(hemi);

this_dir = fileparts(mfilename('fullpath'));
repo_root = fullfile(this_dir, '..', '..', '..');
utils_dir = fullfile(repo_root, 'utils');
addpath(this_dir);
addpath(genpath(utils_dir));

if ischar(config) || isstring(config)
    config = pipeline_load_config(char(config));
end

dataDir = config.data_directories.dataset_root;
iCOMBAT = num2str(config.analysis_settings.harmonize);
smoothKernel = config.analysis_settings.sbm_smoothing_kernel;

eigenFile = fullfile(dataDir, ['eigenStruct_', hemi, '.mat']);
if ~exist(eigenFile, 'file')
    error('eigenStruct not found: %s\nRun SBM step7a_precal_eigenmode first.', eigenFile);
end
load(eigenFile); %#ok<LOAD>  % loads s

datadir = fullfile(dataDir, 'derivatives', 'eigentrap');
if ~exist(datadir, 'dir')
    error('eigentrap directory not found: %s\nRun SBM step7b first.', datadir);
end

fprintf('=== STEP7D: VER NULL ===\n');
fprintf('dataDir: %s\neigentrap: %s\nhemi: %s\n', dataDir, datadir, hemi);

datasets = dir(datadir);
datasets = datasets(~ismember({datasets.name}, {'.', '..'}));

for iSite = 1:length(datasets)
    fprintf('Site folder: %s\n', datasets(iSite).name);

    files = dir(fullfile(datadir, datasets(iSite).name, 'qdec*'));
    files = files(~ismember({files.name}, {'.', '..'}));
    for iFile = 1:length(files)
        parts = strsplit(files(iFile).name, '_');
        if numel(parts) > 8
            diag(iFile) = str2double(parts{5});
        else
            diag(iFile) = str2double(parts{4});
        end
    end
    uniqueDiag = unique(diag);
    nDiag = length(uniqueDiag);
    clear diag

    for iDiag = 1:nDiag
        filesDiag = dir(fullfile(datadir, datasets(iSite).name, ...
            ['qdec_table_*_', char(num2str(uniqueDiag(iDiag))), '_combat', iCOMBAT, '_', hemi, '_smooth', char(num2str(smoothKernel)), '*.mat']));
        filesDiag = filesDiag(~ismember({filesDiag.name}, {'.', '..'}));
        mapStartIn = 1;

        for iFile = 1:length(filesDiag)
            load(fullfile(filesDiag(iFile).folder, filesDiag(iFile).name), ...
                'zmapSurrs', 'sigmapSurrs_HC_P', 'sigmapSurrs_P_HC', 'sigFdrmapSurrs_HC_P', 'sigFdrmapSurrs_P_HC', ...
                'sigClustermapSurrs_HC_P', 'sigClustermapSurrs_P_HC');
            nSur = width(zmapSurrs);
            mapEndIn = mapStartIn + nSur - 1;
            zmapSurrsFull(:, s.mask == 1) = zmapSurrs';

            sigmapSurrsHC_PFull(:, s.mask == 1) = sigmapSurrs_HC_P';
            sigmapSurrsP_HCFull(:, s.mask == 1) = sigmapSurrs_P_HC';
            sigFdrmapSurrsHC_PFull(:, s.mask == 1) = sigFdrmapSurrs_HC_P';
            sigFdrmapSurrsP_HCFull(:, s.mask == 1) = sigFdrmapSurrs_P_HC';
            sigClustermapSurrsHC_PFull(:, s.mask == 1) = sigClustermapSurrs_HC_P';
            sigClustermapSurrsP_HCFull(:, s.mask == 1) = sigClustermapSurrs_P_HC';

            zmapSurrsVer(:, mapStartIn:mapEndIn) = round(zmapSurrsFull', 5);
            sigmapSurrsHC_PVer(:, mapStartIn:mapEndIn) = sigmapSurrsHC_PFull';
            sigmapSurrsP_HCVer(:, mapStartIn:mapEndIn) = sigmapSurrsP_HCFull';
            sigFdrmapSurrsHC_PVer(:, mapStartIn:mapEndIn) = sigFdrmapSurrsHC_PFull';
            sigFdrmapSurrsP_HCVer(:, mapStartIn:mapEndIn) = sigFdrmapSurrsP_HCFull';
            sigClustermapSurrsHC_PVer(:, mapStartIn:mapEndIn) = sigClustermapSurrsHC_PFull';
            sigClustermapSurrsP_HCVer(:, mapStartIn:mapEndIn) = sigClustermapSurrsP_HCFull';
            mapStartIn = mapStartIn + width(zmapSurrs);
        end

        namepart = filesDiag(1).name;
        save(fullfile(datadir, datasets(iSite).name, ['verMap_', namepart(1:end-6), '.mat']), 'zmapSurrsVer');
        save(fullfile(datadir, datasets(iSite).name, ['verThresMap_', namepart(1:end-6), '.mat']), ...
            'sigmapSurrsHC_PVer', 'sigmapSurrsP_HCVer', 'sigFdrmapSurrsHC_PVer', 'sigFdrmapSurrsP_HCVer', ...
            'sigClustermapSurrsHC_PVer', 'sigClustermapSurrsP_HCVer');

        clear zmapSurrsVer sigmapSurrsHC_PFull sigmapSurrsP_HCFull sigFdrmapSurrsHC_PFull sigFdrmapSurrsP_HCFull ...
            sigClustermapSurrsHC_PFull sigClustermapSurrsP_HCFull
        clear sigmapSurrsHC_PVer sigmapSurrsP_HCVer sigFdrmapSurrsHC_PVer sigFdrmapSurrsP_HCVer ...
            sigClustermapSurrsHC_PVer sigClustermapSurrsP_HCVer
    end
end

fprintf('=== STEP7D DONE ===\n');
end
