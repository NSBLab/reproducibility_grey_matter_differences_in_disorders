clear all
addpath(genpath('/projects/kg98/trangc/library/BrainSpace'))
addpath(genpath('/projects/kg98/trangc/library'))
hemi = 'lh';
smoothkernel = 0;
measure = 'thick';
iCOMBAT = 1;
% load(['eigenStruct_',hemi,'.mat']); %load structure that contains eigentrapping because the mask was changed to fix the 164k mesh error
% DK atlas
[tempVertices,tempLabel,colortable]=read_annotation(['/projects/kg98/trangc/VBM/data/Atypical/derivatives' ...
    '/freesurfer/fsaverage/label/lh.aparc.annot']);
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
        if iCOMBAT == 0
            if strcmp(datasets(iSite),'MBBP')
                for iMap = 1:height(qdecfile)
                    subNameFull = char(qdecfile.fsid{iMap});
                    subNameSort = ['sub-',num2str(str2num(subNameFull(5:end)))];
                    vermap(:,iMap) = load_mgh(fullfile('/scratch/kg98/Toby/WHOLEMBBP/workspace', 'derivatives','freesurfer',subNameSort,'surf',['lh.thickness.fwhm',char(num2str(smoothkernel)),'.fsaverage.mgh']));

                    zmapDK(:,iMap) = full2parcel(vermap(:,iMap) ,labelDK');
                    zmapSF100(:,iMap) = full2parcel(vermap(:,iMap) ,labelSF100');
                    zmapSF500(:,iMap) = full2parcel(vermap(:,iMap) ,labelSF500');
                    zmapSF1000(:,iMap) = full2parcel(vermap(:,iMap) ,labelSF1000');
                end
            else
                for iMap = 1:height(qdecfile)
                    vermap(:,iMap) = load_mgh(fullfile(datadir,char(datasets(iSite)), 'derivatives','freesurfer',char(qdecfile.fsid{iMap}),'surf',['lh.thickness.fwhm',char(num2str(smoothkernel)),'.fsaverage.mgh']));

                    zmapDK(:,iMap) = full2parcel(vermap(:,iMap) ,labelDK');

                    zmapSF100(:,iMap) = full2parcel(vermap(:,iMap) ,labelSF100');
                    zmapSF500(:,iMap) = full2parcel(vermap(:,iMap) ,labelSF500');
                    zmapSF1000(:,iMap) = full2parcel(vermap(:,iMap) ,labelSF1000');

                end
            end
            qdecfolder = fullfile(datadir,char(datasets(iSite)), 'derivatives','freesurfer','qdec',[char(num2str(diag(iFile))),'_',char(site{iFile}),'_',measure,'_smooth',char(num2str(smoothkernel)),'_',hemi,'_sex_age_SF']);
            mkdir(qdecfolder);

            save(fullfile(qdecfolder,[hemi,'.thickness.fwhm',char(num2str(smoothkernel)),'.fsaverage.mat']),'zmapSF100','zmapSF500' ,'zmapSF1000')

        else
            for iMap = 1:height(qdecfile)
                vermap(:,iMap) = load_mgh(fullfile(datadir,char(datasets(iSite)), 'derivatives','freesurfer',char(qdecfile.fsid{iMap}),'surf',['lh.thickness.fwhm',char(num2str(smoothkernel)),'.fsaverage_combat.mgh']));

                zmapDK(:,iMap) = full2parcel(vermap(:,iMap) ,labelDK');

                zmapSF100(:,iMap) = full2parcel(vermap(:,iMap) ,labelSF100');
                zmapSF500(:,iMap) = full2parcel(vermap(:,iMap) ,labelSF500');
                zmapSF1000(:,iMap) = full2parcel(vermap(:,iMap) ,labelSF1000');

            end
            qdecfolder = fullfile(datadir,char(datasets(iSite)), 'derivatives','freesurfer','qdec',[char(num2str(diag(iFile))),'_',char(site{iFile}),'_',measure,'_smooth',char(num2str(smoothkernel)),'_',hemi,'_sex_age_SF_combat']);
            mkdir(qdecfolder);

            save(fullfile(qdecfolder,[hemi,'.thickness.fwhm',char(num2str(smoothkernel)),'.fsaverage.mat']),'zmapDK','zmapSF100','zmapSF500' ,'zmapSF1000')

        end
        clear zmapDK zmapSF100 zmapSF500 zmapSF1000  vermap
    end
    clear site diag
end
