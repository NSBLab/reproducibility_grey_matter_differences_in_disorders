% %make lh mask
% mapnifti = niftiread('/projects/kg98/trangc/VBM/data/derivatives/s6/mask_psy/mask.nii');
% lh = mapnifti;
% lh(57:end,:,:) = 0;
% niftiwrite(lh,'/projects/kg98/trangc/VBM/data/derivatives/s6/mask_psy/mask_lh.nii');

parnifti = niftiread('/fs03/kg98/gchan/Atlases/Tian/Schaefer_Tian/reordered/Schaefer2018_100Parcels_7Networks_order_Tian_Subcortex_S2_MNI152NLin6Asym_1.5mm_reordered.nii.gz');