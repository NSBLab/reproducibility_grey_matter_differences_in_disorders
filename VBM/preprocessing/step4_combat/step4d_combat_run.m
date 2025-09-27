function step4d_combat_run(config)
% STEP4D: Run COMBAT harmonization
% This function submits batch jobs for COMBAT harmonization using shell scripts
% for each combat group separately
%
% Input: config - Configuration structure containing paths and settings

% Use config passed as parameter, or load from file if not provided
if nargin < 1 || isempty(config)
    % Fallback: Load configuration from config.json file
    config = jsondecode(fileread('../../config.json'));
end

fprintf('=== STEP4D: COMBAT HARMONIZATION ===\n');

% Get paths from config
dataset_root = config.data_directories.dataset_root;
smoothKernel = config.analysis_settings.smoothing_kernel;

% Set environment variables
setenv('DATA_ROOT', dataset_root);
setenv('SMOOTH_KERNEL', num2str(smoothKernel));

% Get script directory
scriptDir = fileparts(mfilename('fullpath'));
sendScript = fullfile(scriptDir, 'step4d_COMBAT_run_sbatch_send.sh');

if ~exist(sendScript, 'file')
    error('Send script not found: %s', sendScript);
end

fprintf('Submitting COMBAT harmonization batch jobs...\n');
fprintf('Data root: %s\n', dataset_root);
fprintf('Smoothing kernel: %d\n', smoothKernel);

% Run the send script to submit batch jobs
cmd = sprintf('bash "%s"', sendScript);
[status, output] = system(cmd);

if status == 0
    fprintf('Batch jobs submitted successfully\n');
    if ~isempty(output)
        fprintf('Output: %s\n', output);
    end
else
    error('Failed to submit batch jobs with status %d\nOutput: %s', status, output);
end

fprintf('=== STEP4D COMPLETED ===\n');
end
