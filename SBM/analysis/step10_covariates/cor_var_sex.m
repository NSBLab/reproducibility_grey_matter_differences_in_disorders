function [varTable, DifVar1, DifVar2, DifSumVar, DifVar1vsVar2, nSite] = cor_var_sex(metadata, diagnosisString, corTmap1, siteList,iter, type)
% Analyze correlation of sex-based differences in t-map data across sites
%
% INPUT:
%   metadata         : A structure containing metadata about subjects, including:
%                      - metadata.diagnosis_string: Diagnosis labels (e.g., 'HC', 'P').
%                      - metadata.site_string: Site labels for each subject.
%                      - metadata.sex_string: Sex labels ('M' or 'F').
%   diagnosisString  : A string or array of strings specifying the diagnoses of interest.
%   corTmap1         : Correlation matrix of t-maps (nSite x nSite).
%   iter             : Number of iterations for the Mantel test.
%   type             : Type of correlation to compute ('pearson', 'spearman', etc.).
%
% OUTPUT:
%   varTable         : Table summarizing Mantel test results for sex differences.
%                      - If no valid data is available (e.g., NaNs or zeros in `nSex`), returns an empty array.
%   nSite            : Number of unique sites in the dataset.
%
% DESCRIPTION:
%   This function calculates the number of male and female subjects for each site while
%   filtering for the specified diagnoses. It then computes the correlation between sex-based
%   differences (number of males vs. females) and the provided correlation matrix of t-maps
%   using a helper function (`cal_var`).
%
% STEPS:
%   1. Identify the rows in the metadata corresponding to the specified diagnoses (`LaDiag`).
%   2. Extract unique site identifiers and count the number of sites (`nSite`).
%   3. For each site, calculate:
%      - nSex(iSite,1): Number of male subjects (both healthy controls and specified diagnoses).
%      - nSex(iSite,2): Number of female subjects (both healthy controls and specified diagnoses).
%   4. Exclude sites with missing data or zero counts for any sex.
%   5. If valid data exists, call `cal_var` to compute correlations; otherwise, return an empty array.
%
% NOTES:
%   - The function ensures no sites with NaN values or zero counts for any sex are included in the analysis.
%   - Relies on the `cal_var` function for computing correlations and generating the results table.
%
% EXAMPLE USAGE:
%   [varTable, nSite] = cor_var_sex(metadata, {'P'}, corTmap1, 1000, 'pearson');


nSite = length(siteList);

% Initialize nSex matrix (columns: males, females)
nSex = zeros(nSite, 2);

% Count the number of males and females per site for the specified diagnoses
for iSite = 1:nSite
    % Count males
    nSex(iSite, 1) = sum(ismember(metadata.sex_string, 'M') & ...
                         ismember(metadata.site_string, siteList(iSite)) & ...
                         (ismember(metadata.diagnosis_string, 'HC') | ismember(metadata.diagnosis_string, diagnosisString)));
    % Count females
    nSex(iSite, 2) = sum(ismember(metadata.sex_string, 'F') & ...
                         ismember(metadata.site_string, siteList(iSite)) & ...
                         (ismember(metadata.diagnosis_string, 'HC') | ismember(metadata.diagnosis_string, diagnosisString)));
end

% Identify rows with NaN values or zero counts for any sex
rows_with_nan = any(isnan(nSex), 2) | ~all(nSex, 2);

% Compute correlations if valid data exists, otherwise return empty array
if ~all(rows_with_nan)
    % Exclude invalid rows and compute correlations
    [varTable, DifVar1, DifVar2, DifSumVar, DifVar1vsVar2]  = cal_var(nSex(~rows_with_nan, :), corTmap1(~rows_with_nan, ~rows_with_nan), iter, type);
else
    % No valid data; return empty result
    varTable = [];
end

end