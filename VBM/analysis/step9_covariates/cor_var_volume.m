function [varTable, nEffect] = cor_var_volume(metadata, diagnosisString, corTmap1, corTmap2,siteList, iter, type)
% cor_var_volume: Calculates variance explained by voxel volume across sites.
%
% Inputs:
% - metadata: Table containing metadata about subjects, including site and volume information.
% - diagnosisString: String specifying the diagnosis to analyze.
% - corTmap1, corTmap2: Correlation matrices for voxel data.
% - iter: Number of iterations for permutation testing.
% - type: Type of correlation to compute (e.g., 'spearman').
%
% Outputs:
% - varTable: Table summarizing variance explained by voxel volume.
% - nEffect: Number of effective sites used in the analysis.

% Match the diagnosis group in metadata with the specified diagnosisString.
metadataUsed = metadata(ismember(metadata.Diagnosis, diagnosisString),:);

% Extract scanner information for the matched sites.
[lia Lob] = ismember(siteList, reverse_change_siteName(metadataUsed.Site)) ;
siteScanner = metadataUsed{Lob,"Voxel volume (mm3)"};
nSite = length(siteList); % Count the number of unique sites

% Identify rows with NaN values or zero volumes
rows_with_nan = any(isnan(siteScanner), 2) | ~any(siteScanner, 2);

% Proceed with variance calculation if valid rows exist and volume has variability
if ~all(rows_with_nan) && range(siteScanner) ~= 0
    % Compute variance explained by volume for valid rows
    varTable = cal_var_volume(siteScanner(~rows_with_nan, :), ...
        corTmap1(~rows_with_nan, ~rows_with_nan), ...
        corTmap2(~rows_with_nan, ~rows_with_nan), ...
        iter, type);
else
    % Set varTable to an empty array if no valid rows or insufficient volume variability
    varTable = [];
end

% Calculate the number of effective sites used in the analysis
nEffect = nSite - sum(rows_with_nan);

end