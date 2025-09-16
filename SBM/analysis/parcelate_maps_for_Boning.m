clear all
addpath(genpath('/projects/kg98/trangc/library/BrainSpace'))

% hemi = 'lh';
% smoothkernel = 0;
% measure = 'thick';

% load annotation
% DK atlas
[tempVertices,tempLabel,colortable]=read_annotation(['/projects/kg98/trangc/VBM/data/Atypical/derivatives' ...
    '/freesurfer/fsaverage/label/lh.aparc.annot']); % change to your dir
map2colortable = [2:4 6:36];
colorcode = colortable.table(map2colortable,5);
[lia labelDK] = ismember(tempLabel, colorcode);

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




qdecfile = readtable(fullfile(datadir,datasets(iSite), files(iFile).name));

for iMap = 1:height(qdecfile)
    vermap(:,iMap) = load_mgh(fullfile(datadir,char(datasets(iSite)), 'derivatives','freesurfer',<dataset>,'surf',['lh.thickness.fwhm0.fsaverage.mgh']));

    zmapDK(:,iMap) = full2parcel(vermap(:,iMap) ,labelDK');

    zmapSF100(:,iMap) = full2parcel(vermap(:,iMap) ,labelSF100');
    zmapSF500(:,iMap) = full2parcel(vermap(:,iMap) ,labelSF500');
    zmapSF1000(:,iMap) = full2parcel(vermap(:,iMap) ,labelSF1000');

end


save(fullfile(<dir>,[hemi,'.thickness.fwhm',char(num2str(smoothkernel)),'.fsaverage.mat']),'zmapDK','zmapSF100','zmapSF500' ,'zmapSF1000')


