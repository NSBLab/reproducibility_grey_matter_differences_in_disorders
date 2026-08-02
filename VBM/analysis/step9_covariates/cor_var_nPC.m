function [varTable, nSite] = cor_var_nPC(metadata, diagnosisString, corTmap1, corTmap2,siteList, iter, type)
% Computes correlations based on the number of participants (nPC) for each site and diagnosis.
%
% INPUT:
%   metadata         : Table containing metadata for all subjects
%   diagnosisString  : String specifying the diagnosis to analyze
%   corTmap1         : Correlation matrix of t-maps for HC > Patients
%   corTmap2         : Correlation matrix of t-maps for HC < Patients
%   iter             : Number of iterations for Mantel test
%   type             : Type of correlation ('spearman', 'pearson', etc.)
%
% OUTPUT:
%   varTable         : Table summarizing the correlation results (e.g., percentage correlation, p-value)
%   nSite            : Number of unique sites in the analysis
%
% SIDE EFFECTS:
%   Calls the `cal_var` function to compute the correlation values and p-values based on participant counts.

nSite = length(siteList); % Total number of unique sites

% Initialize the number of participants (nPC) for each site
for iSite = 1:nSite
    % Calculate the number of participants in each diagnosis (for the given diagnosis and 'HC' for healthy controls)
    nPC(iSite,1) = sum(ismember(metadata.diagnosis_string, diagnosisString) & ismember(metadata.site_string, siteList(iSite)));
    nPC(iSite,2) = sum(ismember(metadata.diagnosis_string, 'HC') & ismember(metadata.site_string, siteList(iSite)));
end

% Calculate the correlation and variance using the cal_var function
varTable = cal_var(nPC, corTmap1, corTmap2, iter, type);

end