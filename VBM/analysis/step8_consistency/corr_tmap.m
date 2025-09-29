clear all
close all
addpath('/projects/kg98/trangc/library/Violinplot-Matlab-master')
addpath('/projects/kg98/trangc/VBM/code/utils')
iCOMBAT = 0;
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



for iSite = 1:length(diagString)-1

    if iSite==6
        [cor1{iSite}, cor2{iSite}, t1All{iSite}, t2All{iSite}, siteList{iSite}] = cal_corr_tmap(address, metadataAD, diagString(iSite+1), maskAD);
    [corThres1{iSite}, corThres2{iSite}, repThres1{iSite}, repThres2{iSite},siteThresList{iSite},thresmap1{iSite},thresmap2{iSite}] = cal_corr_tmap_thres(address, metadataAD, diagString(iSite+1), maskAD);
[corThresFWE1{iSite}, corThresFWE2{iSite},repThresFWE1{iSite}, repThresFWE2{iSite}, siteThresFWEList{iSite},thresmapFWE1{iSite},thresmapFWE2{iSite}] = cal_corr_tmap_thres_fwe(address, metadataAD, diagString(iSite+1), maskAD);

    else
        [cor1{iSite}, cor2{iSite}, t1All{iSite}, t2All{iSite}, siteList{iSite}] = cal_corr_tmap(address, metadata, diagString(iSite+1), mask);
    [corThres1{iSite}, corThres2{iSite}, repThres1{iSite}, repThres2{iSite}, siteThresList{iSite},thresmap1{iSite},thresmap2{iSite}] = cal_corr_tmap_thres(address, metadata, diagString(iSite+1), mask);
[corThresFWE1{iSite}, corThresFWE2{iSite},repThresFWE1{iSite}, repThresFWE2{iSite}, siteThresFWEList{iSite},thresmapFWE1{iSite},thresmapFWE2{iSite}] = cal_corr_tmap_thres_fwe(address, metadata, diagString(iSite+1), mask);
 
    end
end

save(['output/corr_tmap_combat',num2str(iCOMBAT),'_smooth',num2str(smoothKernel),'.mat'], ...
    'cor1', 'cor2','corThres1','corThres2','repThres1','repThres2','corThresFWE1','corThresFWE2', ...
    'repThresFWE1','repThresFWE2',"siteList",'siteThresList','siteThresFWEList','t1All','t2All','thresmap1','thresmap2','thresmapFWE1','thresmapFWE2')