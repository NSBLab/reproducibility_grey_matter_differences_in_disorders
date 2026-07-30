function parcelate_maps_func(config, outdir, iSubdivide, randomSubdivide)
if nargin < 4
    error('Usage: parcelate_maps_func(config, outdir, iSubdivide, randomSubdivide)');
end
this_dir = fileparts(mfilename('fullpath'));
repo_root = fullfile(this_dir, '..', '..', '..');
addpath(this_dir);
addpath(genpath(fullfile(repo_root, 'utils')));
if ischar(config) || isstring(config)
    config = pipeline_load_config(char(config));
end
data_root = config.data_directories.dataset_root;
if isfield(config.data_directories, 'data') && ~isempty(config.data_directories.data)
    atlas_root = pipeline_resolve_relative_path(repo_root, config.data_directories.data);
else
    atlas_root = fullfile(repo_root, 'data');
end
hemi = 'lh';
smoothkernel = 0;
iCOMBAT = 1;
% DK atlas
[~,tempLabel,colortable]=read_annotation(fullfile(atlas_root, [hemi, '.aparc.annot']));
map2colortable = [2:4 6:36];
colorcode = colortable.table(map2colortable,5);
[lia labelDK] = ismember(tempLabel, colorcode);

% Schaefer atlas
[~,tempLabel,colortable]=read_annotation(fullfile(atlas_root, [hemi, '.Schaefer2018_100Parcels_7Networks_order.annot']));
map2colortable = [2:51];
colorcode = colortable.table(map2colortable,5);
[lia labelSF100] = ismember(tempLabel, colorcode);

[~,tempLabel,colortable]=read_annotation(fullfile(atlas_root, [hemi, '.Schaefer2018_500Parcels_7Networks_order.annot']));
map2colortable = [2:251];
colorcode = colortable.table(map2colortable,5);
[lia labelSF500] = ismember(tempLabel, colorcode);

[~,tempLabel,colortable]=read_annotation(fullfile(atlas_root, [hemi, '.Schaefer2018_1000Parcels_7Networks_order.annot']));
map2colortable = [2:501];
colorcode = colortable.table(map2colortable,5);
[lia labelSF1000] = ismember(tempLabel, colorcode);


datadir = data_root;

inGroup = [1 2];
for iSite = 1:length(inGroup)
    metadata = readtable(fullfile(outdir,['iSubdivide_',char(num2str(iSubdivide)),'_seed2group_',char(num2str(randomSubdivide))], ...
        ['iSubdivide_',char(num2str(iSubdivide)),'_seed2group_',char(num2str(randomSubdivide)),'_group',char(num2str(inGroup(iSite))),'.txt']));
    if iCOMBAT == 0

        for iMap = 1:height(metadata)
            % find site name
            vermap(:,iMap) = load_mgh(fullfile(datadir,metadata.dataset{iMap},'derivatives','freesurfer',metadata.subj_id{iMap},'surf',['lh.thickness.fwhm',char(num2str(smoothkernel)),'.fsaverage.mgh']));

            zmapDK(:,iMap) = full2parcel(vermap(:,iMap) ,labelDK');

            zmapSF100(:,iMap) = full2parcel(vermap(:,iMap) ,labelSF100');
            zmapSF500(:,iMap) = full2parcel(vermap(:,iMap) ,labelSF500');
            zmapSF1000(:,iMap) = full2parcel(vermap(:,iMap) ,labelSF1000');


        end
        qdecfolder = fullfile(outdir,['iSubdivide_',char(num2str(iSubdivide)),'_seed2group_',char(num2str(randomSubdivide))],...
            ['iSubdivide_',char(num2str(iSubdivide)),'_seed2group_',char(num2str(randomSubdivide)),'_group',char(num2str(inGroup(iSite))),'_SF']);
        mkdir(qdecfolder);
        save(fullfile(qdecfolder,[hemi,'.thickness.fwhm',char(num2str(smoothkernel)),'.fsaverage.mat']),'zmapSF100','zmapSF500' ,'zmapSF1000')

    else
        for iMap = 1:height(metadata)
            % find site name
            vermap(:,iMap) = load_mgh(fullfile(datadir,metadata.dataset{iMap},'derivatives','freesurfer',metadata.subj_id{iMap},'surf',['lh.thickness.fwhm',char(num2str(smoothkernel)),'.fsaverage_combat.mgh']));

            zmapDK(:,iMap) = full2parcel(vermap(:,iMap) ,labelDK');

            zmapSF100(:,iMap) = full2parcel(vermap(:,iMap) ,labelSF100');
            zmapSF500(:,iMap) = full2parcel(vermap(:,iMap) ,labelSF500');
            zmapSF1000(:,iMap) = full2parcel(vermap(:,iMap) ,labelSF1000');

        end
        qdecfolder = fullfile(outdir,['iSubdivide_',char(num2str(iSubdivide)),'_seed2group_',char(num2str(randomSubdivide))],...
            ['iSubdivide_',char(num2str(iSubdivide)),'_seed2group_',char(num2str(randomSubdivide)),'_group',char(num2str(inGroup(iSite))),'_SF_combat']);
        mkdir(qdecfolder);

        save(fullfile(qdecfolder,[hemi,'.thickness.fwhm',char(num2str(smoothkernel)),'.fsaverage.mat']),'zmapDK','zmapSF100','zmapSF500' ,'zmapSF1000')

    end
    clear zmapDK zmapSF100 zmapSF500 zmapSF1000  vermap
end

end
