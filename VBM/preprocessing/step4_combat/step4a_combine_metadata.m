function step4a_combine_metadata(config)
% Combine metadata from all enabled datasets and write group-specific files for COMBAT.

if nargin < 1 || isempty(config)
    error('No config passed');
end

if ischar(config) || isstring(config)
    this_dir = fileparts(mfilename('fullpath'));
    repo_root = fullfile(this_dir, '..', '..', '..');
    addpath(genpath(repo_root));
    config = pipeline_load_config(char(config));
end

fprintf('=== STEP4A: COMBINE METADATA ===\n');

dataset_root = config.data_directories.dataset_root;
smoothKernels = config.analysis_settings.vbm_smoothing_kernel;

enabled_datasets = pipeline_get_enabled_datasets(config);
if isempty(enabled_datasets)
    error('No enabled datasets found in config');
end

fprintf('Processing %d enabled datasets: %s\n', length(enabled_datasets), strjoin(enabled_datasets, ', '));

all_variable_names = {'subj_id', 'dataset', 'site', 'diagnosis', 'age', 'sex', ...
    'site_string', 'sex_string', 'ses', 'diagnosis_string'};

metadata_tables = {};
for i = 1:length(enabled_datasets)
    dataset_name = enabled_datasets{i};
    metadata_file = fullfile(dataset_root, dataset_name, [dataset_name, '_dems.csv']);

    if ~isfile(metadata_file)
        warning('Metadata file not found: %s. Skipping...', metadata_file);
        continue;
    end

    fprintf('  Reading metadata from: %s\n', metadata_file);
    try
        t = readtable(metadata_file);
    catch ME
        warning('Failed to read: %s. Error: %s. Skipping...', metadata_file, ME.message);
        continue;
    end

    if ~ismember('ses', t.Properties.VariableNames)
        t.ses = repmat({''}, height(t), 1);
    end
    metadata_tables{end+1} = t(:, all_variable_names);
end

if isempty(metadata_tables)
    error('No valid metadata files found');
end

fprintf('  Combining metadata from %d datasets...\n', length(metadata_tables));
metadata = vertcat(metadata_tables{:});

writetable(metadata, fullfile(dataset_root, 'metadataVBM.csv'));
fprintf('  Combined metadata saved to: %s (%d subjects)\n', ...
    fullfile(dataset_root, 'metadataVBM.csv'), height(metadata));

% Split by combat group from config and write group files
group_datasets = get_group_datasets(config);
group_names = fieldnames(group_datasets);
for g = 1:length(group_names)
    gname = group_names{g};
    gdata = metadata(ismember(metadata.dataset, group_datasets.(gname)), :);
    gfile = fullfile(dataset_root, ['metadataVBM_', gname, '.csv']);
    writetable(gdata, gfile);
    fprintf('  %s group: %s (%d subjects)\n', gname, gfile, height(gdata));
end

% Copy group files to derivatives directories
for smoothKernel = smoothKernels
    deriv_dir = fullfile(dataset_root, 'derivatives', ['s', num2str(smoothKernel)]);
    combat_dir = fullfile(dataset_root, 'derivatives', ['s', num2str(smoothKernel), 'COMBAT']);
    if ~exist(deriv_dir, 'dir'); mkdir(deriv_dir); end
    if ~exist(combat_dir, 'dir'); mkdir(combat_dir); end
    for g = 1:length(group_names)
        src = fullfile(dataset_root, ['metadataVBM_', group_names{g}, '.csv']);
        copyfile(src, fullfile(deriv_dir, ['metadataVBM_', group_names{g}, '.csv']));
        copyfile(src, fullfile(combat_dir, ['metadataVBM_', group_names{g}, '.csv']));
    end
end

% Process extended metadata
fprintf('  Processing extended metadata...\n');
datasetList = unique(metadata.dataset);
metadata.CAT             = cell(height(metadata), 1);
metadata.antipsychotic   = cell(height(metadata), 1);
metadata.moodstabiliser  = cell(height(metadata), 1);
metadata.antidepression  = cell(height(metadata), 1);
metadata.antianxiety     = cell(height(metadata), 1);
metadata.treatment       = cell(height(metadata), 1);
metadata.ageOnset        = NaN(height(metadata), 1);
metadata.illnessDuration = NaN(height(metadata), 1);

cell_fields = {'CAT', 'antipsychotic', 'moodstabiliser', 'antidepression', 'antianxiety', 'treatment'};

for iSet = 1:length(datasetList)
    dataset_name = char(datasetList(iSet));
    extendFile = fullfile(dataset_root, dataset_name, [dataset_name, '_dems_extended.csv']);

    if ~exist(extendFile, 'file')
        continue;
    end

    fprintf('    Processing extended metadata for: %s\n', dataset_name);
    extend = readtable(extendFile, 'Delimiter', ',');
    isinSet = ismember(metadata.dataset, dataset_name);
    [~, indexSetinData] = ismember(metadata.subj_id(isinSet), extend.subj_id);

    for c = 1:length(cell_fields)
        col = cell_fields{c};
        if ismember(col, extend.Properties.VariableNames)
            if iscell(extend.(col))
                metadata.(col)(isinSet) = extend.(col)(indexSetinData);
            else
                metadata.(col)(isinSet) = cellstr(string(extend.(col)(indexSetinData)));
            end
        end
    end

    if ismember('ageOnset', extend.Properties.VariableNames)
        metadata.ageOnset(isinSet) = extend.ageOnset(indexSetinData);
    end
    if ismember('illnessDuration', extend.Properties.VariableNames)
        metadata.illnessDuration(isinSet) = extend.illnessDuration(indexSetinData);
    end
end

if ismember('ageOnset', metadata.Properties.VariableNames)
    metadata.ageOnset(metadata.ageOnset == 0 | metadata.ageOnset == 9999) = NaN;
end
if ismember('illnessDuration', metadata.Properties.VariableNames)
    metadata.illnessDuration(metadata.illnessDuration <= 0) = NaN;
end

writetable(metadata, fullfile(dataset_root, 'metadataVBM_extended.csv'));
fprintf('  Extended metadata saved to: %s\n', fullfile(dataset_root, 'metadataVBM_extended.csv'));

fprintf('=== STEP4A COMPLETED ===\n');
fprintf('Total subjects: %d\n', height(metadata));
end


function group_datasets = get_group_datasets(config)
% Return struct mapping combat_group name -> cell array of dataset names
group_datasets = struct();
if ~isfield(config, 'datasets'); return; end
ds_names = fieldnames(config.datasets);
for k = 1:numel(ds_names)
    ds = config.datasets.(ds_names{k});
    if isfield(ds, 'enabled') && logical(ds.enabled) && isfield(ds, 'combat_group')
        g = ds.combat_group;
        if ~isfield(group_datasets, g)
            group_datasets.(g) = {};
        end
        group_datasets.(g){end+1} = ds_names{k};
    end
end
end
