function [varTable, nSite] = cor_var_age(metadata, diagnosisString, corTmap1, corTmap2, siteList,iter, type)
% Computes correlations between age-related statistics at sites and brain t-map correlations for a given diagnosis.
%
% INPUT:
%   metadata        : Table containing metadata for all subjects
%   diagnosisString : String specifying the diagnosis to analyze
%   corTmap1        : Correlation matrix of t-maps for HC > Patients
%   corTmap2        : Correlation matrix of t-maps for HC < Patients
%   iter            : Number of iterations for the Mantel test
%   type            : Type of correlation to use (e.g., 'spearman', 'pearson')
%
% OUTPUT:
%   varTable        : Table summarizing correlations and p-values for age statistics
%   nSite           : Number of unique sites included in the analysis


nSite = length(siteList); % Total number of unique sites

% Initialize mean and standard deviation of age for each site
for iSite = 1:nSite
    % Compute the mean age for subjects at the current site, including HC and the target diagnosis
    age(iSite, 1) = mean(metadata.age(ismember(metadata.site_string, siteList(iSite)) & ...
                                       (ismember(metadata.diagnosis_string, 'HC') | ismember(metadata.diagnosis_string, diagnosisString))));
    
    % Compute the standard deviation of age for subjects at the current site
    age(iSite, 2) = std(metadata.age(ismember(metadata.site_string, siteList(iSite)) & ...
                                      (ismember(metadata.diagnosis_string, 'HC') | ismember(metadata.diagnosis_string, diagnosisString))));
end

% Compute correlations using the helper function 'cal_var_age'
varTable = cal_var_age(age, corTmap1, corTmap2, iter, type);

end