function create_permuted_metadata(data_root, dataset, perm_id, harmonize, smooth_kernel)
% CREATE_PERMUTED_METADATA: Create permuted metadata for permutation testing
% This function creates a copy of the original metadata with randomly shuffled diagnosis labels
%
% Inputs:
%   data_root - Root directory containing datasets
%   dataset - Dataset name
%   perm_id - Permutation ID (for random seed)
%   harmonize - Harmonization flag (1 for COMBAT, 0 for no harmonization)
%   smooth_kernel - Smoothing kernel size
%
% Output:
%   permuted_metadata_file - Path to the created permuted metadata file

fprintf('=== CREATING PERMUTED METADATA ===\n');
fprintf('Dataset: %s\n', dataset);
fprintf('Permutation ID: %d\n', perm_id);
fprintf('Harmonization: %d\n', harmonize);
fprintf('Smoothing kernel: %d\n', smooth_kernel);

% Set random seed based on permutation ID for reproducibility
rng(perm_id);

% Define input and output directories
if harmonize == 1
    input_dir = fullfile(data_root, dataset);
    output_dir = fullfile(data_root, 'derivatives', ['s', num2str(smooth_kernel), 'COMBAT_perm', num2str(perm_id)]);
else
    input_dir = fullfile(data_root, dataset);
    output_dir = fullfile(data_root, 'derivatives', ['s', num2str(smooth_kernel), '_perm', num2str(perm_id)]);
end

% Create output directory if it doesn't exist
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
    fprintf('Created output directory: %s\n', output_dir);
end

% Path to original metadata file
original_metadata_file = fullfile(input_dir, [dataset, '_dems.csv']);

if ~exist(original_metadata_file, 'file')
    error('Original metadata file not found: %s', original_metadata_file);
end

fprintf('Reading original metadata from: %s\n', original_metadata_file);

% Read original metadata
original_metadata = readtable(original_metadata_file);

% Check if metadata has the required columns
if ~ismember('diagnosis', original_metadata.Properties.VariableNames)
    error('Metadata file must contain a ''diagnosis'' column');
end

fprintf('Original metadata contains %d subjects\n', height(original_metadata));

% Get unique diagnosis labels
unique_diagnoses = unique(original_metadata.diagnosis);
fprintf('Unique diagnoses: %s\n', strjoin(string(unique_diagnoses), ', '));

% Create permuted metadata by shuffling diagnosis labels
permuted_metadata = original_metadata;
permuted_metadata.diagnosis = original_metadata.diagnosis(randperm(height(original_metadata)));
diagString = {'HC', 'BD', 'SCA', 'SCZ', 'ASD', 'MDD', 'AD'};
permuted_metadata.diagnosis_string = arrayfun(@(x) diagString{x},permuted_metadata.diagnosis,'UniformOutput',false);
% Save permuted metadata
permuted_metadata_file = fullfile(output_dir, [dataset, '_dems_perm', num2str(perm_id), '.csv']);
writetable(permuted_metadata, permuted_metadata_file);

fprintf('Permuted metadata saved to: %s\n', permuted_metadata_file);


end

