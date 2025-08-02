%% read demographic information and extract subjects that satisfy criteria:
% - age: 18-60
% - each site has at least 20 subjects

% Trang Cao, Neural Systems and Behaviour Lab, Monash University, 2024.

%% make BIDS format of usable files
clear all
close all

study = 'ADNIAchieva';

% define const
LOWAGE = 18*12; % lower bound of age
UPAGE = 60*12; % upper bound of age
NSUB = 20; % lowest number of subject per site per phenotype



% Open the input file for reading
imageTable = readtable(['/projects/kg98/trangc/VBM/data/', study, '/adniachieva.csv']);

% list of sites and diagnose
[diag, ~, indexDiag] = unique(imageTable.ResearchGroup);
diagList = {'HC', 'BD', 'SCA',...
    'SCZ', 'ASD', 'MDD' ,'AD'};
nDiag = length(diagList);
diagIndex = {[2],[],[],[],[],[],[1]};

adult.ID = unique(imageTable.SubjectID);

for iDiag = 1:nDiag
 % adult subjects in each phenotype in each site
        condition = ismember(adult.ID,...
            imageTable.SubjectID( ismember(imageTable.ResearchGroup, diag(diagIndex{iDiag}))));
          
       
        adult.use(condition) = 1;
end


useID = adult.ID(adult.use==1);
scantype = unique(imageTable.Description);
imageTable.useID = ismember(imageTable.SubjectID,useID)& ismember(imageTable.Description,scantype([7,12:14]));

%find unique ID
imageTable.useFile = imageTable.useID == 1 ;
[iUseFile col va] = find(imageTable.useFile);

idUse = imageFile.src_subject_id(iUseFile);
[useSub iUnique iID] = unique(idUse);


useFolder = adult.ID(adult.use==1);


 useID = zeros(size(useFolder));
% copy file
for iSub = 11:length(useFolder)
   
   if exist(['/scratch/kg98/Data_Trang/WMH-AD/rawdata/',char(useFolder(iSub)),'/ses-T00/anat/',char(useFolder(iSub)),'_ses-T00_acq-3D_T1w.nii.gz'])
       useID(iSub) = 1;
            useFolder(iSub)
            mkdir(['/projects/kg98/trangc/VBM/data/', study,'/',char(useFolder(iSub)),'/ses-1/anat' ]);
            copyfile(['/scratch/kg98/Data_Trang/WMH-AD/rawdata/',char(useFolder(iSub)),'/ses-T00/anat/',char(useFolder(iSub)),'_ses-T00_acq-3D_T1w.nii.gz'],...
                ['/projects/kg98/trangc/VBM/data/', study,'/',char(useFolder(iSub)),'/ses-1/anat/',char(useFolder(iSub)),'_ses-1_T1w.nii.gz'  ]);

         gunzip(['/projects/kg98/trangc/VBM/data/', study,'/',char(useFolder(iSub)),'/ses-1/anat/',char(useFolder(iSub)),'_ses-1_T1w.nii.gz'  ]);
        delete(['/projects/kg98/trangc/VBM/data/', study,'/',char(useFolder(iSub)),'/ses-1/anat/',char(useFolder(iSub)),'_ses-1_T1w.nii.gz'  ]);
   end
end
for iDiag = 1:nDiag
 % adult subjects in each phenotype in each site
        condition = ismember(useFolder(useID==1),...
            imageTable.PatientID_BIDS( ismember(imageTable.Diagnosis, diag(diagIndex{iDiag}))));
            % number of adult subjects in each phenotype in each site
        % number of adult subjects in each phenotype in each site
    nSubPerPhenotypePerSite(iDiag) = sum(condition);
       
end
% only write one time at the begining and then comment
% writelines(useFolder(useID==1), ['/projects/kg98/trangc/VBM/data/', study, '/subject_use.txt']);

