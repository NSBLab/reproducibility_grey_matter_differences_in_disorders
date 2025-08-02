function [overlap1, overlap2] = cal_overlap_tmap_thres(address, metadata, diagnosisString)
[LaDiag LbDiag] = ismember(metadata.diagnosis_string,diagnosisString);
[siteString ia ic] = unique(metadata.site_string(LaDiag));
nSite = length(siteString);


mask = logical(niftiread(['/home/trangc/kg98/trangc/VBM/data/derivatives/s8COMBAT/mask_group_mean_bin.nii']));

for iSite = 1:nSite
    t1 = niftiread(['/projects/kg98/trangc/VBM/data/', address, char(diagnosisString),'/',char(siteString(iSite)),'/cluster0001.nii']);
    t2 = niftiread(['/projects/kg98/trangc/VBM/data/', address, char(diagnosisString),'/',char(siteString(iSite)),'/clusterIncrease0001.nii']);

    t1All(iSite,:) = t1(mask);
    t2All(iSite,:) = t2(mask);

end

rowst1_without_zeros = sum(t1All, 2)>0;
if sum(rowst1_without_zeros) == 0
    cor1 = [];
else
    t1All_non0 = double(t1All(rowst1_without_zeros,:));

% overlap1 = sum(t1All_non0,1)./size(t1All_non0,1);
overlap1 = sum(t1All_non0,1);

   
end

rowst2_without_zeros = sum(t2All, 2)>0;
if sum(rowst2_without_zeros) == 0
    cor2 = [];
else
    t2All_non0 = double(t2All(rowst2_without_zeros,:));
    overlap2 = sum(t2All_non0,1);
end
end
