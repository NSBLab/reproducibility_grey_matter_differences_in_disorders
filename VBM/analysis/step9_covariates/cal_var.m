function varTable = cal_var(nPC, corTmap1, corTmap2, iter, type)
% Calculates the correlation matrix of t-maps for each disorder using distance metrics.
%
% INPUT:
%   nPC        : Matrix of participant counts per site for each group
%   corTmap1   : Correlation matrix of t-maps for HC > Patients
%   corTmap2   : Correlation matrix of t-maps for HC < Patients
%   iter       : Number of iterations for the Mantel test
%   type       : Type of correlation to compute ('spearman', 'pearson', etc.)
%
% OUTPUT:
%   varTable   : Table summarizing correlation results (e.g., correlation values and p-values)

% Add the required library for the Mantel test
addpath('/projects/kg98/trangc/library')

% Number of sites
nSite = size(corTmap1, 1);

% Compute pairwise distance metrics for each site
for iSite1 = 1:nSite
    for iSite2 = 1:nSite
        % Ratio of group 1 participants between sites
        DifVar1(iSite1, iSite2) = nPC(iSite1, 1) / nPC(iSite2, 1) * (nPC(iSite1, 1) < nPC(iSite2, 1)) ...
            + nPC(iSite2, 1) / nPC(iSite1, 1) * (nPC(iSite1, 1) >= nPC(iSite2, 1));
        
        % Ratio of group 2 participants between sites
        DifVar2(iSite1, iSite2) = nPC(iSite1, 2) / nPC(iSite2, 2) * (nPC(iSite1, 2) < nPC(iSite2, 2)) ...
            + nPC(iSite2, 2) / nPC(iSite1, 2) * (nPC(iSite1, 2) >= nPC(iSite2, 2));
        
        % Ratio of total participants between sites
        DifSumVar(iSite1, iSite2) = sum(nPC(iSite1, :)) / sum(nPC(iSite2, :)) * (sum(nPC(iSite1, :)) > sum(nPC(iSite2, :))) ...
            + sum(nPC(iSite2, :)) / sum(nPC(iSite1, :)) * (sum(nPC(iSite1, :)) <= sum(nPC(iSite2, :)));
        
        % Ratio of group 1 to group 2 participants between sites
        DifVar1vsVar2(iSite1, iSite2) = (nPC(iSite1, 1) / nPC(iSite1, 2)) / (nPC(iSite2, 1) / nPC(iSite2, 2)) ...
            * ((nPC(iSite1, 1) / nPC(iSite1, 2)) > (nPC(iSite2, 1) / nPC(iSite2, 2))) ...
            + (nPC(iSite2, 1) / nPC(iSite2, 2)) / (nPC(iSite1, 1) / nPC(iSite1, 2)) ...
            * ((nPC(iSite1, 1) / nPC(iSite1, 2)) <= (nPC(iSite2, 1) / nPC(iSite2, 2)));
    end
end

% Perform Mantel tests for each distance metric
[corvar1.group1(1, 1), corvar1.group1(2, 1)] = bramila_mantel(corTmap1, DifVar1, iter, type);
[corvar1.group2(1, 1), corvar1.group2(2, 1)] = bramila_mantel(corTmap1, DifVar2, iter, type);
[corvar1.sumGroup(1, 1), corvar1.sumGroup(2, 1)] = bramila_mantel(corTmap1, DifSumVar, iter, type);
[corvar1.group1vsGroup2(1, 1), corvar1.group1vsGroup2(2, 1)] = bramila_mantel(corTmap1, DifVar1vsVar2, iter, type);

% Plot scatter plots for each distance metric against t-map correlations
figure;
vectorIndex = triu(true(size(corTmap1)), 1);
scatter(corTmap1(vectorIndex), DifVar1(vectorIndex));
lsline(gca);

figure;
scatter(corTmap1(vectorIndex), DifVar2(vectorIndex));
lsline(gca);

figure;
scatter(corTmap1(vectorIndex), DifSumVar(vectorIndex));
lsline(gca);

figure;
scatter(corTmap1(vectorIndex), DifVar1vsVar2(vectorIndex));
lsline(gca);

% Convert results to a table
varTable = struct2table(corvar1, 'RowNames', {[type, ' corr'], 'p'});

end