% List of open inputs
% Factorial design specification: Directory - cfg_files
% Factorial design specification: Group 1 scans - cfg_files
% Factorial design specification: Group 2 scans - cfg_files
% Factorial design specification: Vector - cfg_entry
% Factorial design specification: Name - cfg_entry
% Factorial design specification: Vector - cfg_entry
% Factorial design specification: Name - cfg_entry
% Factorial design specification: Vector - cfg_entry
% Factorial design specification: Name - cfg_entry
nrun = X; % enter the number of runs here
jobfile = {'/projects/kg98/trangc/VBM/code/voxelwise/factorial_design_ttest_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(9, nrun);
for crun = 1:nrun
    inputs{1, crun} = MATLAB_CODE_TO_FILL_INPUT; % Factorial design specification: Directory - cfg_files
    inputs{2, crun} = MATLAB_CODE_TO_FILL_INPUT; % Factorial design specification: Group 1 scans - cfg_files
    inputs{3, crun} = MATLAB_CODE_TO_FILL_INPUT; % Factorial design specification: Group 2 scans - cfg_files
    inputs{4, crun} = MATLAB_CODE_TO_FILL_INPUT; % Factorial design specification: Vector - cfg_entry
    inputs{5, crun} = MATLAB_CODE_TO_FILL_INPUT; % Factorial design specification: Name - cfg_entry
    inputs{6, crun} = MATLAB_CODE_TO_FILL_INPUT; % Factorial design specification: Vector - cfg_entry
    inputs{7, crun} = MATLAB_CODE_TO_FILL_INPUT; % Factorial design specification: Name - cfg_entry
    inputs{8, crun} = MATLAB_CODE_TO_FILL_INPUT; % Factorial design specification: Vector - cfg_entry
    inputs{9, crun} = MATLAB_CODE_TO_FILL_INPUT; % Factorial design specification: Name - cfg_entry
end
spm('defaults', 'PET');
spm_jobman('run', jobs, inputs{:});
