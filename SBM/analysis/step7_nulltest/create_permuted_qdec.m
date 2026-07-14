function create_permuted_qdec(originalSiteFile, permutedSiteFile, ranseed)
% CREATE_PERMUTED_QDEC: Create permuted qdec file for SBM permutation testing
% This function creates a copy of the original qdec file with randomly shuffled diagnosis labels
%
% Inputs:
%   originalSiteFile - Path to the original qdec site file
%   permutedSiteFile - Path to save the permuted qdec file
%   ranseed - Random seed for reproducibility
%
% Trang Cao, Neural Systems and Behaviour Lab, Monash University, 2024.

fprintf('=== CREATING PERMUTED QDEC FILE ===\n');
fprintf('Original file: %s\n', originalSiteFile);
fprintf('Permuted file: %s\n', permutedSiteFile);
fprintf('Random seed: %d\n', ranseed);

% Set random seed for reproducibility
rng(ranseed);

% Check if original file exists
if ~exist(originalSiteFile, 'file')
    error('Original site file not found: %s', originalSiteFile);
end

% Read original file
fprintf('Reading original qdec file...\n');
fid = fopen(originalSiteFile, 'r');
if fid == -1
    error('Cannot open original file: %s', originalSiteFile);
end

% Read header line
header = fgetl(fid);

% Read all data lines
data_lines = {};
line_count = 0;
while ~feof(fid)
    line = fgetl(fid);
    if ischar(line) && ~isempty(strtrim(line))
        line_count = line_count + 1;
        data_lines{line_count} = line;
    end
end
fclose(fid);

fprintf('Read %d data lines from original file\n', line_count);

% Parse data lines
subjects = cell(line_count, 1);
diagnoses = cell(line_count, 1);
covariates = cell(line_count, 1);

for i = 1:line_count
    % Split line by tabs
    parts = split(data_lines{i}, '\t');
    
    if length(parts) >= 4
        subjects{i} = parts{1};
        diagnoses{i} = parts{2};
        % Store remaining parts as covariates
        if length(parts) > 4
            covariates{i} = parts(3:end);
        else
            covariates{i} = parts(3:4);
        end
    else
        warning('Line %d has insufficient columns: %s', i, data_lines{i});
        continue;
    end
end

% Shuffle diagnosis labels while keeping subjects and covariates the same
fprintf('Shuffling diagnosis labels...\n');
shuffled_diagnoses = diagnoses(randperm(length(diagnoses)));

% Write permuted file
fprintf('Writing permuted qdec file...\n');
fid = fopen(permutedSiteFile, 'w');
if fid == -1
    error('Cannot create permuted file: %s', permutedSiteFile);
end

% Write header
fprintf(fid, '%s\n', header);

% Write data lines
for i = 1:line_count
    if length(covariates{i}) > 1
        fprintf(fid, '%s\t%s\t%s\t%s\n', subjects{i}, shuffled_diagnoses{i}, covariates{i}{1}, covariates{i}{2});
    else
        fprintf(fid, '%s\t%s\t%s\n', subjects{i}, shuffled_diagnoses{i}, covariates{i}{1});
    end
end
fclose(fid);

fprintf('Permuted qdec file created successfully: %s\n', permutedSiteFile);

% Verify the file was created correctly
if exist(permutedSiteFile, 'file')
    fprintf('Verification: Permuted file exists and is accessible\n');
else
    error('Failed to create permuted file: %s', permutedSiteFile);
end

end
