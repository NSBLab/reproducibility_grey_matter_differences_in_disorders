function step5b_combat_surface_input(config, group_filter)
% Prepare masked surface data matrix for COMBAT: reads smoothed thickness
% .mgh files, applies cortex mask, and writes
% {hemi}_thickness_s{k}_{group}.txt per combat group and hemisphere.
%
% Requires config.data_directories.atlas_dir pointing to the directory
% containing fsaverage_164k_cortex-{lh|rh}_mask.txt.
%
% Usage:
%   step5b_combat_surface_input(config)              % all groups
%   step5b_combat_surface_input(config, 'psy')       % one group only
%   step5b_combat_surface_input('config_hpc.json')   % load from file, all groups
%   step5b_combat_surface_input('config_hpc.json', 'psy')

if nargin < 1 || isempty(config)
    error('No config passed');
end
if nargin < 2; group_filter = ''; end

if ischar(config) || isstring(config)
    this_dir = fileparts(mfilename('fullpath'));
    addpath(genpath(fullfile(this_dir, '..', '..', '..')));
    config = pipeline_load_config(char(config));
end

fprintf('=== STEP5B: COMBAT SURFACE INPUT PREPARATION ===\n');

dataset_root = config.data_directories.dataset_root;
smoothKernel = config.analysis_settings.sbm_smoothing_kernel;
atlas_dir    = config.data_directories.atlas_dir;
hemispheres  = {'lh', 'rh'};

group_datasets = get_group_datasets(config);
group_names    = fieldnames(group_datasets);

if isempty(group_names)
    error('No combat groups found in config.');
end

for g = 1:length(group_names)
    group_name = group_names{g};
    if ~isempty(group_filter) && ~strcmp(group_name, group_filter)
        continue;
    end
    fprintf('Processing combat group: %s\n', group_name);

    metadataFilename = fullfile(dataset_root, ['metadataSBM_', group_name, '.csv']);
    if ~exist(metadataFilename, 'file')
        error('Metadata file not found: %s', metadataFilename);
    end
    metadata = readtable(metadataFilename);
    fprintf('  %d subjects\n', height(metadata));

    outDir = fullfile(dataset_root, 'derivatives', 'freesurfer', ['s', num2str(smoothKernel), 'COMBAT']);
    if ~exist(outDir, 'dir')
        mkdir(outDir);
        fprintf('  Created: %s\n', outDir);
    end

    for h = 1:length(hemispheres)
        hemi = hemispheres{h};

        mask_file = fullfile(atlas_dir, sprintf('fsaverage_164k_cortex-%s_mask.txt', hemi));
        if ~exist(mask_file, 'file')
            error('Cortex mask not found: %s', mask_file);
        end
        mask     = readmatrix(mask_file);
        thickmap = zeros(sum(mask(:)), height(metadata));

        for iSub = 1:height(metadata)
            subj_id    = metadata.subj_id{iSub};
            dataset    = metadata.dataset{iSub};
            ds_path    = get_dataset_path(config, dataset, dataset_root);

            surf_file = fullfile(ds_path, 'derivatives', 'freesurfer', subj_id, 'surf', ...
                sprintf('%s.thickness.fwhm%d.fsaverage.mgh', hemi, smoothKernel));

            if ~exist(surf_file, 'file')
                warning('  Surface file not found: %s', surf_file);
                continue;
            end

            map = squeeze(load_mgh(surf_file));
            thickmap(:, iSub) = map(mask == 1);
        end

        outputFile = fullfile(outDir, sprintf('%s_thickness_s%d_%s.txt', hemi, smoothKernel, group_name));
        writematrix(thickmap, outputFile);
        fprintf('  Saved: %s\n', outputFile);
    end
end

fprintf('=== STEP5B COMPLETED ===\n');
end


function p = get_dataset_path(config, dataset, dataset_root)
if isfield(config.datasets, dataset) && isfield(config.datasets.(dataset), 'path')
    p = config.datasets.(dataset).path;
else
    p = fullfile(dataset_root, dataset);
end
end


function group_datasets = get_group_datasets(config)
group_datasets = struct();
if ~isfield(config, 'datasets'); return; end
ds_names = fieldnames(config.datasets);
for k = 1:numel(ds_names)
    ds = config.datasets.(ds_names{k});
    if isfield(ds, 'enabled') && logical(ds.enabled) && isfield(ds, 'combat_group')
        grp = ds.combat_group;
        if ~isfield(group_datasets, grp)
            group_datasets.(grp) = {};
        end
        group_datasets.(grp){end+1} = ds_names{k};
    end
end
end
