function varTable= cor_var(metadata, diagnosisString, corTmap1, corTmap2, iter, type )

[LaDiag LbDiag] = ismember(metadata.diagnosis_string,diagnosisString);
[siteString ia ic] = unique(metadata.site_string(LaDiag));
nSite = length(siteString);

for iSite = 1:nSite
    
    nPC(iSite,1) = sum(LaDiag & ismember(metadata.site_string,siteString(iSite)));
    nPC(iSite,2) = sum(ismember(metadata.diagnosis_string,'HC') & ismember(metadata.site_string,siteString(iSite)));

    nSex(iSite,1) = sum(ismember(metadata.sex_string,'M') & ismember(metadata.site_string,siteString(iSite)));
    nSex(iSite,2) = sum(ismember(metadata.sex_string,'F') & ismember(metadata.site_string,siteString(iSite)));

    ageMean(iSite) = mean(metadata.age(ismember(metadata.site_string,siteString(iSite))));
    ageStd(iSite) = std(metadata.age(ismember(metadata.site_string,siteString(iSite))));
end

varTable = cal_var(nPC, corTmap1, corTmap2, iter, type);


end