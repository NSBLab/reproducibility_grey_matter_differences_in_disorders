% make the three column matrix of parc coordinate

clear all
addpath(genpath('/projects/kg98/trangc/library/nihelp'))
nParcList = [200 300 400 500 600 700 800 900 1000];

% Load the .nii file
nii_file = '/usr/local/spm12/matlab2021a.r7771-v1/toolbox/cat12/templates_MNI152NLin2009cAsym/Template_0_GS.nii';  % Replace with the path to your .nii file

% get xyz cordinate
volumeInfo = spm_vol(nii_file)
[intensityValues,xyzCoordinates ] = spm_read_vols(volumeInfo);
voxCo = reshape(xyzCoordinates,3,113,137,113);
voxCox = squeeze(voxCo(1,:,:,:));
voxCoy = squeeze(voxCo(2,:,:,:));
voxCoz = squeeze(voxCo(3,:,:,:));

for iParc = 1:length(nParcList)
    % read parcellation label
    label=niftiread(['/projects/kg98/trangc/VBM/code/roi/Buckner-whole_1mm_Tian_Subcortex_S1_3T_2009cAsym_Schaefer2018_',char(num2str(nParcList(iParc))),'Parcels_7Networks_order_CAT12MNI.nii']);
    nROI = max(label,[],"all");
    figure

    for iROI = 1:nROI
        [lia,locb] = ismember(label,iROI);
        voROI(:,1) = voxCox(lia);
        voROI(:,2) = voxCoy(lia);
        voROI(:,3) = voxCoz(lia);
        m = calcRoiMedioid(voROI);
        centroidCo(iROI,:) = voROI(m,:);
        scatter3(voROI(:,1),voROI(:,2),voROI(:,3),[],(1:size(voROI,1)).'==m,'filled');
        hold on
        clear voROI
    end

    writematrix(centroidCo,['/home/trangc/kg98/trangc/VBM/code/nulltest/pythonProject/parc_Coordinate_Buckner-whole_1mm_Tian_Subcortex_S1_3T_2009cAsym_Schaefer2018_',char(num2str(nParcList(iParc))),'Parcels_7Networks_order_CAT12MNI','.txt'],'Delimiter',' ');
end