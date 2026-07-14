%-----------------------------------------------------------------------
% Job saved on 19-Mar-2024 21:41:46 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7771)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
function report_thres_job(spm_file)
matlabbatch{1}.spm.stats.results.spmmat = {spm_file};
matlabbatch{1}.spm.stats.results.conspec(1).titlestr = '';
matlabbatch{1}.spm.stats.results.conspec(1).contrasts = 1;
matlabbatch{1}.spm.stats.results.conspec(1).threshdesc = 'none';
matlabbatch{1}.spm.stats.results.conspec(1).thresh = 0.05;
matlabbatch{1}.spm.stats.results.conspec(1).extent = 0;
matlabbatch{1}.spm.stats.results.conspec(1).conjunction = 1;
matlabbatch{1}.spm.stats.results.conspec(1).mask.none = 1;
matlabbatch{1}.spm.stats.results.units = 1;
matlabbatch{1}.spm.stats.results.conspec(2).titlestr = '';
matlabbatch{1}.spm.stats.results.conspec(2).contrasts = 2;
matlabbatch{1}.spm.stats.results.conspec(2).threshdesc = 'none';
matlabbatch{1}.spm.stats.results.conspec(2).thresh = 0.05;
matlabbatch{1}.spm.stats.results.conspec(2).extent = 0;
matlabbatch{1}.spm.stats.results.conspec(2).conjunction = 1;
matlabbatch{1}.spm.stats.results.conspec(2).mask.none = 1;
matlabbatch{1}.spm.stats.results.export{1}.tspm.basename = 'thres';
matlabbatch{1}.spm.stats.results.export{2}.binary.basename = 'binary';

spm_jobman('run',matlabbatch);
