function run_resample_random_subject_func(smoothKernel,sampleSize,iResample,randomNumber)
% This script to run GLM with a dataset subsampled from the whole dataset
%
%   1.SPM: Smooth (8mm) - voxel intensities become a weighted average of the
%       surrounding voxels. This is required to render the data more normally
%       distributed and to correct for some error in the registration process.
%   2. SPM: Estimate TIV - Total intracanial volume(TIV) interates GM, VM, and
%       CSF, or attempts to measure the skull volume directly. TIV is modelled
%       as a confounding parameter. Note: We want it to be orthogonal
%       (independent) to any other parameter of interest (ie no correlation).
%       Othwewise not only the ariance explained by TIV is removed from your
%       data, but also parts of the variance of your parameter of interest.
%       The larger the correlation between TIV and any parameter of interest
%       the more the need to not use TIV as nuisance parameter. In this case
%       an alternative approach is to use global scaling with TIV.
%   3. SPM: Basic Models - specific a design matric that explains how the preprocessed
%       data are cause
%   5. SPM: Estiamte - To actually fit the GLM to the data

% Additional steps required not avaliable through batch:
%   4. SPM: Review - to see what is in the design matrix and generally poke about.
%   6. SPM: Results - to identify any significant differences and to generate tmap files



rng(randomNumber)


% ------------------------------------------------------------
% Prep
% ------------------------------------------------------------



% Directories
inDir = '/projects/kg98/trangc/VBM/data';
outDir = fullfile('/scratch','kg98','trangc','VBM','data', 'derivatives', ['s',num2str(smoothKernel)], 'resampleRandom',['sampleSize_',num2str(sampleSize)]);
if ~exist(outDir, 'dir')
    mkdir(outDir);
end

% Load in metadata
metadataFilename = fullfile(inDir, 'metadataToResample.csv');
metadataAll = readtable(metadataFilename, 'delimiter',',');
% subsampling subjects
allIndex = 1:length(metadataAll.diagnosis);

nGroup = floor(length(metadataAll.diagnosis)/sampleSize/2); %divide to a number of nonoverlap groups
patientIndex = randperm(length(metadataAll.diagnosis),sampleSize*nGroup);
randPatient = randperm(length(patientIndex),sampleSize*nGroup);
controlIndex = allIndex(~ismember(allIndex,patientIndex));
randControl = randperm(length(controlIndex),sampleSize*nGroup);

for iGroup = 1:nGroup
subsamplePatientIndex = patientIndex(randPatient((sampleSize*(iGroup-1)+1):sampleSize*iGroup));

subsampleControlIndex = controlIndex(randControl((sampleSize*(iGroup-1)+1):sampleSize*iGroup));


metadata = metadataAll([subsamplePatientIndex,subsampleControlIndex],:);
metadata.diagnosis(1:length(subsamplePatientIndex))=4;
metadata.diagnosis(1+length(subsamplePatientIndex):end)=1;
writetable(metadata,fullfile(outDir,['iResample_',num2str(iResample),'_seed_',num2str(randomNumber),'_',num2str(iGroup)]));

runGLMresample_func(metadata,inDir,outDir,smoothKernel,iResample,randomNumber,iGroup)
end
