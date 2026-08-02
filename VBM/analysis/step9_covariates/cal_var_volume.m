function varTable = cal_var_volume(nPC, corTmap1, corTmap2, iter, type)
% cal_var_volume: Calculates the correlation between voxel volume differences
% and the correlation matrices of t-maps for a given disorder.
%
% Inputs:
% - nPC: Number of voxels (or principal components) per site.
% - corTmap1: Correlation matrix of t-maps (HC > P).
% - corTmap2: Correlation matrix of t-maps (HC < P).
% - iter: Number of iterations for Mantel test.
% - type: Correlation type (e.g., 'spearman').
%
% Outputs:
% - varTable: A table summarizing the Mantel test results (correlation and p-value).
%
% Additional:
% - Produces a scatter plot of the correlation matrix values vs. volume differences.

% Add necessary libraries to the MATLAB path
addpath('/projects/kg98/trangc/library');

% Initialize variables
nSite = size(corTmap1, 1); % Number of sites based on the size of the correlation matrix
DifVar1 = zeros(nSite, nSite); % Preallocate matrix for differences in voxel volume

% Compute pairwise differences in voxel volume between sites
for iSite1 = 1:nSite
    for iSite2 = 1:nSite
        % Calculate the ratio of voxel volumes between two sites
        DifVar1(iSite1, iSite2) = ...
            nPC(iSite1, 1) / nPC(iSite2, 1) * (nPC(iSite1, 1) < nPC(iSite2, 1)) + ...
            nPC(iSite2, 1) / nPC(iSite1, 1) * (nPC(iSite1, 1) >= nPC(iSite2, 1));
    end
end

% Perform Mantel test to evaluate correlation between t-map correlations and volume differences
[corvar1.volume(1, 1), corvar1.volume(2, 1)] = ...
    bramila_mantel(corTmap1, DifVar1, iter, type);

% Generate a scatter plot to visualize the relationship
figure;
vectorIndex = triu(true(size(corTmap1)), 1); % Get upper triangle indices of the matrix
scatter(corTmap1(vectorIndex), DifVar1(vectorIndex)); % Scatter plot of correlation values vs. volume differences
lsline(gca); % Add a least-squares line to the scatter plot

% Convert the Mantel test results into a table
varTable = struct2table(corvar1, 'RowNames', {[type ' corr'], 'p'});
end