function varTable = cal_var_treatment(nPC, corTmap1, corTmap2, iter, type)
% calculate correlation matrix of the t-maps for each disorder
%
% INPUT:
%       nPC         : Proportions (e.g., treatment percentage) for each site
%       corTmap1    : Correlation matrix of t-maps for HC > Patients
%       corTmap2    : Correlation matrix of t-maps for HC < Patients (currently unused)
%       iter        : Number of iterations for the Mantel test
%       type        : Type of correlation ('spearman', 'pearson', etc.)
%
% OUTPUT:
%       varTable    : Table summarizing the correlation and p-value
%
% SIDE EFFECTS:
%       Generates a scatter plot of the relationship between correlations and variable differences.

addpath('/projects/kg98/trangc/library') % Add required library for Mantel test

nSite = size(corTmap1,1); % Number of sites based on the correlation matrix dimensions

% Initialize a matrix to store the difference ratios
for iSite1 = 1:nSite
    for iSite2 = 1:nSite
        % Calculate difference ratios based on proportions in nPC
        % Ensures directionality (iSite1 vs. iSite2) is accounted for
        DifVar1(iSite1, iSite2) = nPC(iSite1,1)/nPC(iSite2,1)* (nPC(iSite1,1)<nPC(iSite2,1))...
            + nPC(iSite2,1)/nPC(iSite1,1)* (nPC(iSite1,1)>=nPC(iSite2,1));
    end
end

% Identify rows or columns with NaN values to exclude invalid data
rows_with_nan = any(isnan(DifVar1), 2);
cols_with_nan = any(isnan(DifVar1), 1);

% Perform Mantel correlation if there are sufficient valid rows and columns
if max(size((DifVar1(~rows_with_nan,~cols_with_nan)))) > 1
    % Compute correlation and p-value using Mantel test
    [corvar1.Percentage(1,1), corvar1.Percentage(2,1)] = ...
        bramila_mantel(corTmap1(~rows_with_nan,~cols_with_nan), ...
                       DifVar1(~rows_with_nan,~cols_with_nan), iter, type);
end

% Check if correlation results exist, then convert to a table
if exist("corvar1","var")
    % Convert the correlation structure to a table
    varTable = struct2table(corvar1,'RowNames',{[type ' corr'], 'p' });

    % Generate a scatter plot of the relationship
    figure;
    vectorIndex = triu(true(size(corTmap1)),1); % Get the upper triangular indices
    scatter(corTmap1(vectorIndex), DifVar1(vectorIndex)); % Plot correlation vs. variable differences
    lsline(gca); % Add a least-squares fit line
else
    % If no valid correlation data, return an empty table
    varTable = [];
end

end