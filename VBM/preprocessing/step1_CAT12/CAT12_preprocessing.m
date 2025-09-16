% List of open inputs
% CAT12: Segmentation: Volumes - cfg_files
nrun = X; % enter the number of runs here
jobfile = {'/home/trangc/kg98/trangc/VBM/code/preprocessing/CAT12_preprocessing_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(1, nrun);
for crun = 1:nrun
    inputs{1, crun} = MATLAB_CODE_TO_FILL_INPUT; % CAT12: Segmentation: Volumes - cfg_files
end
spm('defaults', 'PET');
spm_jobman('run', jobs, inputs{:});
