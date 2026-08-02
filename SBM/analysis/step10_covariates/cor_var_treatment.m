function [varTable, medRatio, nEffect] = cor_var_treatment(metadata, diagnosisString, corTmap1, siteList,iter, type)
% cor_var_treatment: Computes the relationship between treatment proportions
% and the correlation matrix of z-maps across different sites.
%
% Inputs:
% - metadata: Table containing site-level data, including treatment information and diagnoses.
% - diagnosisString: String specifying the diagnosis category (e.g., 'BD', 'SCZ').
% - corTmap1: Correlation matrix of z-maps.
% - iter: Number of iterations for permutation testing.
% - type: Type of correlation to compute (e.g., 'spearman' or 'pearson').
%
% Outputs:
% - varTable: Table summarizing correlation results for treatment proportions across sites.
%             Includes correlation values and p-values.
% - nEffect: Number of effective sites with valid treatment data.


nSite = length(siteList);

% Initialize matrix to store treatment proportions for each site
med = nan(nSite, 1);

% Loop through each site to calculate treatment proportions
for iSite = 1:nSite
    % Identify subjects within the site and belonging to the selected diagnosis or HC
    inSite = ismember(metadata.site_string, siteList(iSite)) & ...
             (ismember(metadata.diagnosis_string, 'HC') | ismember(metadata.diagnosis_string, diagnosisString));
    
    % Calculate the proportion of subjects receiving treatment at the site
    med(iSite, 1) = sum(metadata.treatment(inSite)) / sum(inSite);
end

% Identify rows with NaN values or sites with zero treatment data
rows_with_nan = any(isnan(med), 2) | ~any(med, 2);

% Perform correlation analysis if more than one valid site exists
if ~all(rows_with_nan)
    % Call cal_var_treatment to compute correlations
    [varTable DifVar1] = cal_var_treatment(med(~rows_with_nan, :), ...
                                 corTmap1(~rows_with_nan, ~rows_with_nan), ...
                                 iter, type);
    medRatio(~rows_with_nan, ~rows_with_nan) = DifVar1;
else
    % If fewer than two valid sites, return an empty table
    varTable = [];
    medRatio = [];
end

% Calculate the number of effective sites (rows without NaN or zero treatment data)
nEffect = nSite - sum(rows_with_nan);

end