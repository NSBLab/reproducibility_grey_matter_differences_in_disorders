%% read demographic information and extract subjects that satisfy criteria:
% - age: 18-60
% - each site has at least 20 subjects

% Trang Cao, Neural Systems and Behaviour Lab, Monash University, 2024.

%% make BIDS format of usable files
clear all
close all

study = 'MBBP';

% define const
LOWAGE = 18*12; % lower bound of age
UPAGE = 60*12; % upper bound of age
NSUB = 20; % lowest number of subject per site per phenotype



% Open the input file for reading
imageTable = readtable(['/projects/kg98/trangc/VBM/data/', study, '/MBBP_dems_ori.csv']);
useFolder = imageTable.subj_id(imageTable.age>=18);
useFolderName = cellfun(@(x) [x(1:4),sprintf('%04d',str2num(x(5:end)))], useFolder,'UniformOutput',false);
% iname = 1;
useID = zeros(size(useFolder));
% copy file
for iSub = [1:length(useFolder)]
        if exist(['/home/trangc/kg98_scratch/Toby/WHOLEMBBP/workspace/processed_niftis/',char(useFolder(iSub)),'/anat/',char(useFolder(iSub)),'_T1w.nii'])
              useID(iSub) = 1;
            
     %        mkdir(['/projects/kg98/trangc/VBM/data/', study,'/',char(useFolderName(iSub)),'/anat' ]);
     %        copyfile(['/home/trangc/kg98_scratch/Toby/WHOLEMBBP/workspace/processed_niftis/',char(useFolder(iSub)),'/anat/',char(useFolder(iSub)),'_T1w.nii'],...
     %            ['/projects/kg98/trangc/VBM/data/', study,'/',char(useFolderName(iSub)),'/anat/',char(useFolderName(iSub)),'_T1w.nii'  ]);
     % 
     % copyfile(['/home/trangc/kg98_scratch/Toby/WHOLEMBBP/workspace/processed_niftis/',char(useFolder(iSub)),'/anat/',char(useFolder(iSub)),'_T1w.json'],...
     %            ['/projects/kg98/trangc/VBM/data/', study,'/',char(useFolderName(iSub)),'/anat/',char(useFolderName(iSub)),'_T1w.json'  ]);
       % iname=iname+1;
        end
end

% only write one time at the begining and then comment
% writelines(useFolderName(useID ==1), ['/projects/kg98/trangc/VBM/data/', study, '/subject_use.txt']);

