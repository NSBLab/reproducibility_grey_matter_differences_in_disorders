% create metadata and combine surface inputs for combat
clear all

smoothKernel = 12;
diag = 'psy'; %'psy' or 'AD'
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
%scz sub
% sczSite = unique(metadata.site(metadata.diagnosis==4));
% sczMeta = metadata(ismember(metadata.site, sczSite) & (metadata.diagnosis==4|metadata.diagnosis==1),:);
% writetable(sczMeta, fullfile(outDir,'metadata_surface_SCZ.csv'),'Delimiter','tab');
%% combine maps

for iSub = 1:height(metadata)
    subj_id = metadata.subj_id{iSub}
    ses = metadata.ses{iSub};
    dataset = metadata.dataset{iSub};
    if strcmp(ses,'')
        mapnifti = niftiread(fullfile(dataDir, dataset, subj_id,'anat',['s',  char(num2str(smoothKernel)), 'mwp1', subj_id, '_T1w.nii']));
    map(:,iSub) = mapnifti(logical(mask));
    else
        mapnifti = niftiread(fullfile(dataDir, dataset, subj_id,ses,'anat',['s',  char(num2str(smoothKernel)), 'mwp1', subj_id, '_', ses,'_T1w.nii']));
 map(:,iSub) = mapnifti(logical(mask));
    end
end

writematrix(map, fullfile(outDir,['anat_s',char(num2str(smoothKernel)),'mwp1_T1w_masked.txt']),'Delimiter',' ');
% end