function BIDS_OASIS3(config)
%% BIDS conversion for OASIS3 dataset
% This function converts OASIS3 dataset to BIDS format and filters subjects
% based on age criteria and site requirements
%
% Input: config - Configuration structure containing paths and settings
%
% Trang Cao, Neural Systems and Behaviour Lab, Monash University, 2024.

study = 'OASIS3';

% Use config passed as parameter, or load from file if not provided
if nargin < 1 || isempty(config)
    error('config is not available');
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

% Get age range from config
LOWAGE = config.analysis_settings.age_range.min; % lower bound of age
UPAGE = config.analysis_settings.age_range.max; % upper bound of age
NSUB = config.analysis_settings.minimum_subjects_per_site; % lowest number of subject per site per phenotype

fprintf('=== BIDS CONVERSION FOR %s ===\n', study);
fprintf('Longitudinal study: %s\n', string(is_longitudinal));
fprintf('Age range: %d-%d years\n', LOWAGE, UPAGE);
fprintf('Minimum subjects per site/phenotype: %d\n', NSUB);

%% Read demographic information and extract subjects that satisfy criteria

% Read demographic files
subject = readtable(fullfile(source_path, 'OASIS3_demographics.csv'),'Delimiter',',','VariableNamingRule','preserve');
image = readtable(fullfile(source_path, 'OASIS3_MR_json.csv'),'Delimiter',',','VariableNamingRule','preserve');
dayses = readtable(fullfile(source_path, 'day_ses.txt'),'Delimiter',' ','VariableNamingRule','preserve');
diagfile = readtable(fullfile(source_path, 'OASIS3_UDSd1_diagnoses.csv'),'Delimiter',',','VariableNamingRule','preserve');

% Process image data
subsplit = cellfun(@(x) strsplit(x,'_'),image.label, UniformOutput=false);
image.daytemp = cellfun(@(x) x(3), subsplit,UniformOutput=false);
image.day = cellfun(@(x) str2num(x{:}(2:end)), image.daytemp);
[lia loSub] = ismember(image.subject_id, subject.OASISID);
image.age = image.day./365 + subject.AgeatEntry(loSub);
image.sex = subject.GENDER_1_M_2_F(loSub);

% Process diagnosis data safely
[lia loSub] = ismember(image.subject_id, diagfile.OASISID);
% Initialize diagnosis vector with NaN for subjects not in diagnostic file
image.diag = NaN(size(image.subject_id));

% Only assign diagnosis for subjects found in diagnostic file
valid_subjects = lia & loSub > 0;
image.diag(valid_subjects) = (diagfile.NORMCOG(loSub(valid_subjects))==1)*1 + (diagfile.alzdis(loSub(valid_subjects))==1)*7;

% Process session information
daysplit = cellfun(@(x) strsplit(x,'/'),dayses.folder, UniformOutput=false);
dayses.file = cellfun(@(x) x(6), daysplit);
[lia lofile] = ismember(image.label, dayses.file);
image.ses = "ses-" + dayses.ses(lofile);

% Create subject-session identifiers
image.subses="sub-"+image.subject_id+image.ses;

% Filter subjects by age criteria
adult_idx = image.age >= LOWAGE & image.age <= UPAGE;
adult_subjects = image.subject_id(adult_idx);

fprintf('Found %d subjects in age range %d-%d\n', length(adult_subjects), LOWAGE, UPAGE);

% Get unique subjects (for site/diagnosis counting)
[unique_subjects, ~, unique_idx] = unique(adult_subjects);

% Count subjects by site and diagnosis
site_device = image.DeviceSerialNumber(adult_idx);
unique_sites = unique(site_device);
diagCat = [1,7]; % Control (1) and AD (7)

% Initialize counting arrays
nSiteDiag = zeros(length(unique_sites), length(diagCat));
site_conditions = false(length(unique_sites), 1);

fprintf('Analyzing %d unique sites...\n', length(unique_sites));

for iSite = 1:length(unique_sites)
    site_subjects = adult_subjects(site_device == unique_sites(iSite));
    
    for iDiag = 1:length(diagCat)
        % Count subjects with this diagnosis at this site
        site_sub_diag = [];
        for j = 1:length(site_subjects)
            sub_diag = image.diag(strcmp(image.subject_id, site_subjects{j}));
            if ~isnan(sub_diag) && sub_diag == diagCat(iDiag)
                site_sub_diag(end+1) = j;
            end
        end
        nSiteDiag(iSite, iDiag) = length(site_sub_diag);
    end
    
    % Check if site meets minimum subject criteria
    site_conditions(iSite) = nSiteDiag(iSite,1) >= NSUB && any(nSiteDiag(iSite,2:end) >= NSUB);
end

% Get sites that meet criteria
valid_sites = unique_sites(site_conditions);
fprintf('Found %d sites meeting minimum subject criteria\n', length(valid_sites));

% Get subjects from valid sites
valid_subjects = [];
for i = 1:length(valid_sites)
    site_subjects = adult_subjects(site_device == valid_sites(i));
    valid_subjects = [valid_subjects; site_subjects];
end

% Remove duplicates
valid_subjects = unique(valid_subjects);

fprintf('Selected %d subjects from valid sites\n', length(valid_subjects));

% Save the filtered subject list
subject_list_file = fullfile(study_path, 'subject_use.txt');
writelines(valid_subjects, subject_list_file);
fprintf('Subject list saved to: %s\n', subject_list_file);

%% Handle longitudinal study structure
if is_longitudinal
    fprintf('Processing as longitudinal study...\n');
    
    % Extract session information for longitudinal study
    ses_subject_list = {};
    for iSub = 1:length(valid_subjects)
        sub = char(valid_subjects(iSub));
        sub_id = strrep(sub, 'sub-', ''); % Remove 'sub-' prefix if present
        
        % Find all sessions for this subject
        subject_sessions = image.subses(strcmp(image.subject_id, sub_id));
        
        if ~isempty(subject_sessions)
            % Use the first session 
            first_session = subject_sessions(1);
            ses_subject_list{end+1} = char(first_session);
        else
            warning('No sessions found for subject: %s', sub);
        end
    end
    
    % Save the session-subject list
    ses_subject_list_file = fullfile(study_path, 'ses_subject_use.txt');
    writelines(ses_subject_list, ses_subject_list_file);
    fprintf('Session-subject list saved to: %s\n', ses_subject_list_file);
    
    %% Create BIDS directory structure and copy files
    fprintf('Creating BIDS structure...\n');
    
    % Process each session-subject
    for iSub = 1:length(ses_subject_list)
        ses_sub = char(ses_subject_list(iSub));
        
        % Extract subject and session from the combined string
        % Format: "sub-XXXXXses-XX"
        if contains(ses_sub, 'ses-')
            parts = split(ses_sub, 'ses-');
            sub = parts{1};
            ses = ['ses-', parts{2}];
        else
            warning('Unexpected session format: %s', ses_sub);
            continue;
        end
        
        % Create directory structure: study_path/sub/ses/anat/
        anat_dir = fullfile(study_path, sub, ses, 'anat');
        if ~exist(anat_dir, 'dir')
            mkdir(anat_dir);
        end
        
        % Find the corresponding image file in the original data
        sub_id = strrep(sub, 'sub-', '');
        ses_num = strrep(ses, 'ses-', '');
        
        % Look for the image file in the original structure
        image_idx = find(strcmp(image.subject_id, sub_id) & strcmp(image.ses, ses));
        
        if ~isempty(image_idx)
            % Get the image filename from the original data
            original_filename = image.label{image_idx};
            
            % Define source and destination file paths
            % Note: You may need to adjust this path based on your actual OASIS3 data structure
            source_file = fullfile(source_path, 'derivatives', 'anat', [original_filename, '.nii.gz']);
            dest_file = fullfile(study_path, sub, ses, 'anat', [sub,'_',ses, '_T1w.nii.gz']);
            dest_file_unzipped = fullfile(study_path, sub, ses, 'anat', [sub,'_',ses, '_T1w.nii']);
            
            % Only copy if destination file doesn't exist
            if ~exist(dest_file_unzipped, 'file')
                if exist(source_file, 'file')
                    if ~strcmp(source_file, dest_file)
                        copyfile(source_file, dest_file);
                    end
                    gunzip(dest_file);
                    delete(dest_file);
                    fprintf('Processed: %s\n', ses_sub);
                else
                    warning('Source file not found: %s', source_file);
                end
            else
                fprintf('File already exists, skipping: %s\n', dest_file_unzipped);
            end
        else
            warning('Image data not found for: %s', ses_sub);
        end
    end
    
    fprintf('BIDS conversion completed for %d session-subjects\n', length(ses_subject_list));
else
    fprintf('Non-longitudinal study - BIDS structure creation completed\n');
end

fprintf('\n=== BIDS CONVERSION COMPLETED FOR %s ===\n', study);
fprintf('Total subjects processed: %d\n', length(valid_subjects));
if is_longitudinal
    fprintf('Session-subject pairs: %d\n', length(ses_subject_list));
end
fprintf('Output directory: %s\n', study_path);

end
