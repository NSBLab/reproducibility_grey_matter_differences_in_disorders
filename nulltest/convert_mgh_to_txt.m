addpath('/home/trangc/kg98/trangc/MBM/utils/')
mghmap = load_mgh('/home/trangc/kg98/trangc/VBM/data/HCP/derivatives/freesurfer/sub-1001/surf/lh.thickness.fsaverage.mgh');
writematrix(mghmap,'HCP_thickness_sub-1001.txt');