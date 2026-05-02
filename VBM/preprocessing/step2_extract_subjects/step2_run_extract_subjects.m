function step2_run_extract_subjects(config_file)
% STEP 2 (VBM): run dataset-specific extract_sub_<dataset>.m scripts from config.
%
% After step 1c, write subjects_pass_visualisation.txt per dataset (copy from subjects_cat12_passed.txt,
% remove excluded IDs); extract scripts read that file with readlines.
%
% Same pattern as data_BIDS/step0b_organize_bids.m: loops enabled datasets and calls
% config.datasets.<name>.vbm_extract_script under this folder with pipeline_load_config(config).
%
% Usage:
%   step2_run_extract_subjects();
%   step2_run_extract_subjects('config_hpc.json');

if nargin < 1 || isempty(config_file)
    config_file = 'config.json';
end

this_dir = fileparts(mfilename('fullpath'));
repo_main = fullfile(this_dir, '..', '..', '..');
addpath(genpath(repo_main));
pipeline_ensure_paths();

config = pipeline_load_config(config_file);

fprintf('=== STEP 2 VBM: EXTRACT SUBJECTS ===\n');
enabled_datasets = pipeline_get_enabled_datasets(config);

repo_root = pipeline_get_repo_root();
vbm_root = pipeline_resolve_relative_path(repo_root, config.data_directories.VBM);
extract_dir = fullfile(vbm_root, 'preprocessing', 'step2_extract_subjects');

for i = 1:numel(enabled_datasets)
    dataset_name = enabled_datasets{i};
    dataset_cfg = config.datasets.(dataset_name);

    if ~isfield(dataset_cfg, 'vbm_extract_script')
        warning('Dataset "%s" has no vbm_extract_script in config — skipping.', dataset_name);
        continue
    end

    extract_script = fullfile(extract_dir, dataset_cfg.vbm_extract_script);
    if ~exist(extract_script, 'file')
        warning('Extract script not found: %s', extract_script);
        continue
    end

    fprintf('Running VBM extract: %s\n', extract_script);
    [script_dir, func_name, ~] = fileparts(extract_script);

    try
        addpath(script_dir);
        feval(func_name, config);
        rmpath(script_dir);
    catch ME
        rmpath(script_dir);
        error('Error running %s: %s', extract_script, ME.message);
    end
end

end
