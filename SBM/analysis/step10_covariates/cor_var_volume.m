function [varTable volRatio nEffect] = cor_var_volume(metadata, diagnosisString, corTmap1, siteList,iter, type )
    % COR_VAR_VOLUME computes variance of volume across sites for specific diagnoses.
    %
    % Inputs:
    % - metadata: A structure containing site, diagnosis, and volume information.
    % - diagnosisString: A cell array of diagnosis strings to filter the data.
    % - corTmap1: Correlation matrix (or other site-to-site metric).
    % - iter: Number of iterations for the variance calculation.
    % - type: Indicator for the type of variance calculation to perform.
    %
    % Outputs:
    % - varTable: Table containing the computed variance. Empty if conditions are not met.
    % - nEffect: The number of valid sites used in the calculation.

    % Match the diagnosis group in metadata with the specified diagnosisString.
metadataUsed = metadata(ismember(metadata.Diagnosis, diagnosisString),:);

% Extract scanner information for the matched sites.
[lia Lob] = ismember(siteList, reverse_change_siteName(metadataUsed.Site)) ;
siteScanner = metadataUsed{Lob,"Voxel volume (mm3)"};


    % Total number of unique sites.
    nSite = length(siteList);

    % Identify rows with NaN or invalid values (e.g., zero volume).
    rows_with_nan = any(isnan(siteScanner), 2) | ~any(siteScanner, 2);

    % Check if all rows are invalid or if the volume range is zero.
    if ~all(rows_with_nan) && range(siteScanner) ~= 0
        % Perform variance calculation using only valid rows.
        [varTable DifVar] = cal_var_volume(siteScanner(~rows_with_nan, :), ...
                                  corTmap1(~rows_with_nan, ~rows_with_nan), ...
                                  iter, type);
        volRatio(~rows_with_nan, ~rows_with_nan) = DifVar;
    else
        % Return an empty table if all rows are invalid or no variance exists.
        varTable = [];
        volRatio = [];
    end

    % Number of valid sites used in the calculation.
    nEffect = nSite - sum(rows_with_nan);
end