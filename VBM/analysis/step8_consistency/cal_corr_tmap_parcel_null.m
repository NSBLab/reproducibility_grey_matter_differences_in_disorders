function [corNull  corBinNull repNull siteList] = cal_corr_tmap_parcel_null(nulldir, metadata, diagnosisString, nParc, nNull)
[LaDiag LbDiag] = ismember(metadata.diagnosis_string,diagnosisString);
[siteString ia ic] = unique(metadata.site_string(LaDiag));
nSite = length(siteString);
for iSite = 1:nSite
    for iNull = 1:nNull
        nullmaps = load(fullfile(nulldir, char(diagnosisString),char(siteString(iSite)),['spmT_0001_surrogate_',char(num2str(iNull)),'_T1w_Buckner-whole_1mm_Tian_Subcortex_S1_3T_2009cAsym_Schaefer2018_',char(num2str(nParc)),'Parcels_7Networks_order_CAT12MNI.mat']),'volParc','binParc');
        parcNull(iSite,iNull,:) = nullmaps.volParc;
        parcThresNull(iSite,iNull,:) = nullmaps.binParc;



    end
end
    corNull = [];
    corBinNull = [];
    repNull = [];
    for iNull = 1:nNull

        cor1 = corr(squeeze(parcNull(:,iNull,:))');
        ids = find(triu(ones(size(cor1)),1));
        corNull = [corNull;median(cor1(ids))];

        corBin = bin_corr_mat_account_zero(squeeze(parcThresNull(:,iNull,:))');
        ids = find(triu(ones(size(corBin)),1));
        corBinNull = [corBinNull;median(corBin(ids))];

        rep1 = replication_mat(squeeze(parcThresNull(:,iNull,:))');
        ids = find(triu(ones(size(rep1)),1));
        repNull = [repNull;median(rep1(ids))];

    end
siteList = siteString;

end
