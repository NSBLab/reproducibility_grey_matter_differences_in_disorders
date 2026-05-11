%-----------------------------------------------------------------------
% Job saved on 24-Jul-2020 20:14:55 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7487)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
function estimate_tiv_job(subReport_cell, tiv_filename)

    matlabbatch{1}.spm.tools.cat.tools.calcvol.data_xml = subReport_cell;
    matlabbatch{1}.spm.tools.cat.tools.calcvol.calcvol_TIV = 1;
    matlabbatch{1}.spm.tools.cat.tools.calcvol.calcvol_name = tiv_filename;

spm_jobman('run',matlabbatch);
end