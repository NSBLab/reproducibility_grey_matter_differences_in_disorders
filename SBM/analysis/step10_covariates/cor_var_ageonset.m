function [varTable,meanAge, stdAge, nEffect] = cor_var_ageonset(metadata, diagnosisString, corTmap1, siteList, iter, type)
% cor_var_ageonset: Analyzes the relationship between variability in age of onset and
% the correlation matrix of z-maps across sites.
%
% Inputs:
% - metadata: Table containing site-level data, including age of onset and diagnosis information.
% - diagnosisString: String indicating the diagnosis category to analyze (e.g., 'BD', 'SCZ').
% - corTmap1: Correlation matrix of z-maps (e.g., HC > P).
% - iter: Number of iterations for permutation testing.
% - type: Correlation type (e.g., 'spearman' or 'pearson').
%
% Outputs:
% - varTable: Table summarizing the correlation results for age of onset (mean and variance),
%             including correlation values and p-values.
% - nEffect: Number of effective sites with valid data for analysis.


nSite = length(siteList);

% Initialize age matrix to store mean and variance for each site
age = nan(nSite, 2);

for iSite = 1:nSite
    % Calculate mean age of onset for the site
    age(iSite, 1) = mean(metadata.ageOnset( ...
        ismember(metadata.site_string, siteList(iSite)) & ...
        (ismember(metadata.diagnosis_string, 'HC') | ismember(metadata.diagnosis_string, diagnosisString)) & ...
        (0 < metadata.ageOnset & metadata.ageOnset < 61)));

    % Calculate variance of age of onset for the site
    age(iSite, 2) = std(metadata.ageOnset( ...
        ismember(metadata.site_string, siteList(iSite)) & ...
        (ismember(metadata.diagnosis_string, 'HC') | ismember(metadata.diagnosis_string, diagnosisString)) & ...
        (0 < metadata.ageOnset & metadata.ageOnset < 61)));
end

% Identify rows with NaN values in the age matrix
rows_with_nan = any(isnan(age), 2);

% If valid rows exist (rows without NaN), proceed to calculate the correlation
if ~all(rows_with_nan)
    [varTable, DifVar1, DifVar2] = cal_var_age(age(~rows_with_nan, :), ...
                           corTmap1(~rows_with_nan, ~rows_with_nan), ...
                           iter, type);
    meanAge(~rows_with_nan, ~rows_with_nan) = DifVar1;
    stdAge(~rows_with_nan, ~rows_with_nan) = DifVar2;
else
    % If all rows contain NaN, return an empty table
    varTable = [];
    meanAge =[];
    stdAge = [];
end

% Calculate the number of effective sites (rows without NaN values)
nEffect = nSite - sum(rows_with_nan);

end