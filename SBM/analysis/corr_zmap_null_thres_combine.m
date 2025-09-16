% read all the z-maps and correlate them


clear all
% list of disorders
diagString = {'HC', 'BD', 'SCA',...
    'SCZ', 'ASD', 'MDD' ,'AD'};
addpath('/home/trangc/kg98/trangc/MBM/func')
addpath('/home/trangc/kg98/trangc/VBM/code/utils')
addpath('/home/trangc/kg98/trangc/library/fdr_bh')
addpath(genpath('/projects/kg98/trangc/library/BrainSpace'))
addpath(genpath('/projects/kg98/trangc/library'))
% load(['eigenStruct_',hemi,'.mat']); %load structure that contains eigentrapping because the mask was changed to fix the 164k mesh error


% list of dataset
dataDir = '/projects/kg98/trangc/VBM/data';
dataFilePS = readtable(fullfile(dataDir,'dataset_list_SBM.txt'),'ReadVariableNames',false);
dataList = dataFilePS.Var1;

iCOMBAT = 1;
measureShort = 'thick';
measure = 'thickness';
hemi = 'lh';
smoothKernel = 10;
thres=0.05;
nNull = 1000;

% find all sites
datadir = '/scratch2/kg98/trangc/VBM/data/eigentrap';
datasets = dir(datadir);
datasets = datasets(~ismember({datasets.name}, {'.', '..'})); % Exclude '.' and '..'



%%

corsigmapSurrsHC_PVerAll = cell(1,6);

corsigmapSurrsP_HCVerAll = cell(1,6);

corsigFdrmapSurrsHC_PVerAll = cell(1,6);

corsigFdrmapSurrsP_HCVerAll = cell(1,6);

repsigmapSurrsHC_PVerAll = cell(1,6);

repsigmapSurrsP_HCVerAll = cell(1,6);

repsigFdrmapSurrsHC_PVerAll = cell(1,6);

repsigFdrmapSurrsP_HCVerAll = cell(1,6);
%%
for iDiag = 1:length(diagString)-1


    for iNull = 1:nNull
        data=load (['output/zmap_null_COMBAT',num2str(iCOMBAT),'_',hemi,'_smooth',num2str(smoothKernel),'_ver_part_',char(num2str(iNull)),'_newthres.mat'], ...
            'corsigmapSurrsHC_PVer','corsigmapSurrsP_HCVer','corsigFdrmapSurrsHC_PVer','corsigFdrmapSurrsP_HCVer', ...
    'repsigmapSurrsHC_PVer','repsigmapSurrsP_HCVer','repsigFdrmapSurrsHC_PVer','repsigFdrmapSurrsP_HCVer');
        
        % ids=find(triu(ones(size(corzmapSurrsVer{iDiag})),1));
        % temp = corzmapSurrsVer{iDiag}(ids);
        % corzmapSurrsVerAll{iDiag} = [corzmapSurrsVerAll{iDiag}; temp];


        % Extract upper triangular part and append for corsigmapSurrsHC_PVer
ids = find(triu(ones(size(data.corsigmapSurrsHC_PVer{iDiag})), 1));
temp = data.corsigmapSurrsHC_PVer{iDiag}(ids);
corsigmapSurrsHC_PVerAll{iDiag} = [corsigmapSurrsHC_PVerAll{iDiag}; temp];

% Extract upper triangular part and append for corsigmapSurrsP_HCVer
ids = find(triu(ones(size(data.corsigmapSurrsP_HCVer{iDiag})), 1));
temp = data.corsigmapSurrsP_HCVer{iDiag}(ids);
corsigmapSurrsP_HCVerAll{iDiag} = [corsigmapSurrsP_HCVerAll{iDiag}; temp];

% Extract upper triangular part and append for corsigFdrmapSurrsHC_PVer
ids = find(triu(ones(size(data.corsigFdrmapSurrsHC_PVer{iDiag})), 1));
temp = data.corsigFdrmapSurrsHC_PVer{iDiag}(ids);
corsigFdrmapSurrsHC_PVerAll{iDiag} = [corsigFdrmapSurrsHC_PVerAll{iDiag}; temp];

% Extract upper triangular part and append for corsigFdrmapSurrsP_HCVer
ids = find(triu(ones(size(data.corsigFdrmapSurrsP_HCVer{iDiag})), 1));
temp = data.corsigFdrmapSurrsP_HCVer{iDiag}(ids);
corsigFdrmapSurrsP_HCVerAll{iDiag} = [corsigFdrmapSurrsP_HCVerAll{iDiag}; temp];

% Repeat for repsigmapSurrsHC_PVer
ids = find(triu(ones(size(data.repsigmapSurrsHC_PVer{iDiag})), 1));
temp = data.repsigmapSurrsHC_PVer{iDiag}(ids);
repsigmapSurrsHC_PVerAll{iDiag} = [repsigmapSurrsHC_PVerAll{iDiag}; temp];

% Repeat for repsigmapSurrsP_HCVer
ids = find(triu(ones(size(data.repsigmapSurrsP_HCVer{iDiag})), 1));
temp = data.repsigmapSurrsP_HCVer{iDiag}(ids);
repsigmapSurrsP_HCVerAll{iDiag} = [repsigmapSurrsP_HCVerAll{iDiag}; temp];

% Repeat for repsigFdrmapSurrsHC_PVer
ids = find(triu(ones(size(data.repsigFdrmapSurrsHC_PVer{iDiag})), 1));
temp = data.repsigFdrmapSurrsHC_PVer{iDiag}(ids);
repsigFdrmapSurrsHC_PVerAll{iDiag} = [repsigFdrmapSurrsHC_PVerAll{iDiag}; temp];

% Repeat for repsigFdrmapSurrsP_HCVer
ids = find(triu(ones(size(data.repsigFdrmapSurrsP_HCVer{iDiag})), 1));
temp = data.repsigFdrmapSurrsP_HCVer{iDiag}(ids);
repsigFdrmapSurrsP_HCVerAll{iDiag} = [repsigFdrmapSurrsP_HCVerAll{iDiag}; temp];

    end
end
%%
save(['output/zmap_null_COMBAT',num2str(iCOMBAT),'_',hemi,'_smooth',num2str(smoothKernel),'_ver_all_newthres.mat'],...
    'corsigmapSurrsHC_PVerAll','corsigmapSurrsP_HCVerAll','corsigFdrmapSurrsHC_PVerAll','corsigFdrmapSurrsP_HCVerAll', ...
    'repsigmapSurrsHC_PVerAll','repsigmapSurrsP_HCVerAll','repsigFdrmapSurrsHC_PVerAll','repsigFdrmapSurrsP_HCVerAll');
