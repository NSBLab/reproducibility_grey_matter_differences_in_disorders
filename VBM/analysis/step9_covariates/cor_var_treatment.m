function [varTable, nEffect] = cor_var_treatment(metadata, diagnosisString, corTmap1, corTmap2, siteList, iter, type)
% Computes the correlation between treatment proportions at sites and
% brain t-map correlations for a given diagnosis.
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
%   varTable         : Table summarizing correlations and p-values for treatment proportions
%   nEffect          : Number of sites contributing to the analysis


nSite = length(siteList); % Total number of unique sites

% Initialize treatment proportions for each site
for iSite = 1:nSite
    % Filter subjects within the current site and relevant diagnoses
    inSite = ismember(metadata.site_string, siteList(iSite)) & ...
             (ismember(metadata.diagnosis_string, 'HC') | ismember(metadata.diagnosis_string, diagnosisString));
    
    % Compute the proportion of subjects receiving treatment
    age(iSite, 1) = sum(metadata.treatment(inSite)) / sum(inSite);
end

% Identify rows with NaN values or sites with no treatment data
rows_with_nan = any(isnan(age), 2) | ~any(age, 2);

% If valid data exists, compute correlation metrics
if ~all(rows_with_nan)
    % Calculate correlations using the Mantel test
    varTable = cal_var_treatment(age(~rows_with_nan, :), ...
        corTmap1(~rows_with_nan, ~rows_with_nan), ...
        corTmap2(~rows_with_nan, ~rows_with_nan), ...
        iter, type);
else
    % If all rows contain invalid data, return an empty result
    varTable = [];
end

% Calculate the effective number of sites (excluding those with NaN or no treatment data)
nEffect = nSite - sum(rows_with_nan);

end