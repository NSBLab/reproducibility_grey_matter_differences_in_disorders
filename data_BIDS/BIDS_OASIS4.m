%% read demographic information and extract subjects that satisfy criteria:
% - age: 18-60
% - each site has at least 20 subjects

% Trang Cao, Neural Systems and Behaviour Lab, Monash University, 2024.

%% make BIDS format of usable files
clear all
close all

study = 'OASIS4';

% define const
LOWAGE = 18*12; % lower bound of age
UPAGE = 60*12; % upper bound of age
NSUB = 20; % lowest number of subject per site per phenotype



% Open the input file for reading
imageTable = readtable(['/projects/kg98/trangc/VBM/data/', study, '/OASIS4_data_clinical.csv']);

% list of sites and diagnose
[diag, ~, indexDiag] = unique(imageTable.final_dx);
diagList = {'HC', 'BD', 'SCA',...
    'SCZ', 'ASD', 'MDD' ,'AD'};
nDiag = length(diagList);
diagIndex = {[5],[],[],[],[],[],[1:4,7]};

adult.ID = unique(imageTable.oasis_id);

for iDiag = 1:nDiag
    % adult subjects in each phenotype in each site
    condition = ismember(adult.ID,...
        imageTable.oasis_id( ismember(imageTable.final_dx, diag(diagIndex{iDiag}))));
    % number of adult subjects in each phenotype in each site
    nSubPerPhenotypePerSite( iDiag) = sum(condition);

    adult.use(condition) = 1;
end
useFolder = adult.ID(adult.use==1);
useID = zeros(size(useFolder));

% copy file
for iSub = 1:length(useFolder)
    iCombine = 1;
    anatfolfer = dir(fullfile('/scratch/kg98/Data_Trang/OASIS4/',char(useFolder(iSub)),'*/*'));
    for iFolder = 1:height(anatfolfer)
        anatfile = dir(fullfile(anatfolfer(iFolder).folder,anatfolfer(iFolder).name,'NIFTI'));
        jsonfile = dir(fullfile(anatfolfer(iFolder).folder,anatfolfer(iFolder).name,'BIDS'));
        for iAnat = 1:height(anatfile)
            if contains(anatfile(iAnat).name,'T1w')
                fileSource(iCombine) = {fullfile(anatfile(iAnat).folder,anatfile(iAnat).name)};
                jsonSource(iCombine) = {fullfile(jsonfile(iAnat).folder,jsonfile(iAnat).name)};
                fileSize(iCombine) = anatfile(iAnat).bytes;
                iCombine = iCombine +1;
            end
        end
    end




    if exist('fileSource','var')
        [va inMax] = max(fileSize);
        file2Copy = fileSource{inMax};
 json2Copy = jsonSource{inMax};
        useID(iSub) = 1;
        useFolder(iSub)
        mkdir(['/projects/kg98/trangc/VBM/data/', study,'/sub-',char(useFolder(iSub)),'/ses-1/anat' ]);
        copyfile(file2Copy,...
            ['/projects/kg98/trangc/VBM/data/', study,'/sub-',char(useFolder(iSub)),'/ses-1/anat/sub-',char(useFolder(iSub)),'_ses-1_T1w.nii.gz'  ]);
copyfile(json2Copy,...
            ['/projects/kg98/trangc/VBM/data/', study,'/sub-',char(useFolder(iSub)),'/ses-1/anat/sub-',char(useFolder(iSub)),'_ses-1_T1w.json'  ]);

        gunzip(['/projects/kg98/trangc/VBM/data/', study,'/sub-',char(useFolder(iSub)),'/ses-1/anat/sub-',char(useFolder(iSub)),'_ses-1_T1w.nii.gz'  ]);
        delete(['/projects/kg98/trangc/VBM/data/', study,'/sub-',char(useFolder(iSub)),'/ses-1/anat/sub-',char(useFolder(iSub)),'_ses-1_T1w.nii.gz'  ]);
        clear fileSource fileSize

    end
end


for iDiag = 1:nDiag
    % adult subjects in each phenotype in each site
    condition = ismember(useFolder(useID==1),...
        imageTable.oasis_id( ismember(imageTable.final_dx, diag(diagIndex{iDiag}))));
    % number of adult subjects in each phenotype in each site
    % number of adult subjects in each phenotype in each site
    nSubPerPhenotypePerSite(iDiag) = sum(condition);

end
useFolderName = cellfun(@(x) ['sub-',char(x)],useFolder, 'UniformOutput', false);
% only write one time at the begining and then comment
% writelines(useFolderName(useID==1), ['/projects/kg98/trangc/VBM/data/', study, '/subject_copy.txt']);

