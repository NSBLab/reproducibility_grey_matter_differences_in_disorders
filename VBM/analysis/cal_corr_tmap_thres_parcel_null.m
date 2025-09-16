function [corNull  repNull siteList] = cal_corr_tmap_thres_parcel_null( metadata, diagnosisString, nParc)
[LaDiag LbDiag] = ismember(metadata.diagnosis_string,diagnosisString);
[siteString ia ic] = unique(metadata.site_string(LaDiag));
nSite = length(siteString);


for iSite = 1:nSite
    nullmaps = readmatrix(['/projects/kg98/trangc/VBM/data/derivatives/roi/',char(diagnosisString),'/',char(siteString(iSite)),'/',char(num2str(nParc)),'_parcCon_thresMap_null.txt']);

    t1All(iSite,:,:) = nullmaps;


end
corNull = [];
repNull = [];
for iNull = 1:size(nullmaps,1)

    cor1 = bin_corr_mat_account_zero(squeeze(t1All(:,iNull,:))');
    ids = find(triu(ones(size(cor1)),1));
    corNull = [corNull;cor1(ids)];

    rep1 = replication_mat(squeeze(t1All(:,iNull,:))');
    ids = find(triu(ones(size(rep1)),1));
    repNull = [repNull;rep1(ids)];
end
% corThres1 = bin_corr_mat_account_zero(t1Thres');
siteList = siteString;

end
