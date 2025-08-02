% Function to compute correlation matrices for surrogate null maps between
% themselves or vs original maps
% Inputs:
%   iNull       - Index for selecting a specific surrogate null map.
%   iCOMBAT     - Flag indicating if COMBAT harmonization is applied (1 = yes, 0 = no).
%   smoothKernel - Smoothing kernel size used in preprocessing.
clear all
iCOMBAT = 1;
smoothKernel = 6;
diagString = {'HC', 'BD', 'SCA',...
    'SCZ', 'ASD', 'MDD' ,'AD'};
addpath('/home/trangc/kg98/trangc/library/Violinplot-Matlab-master')
% Define diagnostic labels for analysis. First one ('HC') is excluded from `nDiag`.

nDiag = length(diagString)-1;
% Number of diagnostic groups to process, excluding 'HC'.

if iCOMBAT == 1
    address = ['/scratch2/kg98/trangc/VBM/data/nulltest/surrogateVBM/s',num2str(smoothKernel),'COMBAT'];
else
    address = ['/scratch2/kg98/trangc/VBM/data/nulltest/surrogateVBM/s',num2str(smoothKernel)];
end
% Construct the directory path based on the smoothing kernel and COMBAT flag.

metadata = readtable(['/projects/kg98/trangc/VBM/data/metadataVBM.csv']);
% metadataAD = readtable(['/projects/kg98/trangc/VBM/data/metadataVBM_AD.csv']);
% % Load metadata for psychiatric and Alzheimer's datasets.


% corNull = cell(nDiag,100);
nNull=100;
% Initialize a cell array to store correlation matrices for each diagnosis.
nullcount = 0;
for iDiag = 1:1%nDiag
    iDiag
    % Display the current diagnostic group index (for debugging/monitoring).

    if iDiag ~= nDiag
        mask = logical(niftiread(['/projects/kg98/trangc/VBM/data/derivatives/s',char(num2str(smoothKernel)),'COMBAT/mask_psy/mask.nii']));
    else
        mask = logical(niftiread(['/projects/kg98/trangc/VBM/data/derivatives/s',char(num2str(smoothKernel)),'COMBAT/mask_AD/mask.nii']));
    end
    % % Load binary masks for region selection.


    [LaDiag LbDiag] = ismember(metadata.diagnosis,(iDiag+1));
    % Logical index for matching the current diagnosis in metadata.

    [siteString ia ic] = unique(metadata.site_string(LaDiag));
    % Identify unique site strings for individuals in the current diagnostic group.

    [diagnosisString ia ic] = unique(metadata.diagnosis_string(LaDiag));
    % Identify unique diagnosis strings (stratified by diagnosis).

    nSite = length(siteString)
    for iNull=1:nNull
    % Determine the number of unique sites for the current diagnostic group.
    countSite = 0;
    orifile = (['/projects/kg98/trangc/VBM/data/derivatives/s',char(num2str(smoothKernel)),'COMBAT/',char(diagnosisString),'/',char(siteString(1)),'/spmT_0001.nii'])
    orimap = niftiread(orifile);
    for iSite = [1,7]
        file1 = ([address,'/',char(diagnosisString),'/',char(siteString(iSite)),'/spmT_0001_surrogate_',char(num2str(iNull)),'.nii.gz'])
        % file1 = ([address,'/',char(diagnosisString),'/',char(siteString(iSite)),'/spmT_0001_surrogate_',char(num2str(iNull)),'.txt'])
        % Construct the file path for the surrogate map of the current site.
        if exist(file1,'file')
            surrogateMap = niftiread(file1);
            % surrogateMap = dlmread(file1);
            % Read and reshape the surrogate masked map into a matrix with 1000 columns.
            countSite = countSite + 1;
            mapAllNull(countSite,:) = double(surrogateMap(mask>0)) ;
            % Select the specific surrogate map based on the input index `iNull`.

            % else
            %     break
        end
    end
    
    if size(mapAllNull,1)>1
        nullcount = nullcount + 1;
    corNullBW(nullcount) = corr(mapAllNull(1,:)',mapAllNull(2,:)');
    corNullOri(nullcount) = corr(mapAllNull(2,:)',orimap(mask>0));
    % Compute the correlation matrix across all surrogate maps for the current diagnosis.
    end
    clear mapAllNull
    % Clear the temporary variable to free memory.
    end
end

%% plot
figure
% C = [darkblue; gray]; %lines;
% ViolinColor = {repmat(C,ceil(size(corToPlot,2)/length(C)),1)};
corToPlot(1,:) = corNullBW;
corToPlot(2,:) = corNullOri;
violinplot(corToPlot',{'between nulls','null vs original maps'});