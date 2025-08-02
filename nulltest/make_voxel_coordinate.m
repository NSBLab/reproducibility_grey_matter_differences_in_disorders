% make the three column matrix of voxel coordinate
clear all
diag = 'psy';
nii_file=('/usr/local/spm12/matlab2021a.r7771-v1/toolbox/cat12/templates_MNI152NLin2009cAsym/Template_0_GS.nii');
mask=niftiread(['/projects/kg98/trangc/VBM/data/derivatives/s6/mask_',diag,'/mask.nii']);
linIn = find(mask==1);
[maskedtem(:,1) maskedtem(:,2) maskedtem(:,3)] = ind2sub(size(mask),linIn);
% % get xyz cordinate
% volumeInfo = spm_vol(nii_file)
% [intensityValues,xyzCoordinates ] = spm_read_vols(volumeInfo);
% voxCo = reshape(xyzCoordinates,3,113,137,113);
% voxCox = squeeze(voxCo(1,:,:,:));
% voxCoy = squeeze(voxCo(2,:,:,:));
% voxCoz = squeeze(voxCo(3,:,:,:));
% 
% maskedtem(:,1) = voxCox(mask==1);
% maskedtem(:,2) = voxCoy(mask==1);
% maskedtem(:,3) = voxCoz(mask==1);

writematrix(maskedtem,['/projects/kg98/trangc/VBM/code/nulltest/pythonProject/mnimaskedtemplate_',diag,'_index_lh.txt'],'Delimiter',' ');