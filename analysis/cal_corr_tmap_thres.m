function [cor1, cor2, rep1, rep2, siteList, varargout] = cal_corr_tmap_thres(address, metadata, diagnosisString, mask)

addpath('/projects/kg98/trangc/MBM/func')
[LaDiag LbDiag] = ismember(metadata.diagnosis_string,diagnosisString);
[siteString ia ic] = unique(metadata.site_string(LaDiag));
nSite = length(siteString);



for iSite = 1:nSite
    t1 = niftiread([address, char(diagnosisString),'/',char(siteString(iSite)),'/spmT_0001_binary.nii']);
    t2 = niftiread([ address, char(diagnosisString),'/',char(siteString(iSite)),'/spmT_0002_binary.nii']);

    t1Map{iSite} = t1;
    t2Map{iSite} = t2;
    t1All(iSite,:) = t1(mask);
    t2All(iSite,:) = t2(mask);

end


    cor1 = bin_corr_mat_account_zero(t1All');
    cor2= bin_corr_mat_account_zero(t2All(:,:)');

    rep1 = replication_mat(t1All');
    rep2 = replication_mat(t2All');

siteList = siteString;
varargout{1} = t1Map;
varargout{2} = t2Map;
end
