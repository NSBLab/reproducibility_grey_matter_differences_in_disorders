function [varTable, meanAge, stdAge, nSite] = cor_var_age(metadata, diagnosisString, corTmap1, siteList, iter, type)
% Analyze correlation of age-related differences in t-map data across sites
%
% INPUT:
%   metadata         : A structure containing metadata about subjects, including:
%                      - metadata.diagnosis_string: Diagnosis labels (e.g., 'HC', 'P').
%                      - metadata.site_string: Site labels for each subject.
%                      - metadata.age: Age of each subject.
%   diagnosisString  : A string or array of strings specifying the diagnoses of interest.
%   corTmap1         : Correlation matrix of t-maps (nSite x nSite).
%   iter             : Number of iterations for the Mantel test.
%   type             : Type of correlation to compute ('pearson', 'spearman', etc.).
%
% OUTPUT:
%   varTable         : Table summarizing Mantel test results for age differences.
%   nSite            : Number of unique sites in the dataset.
%
% DESCRIPTION:
%   This function calculates age statistics (mean and standard deviation) for each site,
%   focusing on subjects within the specified diagnoses and healthy controls ('HC').
%   It then computes the correlation between these age statistics and the provided 
%   correlation matrix of t-maps using a helper function (`cal_var_age`).
%
% STEPS:
%   1. Identify the rows in the metadata corresponding to the specified diagnoses (`LaDiag`).
%   2. Extract unique site identifiers and count the number of sites (`nSite`).
%   3. For each site, calculate:
%      - Mean age of subjects (`age(iSite,1)`).
%      - Standard deviation of age (`age(iSite,2)`).
%   4. Call `cal_var_age` to compute correlations and generate the results table.
%
% NOTES:
%   - Relies on the `cal_var_age` function for computing correlations and returning results.
%   - Ensures statistics are computed only for subjects belonging to the specified diagnoses
%     or healthy controls ('HC').
%
% EXAMPLE USAGE:
%   [varTable, nSite] = cor_var_age(metadata, {'P'}, corTmap1, 1000, 'spearman');


nSite = length(siteList);

% Initialize age matrix (columns: mean, standard deviation)
age = zeros(nSite, 2);

% Calculate mean and standard deviation of age for each site
for iSite = 1:nSite
    % Compute mean age for the current site
    age(iSite, 1) = mean(metadata.age(ismember(metadata.site_string, siteList(iSite)) & ...
                                      (ismember(metadata.diagnosis_string, 'HC') | ismember(metadata.diagnosis_string, diagnosisString))));
    % Compute standard deviation of age for the current site
    age(iSite, 2) = std(metadata.age(ismember(metadata.site_string, siteList(iSite)) & ...
                                     (ismember(metadata.diagnosis_string, 'HC') | ismember(metadata.diagnosis_string, diagnosisString))));
end

% Compute correlations using the helper function `cal_var_age`
[varTable, meanAge, stdAge] = cal_var_age(age, corTmap1, iter, type);

end