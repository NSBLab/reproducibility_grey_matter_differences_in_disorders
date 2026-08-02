function [varTable, nEffect] = cor_var_scannermodel(metadata, diagnosisString, corTmap1, corTmap2,siteList, iter, type)
% cor_var_scannermodel: Analyzes the effect of scanner model similarity as a confound
% in the correlation of t-maps for a given diagnosis.
%
% Inputs:
% - metadata: Table containing metadata for each site (including scanner model and diagnosis).
% - diagnosisString: Specific diagnosis to analyze.
% - corTmap1: Correlation matrix of t-maps (HC > P).
% - corTmap2: Correlation matrix of t-maps (HC < P).
% - iter: Number of iterations for permutation testing.
% - type: Correlation type (e.g., 'spearman').
%
% Outputs:
% - varTable: A table summarizing the results of variance analysis related to scanner models.
% - nEffect: Number of sites included in the analysis after excluding invalid entries.


nSite = length(siteList); % Total number of sites
% Match the diagnosis group in metadata with the specified diagnosisString.
metadataUsed = metadata(ismember(metadata.Diagnosis, diagnosisString),:);

% Extract scanner information for the matched sites.
[lia Lob] = ismember(siteList, reverse_change_siteName(metadataUsed.Site)) ;
siteScanner = metadataUsed{Lob,"Scanner model"};

% Identify rows with missing or invalid scanner model data
rows_with_nan = strcmp(siteScanner, '');

% Proceed only if not all rows have missing data
if ~all(rows_with_nan)
    % Calculate variance related to scanner model similarity
    varTable = cal_var_scanner(siteScanner(~rows_with_nan, :), ...
        corTmap1(~rows_with_nan, ~rows_with_nan), ...
        corTmap2(~rows_with_nan, ~rows_with_nan), iter, type);
else
    varTable = []; % Return an empty table if all rows are invalid
end

% Determine the number of effective sites included in the analysis
if isempty(varTable)
    nEffect = []; % No effective sites if varTable is empty
else
    nEffect = nSite - sum(rows_with_nan); % Subtract invalid entries from total sites
end
end