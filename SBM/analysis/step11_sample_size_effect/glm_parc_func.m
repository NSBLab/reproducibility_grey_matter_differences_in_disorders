function glm_parc_func(outdir, iSubdivide, randomSubdivide)
iCOMBAT = 1;
%glm parcelated maps
currentPath = '/projects/kg98/trangc/MBM';
addpath(genpath(fullfile(currentPath,'func')))
addpath(fullfile(currentPath,'utils'))
addpath(fullfile(currentPath,'utils','modes'))
addpath(fullfile(currentPath,'utils','fdr_bh'))
addpath(fullfile(currentPath,'utils','PALM-master'))
addpath(fullfile(currentPath,'utils','gifti-matlab'))
addpath(genpath('/projects/kg98/trangc/library/BrainSpace'))
addpath(genpath('/projects/kg98/trangc/library'))

hemi = 'lh';
smoothkernel = 0;

% Schaefer atlas
[tempVertices,tempLabel,colortable]=read_annotation(['/projects/kg98/trangc/atlases/Human_cortical/Schaefer/fsaverage/label/lh.Schaefer2018_100Parcels_7Networks_order.annot']);
map2colortable = [2:51];
colorcode = colortable.table(map2colortable,5);
[lia labelSF100] = ismember(tempLabel, colorcode);

[tempVertices,tempLabel,colortable]=read_annotation(['/projects/kg98/trangc/atlases/Human_cortical/Schaefer/fsaverage/label/lh.Schaefer2018_500Parcels_7Networks_order.annot']);
map2colortable = [2:251];
colorcode = colortable.table(map2colortable,5);
[lia labelSF500] = ismember(tempLabel, colorcode);

[tempVertices,tempLabel,colortable]=read_annotation(['/projects/kg98/trangc/atlases/Human_cortical/Schaefer/fsaverage/label/lh.Schaefer2018_1000Parcels_7Networks_order.annot']);
map2colortable = [2:501];
colorcode = colortable.table(map2colortable,5);
[lia labelSF1000] = ismember(tempLabel, colorcode);


datadir = '/projects/kg98/trangc/VBM/data';


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