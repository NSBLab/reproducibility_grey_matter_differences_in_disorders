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

% % find all sites
% datadir = '/projects/kg98/trangc/VBM/code/freesurfer/freesurfer_holmesQC/step4_qdec/output';
% datasets = dir(datadir);
% datasets = datasets(~ismember({datasets.name}, {'.', '..'})); % Exclude '.' and '..'



%%

corzmapBrainsmashSurrsVerAll = cell(1,6);

%%
for iDiag = 1:length(diagString)-1


    for iNull = 1:nNull
        load (['output/corr_null_zmap_brainsmash_combat',num2str(iCOMBAT),...
            '_smooth', char(num2str(smoothKernel)), '_', char(num2str(iNull)), '.mat'],'corNull');
        
        ids=find(triu(ones(size(corNull{iDiag})),1));
        temp = corNull{iDiag}(ids);
        corzmapBrainsmashSurrsVerAll{iDiag} = [corNull{iDiag}; temp];

      
    end
end
%%
save(['output/zmap_null_brainsmash_COMBAT',num2str(iCOMBAT),'_',hemi,'_smooth',num2str(smoothKernel),'_ver_all.mat'],...
    'corzmapBrainsmashSurrsVerAll');
