% read all the z-maps and correlate them

clear all
% Clear all variables from the workspace.

% list of disorders
diagString = {'HC', 'BD', 'SCA',...
    'SCZ', 'ASD', 'MDD' ,'AD'};
% Define diagnostic groups. The first group ('HC') is excluded later in the analysis.

% % Add paths to necessary functions and libraries
% addpath('/home/trangc/kg98/trangc/MBM/func');
% addpath('/home/trangc/kg98/trangc/VBM/code/utils');
% addpath('/home/trangc/kg98/trangc/library/fdr_bh');
% addpath(genpath('/projects/kg98/trangc/library/BrainSpace'));
% addpath(genpath('/projects/kg98/trangc/library'));

% % list of dataset
% dataDir = '/projects/kg98/trangc/VBM/data';
% dataFilePS = readtable(fullfile(dataDir,'dataset_list_VBM.txt'),'ReadVariableNames',false);
% % Read the dataset list from a text file. The file doesn't include variable names.
% 
% dataList = dataFilePS.Var1;
% % Extract the dataset names as a list.

iCOMBAT = 1;
% Flag indicating if COMBAT harmonization is applied (1 = yes, 0 = no).

% measureShort = 'thick';
% measure = 'thickness';
% % Variables for naming conventions related to the measure (e.g., cortical thickness).

smoothKernel = 6;
% Smoothing kernel size used in preprocessing.

% thres = 0.05;
% % Statistical threshold for analysis.

nNull = 7;
% Number of null maps to process.

% % find all sites
% if iCOMBAT == 1
%     address = ['/scratch2/kg98/trangc/VBM/data/nulltest/surrogateVBM/s',num2str(smoothKernel),'COMBAT/'];
% else
%     address = ['/scratch2/kg98/trangc/VBM/data/nulltest/surrogateVBM/s',num2str(smoothKernel),'/'];
% end
% % Construct the directory path based on the smoothing kernel and COMBAT flag.

%%
corNullAll = cell(1,6);
% Initialize a cell array to store correlations for each diagnostic group.

%%
for iDiag = 1:length(diagString)-1
    % Loop over diagnostic groups, excluding the last one ('AD').

    for iNull = 1:nNull
        % Loop over all null map indices.

        load(['output/corr_null_tmap_brainsmash_combat',char(num2str(iCOMBAT)),'_smooth',char(num2str(smoothKernel)),'_',char(num2str(iNull)),'.mat'], 'corNull');
        % Load the correlation matrix for the current diagnostic group and null index.

        ids = find(triu(ones(size(corNull{iDiag})),1));
        % Get indices of the upper triangular part of the correlation matrix, excluding the diagonal.

        temp = corNull{iDiag}(ids);
        % Extract the upper triangular values as a vector.

        corNullAll{iDiag} = [corNullAll{iDiag}; temp];
        % Append the vector to the cell array for the current diagnostic group.
    end
end

%%
save(['output/corr_null_tmap_combat',num2str(iCOMBAT),'_smooth',num2str(smoothKernel),'_voxel_all.mat'],...
    'corNullAll');
% Save the concatenated correlation values for all diagnostic groups and null maps to a MAT file.
