
function run_divide_2sitegroup_HC_func(diag,smoothKernel,hemis,iSubdivide,randomSubdivide)
% This script to run GLM with a dataset subsampled from the whole dataset

rng(randomSubdivide)


% ------------------------------------------------------------
% Prep
% ------------------------------------------------------------



% Directories
inDir = '/projects/kg98/trangc/VBM/data';
outDir = fullfile('/scratch','kg98','trangc','VBM','data', 'derivatives', 'freesurfer',['s',num2str(smoothKernel),'noCOMBAT'],['diag',num2str(diag)],hemis, 'resample_2sitegroup',['iSubdivide_',num2str(iSubdivide),'_seed2group_',num2str(randomSubdivide)]);
if ~exist(outDir, 'dir')
    mkdir(outDir);
end

% Load in metadata
metadataFilename = fullfile(inDir, 'metadataqdecAll.csv');
metadataAll = readtable(metadataFilename, 'delimiter',',');
% subsampling subjects
siteAll = unique(metadataAll.site_string(metadataAll.diagnosis==1));
siteToPick = siteAll;
nSite  = length(siteAll);
nSub = sum(metadataAll.diagnosis==1);
halfTotalPatient = nSub/2;
% get site indeces forthe first group until the number of patients are half
% of the total
nPatient = 0;
iSite = 1;
while nPatient < halfTotalPatient
    indexToPick = randi(length(siteToPick));
    siteChosen(iSite) = siteToPick(indexToPick);
    siteToPick = siteToPick(1:end ~=indexToPick);
    iSite = iSite +1;
    nPatient = sum(metadataAll.diagnosis==1 & ismember(metadataAll.site_string,siteChosen));
end

metadata1 = metadataAll(ismember(metadataAll.site_string,siteChosen) & (metadataAll.diagnosis==1 ),:);
metadata1.diagnosis( randi(height(metadata1),floor(halfTotalPatient/2),1)) = diag;
writetable(metadata1,fullfile(outDir,['iSubdivide_',num2str(iSubdivide),'_seed2group_',num2str(randomSubdivide),'_group1.txt']),'Delimiter','tab');

metadata2 = metadataAll(~ismember(metadataAll.site_string,siteChosen) & (metadataAll.diagnosis==1 ),:);
metadata2.diagnosis( randi(height(metadata2),floor(halfTotalPatient/2),1)) = diag;
writetable(metadata2,fullfile(outDir,['iSubdivide_',num2str(iSubdivide),'_seed2group_',num2str(randomSubdivide),'_group2.txt']),'Delimiter','tab');

end

