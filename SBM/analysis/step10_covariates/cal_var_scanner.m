function [varTable DifVar1] = cal_var_scanner(nPC, corTmap1, iter, type)
% cal_var_scanner: Calculates the correlation between scanner model similarity and
% correlation matrices of z-maps for each disorder.
%
% Inputs:
% - nPC: List of scanner model types for each site (cell array or string array).
% - corTmap1: Correlation matrix of z-maps (e.g., derived from HC > P contrasts).
% - iter: Number of iterations for permutation testing (used in Mantel test).
% - type: Correlation type to be used, such as 'spearman' or 'pearson'.
%
% Outputs:
% - varTable: Table summarizing the correlation between scanner similarity and
%   t-map correlations. Includes correlation values and p-values. Returns
%   empty if scanner models are identical for all sites.
%
% Dependencies:
% - Requires the function `bramila_mantel` to perform the Mantel test.
% - Visualization relies on MATLAB's scatter plot and `lsline`.

% Add path to required libraries or dependencies
addpath('/projects/kg98/trangc/library')

% Number of sites in the correlation matrix
nSite = size(corTmap1, 1);

% Initialize a matrix to store scanner similarity information
for iSite1 = 1:nSite
    for iSite2 = 1:nSite
        % Determine whether the scanner models at two sites are the same
        % Results in a binary matrix (1 if models are the same, 0 otherwise)
        DifVar1(iSite1, iSite2) = strcmp(nPC(iSite1), nPC(iSite2));
    end
end

% Check if there is variability in scanner models across sites
if ~isequal(DifVar1, eye(size(DifVar1))) % Identity matrix means all scanners are identical
    % Perform Mantel test to assess correlation between scanner similarity
    % and z-map correlations
    [corvar1.scanner(1, 1), corvar1.scanner(2, 1)] = bramila_mantel(corTmap1, DifVar1, iter, type);

    % Convert the results structure to a table for presentation
    varTable = struct2table(corvar1, 'RowNames', {[type ' corr'], 'p' });

    % Visualize the correlation
    % Extract the upper triangle of the matrix (excluding diagonal) for scatter plot
    vectorIndex = triu(true(size(corTmap1)), 1);
    scatter(corTmap1(vectorIndex), DifVar1(vectorIndex)); % Plot z-map correlations vs. scanner similarity
    lsline(gca); % Add a least-squares regression line
else
    % If scanner models are identical, return an empty result table
    varTable = [];
end

end