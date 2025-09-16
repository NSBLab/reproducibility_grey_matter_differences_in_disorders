% create metadata and combine surface inputs for combat
clear all

smoothKernel = 10;
outDir = ['/scratch/kg98/trangc/VBM/data/derivatives/freesurfer/s',char(num2str(smoothKernel)),'COMBAT'];
dataDir = fullfile('/projects','kg98','trangc','VBM','data');
metadata = readtable(fullfile(outDir,'metadata_AD.csv'),'Delimiter','tab');

 %% combine maps
thickmap = readmatrix( fullfile(outDir,['thickness_s',char(num2str(smoothKernel)),'_combat_AD.txt']));
 for iSub = 1:height(metadata)
     [vol, M, mr_parms, volsz] = load_mgh(fullfile(dataDir, char(metadata.dataset{iSub}), 'derivatives','freesurfer', char(metadata.fsid(iSub)),'surf', ['lh.thickness.fwhm',char(num2str(smoothKernel)),'.fsaverage.mgh']));

     save_mgh(thickmap(:,iSub),fullfile(dataDir, char(metadata.dataset{iSub}), 'derivatives','freesurfer', char(metadata.fsid(iSub)),'surf', ['lh.thickness.fwhm',char(num2str(smoothKernel)),'.fsaverage.combat.mgh']), M, mr_parms);
 end
