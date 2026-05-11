function step4_run_extract_surface(config_file)
% STEP 4 (SBM): run dataset-specific extract_sub_surface_<dataset>.m scripts from config.
%
% Loops enabled datasets and calls config.datasets.<name>.sbm_extract_surface_script
% under this folder as a function, passing config.
%
% Usage:
%   step4_run_extract_surface();              % auto-detects CONFIG_FILE env var or config_hpc.json
%   step4_run_extract_surface('config_hpc.json');

if nargin < 1 || isempty(config_file)
    env_cfg = getenv('CONFIG_FILE');
    if ~isempty(env_cfg)
        config_file = env_cfg;
    else
        this_dir_tmp = fileparts(mfilename('fullpath'));
        hpc_cfg = fullfile(this_dir_tmp, '..', '..', '..', 'config_hpc.json');
        if exist(hpc_cfg, 'file')
            config_file = hpc_cfg;
        else
            error('CONFIG_FILE not set and config_hpc.json not found.\nChecked: %s', hpc_cfg);
        end
    end
end

this_dir = fileparts(mfilename('fullpath'));
repo_main = fullfile(this_dir, '..', '..', '..');
addpath(genpath(repo_main));
pipeline_ensure_paths();

config = pipeline_load_config(config_file);

fprintf('=== STEP 4 SBM: EXTRACT SURFACE SUBJECTS ===\n');
enabled_datasets = pipeline_get_enabled_datasets(config);

repo_root = pipeline_get_repo_root();
sbm_root = pipeline_resolve_relative_path(repo_root, config.data_directories.SBM);
extract_dir = fullfile(sbm_root, 'preprocessing', 'step4_extract_subjects');

for i = 1:numel(enabled_datasets)
    dataset_name = enabled_datasets{i};
    dataset_cfg = config.datasets.(dataset_name);

    if ~isfield(dataset_cfg, 'sbm_extract_surface_script')
        warning('Dataset "%s" has no sbm_extract_surface_script in config — skipping.', dataset_name);
        continue
    end

    extract_script = fullfile(extract_dir, dataset_cfg.sbm_extract_surface_script);
    if ~exist(extract_script, 'file')
        warning('Extract script not found: %s', extract_script);
        continue
    end

    fprintf('Running SBM surface extract: %s\n', extract_script);
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
