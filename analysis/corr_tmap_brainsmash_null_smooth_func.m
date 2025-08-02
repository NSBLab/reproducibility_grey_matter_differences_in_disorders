function corr_tmap_brainsmash_null_smooth_func(iNull, iCOMBAT, smoothKernel)
% Function to compute correlation matrices for surrogate null maps.
% Inputs:
%   iNull       - Index for selecting a specific surrogate null map.
%   iCOMBAT     - Flag indicating if COMBAT harmonization is applied (1 = yes, 0 = no).
%   smoothKernel - Smoothing kernel size used in preprocessing.
% use module load  spm12/matlab2021a.r7771-v1

addpath('/projects/kg98/trangc/VBM/code/voxelwise')
diagString = {'HC', 'BD', 'SCA',...
    'SCZ', 'ASD', 'MDD' ,'AD'};
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

% mask = logical(niftiread(['/projects/kg98/trangc/VBM/data/derivatives/s',char(num2str(smoothKernel)),'COMBAT/mask_psy/mask.nii']));
% maskAD = logical(niftiread(['/projects/kg98/trangc/VBM/data/derivatives/s',char(num2str(smoothKernel)),'COMBAT/mask_AD/mask.nii']));
% % Load binary masks for region selection.

corNull = cell(nDiag,1);
% Initialize a cell array to store correlation matrices for each diagnosis.

for iDiag = 1:nDiag
    iDiag
    % Display the current diagnostic group index (for debugging/monitoring).
    
    [LaDiag LbDiag] = ismember(metadata.diagnosis,(iDiag+1));
    % Logical index for matching the current diagnosis in metadata.
    
    [siteString ia ic] = unique(metadata.site_string(LaDiag));
    % Identify unique site strings for individuals in the current diagnostic group.
    
    [diagnosisString ia ic] = unique(metadata.diagnosis_string(LaDiag));
    % Identify unique diagnosis strings (stratified by diagnosis).
    
    nSite = length(siteString)
    % Determine the number of unique sites for the current diagnostic group.
    
    if iDiag == 6
        mask_file = ['/projects/kg98/trangc/VBM/data/derivatives/s' , char(num2str(smoothKernel)) , 'COMBAT/mask_AD/mask.nii' ];
    else
        mask_file = ['/projects/kg98/trangc/VBM/data/derivatives/s' ,  char(num2str(smoothKernel)) , 'COMBAT/mask_psy/mask.nii' ];
    end
    
    mask = niftiread(mask_file);
    info = niftiinfo(mask_file);
    unmaskedMap = zeros(size(mask));
    subNifti_cell = {}
    countSite = 0;
    for iSite = 1:nSite
        file1 = ([address,'/',char(diagnosisString),'/',char(siteString(iSite)),'/spmT_0001_surrogate_',char(num2str(iNull)),'.txt'])
        % Construct the file path for the surrogate map of the current site.
        if exist(file1,'file')
            surrogateMap = dlmread(file1);
            unmaskedMap(mask==1) = surrogateMap;
            niftifile = [address,'/',char(diagnosisString),'/',char(siteString(iSite)),'/spmT_0001_surrogate_',char(num2str(iNull)),'.nii'];
            niftiwrite(unmaskedMap,niftifile);
            countSite = countSite + 1;
            subNifti_cell{countSite} = niftifile;
            
            % mapAllNull(countSite,:) = surrogateMap ;
            
        end
    end
    subNifti_cell = subNifti_cell' % transpose so its in the correct format for functions
    smooth_job(subNifti_cell, smoothKernel)
    countSite = 0;
    for iSite = 1:nSite
        file1 = ([address,'/',char(diagnosisString),'/',char(siteString(iSite)),'/spmT_0001_surrogate_',char(num2str(iNull)),'.txt'])
        % Construct the file path for the surrogate map of the current site.
        if exist(file1,'file')
            subNiftiSmoothFile = [address,'/',char(diagnosisString),'/',char(siteString(iSite)),'/s',num2str(smoothKernel),'spmT_0001_surrogate_',char(num2str(iNull)),'.nii'];
            subNiftiSmooth = niftiread(subNiftiSmoothFile);
            countSite = countSite + 1;
            mapAllNull(countSite,:) = subNiftiSmooth(mask==1);
        end
    end
    corNull{iDiag} = corr(mapAllNull');
    % Compute the correlation matrix across all surrogate maps for the current diagnosis.
    
    clear mapAllNull subNifti_cell
    % Clear the temporary variable to free memory.
end

save(['output/corr_null_tmap_brainsmash_combat',char(num2str(iCOMBAT)),'_smooth',char(num2str(smoothKernel)),'_smoothsurro_',char(num2str(iNull)),'.mat'], 'corNull');
% Save the resulting correlation matrices to a MAT file, with a name that includes COMBAT, smoothing kernel, and null index information.

end
% End of the function.
