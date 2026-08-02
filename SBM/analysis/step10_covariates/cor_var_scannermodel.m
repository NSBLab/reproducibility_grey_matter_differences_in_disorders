function [varTable modelSim nEffect] = cor_var_scannermodel(metadata, diagnosisString, corTmap1, siteList, iter, type )
% This function calculates the confounding effect of scanner model similarity
% between sites on the correlation matrix (corTmap1) for a specific diagnosis.

% Inputs:
% metadata: Table containing site and scanner metadata
% diagnosisString: Diagnosis of interest
% corTmap1: Correlation matrix between sites
% iter: Number of iterations for Mantel test
% type: Type of correlation (e.g., 'spearman')

% Outputs:
% varTable: Table of variance results based on scanner similarity
% nEffect: Number of effective sites used in the analysis (excluding rows with NaN or empty scanner information)

nSite = length(siteList);

% Match the diagnosis group in metadata with the specified diagnosisString.
metadataUsed = metadata(ismember(metadata.Diagnosis, diagnosisString),:);

% Extract scanner information for the matched sites.
[lia Lob] = ismember(siteList, reverse_change_siteName(metadataUsed.Site)) ;
siteScanner = metadataUsed{Lob,"Scanner model"};



% Identify rows with missing or empty scanner information
rows_with_nan = strcmp(siteScanner, '');

% If valid rows exist, calculate the variance related to scanner similarity
if ~all(rows_with_nan)
    [varTable DifVar] = cal_var_scanner(siteScanner(~rows_with_nan, :), corTmap1(~rows_with_nan, ~rows_with_nan), iter, type);
modelSim(~rows_with_nan, ~rows_with_nan) = DifVar;
else
    varTable = []; % Return empty if all rows are invalid
    modelSim = [];
end

% Calculate the number of effective sites
if isempty(varTable)
    nEffect = []; % Return empty if no valid data
else
    nEffect = nSite - sum(rows_with_nan); % Count non-missing rows
end

end