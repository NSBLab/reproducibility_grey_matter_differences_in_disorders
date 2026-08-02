function [varTable DifVar1] = cal_var_volume(nPC, corTmap1, iter, type)
    % CAL_VAR_VOLUME computes the correlation between site-level variance and correlation matrix of t-maps.
    %
    % Inputs:
    % - nPC: A matrix where each row corresponds to site-level values (e.g., principal components or variance measures).
    % - corTmap1: Correlation matrix of t-maps for HC>P or HC<P.
    % - iter: Number of iterations for statistical tests (e.g., Mantel test).
    % - type: Type of correlation to compute (e.g., Pearson, Spearman).
    %
    % Output:
    % - varTable: A table containing correlation values and p-values for the analysis.
    %
    % Description:
    % This function computes pairwise differences between site-level variances, tests for correlations 
    % with the t-map correlation matrix using the Mantel test, and visualizes the relationship.

    % Add necessary libraries to the path.
    addpath('/projects/kg98/trangc/library');

    % Number of sites in the correlation matrix.
    nSite = size(corTmap1, 1);

    % Initialize the difference matrix for pairwise comparisons of variance (nPC).
    for iSite1 = 1:nSite
        for iSite2 = 1:nSite
            % Compute pairwise differences in variance (normalized ratio).
            DifVar1(iSite1, iSite2) = nPC(iSite1, 1) / nPC(iSite2, 1) * (nPC(iSite1, 1) < nPC(iSite2, 1)) ...
                                    + nPC(iSite2, 1) / nPC(iSite1, 1) * (nPC(iSite1, 1) >= nPC(iSite2, 1));
        end
    end

    % Compute the Mantel test for correlation between t-map correlation and variance difference.
    [corvar1.volume(1, 1), corvar1.volume(2, 1)] = bramila_mantel(corTmap1, DifVar1, iter, type);

    % Create a scatter plot of correlation values versus variance differences.
    figure;
    vectorIndex = triu(true(size(corTmap1)), 1); % Upper triangle indices of the correlation matrix.
    scatter(corTmap1(vectorIndex), DifVar1(vectorIndex)); % Scatter plot of values.
    lsline(gca); % Add a least-squares fit line to the plot.

    % Convert results to a table for output, with type and p-value.
    varTable = struct2table(corvar1, 'RowNames', {[type ' corr'], 'p'});
end