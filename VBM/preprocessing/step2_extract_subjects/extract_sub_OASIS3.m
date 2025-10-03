function extract_sub_OASIS3(config)
%% Extract subjects from CAT12 QC reports and create metadata for OASIS3
% This function processes CAT12 QC reports and creates metadata files
% for subjects that meet quality criteria in OASIS3 dataset
%
% Input: config - Configuration structure containing paths and settings
%
% Trang Cao, Neural Systems and Behaviour Lab, Monash University, 2024.

study = 'OASIS3';

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
NSUB = config.analysis_settings.minimum_subjects_per_site; % minimum subjects per site per phenotype

fprintf('=== EXTRACTING SUBJECTS FOR %s ===\n', study);
fprintf('Longitudinal study: %s\n', string(is_longitudinal));
fprintf('Using CAT12 quality threshold: %.1f\n', IQRthres);
fprintf('Minimum subjects per site/phenotype: %d\n', NSUB);


% Check if CAT12 passed subjects list exists (created by step1b)
cat12_passed_file = fullfile(study_path, 'subjects_cat12_passed.txt');
if ~exist(cat12_passed_file, 'file')
    error('subjects_cat12_passed.txt not found at %s. Please run step1b first to generate CAT12 QC results.', cat12_passed_file);
end

% Read the CAT12 passed subjects list
cat12_passed_subjects = readlines(cat12_passed_file);
% Remove empty lines that may be created by bash
cat12_passed_subjects = cat12_passed_subjects(~strcmp(cat12_passed_subjects, ''));
fprintf('Found %d subjects that passed CAT12 QC\n', length(cat12_passed_subjects));

% Check if visual inspection exclusion list exists
visual_exclusion_file = fullfile(study_path, 'derivatives','volume_visualisation','subject_list_excluded_after_visualisation.txt');
if exist(visual_exclusion_file, 'file')
    visual_excluded_subjects = readlines(visual_exclusion_file);
     % Remove empty lines that may be created by bash
    visual_excluded_subjects = visual_excluded_subjects(~strcmp(visual_excluded_subjects, ''));
   fprintf('Found %d subjects excluded after visual inspection\n', length(visual_excluded_subjects));
    
    % Remove visually excluded subjects from CAT12 passed list
    useFolder = setdiff(cat12_passed_subjects, visual_excluded_subjects);
    fprintf('After visual inspection exclusion: %d subjects remaining\n', length(useFolder));
else
    fprintf('No visual inspection exclusion list found. Using all CAT12 passed subjects.\n');
    useFolder = cat12_passed_subjects;
end

% Read demographic files
subject = readtable(fullfile(source_path, 'OASIS3_demographics.csv'),'Delimiter',',','VariableNamingRule','preserve');
image = readtable(fullfile(source_path, 'OASIS3_MR_json.csv'),'Delimiter',',','VariableNamingRule','preserve');
dayses = readtable(fullfile(source_path, 'day_ses.txt'),'Delimiter',' ','VariableNamingRule','preserve');
diagfile = readtable(fullfile(source_path, 'OASIS3_UDSd1_diagnoses.csv'),'Delimiter',',','VariableNamingRule','preserve');



subsplit = cellfun(@(x) strsplit(x,'_'),image.label, UniformOutput=false);
image.daytemp = cellfun(@(x) x(3), subsplit,UniformOutput=false);
image.day = cellfun(@(x) str2num(x{:}(2:end)), image.daytemp);
[lia loSub] = ismember(image.subject_id, subject.OASISID);
image.age = image.day./365 + subject.AgeatEntry(loSub);
image.sex = subject.GENDER_1_M_2_F(loSub);

[lia loSub] = ismember(image.subject_id, diagfile.OASISID);
% Initialize diagnosis vector with NaN for subjects not in diagnostic file
image.diag = NaN(size(image.subject_id));

% Only assign diagnosis for subjects found in diagnostic file
valid_subjects = lia & loSub > 0;
image.diag(valid_subjects) = (diagfile.NORMCOG(loSub(valid_subjects))==1)*1 + (diagfile.alzdis(loSub(valid_subjects))==1)*7;

daysplit = cellfun(@(x) strsplit(x,'/'),dayses.folder, UniformOutput=false);
dayses.file = cellfun(@(x) x(6), daysplit);
[lia lofile] = ismember(image.label, dayses.file);
image.ses = "ses-" + dayses.ses(lofile);

% writetable(removevars(subject,{'MRID','Date','Subject','Scanner','Scans'}),'/projects/kg98/trangc/VBM/data/miriad/temp.txt');
% subject = unique(readtable('/projects/kg98/trangc/VBM/data/miriad/temp.txt'),'rows');
image.subses="sub-"+image.subject_id+image.ses;

% useFolder = "sub-" + unique(subject.id);

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


% Create metadata structure for quality subjects
metadata.subj_id = cellstr(quality_subjects);
metadata.dataset = cellstr(repmat(study, size(quality_subjects)));

% Extract demographic information and IQR values for quality subjects
metadata.age = zeros(size(quality_subjects));
metadata.sex = cell(size(quality_subjects));
metadata.sex_string = cell(size(quality_subjects));
metadata.diag = cell(size(quality_subjects));
metadata.site = cell(size(quality_subjects));
metadata.site_string = cell(size(quality_subjects));
metadata.ses = cell(size(quality_subjects));
metadata.iqr = zeros(size(quality_subjects));

for i = 1:length(quality_subjects)
    % Extract subject ID without 'sub-' prefix for matching
    sub_id = strrep(quality_subjects{i}, 'sub-', '');
    
    % Find subject in image data
    sub_idx = find(strcmp(image.subject_id, sub_id));
    if ~isempty(sub_idx)
        % Use first occurrence if multiple sessions
        sub_idx = sub_idx(1);
        metadata.age(i,1) = image.age(sub_idx);
        metadata.sex{i,1} = num2str(image.sex(sub_idx));
        metadata.site{i,1} = num2str(image.DeviceSerialNumber(sub_idx));
        
        % Convert sex to string
        if image.sex(sub_idx) == 1
            metadata.sex_string{i,1} = 'M';
        else
            metadata.sex_string{i,1} = 'F';
        end
        
        % Handle diagnosis
        if isnan(image.diag(sub_idx))
            metadata.diag{i,1} = 'No diagnosis';
        else
            metadata.diag{i,1} = num2str(image.diag(sub_idx));
        end
        
        % Session information
        metadata.ses{i,1} = char(image.ses(sub_idx));
    else
        warning('Subject %s not found in image data', quality_subjects{i});
        metadata.age(i,1) = NaN;
        metadata.sex{i,1} = 'Unknown';
        metadata.sex_string{i,1} = 'Unknown';
        metadata.diag{i,1} = 'Unknown';
        metadata.site{i,1} = 'Unknown';
        metadata.ses{i,1} = 'Unknown';
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

% Create site strings
for i = 1:length(metadata.site)
    if ~strcmp(metadata.site{i}, 'Unknown')
        metadata.site_string{i,1} = sprintf('OASIS3-%s', metadata.site{i});
    else
        metadata.site_string{i,1} = 'Unknown';
    end
end

% Initialize diagnosis arrays
metadata.diagnosis = zeros(size(metadata.diag));
metadata.diagnosis_string = cell(size(metadata.diag));

% find diagnosis for used subjects
% Handle 'No diagnosis' case first
no_diag_idx = strcmp(metadata.diag, 'No diagnosis');
metadata.diagnosis(no_diag_idx) = NaN;
metadata.diagnosis_string(no_diag_idx) = cellstr('No diagnosis');

% Handle cognitively normal subjects
[La Lb] = ismember(metadata.diag, {'Cognitively normal' ,'No dementia'});
metadata.diagnosis(La==1,1) = 1;
metadata.diagnosis_string(La==1,1) = cellstr('HC');

% Handle AD subjects
[La Lb] = ismember(metadata.diag, {'AD Dementia','AD dem Language dysf after',...
'AD dem Language dysf with','AD dem distrubed social- after',...
'AD dem distrubed social- prior','AD dem distrubed social- with',...
'AD dem w/CVD contribut','AD dem w/CVD not contrib','AD dem w/depresss- contribut',...
'AD dem w/depresss- not contribut','AD dem w/oth (list B) contribut','AD dem w/oth (list B) not contrib','DAT'});
metadata.diagnosis(La==1,1) = 7;
metadata.diagnosis_string(La==1,1) = cellstr('AD');

%% check number of subjects
siteCat = unique(metadata.site);
diagCat = [1,7];

for iSite = 1: length(siteCat)
    for iDiag = 1: length(diagCat) % control and proband in the diag list

        % number of adult subjects in each phenotype in each site
        % Only count subjects with valid diagnosis (not NaN)
        valid_diag_idx = ~isnan(metadata.diagnosis);
        nSiteDiag(iSite, iDiag) = sum(strcmp(metadata.site, siteCat(iSite)) & metadata.diagnosis==diagCat(iDiag) & valid_diag_idx);

    end
end

% the site and phenotype has >= NSUB HC subjects
nSiteDiagCondition = nSiteDiag >= NSUB;
nSiteCondition = nSiteDiagCondition(:,1) & any(nSiteDiagCondition(:,2:end),2);
siteCon = siteCat(nSiteCondition);

%%
metadata.con = zeros(size(metadata.subj_id));
for iSite = 1:length(siteCon)
    
        condition = ismember(metadata.site,siteCon(iSite)) & ...
            ismember(metadata.diagnosis ,diagCat) & ...
            ~isnan(metadata.diagnosis);  % Only include subjects with valid diagnosis

        metadata.con(condition) = 1;
end

metadata.con = logical(metadata.con);

[La Lb] = ismember(metadata.subj_id(metadata.con), catFile.Var1);
metadata.CAT = cellstr(num2str(catFile.Var2(Lb)));


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

