function step4a_combine_metadata(config)
% STEP4A: Combine metadata from all datasets
% This function combines metadata from all enabled datasets and creates
% group-specific metadata files for COMBAT processing
%
% Input: config - Configuration structure containing paths and settings

% Use config passed as parameter, or load from file if not provided
if nargin < 1 || isempty(config)
    % Fallback: Load configuration from config.json file
    config = jsondecode(fileread('../../config.json'));
end

fprintf('=== STEP4A: COMBINE METADATA ===\n');

% Get paths from config
dataset_root = config.data_directories.dataset_root;

% Get enabled datasets
enabled_datasets = get_enabled_datasets(config);
if isempty(enabled_datasets)
    error('No enabled datasets found in config');
end

fprintf('Processing %d enabled datasets: %s\n', length(enabled_datasets), strjoin(enabled_datasets, ', '));

% Initialize a cell array to store individual metadata tables
metadata_tables = {};

% Define AD datasets (these will be classified as 'AD' group)
AD_dataset = {'AIBL', 'Harmonisation', 'miriad', 'OASIS3', 'OASIS4'};

% Loop through each enabled dataset
for i = 1:length(enabled_datasets)
    dataset_name = enabled_datasets{i};
    
    % Define the expected metadata file name
    metadata_file = fullfile(dataset_root, dataset_name, [dataset_name, '_dems.csv']);
    
    % Check if the metadata file exists
    if ~isfile(metadata_file)
        warning('Metadata file not found: %s. Skipping...', metadata_file);
        continue;
    end
    
    fprintf('  Reading metadata from: %s\n', metadata_file);
    
    % Read the metadata file into a table
    try
        metadata = readtable(metadata_file);
    catch ME
        warning('Failed to read metadata file: %s. Error: %s. Skipping...', metadata_file, ME.message);
        continue;
    end
    
    % Store the metadata table in the cell array
    metadata_tables{end+1} = metadata;
end

if isempty(metadata_tables)
    error('No valid metadata files found');
end

% Combine all metadata tables, aligning columns
fprintf('  Combining metadata from %d datasets...\n', length(metadata_tables));

% Get the union of all variable names
all_variable_names = {'subj_id', 'dataset', 'site', 'diagnosis', 'age', 'sex', 'site_string', 'sex_string', 'ses', 'diagnosis_string'};

% Align all tables to have the same variables
for i = 1:length(metadata_tables)
    if width(metadata_tables{i}) == 9
        addcellarray = cell(height(metadata_tables{i}), 1);
        addcellarray(:) = {''};
        metadata_tables{i} = addvars(metadata_tables{i}, ...
            addcellarray, ...
            'NewVariableNames', 'ses');
    end
    metadata_tables{i} = metadata_tables{i}(:, all_variable_names); % Reorder columns
end

% Concatenate all tables
metadata = vertcat(metadata_tables{:});

% Write the combined metadata to a CSV file
output_file = fullfile(dataset_root, 'metadataVBM.csv');
writetable(metadata, output_file);
fprintf('  Combined metadata saved to: %s\n', output_file);

% Split metadata by group (AD vs psy)
metadata_AD = metadata(ismember(metadata.dataset, AD_dataset), :);
metadata_psy = metadata(~ismember(metadata.dataset, AD_dataset), :);

% Write group-specific metadata files
metadata_AD_file = fullfile(dataset_root, 'metadataVBM_AD.csv');
metadata_psy_file = fullfile(dataset_root, 'metadataVBM_psy.csv');

writetable(metadata_AD, metadata_AD_file);
writetable(metadata_psy, metadata_psy_file);

fprintf('  AD group metadata saved to: %s (%d subjects)\n', metadata_AD_file, height(metadata_AD));
fprintf('  Psy group metadata saved to: %s (%d subjects)\n', metadata_psy_file, height(metadata_psy));

% Copy metadata files to derivatives directories for all smoothing kernels
smoothKernels = [6, 8, 12];
for smoothKernel = smoothKernels
    % Create derivatives directories
    deriv_dir = fullfile(dataset_root, 'derivatives', ['s', num2str(smoothKernel)]);
    combat_dir = fullfile(dataset_root, 'derivatives', ['s', num2str(smoothKernel), 'COMBAT']);
    
    if ~exist(deriv_dir, 'dir')
        mkdir(deriv_dir);
    end
    if ~exist(combat_dir, 'dir')
        mkdir(combat_dir);
    end
    
    % Copy metadata files
    writetable(metadata_AD, fullfile(deriv_dir, 'metadataVBM_AD.csv'));
    writetable(metadata_AD, fullfile(combat_dir, 'metadataVBM_AD.csv'));
    writetable(metadata_psy, fullfile(deriv_dir, 'metadataVBM_psy.csv'));
    writetable(metadata_psy, fullfile(combat_dir, 'metadataVBM_psy.csv'));
end

% Process extended metadata if available
fprintf('  Processing extended metadata...\n');
datasetList = unique(metadata.dataset);
nDataset = length(datasetList);

% Initialize extended metadata columns
metadata.CAT = cell(height(metadata), 1);
metadata.antipsychotic = cell(height(metadata), 1);
metadata.moodstabiliser = cell(height(metadata), 1);
metadata.antidepression = cell(height(metadata), 1);
metadata.antianxiety = cell(height(metadata), 1);
metadata.treatment = cell(height(metadata), 1);
metadata.ageOnset = NaN(height(metadata), 1);
metadata.illnessDuration = NaN(height(metadata), 1);

for iSet = 1:nDataset
    dataset_name = char(datasetList(iSet));
    extendFile = fullfile(dataset_root, dataset_name, [dataset_name, '_dems_extended.csv']);
    
    if exist(extendFile, 'file')
        fprintf('    Processing extended metadata for: %s\n', dataset_name);
        extend = readtable(extendFile, 'delimiter',',');
        [isinSet, ~] = ismember(metadata.dataset, dataset_name);
        
        [La, indexSetinData] = ismember(metadata.subj_id(isinSet), extend.subj_id);
        
        if ismember('CAT', extend.Properties.VariableNames)
            if iscell(extend.CAT)
                metadata.CAT(isinSet) = extend.CAT(indexSetinData);
            else
                metadata.CAT(isinSet) = cellstr(string(extend.CAT(indexSetinData)));
            end
        end
        if ismember('antipsychotic', extend.Properties.VariableNames)
            if iscell(extend.antipsychotic)
                metadata.antipsychotic(isinSet) = extend.antipsychotic(indexSetinData);
            else
                metadata.antipsychotic(isinSet) = cellstr(string(extend.antipsychotic(indexSetinData)));
            end
        end
        if ismember('moodstabiliser', extend.Properties.VariableNames)
            if iscell(extend.moodstabiliser)
                metadata.moodstabiliser(isinSet) = extend.moodstabiliser(indexSetinData);
            else
                metadata.moodstabiliser(isinSet) = cellstr(string(extend.moodstabiliser(indexSetinData)));
            end
        end
        if ismember('antidepression', extend.Properties.VariableNames)
            if iscell(extend.antidepression)
                metadata.antidepression(isinSet) = extend.antidepression(indexSetinData);
            else
                metadata.antidepression(isinSet) = cellstr(string(extend.antidepression(indexSetinData)));
            end
        end
        if ismember('antianxiety', extend.Properties.VariableNames)
            if iscell(extend.antianxiety)
                metadata.antianxiety(isinSet) = extend.antianxiety(indexSetinData);
            else
                metadata.antianxiety(isinSet) = cellstr(string(extend.antianxiety(indexSetinData)));
            end
        end
        if ismember('treatment', extend.Properties.VariableNames)
            if iscell(extend.treatment)
                metadata.treatment(isinSet) = extend.treatment(indexSetinData);
            else
                metadata.treatment(isinSet) = cellstr(string(extend.treatment(indexSetinData)));
            end
        end
        if ismember('ageOnset', extend.Properties.VariableNames)
            metadata.ageOnset(isinSet) = extend.ageOnset(indexSetinData);
        end
        if ismember('illnessDuration', extend.Properties.VariableNames)
            metadata.illnessDuration(isinSet) = extend.illnessDuration(indexSetinData);
        end
    end
end

% Clean up data
if ismember('ageOnset', metadata.Properties.VariableNames)
    metadata.ageOnset(metadata.ageOnset == 0 | metadata.ageOnset == 9999) = NaN;
end
if ismember('illnessDuration', metadata.Properties.VariableNames)
    metadata.illnessDuration(metadata.illnessDuration <= 0) = NaN;
end

% Write extended metadata
extended_output_file = fullfile(dataset_root, 'metadataVBM_extended.csv');
writetable(metadata, extended_output_file);
fprintf('  Extended metadata saved to: %s\n', extended_output_file);

fprintf('=== STEP4A COMPLETED ===\n');
fprintf('Total subjects processed: %d\n', height(metadata));
fprintf('AD group subjects: %d\n', height(metadata_AD));
fprintf('Psy group subjects: %d\n', height(metadata_psy));
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