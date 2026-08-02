function [varTable nEffect] = cor_var_illness(metadata, diagnosisString, corTmap1, corTmap2, siteList,iter, type)
% Function to compute variability of correlations with illness duration.
% Inputs:
%   metadata        - Table containing metadata (e.g., diagnosis, site, illness duration).
%   diagnosisString - String specifying the diagnosis to analyze.
%   corTmap1        - Correlation map 1 (matrix).
%   corTmap2        - Correlation map 2 (matrix).
%   iter            - Number of iterations for variability calculation.
%   type            - Type of variability computation.
% Outputs:
%   varTable        - Table containing variability metrics.
%   nEffect         - Number of sites with valid data after removing NaNs.


nSite = length(siteList);
% Determine the number of unique sites.

for iSite = 1:nSite
    % Loop through each site.

    %mean
    age(iSite,1) = mean(metadata.illnessDuration(ismember(metadata.site_string, siteList(iSite)) & ...
        (ismember(metadata.diagnosis_string, 'HC') | ismember(metadata.diagnosis_string, diagnosisString)) & ...
        0 < metadata.illnessDuration & metadata.illnessDuration < 61));
    % Compute the mean illness duration for individuals at the current site, excluding invalid values.

    %var
    age(iSite,2) = std(metadata.illnessDuration(ismember(metadata.site_string, siteList(iSite)) & ...
        (ismember(metadata.diagnosis_string, 'HC') | ismember(metadata.diagnosis_string, diagnosisString)) & ...
        0 < metadata.illnessDuration & metadata.illnessDuration < 61));
    % Compute the standard deviation of illness duration for the same group.
end

rows_with_nan = any(isnan(age), 2);
% Identify rows in `age` that contain NaN values.

if ~all(rows_with_nan)
    % Proceed if not all rows contain NaNs.

    varTable = cal_var_age(age(~rows_with_nan, :), corTmap1(~rows_with_nan, ~rows_with_nan), ...
        corTmap2(~rows_with_nan, ~rows_with_nan), iter, type);
    % Compute variability metrics using valid rows only.
else
    varTable = [];
    % Return an empty variable table if all rows are invalid.
end

nEffect = nSite - sum(rows_with_nan);
% Calculate the number of sites with valid data after removing NaNs.

end