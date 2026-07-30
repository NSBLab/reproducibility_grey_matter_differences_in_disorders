function step7b_combine_parcellation(config)
% Combine Buckner cerebellum + Tian subcortex + Schaefer cortex into one NIfTI per scale.
% Writes to <dataset_root>/derivatives/roi/.
%
% Usage:
%   step7b_combine_parcellation('config_hpc.json')
%   step7b_combine_parcellation(config)

if nargin < 1 || isempty(config)
    error('Usage: step7b_combine_parcellation(config)');
end

this_dir = fileparts(mfilename('fullpath'));
repo_root = fullfile(this_dir, '..', '..', '..');
utils_dir = fullfile(repo_root, 'utils');
addpath(genpath(utils_dir));

if ischar(config) || isstring(config)
    config = pipeline_load_config(char(config));
end

dataset_root = config.data_directories.dataset_root;
out_dir = fullfile(dataset_root, 'derivatives', 'roi');
if ~exist(out_dir, 'dir'); mkdir(out_dir); end

% Atlas NIfTIs live under repo data/ (config data_directories.data)
if isfield(config.data_directories, 'data') && ~isempty(config.data_directories.data)
    atlas_root = pipeline_resolve_relative_path(repo_root, config.data_directories.data);
else
    atlas_root = fullfile(repo_root, 'data');
end

cere_file = fullfile(atlas_root, 'Human_cerebellum', 'Buckner-whole_1mm_CAT12MNI.nii.gz');
sub_file  = fullfile(atlas_root, 'Tian_subcortical', 'CAT12MNI', 'Tian_Subcortex_S1_3T_2009cAsym_CAT12MNI.nii.gz');
if ~exist(cere_file, 'file')
    error('Cerebellum atlas not found: %s\nRun step7a first.', cere_file);
end
if ~exist(sub_file, 'file')
    error('Tian subcortex atlas not found: %s\nRun step7a first.', sub_file);
end

fprintf('=== STEP7B: COMBINE PARCELLATION ===\n');
fprintf('atlas_root:    %s\n', atlas_root);
fprintf('out_dir:       %s\n', out_dir);

cere = niftiread(cere_file);
cereInfo = niftiinfo(cere_file);
nCere = max(cere, [], 'all');

sub = niftiread(sub_file);
nSub = max(sub, [], 'all');

nParcList = 100:100:1000;

for iParc = 1:length(nParcList)
    nParc = nParcList(iParc);
    cortex_file = fullfile(atlas_root, 'Human_cortical', 'Schaefer', 'CAT12MNI', ...
        sprintf('Schaefer2018_%dParcels_7Networks_order_CAT12MNI.nii.gz', nParc));
    if ~exist(cortex_file, 'file')
        % FSL sometimes writes without .gz
        cortex_file_alt = fullfile(atlas_root, 'Human_cortical', 'Schaefer', 'CAT12MNI', ...
            sprintf('Schaefer2018_%dParcels_7Networks_order_CAT12MNI.nii', nParc));
        if exist(cortex_file_alt, 'file')
            cortex_file = cortex_file_alt;
        else
            warning('Missing cortex atlas for nParc=%d: %s', nParc, cortex_file);
            continue;
        end
    end

    cortex = niftiread(cortex_file);

    combi = cere;
    combi(sub > 0) = sub(sub > 0) + nCere;
    combi(cortex > 0 & combi == 0) = cortex(cortex > 0 & combi == 0) + nCere + nSub;

    out_name = sprintf('Buckner-whole_1mm_Tian_Subcortex_S1_3T_2009cAsym_Schaefer2018_%dParcels_7Networks_order_CAT12MNI.nii', nParc);
    out_file = fullfile(out_dir, out_name);
    niftiwrite(combi, out_file, cereInfo);
    fprintf('Wrote: %s\n', out_file);
end

fprintf('=== STEP7B DONE ===\n');
end
