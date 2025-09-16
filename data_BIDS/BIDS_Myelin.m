function BIDS_Myelin(config)
%% read demographic information and extract subjects that satisfy criteria:
% - age: 18-60
% - each site has at least 20 subjects

% Trang Cao, Neural Systems and Behaviour Lab, Monash University, 2024.

study = 'Myelin';

% Use config passed as parameter, or load from file if not provided
if nargin < 1 || isempty(config)
    % Fallback: Load configuration from config.json file
    config = jsondecode(fileread('../config.json'));
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

% Open the input file for reading
imageFile = readtable(fullfile(source_path, 'participants.tsv'), "FileType","text",'Delimiter', '\t');

% subject in the age range 18-60 at scanning time
imageFile.adult = imageFile.age >= LOWAGE & imageFile.age <= UPAGE;
adult.ID = unique(imageFile.participant_id(imageFile.adult == 1));

% list of sites and diagnose
[diag, ~, indexDiag] = unique(imageFile.group);
diagList = [1,3]; %manually added once seeing the diagnosis labels

nDiag = size(diag,1);

for iDiag = 1: nDiag % control and proband in the diag list
    % adult subjects in each phenotype in each site
    condition = ismember(adult.ID,...
        imageFile.participant_id(indexDiag == iDiag));
    
    % number of adult subjects in each phenotype in each site
    nSubPerPhenotypePerSite( iDiag) = sum(condition);
end

% the site and phenotype has >= NSUB HC subjects
siteSizeCondition = nSubPerPhenotypePerSite >= NSUB;

adult.use =  zeros(size(adult.ID));

for iDiag = diagList
    if siteSizeCondition( iDiag) == 1
        % adult subjects in each phenotype in each site
        condition = ismember(adult.ID,...
            imageFile.participant_id( indexDiag == iDiag));
        adult.use(condition) = 1;
    end
end

useID = adult.ID(adult.use==1);
imageFile.useID = ismember(imageFile.participant_id,useID);
imageFile.useFile = imageFile.useID == 1 ;
[iUseFile col va] = find(imageFile.useFile);

idUse = imageFile.participant_id(iUseFile);
[useSub iUnique iID] = unique(idUse);

useFolder = cellstr(imageFile.participant_id(iUseFile(iUnique),:));

% Save the filtered subject list
writelines(useFolder, fullfile(study_path, 'subject_use.txt'));

fprintf('Extracted %d subjects that meet the criteria (age %d-%d, min %d subjects per site/phenotype)\n', ...
    length(useFolder), LOWAGE, UPAGE, NSUB);
fprintf('Subject list saved to: %s\n', fullfile(study_path, 'subject_use.txt'));

%% Handle longitudinal study structure
if is_longitudinal
    fprintf('Processing as longitudinal study...\n');
    
    % Extract session information for longitudinal study
    ses_subject_list = {};
    for iSub = 1:length(useFolder)
        sub = char(useFolder(iSub));
        sub_path = fullfile(source_path, sub);
        
        if exist(sub_path, 'dir')
            % List all sessions for this subject
            sessions = dir(sub_path);
            sessions = sessions([sessions.isdir]); % Only directories
            sessions = sessions(~ismember({sessions.name}, {'.', '..'})); % Exclude . and ..
            
            if ~isempty(sessions)
                % Use the first session 
                first_session = sessions(1).name;
                ses_subject_list{end+1} = sprintf('%s%s', sub, first_session);
            else
                warning('No sessions found for subject: %s', sub);
            end
        else
            warning('Subject directory not found: %s', sub_path);
        end
    end
    
    % Save the session-subject list
    writelines(ses_subject_list, fullfile(study_path, 'ses_subject_use.txt'));
    fprintf('Session-subject list saved to: %s\n', fullfile(study_path, 'ses_subject_use.txt'));
    
    %% make BIDS format of usable files for longitudinal study
    % Now process only the filtered subjects with sessions
    for iSub = 1:length(ses_subject_list)
        ses_sub = char(ses_subject_list(iSub));
        
        % Extract subject and session from the combined string
        % Assuming format is like "sub-001ses-01" or similar
  
        if contains(ses_sub, 'ses-')
            parts = split(ses_sub, 'ses-');
            sub = parts{1};
            ses = ['ses-', parts{2}];
        else
            % Fallback: assume the last part is the session
            sub = ses_sub(1:end-6); % Remove last 6 characters (session)
            ses = ses_sub(end-5:end); % Last 6 characters (session)
        end
        
        % Create directory structure: study_path/sub/ses/anat/
        anat_dir = fullfile(study_path, sub, ses, 'anat');
        if ~exist(anat_dir, 'dir')
            mkdir(anat_dir);
        end
        
        % Define source and destination file paths
        source_file = fullfile(source_path, sub, ses, 'anat', [sub,'_',ses, '_T1w.nii.gz']);
        dest_file = fullfile(study_path, sub, ses, 'anat', [sub,'_',ses, '_T1w.nii.gz']);
        dest_file_unzipped = fullfile(study_path, sub, ses, 'anat', [sub,'_',ses, '_T1w.nii']);
        
        % Only copy if destination file doesn't exist or if source and destination are different
        if ~exist(dest_file_unzipped, 'file')
            if exist(source_file, 'file')
                if ~strcmp(source_file, dest_file)
                    copyfile(source_file, dest_file);
                end
                gunzip(dest_file);
                delete(dest_file);
            else
                warning('Source file not found: %s', source_file);
            end
        else
            fprintf('File already exists, skipping: %s\n', dest_file_unzipped);
        end
    end
    
    fprintf('BIDS conversion completed for %d session-subjects\n', length(ses_subject_list));

end
end