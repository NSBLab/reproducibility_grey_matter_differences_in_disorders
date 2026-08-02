function [varTable, DifVar1, DifVar2, DifSumVar, DifVar1vsVar2]  = cal_var(nPC, corTmap1, iter, type)
% Calculate correlation matrix of t-maps based on group differences
%
% INPUT:
%   nPC       : Matrix containing subject counts per site. Each row corresponds to a site:
%               - Column 1: Number of patients (group 1)
%               - Column 2: Number of healthy controls (group 2)
%   corTmap1  : Correlation matrix of t-maps across sites (nSite x nSite).
%   iter      : Number of iterations for the Mantel test.
%   type      : Type of correlation to compute ('pearson', 'spearman', etc.).
%
% OUTPUT:
%   varTable  : Table summarizing Mantel test results:
%               - group1       : Correlation and p-value for differences in group 1 (patients).
%               - group2       : Correlation and p-value for differences in group 2 (healthy controls).
%               - sumGroup     : Correlation and p-value for total subject count differences.
%               - group1vsGroup2: Correlation and p-value for group 1/group 2 ratio differences.
%
% DESCRIPTION:
%   This function computes several pairwise distance matrices based on subject counts (nPC) 
%   for sites, including differences in individual group sizes, total counts, and ratios. 
%   These distance matrices are then correlated with the provided correlation matrix of t-maps 
%   using the Mantel test. Scatter plots are generated to visualize relationships.
%
% STEPS:
%   1. Calculate pairwise distance matrices:
%      - DifVar1: Differences in patient counts between sites.
%      - DifVar2: Differences in healthy control counts between sites.
%      - DifSumVar: Differences in total subject counts between sites.
%      - DifVar1vsVar2: Differences in patient-to-control ratios between sites.
%   2. Compute correlations between these distance matrices and the t-map correlation matrix.
%   3. Plot scatter plots for visualization.
%   4. Compile results into a structured table.

addpath('/projects/kg98/trangc/library')  % Add library path for additional dependencies
nSite = size(corTmap1, 1);  % Number of sites

% Initialize distance matrices
DifVar1 = zeros(nSite, nSite);
DifVar2 = zeros(nSite, nSite);
DifSumVar = zeros(nSite, nSite);
DifVar1vsVar2 = zeros(nSite, nSite);

% Compute pairwise distance matrices for all sites
for iSite1 = 1:nSite
    for iSite2 = 1:nSite
        % Distance for group 1 (patients)
        DifVar1(iSite1, iSite2) = nPC(iSite1,1)/nPC(iSite2,1)*(nPC(iSite1,1) < nPC(iSite2,1)) ...
            + nPC(iSite2,1)/nPC(iSite1,1)*(nPC(iSite1,1) >= nPC(iSite2,1));
        
        % Distance for group 2 (healthy controls)
        DifVar2(iSite1, iSite2) = nPC(iSite1,2)/nPC(iSite2,2)*(nPC(iSite1,2) < nPC(iSite2,2)) ...
            + nPC(iSite2,2)/nPC(iSite1,2)*(nPC(iSite1,2) >= nPC(iSite2,2));
        
        % Distance for total subject counts
        DifSumVar(iSite1, iSite2) = sum(nPC(iSite1,:))/sum(nPC(iSite2,:))*(sum(nPC(iSite1,:)) > sum(nPC(iSite2,:))) ...
            + sum(nPC(iSite2,:))/sum(nPC(iSite1,:))*(sum(nPC(iSite1,:)) <= sum(nPC(iSite2,:)));
        
        % Distance for group 1/group 2 ratios
        DifVar1vsVar2(iSite1, iSite2) = (nPC(iSite1,1)/nPC(iSite1,2))/(nPC(iSite2,1)/nPC(iSite2,2)) ...
            * ((nPC(iSite1,1)/nPC(iSite1,2)) > (nPC(iSite2,1)/nPC(iSite2,2))) ...
            + (nPC(iSite2,1)/nPC(iSite2,2))/(nPC(iSite1,1)/nPC(iSite1,2)) ...
            * ((nPC(iSite1,1)/nPC(iSite1,2)) <= (nPC(iSite2,1)/nPC(iSite2,2)));
    end
end

% Compute Mantel test correlations and p-values
[corvar1.group1(1,1), corvar1.group1(2,1)] = bramila_mantel(corTmap1, DifVar1, iter, type);
[corvar1.group2(1,1), corvar1.group2(2,1)] = bramila_mantel(corTmap1, DifVar2, iter, type);
[corvar1.sumGroup(1,1), corvar1.sumGroup(2,1)] = bramila_mantel(corTmap1, DifSumVar, iter, type);
[corvar1.group1vsGroup2(1,1), corvar1.group1vsGroup2(2,1)] = bramila_mantel(corTmap1, DifVar1vsVar2, iter, type);

% Generate scatter plots for visualization
vectorIndex = triu(true(size(corTmap1)), 1);  % Upper triangle indices
figure;
scatter(corTmap1(vectorIndex), DifVar1(vectorIndex)); lsline(gca); title('DifVar1');
figure;
scatter(corTmap1(vectorIndex), DifVar2(vectorIndex)); lsline(gca); title('DifVar2');
figure;
scatter(corTmap1(vectorIndex), DifSumVar(vectorIndex)); lsline(gca); title('DifSumVar');
figure;
scatter(corTmap1(vectorIndex), DifVar1vsVar2(vectorIndex)); lsline(gca); title('DifVar1vsVar2');

% Compile results into a structured table
varTable = struct2table(corvar1, 'RowNames', {[type, ' corr'], 'p'});

end