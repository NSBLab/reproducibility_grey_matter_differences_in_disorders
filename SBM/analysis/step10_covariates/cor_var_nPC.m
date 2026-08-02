function [varTable, patientRatio, controlRatio, subjectRatio, patientControlRatio, nSite] = cor_var_nPC(metadata, diagnosisString, corTmap1, siteList,iter, type)
% Compute correlation matrix of t-maps based on subject counts per site
%
% INPUT:
%   metadata        : Struct containing study metadata with fields:
%                     - diagnosis_string: Diagnoses of subjects.
%                     - site_string     : Site information for each subject.
%   diagnosisString : Cell array of diagnosis strings to analyze.
%   corTmap1        : Correlation matrix of z-maps across sites (nSite x nSite).
%   iter            : Number of iterations for the Mantel test.
%   type            : Type of correlation to compute ('pearson', 'spearman', etc.).
%
% OUTPUT:
%   varTable        : Table summarizing Mantel test results, including correlation values and p-values.
%   nSite           : Number of unique sites included in the analysis.
%
% DESCRIPTION:
%   This function calculates the number of subjects (patients and healthy controls) for each site 
%   and assesses the relationship between these counts and the provided correlation matrix using 
%   the Mantel test.

nSite = length(siteList);  % Count the number of unique sites

% Initialize matrix to store subject counts
nPC = zeros(nSite, 2);

% Compute subject counts for each site
for iSite = 1:nSite
    % Count the number of patients (matching diagnosisString) at the site
    nPC(iSite,1) = sum(ismember(metadata.diagnosis_string, diagnosisString) & ismember(metadata.site_string, siteList(iSite)));
    
    % Count the number of healthy controls (HC) at the site
    nPC(iSite,2) = sum(ismember(metadata.diagnosis_string, 'HC') & ...
                       ismember(metadata.site_string, siteList(iSite)));
end

% Calculate correlation matrix and perform Mantel test based on subject counts
[varTable,  patientRatio, controlRatio, subjectRatio, patientControlRatio]= cal_var(nPC, corTmap1, iter, type);

end