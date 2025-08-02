%combine parcellation
clear all
%read cerebellum
cere=niftiread('/home/trangc/kg98/trangc/atlases/Human_cerebellum/Buckner-whole_1mm_CAT12MNI.nii.gz');
cereInfo=niftiinfo('/home/trangc/kg98/trangc/atlases/Human_cerebellum/Buckner-whole_1mm_CAT12MNI.nii.gz');
nCere = max(cere,[],'all');

%read subcortex
sub=niftiread('/home/trangc/kg98/trangc/atlases/Tian_subcortical/CAT12MNI/Tian_Subcortex_S1_3T_2009cAsym_CAT12MNI.nii.gz');
nSub = max(sub,[],'all');



%read cortex
nParcList = [100 200 300 400 500 600 700 800 900 1000]; %number of parcels


for iParc = 1:length(nParcList)
    cortex = niftiread(['/home/trangc/kg98/trangc/atlases/Human_cortical/Schaefer/CAT12MNI/Schaefer2018_',num2str(nParcList(iParc)),'Parcels_7Networks_order_CAT12MNI.nii.gz']);

    % combine cerebellum and subcortex
    combi = cere;
    combi(sub>0) = sub(sub>0)+nCere;
    combi(cortex>0 & combi==0) = cortex(cortex>0 & combi==0)+ nCere + nSub;
    % niftiwrite(combi,['Buckner-whole_1mm_Tian_Subcortex_S1_3T_2009cAsym_Schaefer2018_',num2str(nParcList(iParc)),'Parcels_7Networks_order_CAT12MNI.nii'],cereInfo);

    clear combi
end
