%% read demographic information and extract subjects that satisfy criteria:
% - age: 18-60
% - each site has at least 20 subjects

% Trang Cao, Neural Systems and Behaviour Lab, Monash University, 2024.

%% make BIDS format of usable files
clear all
close all

study = 'RestDepress';

% define const
LOWAGE = 18*12; % lower bound of age
UPAGE = 60*12; % upper bound of age
NSUB = 20; % lowest number of subject per site per phenotype



% Open the input file for reading
imageTable = readtable(['/projects/kg98/trangc/VBM/data/', study, '/participants.tsv'], "FileType","text",'Delimiter', '\t');
useFolder = imageTable.participant_id;

% copy file
for iSub = 1:length(useFolder)
   

       
            
            mkdir(['/projects/kg98/trangc/VBM/data/', study,'/',char(useFolder(iSub)),'/anat' ]);
            copyfile(['/scratch/kg98/Data_Trang/MDD_restingState/',char(useFolder(iSub)),'/anat/',char(useFolder(iSub)),'_T1w.nii.gz'],...
                ['/projects/kg98/trangc/VBM/data/', study,'/',char(useFolder(iSub)),'/anat/',char(useFolder(iSub)),'_T1w.nii.gz'  ]);
              gunzip(['/projects/kg98/trangc/VBM/data/', study,'/',char(useFolder(iSub)),'/anat/',char(useFolder(iSub)),'_T1w.nii.gz'  ]);
        delete(['/projects/kg98/trangc/VBM/data/', study,'/',char(useFolder(iSub)),'/anat/',char(useFolder(iSub)),'_T1w.nii.gz'  ]);
     
end

% only write one time at the begining and then comment
% writelines(useFolder, ['/projects/kg98/trangc/VBM/data/', study, '/subject_use.txt']);

