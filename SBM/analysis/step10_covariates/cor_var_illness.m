function [varTable, meanIllness, varIllness, nEffect] = cor_var_illness(metadata, diagnosisString, corTmap1, siteList, iter, type)
% cor_var_illness: Analyzes the relationship between illness duration variability 
% and the correlation matrix of z-maps across sites.
%
% Inputs:
% - metadata: Table containing site information, diagnosis, and illness duration.
% - diagnosisString: String representing the diagnosis of interest (e.g., 'SCZ').
% - corTmap1: Correlation matrix of z-maps (HC > P).
% - iter: Number of iterations for permutation testing.
% - type: Correlation type (e.g., 'spearman' or 'pearson').
%
% Outputs:
% - varTable: Table summarizing the correlation between illness duration and z-map correlations.
% - nEffect: Number of sites with non-NaN illness duration data.


nSite = length(siteList);

% Initialize matrix to store mean and standard deviation of illness duration
age = nan(nSite, 2); % Each row corresponds to a site; columns: [mean, std deviation]

% Iterate through each site to calculate mean and standard deviation of illness duration
for iSite = 1:nSite
    % Define the condition for selecting valid illness duration data:
    % - Belongs to the current site
    % - Diagnosis matches either HC or the specified diagnosis
    % - Illness duration is within the range (0, 61)
    validCondition = ismember(metadata.site_string, siteList(iSite)) & ...
        (ismember(metadata.diagnosis_string, 'HC') | ismember(metadata.diagnosis_string, diagnosisString)) & ...
        (0 < metadata.illnessDuration & metadata.illnessDuration < 61);

    % Calculate mean and standard deviation of illness duration for the current site
    age(iSite, 1) = mean(metadata.illnessDuration(validCondition)); % Mean duration
    age(iSite, 2) = std(metadata.illnessDuration(validCondition));  % Standard deviation
end

% Identify sites with NaN values (due to insufficient or invalid data)
rows_with_nan = any(isnan(age), 2);

% Check if there are valid rows remaining after removing NaN rows
if ~all(rows_with_nan)
    % Call the function to calculate the correlation between age and z-map correlations
    [varTable, DifVar1, DifVar2] = cal_var_age(age(~rows_with_nan, :), corTmap1(~rows_with_nan, ~rows_with_nan), iter, type);
    meanIllness(~rows_with_nan, ~rows_with_nan) = DifVar1;
    varIllness(~rows_with_nan, ~rows_with_nan) = DifVar2;
else
    % If all rows contain NaN, return an empty table
    varTable = [];
    meanIllness = [];
    varIllness = [];
end

% Calculate the number of sites with valid illness duration data
nEffect = nSite - sum(rows_with_nan);

end