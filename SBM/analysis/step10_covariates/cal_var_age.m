function [varTable , DifVar1, DifVar2] = cal_var_age(nPC, corTmap1, iter, type)
% cal_var_age: Analyzes the relationship between variability in two features (mean and variance)
% of a parameter (e.g., illness duration) and the correlation matrix of z-maps across sites.
%
% Inputs:
% - nPC: Matrix containing feature values for each site.
%        Column 1: Feature 1 (e.g., mean illness duration).
%        Column 2: Feature 2 (e.g., variance of illness duration).
% - corTmap1: Correlation matrix of z-maps (HC > P).
% - iter: Number of iterations for permutation testing.
% - type: Correlation type (e.g., 'spearman' or 'pearson').
%
% Outputs:
% - varTable: Table summarizing the correlation results for Feature 1 (mean) and Feature 2 (variance),
%             including correlation values and p-values.

% Add path to required libraries or dependencies
addpath('/projects/kg98/trangc/library')

% Number of sites
nSite = size(corTmap1, 1);

% Initialize matrices to store pairwise differences between sites for two features
DifVar1 = nan(nSite, nSite); % Pairwise comparisons for Feature 1 (mean)
DifVar2 = nan(nSite, nSite); % Pairwise comparisons for Feature 2 (variance)

% Calculate pairwise differences for each feature
for iSite1 = 1:nSite
    for iSite2 = 1:nSite
        % Pairwise differences for Feature 1 (mean)
        DifVar1(iSite1, iSite2) = nPC(iSite1, 1) / nPC(iSite2, 1) * (nPC(iSite1, 1) < nPC(iSite2, 1)) + ...
                                  nPC(iSite2, 1) / nPC(iSite1, 1) * (nPC(iSite1, 1) >= nPC(iSite2, 1));

        % Pairwise differences for Feature 2 (variance)
        DifVar2(iSite1, iSite2) = nPC(iSite1, 2) / nPC(iSite2, 2) * (nPC(iSite1, 2) < nPC(iSite2, 2)) + ...
                                  nPC(iSite2, 2) / nPC(iSite1, 2) * (nPC(iSite1, 2) >= nPC(iSite2, 2));
    end
end

% Analyze the relationship between Feature 1 (mean) differences and z-map correlations
rows_with_nan = any(isnan(DifVar1), 2); % Identify rows with NaN
cols_with_nan = any(isnan(DifVar1), 1); % Identify columns with NaN
if ~isempty(DifVar1(~rows_with_nan, ~cols_with_nan)) % Ensure data exists after removing NaN
    [corvar1.Mean(1, 1), corvar1.Mean(2, 1)] = bramila_mantel(corTmap1(~rows_with_nan, ~cols_with_nan), ...
                                                              DifVar1(~rows_with_nan, ~cols_with_nan), iter, type);
end

% Analyze the relationship between Feature 2 (variance) differences and z-map correlations
rows_with_nan = any(isnan(DifVar2), 2); % Identify rows with NaN
cols_with_nan = any(isnan(DifVar2), 1); % Identify columns with NaN
if ~isempty(DifVar2(~rows_with_nan, ~cols_with_nan)) % Ensure data exists after removing NaN
    [corvar1.Variance(1, 1), corvar1.Variance(2, 1)] = bramila_mantel(corTmap1(~rows_with_nan, ~cols_with_nan), ...
                                                                      DifVar2(~rows_with_nan, ~cols_with_nan), iter, type);
end

% Visualize the relationship for Feature 1 (mean)
figure
vectorIndex = triu(true(size(corTmap1)), 1); % Upper triangle of the matrix
scatter(corTmap1(vectorIndex), DifVar1(vectorIndex)) % Scatter plot
lsline(gca) % Add least-squares fit line

% Visualize the relationship for Feature 2 (variance)
figure
scatter(corTmap1(vectorIndex), DifVar2(vectorIndex)) % Scatter plot
lsline(gca) % Add least-squares fit line

% Convert the correlation results to a table for better presentation
varTable = struct2table(corvar1, 'RowNames', {[type ' corr'], 'p'});

end