%% read demographic information and extract subjects that satisfy criteria:
% - age: 18-60
% - each site has at least 20 subjects

% Trang Cao, Neural Systems and Behaviour Lab, Monash University, 2024.

%% make BIDS format of usable files
clear all
close all

study = 'ARWIBO';

% define const
LOWAGE = 18*12; % lower bound of age
UPAGE = 60*12; % upper bound of age
NSUB = 20; % lowest number of subject per site per phenotype



% Open the input file for reading
imageTable = readtable(['/projects/kg98/trangc/VBM/data/', study, '/ng2_ARWIBO_fulldataset.csv']);

% list of sites and diagnose
[diag, ~, indexDiag] = unique(imageTable.Diagnosis);
diagList = {'HC', 'BD', 'SCA',...
    'SCZ', 'ASD', 'MDD' ,'AD'};
nDiag = length(diagList);
diagIndex = {[46],[],[],[],[],[],[1,3:11,26:29,31,83,90:92]};

adult.ID = unique(imageTable.PatientID_BIDS);

for iDiag = 1:nDiag
 % adult subjects in each phenotype in each site
        condition = ismember(adult.ID,...
            imageTable.PatientID_BIDS( ismember(imageTable.Diagnosis, diag(diagIndex{iDiag}))));
           % number of adult subjects in each phenotype in each site
    nSubPerPhenotypePerSite( iDiag) = sum(condition);
       
        adult.use(condition) = 1;
end
useFolder = adult.ID(adult.use==1);
 useID = zeros(size(useFolder));
% copy file
for iSub = 1:length(useFolder)
   
   if exist(['/scratch/kg98/Data_Trang/ARWIBO/ARWIBO/rawdata/',char(useFolder(iSub)),'/ses-T00/anat/',char(useFolder(iSub)),'_ses-T00_acq-3D_T1w.nii.gz'])
       useID(iSub) = 1;
            useFolder(iSub)
            mkdir(['/projects/kg98/trangc/VBM/data/', study,'/',char(useFolder(iSub)),'/ses-1/anat' ]);
            copyfile(['/scratch/kg98/Data_Trang/ARWIBO/ARWIBO/rawdata/',char(useFolder(iSub)),'/ses-T00/anat/',char(useFolder(iSub)),'_ses-T00_acq-3D_T1w.nii.gz'],...
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

