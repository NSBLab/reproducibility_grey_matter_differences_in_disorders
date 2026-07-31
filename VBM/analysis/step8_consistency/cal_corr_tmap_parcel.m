function [cor1 corThres1 rep1 t1All t1Thres siteList] = cal_corr_tmap_parcel(data_root, address, metadata, diagnosisString, nParc)
[LaDiag LbDiag] = ismember(metadata.diagnosis_string,diagnosisString);
[siteString ia ic] = unique(metadata.site_string(LaDiag));
nSite = length(siteString);
if nSite < 2
    cor1 = [];
    corThres1 = [];
    rep1 = [];
    t1All = [];
    t1Thres = [];
    siteList = siteString;
    return;
end


for iSite = 1:nSite
    in_file = fullfile(data_root, address, char(diagnosisString), char(siteString(iSite)), ...
        [char(num2str(nParc)), '_parcCon.mat']);
    load(in_file);
    
    t1All(iSite,:) = stat.tMap;

    t1Thres(iSite,:) = stat.thresMap;
  
end

   
cor1 = corr(t1All');
corThres1 = bin_corr_mat_account_zero(t1Thres');
rep1 = replication_mat(t1Thres');
siteList = siteString;

end
