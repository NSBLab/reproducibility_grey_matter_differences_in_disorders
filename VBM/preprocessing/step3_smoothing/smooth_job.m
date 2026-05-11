%-----------------------------------------------------------------------
% Job saved on 25-Jul-2020 15:08:46 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7487)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
function smooth_job(subNifti_cell, smoothKernel)

    matlabbatch{1}.spm.spatial.smooth.data = subNifti_cell;
    matlabbatch{1}.spm.spatial.smooth.fwhm = [smoothKernel smoothKernel smoothKernel];
    matlabbatch{1}.spm.spatial.smooth.dtype = 0;
    matlabbatch{1}.spm.spatial.smooth.im = 1;
    matlabbatch{1}.spm.spatial.smooth.prefix = ['s',num2str(smoothKernel)];

spm_jobman('run',matlabbatch);
end
