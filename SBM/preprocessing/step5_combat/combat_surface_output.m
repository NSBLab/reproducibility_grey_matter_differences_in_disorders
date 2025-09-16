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


metadata = readtable(['/home/trangc/kg98/trangc/VBM/data/metadataSBM_',diag,'.csv']);
mask = readmatrix(['/projects/kg98/trangc/atlases/Human_standard_surface/fsaverage_164k_cortex-',hemi,'_mask.txt']);


combatMap = readmatrix( fullfile(outDir,[hemi,'_thickness_s',char(num2str(smoothKernel)),'_',diag,'_combat.txt']));
unmaskedCombatMap(mask==1,:) = combatMap;

for iSub = 1:height(metadata)
    
    if strcmp(metadata.dataset{iSub},'MBBP')
        subNameFull = metadata.subj_id{iSub};
subNameSort = ['sub-',num2str(str2num(subNameFull(5:end)))];
        [vol, M, mr_parms, volsz] = load_mgh(fullfile('/scratch/kg98/Toby/WHOLEMBBP/workspace', 'derivatives','freesurfer', subNameSort,'surf', [hemi,'.thickness.fwhm',char(num2str(smoothKernel)),'.fsaverage.mgh']));
   mkdir(fullfile(dataDir, char(metadata.dataset{iSub}), 'derivatives','freesurfer', char(metadata.subj_id(iSub)),'surf'))
    else
    [vol, M, mr_parms, volsz] = load_mgh(fullfile(dataDir, char(metadata.dataset{iSub}), 'derivatives','freesurfer', char(metadata.subj_id(iSub)),'surf', [hemi,'.thickness.fwhm',char(num2str(smoothKernel)),'.fsaverage.mgh']));
    
    end
    if strcmp(diag,'SCZ')
        fname = fullfile(dataDir, char(metadata.dataset{iSub}), 'derivatives','freesurfer', char(metadata.subj_id(iSub)),'surf', [hemi,'.thickness.fwhm',char(num2str(smoothKernel)),'.fsaverage_combat_',diag,'.mgh']);
   
    else
    fname = fullfile(dataDir, char(metadata.dataset{iSub}), 'derivatives','freesurfer', char(metadata.subj_id(iSub)),'surf', [hemi,'.thickness.fwhm',char(num2str(smoothKernel)),'.fsaverage_combat.mgh']);
    end
    save_mgh(unmaskedCombatMap(:,iSub), fname, M, mr_parms);
   
 end