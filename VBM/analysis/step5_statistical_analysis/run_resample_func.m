
function run_resample_func(smoothKernel,sampleSize,iResample,randomNumber)
% This script to run GLM with a dataset subsampled from the whole dataset

rng(randomNumber)


% ------------------------------------------------------------
% Prep
% ------------------------------------------------------------



% Directories
inDir = '/projects/kg98/trangc/VBM/data';
outDir = fullfile('/scratch','kg98','trangc','VBM','data', 'derivatives', ['s',num2str(smoothKernel)], 'resample',['sampleSize_',num2str(sampleSize)]);
if ~exist(outDir, 'dir')
    mkdir(outDir);
end

% Load in metadata
metadataFilename = fullfile(inDir, 'metadataToResample.csv');
metadataAll = readtable(metadataFilename, 'delimiter',',');
% subsampling subjects
patientIndex = find(metadataAll.diagnosis==4);
nGroup = floor(length(patientIndex)/sampleSize); %divide to a number of nonoverlap groups
randPatient = randperm(length(patientIndex),sampleSize*nGroup);
controlIndex = find(metadataAll.diagnosis==1);
randControl = randperm(length(controlIndex),sampleSize*nGroup);

for iGroup = 1:nGroup
subsamplePatientIndex = patientIndex(randPatient((sampleSize*(iGroup-1)+1):sampleSize*iGroup));

subsampleControlIndex = controlIndex(randControl((sampleSize*(iGroup-1)+1):sampleSize*iGroup));


metadata = metadataAll([subsamplePatientIndex,subsampleControlIndex],:);
writetable(metadata,fullfile(outDir,['iResample_',num2str(iResample),'_seed_',num2str(randomNumber),'_',num2str(iGroup)]));

runGLMresample_func(metadata,inDir,outDir,smoothKernel,iResample,randomNumber,iGroup)
end
