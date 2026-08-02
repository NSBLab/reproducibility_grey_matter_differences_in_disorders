%% 
% Consider the confound of age.
% 
% Mean: ratio of age mean between sites
% 
% Variance: ratio of age variance between sites
% 
% 

% Clear all variables and close all figures
clear all
close all

% Initialize parameters
iCOMBAT = 1; % Flag to determine if COMBAT harmonization is used
smoothKernel = 6; % Smoothing kernel size
iter = 5000; % Number of iterations for permutation testing
type = 'spearman'; % Correlation type (Spearman)
diagnosisString = {'BD', 'SCA', 'SCZ', 'ASD', 'MDD', 'AD'}; % List of diagnoses to analyze

nDiag = length(diagnosisString); % Number of diagnoses

% Set the address path based on whether COMBAT harmonization is applied
if iCOMBAT == 1
    address = ['derivatives/s', num2str(smoothKernel), 'COMBAT/'];
else
    address = ['derivatives/s', num2str(smoothKernel), '/'];
end

% Load metadata about demographics and site information
metadata = readtable(['/projects/kg98/trangc/VBM/data/metadataVBM_extended.csv']);
% Load pre-computed correlation matrices and site lists
load(['output/corr_tmap_combat',num2str(iCOMBAT),'_smooth',num2str(smoothKernel),'.mat'], 'cor1', 'cor2',"siteList")

% Loop through each diagnosis
for iDiag = 1:nDiag
    % Compute variance related to age and site correlation
    [varTable{iDiag} nSite{iDiag}]= cor_var_age(metadata, ...
        diagnosisString(iDiag), cor1{iDiag}, cor2{iDiag}, siteList{iDiag},iter, type);

 % Display results if the variance table is not empty
    if size(varTable,1)~=0
        disp(char(diagnosisString(iDiag))); % Display diagnosis name
        disp(varTable{iDiag}); % Display variance table
        disp(' '); % Add spacing
        disp(' ')
    end
end

% Suppress specific warnings and save the results

warning('off','last')
save('output/confound_age.mat','varTable','nSite')