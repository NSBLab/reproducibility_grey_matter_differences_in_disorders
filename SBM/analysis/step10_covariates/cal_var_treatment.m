function [varTable DifVar1] = cal_var_treatment(nPC, corTmap1, iter, type)
% Calculate correlation matrix of the t-maps for each disorder
%
% INPUT:
%   nPC        : Treatment proportions across sites (nSite x 1 matrix).
%   corTmap1   : Correlation matrix of z-maps across sites (nSite x nSite).
%   iter       : Number of iterations for the Mantel test.
%   type       : Type of correlation to compute ('pearson', 'spearman', etc.).
%
% OUTPUT:
%   varTable   : Table summarizing Mantel test results, including correlation values and p-values.
%
% DESCRIPTION:
%   This function calculates the relationship between site-specific treatment proportions and 
%   the correlation matrix of z-maps across sites using the Mantel test. Visualizations of 
%   relationships are generated, and the results are stored in a structured table format.

% Add custom library to the MATLAB path
addpath('/projects/kg98/trangc/library')

% Initialize variables
nSite = size(corTmap1, 1);  % Number of sites
DifVar1 = zeros(nSite, nSite);  % Initialize difference matrix

% Compute pairwise distance based on treatment proportions
for iSite1 = 1:nSite
    for iSite2 = 1:nSite
        % Symmetric ratio-based calculation of differences in treatment proportions
        DifVar1(iSite1, iSite2) = nPC(iSite1,1)/nPC(iSite2,1)* (nPC(iSite1,1) < nPC(iSite2,1)) ...
                                + nPC(iSite2,1)/nPC(iSite1,1)* (nPC(iSite1,1) >= nPC(iSite2,1));
    end
end

% Handle missing values in the difference matrix
rows_with_nan = any(isnan(DifVar1), 2);
cols_with_nan = any(isnan(DifVar1), 1);

% Perform Mantel test if sufficient valid data exists
if max(size((DifVar1(~rows_with_nan, ~cols_with_nan)))) > 1
    [corvar1.Percentage(1,1), corvar1.Percentage(2,1)] = ...
        bramila_mantel(corTmap1(~rows_with_nan, ~cols_with_nan), ...
                       DifVar1(~rows_with_nan, ~cols_with_nan), ...
                       iter, type);
end

% Convert Mantel test results to a table if available
if exist("corvar1", "var")
    varTable = struct2table(corvar1, 'RowNames', {[type ' corr'], 'p'});

    % Generate scatter plot for visualization
    figure
    vectorIndex = triu(true(size(corTmap1)), 1);  % Upper triangle indices
    scatter(corTmap1(vectorIndex), DifVar1(vectorIndex))  % Scatter plot
    lsline(gca)  % Add least-squares regression line
else
    varTable = [];  % Return empty if no results available
end

end