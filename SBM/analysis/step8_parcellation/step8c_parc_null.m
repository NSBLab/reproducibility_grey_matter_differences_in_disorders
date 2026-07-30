function step8c_parc_null(config, hemi)
% Parcellate eigentrapping null maps and match observed ROI extent.
%
% Usage:
%   step8c_parc_null('config_hpc.json')
%   step8c_parc_null('config_hpc.json', 'lh')
%   step8c_parc_null(config, 'rh')

if nargin < 1 || isempty(config)
    error('Usage: step8c_parc_null(config [, hemi])');
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

if exist('full2parcel', 'file') ~= 2
    cand = {fullfile(repo_root, 'utils', 'BrainSpace'), ...
            '/projects/kg98/trangc/library/BrainSpace'};
    for ic = 1:numel(cand)
        if exist(cand{ic}, 'dir')
            addpath(genpath(cand{ic}));
            break;
        end
    end
end
if exist('full2parcel', 'file') ~= 2
    error('full2parcel not found. Add BrainSpace to the MATLAB path.');
end

dataDir = config.data_directories.dataset_root;
enabled = pipeline_get_enabled_datasets(config);
iCOMBAT = num2str(config.analysis_settings.harmonize);
measureShort = 'thick';
smoothKernel = config.analysis_settings.sbm_smoothing_kernel;
thres = 0.05;

% Atlas annotations live under repo data/ (config data_directories.data)
if isfield(config.data_directories, 'data') && ~isempty(config.data_directories.data)
    atlas_root = pipeline_resolve_relative_path(repo_root, config.data_directories.data);
else
    atlas_root = fullfile(repo_root, 'data');
end

eigenFile = fullfile(dataDir, ['eigenStruct_', hemi, '.mat']);
if ~exist(eigenFile, 'file')
    error('eigenStruct not found: %s\nRun SBM step7a_precal_eigenmode first.', eigenFile);
end
load(eigenFile); %#ok<LOAD>  % loads s

% DK aparc
aparc_file = '';
for i = 1:length(enabled)
    cand = fullfile(dataDir, char(enabled{i}), 'derivatives', 'freesurfer', 'fsaverage', 'label', [hemi, '.aparc.annot']);
    if exist(cand, 'file'); aparc_file = cand; break; end
end
if isempty(aparc_file)
    cand = fullfile(atlas_root, [hemi, '.aparc.annot']);
    if exist(cand, 'file'); aparc_file = cand; end
end
if isempty(aparc_file)
    error('Could not find %s.aparc.annot under enabled datasets or %s', hemi, atlas_root);
end

[~, tempLabel, colortable] = read_annotation(aparc_file);
map2colortable = [2:4 6:36];
colorcode = colortable.table(map2colortable, 5);
[~, labelDK] = ismember(tempLabel, colorcode);

schaefer_label_dir = atlas_root;
[~, tempLabel, colortable] = read_annotation(fullfile(schaefer_label_dir, [hemi, '.Schaefer2018_100Parcels_7Networks_order.annot']));
map2colortable = 2:51;
colorcode = colortable.table(map2colortable, 5);
[~, labelSF100] = ismember(tempLabel, colorcode);

[~, tempLabel, colortable] = read_annotation(fullfile(schaefer_label_dir, [hemi, '.Schaefer2018_500Parcels_7Networks_order.annot']));
map2colortable = 2:251;
colorcode = colortable.table(map2colortable, 5);
[~, labelSF500] = ismember(tempLabel, colorcode);

[~, tempLabel, colortable] = read_annotation(fullfile(schaefer_label_dir, [hemi, '.Schaefer2018_1000Parcels_7Networks_order.annot']));
map2colortable = 2:501;
colorcode = colortable.table(map2colortable, 5);
[~, labelSF1000] = ismember(tempLabel, colorcode);

filename = fullfile(dataDir, 'metadataSBM.csv');
if ~exist(filename, 'file')
    error('metadataSBM.csv not found: %s', filename);
end
data = readtable(filename);
data.site_string(strcmp(data.site_string, 'Signa HDxt') == 1) = {'Signa_HDxt'};

datadir = fullfile(dataDir, 'derivatives', 'eigentrap');
if ~exist(datadir, 'dir')
    error('eigentrap directory not found: %s\nRun SBM step7b first.', datadir);
end

fprintf('=== STEP8C: PARC NULL ===\n');
fprintf('dataDir: %s\neigentrap: %s\n', dataDir, datadir);

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
            siteName{iFile} = [parts{3}, '_', parts{4}];
        else
            diag(iFile) = str2double(parts{4});
            siteName{iFile} = parts{3};
        end
    end
    uniqueDiag = unique(diag);
    nDiag = length(uniqueDiag);
    uniquesiteName = unique(siteName);
    datasetName = unique(data.dataset(strcmp(data.site_string, uniquesiteName) == 1));
    clear diag siteName

    for iDiag = 1:nDiag
        if strcmp(iCOMBAT, '0')
            qdecfolder = fullfile(dataDir, datasetName{1}, 'derivatives', 'freesurfer', 'qdec', ...
                [char(num2str(uniqueDiag(iDiag))), '_', uniquesiteName{1}, '_', measureShort, '_smooth', char(num2str(smoothKernel)), '_', hemi, '_sex_age_SF']);
        else
            qdecfolder = fullfile(dataDir, datasetName{1}, 'derivatives', 'freesurfer', 'qdec', ...
                [char(num2str(uniqueDiag(iDiag))), '_', uniquesiteName{1}, '_', measureShort, '_smooth', char(num2str(smoothKernel)), '_', hemi, '_sex_age_SF_combat']);
        end

        load(fullfile(qdecfolder, [hemi, '.thickness.fwhm', char(num2str(smoothKernel)), '_glm.fsaverage.mat']), ...
            'pValueDK', 'pValueSF100', 'pValueSF500', 'pValueSF1000');

        sigmapDK = double(pValueDK <= thres);
        sigmapSF100 = double(pValueSF100 <= thres);
        sigmapSF500 = double(pValueSF500 <= thres);
        sigmapSF1000 = double(pValueSF1000 <= thres);
        N_DK = sum(sigmapDK);
        N_SF100 = sum(sigmapSF100);
        N_SF500 = sum(sigmapSF500);
        N_SF1000 = sum(sigmapSF1000);

        filesDiag = dir(fullfile(datadir, datasets(iSite).name, ...
            ['qdec_table_*_', char(num2str(uniqueDiag(iDiag))), '_combat', iCOMBAT, '_', hemi, '_smooth', char(num2str(smoothKernel)), '*.mat']));
        filesDiag = filesDiag(~ismember({filesDiag.name}, {'.', '..'}));
        mapStartIn = 1;

        for iFile = 1:length(filesDiag)
            load(fullfile(filesDiag(iFile).folder, filesDiag(iFile).name), ...
                'zmapSurrs', 'sigmapSurrs_HC_P', 'sigmapSurrs_P_HC', 'sigFdrmapSurrs_HC_P', 'sigFdrmapSurrs_P_HC');
            nSur = width(zmapSurrs);
            mapEndIn = mapStartIn + nSur - 1;
            zmapSurrsFull(:, s.mask == 1) = zmapSurrs;

            zmapSurrsDK(:, mapStartIn:mapEndIn) = full2parcel(zmapSurrsFull, labelDK');
            zmapSurrsSF100(:, mapStartIn:mapEndIn) = full2parcel(zmapSurrsFull, labelSF100');
            zmapSurrsSF500(:, mapStartIn:mapEndIn) = full2parcel(zmapSurrsFull, labelSF500');
            zmapSurrsSF1000(:, mapStartIn:mapEndIn) = full2parcel(zmapSurrsFull, labelSF1000');

            sigmapSurrsHC_PFull(:, s.mask == 1) = sigmapSurrs_HC_P; %#ok<NASGU>
            sigmapSurrsP_HCFull(:, s.mask == 1) = sigmapSurrs_P_HC; %#ok<NASGU>
            sigFdrmapSurrsHC_PFull(:, s.mask == 1) = sigFdrmapSurrs_HC_P; %#ok<NASGU>
            sigFdrmapSurrsP_HCFull(:, s.mask == 1) = sigFdrmapSurrs_P_HC; %#ok<NASGU>

            [~, idx_sorted_DK] = sort(zmapSurrsDK, 'descend');
            top_indices_DK = idx_sorted_DK(1:N_DK, :);
            [~, idx_sorted_SF100] = sort(zmapSurrsSF100, 'descend');
            top_indices_SF100 = idx_sorted_SF100(1:N_SF100, :);
            [~, idx_sorted_SF500] = sort(zmapSurrsSF500, 'descend');
            top_indices_SF500 = idx_sorted_SF500(1:N_SF500, :);
            [~, idx_sorted_SF1000] = sort(zmapSurrsSF1000, 'descend');
            top_indices_SF1000 = idx_sorted_SF1000(1:N_SF1000, :);

            sigmapSurrsDK(:, mapStartIn:mapEndIn) = zeros(length(sigmapDK), nSur);
            sigmapSurrsSF100(:, mapStartIn:mapEndIn) = zeros(length(sigmapSF100), nSur);
            sigmapSurrsSF500(:, mapStartIn:mapEndIn) = zeros(length(sigmapSF500), nSur);
            sigmapSurrsSF1000(:, mapStartIn:mapEndIn) = zeros(length(sigmapSF1000), nSur);

            for i = mapStartIn:mapEndIn
                sigmapSurrsDK(top_indices_DK(:, i), i) = 1;
                sigmapSurrsSF100(top_indices_SF100(:, i), i) = 1;
                sigmapSurrsSF500(top_indices_SF500(:, i), i) = 1;
                sigmapSurrsSF1000(top_indices_SF1000(:, i), i) = 1;
            end

            mapStartIn = mapStartIn + width(zmapSurrs);
        end

        namepart = filesDiag(1).name;
        save(fullfile(datadir, datasets(iSite).name, ['parcMap_', namepart(1:end-6), '.mat']), ...
            'zmapSurrsSF100', 'zmapSurrsSF500', 'zmapSurrsSF1000', 'zmapSurrsDK');
        save(fullfile(datadir, datasets(iSite).name, ['parcThresMap_', namepart(1:end-6), '.mat']), ...
            'sigmapSurrsSF100', 'sigmapSurrsSF500', 'sigmapSurrsSF1000', 'sigmapSurrsDK');

        clear sigmapSurrsSF100 sigmapSurrsSF500 sigmapSurrsSF1000 sigmapSurrsDK
        clear zmapSurrsSF100 zmapSurrsSF500 zmapSurrsSF1000 zmapSurrsDK zmapSurrsVer
    end
end

fprintf('=== STEP8C DONE ===\n');
end
