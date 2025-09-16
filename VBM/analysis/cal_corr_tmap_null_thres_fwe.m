function [cor1, cor2,rowst1_without_zeros, rowst2_without_zeros] = cal_corr_tmap_null_thres_fwe(address, metadata, diagnosisString, mask,iNull)

addpath('/home/trangc/kg98/trangc/MBM/func')
[LaDiag LbDiag] = ismember(metadata.diagnosis_string,diagnosisString);
[siteString ia ic] = unique(metadata.site_string(LaDiag));
nSite = length(siteString);



for iSite = 1:nSite
    t1 = niftiread([address, num2str(iNull),'/', char(diagnosisString),'/',char(siteString(iSite)),'/spmT_0001_binary_fwe.nii']);
    t2 = niftiread([address,num2str(iNull),'/', char(diagnosisString),'/',char(siteString(iSite)),'/spmT_0002_binary_fwe.nii']);

    t1All(iSite,:) = t1(mask);
    t2All(iSite,:) = t2(mask);

end

rowst1_without_zeros = sum(t1All, 2)>0;
if sum(rowst1_without_zeros) == 0
    cor1 = [];
else
    t1All_non0 = double(t1All(rowst1_without_zeros,:));



    cor1 = bin_corr_mat_account_zero(t1All_non0(:,:)');


end

rowst2_without_zeros = sum(t2All, 2)>0;
if sum(rowst2_without_zeros) == 0
    cor2 = [];
else
    t2All_non0 = double(t2All(rowst2_without_zeros,:));

    cor2= bin_corr_mat_account_zero(t2All_non0(:,:)');

end
end
