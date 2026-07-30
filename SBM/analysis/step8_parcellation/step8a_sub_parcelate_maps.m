function step8a_sub_parcelate_maps(config, hemi)
% Parcellate subject thickness maps (DK + Schaefer) for enabled datasets.
%
% Usage:
%   step8a_parcelate_maps('config_hpc.json')
%   step8a_parcelate_maps('config_hpc.json', 'lh')
%   step8a_parcelate_maps(config, 'rh')

if nargin < 1 || isempty(config)
    error('Usage: step8a_parcelate_maps(config [, hemi])');
end
if nargin < 2 || isempty(hemi)
    hemi = 'lh';
end
hemi = char(hemi);

this_dir = fileparts(mfilename('fullpath'));
repo_root = fullfile(this_dir, '..', '..', '..');
utils_dir = fullfile(repo_root, 'utils');
addpath(this_dir);                 % load_mgh
addpath(genpath(utils_dir));       % read_annotation, pipeline_*
if exist('pipeline_get_repo_root', 'file') == 2
    repo_root = pipeline_get_repo_root();
end

if ischar(config) || isstring(config)
    config = pipeline_load_config(char(config));
end

% full2parcel from BrainSpace if available
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

datadir = config.data_directories.dataset_root;
datasets = pipeline_get_enabled_datasets(config);
if isempty(datasets)
    error('No enabled datasets in config');
end

smoothkernel = config.analysis_settings.sbm_smoothing_kernel;
iCOMBAT = config.analysis_settings.harmonize;
measure = 'thick';

atlas_root = local_atlas_root(config, repo_root);
aparc_file = local_find_aparc(datadir, datasets, atlas_root, hemi);

schaefer_label_dir = atlas_root;

fprintf('=== STEP8A: PARCELATE MAPS ===\n');
fprintf('datadir: %s\n', datadir);
fprintf('atlas_root: %s\n', atlas_root);
fprintf('hemi: %s  smooth: %d  combat: %d\n', hemi, smoothkernel, iCOMBAT);
fprintf('aparc: %s\n', aparc_file);

% DK atlas
[~, tempLabel, colortable] = read_annotation(aparc_file);
map2colortable = [2:4 6:36];
colorcode = colortable.table(map2colortable, 5);
[~, labelDK] = ismember(tempLabel, colorcode);

% Schaefer atlases
sf100 = local_require_annot(schaefer_label_dir, hemi, 100);
[~, tempLabel, colortable] = read_annotation(sf100);
map2colortable = 2:51;
colorcode = colortable.table(map2colortable, 5);
[~, labelSF100] = ismember(tempLabel, colorcode);

sf500 = local_require_annot(schaefer_label_dir, hemi, 500);
[~, tempLabel, colortable] = read_annotation(sf500);
map2colortable = 2:251;
colorcode = colortable.table(map2colortable, 5);
[~, labelSF500] = ismember(tempLabel, colorcode);

sf1000 = local_require_annot(schaefer_label_dir, hemi, 1000);
[~, tempLabel, colortable] = read_annotation(sf1000);
map2colortable = 2:501;
colorcode = colortable.table(map2colortable, 5);
[~, labelSF1000] = ismember(tempLabel, colorcode);

for iSite = 1:length(datasets)
    dsName = char(datasets{iSite});
    fprintf('Dataset: %s\n', dsName);

    files = dir(fullfile(datadir, dsName, 'qdec*'));
    files = files(~ismember({files.name}, {'.', '..'}));

    for iFile = 1:length(files)
        parts = strsplit(files(iFile).name, '_');
        if numel(parts) > 4
            lastpart = char(parts{5});
            diag(iFile) = str2double(lastpart(1));
            site{iFile} = [char(parts{3}), '_', char(parts{4})];
        else
            lastpart = char(parts{4});
            diag(iFile) = str2double(lastpart(1));
            site{iFile} = char(parts{3});
        end

        qdecfile = readtable(fullfile(datadir, dsName, files(iFile).name));
        if iCOMBAT == 0
            for iMap = 1:height(qdecfile)
                vermap(:, iMap) = load_mgh(fullfile(datadir, dsName, 'derivatives', 'freesurfer', char(qdecfile.fsid{iMap}), 'surf', ...
                    [hemi, '.thickness.fwhm', char(num2str(smoothkernel)), '.fsaverage.mgh']));
                zmapDK(:, iMap) = full2parcel(vermap(:, iMap), labelDK');
                zmapSF100(:, iMap) = full2parcel(vermap(:, iMap), labelSF100');
                zmapSF500(:, iMap) = full2parcel(vermap(:, iMap), labelSF500');
                zmapSF1000(:, iMap) = full2parcel(vermap(:, iMap), labelSF1000');
            end
            qdecfolder = fullfile(datadir, dsName, 'derivatives', 'freesurfer', 'qdec', ...
                [char(num2str(diag(iFile))), '_', char(site{iFile}), '_', measure, '_smooth', char(num2str(smoothkernel)), '_', hemi, '_sex_age_SF']);
            mkdir(qdecfolder);
            save(fullfile(qdecfolder, [hemi, '.thickness.fwhm', char(num2str(smoothkernel)), '.fsaverage.mat']), ...
                'zmapSF100', 'zmapSF500', 'zmapSF1000');
        else
            for iMap = 1:height(qdecfile)
                vermap(:, iMap) = load_mgh(fullfile(datadir, dsName, 'derivatives', 'freesurfer', char(qdecfile.fsid{iMap}), 'surf', ...
                    [hemi, '.thickness.fwhm', char(num2str(smoothkernel)), '.fsaverage_combat.mgh']));
                zmapDK(:, iMap) = full2parcel(vermap(:, iMap), labelDK');
                zmapSF100(:, iMap) = full2parcel(vermap(:, iMap), labelSF100');
                zmapSF500(:, iMap) = full2parcel(vermap(:, iMap), labelSF500');
                zmapSF1000(:, iMap) = full2parcel(vermap(:, iMap), labelSF1000');
            end
            qdecfolder = fullfile(datadir, dsName, 'derivatives', 'freesurfer', 'qdec', ...
                [char(num2str(diag(iFile))), '_', char(site{iFile}), '_', measure, '_smooth', char(num2str(smoothkernel)), '_', hemi, '_sex_age_SF_combat']);
            mkdir(qdecfolder);
            save(fullfile(qdecfolder, [hemi, '.thickness.fwhm', char(num2str(smoothkernel)), '.fsaverage.mat']), ...
                'zmapDK', 'zmapSF100', 'zmapSF500', 'zmapSF1000');
        end
        clear zmapDK zmapSF100 zmapSF500 zmapSF1000 vermap
    end
    clear site diag
end

fprintf('=== STEP8A DONE ===\n');
end

function atlas_root = local_atlas_root(config, repo_root)
% Atlas annotations live under repo data/ (config data_directories.data)
if isfield(config.data_directories, 'data') && ~isempty(config.data_directories.data)
    atlas_root = pipeline_resolve_relative_path(repo_root, config.data_directories.data);
else
    atlas_root = fullfile(repo_root, 'data');
end
end

function aparc_file = local_find_aparc(datadir, datasets, atlas_root, hemi)
% Prefer first enabled dataset with fsaverage aparc; else atlas tree / repo data.
fname = [hemi, '.aparc.annot'];
for i = 1:length(datasets)
    cand = fullfile(datadir, char(datasets{i}), 'derivatives', 'freesurfer', 'fsaverage', 'label', fname);
    if exist(cand, 'file')
        aparc_file = cand;
        return;
    end
end
cand = fullfile(atlas_root, fname);
if exist(cand, 'file')
    aparc_file = cand;
    return;
end
error('Could not find %s under enabled datasets or %s', fname, atlas_root);
end

function annot_file = local_require_annot(label_dir, hemi, nParc)
fname = sprintf('%s.Schaefer2018_%dParcels_7Networks_order.annot', hemi, nParc);
annot_file = fullfile(label_dir, fname);
if exist(annot_file, 'file') ~= 2
    error('Missing Schaefer annot (expected flat under data/):\n  %s', annot_file);
end
end
