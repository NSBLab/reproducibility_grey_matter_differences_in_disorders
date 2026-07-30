function step8b_glm_parc(config, hemi)
% GLM on parcellated thickness maps for enabled datasets.
%
% Usage:
%   step8b_glm_parc('config_hpc.json')
%   step8b_glm_parc('config_hpc.json', 'lh')
%   step8b_glm_parc(config, 'rh')

if nargin < 1 || isempty(config)
    error('Usage: step8b_glm_parc(config [, hemi])');
end
if nargin < 2 || isempty(hemi)
    hemi = 'lh';
end
hemi = char(hemi);

this_dir = fileparts(mfilename('fullpath'));
repo_root = fullfile(this_dir, '..', '..', '..');
utils_dir = fullfile(repo_root, 'utils');
addpath(this_dir);                 % mbm_stat_map
addpath(genpath(utils_dir));       % read_annotation, pipeline_*, fdr_bh, etc.

if ischar(config) || isstring(config)
    config = pipeline_load_config(char(config));
end

datadir = config.data_directories.dataset_root;
datasets = pipeline_get_enabled_datasets(config);
if isempty(datasets)
    error('No enabled datasets in config');
end

smoothkernel = config.analysis_settings.sbm_smoothing_kernel;
iCOMBAT = config.analysis_settings.harmonize;
measure = 'thick';

% Atlas annotations live under repo data/ (config data_directories.data)
if isfield(config.data_directories, 'data') && ~isempty(config.data_directories.data)
    atlas_root = pipeline_resolve_relative_path(repo_root, config.data_directories.data);
else
    atlas_root = fullfile(repo_root, 'data');
end

schaefer_label_dir = fullfile(atlas_root);

fprintf('=== STEP8B: GLM PARC ===\n');
fprintf('datadir: %s\n', datadir);
fprintf('hemi: %s  smooth: %d  combat: %d\n', hemi, smoothkernel, iCOMBAT);

[~, tempLabel, colortable] = read_annotation(fullfile(schaefer_label_dir, [hemi, '.Schaefer2018_100Parcels_7Networks_order.annot']));
map2colortable = 2:51;
colorcode = colortable.table(map2colortable, 5);
[~, labelSF100] = ismember(tempLabel, colorcode); %#ok<ASGLU>

[~, tempLabel, colortable] = read_annotation(fullfile(schaefer_label_dir, [hemi, '.Schaefer2018_500Parcels_7Networks_order.annot']));
map2colortable = 2:251;
colorcode = colortable.table(map2colortable, 5);
[~, labelSF500] = ismember(tempLabel, colorcode); %#ok<ASGLU>

[~, tempLabel, colortable] = read_annotation(fullfile(schaefer_label_dir, [hemi, '.Schaefer2018_1000Parcels_7Networks_order.annot']));
map2colortable = 2:501;
colorcode = colortable.table(map2colortable, 5);
[~, labelSF1000] = ismember(tempLabel, colorcode); %#ok<ASGLU>

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
            qdecfolder = fullfile(datadir, dsName, 'derivatives', 'freesurfer', 'qdec', ...
                [char(num2str(diag(iFile))), '_', char(site{iFile}), '_', measure, '_smooth', char(num2str(smoothkernel)), '_', hemi, '_sex_age_SF']);
            load(fullfile(qdecfolder, [hemi, '.thickness.fwhm', char(num2str(smoothkernel)), '.fsaverage.mat']), ...
                'zmapDK', 'zmapSF100', 'zmapSF500', 'zmapSF1000');
        else
            qdecfolder = fullfile(datadir, dsName, 'derivatives', 'freesurfer', 'qdec', ...
                [char(num2str(diag(iFile))), '_', char(site{iFile}), '_', measure, '_smooth', char(num2str(smoothkernel)), '_', hemi, '_sex_age_SF_combat']);
            load(fullfile(qdecfolder, [hemi, '.thickness.fwhm', char(num2str(smoothkernel)), '.fsaverage.mat']), ...
                'zmapDK', 'zmapSF100', 'zmapSF500', 'zmapSF1000');
        end

        if ismember(dsName, {'ABIDEI', 'ABIDEII'})
            stat.designMatrix = table2array(qdecfile(:, [2, 4]));
        else
            stat.designMatrix = table2array(qdecfile(:, 2:end));
        end
        stat.test = 'ANCOVA';

        [fMapDK, GDK] = mbm_stat_map(zmapDK', stat);
        pValueDK = (1 - fcdf(fMapDK, 1, height(stat.designMatrix) - width(stat.designMatrix)));
        pValueDK(pValueDK < 2*10^-16) = 2*10^-16;
        zDK = sign(GDK) .* norminv(1 - pValueDK / 2);

        [fMapSF100, GSF100] = mbm_stat_map(zmapSF100', stat);
        pValueSF100 = (1 - fcdf(fMapSF100, 1, height(stat.designMatrix) - width(stat.designMatrix)));
        pValueSF100(pValueSF100 < 2*10^-16) = 2*10^-16;
        zSF100 = sign(GSF100) .* norminv(1 - pValueSF100 / 2);

        [fMapSF500, GSF500] = mbm_stat_map(zmapSF500', stat);
        pValueSF500 = (1 - fcdf(fMapSF500, 1, height(stat.designMatrix) - width(stat.designMatrix)));
        pValueSF500(pValueSF500 < 2*10^-16) = 2*10^-16;
        zSF500 = sign(GSF500) .* norminv(1 - pValueSF500 / 2);

        [fMapSF1000, GSF1000] = mbm_stat_map(zmapSF1000', stat);
        pValueSF1000 = (1 - fcdf(fMapSF1000, 1, height(stat.designMatrix) - width(stat.designMatrix)));
        pValueSF1000(pValueSF1000 < 2*10^-16) = 2*10^-16;
        zSF1000 = sign(GSF1000) .* norminv(1 - pValueSF1000 / 2);

        save(fullfile(qdecfolder, [hemi, '.thickness.fwhm', char(num2str(smoothkernel)), '_glm.fsaverage.mat']), ...
            'pValueDK', 'pValueSF100', 'pValueSF500', 'pValueSF1000', 'zDK', 'zSF100', 'zSF500', 'zSF1000');
    end
    clear site diag
end

fprintf('=== STEP8B DONE ===\n');
end
