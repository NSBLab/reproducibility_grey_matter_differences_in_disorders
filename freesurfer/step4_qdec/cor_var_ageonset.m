function [varTable nEffect]= cor_var_ageonset(metadata, diagnosisString, corTmap1, corTmap2, iter, type )

[LaDiag LbDiag] = ismember(metadata.diagnosis_string,diagnosisString);
[siteString ia ic] = unique(metadata.site_string(LaDiag));
nSite = length(siteString);

for iSite = 1:nSite

    %mean
    age(iSite,1) = mean(metadata.ageOnset(ismember(metadata.site_string,siteString(iSite)) & (ismember(metadata.diagnosis_string,'HC') | LaDiag)...
        &  0 < metadata.ageOnset & metadata.ageOnset < 61));

    %var
    age(iSite,2) = std(metadata.ageOnset(ismember(metadata.site_string,siteString(iSite)) & (ismember(metadata.diagnosis_string,'HC') | LaDiag)...
        & 0 < metadata.ageOnset & metadata.ageOnset < 61));

end
rows_with_nan = any(isnan(age), 2);

if ~all(rows_with_nan)
varTable = cal_var_age(age(~rows_with_nan,:), corTmap1(~rows_with_nan,~rows_with_nan), corTmap2(~rows_with_nan,~rows_with_nan), iter, type);

else
varTable =[];
end

nEffect = nSite - sum(rows_with_nan);

end

