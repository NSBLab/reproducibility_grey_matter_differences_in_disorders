
function run_resample_samesite_func(smoothKernel,nGroup,iResample,randomNumber)
% This script to run GLM with a dataset subsampled from the whole dataset

rng(randomNumber)


% ------------------------------------------------------------
% Prep
% ------------------------------------------------------------



% Directories
inDir = '/projects/kg98/trangc/VBM/data';
outDir = fullfile('/scratch','kg98','trangc','VBM','data', 'derivatives', 'freesurfer',['s',num2str(smoothKernel),'COMBAT'], 'resample_samesite',['nGroup_',num2str(nGroup)]);
if ~exist(outDir, 'dir')
    mkdir(outDir);
end

% Load in metadata
metadataFilename = fullfile(inDir, 'metadata_surface_SCZ.csv');
metadataAll = readtable(metadataFilename, 'delimiter','tab');
% subsampling subjects
siteAll = unique(metadataAll.site);
nSite  = length(siteAll);
% patientIndex = find(metadataAll.diagnosis==4);
% nGroup = floor(length(patientIndex)/sampleSize); %divide to a number of nonoverlap groups
nSitePerGroup = floor(nSite/nGroup);
siteIndex = randperm(nSite,nSitePerGroup*nGroup);
% randPatient = randperm(length(patientIndex),sampleSize*nGroup);
% controlIndex = find(metadataAll.diagnosis==1);
% randControl = randperm(length(controlIndex),sampleSize*nGroup);

for iGroup = 1:nGroup

siteSelect = siteAll((nSitePerGroup*(iGroup-1)+1):nSitePerGroup*iGroup);
metadata = metadataAll(ismember(metadataAll.site,siteSelect),:);
writetable(metadata,fullfile(outDir,['iResample_',num2str(iResample),'_seed_',num2str(randomNumber),'_',num2str(iGroup)]),'Delimiter','tab');

end
end
