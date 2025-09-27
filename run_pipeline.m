function run_pipeline(stage, config_file)
% Main pipeline runner for neuroimaging analysis
% Supports running individual stages or multiple stages
%
% Usage:
%   run_pipeline('step0a_create_dataset_list')                    % Run single stage
%   run_pipeline({'step0a_create_dataset_list', 'step0b_organize_bids'}) % Run multiple stages
%   run_pipeline('step0a_create_dataset_list', 'my_config.json')  % Use custom config
%   run_pipeline({'step0a_create_dataset_list', 'step0b_organize_bids'}, 'my_config.json') % Multiple stages with custom config

if nargin < 1
    error('Please specify a stage to run');
end

if nargin < 2
    config_file = 'config.json';
end

% Load configuration
config = load_config(config_file);

% Validate stage - Updated to include all stages from config.json
valid_stages = {'step0a_create_dataset_list', 'step0b_organize_bids',  ...
                'step1a_VBM_CAT12_preprocess', 'step1b_VBM_CAT12_report_concat', 'step1c_VBM_CAT12_visualisation', ...
                'step2_VBM_extract_subjects', 'step3_VBM_smoothing', ...
                'step4a_VBM_combine_metadata', 'step4b_VBM_make_mask', 'step4c_VBM_combat_input', 'step4d_VBM_combat', 'step4e_VBM_combat_output', ...
                'step5_VBM_statistical_analysis', ...
                'step7_VBM_parcellation', 'step8_VBM_nulltest', 'step9_VBM_consistency', ...
                'step10_VBM_covariates', 'step11_VBM_figures', ...
                'SBM_recon_all', 'SBM_autoQC', 'SBM_surfacevis', ...
                'SBM_extract_subjects', 'SBM_combat', 'SBM_metadata', ...
                'SBM_statistical_analysis', 'SBM_parcellation', 'SBM_nulltest', ...
                'SBM_consistency', 'SBM_covariates', 'SBM_sample_size_effect', ...
                'SBM_figures'};

% Handle multiple stages
if iscell(stage)
    % Multiple stages provided as cell array
    stages_to_run = stage;
    
    % Validate all stages
    for i = 1:length(stages_to_run)
        if ~ismember(stages_to_run{i}, valid_stages)
            error('Invalid stage "%s". Valid stages are: %s', stages_to_run{i}, strjoin(valid_stages, ', '));
        end
    end
    
    % Run each stage in sequence
    fprintf('Running %d stages: %s\n', length(stages_to_run), strjoin(stages_to_run, ', '));
    
    for i = 1:length(stages_to_run)
        current_stage = stages_to_run{i};
        fprintf('\n%s\n', repmat('=', 1, 50));
        fprintf('Starting stage %d/%d: %s\n', i, length(stages_to_run), upper(current_stage));
        fprintf('%s\n', repmat('=', 1, 50));
        
        try
            success = run_single_stage(current_stage, config);
            if ~success
                error('Stage "%s" failed', current_stage);
            end
            fprintf('Stage "%s" completed successfully!\n', current_stage);
        catch ME
            fprintf('Error in stage "%s": %s\n', current_stage, ME.message);
            error('Pipeline failed at stage "%s"', current_stage);
        end
    end
    
    fprintf('\n%s\n', repmat('=', 1, 50));
    fprintf('All %d stages completed successfully!\n', length(stages_to_run));
    fprintf('%s\n', repmat('=', 1, 50));
    
else
    % Single stage provided as string
    if ~ismember(stage, valid_stages)
        error('Invalid stage. Valid stages are: %s', strjoin(valid_stages, ', '));
    end
    
    success = run_single_stage(stage, config);
    if ~success
        error('Pipeline stage failed');
    end
    
    fprintf('Pipeline stage ''%s'' completed successfully!\n', stage);
end
end

function success = run_single_stage(stage, config)
% Run a single pipeline stage
switch stage
    case 'step0a_create_dataset_list'
        success = run_step0a_create_dataset_list(config);
    case 'step0b_organize_bids'
        success = run_step0b_organize_bids(config);
    case 'step1a_VBM_CAT12_preprocess'
        success = run_vbm_cat12_step1a(config);
    case 'step1b_VBM_CAT12_report_concat'
        success = run_vbm_cat12_step1b(config);
    case 'step1c_VBM_CAT12_visualisation'
        success = run_vbm_cat12_step1c(config);
    case 'step2_VBM_extract_subjects'
        success = run_vbm_extract_subjects_step2(config);
    case 'step3_VBM_smoothing'
        success = run_vbm_smoothing_step3(config);
    case 'step4a_VBM_combine_metadata'
        success = run_vbm_combine_metadata_step4a(config);
    case 'step4b_VBM_make_mask'
        success = run_vbm_make_mask_step4b(config);
    case 'step4c_VBM_combat_input'
        success = run_vbm_combat_step4c(config);
    case 'step4d_VBM_combat'
        success = run_vbm_combat_step4d(config);
    case 'step4e_VBM_combat_output'
        success = run_vbm_combat_step4e(config);
    case 'step5_VBM_statistical_analysis'
        success = run_vbm_statistical_analysis(config);
    case 'VBM_parcellation'
        success = run_vbm_parcellation(config);
    case 'VBM_nulltest'
        success = run_vbm_nulltest(config);
    case 'VBM_consistency'
        success = run_vbm_consistency(config);
    case 'VBM_covariates'
        success = run_vbm_covariates(config);
    case 'VBM_figures'
        success = run_vbm_figures(config);
    case 'SBM_recon_all'
        success = run_sbm_recon_all(config);
    case 'SBM_autoQC'
        success = run_sbm_autoQC(config);
    case 'SBM_surfacevis'
        success = run_sbm_surfacevis(config);
    case 'SBM_extract_subjects'
        success = run_sbm_extract_subjects(config);
    case 'SBM_combat'
        success = run_sbm_combat(config);
    case 'SBM_metadata'
        success = run_sbm_metadata(config);
    case 'SBM_statistical_analysis'
        success = run_sbm_statistical_analysis(config);
    case 'SBM_parcellation'
        success = run_sbm_parcellation(config);
    case 'SBM_nulltest'
        success = run_sbm_nulltest(config);
    case 'SBM_consistency'
        success = run_sbm_consistency(config);
    case 'SBM_covariates'
        success = run_sbm_covariates(config);
    case 'SBM_sample_size_effect'
        success = run_sbm_sample_size_effect(config);
    case 'SBM_figures'
        success = run_sbm_figures(config);
end
end

function config = load_config(config_file)
% Load configuration from JSON file and resolve variables
try
    config = jsondecode(fileread(config_file));
    config = resolve_variables(config);
catch ME
    error('Failed to load config file %s: %s', config_file, ME.message);
end
end

function config = resolve_variables(config)
% Resolve ${variable} references in config
if isfield(config, 'data_directories') && isfield(config.data_directories, 'dataset_root')
    dataset_root = config.data_directories.dataset_root;
    
    % Resolve dataset paths
    if isfield(config, 'datasets')
        dataset_names = fieldnames(config.datasets);
        for i = 1:length(dataset_names)
            dataset_name = dataset_names{i};
            if isfield(config.datasets.(dataset_name), 'path')
                path = config.datasets.(dataset_name).path;
                % Replace ${dataset_root} with actual path
                path = strrep(path, '${dataset_root}', dataset_root);
                config.datasets.(dataset_name).path = path;
            end
        end
    end
end
end

function success = run_step0a_create_dataset_list(config)
fprintf('=== STEP 0A: CREATE DATASET LIST ===\n');

enabled_datasets = get_enabled_datasets(config);

% Create dataset list file for shell scripts
dataset_root = config.data_directories.dataset_root;
dataset_list_file = fullfile(dataset_root, 'dataset_list.txt');
fid = fopen(dataset_list_file, 'w');
if fid == -1
    fprintf('  Error: Could not create dataset list file: %s\n', dataset_list_file);
    success = false;
    return;
end
for ii = 1:numel(enabled_datasets)
    fprintf(fid, '%s\n', enabled_datasets{ii});
end
fclose(fid);
fprintf('  Created dataset list: %s\n', dataset_list_file);
fprintf('  Found %d enabled datasets: %s\n', numel(enabled_datasets), strjoin(enabled_datasets, ', '));
success = true;
end

function success = run_step0b_organize_bids(config)
fprintf('=== STEP 0B: ORGANIZE BIDS STAGE ===\n');

enabled_datasets = get_enabled_datasets(config);

% Resolve data_BIDS directory relative to this file if it is a relative path
project_root = fileparts(mfilename('fullpath'));
data_bids_dir = resolve_relative_path(project_root, config.data_directories.data_BIDS);

for i = 1:length(enabled_datasets)
    dataset_name = enabled_datasets{i};
    dataset_config = config.datasets.(dataset_name);
    bids_script = fullfile(data_bids_dir, dataset_config.bids_script);
    
    if exist(bids_script, 'file')
        fprintf('  Running BIDS script: %s\n', bids_script);
        try
            % Get the function name from the script file
            [script_dir, func_name, ~] = fileparts(bids_script);
            
            % Add directory to path, call function, then remove
            addpath(script_dir);
            feval(func_name, config);
            rmpath(script_dir);
            
        catch ME
            fprintf('  Error running BIDS script: %s\n', ME.message);
            success = false;
            return;
        end
    else
        fprintf('  Warning: BIDS script not found: %s\n', bids_script);
    end
end
success = true;
end

function enabled_datasets = get_enabled_datasets(config)
% Return cell array of dataset names with enabled == true
enabled_datasets = {};
if ~isfield(config, 'datasets') || isempty(fieldnames(config.datasets))
    return;
end
dataset_names = fieldnames(config.datasets);
for k = 1:numel(dataset_names)
    name_k = dataset_names{k};
    ds = config.datasets.(name_k);
    if isfield(ds, 'enabled') && logical(ds.enabled)
        enabled_datasets{end+1} = name_k; %#ok<AGROW>
    end
end
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
        datasets_by_group.(group){end+1} = name_k;
    end
end
end


function absPath = resolve_relative_path(baseDir, pathStr)
% If pathStr is absolute, return as-is; otherwise resolve relative to baseDir
if ispc
    % Windows absolute path starts with drive letter like C:\ or \\
    isAbs = ~isempty(regexp(pathStr, '^[A-Za-z]:\\|^\\\\', 'once'));
else
    % Unix absolute path starts with /
    isAbs = startsWith(pathStr, filesep);
end
if isAbs
    absPath = pathStr;
else
    absPath = fullfile(baseDir, pathStr);
end
end

% --- VBM steps ---


function success = run_vbm_cat12_step1a(config)
fprintf('=== VBM CAT12 STEP 1A: SUBMIT PREPROCESSING JOBS ===\n');
vbm_dir = config.data_directories.VBM;
step1_dir = fullfile(vbm_dir, 'preprocessing', 'step1_CAT12');
% Support original filename
cat12_script = fullfile(step1_dir, 'step1a_CAT12_preprocessing_send.sh');
if ~exist(cat12_script, 'file')
    fprintf('  Warning: CAT12 send script not found: %s\n', cat12_script);
    success = false;
    return;
end
try
    dataset_root = config.data_directories.dataset_root;
    setenv('DATA_ROOT', dataset_root);
    % Allow passing config file to shell if desired
    if isfield(config, 'config_file')
        setenv('CONFIG_FILE', config.config_file);
    end
    system(['bash ', cat12_script]);
    success = true;
catch ME
    fprintf('  Error running CAT12 step1a: %s\n', ME.message);
    success = false;
end
end

function success = run_vbm_cat12_step1b(config)
fprintf('=== VBM CAT12 STEP 1B: QC REPORT + SUBJECT FILTERING ===\n');
vbm_dir = config.data_directories.VBM;
step1_dir = fullfile(vbm_dir, 'preprocessing', 'step1_CAT12');
% Use the step1b script name
qc_script = fullfile(step1_dir, 'step1b_cat12_qcReport_concat.sh');
if ~exist(qc_script, 'file')
    fprintf('  Warning: QC concat script not found: %s\n', qc_script);
    success = false;
    return;
end
try
    dataset_root = config.data_directories.dataset_root;
    setenv('DATA_ROOT', dataset_root);
    % Pass config file to shell script
    if isfield(config, 'config_file')
        setenv('CONFIG_FILE', config.config_file);
    end
    % Determine whether to consider sessions based on dataset configs
    enabled_names = get_enabled_datasets(config);
    consider_sessions = false;
    for ii = 1:numel(enabled_names)
        ds_name = enabled_names{ii};
        if isfield(config.datasets.(ds_name), 'longitudinal') && logical(config.datasets.(ds_name).longitudinal)
            consider_sessions = true;
            break;
        end
    end
    if consider_sessions
        % Signal the shell script to handle sessions
        setenv('ses', 'ses-1');
        fprintf('  Session-aware QC: considering sessions for longitudinal datasets.\n');
    else
        % Ensure session var is not set so script treats data as single-session
        setenv('ses', '');
        fprintf('  Session-aware QC: no longitudinal datasets enabled; ignoring sessions.\n');
    end
    system(['bash ', qc_script]);
    success = true;
catch ME
    fprintf('  Warning: CAT12 step1b failed: %s\n', ME.message);
    success = false;
end
end

function success = run_vbm_cat12_step1c(config)
fprintf('=== VBM CAT12 STEP 1C: RENDER IMAGES FOR QC PASSED SUBJECTS ===\n');
vbm_dir = config.data_directories.VBM;
step1_dir = fullfile(vbm_dir, 'preprocessing', 'step1_CAT12');
% Use the step1c script name
viz_script = fullfile(step1_dir, 'step1c_visualisation_individual.sh');
if ~exist(viz_script, 'file')
    fprintf('  Warning: Individual visualization script not found: %s\n', viz_script);
    success = false;
    return;
end
try
    dataset_root = config.data_directories.dataset_root;
    setenv('DATA_ROOT', dataset_root);
    % Pass config file to shell script
    if isfield(config, 'config_file')
        setenv('CONFIG_FILE', config.config_file);
    end
    % Run the visualization script (handles both rendering and PDF concatenation)
    cmd = sprintf('bash %s', viz_script);
    [status, output] = system(cmd);
    if status == 0
        fprintf('  Image rendering and PDF concatenation completed successfully\n');
        success = true;
    else
        fprintf('  Warning: Image rendering and PDF concatenation failed with status %d\n', status);
        fprintf('  Output: %s\n', output);
        success = false;
    end
catch ME
    fprintf('  Warning: CAT12 step1c failed: %s\n', ME.message);
    success = false;
end
end

function success = run_vbm_extract_subjects_step2(config)
fprintf('=== VBM EXTRACT SUBJECTS STEP 2 ===\n');
enabled_datasets = get_enabled_datasets(config);

% Get VBM preprocessing directory
vbm_dir = config.data_directories.VBM;
extract_dir = fullfile(vbm_dir, 'preprocessing', 'step2_extract_subjects');

for i = 1:length(enabled_datasets)
    dataset_name = enabled_datasets{i};
    fprintf('  Processing dataset: %s\n', dataset_name);
    
    % Construct extract function name based on dataset
    extract_function = sprintf('extract_sub_%s', dataset_name);
    extract_script = fullfile(extract_dir, [extract_function, '.m']);
    
    if exist(extract_script, 'file')
        fprintf('  Running extract function: %s\n', extract_function);
        try
            % Add directory to path, call function, then remove
            addpath(extract_dir);
            feval(extract_function, config);
            rmpath(extract_dir);
            fprintf('  Successfully processed %s\n', dataset_name);
            
        catch ME
            fprintf('  Error running extract function for %s: %s\n', dataset_name, ME.message);
            rmpath(extract_dir);
            success = false;
            return;
        end
    else
        fprintf('  Warning: Extract function not found: %s\n', extract_script);
    end
end
success = true;
end

function success = run_vbm_smoothing_step3(config)
fprintf('=== VBM SMOOTHING STEP 3 ===\n');
vbm_dir = config.data_directories.VBM;
step3_dir = fullfile(vbm_dir, 'preprocessing', 'step3_smoothing');
smooth_script = fullfile(step3_dir, 'run_smooth_TIV_send.sh');
if exist(smooth_script, 'file')
    fprintf('  Running smoothing...\n');
    try
        dataset_root = config.data_directories.dataset_root;
        setenv('DATA_ROOT', dataset_root);
        
        % Set smoothing kernel from config or use default
        if isfield(config.analysis_settings, 'smoothing_kernel')
            setenv('smoothKernel', num2str(config.analysis_settings.smoothing_kernel));
        else
            setenv('smoothKernel', '6'); % default 6mm
        end
        
        % Determine whether to consider sessions based on dataset configs
        enabled_names = get_enabled_datasets(config);
        consider_sessions = false;
        for ii = 1:numel(enabled_names)
            ds_name = enabled_names{ii};
            if isfield(config.datasets.(ds_name), 'longitudinal') && logical(config.datasets.(ds_name).longitudinal)
                consider_sessions = true;
                break;
            end
        end
        if consider_sessions
            setenv('isses', '1');
            fprintf('  Session-aware smoothing: considering sessions for longitudinal datasets.\n');
        else
            setenv('isses', '0');
            fprintf('  Session-aware smoothing: no longitudinal datasets enabled; ignoring sessions.\n');
        end
        
        % Pass config file to shell script
        if isfield(config, 'config_file')
            setenv('CONFIG_FILE', config.config_file);
        end
        
        system(['bash ', smooth_script]);
        success = true;
    catch ME
        fprintf('  Error running smoothing: %s\n', ME.message);
        success = false;
        return;
    end
else
    fprintf('  Warning: Smoothing script not found: %s\n', smooth_script);
    success = false;
end
end


function success = run_vbm_combine_metadata_step4a(config)
fprintf('=== VBM COMBINE METADATA STEP 4A ===\n');
vbm_dir = config.data_directories.VBM;
step4_dir = fullfile(vbm_dir, 'preprocessing', 'step4_combat');
step4a_script = fullfile(step4_dir, 'step4a_combine_metadata.m');
if exist(step4a_script, 'file')
    fprintf('  Running metadata combination...\n');
    try
        addpath(step4_dir);
        step4a_combine_metadata(config);
        rmpath(step4_dir);
        success = true;
    catch ME
        fprintf('  Error running metadata combination step4a: %s\n', ME.message);
        rmpath(step4_dir);
        success = false;
        return;
    end
else
    fprintf('  Warning: Metadata combination step4a script not found: %s\n', step4a_script);
    success = false;
end
end


function success = run_vbm_make_mask_step4b(config)
fprintf('=== VBM MAKE MASK STEP 4B ===\n');
vbm_dir = config.data_directories.VBM;
step4_dir = fullfile(vbm_dir, 'preprocessing', 'step4_combat');
step4b_script = fullfile(step4_dir, 'step4b_make_mask.m');
if exist(step4b_script, 'file')
    fprintf('  Running mask creation...\n');
    try
        addpath(step4_dir);
        step4b_make_mask(config);
        rmpath(step4_dir);
        success = true;
    catch ME
        fprintf('  Error running make mask step4b: %s\n', ME.message);
        rmpath(step4_dir);
        success = false;
        return;
    end
else
    fprintf('  Warning: Make mask step4b script not found: %s\n', step4b_script);
    success = false;
end
end

function success = run_vbm_combat_step4c(config)
fprintf('=== VBM COMBAT STEP 4C: INPUT PREPARATION ===\n');
vbm_dir = config.data_directories.VBM;
step4_dir = fullfile(vbm_dir, 'preprocessing', 'step4_combat');
step4c_script = fullfile(step4_dir, 'step4c_combat_input.m');
if exist(step4c_script, 'file')
    fprintf('  Running COMBAT input preparation...\n');
    try
        addpath(step4_dir);
        step4c_combat_input(config);
        rmpath(step4_dir);
        success = true;
    catch ME
        fprintf('  Error running COMBAT step4c: %s\n', ME.message);
        rmpath(step4_dir);
        success = false;
        return;
    end
else
    fprintf('  Warning: COMBAT step4c script not found: %s\n', step4c_script);
    success = false;
end
end

function success = run_vbm_combat_step4d(config)
fprintf('=== VBM COMBAT STEP 4D: HARMONIZATION ===\n');
vbm_dir = config.data_directories.VBM;
step4_dir = fullfile(vbm_dir, 'preprocessing', 'step4_combat');
step4d_script = fullfile(step4_dir, 'step4d_combat_run.m');
if exist(step4d_script, 'file')
    fprintf('  Running COMBAT harmonization...\n');
    try
        addpath(step4_dir);
        step4d_combat_run(config);
        rmpath(step4_dir);
        success = true;
    catch ME
        fprintf('  Error running COMBAT step4d: %s\n', ME.message);
        rmpath(step4_dir);
        success = false;
        return;
    end
else
    fprintf('  Warning: COMBAT step4d script not found: %s\n', step4d_script);
    success = false;
end
end

function success = run_vbm_combat_step4e(config)
fprintf('=== VBM COMBAT STEP 4E: OUTPUT CREATION ===\n');
vbm_dir = config.data_directories.VBM;
step4_dir = fullfile(vbm_dir, 'preprocessing', 'step4_combat');
step4e_script = fullfile(step4_dir, 'step4e_combat_output.m');
if exist(step4e_script, 'file')
    fprintf('  Running COMBAT output creation...\n');
    try
        addpath(step4_dir);
        step4e_combat_output(config);
        rmpath(step4_dir);
        success = true;
    catch ME
        fprintf('  Error running COMBAT step4e: %s\n', ME.message);
        rmpath(step4_dir);
        success = false;
        return;
    end
else
    fprintf('  Warning: COMBAT step4e script not found: %s\n', step4e_script);
    success = false;
end
end

function success = run_vbm_metadata(config)
fprintf('=== VBM COMBINE METADATA ===\n');
vbm_dir = config.data_directories.VBM;
combine_script = fullfile(vbm_dir, 'preprocessing', 'step5_combine_metadata.m');
if exist(combine_script, 'file')
    fprintf('  Combining metadata...\n');
    try
        run(combine_script);
    catch ME
        fprintf('  Error combining metadata: %s\n', ME.message);
        success = false;
        return;
    end
else
    fprintf('  Warning: Combine metadata script not found: %s\n', combine_script);
end
success = true;
end

function success = run_vbm_voxelwise(config)
fprintf('=== VBM VOXELWISE ANALYSIS ===\n');
vbm_dir = config.data_directories.VBM;
analysis_dir = fullfile(vbm_dir, 'analysis');
voxelwise_script = fullfile(analysis_dir, 'runGLM_send.sh');
if exist(voxelwise_script, 'file')
    fprintf('  Running voxelwise analysis...\n');
    try
        system(['bash ', voxelwise_script]);
    catch ME
        fprintf('  Error running voxelwise analysis: %s\n', ME.message);
        success = false;
        return;
    end
else
    fprintf('  Warning: Voxelwise script not found: %s\n', voxelwise_script);
end
success = true;
end

function success = run_vbm_roi(config)
fprintf('=== VBM ROI ANALYSIS ===\n');
vbm_dir = config.data_directories.VBM;
analysis_dir = fullfile(vbm_dir, 'analysis');
roi_script = fullfile(analysis_dir, 'roi', 'runGLM_send.sh');
if exist(roi_script, 'file')
    fprintf('  Running ROI analysis...\n');
    try
        system(['bash ', roi_script]);
    catch ME
        fprintf('  Error running ROI analysis: %s\n', ME.message);
        success = false;
        return;
    end
else
    fprintf('  Warning: ROI script not found: %s\n', roi_script);
end
success = true;
end

function success = run_vbm_statistical_analysis(config)
fprintf('=== VBM STATISTICAL ANALYSIS ===\n');
vbm_dir = config.data_directories.VBM;
analysis_dir = fullfile(vbm_dir, 'analysis', 'step1_statistical_analysis');
stat_script = fullfile(analysis_dir, 'runGLM_send.sh');
if exist(stat_script, 'file')
    fprintf('  Running statistical analysis...\n');
    try
        system(['bash ', stat_script]);
    catch ME
        fprintf('  Error running statistical analysis: %s\n', ME.message);
        success = false;
        return;
    end
else
    fprintf('  Warning: Statistical analysis script not found: %s\n', stat_script);
end
success = true;
end

function success = run_vbm_parcellation(config)
fprintf('=== VBM PARCELLATION ===\n');
vbm_dir = config.data_directories.VBM;
analysis_dir = fullfile(vbm_dir, 'analysis', 'step2_parcellation');
parc_script = fullfile(analysis_dir, 'parcellation_batch.sh');
if exist(parc_script, 'file')
    fprintf('  Running parcellation...\n');
    try
        system(['bash ', parc_script]);
    catch ME
        fprintf('  Error running parcellation: %s\n', ME.message);
        success = false;
        return;
    end
else
    fprintf('  Warning: Parcellation script not found: %s\n', parc_script);
end
success = true;
end

function success = run_vbm_nulltest(config)
fprintf('=== VBM NULL TEST ===\n');
vbm_dir = config.data_directories.VBM;
analysis_dir = fullfile(vbm_dir, 'analysis', 'step3_nulltest');
null_script = fullfile(analysis_dir, 'nulltest_send.sh');
if exist(null_script, 'file')
    fprintf('  Running null test...\n');
    try
        system(['bash ', null_script]);
    catch ME
        fprintf('  Error running null test: %s\n', ME.message);
        success = false;
        return;
    end
else
    fprintf('  Warning: Null test script not found: %s\n', null_script);
end
success = true;
end

function success = run_vbm_consistency(config)
fprintf('=== VBM CONSISTENCY ANALYSIS ===\n');
vbm_dir = config.data_directories.VBM;
analysis_dir = fullfile(vbm_dir, 'analysis', 'step4_consistency');
consistency_script = fullfile(analysis_dir, 'consistency_analysis.sh');
if exist(consistency_script, 'file')
    fprintf('  Running consistency analysis...\n');
    try
        system(['bash ', consistency_script]);
    catch ME
        fprintf('  Error running consistency analysis: %s\n', ME.message);
        success = false;
        return;
    end
else
    fprintf('  Warning: Consistency analysis script not found: %s\n', consistency_script);
end
success = true;
end

function success = run_vbm_covariates(config)
fprintf('=== VBM COVARIATE ANALYSIS ===\n');
vbm_dir = config.data_directories.VBM;
analysis_dir = fullfile(vbm_dir, 'analysis', 'step5_covariates');
covariate_script = fullfile(analysis_dir, 'covariate_analysis.sh');
if exist(covariate_script, 'file')
    fprintf('  Running covariate analysis...\n');
    try
        system(['bash ', covariate_script]);
    catch ME
        fprintf('  Error running covariate analysis: %s\n', ME.message);
        success = false;
        return;
    end
else
    fprintf('  Warning: Covariate analysis script not found: %s\n', covariate_script);
end
success = true;
end

function success = run_vbm_figures(config)
fprintf('=== VBM FIGURE GENERATION ===\n');
vbm_dir = config.data_directories.VBM;
analysis_dir = fullfile(vbm_dir, 'analysis', 'step6_figures');
figure_script = fullfile(analysis_dir, 'generate_figures.sh');
if exist(figure_script, 'file')
    fprintf('  Generating figures...\n');
    try
        system(['bash ', figure_script]);
    catch ME
        fprintf('  Error generating figures: %s\n', ME.message);
        success = false;
        return;
    end
else
    fprintf('  Warning: Figure generation script not found: %s\n', figure_script);
end
success = true;
end

% --- SBM steps ---

function success = run_sbm_recon_all(config)
fprintf('=== SBM RECON-ALL ===\n');
sbm_dir = config.data_directories.SBM;
step1_dir = fullfile(sbm_dir, 'preprocessing', 'step1_recon_all');
recon_script = fullfile(step1_dir, 'Step0.recon_all.sh');
if exist(recon_script, 'file')
    fprintf('  Running recon-all...\n');
    try
        system(['bash ', recon_script]);
    catch ME
        fprintf('  Error running recon-all: %s\n', ME.message);
        success = false;
        return;
    end
else
    fprintf('  Warning: Recon-all script not found: %s\n', recon_script);
end
success = true;
end

function success = run_sbm_autoQC(config)
fprintf('=== SBM AUTO QC ===\n');
sbm_dir = config.data_directories.SBM;
step2_dir = fullfile(sbm_dir, 'preprocessing', 'step2_autoQC');
qc_script = fullfile(step2_dir, 'Step1a.mriqc_individual.sh');
if exist(qc_script, 'file')
    fprintf('  Running auto QC...\n');
    try
        system(['bash ', qc_script]);
    catch ME
        fprintf('  Error running auto QC: %s\n', ME.message);
        success = false;
        return;
    end
else
    fprintf('  Warning: Auto QC script not found: %s\n', qc_script);
end
success = true;
end

function success = run_sbm_surfacevis(config)
fprintf('=== SBM SURFACE VISUALIZATION ===\n');
sbm_dir = config.data_directories.SBM;
step3_dir = fullfile(sbm_dir, 'preprocessing', 'step3_surfacevis');
surface_script = fullfile(step3_dir, 'Step2.freeview_job.sh');
if exist(surface_script, 'file')
    fprintf('  Running surface visualization...\n');
    try
        system(['bash ', surface_script]);
    catch ME
        fprintf('  Error running surface visualization: %s\n', ME.message);
        success = false;
        return;
    end
else
    fprintf('  Warning: Surface visualization script not found: %s\n', surface_script);
end
success = true;
end

function success = run_sbm_combat(config)
fprintf('=== SBM COMBAT HARMONIZATION ===\n');
sbm_dir = config.data_directories.SBM;
step5_dir = fullfile(sbm_dir, 'preprocessing', 'step5_combat');
combat_script = fullfile(step5_dir, 'COMBAT_run_sbatch.sh');
if exist(combat_script, 'file')
    fprintf('  Running COMBAT harmonization...\n');
    try
        system(['bash ', combat_script]);
    catch ME
        fprintf('  Error running COMBAT: %s\n', ME.message);
        success = false;
        return;
    end
else
    fprintf('  Warning: COMBAT script not found: %s\n', combat_script);
end
success = true;
end

function success = run_sbm_metadata(config)
fprintf('=== SBM COMBINE METADATA ===\n');
sbm_dir = config.data_directories.SBM;
combine_script = fullfile(sbm_dir, 'preprocessing', 'step6_combine_metadata.m');
if exist(combine_script, 'file')
    fprintf('  Combining metadata...\n');
    try
        run(combine_script);
    catch ME
        fprintf('  Error combining metadata: %s\n', ME.message);
        success = false;
        return;
    end
else
    fprintf('  Warning: Combine metadata script not found: %s\n', combine_script);
end
success = true;
end

function success = run_sbm_analysis(config)
fprintf('=== SBM SURFACE ANALYSIS ===\n');
sbm_dir = config.data_directories.SBM;
analysis_dir = fullfile(sbm_dir, 'analysis');
surface_script = fullfile(analysis_dir, 'runGLM_send.sh');
if exist(surface_script, 'file')
    fprintf('  Running surface analysis...\n');
    try
        system(['bash ', surface_script]);
    catch ME
        fprintf('  Error running surface analysis: %s\n', ME.message);
        success = false;
        return;
    end
else
    fprintf('  Warning: Surface analysis script not found: %s\n', surface_script);
end
success = true;
end

function success = run_sbm_extract_subjects(config)
fprintf('=== SBM EXTRACT SUBJECTS ===\n');
sbm_dir = config.data_directories.SBM;
step4_dir = fullfile(sbm_dir, 'preprocessing', 'step4_extract_subjects');
extract_script = fullfile(step4_dir, 'extract_subjects_batch.sh');
if exist(extract_script, 'file')
    fprintf('  Extracting subjects...\n');
    try
        system(['bash ', extract_script]);
    catch ME
        fprintf('  Error extracting subjects: %s\n', ME.message);
        success = false;
        return;
    end
else
    fprintf('  Warning: Extract subjects script not found: %s\n', extract_script);
end
success = true;
end

function success = run_sbm_statistical_analysis(config)
fprintf('=== SBM STATISTICAL ANALYSIS ===\n');
sbm_dir = config.data_directories.SBM;
analysis_dir = fullfile(sbm_dir, 'analysis', 'step1_statistical_analysis');
stat_script = fullfile(analysis_dir, 'glmfit_send.sh');
if exist(stat_script, 'file')
    fprintf('  Running statistical analysis...\n');
    try
        system(['bash ', stat_script]);
    catch ME
        fprintf('  Error running statistical analysis: %s\n', ME.message);
        success = false;
        return;
    end
else
    fprintf('  Warning: Statistical analysis script not found: %s\n', stat_script);
end
success = true;
end

function success = run_sbm_parcellation(config)
fprintf('=== SBM PARCELLATION ===\n');
sbm_dir = config.data_directories.SBM;
analysis_dir = fullfile(sbm_dir, 'analysis', 'step2_parcellation');
parc_script = fullfile(analysis_dir, 'parcellation_batch.sh');
if exist(parc_script, 'file')
    fprintf('  Running parcellation...\n');
    try
        system(['bash ', parc_script]);
    catch ME
        fprintf('  Error running parcellation: %s\n', ME.message);
        success = false;
        return;
    end
else
    fprintf('  Warning: Parcellation script not found: %s\n', parc_script);
end
success = true;
end

function success = run_sbm_nulltest(config)
fprintf('=== SBM NULL TEST ===\n');
sbm_dir = config.data_directories.SBM;
analysis_dir = fullfile(sbm_dir, 'analysis', 'step3_nulltest');
null_script = fullfile(analysis_dir, 'nulltest_send.sh');
if exist(null_script, 'file')
    fprintf('  Running null test...\n');
    try
        system(['bash ', null_script]);
    catch ME
        fprintf('  Error running null test: %s\n', ME.message);
        success = false;
        return;
    end
else
    fprintf('  Warning: Null test script not found: %s\n', null_script);
end
success = true;
end

function success = run_sbm_consistency(config)
fprintf('=== SBM CONSISTENCY ANALYSIS ===\n');
sbm_dir = config.data_directories.SBM;
analysis_dir = fullfile(sbm_dir, 'analysis', 'step4_consistency');
consistency_script = fullfile(analysis_dir, 'consistency_analysis.sh');
if exist(consistency_script, 'file')
    fprintf('  Running consistency analysis...\n');
    try
        system(['bash ', consistency_script]);
    catch ME
        fprintf('  Error running consistency analysis: %s\n', ME.message);
        success = false;
        return;
    end
else
    fprintf('  Warning: Consistency analysis script not found: %s\n', consistency_script);
end
success = true;
end

function success = run_sbm_covariates(config)
fprintf('=== SBM COVARIATE ANALYSIS ===\n');
sbm_dir = config.data_directories.SBM;
analysis_dir = fullfile(sbm_dir, 'analysis', 'step5_covariates');
covariate_script = fullfile(analysis_dir, 'covariate_analysis.sh');
if exist(covariate_script, 'file')
    fprintf('  Running covariate analysis...\n');
    try
        system(['bash ', covariate_script]);
    catch ME
        fprintf('  Error running covariate analysis: %s\n', ME.message);
        success = false;
        return;
    end
else
    fprintf('  Warning: Covariate analysis script not found: %s\n', covariate_script);
end
success = true;
end

function success = run_sbm_sample_size_effect(config)
fprintf('=== SBM SAMPLE SIZE EFFECT ===\n');
sbm_dir = config.data_directories.SBM;
analysis_dir = fullfile(sbm_dir, 'analysis', 'step6_sample_size_effect');
sample_script = fullfile(analysis_dir, 'sample_size_effect.sh');
if exist(sample_script, 'file')
    fprintf('  Running sample size effect analysis...\n');
    try
        system(['bash ', sample_script]);
    catch ME
        fprintf('  Error running sample size effect analysis: %s\n', ME.message);
        success = false;
        return;
    end
else
    fprintf('  Warning: Sample size effect script not found: %s\n', sample_script);
end
success = true;
end

function success = run_sbm_figures(config)
fprintf('=== SBM FIGURE GENERATION ===\n');
sbm_dir = config.data_directories.SBM;
analysis_dir = fullfile(sbm_dir, 'analysis', 'step7_figures');
figure_script = fullfile(analysis_dir, 'generate_figures.sh');
if exist(figure_script, 'file')
    fprintf('  Generating figures...\n');
    try
        system(['bash ', figure_script]);
    catch ME
        fprintf('  Error generating figures: %s\n', ME.message);
        success = false;
        return;
    end
else
    fprintf('  Warning: Figure generation script not found: %s\n', figure_script);
end
success = true;
end
