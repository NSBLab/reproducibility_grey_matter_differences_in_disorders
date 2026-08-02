 function [varTable, scannerSim, nEffect] = cor_var_scanner(metadata, diagnosisString, corTmap1, siteList, iter, type)
% This function calculates the correlation between scanner models and
% the correlation matrix of T-maps for a specific diagnostic group.
% 
% Inputs:
% - metadata: A table containing information about sites, diagnoses, and scanners.
% - diagnosisString: The diagnosis of interest (e.g., 'BD', 'SCZ').
% - corTmap1: A correlation matrix of T-maps for the diagnostic group.
% - iter: Number of iterations for the statistical test (e.g., Mantel test).
% - type: Correlation type for the analysis (e.g., 'spearman', 'pearson').
%
% Outputs:
% - varTable: A table containing correlation results between scanner models 
%   and T-map correlations. Returns empty if no valid data exists.
% - nEffect: The number of sites with valid scanner information.

nSite = length(siteList);

% Match the diagnosis group in metadata with the specified diagnosisString.
metadataUsed = metadata(ismember(metadata.Diagnosis, diagnosisString),:);

% Extract scanner information for the matched sites.
[lia Lob] = ismember(siteList, reverse_change_siteName(metadataUsed.Site)) ;
siteScanner = metadataUsed{Lob,"Scanner brand"};


% Identify rows where scanner information is missing (empty strings).
rows_with_nan = strcmp(siteScanner, '');

% Check if there are valid scanner entries for correlation computation.
if ~all(rows_with_nan) 
    % Compute correlations if there are valid scanner entries.
    [varTable DifVar]  = cal_var_scanner(siteScanner(~rows_with_nan, :), ...
        corTmap1(~rows_with_nan, ~rows_with_nan), iter, type);
    scannerSim(~rows_with_nan, ~rows_with_nan) = DifVar;
else
    % Return an empty table if all scanner information is missing.
    varTable = [];
    scannerSim = [];
end

% Calculate the effective number of sites with valid scanner information.
nEffect = nSite - sum(rows_with_nan);

end