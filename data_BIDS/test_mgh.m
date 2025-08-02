dataDir = '/projects/kg98/trangc/VBM/data';
dataset = 'ASRB';
sub1 = 'sub-101001';
sub2 = 'sub-101002';

ymap = squeeze(load_mgh(fullfile(dataDir, dataset, 'derivatives','freesurfer','qdec', '4_BRIS_thick_smooth10_lh_sex_age', 'y.mgh')))';
y1 = squeeze(load_mgh(fullfile(dataDir, dataset, 'derivatives','freesurfer',sub1, 'surf', 'lh.thickness.fwhm10.fsaverage.mgh')))';
y2 = squeeze(load_mgh(fullfile(dataDir, dataset, 'derivatives','freesurfer',sub2, 'surf', 'lh.thickness.fwhm10.fsaverage.mgh')))';
