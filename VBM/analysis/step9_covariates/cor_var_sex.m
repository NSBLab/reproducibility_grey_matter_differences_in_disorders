function [varTable nSite] = cor_var_sex(metadata, diagnosisString, corTmap1, corTmap2, siteList, iter, type )


nSite = length(siteList);

for iSite = 1:nSite

    nSex(iSite,1) = sum(ismember(metadata.sex_string,'M') & ismember(metadata.site_string,siteList(iSite)) ...
        & (ismember(metadata.diagnosis_string,'HC') | ismember(metadata.diagnosis_string,diagnosisString)));
    nSex(iSite,2) = sum(ismember(metadata.sex_string,'F') & ismember(metadata.site_string,siteList(iSite))...
        & (ismember(metadata.diagnosis_string,'HC') | ismember(metadata.diagnosis_string,diagnosisString)));

end
rows_with_nan = any(isnan(nSex), 2) | ~all(nSex,2);
% 
if ~all(rows_with_nan)
varTable = cal_var(nSex(~rows_with_nan,:), corTmap1(~rows_with_nan,~rows_with_nan), corTmap2(~rows_with_nan,~rows_with_nan), iter, type);
else
varTable =[];
end
% varTable = cal_var(nSex, corTmap1, corTmap2, iter, type);

end