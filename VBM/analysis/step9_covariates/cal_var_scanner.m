function varTable = cal_var_scanner(nPC, corTmap1, corTmap2, iter, type)
% cal_var_scanner: Calculates the correlation between scanner model similarity and
% correlation matrices of t-maps for each disorder.
%
% Inputs:
% - nPC: List of scanner model types for each site.
% - corTmap1: Correlation matrix of t-maps (HC > P).
% - corTmap2: Correlation matrix of t-maps (HC < P).
% - iter: Number of iterations for permutation testing.
% - type: Correlation type (e.g., 'spearman').
%
% Outputs:
% - varTable: Table summarizing the correlation between scanner similarity and t-map correlations.
%             Includes correlation values and p-values.

% Add path to required libraries or dependencies
addpath('/projects/kg98/trangc/library');

% Number of sites
nSite = size(corTmap1, 1);

% Initialize a matrix to store scanner similarity information
for iSite1 = 1:nSite
    for iSite2 = 1:nSite
        % Determine whether the scanner models at two sites are the same
        DifVar1(iSite1, iSite2) = strcmp(nPC(iSite1), nPC(iSite2));
    end
end

% Check if DifVar1 is not the identity matrix (indicating variability in scanner models)
if ~isequal(DifVar1, eye(size(DifVar1)))
    % Perform Mantel test to calculate the correlation between scanner similarity
    % and the t-map correlation matrices
    [corvar1.scanner(1, 1), corvar1.scanner(2, 1)] = bramila_mantel(corTmap1, DifVar1, iter, type);
    
    % Convert the result structure to a table for better presentation
    varTable = struct2table(corvar1, 'RowNames', {[type ' corr'], 'p'});
    
    % Visualize the relationship between t-map correlations and scanner similarity
    figure;
    vectorIndex = triu(true(size(corTmap1)), 1); % Indices of the upper triangle
    scatter(corTmap1(vectorIndex), DifVar1(vectorIndex)); % Scatter plot
    lsline(gca); % Add a least-squares line to the plot
else
    % If all scanner models are identical, return an empty table
    varTable = [];
end

end