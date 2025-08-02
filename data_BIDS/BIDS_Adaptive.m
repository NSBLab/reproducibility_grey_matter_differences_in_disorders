%% read demographic information and extract subjects that satisfy criteria:
% - age: 18-60
% - each site has at least 20 subjects

% Trang Cao, Neural Systems and Behaviour Lab, Monash University, 2024.

%% make BIDS format of usable files
clear all
close all

study = 'Adaptive';

% define const
LOWAGE = 18*12; % lower bound of age
UPAGE = 60*12; % upper bound of age
NSUB = 20; % lowest number of subject per site per phenotype



% Open the input file for reading
imageTable = readtable(['/projects/kg98/trangc/VBM/data/', study, '/image03.txt']);
siteTable = readtable(['/projects/kg98/trangc/VBM/data/', study, '/ndar_subject01.txt']);

imageFile.src_subject_id = cellstr(cellfun(@(x) x(3:end), imageTable.src_subject_id(2:end,:), 'UniformOutput', false));
imageFile.scan_type = cellstr(imageTable.scan_type(2:end,:));
imageFile.image_file = cellstr(imageTable.image_file(2:end,:));
imageFile.sex = cellstr(imageTable.sex(2:end,:));
imageFile.interview_age = str2double(string(imageTable.interview_age(2:end,:))); % remove the first line of description
imageFile.interview_date = cellstr(imageTable.interview_date(2:end,:)); % remove the first line of description

siteFile.src_subject_id = cellstr(cellfun(@(x) x(3:end), siteTable.src_subject_id, 'UniformOutput', false));
siteFile.phenotype = cellstr(siteTable.phenotype);

% image filename
pat1 = "submission"+wildcardPattern + (".nii.gz");
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
[diag, ~, indexDiag] = unique(siteFile.phenotype);
diagList = {'HC', 'BD', 'SCA',...
    'SCZ', 'ASD', 'MDD' };
nDiag = length(diagList);
diagIndex = {[1],[],[],[2],[],[]};


for iDiag = 1: nDiag % control and proband in the diag list
    % adult subjects in each phenotype in each site
    condition = ismember(adult.ID,...
        siteFile.src_subject_id(ismember(siteFile.phenotype, diag(diagIndex{iDiag})))) ;

    % number of adult subjects in each phenotype in each site
    nSubPerPhenotypePerSite(iDiag) = sum(condition);
end

% the site and phenotype has >= NSUB HC subjects
siteSizeCondition = nSubPerPhenotypePerSite >= NSUB;

adult.use =  zeros(size(adult.ID));
for iDiag = 1:nDiag

    if siteSizeCondition(iDiag) == 1

        % adult subjects in each phenotype in each site
        condition = ismember(adult.ID,...
            siteFile.src_subject_id( ismember(siteFile.phenotype, diag(diagIndex{iDiag}))));
        adult.use(condition) = 1;
    end

end

useID = adult.ID(adult.use==1);
imageFile.useID = ismember(imageFile.src_subject_id,useID)& ismember(imageFile.scan_type,{'T1'});

%find unique ID
imageFile.useFile = imageFile.useID == 1 ;
[iUseFile col va] = find(imageFile.useFile);

idUse = imageFile.src_subject_id(iUseFile);
[useSub iUnique iID] = unique(idUse);

useFile = cellstr(imageFile.filepath(iUseFile(iUnique),:));
useFolder = cellstr(imageFile.src_subject_id(iUseFile(iUnique),:));
useFolderName = cellfun(@(x) [char(x(1:end))],useFolder, 'UniformOutput', false);

% copy file
for iSub = 1:length(useFolder)
    indexFilePerSub = strcmp(imageFile.src_subject_id,useFolder(iSub))& imageFile.useID==1;
    filePerSub = imageFile.filepath(indexFilePerSub);
    datePerSub = imageFile.interview_date(indexFilePerSub);
    if length(unique(datePerSub))>1
        useFolder(iSub)
    end
    iDate = 1;
    uniqueDate = {};
    for iFile = 1:length(filePerSub)
        if ~ismember(datePerSub(iFile),uniqueDate)
            uniqueDate(iDate) = datePerSub(iFile);
            mkdir(['/projects/kg98/trangc/VBM/data/', study,'/sub-',char(useFolderName(iSub)),'/anat' ]);
            copyfile(['/scratch/kg98/Data_Trang/SCZ_Adaptive/image03/',char(filePerSub(iFile))],['/projects/kg98/trangc/VBM/data/', study,'/sub-',char(useFolderName(iSub)),'/anat/sub-',char(useFolderName(iSub)),'.nii.gz'  ])
       gunzip(['/projects/kg98/trangc/VBM/data/', study,'/sub-',char(useFolderName(iSub)),'/anat/sub-',char(useFolderName(iSub)),'_ses-01_T1w.nii.gz'  ]);
      movefile(['/projects/kg98/trangc/VBM/data/', study,'/sub-',char(useFolderName(iSub)),'/anat/sub-',char(useFolderName(iSub)),'_ses-01_T1w.nii'  ],...
          ['/projects/kg98/trangc/VBM/data/', study,'/sub-',char(useFolderName(iSub)),'/anat/sub-',char(useFolderName(iSub)),'_T1w.nii'  ]);
      delete(['/projects/kg98/trangc/VBM/data/', study,'/sub-',char(useFolderName(iSub)),'/anat/sub-',char(useFolderName(iSub)),'_ses-01_T1w.nii.gz'  ]);
           
            iDate = iDate+1;
        end
    end
end

useFolder = cellfun(@(x) ['sub-',char(x)],useFolderName, 'UniformOutput', false);
% only write one time at the begining and then comment
writelines(useFolder, ['/projects/kg98/trangc/VBM/data/', study, '/subject_use.txt']);

