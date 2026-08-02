function varTable = cal_var_age(nPC, corTmap1, corTmap2, iter, type)
% Calculate the correlation matrix of t-maps for each disorder, considering differences in variance or mean.
%
% Inputs:
%   nPC       - Matrix with two columns: column 1 is mean, column 2 is variance of illness duration for each site.
%   corTmap1  - Correlation matrix of HC > P t-maps (healthy controls vs patients).
%   corTmap2  - Correlation matrix of HC < P t-maps.
%   iter      - Number of iterations for the Mantel test.
%   type      - Type of test to perform (e.g., Pearson, Spearman).
%
% Output:
%   varTable  - Table summarizing the Mantel test results for mean and variance.

addpath('/projects/kg98/trangc/library');
% Add the library path to use functions such as `bramila_mantel`.

nSite = size(corTmap1, 1);
% Get the number of sites.

for iSite1 = 1:nSite
    for iSite2 = 1:nSite
        % Calculate the relative difference in mean illness duration (Var1).
        DifVar1(iSite1, iSite2) = nPC(iSite1,1)/nPC(iSite2,1) * (nPC(iSite1,1) < nPC(iSite2,1)) ...
                                + nPC(iSite2,1)/nPC(iSite1,1) * (nPC(iSite1,1) >= nPC(iSite2,1));

        % Calculate the relative difference in variance of illness duration (Var2).
        DifVar2(iSite1, iSite2) = nPC(iSite1,2)/nPC(iSite2,2) * (nPC(iSite1,2) < nPC(iSite2,2)) ...
                                + nPC(iSite2,2)/nPC(iSite1,2) * (nPC(iSite1,2) >= nPC(iSite2,2));
    end
end

% Handle missing data for DifVar1
rows_with_nan = any(isnan(DifVar1), 2);
cols_with_nan = any(isnan(DifVar1), 1);

if ~isempty(DifVar1(~rows_with_nan, ~cols_with_nan))
    % Perform Mantel test between correlation matrix and mean differences (DifVar1).
    [corvar1.Mean(1,1), corvar1.Mean(2,1)] = bramila_mantel(corTmap1(~rows_with_nan, ~cols_with_nan), DifVar1(~rows_with_nan, ~cols_with_nan), iter, type);
end

% Handle missing data for DifVar2
rows_with_nan = any(isnan(DifVar2), 2);
cols_with_nan = any(isnan(DifVar2), 1);

if ~isempty(DifVar2(~rows_with_nan, ~cols_with_nan))
    % Perform Mantel test between correlation matrix and variance differences (DifVar2).
    [corvar1.Variance(1,1), corvar1.Variance(2,1)] = bramila_mantel(corTmap1(~rows_with_nan, ~cols_with_nan), DifVar2(~rows_with_nan, ~cols_with_nan), iter, type);
end

% Plot scatter plot of correlation values vs. DifVar1
figure;
vectorIndex = triu(true(size(corTmap1)), 1);
scatter(corTmap1(vectorIndex), DifVar1(vectorIndex));
lsline(gca); % Add a least-squares regression line to the scatter plot.

% Plot scatter plot of correlation values vs. DifVar2
figure;
scatter(corTmap1(vectorIndex), DifVar2(vectorIndex));
lsline(gca); % Add a least-squares regression line to the scatter plot.

% Convert Mantel test results from structure to table for output.
varTable = struct2table(corvar1, 'RowNames', {[type ' corr'], 'p'});
% Rows represent the correlation type and p-values; columns correspond to mean and variance results.

end