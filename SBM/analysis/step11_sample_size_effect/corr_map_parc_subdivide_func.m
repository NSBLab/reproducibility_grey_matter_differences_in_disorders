% read all the z-maps and correlate them
function corr_map_parc_subdivide_func(config, outdir, iSubdivide, randomSubdivide)
if nargin < 4
    error('Usage: corr_map_parc_subdivide_func(config, outdir, iSubdivide, randomSubdivide)');
end
this_dir = fileparts(mfilename('fullpath'));
repo_root = fullfile(this_dir, '..', '..', '..');
addpath(this_dir);
addpath(genpath(fullfile(repo_root, 'utils')));
if ischar(config) || isstring(config)
    config = pipeline_load_config(char(config));
end
iCOMBAT = 1;
smoothkernel = 0;
thres = 0.05;
hemi = 'lh';


inGroup = [1 2];
for iSite = 1:length(inGroup)

    if iCOMBAT==0
        qdecfolder = fullfile(outdir,['iSubdivide_',char(num2str(iSubdivide)),'_seed2group_',char(num2str(randomSubdivide))],...
            ['iSubdivide_',char(num2str(iSubdivide)),'_seed2group_',char(num2str(randomSubdivide)),'_group',char(num2str(inGroup(iSite))),'_SF']);
        load(fullfile(qdecfolder,[hemi,'.thickness.fwhm',char(num2str(smoothkernel)),'_glm.fsaverage.mat']),'pValueDK','pValueSF100','pValueSF500' ,'pValueSF1000','zDK','zSF100','zSF500','zSF1000')

    else
        qdecfolder = fullfile(outdir,['iSubdivide_',char(num2str(iSubdivide)),'_seed2group_',char(num2str(randomSubdivide))],...
            ['iSubdivide_',char(num2str(iSubdivide)),'_seed2group_',char(num2str(randomSubdivide)),'_group',char(num2str(inGroup(iSite))),'_SF_combat']);
        load(fullfile(qdecfolder,[hemi,'.thickness.fwhm',char(num2str(smoothkernel)),'_glm.fsaverage.mat']),'pValueDK','pValueSF100','pValueSF500' ,'pValueSF1000','zDK','zSF100','zSF500','zSF1000')

    end

    map.zmapDK(iSite,:) = zDK;
    map.zmapSF100(iSite,:) = zSF100;
    map.zmapSF500(iSite,:) = zSF500;
    map.zmapSF1000(iSite,:) = zSF1000;
    map.sigmapDK(iSite,:) = double(pValueDK <=thres);
    map.sigmapSF100(iSite,:) = double(pValueSF100 <=thres);
    map.sigmapSF500(iSite,:) = double(pValueSF500 <=thres);
    map.sigmapSF1000(iSite,:) = double(pValueSF1000 <=thres);
end



corDiagDK = corr(map.zmapDK');
corDiagSF100 = corr(map.zmapSF100');
corDiagSF500 = corr(map.zmapSF500');
corDiagSF1000 = corr(map.zmapSF1000');
corSigDK = bin_corr_mat_account_zero(map.sigmapDK');
corSigSF100 = bin_corr_mat_account_zero(map.sigmapSF100');
corSigSF500 = bin_corr_mat_account_zero(map.sigmapSF500');
corSigSF1000 = bin_corr_mat_account_zero(map.sigmapSF1000');
repSigDK = replication_mat(map.sigmapDK');
repSigSF100 = replication_mat(map.sigmapSF100');
repSigSF500 = replication_mat(map.sigmapSF500');
repSigSF1000 = replication_mat(map.sigmapSF1000');



save(fullfile(outdir,['iSubdivide_',char(num2str(iSubdivide)),'_seed2group_',char(num2str(randomSubdivide))],'corr_furface_SF.mat'))
