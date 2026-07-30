function glm_parc_func(config, outdir, iSubdivide, randomSubdivide)
if nargin < 4
    error('Usage: glm_parc_func(config, outdir, iSubdivide, randomSubdivide)');
end
this_dir = fileparts(mfilename('fullpath'));
repo_root = fullfile(this_dir, '..', '..', '..');
addpath(this_dir);
addpath(genpath(fullfile(repo_root, 'utils')));
if ischar(config) || isstring(config)
    config = pipeline_load_config(char(config));
end
iCOMBAT = 1;
%glm parcelated maps

hemi = 'lh';
smoothkernel = 0;


inGroup = [1 2];
for iSite = 1:length(inGroup)
   metadata = readtable(fullfile(outdir,['iSubdivide_',char(num2str(iSubdivide)),'_seed2group_',char(num2str(randomSubdivide))], ...
        ['iSubdivide_',char(num2str(iSubdivide)),'_seed2group_',char(num2str(randomSubdivide)),'_group',char(num2str(inGroup(iSite))),'.txt']));
        
        if iCOMBAT==0
            qdecfolder = fullfile(outdir,['iSubdivide_',char(num2str(iSubdivide)),'_seed2group_',char(num2str(randomSubdivide))],...
            ['iSubdivide_',char(num2str(iSubdivide)),'_seed2group_',char(num2str(randomSubdivide)),'_group',char(num2str(inGroup(iSite))),'_SF']);
        load(fullfile(qdecfolder,[hemi,'.thickness.fwhm',char(num2str(smoothkernel)),'.fsaverage.mat']),'zmapDK', 'zmapSF100','zmapSF500' ,'zmapSF1000')
        
        else
            qdecfolder = fullfile(outdir,['iSubdivide_',char(num2str(iSubdivide)),'_seed2group_',char(num2str(randomSubdivide))],...
            ['iSubdivide_',char(num2str(iSubdivide)),'_seed2group_',char(num2str(randomSubdivide)),'_group',char(num2str(inGroup(iSite))),'_SF_combat']);
             load(fullfile(qdecfolder,[hemi,'.thickness.fwhm',char(num2str(smoothkernel)),'.fsaverage.mat']),'zmapDK', 'zmapSF100','zmapSF500' ,'zmapSF1000')
        
        end
        if all(metadata.sex==1) | all(metadata.sex==0)
        stat.designMatrix = table2array(metadata(:,4:5));
       else
           stat.designMatrix = table2array(metadata(:,4:6));
       end
       stat.test = 'ANCOVA';
       [fMapDK GDK]= mbm_stat_map(zmapDK', stat);
        pValueDK = ( 1 - fcdf(fMapDK, 1, height(stat.designMatrix)-width(stat.designMatrix)));
        pValueDK(pValueDK<2*10^-16) = 2*10^-16;
        zDK = sign(GDK).*norminv(1 - pValueDK/2);

        [fMapSF100 GSF100]= mbm_stat_map(zmapSF100', stat);
        pValueSF100 = ( 1 - fcdf(fMapSF100, 1, height(stat.designMatrix)-width(stat.designMatrix)));
        pValueSF100(pValueSF100<2*10^-16) = 2*10^-16;
        zSF100 = sign(GSF100).*norminv(1 - pValueSF100/2);

        [fMapSF500 GSF500] = mbm_stat_map(zmapSF500', stat);
        pValueSF500 = ( 1 - fcdf(fMapSF500, 1, height(stat.designMatrix)-width(stat.designMatrix)));
        pValueSF500(pValueSF500<2*10^-16) = 2*10^-16;
        zSF500 = sign(GSF500).*norminv(1 - pValueSF500/2);
        
        [fMapSF1000 GSF1000] = mbm_stat_map(zmapSF1000', stat);
        pValueSF1000 = ( 1 - fcdf(fMapSF1000, 1, height(stat.designMatrix)-width(stat.designMatrix)));
        pValueSF1000(pValueSF1000<2*10^-16) = 2*10^-16;
        zSF1000 = sign(GSF1000).*norminv(1 - pValueSF1000/2);
        save(fullfile(qdecfolder,[hemi,'.thickness.fwhm',char(num2str(smoothkernel)),'_glm.fsaverage.mat']),'pValueDK','pValueSF100','pValueSF500' ,'pValueSF1000','zDK','zSF100','zSF500','zSF1000')
      
    end
end