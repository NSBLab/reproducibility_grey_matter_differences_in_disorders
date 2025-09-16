clear all
close all

iCOMBAT = 1;
smoothKernel = 8;

if iCOMBAT == 1
    address = ['derivatives/s',num2str(smoothKernel),'COMBAT/'];
else
    address = ['derivatives/s',num2str(smoothKernel),'/'];
end

metadata = readtable(['/home/trangc/kg98/trangc/VBM/data/derivatives/s',num2str(smoothKernel),'COMBAT/metadata.csv']);

diagnosisString = unique(metadata.diagnosis_string);
diagnosisString = diagnosisString(~ismember(diagnosisString,'HC'));
nDiag = length(diagnosisString);






%%


for iSite = 1:5
    [LaDiag LbDiag] = ismember(metadata.diagnosis_string,diagnosisString(iSite));
    [siteString ia ic] = unique(metadata.site_string(LaDiag));
    [siteString] = change_siteName(siteString);
    [overlap1, overlap2] = cal_overlap_tmap_thres(address, metadata, diagnosisString(iSite));

    overlapTime1 = unique(overlap1);
    for iO = 1:length(overlapTime1)
        overlapCount1(iSite,iO) = sum(overlap1==overlapTime1(iO));

    end

    overlapTime2 = unique(overlap2);
    for iO = 1:length(overlapTime2)
        overlapCount2(iSite,iO) = sum(overlap2==overlapTime2(iO));

    end
end

save('output/overlap.mat', 'overlapTime1', 'overlapTime2', 'overlapCount1', 'overlapCount2')