function step7c_sub_parcellate_maps(config, dataset)
% Parcellate subject mwp1 GM maps with combined Buckner+Tian+Schaefer NIfTIs.
%
% Usage:
%   parcellate_maps('config_hpc.json', 'Myelin')
%   parcellate_maps(config, 'Myelin')

if nargin < 2 || isempty(config) || isempty(dataset)
    error('Usage: parcellate_maps(config, dataset)');
end

this_dir = fileparts(mfilename('fullpath'));
repo_root = fullfile(this_dir, '..', '..', '..');
addpath(this_dir);
addpath(genpath(fullfile(repo_root, 'utils')));

if ischar(config) || isstring(config)
    config = pipeline_load_config(char(config));
end

dataset = char(dataset);
dataset_root = config.data_directories.dataset_root;
dataDir = dataset_root;

isses = isfield(config.datasets, dataset) && ...
        isfield(config.datasets.(dataset), 'longitudinal') && ...
        logical(config.datasets.(dataset).longitudinal);

roi_dir = fullfile(dataset_root, 'derivatives', 'roi');
nParcList = 100:100:1000;

fprintf('=== PARCELLATE MAPS: %s (longitudinal=%d) ===\n', dataset, isses);

subList = readtable(fullfile(dataDir, dataset, [dataset, '_dems.csv']), 'delimiter', ',');

for iSub = 1:height(subList)
    sub = char(subList.subj_id(iSub));
    if isses
        ses = char(subList.ses(iSub));
        out_check = fullfile(dataDir, dataset, sub, ses, 'anat', ...
            ['mwp1', sub, '_', ses, '_T1w_Buckner-whole_1mm_Tian_Subcortex_S1_3T_2009cAsym_Schaefer2018_1000Parcels_7Networks_order_CAT12MNI.mat']);
        if ~exist(out_check, 'file')
            map = spm_vol(fullfile(dataDir, dataset, sub, ses, 'anat', ['mwp1', sub, '_', ses, '_T1w.nii']));
            for iParc = 1:length(nParcList)
                parc = niftiread(fullfile(roi_dir, ...
                    ['Buckner-whole_1mm_Tian_Subcortex_S1_3T_2009cAsym_Schaefer2018_', num2str(nParcList(iParc)), 'Parcels_7Networks_order_CAT12MNI.nii']));
                volParc = get_vol_parc(map, parc);
                save(fullfile(dataDir, dataset, sub, ses, 'anat', ...
                    ['mwp1', sub, '_', ses, '_T1w_Buckner-whole_1mm_Tian_Subcortex_S1_3T_2009cAsym_Schaefer2018_', char(num2str(nParcList(iParc))), 'Parcels_7Networks_order_CAT12MNI.mat']), 'volParc');
            end
        end
    else
        out_check = fullfile(dataDir, dataset, sub, 'anat', ...
            ['mwp1', sub, '_T1w_Buckner-whole_1mm_Tian_Subcortex_S1_3T_2009cAsym_Schaefer2018_1000Parcels_7Networks_order_CAT12MNI.mat']);
        if ~exist(out_check, 'file')
            map = spm_vol(fullfile(dataDir, dataset, sub, 'anat', ['mwp1', sub, '_T1w.nii']));
            for iParc = 1:length(nParcList)
                parc = niftiread(fullfile(roi_dir, ...
                    ['Buckner-whole_1mm_Tian_Subcortex_S1_3T_2009cAsym_Schaefer2018_', num2str(nParcList(iParc)), 'Parcels_7Networks_order_CAT12MNI.nii']));
                volParc = get_vol_parc(map, parc);
                save(fullfile(dataDir, dataset, sub, 'anat', ...
                    ['mwp1', sub, '_T1w_Buckner-whole_1mm_Tian_Subcortex_S1_3T_2009cAsym_Schaefer2018_', char(num2str(nParcList(iParc))), 'Parcels_7Networks_order_CAT12MNI.mat']), 'volParc');
            end
        end
    end
end

fprintf('=== PARCELLATE MAPS DONE: %s ===\n', dataset);
end
