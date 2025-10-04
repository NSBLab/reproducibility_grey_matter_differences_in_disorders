clear all
addpath(genpath('/projects/kg98/trangc/library/BrainSpace'))
addpath(genpath('/projects/kg98/trangc/library'))
hemi = 'lh';
iCOMBAT = '1';
measureShort = 'thick';
smoothKernel = 10;
thres=0.05;
dataDir = '/projects/kg98/trangc/VBM/data';
load(['eigenStruct_',hemi,'.mat']); %load structure that contains eigentrapping because the mask was changed to fix the 164k mesh error
% DK atlas
[tempVertices,tempLabel,colortable]=read_annotation(['/projects/kg98/trangc/VBM/data/Atypical/derivatives' ...
    '/freesurfer/fsaverage/label/',hemi,'.aparc.annot']);
map2colortable = [2:4 6:36];
colorcode = colortable.table(map2colortable,5);
[lia labelDK] = ismember(tempLabel, colorcode);

% Schaefer atlas
[tempVertices,tempLabel,colortable]=read_annotation(['/projects/kg98/trangc/atlases/Human_cortical/Schaefer/fsaverage/label/',hemi,'.Schaefer2018_100Parcels_7Networks_order.annot']);
map2colortable = [2:51];
colorcode = colortable.table(map2colortable,5);
[lia labelSF100] = ismember(tempLabel, colorcode);

[tempVertices,tempLabel,colortable]=read_annotation(['/projects/kg98/trangc/atlases/Human_cortical/Schaefer/fsaverage/label/',hemi,'.Schaefer2018_500Parcels_7Networks_order.annot']);
map2colortable = [2:251];
colorcode = colortable.table(map2colortable,5);
[lia labelSF500] = ismember(tempLabel, colorcode);

[tempVertices,tempLabel,colortable]=read_annotation(['/projects/kg98/trangc/atlases/Human_cortical/Schaefer/fsaverage/label/',hemi,'.Schaefer2018_1000Parcels_7Networks_order.annot']);
map2colortable = [2:501];
colorcode = colortable.table(map2colortable,5);
[lia labelSF1000] = ismember(tempLabel, colorcode);

filename = '/projects/kg98/trangc/VBM/data/metadataSBM.csv';  % Change this to the path of your CSV file
data = readtable(filename);
data.site_string(strcmp(data.site_string,'Signa HDxt')==1) = {'Signa_HDxt'};

datadir = '/scratch2/kg98/trangc/VBM/data/eigentrap';
datasets = dir(datadir);
datasets = datasets(~ismember({datasets.name}, {'.', '..'})); % Exclude '.' and '..'

for iSite = 1:length(datasets)
    datasets(iSite).name

    files = dir(fullfile(datadir,datasets(iSite).name,'qdec*'));
    files = files(~ismember({files.name}, {'.', '..'})); % Exclude '.' and '..'
    for iFile = 1:length(files)
        % find site name
        % Split the string using '_' as the delimiter
        parts =  strsplit(files(iFile).name, '_');

        % Check if there are at least two parts
        if numel(parts) >8
            % Extract the substring between the first and second underscores
            diag(iFile) = str2num(parts{5});
            siteName{iFile} = [parts{3},'_',parts{4}];

        else
            % Handle the case where there are not enough underscores
            diag(iFile) = str2num(parts{4});
            siteName{iFile} = parts{3};
        end
    end
    uniqueDiag = unique(diag);
    nDiag = length(uniqueDiag);
    uniquesiteName = unique(siteName);
    datasetName = unique(data.dataset(strcmp(data.site_string,uniquesiteName)==1));
    clear diag siteName

    for iDiag = 1:nDiag
        if iCOMBAT == 0
            qdecfolder = fullfile(dataDir,datasetName{1}, 'derivatives','freesurfer','qdec',...
                [char(num2str(uniqueDiag(iDiag))),'_',uniquesiteName{1},'_',measureShort,'_smooth',char(num2str(smoothKernel)),'_',hemi,'_sex_age_SF']);
        else
            qdecfolder = fullfile(dataDir,datasetName{1}, 'derivatives','freesurfer','qdec',...
                [char(num2str(uniqueDiag(iDiag))),'_',uniquesiteName{1},'_',measureShort,'_smooth',char(num2str(smoothKernel)),'_',hemi,'_sex_age_SF_combat']);
        end

        load(fullfile(qdecfolder,[hemi,'.thickness.fwhm',char(num2str(smoothKernel)),'_glm.fsaverage.mat']),'pValueDK','pValueSF100','pValueSF500' ,'pValueSF1000')

        sigmapDK= double(pValueDK <=thres);
        sigmapSF100 = double(pValueSF100 <=thres);
        sigmapSF500 = double(pValueSF500 <=thres);
        sigmapSF1000 = double(pValueSF1000 <=thres);
        % Count number of significant points
        N_DK = sum(sigmapDK);
        N_SF100 = sum(sigmapSF100);
        N_SF500 = sum(sigmapSF500);
        N_SF1000 = sum(sigmapSF1000);

        % % Initialize sigsurr as zeros
        % sigmapSurrsDK = zeros(size(sigmapDK));
        % sigmapSurrsSF100 = zeros(size(sigmapSF100));
        % sigmapSurrsSF500 = zeros(size(sigmapSF500));
        % sigmapSurrsSF1000 = zeros(size(sigmapSF1000));


        filesDiag = dir(fullfile(datadir,datasets(iSite).name,['qdec_table_*_',char(num2str(uniqueDiag(iDiag))),'_combat',iCOMBAT,'_',hemi,'_smooth',char(num2str(smoothKernel)),'*.mat']));
        filesDiag = filesDiag(~ismember({filesDiag.name}, {'.', '..'})); % Exclude '.' and '..'
        mapStartIn = 1;
        % Loop through files
        for iFile = 1:length(filesDiag)



            load(fullfile(filesDiag(iFile).folder,filesDiag(iFile).name),'zmapSurrs','sigmapSurrs_HC_P','sigmapSurrs_P_HC','sigFdrmapSurrs_HC_P','sigFdrmapSurrs_P_HC');
            nSur = width(zmapSurrs);
            mapEndIn = mapStartIn + nSur -1 ;
            zmapSurrsFull(:,s.mask==1) = zmapSurrs';

            zmapSurrsDK(:,mapStartIn:mapEndIn) = full2parcel(zmapSurrsFull,labelDK');
            zmapSurrsSF100(:,mapStartIn:mapEndIn) = full2parcel(zmapSurrsFull,labelSF100');
            zmapSurrsSF500(:,mapStartIn:mapEndIn) = full2parcel(zmapSurrsFull,labelSF500');
            zmapSurrsSF1000(:,mapStartIn:mapEndIn) = full2parcel(zmapSurrsFull,labelSF1000');

            sigmapSurrsHC_PFull(:,s.mask==1) = sigmapSurrs_HC_P';
            sigmapSurrsP_HCFull(:,s.mask==1) = sigmapSurrs_P_HC';
            sigFdrmapSurrsHC_PFull(:,s.mask==1) = sigFdrmapSurrs_HC_P';
            sigFdrmapSurrsP_HCFull(:,s.mask==1) = sigFdrmapSurrs_P_HC';


            % Find indices of the N largest values in zmap
            [~, idx_sorted_DK] = sort( zmapSurrsDK, 'descend');
            top_indices_DK = idx_sorted_DK(1:N_DK,:);
            [~, idx_sorted_SF100] = sort( zmapSurrsSF100, 'descend');
            top_indices_SF100 = idx_sorted_SF100(1:N_SF100,:);
            [~, idx_sorted_SF500] = sort( zmapSurrsSF500, 'descend');
            top_indices_SF500 = idx_sorted_SF500(1:N_SF500,:);
            [~, idx_sorted_SF1000] = sort( zmapSurrsSF1000, 'descend');
            top_indices_SF1000 = idx_sorted_SF1000(1:N_SF1000,:);

            % Set the top N points to 1
            sigmapSurrsDK(:,mapStartIn:mapEndIn) = zeros(length(sigmapDK),nSur);

            sigmapSurrsSF100(:,mapStartIn:mapEndIn) = zeros(length(sigmapSF100),nSur);

            sigmapSurrsSF500(:,mapStartIn:mapEndIn) = zeros(length(sigmapSF500),nSur);

            sigmapSurrsSF1000(:,mapStartIn:mapEndIn) = zeros(length(sigmapSF1000),nSur);

            for i = mapStartIn:mapEndIn
                sigmapSurrsDK(top_indices_DK(:,i),i) = 1;
                sigmapSurrsSF100(top_indices_SF100(:,i),i) = 1;
                sigmapSurrsSF500(top_indices_SF500(:,i),i) = 1;
                sigmapSurrsSF1000(top_indices_SF1000(:,i),i) = 1;
            end


            % % read and combine zmaps at vertice level
            % zmapSurrsVer(:,mapStartIn:mapEndIn) = round(zmapSurrsFull',5);
            % sigmapSurrsHC_PVer(:,mapStartIn:mapEndIn) = sigmapSurrsHC_PFull';
            % sigmapSurrsP_HCVer(:,mapStartIn:mapEndIn) = sigmapSurrsP_HCFull';
            % sigFdrmapSurrsHC_PVer(:,mapStartIn:mapEndIn) = sigFdrmapSurrsHC_PFull';
            % sigFdrmapSurrsP_HCVer(:,mapStartIn:mapEndIn) = sigFdrmapSurrsP_HCFull';

            mapStartIn = mapStartIn + width(zmapSurrs) ;

        end
        namepart = filesDiag(1).name;
        save(fullfile(datadir,datasets(iSite).name,['parcMap_',namepart(1:end-6),'.mat']), "zmapSurrsSF100","zmapSurrsSF500","zmapSurrsSF1000","zmapSurrsDK");
        % save(fullfile(datadir,datasets(iSite).name,['verMap_',namepart(1:end-6),'.mat']), "zmapSurrsVer");
        save(fullfile(datadir,datasets(iSite).name,['parcThresMap_',namepart(1:end-6),'.mat']), "sigmapSurrsSF100","sigmapSurrsSF500","sigmapSurrsSF1000","sigmapSurrsDK");
        % save(fullfile(datadir,datasets(iSite).name,['verThresMap_',namepart(1:end-6),'.mat']), "sigmapSurrsHC_PVer", "sigmapSurrsP_HCVer","sigFdrmapSurrsHC_PVer","sigFdrmapSurrsP_HCVer");

        clear sigmapSurrsSF100 sigmapSurrsSF500 sigmapSurrsSF1000 sigmapSurrsDK
        clear zmapSurrsSF100 zmapSurrsSF500 zmapSurrsSF1000 zmapSurrsDK zmapSurrsVer
        % clear zmapSurrsVer  sigmapSurrsHC_PFull  sigmapSurrsP_HCFull sigFdrmapSurrsHC_PFull sigFdrmapSurrsP_HCFull
        % clear sigmapSurrsHC_PVer sigmapSurrsP_HCVer sigFdrmapSurrsHC_PVer sigFdrmapSurrsP_HCVer
    end
end