function extract_sub_Myelin(config)
%% Extract subjects from CAT12 QC reports and create metadata for longitudinal study
% This function processes CAT12 QC reports and creates metadata files
% for subjects that meet quality criteria in a longitudinal study
%
% Input: config - Configuration structure containing paths and settings
%
% Trang Cao, Neural Systems and Behaviour Lab, Monash University, 2024.

study = 'Myelin';

% Use config passed as parameter, or load from file if not provided
if nargin < 1 || isempty(config)
    error('No config passed');
end

% Get destination paths from config
dataset_root = config.data_directories.dataset_root;
study_path = fullfile(dataset_root, study);

% Get source path from config
if ~isfield(config.datasets, study) || ~isfield(config.datasets.(study), 'path')
    error('source_path not found in config for dataset %s. Please add source_path to config.datasets.%s', study, study);
end
source_path = config.datasets.(study).path;

% Check if this is a longitudinal study
is_longitudinal = false;
if isfield(config.datasets.(study), 'longitudinal')
    is_longitudinal = config.datasets.(study).longitudinal;
end

% Get quality threshold from config
IQRthres = config.analysis_settings.cat12_quality_threshold; % threshold to determine good quality images

fprintf('=== EXTRACTING SUBJECTS FOR %s ===\n', study);
fprintf('Longitudinal study: %s\n', string(is_longitudinal));
fprintf('Using CAT12 quality threshold: %.1f\n', IQRthres);

fn = fullfile(study_path, 'subjects_pass_visualisation.txt');
if ~exist(fn, 'file')
    error('Missing %s (copy from subjects_cat12_passed.txt after step1c and edit)', fn);
end
useFolder = readlines(fn);
useFolder = useFolder(useFolder ~= "");
fprintf('Subject list: %d subjects\n', numel(useFolder));

% For longitudinal studies, also check for ses_subject_use.txt
ses_subject_list_file = fullfile(study_path, 'ses_subject_use.txt');
if is_longitudinal && ~exist(ses_subject_list_file, 'file')
    error('ses_subject_use.txt not found at %s. Please run BIDS_Myelin.m first to create the session-subject list.', ses_subject_list_file);
end

% Read session-subject list for longitudinal studies
if is_longitudinal
    ses_subject_list = readlines(ses_subject_list_file);
    fprintf('Found %d session-subjects in ses_subject_use.txt\n', length(ses_subject_list));
end

% Check if CAT12 QC report exists (for metadata extraction)
cat_report_file = fullfile(study_path, sprintf('cat12_qcReport_%s.txt', study));
if ~exist(cat_report_file, 'file')
    error('CAT12 QC report not found at %s. Please run CAT12 preprocessing first.', cat_report_file);
end

% Read CAT12 QC report
fprintf('Reading CAT12 QC report: %s\n', cat_report_file);
catFile = readtable(cat_report_file, "FileType","text",'Delimiter', '\t');

% Since we're already using CAT12 passed subjects, we just need to verify they exist in the QC report
% and extract their IQR values for metadata
quality_subjects = useFolder; % All subjects in useFolder have already passed CAT12 QC
fprintf('Using %d subjects that passed CAT12 QC and visual inspection\n', length(quality_subjects));

% Read demographic data for metadata creation
demographic_file = fullfile(source_path, 'participants.tsv');
if ~exist(demographic_file, 'file')
    error('Demographic file not found at %s', demographic_file);
end

imageFile = readtable(demographic_file, "FileType","text",'Delimiter', '\t');

% Create metadata structure
metadata.subj_id = cellstr(quality_subjects);
metadata.dataset = cellstr(repmat(study, size(quality_subjects)));
metadata.site_string = metadata.dataset;
metadata.site = cellstr(repmat('41', size(quality_subjects))); % Myelin uses site 41


% Extract demographic information and IQR values for quality subjects
metadata.iqr = zeros(size(quality_subjects));
for i = 1:length(quality_subjects)
    % Extract demographic info
    sub_idx = find(strcmp(imageFile.participant_id, quality_subjects{i}));
    if ~isempty(sub_idx)
        metadata.age(i,1) = imageFile.age(sub_idx);
        metadata.sex_string{i,1} = imageFile.sex{sub_idx}; % Myelin uses 'sex' column
        metadata.diagnosis_string{i,1} = imageFile.group{sub_idx};
    else
        warning('Subject %s not found in demographic file', quality_subjects{i});
        metadata.age(i,1) = NaN;
        metadata.sex_string{i,1} = 'Unknown';
        metadata.diagnosis_string{i,1} = 'Unknown';
    end
    
    % Extract IQR from CAT12 report
    cat_idx = find(strcmp(catFile.Var1, quality_subjects{i}));
    if ~isempty(cat_idx)
        metadata.iqr(i,1) = catFile.Var2(cat_idx);
    else
        warning('Subject %s not found in CAT12 QC report', quality_subjects{i});
        metadata.iqr(i,1) = NaN;
    end
end

% Convert sex to numeric (1=M, 0=F) - Myelin uses 'M'/'F' format
metadata.sex = arrayfun(@(x) num2str(strcmp(x, 'M')), metadata.sex_string, 'UniformOutput', false);

% Convert diagnosis to numeric codes - Myelin uses diagList [1,3]
[diag, ~, ~] = unique(imageFile.group);
control_idx = find(strcmp(diag, 'HC')); % Myelin uses 'HC' instead of 'control'
metadata.diagnosis = zeros(size(metadata.diagnosis_string));
for i = 1:length(metadata.diagnosis_string)
    diag_idx = find(strcmp(diag, metadata.diagnosis_string{i}));
    if ~isempty(diag_idx)
        if diag_idx == control_idx
            metadata.diagnosis(i) = 1; % Control
        elseif diag_idx == 3
            metadata.diagnosis(i) = 6; % Other diagnosis (diagList [1,3])
        else
            metadata.diagnosis(i) = 8; % Default to other
        end
    end
end

% Convert diagnosis to string codes
diagString = {'HC', 'BD', 'SCA', 'SCZ', 'ASD', 'MDD'};
for i = 1:length(metadata.diagnosis)
    if metadata.diagnosis(i) <= length(diagString)
        metadata.diagnosis_string{i,1} = diagString{metadata.diagnosis(i)};
    else
        metadata.diagnosis_string{i,1} = 'Unknown';
    end
end
metadata.diagnosis = arrayfun(@(x) num2str(x), metadata.diagnosis, 'UniformOutput', false);

% Handle session information for longitudinal studies
if is_longitudinal
    % Extract session information from CAT12 report
    metadata.ses = cell(size(metadata.subj_id));
    metadata.ses = catFile.Var3(catFile.Var2 <= IQRthres & ismember(catFile.Var1, useFolder));
    fprintf('Extracted session information for longitudinal study\n');
else
    % For non-longitudinal studies, create empty session field
    metadata.ses = cell(size(metadata.subj_id));
    metadata.ses(:) = {''};
end

% Check number of subjects per diagnosis
diagCat = unique(metadata.diagnosis);
diagCat = diagCat(ismember(diagCat,{'1','2','3','4','5','6','7'}));
fprintf('\nSubject counts by diagnosis:\n');
for iDiag = 1:length(diagCat)
    nSiteDiag(iDiag) = sum(strcmp(metadata.diagnosis, diagCat(iDiag)));
    fprintf('  %s: %d subjects\n', diagCat{iDiag}, nSiteDiag(iDiag));
end

% Apply minimum subject criteria
NSUB = config.analysis_settings.minimum_subjects_per_site;
nSiteDiagCondition = nSiteDiag >= NSUB;
fprintf('Minimum subjects per diagnosis: %d\n', NSUB);

% Create inclusion mask
metadata.con = false(size(metadata.subj_id));
for i = 1:length(metadata.diagnosis)
    diag_idx = find(strcmp(diagCat, metadata.diagnosis{i}));
    if ~isempty(diag_idx) && nSiteDiagCondition(diag_idx)
        metadata.con(i) = true;
    end
end

fprintf('Final inclusion: %d subjects meet all criteria\n', sum(metadata.con));

% Add CAT12 quality scores for included subjects
metadata.CAT = cell(size(metadata.subj_id));
[La, Lb] = ismember(metadata.subj_id(metadata.con), catFile.Var1);
metadata.CAT(metadata.con) = cellstr(num2str(catFile.Var2(Lb)));

% Create metadata tables
fprintf('\nCreating metadata files...\n');

% Basic metadata table (includes session for longitudinal studies)
if is_longitudinal
    metaTable = cell2table([metadata.subj_id(metadata.con), metadata.dataset(metadata.con), ...
        metadata.site(metadata.con), metadata.diagnosis(metadata.con), cellstr(num2str(metadata.age(metadata.con))),...
        metadata.sex(metadata.con), metadata.site_string(metadata.con), metadata.sex_string(metadata.con),...
        metadata.ses(metadata.con), metadata.diagnosis_string(metadata.con)], "VariableNames",["subj_id", "dataset", "site", "diagnosis",...
        "age", "sex", "site_string", "sex_string", "ses", "diagnosis_string"]);
else
    metaTable = cell2table([metadata.subj_id(metadata.con), metadata.dataset(metadata.con), ...
        metadata.site(metadata.con), metadata.diagnosis(metadata.con), cellstr(num2str(metadata.age(metadata.con))),...
        metadata.sex(metadata.con), metadata.site_string(metadata.con), metadata.sex_string(metadata.con),...
        metadata.diagnosis_string(metadata.con)], "VariableNames",["subj_id", "dataset", "site", "diagnosis",...
        "age", "sex", "site_string", "sex_string", "diagnosis_string"]);
end

% Save basic metadata
basic_meta_file = fullfile(study_path, sprintf('%s_dems.csv', study));
writetable(metaTable, basic_meta_file);
fprintf('Basic metadata saved to: %s\n', basic_meta_file);

% Extended metadata table (includes CAT12 quality scores)
if is_longitudinal
    metaTable_extended = cell2table([metadata.subj_id(metadata.con), metadata.dataset(metadata.con), ...
        metadata.site(metadata.con), metadata.diagnosis(metadata.con), cellstr(num2str(metadata.age(metadata.con))),...
        metadata.sex(metadata.con), metadata.site_string(metadata.con), metadata.sex_string(metadata.con),...
        metadata.ses(metadata.con), metadata.diagnosis_string(metadata.con), metadata.CAT(metadata.con)], "VariableNames",["subj_id", "dataset", "site", "diagnosis",...
        "age", "sex", "site_string", "sex_string", "ses", "diagnosis_string", "CAT"]);
else
    metaTable_extended = cell2table([metadata.subj_id(metadata.con), metadata.dataset(metadata.con), ...
        metadata.site(metadata.con), metadata.diagnosis(metadata.con), cellstr(num2str(metadata.age(metadata.con))),...
        metadata.sex(metadata.con), metadata.site_string(metadata.con), metadata.sex_string(metadata.con),...
        metadata.diagnosis_string(metadata.con), metadata.CAT(metadata.con)], "VariableNames",["subj_id", "dataset", "site", "diagnosis",...
        "age", "sex", "site_string", "sex_string", "diagnosis_string", "CAT"]);
end

% Save extended metadata
extended_meta_file = fullfile(study_path, sprintf('%s_dems_extended.csv', study));
writetable(metaTable_extended, extended_meta_file);
fprintf('Extended metadata saved to: %s\n', extended_meta_file);

fprintf('\n=== EXTRACTION COMPLETED FOR %s ===\n', study);
fprintf('Total subjects processed: %d\n', length(quality_subjects));
fprintf('Subjects meeting all criteria: %d\n', sum(metadata.con));
if is_longitudinal
    fprintf('Longitudinal study with session information included\n');
end
end