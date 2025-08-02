%% read demographic information and extract subjects that satisfy criteria:
% - age: 18-60
% - each site has at least 20 subjects

% Trang Cao, Neural Systems and Behaviour Lab, Monash University, 2024.

%% make BIDS format of usable files
clear all
close all

study = 'Harmonisation';

% define const

NSUB = 20; % lowest number of subject per site per phenotype



% Open the input file for reading
imageTable = readtable(['/projects/kg98/trangc/VBM/data/', study, '/Harmonisation_demo.csv'], "FileType","text",'Delimiter', ',');
useFolder = imageTable.subid;
% useID = zeros(size(useFolder));
iname = 1;
% copy file
for iSub = 1:length(useFolder)


    if exist(['/scratch/kg98/Data_Trang/harmonisation/T1w images/',char(useFolder(iSub)),'_BL.zip'])
        % useID(iSub) = 1;
        % mkdir(['/projects/kg98/trangc/VBM/data/', study,'/sub-',char(useFolder(iSub)),'/ses-1/anat' ]);
        % copyfile(['/scratch/kg98/Data_Trang/harmonisation/T1w images/',char(useFolder(iSub)),'_BL.zip'],...
        %     ['/projects/kg98/trangc/VBM/data/', study,'/sub-',char(useFolder(iSub)),'/ses-1/anat/sub-',char(useFolder(iSub)),'.zip'  ]);
        allItems = dir(['/projects/kg98/trangc/VBM/data/', study,'/sub-',char(useFolder(iSub)),'/ses-1/anat/']);

        % Filter only folders (ignoring '.' and '..' system folders)
         allFolders = allItems([allItems.isdir]);  % Keep only directories
        allFolders = allFolders(~ismember({allFolders.name}, {'.', '..'}));  % Exclude '.' and '..'
        for iFolder = 1:height(allFolders)
            foldercontain.sub(iname,1) = useFolder(iSub);
            foldercontain.name(iname,1) = {allFolders(iFolder).name};
            allNifti= dir(['/projects/kg98/trangc/VBM/data/', study,'/sub-',char(useFolder(iSub)),'/ses-1/anat/',allFolders(iFolder).name,'/*.nii.gz']);
            [va in] = max([allNifti.bytes]);
            copyfile([allNifti(in).folder,'/',allNifti(in).name],['/projects/kg98/trangc/VBM/data/', study,'/sub-',char(useFolder(iSub)),'/ses-1/anat/sub-',char(useFolder(iSub)),'_ses-1_T1w.nii.gz']);
            gunzip(['/projects/kg98/trangc/VBM/data/', study,'/sub-',char(useFolder(iSub)),'/ses-1/anat/sub-',char(useFolder(iSub)),'_ses-1_T1w.nii.gz']);
          
            iname = iname+1;

            % movefile(['/projects/kg98/trangc/VBM/data/', study,'/sub-',char(useFolder(iSub)),'/ses-1/anat/',allFolders(iFolder).name], ['/projects/kg98/trangc/VBM/data/', study,'/sub-',char(useFolder(iSub)),'/ses-1/anat/',strrep(allFolders(iFolder).name, ' ', '_')])
            % unzip(['/projects/kg98/trangc/VBM/data/', study,'/sub-',char(useFolder(iSub)),'/ses-1/anat/sub-',char(useFolder(iSub)),'.zip'  ]);
            % delete(['/projects/kg98/trangc/VBM/data/', study,'/sub-',char(useFolder(iSub)),'/ses-1/anat/sub-',char(useFolder(iSub)),'.zip'  ]);
        end
    end
end
% useFoldersave = cellfun(@(x) ['sub-',char(x)],useFolder(useID==1), 'UniformOutput', false);
    % % only write one time at the begining and then comment
    % writelines(useFoldersave, ['/projects/kg98/trangc/VBM/data/', study, '/subject_use.txt']);

metaTable = cell2table([foldercontain.sub,foldercontain.name]);
