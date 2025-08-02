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
dataFilePS = readtable(fullfile(dataDir,'dataset_list_VBM.txt'),'ReadVariableNames',false);
dataList = dataFilePS.Var1;

iCOMBAT = 1;
measureShort = 'thick';
measure = 'thickness';
smoothKernel = 6;
thres=0.05;
nNull = 100;

% % find all sites
% datadir = '/projects/kg98/trangc/VBM/code/freesurfer/freesurfer_holmesQC/step4_qdec/output';
% datasets = dir(datadir);
% datasets = datasets(~ismember({datasets.name}, {'.', '..'})); % Exclude '.' and '..'



%%

cortmapBrainsmashSurrsVerAll = cell(1,6);
corsigmapSurrsHC_PVerAll = cell(1,6);
corsigmapSurrsP_HCVerAll = cell(1,6);
corsigFwemapSurrsHC_PVerAll = cell(1,6);
corsigFwemapSurrsP_HCVerAll = cell(1,6);
repsigmapSurrsHC_PVerAll = cell(1,6);
repsigmapSurrsP_HCVerAll = cell(1,6);
repsigFwemapSurrsHC_PVerAll = cell(1,6);
repsigFwemapSurrsP_HCVerAll = cell(1,6);
%%
for iDiag = 1:length(diagString)-1


    for iNull = 1:nNull
        %load (['output/corr_null_tmap_brainsmash_combat',num2str(iCOMBAT),...
            % '_smooth', char(num2str(smoothKernel)), '_smoothsurro_', char(num2str(iNull)), '.mat'],'corNull');
        data = load (['output/corr_null_tmap_brainsmash_combat',num2str(iCOMBAT),...
            '_smooth', char(num2str(smoothKernel)), '_', char(num2str(iNull)), '.mat'],'corNull',...
            'corsigmapSurrs_HC_P','corsigmapSurrs_P_HC','repsigmapSurrs_HC_P','repsigmapSurrs_P_HC',...
    'corsigFwemapSurrs_HC_P','corsigFwemapSurrs_P_HC','repsigFwemapSurrs_HC_P','repsigFwemapSurrs_P_HC');
        
        ids=find(triu(ones(size(data.corNull{iDiag})),1));
        temp = median(data.corNull{iDiag}(ids));
        cortmapBrainsmashSurrsVerAll{iDiag} = [cortmapBrainsmashSurrsVerAll{iDiag}; temp];

         % Extract upper triangular part and append for corsigmapSurrs_HC_PVer
        ids = find(triu(ones(size(data.corsigmapSurrs_HC_P{iDiag})), 1));
        temp = median(data.corsigmapSurrs_HC_P{iDiag}(ids));
        corsigmapSurrsHC_PVerAll{iDiag} = [corsigmapSurrsHC_PVerAll{iDiag}; temp];

        % Extract upper triangular part and append for corsigmapSurrs_P_HCVer
        ids = find(triu(ones(size(data.corsigmapSurrs_P_HC{iDiag})), 1));
        temp = median(data.corsigmapSurrs_P_HC{iDiag}(ids));
        corsigmapSurrsP_HCVerAll{iDiag} = [corsigmapSurrsP_HCVerAll{iDiag}; temp];

        % Extract upper triangular part and append for corsigFwemapSurrs_HC_PVer
        ids = find(triu(ones(size(data.corsigFwemapSurrs_HC_P{iDiag})), 1));
        temp = median(data.corsigFwemapSurrs_HC_P{iDiag}(ids));
        corsigFwemapSurrsHC_PVerAll{iDiag} = [corsigFwemapSurrsHC_PVerAll{iDiag}; temp];

        % Extract upper triangular part and append for corsigFwemapSurrs_P_HCVer
        ids = find(triu(ones(size(data.corsigFwemapSurrs_P_HC{iDiag})), 1));
        temp = median(data.corsigFwemapSurrs_P_HC{iDiag}(ids));
        corsigFwemapSurrsP_HCVerAll{iDiag} = [corsigFwemapSurrsP_HCVerAll{iDiag}; temp];

           % Repeat for repsigmapSurrs_HC_PVer
        ids = find(triu(ones(size(data.repsigmapSurrs_HC_P{iDiag})), 1));
        temp = median(data.repsigmapSurrs_HC_P{iDiag}(ids));
        repsigmapSurrsHC_PVerAll{iDiag} = [repsigmapSurrsHC_PVerAll{iDiag}; temp];

        % Repeat for repsigmapSurrs_P_HCVer
        ids = find(triu(ones(size(data.repsigmapSurrs_P_HC{iDiag})), 1));
        temp = median(data.repsigmapSurrs_P_HC{iDiag}(ids));
        repsigmapSurrsP_HCVerAll{iDiag} = [repsigmapSurrsP_HCVerAll{iDiag}; temp];

        % Repeat for repsigFwemapSurrs_HC_PVer
        ids = find(triu(ones(size(data.repsigFwemapSurrs_HC_P{iDiag})), 1));
        temp = median(data.repsigFwemapSurrs_HC_P{iDiag}(ids));
        repsigFwemapSurrsHC_PVerAll{iDiag} = [repsigFwemapSurrsHC_PVerAll{iDiag}; temp];

        % Repeat for repsigFwemapSurrs_P_HCVer
        ids = find(triu(ones(size(data.repsigFwemapSurrs_P_HC{iDiag})), 1));
        temp = median(data.repsigFwemapSurrs_P_HC{iDiag}(ids));
        repsigFwemapSurrsP_HCVerAll{iDiag} = [repsigFwemapSurrsP_HCVerAll{iDiag}; temp];

      
    end
end
%%
save(['output/tmap_null_brainsmash_COMBAT',num2str(iCOMBAT),'_smooth',num2str(smoothKernel),'_ver_all.mat'],...
    'cortmapBrainsmashSurrsVerAll','corsigmapSurrsHC_PVerAll','corsigmapSurrsP_HCVerAll','corsigFwemapSurrsHC_PVerAll','corsigFwemapSurrsP_HCVerAll', ...
        'repsigmapSurrsHC_PVerAll','repsigmapSurrsP_HCVerAll','repsigFwemapSurrsHC_PVerAll','repsigFwemapSurrsP_HCVerAll');
