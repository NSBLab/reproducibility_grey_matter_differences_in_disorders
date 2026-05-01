function step0a_create_dataset_list(config_file)
% Step 0A: create enabled dataset list from config.
%
% Usage:
%   step0a_create_dataset_list();
%   step0a_create_dataset_list('config_windows.json');

if nargin < 1
    config_file = 'config.json';
end

repo_utils = fullfile(fileparts(mfilename('fullpath')), '..', 'utils');
addpath(repo_utils);
pipeline_ensure_paths();

config = pipeline_load_config(config_file);

fprintf('=== STEP 0A: CREATE DATASET LIST ===\n');
enabled_datasets = pipeline_get_enabled_datasets(config);

dataset_root = config.data_directories.dataset_root;
dataset_list_file = fullfile(dataset_root, 'dataset_list.txt');
fid = fopen(dataset_list_file, 'w');
if fid == -1
    error('Could not create dataset list file: %s', dataset_list_file);
end

for ii = 1:numel(enabled_datasets)
    fprintf(fid, '%s\n', enabled_datasets{ii});
end
fclose(fid);

fprintf('Created dataset list: %s\n', dataset_list_file);
fprintf('Found %d enabled datasets: %s\n', numel(enabled_datasets), strjoin(enabled_datasets, ', '));

end
