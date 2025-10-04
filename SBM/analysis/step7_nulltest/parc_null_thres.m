clear all
addpath(genpath('/projects/kg98/trangc/library/BrainSpace'))
addpath(genpath('/projects/kg98/trangc/library'))
hemi = 'lh';
iCOMBAT = '1';
smoothKernel = 10;
load(['eigenStruct_',hemi,'.mat']); %load structure that contains eigentrapping because the mask was changed to fix the 164k mesh error
% % DK atlas
% [tempVertices,tempLabel,colortable]=read_annotation(['/projects/kg98/trangc/VBM/data/Atypical/derivatives' ...
%     '/freesurfer/fsaverage/label/',hemi,'.aparc.annot']);
% map2colortable = [2:4 6:36];
% colorcode = colortable.table(map2colortable,5);
% [lia labelDK] = ismember(tempLabel, colorcode);
% 
% % Schaefer atlas
% [tempVertices,tempLabel,colortable]=read_annotation(['/projects/kg98/trangc/atlases/Human_cortical/Schaefer/fsaverage/label/',hemi,'.Schaefer2018_100Parcels_7Networks_order.annot']);
% map2colortable = [2:51];
% colorcode = colortable.table(map2colortable,5);
% [lia labelSF100] = ismember(tempLabel, colorcode);
% 
% [tempVertices,tempLabel,colortable]=read_annotation(['/projects/kg98/trangc/atlases/Human_cortical/Schaefer/fsaverage/label/',hemi,'.Schaefer2018_500Parcels_7Networks_order.annot']);
% map2colortable = [2:251];
% colorcode = colortable.table(map2colortable,5);
% [lia labelSF500] = ismember(tempLabel, colorcode);
% 
% [tempVertices,tempLabel,colortable]=read_annotation(['/projects/kg98/trangc/atlases/Human_cortical/Schaefer/fsaverage/label/',hemi,'.Schaefer2018_1000Parcels_7Networks_order.annot']);
% map2colortable = [2:501];
% colorcode = colortable.table(map2colortable,5);
% [lia labelSF1000] = ismember(tempLabel, colorcode);


datadir = '/scratch2/kg98/trangc/VBM/data/eigentrap';
datasets = dir(datadir);
datasets = datasets(~ismember({datasets.name}, {'.', '..'})); % Exclude '.' and '..'

for iSite = 1:length(datasets)
    datasets(iSite).name

    files = dir(fullfile(datadir,datasets(iSite).name,'qdec*newthres.mat'));
    files = files(~ismember({files.name}, {'.', '..'})); % Exclude '.' and '..'
    for iFile = 1:length(files)
        % find site name
        % Split the string using '_' as the delimiter
        parts =  strsplit(files(iFile).name, '_');

        % Check if there are at least two parts
        if numel(parts) >9
            % Extract the substring between the first and second underscores
            diag(iFile) = str2num(parts{5});
        else
            % Handle the case where there are not enough underscores
            diag(iFile) = str2num(parts{4});
        end
    end
    uniqueDiag = unique(diag);
    nDiag = length(uniqueDiag);
    for iDiag = 1:nDiag
        filesDiag = dir(fullfile(datadir,datasets(iSite).name,['qdec_table_*_',char(num2str(uniqueDiag(iDiag))),'_combat',iCOMBAT,'_',hemi,'_smooth',char(num2str(smoothKernel)),'*_newthres.mat']));
        filesDiag = filesDiag(~ismember({filesDiag.name}, {'.', '..'})); % Exclude '.' and '..'
        mapStartIn = 1;
        % Loop through files
        for iFile = 1:length(filesDiag)

            load(fullfile(filesDiag(iFile).folder,filesDiag(iFile).name),'sigmapSurrsHC_P','sigmapSurrsP_HC','sigFdrmapSurrsHC_P','sigFdrmapSurrsP_HC');
            mapEndIn = mapStartIn + width(sigmapSurrsHC_P) -1 ;
            % zmapSurrsFull(:,s.mask==1) = zmapSurrs';

            % zmapSurrsDK(:,mapStartIn:mapEndIn) = full2parcel(zmapSurrsFull,labelDK');
            % zmapSurrsSF100(:,mapStartIn:mapEndIn) = full2parcel(zmapSurrsFull,labelSF100');
            % zmapSurrsSF500(:,mapStartIn:mapEndIn) = full2parcel(zmapSurrsFull,labelSF500');
            % zmapSurrsSF1000(:,mapStartIn:mapEndIn) = full2parcel(zmapSurrsFull,labelSF1000');
            % zmapSurrsVer(:,mapStartIn:mapEndIn) = round(zmapSurrsFull',5);

            sigmapSurrsHC_PFull(:,s.mask==1) = sigmapSurrsHC_P';
            sigmapSurrsP_HCFull(:,s.mask==1) = sigmapSurrsP_HC';
           sigFdrmapSurrsHC_PFull(:,s.mask==1) = sigFdrmapSurrsHC_P';
            sigFdrmapSurrsP_HCFull(:,s.mask==1) = sigFdrmapSurrsP_HC';

            % sigmapSurrsDK(:,mapStartIn:mapEndIn) = full2parcel(sigmapSurrsFull,labelDK');
            % sigmapSurrsSF100(:,mapStartIn:mapEndIn) = full2parcel(sigmapSurrsFull,labelSF100');
            % sigmapSurrsSF500(:,mapStartIn:mapEndIn) = full2parcel(sigmapSurrsFull,labelSF500');
            % sigmapSurrsSF1000(:,mapStartIn:mapEndIn) = full2parcel(sigmapSurrsFull,labelSF1000');
            sigmapSurrsHC_PVer(:,mapStartIn:mapEndIn) = sigmapSurrsHC_PFull';
            sigmapSurrsP_HCVer(:,mapStartIn:mapEndIn) = sigmapSurrsP_HCFull';
            sigFdrmapSurrsHC_PVer(:,mapStartIn:mapEndIn) = sigFdrmapSurrsHC_PFull';
            sigFdrmapSurrsP_HCVer(:,mapStartIn:mapEndIn) = sigFdrmapSurrsP_HCFull';

            mapStartIn = mapStartIn + width(sigmapSurrsHC_P) ;

        end
        namepart = filesDiag(1).name;
        % save(fullfile(datadir,datasets(iSite).name,['parcMap_',namepart(1:end-6),'.mat']), "zmapSurrsSF100","zmapSurrsSF500","zmapSurrsSF1000","zmapSurrsDK");
        % save(fullfile(datadir,datasets(iSite).name,['verMap_',namepart(1:end-6),'.mat']), "zmapSurrsVer");
        % save(fullfile(datadir,datasets(iSite).name,['parcThresMap_',namepart(1:end-6),'.mat']), "sigmapSurrsSF100","sigmapSurrsSF500","sigmapSurrsSF1000","sigmapSurrsDK");
        save(fullfile(datadir,datasets(iSite).name,['verThresMap_',namepart(1:end-6),'_newthres.mat']), ...
            "sigmapSurrsHC_PVer", "sigmapSurrsP_HCVer","sigFdrmapSurrsHC_PVer","sigFdrmapSurrsP_HCVer");

        clear sigmapSurrsHC_PFull  sigmapSurrsP_HCFull sigFdrmapSurrsHC_PFull sigFdrmapSurrsP_HCFull sigmapSurrsHC_PVer sigmapSurrsP_HCVer sigFdrmapSurrsHC_PVer sigFdrmapSurrsP_HCVer 
    end
    clear diag
end