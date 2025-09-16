function run_pipeline(stage, config_file)
% Main pipeline runner for neuroimaging analysis
% Supports running the full pipeline, individual stages, or multiple stages
%
% Usage:
%   run_pipeline('organize_bids')                    % Run single stage
%   run_pipeline({'organize_bids', 'organize_extract'}) % Run multiple stages
%   run_pipeline('VBM_CAT12')                        % Run VBM CAT12 only
%   run_pipeline('full')                             % Run full pipeline
%   run_pipeline('organize_bids', 'my_config.json')  % Use custom config
%   run_pipeline({'VBM_CAT12', 'VBM_smoothing'}, 'my_config.json') % Multiple stages with custom config

if nargin < 1
    error('Please specify a stage to run');
end

if nargin < 2
    config_file = 'config.json';
end

% Load configuration
config = load_config(config_file);

% Validate stage - Updated to include all stages from config.json
valid_stages = {'organize_bids',  ...
                'VBM_CAT12', 'VBM_extract_subjects', 'VBM_smoothing', ...
                'VBM_combat', 'VBM_metadata', 'VBM_statistical_analysis', ...
                'VBM_parcellation', 'VBM_nulltest', 'VBM_consistency', ...
                'VBM_covariates', 'VBM_figures', ...
                'SBM_recon_all', 'SBM_autoQC', 'SBM_surfacevis', ...
                'SBM_extract_subjects', 'SBM_combat', 'SBM_metadata', ...
                'SBM_statistical_analysis', 'SBM_parcellation', 'SBM_nulltest', ...
                'SBM_consistency', 'SBM_covariates', 'SBM_sample_size_effect', ...
                'SBM_figures', 'full'};

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
    case 'organize_bids'
        success = run_organize_bids(config);
    case 'VBM_CAT12'
        success = run_vbm_cat12(config);
    case 'VBM_extract_subjects'
        success = run_vbm_extract_subjects(config);
    case 'VBM_smoothing'
        success = run_vbm_smoothing(config);
    case 'VBM_combat'
        success = run_vbm_combat(config);
    case 'VBM_metadata'
        success = run_vbm_metadata(config);
    case 'VBM_statistical_analysis'
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
    case 'full'
        success = run_full_pipeline(config);
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

function success = run_organize_bids(config)
fprintf('=== ORGANIZE BIDS STAGE ===\n');
enabled_datasets = get_enabled_datasets(config);
% Resolve data_BIDS directory relative to this file if it's a relative path
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

function success = run_vbm_cat12(config)
fprintf('=== VBM CAT12 PREPROCESSING ===\n');
vbm_dir = config.data_directories.VBM;
step1_dir = fullfile(vbm_dir, 'preprocessing', 'step1_CAT12');
cat12_script = fullfile(step1_dir, 'CAT12_preprocessing_send.sh');
if exist(cat12_script, 'file')
    fprintf('  Running CAT12 preprocessing...\n');
    try
        % Pass DATA_ROOT to shell so downstream scripts can read it
        dataset_root = config.data_directories.dataset_root;
        setenv('DATA_ROOT', dataset_root);
        system(['bash ', cat12_script]);
        % After preprocessing submissions, run QC report concatenation
        try
            qc_script = fullfile(step1_dir, 'cat12_qcReport_concat.sh');
            if exist(qc_script, 'file')
                fprintf('  Running CAT12 QC report concatenation...\n');
                system(['bash ', qc_script]);
            else
                fprintf('  Warning: QC concat script not found: %s\n', qc_script);
            end
        catch ME2
            fprintf('  Warning: CAT12 QC concat step failed: %s\n', ME2.message);
        end
    catch ME
        fprintf('  Error running CAT12 preprocessing: %s\n', ME.message);
        success = false;
        return;
    end
else
    fprintf('  Warning: CAT12 script not found: %s\n', cat12_script);
end
success = true;
end

function enabled_datasets = run_vbm_extract_subjects(config)
fprintf('=== VBM EXTRACT SUBJECTS ===\n');
enabled_datasets = get_enabled_datasets(config);
data_bids_dir = config.data_directories.data_BIDS;

for i = 1:length(enabled_datasets)
    dataset_name = enabled_datasets{i};
    dataset_config = config.datasets.(dataset_name);
    extract_script = fullfile(data_bids_dir, dataset_config.vbm_extract_script);
    
    if exist(extract_script, 'file')
        fprintf('  Running vbm_extract_subjects script: %s\n', extract_script);
        try
            % Get the function name from the script file
            [script_dir, func_name, ~] = fileparts(extract_script);
            
            % Add directory to path, call function, then remove
            addpath(script_dir);
            feval(func_name, config);
            rmpath(script_dir);
            
        catch ME
            fprintf('  Error running vbm_extract_subjects script: %s\n', ME.message);
            success = false;
            return;
        end
    else
        fprintf('  Warning: vbm_extract_subjects script not found: %s\n', extract_script);
    end
end
success = true;
end

function success = run_vbm_smoothing(config)
fprintf('=== VBM SMOOTHING ===\n');
vbm_dir = config.data_directories.VBM;
step3_dir = fullfile(vbm_dir, 'preprocessing', 'step3_smoothing');
smooth_script = fullfile(step3_dir, 'run_smooth_TIV_send.sh');
if exist(smooth_script, 'file')
    fprintf('  Running smoothing...\n');
    try
        system(['bash ', smooth_script]);
    catch ME
        fprintf('  Error running smoothing: %s\n', ME.message);
        success = false;
        return;
    end
else
    fprintf('  Warning: Smoothing script not found: %s\n', smooth_script);
end
success = true;
end

function success = run_vbm_combat(config)
fprintf('=== VBM COMBAT HARMONIZATION ===\n');
vbm_dir = config.data_directories.VBM;
step4_dir = fullfile(vbm_dir, 'preprocessing', 'step4_combat');
combat_script = fullfile(step4_dir, 'COMBAT_run_sbatch.sh');
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

function success = run_full_pipeline(config)
% Run all enabled stages in order according to config.json
stages = {'organize_bids', 'organize_extract', ...
          'VBM_CAT12', 'VBM_extract_subjects', 'VBM_smoothing', 'VBM_combat', 'VBM_metadata', ...
          'VBM_statistical_analysis', 'VBM_parcellation', 'VBM_nulltest', 'VBM_consistency', ...
          'VBM_covariates', 'VBM_figures', ...
          'SBM_recon_all', 'SBM_autoQC', 'SBM_surfacevis', 'SBM_extract_subjects', ...
          'SBM_combat', 'SBM_metadata', 'SBM_statistical_analysis', 'SBM_parcellation', ...
          'SBM_nulltest', 'SBM_consistency', 'SBM_covariates', 'SBM_sample_size_effect', ...
          'SBM_figures'};
for i = 1:length(stages)
    stage = stages{i};
    if isfield(config.pipeline_stages, stage) && config.pipeline_stages.(stage).enabled
        fprintf('\n%s\n', repmat('=', 1, 50));
        fprintf('Starting %s stage...\n', upper(stage));
        fprintf('%s\n', repmat('=', 1, 50));
        try
            run_pipeline(stage, config);
        catch ME
            fprintf('Error in %s stage: %s\n', stage, ME.message);
            success = false;
            return;
        end
    else
        fprintf('\nSkipping %s stage (disabled in config)\n', stage);
    end
end
success = true;
end 