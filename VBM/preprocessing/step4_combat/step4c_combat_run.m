function step4c_combat_run(config)
% STEP4C: Run COMBAT harmonization
% This function runs the COMBAT harmonization process using Python
% for each combat group separately
%
% Input: config - Configuration structure containing paths and settings

% Use config passed as parameter, or load from file if not provided
if nargin < 1 || isempty(config)
    % Fallback: Load configuration from config.json file
    config = jsondecode(fileread('../../config.json'));
end

fprintf('=== STEP4C: COMBAT HARMONIZATION ===\n');

% Get paths from config
dataset_root = config.data_directories.dataset_root;
smoothKernel = config.analysis_settings.smoothing_kernel;

% Get datasets grouped by combat group
datasets_by_group = get_datasets_by_combat_group(config);
group_names = fieldnames(datasets_by_group);

if isempty(group_names)
    error('No combat groups found in config. Please add combat_group field to datasets.');
end

% Process each combat group
for g = 1:length(group_names)
    group_name = group_names{g};
    datasets = datasets_by_group.(group_name);
    
    if isempty(datasets)
        continue;
    end
    
    fprintf('Processing combat group: %s (%d datasets)\n', group_name, length(datasets));
    
    % Process this group
    process_combat_group(config, group_name, dataset_root, smoothKernel);
end

fprintf('=== STEP4C COMPLETED ===\n');
end

function process_combat_group(config, group_name, dataset_root, smoothKernel)
% Process COMBAT harmonization for a single combat group

% Set up directories
dataDir = dataset_root;
outDir = fullfile(dataDir, 'derivatives', ['s', num2str(smoothKernel), 'COMBAT']);
maskDir = fullfile(outDir, ['mask_', group_name]);

% Check if input files exist
metadataFile = fullfile(dataDir, ['metadataVBM_', group_name, '.csv']);
anatFile = fullfile(maskDir, ['anat_s', num2str(smoothKernel), 'mwp1_T1w_masked.txt']);
maskFile = fullfile(maskDir, 'mask.nii');

if ~exist(metadataFile, 'file')
    error('Metadata file not found: %s', metadataFile);
end
if ~exist(anatFile, 'file')
    error('Anatomical data file not found: %s', anatFile);
end
if ~exist(maskFile, 'file')
    error('Mask file not found: %s', maskFile);
end

fprintf('  Input files verified for group %s:\n', group_name);
fprintf('    Metadata: %s\n', metadataFile);
fprintf('    Anatomical data: %s\n', anatFile);
fprintf('    Mask: %s\n', maskFile);

% Get script directory
scriptDir = fileparts(mfilename('fullpath'));
pythonScript = fullfile(scriptDir, 'COMBAT_run.py');

if ~exist(pythonScript, 'file')
    error('Python COMBAT script not found: %s', pythonScript);
end

% Run COMBAT using Python
fprintf('  Running COMBAT harmonization for group %s...\n', group_name);
fprintf('    Python script: %s\n', pythonScript);
fprintf('    Smoothing kernel: %d\n', smoothKernel);
fprintf('    Group: %s\n', group_name);

% Set up Python command
cmd = sprintf('python "%s" %d %s', pythonScript, smoothKernel, group_name);

% Change to the script directory and run
currentDir = pwd;
try
    cd(scriptDir);
    [status, output] = system(cmd);
    
    if status == 0
        fprintf('    COMBAT harmonization completed successfully for group %s\n', group_name);
        if ~isempty(output)
            fprintf('    Output: %s\n', output);
        end
    else
        error('COMBAT harmonization failed for group %s with status %d\nOutput: %s', group_name, status, output);
    end
    
catch ME
    cd(currentDir);
    rethrow(ME);
end

cd(currentDir);

% Check if output file was created
outputFile = fullfile(maskDir, ['anat_s', num2str(smoothKernel), 'mwp1_T1w_masked_combat.txt']);
if exist(outputFile, 'file')
    fprintf('    COMBAT output file created: %s\n', outputFile);
else
    warning('    COMBAT output file not found: %s', outputFile);
end

fprintf('  Group %s processing completed\n', group_name);
end

function datasets_by_group = get_datasets_by_combat_group(config)
% Return structure with datasets grouped by combat_group
datasets_by_group = struct();
if ~isfield(config, 'datasets') || isempty(fieldnames(config.datasets))
    return;
end

dataset_names = fieldnames(config.datasets);
for k = 1:numel(dataset_names)
    name_k = dataset_names{k};
    ds = config.datasets.(name_k);
    if isfield(ds, 'enabled') && logical(ds.enabled) && isfield(ds, 'combat_group')
        group = ds.combat_group;
        if ~isfield(datasets_by_group, group)
            datasets_by_group.(group) = {};
        end
        datasets_by_group.(group){end+1} = name_k; %#ok<AGROW>
    end
end
end