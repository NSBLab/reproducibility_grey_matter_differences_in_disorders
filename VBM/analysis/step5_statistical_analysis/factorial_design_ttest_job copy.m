 %-----------------------------------------------------------------------
% Job saved on 24-Jul-2020 20:19:07 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7487)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
function factorial_design_ttest_job(outDir, hcCell, patCell, age, sex, tiv, maskFolder)


    matlabbatch{1}.spm.stats.factorial_design.dir = {outDir};
    matlabbatch{1}.spm.stats.factorial_design.des.t2.scans1 = hcCell;
    matlabbatch{1}.spm.stats.factorial_design.des.t2.scans2 = patCell;
    matlabbatch{1}.spm.stats.factorial_design.des.t2.dept = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.t2.variance = 1;
    matlabbatch{1}.spm.stats.factorial_design.des.t2.gmsca = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.t2.ancova = 0;
    matlabbatch{1}.spm.stats.factorial_design.cov(1).c = age;
    matlabbatch{1}.spm.stats.factorial_design.cov(1).cname = 'age';
    matlabbatch{1}.spm.stats.factorial_design.cov(1).iCFI = 1;
    matlabbatch{1}.spm.stats.factorial_design.cov(1).iCC = 1;
    matlabbatch{1}.spm.stats.factorial_design.cov(2).c = sex;
    matlabbatch{1}.spm.stats.factorial_design.cov(2).cname = 'sex';
    matlabbatch{1}.spm.stats.factorial_design.cov(2).iCFI = 1;
    matlabbatch{1}.spm.stats.factorial_design.cov(2).iCC = 1;
    matlabbatch{1}.spm.stats.factorial_design.cov(3).c = tiv;
    matlabbatch{1}.spm.stats.factorial_design.cov(3).cname = 'tiv';
    matlabbatch{1}.spm.stats.factorial_design.cov(3).iCFI = 1;
    matlabbatch{1}.spm.stats.factorial_design.cov(3).iCC = 1;
    matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
    %matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
	% matlabbatch{1}.spm.stats.factorial_design.masking.tm.tma.athresh = 0.1;
    matlabbatch{1}.spm.stats.factorial_design.masking.im = 0;
    matlabbatch{1}.spm.stats.factorial_design.masking.em = {[maskFolder,'mask.nii,1']};
    matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;

spm_jobman('run',matlabbatch);
