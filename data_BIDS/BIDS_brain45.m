%% read demographic information and extract subjects that satisfy criteria:
% - age: 18-60
% - each site has at least 20 subjects

% Trang Cao, Neural Systems and Behaviour Lab, Monash University, 2024.

%% make BIDS format of usable files
clear all
close all

study = 'Brain45';

% define const
LOWAGE = 18*12; % lower bound of age
UPAGE = 60*12; % upper bound of age
NSUB = 20; % lowest number of subject per site per phenotype

% Define the input and output file paths
outputFile = '/home/trangc/kg98/trangc/VBM/data/Brain45/extracted_paths.txt';

% Open the input file for reading
imageTable = readtable(['/projects/kg98/trangc/VBM/data/', study, '/image03.txt']);
siteTable = readtable(['/projects/kg98/trangc/VBM/data/', study, '/ndar_subject01.txt']);

imageFile.src_subject_id = cellstr(num2str(imageTable.src_subject_id(2:end,:)));
imageFile.scan_type = cellstr(imageTable.scan_type(2:end,:));
imageFile.image_file = cellstr(imageTable.image_file(2:end,:));
imageFile.sex = cellstr(imageTable.sex(2:end,:));
imageFile.interview_age = str2double(string(imageTable.interview_age(2:end,:))); % remove the first line of description
imageFile.interview_date = cellstr(imageTable.interview_date(2:end,:)); % remove the first line of description

siteFile.src_subject_id = cellstr(num2str(siteTable.src_subject_id));
siteFile.phenotype_description = cellstr(siteTable.phenotype_description);

% image filename
pat1 = "submission"+wildcardPattern+".nii";
imageFile.filepathlong = cellstr(char(extract(imageFile.image_file,pat1)));
% Find the first '/' in the path
firstSlashIndex = cellfun(@(x) find(x == '/', 1, 'first'), imageFile.filepathlong, 'UniformOutput', false);

imageFile.filepath = cellfun(@(x,y) x((y+1)*double(~strcmp(x(y+1),'/'))+(y+2)*double(strcmp(x(y+1),'/')):end),imageFile.filepathlong,firstSlashIndex,'UniformOutput',false);%to remove the double // in the dir

% % folder name
%   % Find the last '/' in the path
%    lastSlashIndex = cellfun(@(x) find(x == '/', 1, 'last'), imageFile.filepathlong, 'UniformOutput', false);
% imageFile.folderName = cellfun(@(x,y)  regexp(x(y:end), '\d{4}','match'), imageFile.filepathlong, lastSlashIndex,'UniformOutput', false);

% subject in the age range 18-60 at scanning time
imageFile.adult = imageFile.interview_age >= LOWAGE & imageFile.interview_age <= UPAGE;
adult.ID = unique(imageFile.src_subject_id(imageFile.adult == 1 ));

% list of sites and diagnose
[diag, ~, indexDiag] = unique(siteFile.phenotype_description);

nDiag = size(diag,1);

diagList = [1,5];

% control = 'TD';
% [iControl ic] = find(strcmp(diag, control));

for iDiag = 1: nDiag % control and proband in the diag list
    % adult subjects in each phenotype in each site
    condition = ismember(adult.ID,...
        siteFile.src_subject_id(indexDiag == iDiag)) ;

    % number of adult subjects in each phenotype in each site
    nSubPerPhenotypePerSite( iDiag) = sum(condition);

end


% the site and phenotype has >= NSUB HC subjects
siteSizeCondition = nSubPerPhenotypePerSite >= NSUB;

adult.use =  zeros(size(adult.ID));

for iDiag = 1:nDiag

    if siteSizeCondition(iDiag) == 1

        % adult subjects in each phenotype in each site
        condition = ismember(adult.ID,...
            siteFile.src_subject_id( indexDiag == iDiag));
        adult.use(condition) = 1;
    end

end

useID = adult.ID(adult.use==1);
imageFile.useID = ismember(imageFile.src_subject_id,useID)& strcmp(imageFile.scan_type,'MR structural (MPRAGE)');

%find unique ID
imageFile.useFile = imageFile.useID == 1 ;
[iUseFile col va] = find(imageFile.useFile);

idUse = imageFile.src_subject_id(iUseFile);
[useSub iUnique iID] = unique(idUse);

useFile = cellstr(imageFile.filepath(iUseFile(iUnique),:));
useFolder = cellstr(imageFile.src_subject_id(iUseFile(iUnique),:));


% copy file
for iSub = 1:length(useFolder)
    indexFilePerSub = strcmp(imageFile.src_subject_id,useFolder(iSub))& imageFile.useID==1;
    filePerSub = imageFile.filepath(indexFilePerSub);
    datePerSub = imageFile.interview_date(indexFilePerSub);
    iDate = 1;
    uniqueDate = {};
    for iFile = 1:length(filePerSub)
        if ~ismember(datePerSub(iFile),uniqueDate)
            uniqueDate(iDate) = datePerSub(iFile);
            mkdir(['/projects/kg98/trangc/VBM/data/', study,'/sub-',char(useFolder(iSub)),'/ses-',char(num2str(iDate)),'/anat' ]);
            copyfile(['/scratch/kg98/Data_Trang/ASD_brain45/image03/',char(filePerSub(iFile))],['/projects/kg98/trangc/VBM/data/', study,'/sub-',char(useFolder(iSub)),'/ses-',char(num2str(iDate)),'/anat/sub-',char(useFolder(iSub)),'_','ses-',char(num2str(iDate)),'_T1w.nii'  ])
            iDate = iDate+1;
        end
    end
end

useFolder = cellfun(@(x) ['sub-',char(x)],useFolder, 'UniformOutput', false);
% only write one time at the begining and then comment
% writelines(useFolder, ['/projects/kg98/trangc/VBM/data/', study, '/subject_use.txt']);

