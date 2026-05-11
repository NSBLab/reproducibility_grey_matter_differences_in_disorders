function step5d_combat_surface_output(config)
% Write COMBAT-harmonized surface data back as per-subject .mgh files.
% Reads {hemi}_thickness_s{k}_{group}_combat.txt, unmasks, and saves
% {hemi}.thickness.fwhm{k}.fsaverage_combat.mgh per subject.
%
% Requires config.data_directories.atlas_dir pointing to the directory
% containing fsaverage_164k_cortex-{lh|rh}_mask.txt.

if nargin < 1 || isempty(config)
    error('No config passed');
end

fprintf('=== STEP5D: COMBAT SURFACE OUTPUT ===\n');

dataset_root = config.data_directories.dataset_root;
smoothKernel = config.analysis_settings.smoothing_kernel;
atlas_dir    = config.data_directories.atlas_dir;
hemispheres  = {'lh', 'rh'};

group_datasets = get_group_datasets(config);
group_names    = fieldnames(group_datasets);

if isempty(group_names)
    error('No combat groups found in config.');
end

for g = 1:length(group_names)
    group_name = group_names{g};
    fprintf('Processing combat group: %s\n', group_name);

    metadataFilename = fullfile(dataset_root, ['metadataSBM_', group_name, '.csv']);
    if ~exist(metadataFilename, 'file')
        error('Metadata file not found: %s', metadataFilename);
    end
    metadata = readtable(metadataFilename);

    outDir = fullfile(dataset_root, 'derivatives', 'freesurfer', ['s', num2str(smoothKernel), 'COMBAT']);

    for h = 1:length(hemispheres)
        hemi = hemispheres{h};

        mask_file = fullfile(atlas_dir, sprintf('fsaverage_164k_cortex-%s_mask.txt', hemi));
        if ~exist(mask_file, 'file')
            error('Cortex mask not found: %s', mask_file);
        end
        mask = readmatrix(mask_file);

        combat_file = fullfile(outDir, sprintf('%s_thickness_s%d_%s_combat.txt', hemi, smoothKernel, group_name));
        if ~exist(combat_file, 'file')
            error('COMBAT output not found: %s', combat_file);
        end
        combatMap = readmatrix(combat_file);

        % Pre-allocate full-surface matrix and fill masked vertices
        nVertices         = length(mask);
        unmaskedCombatMap = zeros(nVertices, height(metadata));
        unmaskedCombatMap(mask == 1, :) = combatMap;

        fprintf('  Writing %d subjects [%s, %s]...\n', height(metadata), group_name, hemi);

        for iSub = 1:height(metadata)
            subj_id = metadata.subj_id{iSub};
            dataset = metadata.dataset{iSub};
            ds_path = get_dataset_path(config, dataset, dataset_root);

            orig_file = fullfile(ds_path, 'derivatives', 'freesurfer', subj_id, 'surf', ...
                sprintf('%s.thickness.fwhm%d.fsaverage.mgh', hemi, smoothKernel));

            if ~exist(orig_file, 'file')
                warning('  Original surface file not found: %s', orig_file);
                continue;
            end

            [~, M, mr_parms] = load_mgh(orig_file);

            out_file = fullfile(ds_path, 'derivatives', 'freesurfer', subj_id, 'surf', ...
                sprintf('%s.thickness.fwhm%d.fsaverage_combat.mgh', hemi, smoothKernel));

            save_mgh(unmaskedCombatMap(:, iSub), out_file, M, mr_parms);
        end

        fprintf('  Done [%s, %s]\n', group_name, hemi);
    end
end

fprintf('=== STEP5D COMPLETED ===\n');
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
