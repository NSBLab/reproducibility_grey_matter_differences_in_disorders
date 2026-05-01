function step0b_organize_bids(config_file)
% Step 0B: run dataset-specific BIDS organization scripts.
%
% Usage:
%   step0b_organize_bids();
%   step0b_organize_bids('config_windows.json');

if nargin < 1
    config_file = 'config.json';
end

repo_utils = fullfile(fileparts(mfilename('fullpath')), '..', 'utils');
addpath(repo_utils);
pipeline_ensure_paths();

config = pipeline_load_config(config_file);

fprintf('=== STEP 0B: ORGANIZE BIDS STAGE ===\n');
enabled_datasets = pipeline_get_enabled_datasets(config);

repo_root = pipeline_get_repo_root();
data_bids_dir = pipeline_resolve_relative_path(repo_root, config.data_directories.data_BIDS);

for i = 1:length(enabled_datasets)
    dataset_name = enabled_datasets{i};
    dataset_config = config.datasets.(dataset_name);
    bids_script = fullfile(data_bids_dir, dataset_config.bids_script);

    if exist(bids_script, 'file')
        fprintf('Running BIDS script: %s\n', bids_script);
        [script_dir, func_name, ~] = fileparts(bids_script);

        try
            addpath(script_dir);
            feval(func_name, config);
            rmpath(script_dir);
        catch ME
            rmpath(script_dir);
            error('Error running BIDS script %s: %s', bids_script, ME.message);
        end
    else
        warning('BIDS script not found: %s', bids_script);
    end
end

end
