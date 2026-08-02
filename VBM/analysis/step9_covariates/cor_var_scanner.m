function [varTable, nEffect] = cor_var_scanner(metadata, diagnosisString, corTmap1, corTmap2,siteList, iter, type)
% Computes the effect of scanner manufacture as a potential confound.
%
% Inputs:
%   metadata        - Table containing metadata, including diagnosis and scanner information
%   diagnosisString - String specifying the diagnosis to filter by
%   corTmap1        - Correlation matrix of HC > P t-maps
%   corTmap2        - Correlation matrix of HC < P t-maps
%   iter            - Number of iterations for permutation testing
%   type            - Type of correlation to compute (e.g., 'spearman')
%
% Outputs:
%   varTable        - Table summarizing variance related to scanner similarity
%   nEffect         - Number of effective sites considered (excluding NaN or missing values)

nSite = length(siteList); % Number of unique sites


% Match the diagnosis group in metadata with the specified diagnosisString.
metadataUsed = metadata(ismember(metadata.Diagnosis, diagnosisString),:);

% Extract scanner information for the matched sites.
[lia Lob] = ismember(siteList, reverse_change_siteName(metadataUsed.Site)) ;
siteScanner = metadataUsed{Lob,"Scanner brand"};

% Identify rows with missing or empty scanner manufacture values
rows_with_nan = strcmp(siteScanner, '');

% If there are valid scanner values, calculate variance due to scanner similarity
if ~all(rows_with_nan)
    varTable = cal_var_scanner(siteScanner(~rows_with_nan, :), ...
        corTmap1(~rows_with_nan, ~rows_with_nan), ...
        corTmap2(~rows_with_nan, ~rows_with_nan), ...
        iter, type);
else
    % If all rows have missing values, set the variance table to empty
    varTable = [];
end

% Calculate the number of effective sites (excluding rows with missing values)
nEffect = nSite - sum(rows_with_nan);
end