% create metadata and combine surface inputs for combat
clear all

smoothKernel = 6;
diag = 'psy';
dataDir = '/projects/kg98/trangc/VBM/data';
demoDir = ['/projects/kg98/trangc/VBM/data/derivatives/s',char(num2str(smoothKernel)),'/mask_',diag,'/'];
outDir = ['/projects/kg98/trangc/VBM/data/derivatives/s',char(num2str(smoothKernel)),'COMBAT/mask_',diag];
if ~exist(outDir)
    mkdir(outDir)
end
addpath('/projects/kg98/trangc/MBM/func')

metadataFilename = ['/projects/kg98/trangc/VBM/data/metadataVBM_',diag,'.csv'];
metacombat = [dataDir, '/metadataVBM_',diag,'.csv'];
% copyfile(metadataFilename, metacombat);
opts = detectImportOptions(metadataFilename);
opts = setvaropts(opts,'ses','FillValue','');
metadata = readtable(metadataFilename, opts);
mask = niftiread(fullfile(demoDir,'mask.nii'));
copyfile(fullfile(demoDir,'mask.nii'),fullfile(outDir,'mask.nii'))


combatMap = readmatrix( fullfile(outDir,['anat_s',char(num2str(smoothKernel)),'mwp1_T1w_masked_combat.txt']));
%% combine maps

for iSub = 1:height(metadata)
    mapnifti = zeros(size(mask));
    subj_id = metadata.subj_id{iSub}
    ses = metadata.ses{iSub};
    dataset = metadata.dataset{iSub};
    mapnifti(mask==1) = combatMap(:,iSub);
    if strcmp(ses,'')
        mapinfo = niftiinfo(fullfile(dataDir, dataset, subj_id,'anat',['s',  char(num2str(smoothKernel)), 'mwp1', subj_id, '_T1w.nii']));
        niftiwrite(single(mapnifti), fullfile(dataDir, dataset, subj_id,'anat',['s',  char(num2str(smoothKernel)), 'mwp1', subj_id, '_T1w_combat.nii']),mapinfo);
    
    else
        mapinfo = niftiinfo(fullfile(dataDir, dataset, subj_id,ses,'anat',['s',  char(num2str(smoothKernel)), 'mwp1', subj_id, '_', ses,'_T1w.nii']));
      niftiwrite(single(mapnifti),fullfile(dataDir, dataset, subj_id,ses,'anat',['s',  char(num2str(smoothKernel)), 'mwp1', subj_id, '_', ses,'_T1w_combat.nii']),mapinfo);

    end
end

