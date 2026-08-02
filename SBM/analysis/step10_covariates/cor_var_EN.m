function [varTable, meanEN, varEN, nEffect] = cor_var_EN(metadata, diagnosisString, corTmap1, siteList, iter, type)
% cor_var_EN: Computes the relationship between a variable 'EN' (e.g., network efficiency) 
% and the correlation matrix of z-maps across different sites.
%
% Inputs:
% - metadata: Table containing site-level data, including EN values and diagnosis information.
% - diagnosisString: String specifying the diagnosis category (e.g., 'BD', 'SCZ').
% - corTmap1: Correlation matrix of z-maps.
% - iter: Number of iterations for permutation testing.
% - type: Type of correlation to compute (e.g., 'spearman' or 'pearson').
%
% Outputs:
% - varTable: Table summarizing correlation results for mean and variance of EN across sites.
%             Includes correlation values and p-values.
% - nEffect: Number of effective sites with valid EN data.


nSite = length(siteList);

% Initialize matrix to store mean and variance of EN for each site
age = nan(nSite, 2);

% Loop through each site to calculate mean and variance of EN
for iSite = 1:nSite
    % Calculate the mean EN value for the site
    age(iSite, 1) = mean(metadata.EN( ...
        ismember(metadata.site_string, siteList(iSite)) & ...
        (ismember(metadata.diagnosis_string, 'HC') | ismember(metadata.diagnosis_string, diagnosisString))));

    % Calculate the standard deviation (variance) of EN for the site
    age(iSite, 2) = std(metadata.EN( ...
        ismember(metadata.site_string, siteList(iSite)) & ...
        (ismember(metadata.diagnosis_string, 'HC') | ismember(metadata.diagnosis_string, diagnosisString))));
end

% Identify rows with NaN values in the age matrix
rows_with_nan = any(isnan(age), 2);

% Proceed with correlation analysis if more than one valid site exists
if sum(rows_with_nan == 0) > 1
    % Call cal_var_age to compute correlations
    [varTable, DifVar1, DifVar2] = cal_var_age(age(~rows_with_nan, :), ...
                           corTmap1(~rows_with_nan, ~rows_with_nan), ...
                           iter, type);
    meanEN(~rows_with_nan, ~rows_with_nan) =  DifVar1;
    varEN(~rows_with_nan, ~rows_with_nan) = DifVar2;
else
    % If fewer than two valid sites, return an empty table
    varTable = [];
end

% Calculate the number of effective sites (rows without NaN values)
nEffect = nSite - sum(rows_with_nan);

end