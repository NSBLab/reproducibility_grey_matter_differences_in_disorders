function permuted_metadata_file = create_permuted_metadata(data_root, dataset, perm_id, harmonize, smooth_kernel)
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
    input_dir = fullfile(data_root, 'derivatives', ['s', num2str(smooth_kernel), 'COMBAT']);
    output_dir = fullfile(data_root, 'derivatives', ['s', num2str(smooth_kernel), 'COMBAT_perm', num2str(perm_id)]);
else
    input_dir = fullfile(data_root, 'derivatives', ['s', num2str(smooth_kernel)]);
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

% Verify permutation worked
fprintf('Permuted metadata - Diagnosis distribution:\n');
for i = 1:length(unique_diagnoses)
    orig_count = sum(strcmp(original_metadata.diagnosis, unique_diagnoses{i}));
    perm_count = sum(strcmp(permuted_metadata.diagnosis, unique_diagnoses{i}));
    fprintf('  %s: %d -> %d\n', unique_diagnoses{i}, orig_count, perm_count);
end

% Save permuted metadata
permuted_metadata_file = fullfile(output_dir, [dataset, '_dems_perm', num2str(perm_id), '.csv']);
writetable(permuted_metadata, permuted_metadata_file);

fprintf('Permuted metadata saved to: %s\n', permuted_metadata_file);

% Also copy other necessary files from original directory
copy_permutation_files(input_dir, output_dir, dataset, smooth_kernel, harmonize);

end

function copy_permutation_files(input_dir, output_dir, dataset, smooth_kernel, harmonize)
% Copy necessary files for permutation analysis

fprintf('Copying necessary files for permutation analysis...\n');

% Files to copy (these don't need permutation)
files_to_copy = {
    'metadataVBM_psy.csv',
    'metadataVBM_AD.csv',
    [dataset, '_TIV.txt']
};

for i = 1:length(files_to_copy)
    source_file = fullfile(input_dir, files_to_copy{i});
    if exist(source_file, 'file')
        dest_file = fullfile(output_dir, files_to_copy{i});
        copyfile(source_file, dest_file);
        fprintf('  Copied: %s\n', files_to_copy{i});
    else
        fprintf('  Warning: File not found: %s\n', files_to_copy{i});
    end
end

% Copy the processed image files (these also don't need permutation)
if harmonize == 1
    source_img_dir = fullfile(input_dir, dataset);
    dest_img_dir = fullfile(output_dir, dataset);
    
    if exist(source_img_dir, 'dir')
        if ~exist(dest_img_dir, 'dir')
            mkdir(dest_img_dir);
        end
        
        % Copy all subdirectories and files
        copyfile(source_img_dir, dest_img_dir);
        fprintf('  Copied image directory: %s\n', dataset);
    else
        fprintf('  Warning: Image directory not found: %s\n', source_img_dir);
    end
end

end
