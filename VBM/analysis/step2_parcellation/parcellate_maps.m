% parcellate subject maps
function parcellate_maps(dataset,isses)
dataDir = fullfile('/projects','kg98','trangc','VBM','data');

cereInfo = niftiinfo('/home/trangc/kg98/trangc/atlases/Human_cerebellum/Buckner-whole_1mm_CAT12MNI.nii.gz'); %same info as the combine parcelation

nParcList = [100 200 300 400 500 600 700 800 900 1000];



% read subject list
subList = readtable(fullfile(dataDir,dataset, [dataset,'_dems.csv']),'delimiter',',');

% read subject
for iSub = 1:height(subList)
    sub  = char(subList.subj_id(iSub))
    if isses==1
        ses = char(subList.ses(iSub));
        if ~exist(fullfile(dataDir,dataset,sub,ses,'anat',['mwp1',sub,'_',ses,'_T1w_Buckner-whole_1mm_Tian_Subcortex_S1_3T_2009cAsym_Schaefer2018_1000Parcels_7Networks_order_CAT12MNI.mat']))
        %read map
        map = spm_vol(fullfile(dataDir,dataset,sub,ses,'anat',['mwp1',sub,'_',ses,'_T1w.nii']));

        for iParc = 1:length(nParcList)

            parc = niftiread(['Buckner-whole_1mm_Tian_Subcortex_S1_3T_2009cAsym_Schaefer2018_',num2str(nParcList(iParc)),'Parcels_7Networks_order_CAT12MNI.nii']);
            volParc = get_vol_parc(map, parc);
            save(fullfile(dataDir,dataset,sub,ses,'anat',['mwp1',sub,'_',ses,'_T1w_Buckner-whole_1mm_Tian_Subcortex_S1_3T_2009cAsym_Schaefer2018_',char(num2str(nParcList(iParc))),'Parcels_7Networks_order_CAT12MNI.mat']),'volParc');
        end
        end
    else
        if ~exist(fullfile(dataDir,dataset,sub,'anat',['mwp1',sub,'_T1w_Buckner-whole_1mm_Tian_Subcortex_S1_3T_2009cAsym_Schaefer2018_1000Parcels_7Networks_order_CAT12MNI.mat']))
        %read map
        map = spm_vol(fullfile(dataDir,dataset,sub,'anat',['mwp1',sub,'_T1w.nii']));

        for iParc = 1:length(nParcList)

            parc = niftiread(['Buckner-whole_1mm_Tian_Subcortex_S1_3T_2009cAsym_Schaefer2018_',num2str(nParcList(iParc)),'Parcels_7Networks_order_CAT12MNI.nii']);
            volParc = get_vol_parc(map, parc);
            save(fullfile(dataDir,dataset,sub,'anat',['mwp1',sub,'_T1w_Buckner-whole_1mm_Tian_Subcortex_S1_3T_2009cAsym_Schaefer2018_',char(num2str(nParcList(iParc))),'Parcels_7Networks_order_CAT12MNI.mat']),'volParc');
        end
        end
    end
end
end


