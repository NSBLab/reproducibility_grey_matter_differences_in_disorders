%-----------------------------------------------------------------------
% Job saved on 25-Jul-2020 19:05:10 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7487)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
function model_estimation_job(outDir)

matlabbatch{1}.spm.stats.fmri_est.spmmat = {outDir};
matlabbatch{1}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{1}.spm.stats.fmri_est.method.Classical = 1;

spm_jobman('run',matlabbatch);
