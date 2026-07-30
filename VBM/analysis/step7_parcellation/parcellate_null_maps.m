function parcellate_null_maps(config, diagnosisString, site, nulldir, nNull)
% Parcellate VBM surrogate null maps and match observed ROI extent.
%
% Usage:
%   parcellate_null_maps('config_hpc.json', 'SCZ', 'SiteA', nulldir, 10)
%   parcellate_null_maps(config, diagnosisString, site, nulldir, nNull)

if nargin < 5 || isempty(config)
    error('Usage: parcellate_null_maps(config, diagnosisString, site, nulldir, nNull)');
end

this_dir = fileparts(mfilename('fullpath'));
repo_root = fullfile(this_dir, '..', '..', '..');
addpath(this_dir);
addpath(genpath(fullfile(repo_root, 'utils')));

if ischar(config) || isstring(config)
    config = pipeline_load_config(char(config));
end

diagnosisString = char(diagnosisString);
site = char(site);
nulldir = char(nulldir);

dataset_root = config.data_directories.dataset_root;
dataDir = dataset_root;
roi_dir = fullfile(dataDir, 'derivatives', 'roi');

nParcList = [100 500 1000];

fprintf('=== PARCELLATE NULL MAPS: %s / %s ===\n', diagnosisString, site);

for iNull = 1:nNull
    nullfile = fullfile(nulldir, diagnosisString, site, ['spmT_0001_surrogate_', char(num2str(iNull)), '.nii.gz']);
    if exist(nullfile, 'file')
        map = spm_vol(nullfile);

        for iParc = 1:length(nParcList)
            roiStruct = load(fullfile(roi_dir, diagnosisString, site, [num2str(nParcList(iParc)), '_parcCon.mat']), 'stat');
            binMap = roiStruct.stat.thresMap;
            nBin = sum(binMap);

            parc = niftiread(fullfile(roi_dir, ...
                ['Buckner-whole_1mm_Tian_Subcortex_S1_3T_2009cAsym_Schaefer2018_', num2str(nParcList(iParc)), 'Parcels_7Networks_order_CAT12MNI.nii']));
            volParc = get_vol_parc(map, parc);

            [~, idx_sorted] = sort(volParc, 'descend');
            top_indices_bin = idx_sorted(1:nBin);

            binParc = zeros(size(binMap));
            binParc(top_indices_bin) = 1;

            save(fullfile(nulldir, diagnosisString, site, ...
                ['spmT_0001_surrogate_', char(num2str(iNull)), '_T1w_Buckner-whole_1mm_Tian_Subcortex_S1_3T_2009cAsym_Schaefer2018_', char(num2str(nParcList(iParc))), 'Parcels_7Networks_order_CAT12MNI.mat']), ...
                'volParc', 'binParc');
        end
    end
end

fprintf('=== PARCELLATE NULL MAPS DONE: %s / %s ===\n', diagnosisString, site);
end
