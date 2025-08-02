%% read demographic information and extract subjects that satisfy criteria:
% - age: 18-60
% - each site has at least 20 subjects

% Trang Cao, Neural Systems and Behaviour Lab, Monash University, 2024.

%% make BIDS format of usable files
clear all
close all

study = 'ContrastRes';

% define const
LOWAGE = 18*12; % lower bound of age
UPAGE = 60*12; % upper bound of age
NSUB = 20; % lowest number of subject per site per phenotype



% Open the input file for reading
imageTable = readtable(['/projects/kg98/trangc/VBM/data/', study, '/participants.tsv'], "FileType","text",'Delimiter', '\t');
useFolder = imageTable.participant_id;

% copy file
for iSub = 1:length(useFolder)
   
    % Get all files and folders in the specified path
allItems = dir(['/scratch/kg98/Data_Trang/ASD_contrast/',char(useFolder(iSub))]);

% Filter only folders (ignoring '.' and '..' system folders)
allFolders = allItems([allItems.isdir]);  % Keep only directories
allFolders = allFolders(~ismember({allFolders.name}, {'.', '..'}));  % Exclude '.' and '..'

    for iFile = 1:height(allFolders)
       
            
            mkdir(['/projects/kg98/trangc/VBM/data/', study,'/',char(useFolder(iSub)),'/ses-',char(num2str(iFile)),'/anat' ]);
            copyfile(['/scratch/kg98/Data_Trang/ASD_contrast/',char(useFolder(iSub)),'/',allFolders(iFile).name,'/anat/',char(useFolder(iSub)),'_',allFolders(iFile).name,'_T1w.nii.gz'],...
                ['/projects/kg98/trangc/VBM/data/', study,'/',char(useFolder(iSub)),'/ses-',char(num2str(iFile)),'/anat/',char(useFolder(iSub)),'_','ses-',char(num2str(iFile)),'_T1w.nii.gz'  ]);
           gunzip(['/projects/kg98/trangc/VBM/data/', study,'/',char(useFolder(iSub)),'/ses-',char(num2str(iFile)),'/anat/',char(useFolder(iSub)),'_','ses-',char(num2str(iFile)),'_T1w.nii.gz'  ]);
        delete(['/projects/kg98/trangc/VBM/data/', study,'/',char(useFolder(iSub)),'/ses-',char(num2str(iFile)),'/anat/',char(useFolder(iSub)),'_','ses-',char(num2str(iFile)),'_T1w.nii.gz'  ]);
        
    end
end

% only write one time at the begining and then comment
% writelines(useFolder, ['/projects/kg98/trangc/VBM/data/', study, '/subject_use.txt']);

