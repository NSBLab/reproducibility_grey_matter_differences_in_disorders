% create metadata and combine surface inputs for combat
clear all

smoothKernel = 0;
diag = 'AD'; %psy or AD or SCZ
hemi = 'rh';
outDir = ['/projects/kg98/trangc/VBM/data/derivatives/freesurfer/s',char(num2str(smoothKernel)),'COMBAT'];
if ~exist(outDir)
    mkdir(outDir)
end
% list of disorders
% diagString = {'HC', 'BD', 'SCA',...
%     'SCZ', 'ASD', 'MDD' };
addpath('/projects/kg98/trangc/MBM/func')
% list of dataset
dataDir = '/projects/kg98/trangc/VBM/data';
% dataFile = readtable(fullfile(dataDir,['dataset_list_SBM_',diag,'.txt']),'ReadVariableNames',false);
% dataList = dataFile.Var1;

metadata = readtable(['/home/trangc/kg98/trangc/VBM/data/metadataSBM_',diag,'.csv']);
mask = readmatrix(['/projects/kg98/trangc/atlases/Human_standard_surface/fsaverage_164k_cortex-',hemi,'_mask.txt']);
%% combine maps

for iSub = 1:height(metadata)
    if strcmp(metadata.dataset{iSub},'MBBP')
        subNameFull = metadata.subj_id{iSub};
subNameSort = ['sub-',num2str(str2num(subNameFull(5:end)))];
        map = squeeze(load_mgh(fullfile('/scratch/kg98/Toby/WHOLEMBBP/workspace', 'derivatives','freesurfer', subNameSort,'surf', [hemi,'.thickness.fwhm',char(num2str(smoothKernel)),'.fsaverage.mgh'])));
   
    else
    map = squeeze(load_mgh(fullfile(dataDir, char(metadata.dataset{iSub}), 'derivatives','freesurfer', char(metadata.subj_id(iSub)),'surf', [hemi,'.thickness.fwhm',char(num2str(smoothKernel)),'.fsaverage.mgh'])));
    end
    thickmap(:,iSub) = map(mask==1);
end

writematrix(thickmap, fullfile(outDir,[hemi,'_thickness_s',char(num2str(smoothKernel)),'_',diag,'.txt']))