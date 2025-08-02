function [cor1, cor2, siteString] = cal_corr_tmap(address, metadata, diagnosisString,mask)
[LaDiag LbDiag] = ismember(metadata.diagnosis_string,diagnosisString);
[siteString ia ic] = unique(metadata.site_string(LaDiag));
nSite = length(siteString);



for iSite = 1:nSite
    t1 = niftiread(['/projects/kg98/trangc/VBM/data/', address, char(diagnosisString),'/',char(siteString(iSite)),'/spmT_0001.nii']);
    t2 = niftiread(['/projects/kg98/trangc/VBM/data/', address, char(diagnosisString),'/',char(siteString(iSite)),'/spmT_0002.nii']);

    t1All(iSite,:) = reshape(t1(mask),[],1);
    t2All(iSite,:) = reshape(t2(mask),[],1);

end

   
cor1 = corr(t1All');
cor2 = corr(t2All');




end
