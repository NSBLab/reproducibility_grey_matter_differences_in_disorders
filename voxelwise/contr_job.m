%-----------------------------------------------------------------------
% Job saved on 19-Mar-2024 15:16:22 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7771)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
function contr_job(spm_file)

matlabbatch{1}.spm.stats.con.spmmat = {spm_file};
matlabbatch{1}.spm.stats.con.consess{1}.tcon.name = 'HC>P';
matlabbatch{1}.spm.stats.con.consess{1}.tcon.weights = [1 -1];
matlabbatch{1}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
matlabbatch{1}.spm.stats.con.consess{2}.tcon.name = 'HC<P';
matlabbatch{1}.spm.stats.con.consess{2}.tcon.weights = [-1 1];
matlabbatch{1}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
matlabbatch{1}.spm.stats.con.delete = 1;

 spm_jobman('run', matlabbatch)