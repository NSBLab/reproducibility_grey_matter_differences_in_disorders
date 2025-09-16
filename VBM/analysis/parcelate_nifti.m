% read and write nifti file for parcelation

mapFilename = '/home/trangc/kg98/trangc/VBM/data/COBRE/sub-40000/anat/mwp1sub-40000_T1w.nii';
data = niftiread(mapFilename);

roiFilename = '/home/trangc/kg98/trangc/atlases/Tian_subcortical/3T/Cortex-Subcortex/Schaefer2018_400Parcels_7Networks_order_Tian_Subcortex_S1.dlabel.nii';
rois = niftiread(roiFilename);

maskFilename = '/home/trangc/kg98/trangc/VBM/data/derivatives/s8/SCZ/COBRE/mask.nii';
[out, parcellatedData, zeroResult] = parcellateData(data, rois, varargin)