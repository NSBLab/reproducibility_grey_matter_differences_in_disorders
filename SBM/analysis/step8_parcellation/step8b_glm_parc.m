clear all
iCOMBAT = 1;
%glm parcelated maps
currentPath = '/projects/kg98/trangc/MBM';
addpath(genpath(fullfile(currentPath,'func')))
addpath(fullfile(currentPath,'utils'))
addpath(fullfile(currentPath,'utils','modes'))
addpath(fullfile(currentPath,'utils','fdr_bh'))
addpath(fullfile(currentPath,'utils','PALM-master'))
addpath(fullfile(currentPath,'utils','gifti-matlab'))

hemi = 'lh';
smoothkernel = 0;
measure = 'thick';
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
datasets = readlines(fullfile(datadir,'dataset_list_SBM_psy.txt'));

for iSite = 1:length(datasets)
    datasets(iSite)

    files = dir(fullfile(datadir,datasets(iSite),'qdec*'));
    files = files(~ismember({files.name}, {'.', '..'})); % Exclude '.' and '..'

    for iFile = 1:length(files)
        % find site name
        % Split the string using '_' as the delimiter
        parts =  strsplit(files(iFile).name, '_');

        % Check if there are at least two parts
        if numel(parts) >4
            % Extract the substring between the first and second underscores
            lastpart = char(parts{5});
            diag(iFile) = str2num(lastpart(1));
            site{iFile} = [char(parts{3}),'_',char(parts{4})];
        else
            % Handle the case where there are not enough underscores
            lastpart = char(parts{4});
            diag(iFile) = str2num(lastpart(1));
            site{iFile} = char(parts{3});
        end

        qdecfile = readtable(fullfile(datadir,datasets(iSite), files(iFile).name));
        if iCOMBAT==0
            qdecfolder = fullfile(datadir,char(datasets(iSite)), 'derivatives','freesurfer','qdec',[char(num2str(diag(iFile))),'_',char(site{iFile}),'_',measure,'_smooth',char(num2str(smoothkernel)),'_',hemi,'_sex_age_SF']);
        load(fullfile(qdecfolder,[hemi,'.thickness.fwhm',char(num2str(smoothkernel)),'.fsaverage.mat']),'zmapDK', 'zmapSF100','zmapSF500' ,'zmapSF1000')
        else
            qdecfolder = fullfile(datadir,char(datasets(iSite)), 'derivatives','freesurfer','qdec',[char(num2str(diag(iFile))),'_',char(site{iFile}),'_',measure,'_smooth',char(num2str(smoothkernel)),'_',hemi,'_sex_age_SF_combat']);
        load(fullfile(qdecfolder,[hemi,'.thickness.fwhm',char(num2str(smoothkernel)),'.fsaverage.mat']),'zmapDK', 'zmapSF100','zmapSF500' ,'zmapSF1000')
        end
        if ismember(datasets(iSite),{'ABIDEI','ABIDEII'})
        stat.designMatrix = table2array(qdecfile(:,[2,4]));
       else
           stat.designMatrix = table2array(qdecfile(:,2:end));
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