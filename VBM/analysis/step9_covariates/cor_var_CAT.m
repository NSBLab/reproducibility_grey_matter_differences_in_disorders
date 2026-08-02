function [varTable, nEffect] = cor_var_CAT(metadata, diagnosisString, corTmap1, corTmap2,siteList, iter, type)
% Computes the correlation between site-level CAT metrics and brain
% t-map correlations for a given diagnosis.
%
% INPUTS:
%   metadata         : Table containing metadata for all subjects
%   diagnosisString  : String specifying the diagnosis to analyze
%   corTmap1         : Correlation matrix of t-maps for HC > Patients
%   corTmap2         : Correlation matrix of t-maps for HC < Patients
%   iter             : Number of iterations for Mantel test
%   type             : Type of correlation to use (e.g., 'spearman')
%
% OUTPUTS:
%   varTable         : Table summarizing correlations and p-values for mean
%                      and variance of CAT metrics
%   nEffect          : Number of sites contributing to the analysis


nSite = length(siteList); % Total number of unique sites

% Initialize CAT mean and variance for each site
for iSite = 1:nSite
    % Compute mean of CAT scores for valid entries
    age(iSite, 1) = mean(metadata.CAT( ...
        ismember(metadata.site_string, siteList(iSite)) & ...
        (ismember(metadata.diagnosis_string, 'HC') | ismember(metadata.diagnosis_string, diagnosisString))));

    % Compute variance of CAT scores for valid entries
    age(iSite, 2) = std(metadata.CAT( ...
        ismember(metadata.site_string, siteList(iSite)) & ...
        (ismember(metadata.diagnosis_string, 'HC') | ismember(metadata.diagnosis_string, diagnosisString))));
end

% Identify rows with NaN values in the age matrix
rows_with_nan = any(isnan(age), 2);

% If not all rows contain NaN values, compute correlation metrics
if ~all(rows_with_nan)
    % Compute correlation between CAT metrics and t-maps
    varTable = cal_var_age(age(~rows_with_nan, :), ...
        corTmap1(~rows_with_nan, ~rows_with_nan), ...
        corTmap2(~rows_with_nan, ~rows_with_nan), ...
        iter, type);
else
    % If all rows contain NaN, return an empty result
    varTable = [];
end

% Calculate the effective number of sites (excluding those with NaN values)
nEffect = nSite - sum(rows_with_nan);

end