clear all
close all
addpath('/projects/kg98/trangc/library/Violinplot-Matlab-master')
addpath('/projects/kg98/trangc/VBM/code/utils')
iCOMBAT = 1;
smoothKernel = 6;
diagString = {'HC', 'BD', 'SCA',...
    'SCZ', 'ASD', 'MDD','AD' };
if iCOMBAT == 1
    address = ['/projects/kg98/trangc/VBM/data/derivatives/s',num2str(smoothKernel),'COMBAT/'];
else
    address = ['/projects/kg98/trangc/VBM/data/derivatives/s',num2str(smoothKernel),'/'];
end

metadata = readtable(['/projects/kg98/trangc/VBM/data/metadataVBM_psy.csv']);
metadataAD = readtable(['/projects/kg98/trangc/VBM/data/metadataVBM_AD.csv']);

mask = logical(niftiread(['/projects/kg98/trangc/VBM/data/derivatives/s',char(num2str(smoothKernel)),'COMBAT/mask_psy/mask.nii']));
maskAD = logical(niftiread(['/projects/kg98/trangc/VBM/data/derivatives/s',char(num2str(smoothKernel)),'COMBAT/mask_AD/mask.nii']));

nDiv = 10; % number of subdivision

for iDiag = 1:length(diagString)-1

    if iDiag==6
        [cor1{iDiag}, cor2{iDiag}, t1All{iDiag}, t2All{iDiag}, siteList{iDiag}] = cal_corr_tmap_average_across_study(address, metadataAD, diagString(iDiag+1), maskAD, nDiv);
        [corThres1{iDiag}, corThres2{iDiag}, repThres1{iDiag}, repThres2{iDiag},siteThresList{iDiag},thresmap1{iDiag},thresmap2{iDiag}] = cal_corr_tmap_thres_average_across_study(address, metadataAD, diagString(iDiag+1), maskAD, nDiv);

    else
        [cor1{iDiag}, cor2{iDiag}, t1All{iDiag}, t2All{iDiag}, siteList{iDiag}] = cal_corr_tmap_average_across_study(address, metadata, diagString(iDiag+1), mask, nDiv);
        [corThres1{iDiag}, corThres2{iDiag}, repThres1{iDiag}, repThres2{iDiag}, siteThresList{iDiag},thresmap1{iDiag},thresmap2{iDiag}] = cal_corr_tmap_thres_average_across_study(address, metadata, diagString(iDiag+1), mask, nDiv);

    end
end
%%
save(['output/corr_average_across_study_tmap_combat',num2str(iCOMBAT),'_smooth',num2str(smoothKernel),'.mat'], ...
    'cor1', 'cor2','corThres1','corThres2','repThres1','repThres2',"siteList",'siteThresList','t1All','t2All','thresmap1','thresmap2')