function mbm_each_site_indi(dataset, site, diagnosis)

MBMdir = '/projects/kg98/trangc/MBM';
addpath(fullfile(MBMdir,'func'));
% addpath(fullfile(gitDir,'utils'));
addpath(fullfile(MBMdir,'utils','modes'))

% read MBM data that contains precalculated eigenmodes
eigfile = load(fullfile('/projects/kg98/trangc/VBM/code/freesurfer/freesurfer_holmesQC/step4_qdec/output/fsaverage_164k_midthickness-lh_emode_1000.mat'));
mask = readmatrix(fullfile('/projects/kg98/trangc/MBM/data/demo_emp', 'fsaverage_164k_cortex-lh_mask.txt'));
eig_masked = eigfile.eig(mask==1,:);

massfile = load(fullfile('/projects/kg98/trangc/VBM/code/freesurfer/freesurfer_holmesQC/step4_qdec/output/fsaverage_164k_midthickness-lh_mass_1000.mat')); % path to eigenmode file
mass_masked = massfile.mass(mask==1,mask==1);
nMode = [50:50:1000];


% MBM.maps.anatListFile = fullfile('/home/trangc/kg98/trangc/VBM/data/HCP', 'map_list.txt'); % text file comprise the list of paths to the anatomical maps
MBM.maps.anatListFile = fullfile('/projects/kg98/trangc/VBM/data', dataset,'derivatives/freesurfer/qdec', ...
     [diagnosis, '_', site, '_thick_smooth10_lh_sex_age'],'y.mgh'); % text file comprise the list of paths to the anatomical maps

MBM.maps.maskFile = fullfile('/projects/kg98/trangc/MBM/data/demo_emp', 'fsaverage_164k_cortex-lh_mask.txt'); % path to mask

MBM.stat.test = 'ANCOVA'; % statistical test
% make design matrix
make_MBM_designmat('/projects/kg98/trangc/VBM/data', dataset, [diagnosis, '_', site, '_thick_smooth10_lh_sex_age']);
MBM.stat.designFile = fullfile('/projects/kg98/trangc/VBM/data', dataset, 'derivatives','freesurfer','qdec',...
    [diagnosis, '_', site, '_thick_smooth10_lh_sex_age'],['mbmDesignMat.txt']); % path to indicator matrix

MBM.stat.nPer = 1000; % number of permutations
MBM.stat.pThr = 0.1; % threshold for tail estimation
MBM.stat.thres = 0.05; % statistical threshold to be considered significant
MBM.stat.fdr = false; % FDR correction

MBM.eig.eigFile = fullfile('/projects/kg98/trangc/VBM/code/freesurfer/freesurfer_holmesQC/step4_qdec/output/fsaverage_164k_midthickness-lh_emode_1000.mat'); % path to eigenmode file
MBM.eig.massFile = fullfile('/projects/kg98/trangc/VBM/code/freesurfer/freesurfer_holmesQC/step4_qdec/output/fsaverage_164k_midthickness-lh_mass_1000.mat'); % path to eigenmode file
MBM.eig.nEigenmode = 1000; % number of eigenmodes for analysis
MBM.eig.saveResult = true; % save the results, i.e., MBM structure
MBM.eig.resultFile = fullfile('/projects/kg98/trangc/VBM/data', dataset,'derivatives/freesurfer/qdec', ...
     [diagnosis, '_', site, '_thick_smooth10_lh_sex_age'],'mbm_uncorrected_1000mode.mat'); % folder where to save the results

MBM.plot.visualize = true; % visualise the results
MBM.plot.saveFig = true; % save the visualisation of the results
MBM.plot.figFile = fullfile('/projects/kg98/trangc/VBM/data', dataset,'derivatives/freesurfer/qdec', ...
     [diagnosis, '_', site, '_thick_smooth10_lh_sex_age'],'mbm_uncorrected_1000mode.fig'); % where to save the visualisation of the results.
MBM.plot.vtkFile = fullfile('/projects/kg98/trangc/MBM/data/demo_emp', 'fsaverage_164k_midthickness-lh.vtk'); % path to vtk file
MBM.plot.hemis = 'left'; % hemisphere to be analysed
MBM.plot.nInfluentialMode = 6; % number of most influential modes to be plotted

MBM = mbm_main(MBM);
toc
