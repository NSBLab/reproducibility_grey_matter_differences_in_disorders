function BIDS_RD(config)
%% read demographic information and extract subjects that satisfy criteria:
% - age: 18-60
% - each site has at least 20 subjects

% Trang Cao, Neural Systems and Behaviour Lab, Monash University, 2024.

study = 'RD';

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
diagList = 1:2; % Based on extract_sub_RD.m structure

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

%% make BIDS format of usable files
% Now process only the filtered subjects
for iSub = 1:length(useFolder)
    anat_dir = fullfile(study_path, char(useFolder(iSub)), 'anat');
    if ~exist(anat_dir, 'dir')
        mkdir(anat_dir);
    end
    
       
    % Define source and destination file paths
    source_file = fullfile(source_path, char(useFolder(iSub)), 'anat', [char(useFolder(iSub)), '_T1w.nii.gz']);
    dest_file = fullfile(study_path, char(useFolder(iSub)), 'anat', [char(useFolder(iSub)), '_T1w.nii.gz']);
    dest_file_unzipped = fullfile(study_path, char(useFolder(iSub)), 'anat', [char(useFolder(iSub)), '_T1w.nii']);
    
    % Only copy if destination file doesn't exist or if source and destination paths are different
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

fprintf('BIDS conversion completed for %d subjects\n', length(useFolder));
end

