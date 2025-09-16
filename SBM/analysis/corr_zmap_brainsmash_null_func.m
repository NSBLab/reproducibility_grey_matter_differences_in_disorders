function corr_zmap_brainsmash_null_func(iNull, iCOMBAT, hemi, smoothKernel)
% This function calculates the correlation of surrogate z-maps generated 
% using BrainSMASH null models for different diagnostic groups and sites. 
% The results are saved for subsequent analysis.

% Inputs:
% - iNull: Index specifying the particular surrogate null model to use.
% - iCOMBAT: Indicator for whether the COMBAT harmonization was applied (1 = COMBAT, 0 = no COMBAT).
% - hemi: Hemisphere indicator (not explicitly used in the function but included for potential extensions).
% - smoothKernel: Smoothing kernel size used in data preprocessing.

% Define diagnostic groups to analyze.
diagString = {'HC', 'BD', 'SCA', 'SCZ', 'ASD', 'MDD', 'AD'}; % Include HC (healthy controls) and six disorders.
nDiag = length(diagString) - 1; % Exclude HC from correlation calculations.

% Define the address where data is stored based on the COMBAT flag.
if iCOMBAT == 1
    address = ['/scratch2/kg98/trangc/VBM/data/nulltest/surrogateSBM/s', num2str(smoothKernel), 'COMBAT'];
else
    address = ['/scratch2/kg98/trangc/VBM/data/nulltest/surrogateSBM/s', num2str(smoothKernel)];
end

% Load metadata containing diagnostic and site information.
metadata = readtable('/projects/kg98/trangc/VBM/data/metadataSBM.csv');

% Initialize a cell array to store correlation matrices for each diagnostic group.
corNull = cell(nDiag, 1);

% Loop through each diagnostic group (excluding HC).
for iDiag = 1:nDiag
    iDiag % Display the current diagnostic group index for tracking.

    % Identify rows in metadata corresponding to the current diagnostic group.
    [LaDiag, LbDiag] = ismember(metadata.diagnosis, (iDiag + 1));

    % Extract unique site information for the current diagnostic group.
    [siteString, ia, ic] = unique(metadata.site_string(LaDiag));
    diagFolder = ['diag', char(num2str(iDiag + 1))]; % Define folder name for the diagnostic group.
    [diagnosisString, ia, ic] = unique(metadata.diagnosis_string(LaDiag));

    nSite = length(siteString); % Determine the number of unique sites.

    % Loop through each site within the diagnostic group.
    for iSite = 1:nSite
        % Define the file path to the surrogate z-map for the current site.
        file1 = ([address, '/', char(diagFolder), '/', char(siteString(iSite)), '/z_surrogate.txt']);
        
        % Load surrogate data, reshaped for compatibility with subsequent operations.
        surrogateMap = reshape(dlmread(file1), [], 1000);
        
        % Extract the surrogate map corresponding to the specified iNull index.
        mapAllNull(iSite, :) = surrogateMap(:, iNull);
    end

    % Compute the correlation matrix for the surrogate maps across all sites.
    corNull{iDiag} = corr(mapAllNull');
    
    % Clear the temporary variable to free memory for the next iteration.
    clear mapAllNull
end

% Save the computed correlation matrices to an output file for later use.
save(['output/corr_null_zmap_brainsmash_combat', char(num2str(iCOMBAT)), ...
    '_smooth', char(num2str(smoothKernel)), '_', char(num2str(iNull)), '.mat'], 'corNull');

end
