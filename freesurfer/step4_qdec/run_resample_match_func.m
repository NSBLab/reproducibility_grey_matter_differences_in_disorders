
function run_resample_match_func(smoothKernel,sampleSize,iResample,randomNumber)
% This script to run GLM with a dataset subsampled from the whole dataset

rng(randomNumber)


% ------------------------------------------------------------
% Prep
% ------------------------------------------------------------



% Directories
inDir = '/projects/kg98/trangc/VBM/data';
outDir = fullfile('/scratch','kg98','trangc','VBM','data', 'derivatives', 'freesurfer',['s',num2str(smoothKernel),'COMBAT'], 'resample_match',['sampleSize_',num2str(sampleSize)]);
if ~exist(outDir, 'dir')
    mkdir(outDir);
end

% Load in metadata
metadataFilename = fullfile(inDir, 'metadata_surface_SCZ.csv');
metadataAll = readtable(metadataFilename, 'delimiter',',');

%No per site
uniqueSite  = unique(metadataAll.site);
uniqueDiag = unique(metadataAll.diagnosis);
uniqueSex = unique(metadataAll.sex);
for iSite = 1:length(uniqueSite)
    for iDiag = 1:2
        for iSex = 1:2
            nSub(iSite,iDiag,iSex) = sum(metadataAll.site==uniqueSite(iSite)&...
                metadataAll.diagnosis==uniqueDiag(iDiag)&metadataAll.sex==uniqueSex(iSex));
        end
    end
end
% subsampling subjects
patientIndex = find(metadataAll.diagnosis==4);
nGroup = floor(length(patientIndex)/sampleSize); %divide to a number of nonoverlap groups
randPatient = randperm(length(patientIndex),sampleSize*nGroup);
allIndex = 1:height(metadataAll);
indexMark = zeros(height(metadataAll),1);

for iP = 1:length(randPatient)
    chosenSite = metadataAll.site(patientIndex(randPatient(iP)));
    chosenSex = metadataAll.sex(patientIndex(randPatient(iP)));
    chosenAge = metadataAll.age(patientIndex(randPatient(iP)));
    controlIndexMatch = find(indexMark== 0 & metadataAll.diagnosis==1 & metadataAll.site==chosenSite & metadataAll.sex==chosenSex);

    if ~isempty(controlIndexMatch)
        ageGap = abs(metadataAll.age(controlIndexMatch)-chosenAge);
        [sortedAge sortedAgeIndex] = min(ageGap);
        indexMark(controlIndexMatch(sortedAgeIndex)) =1;
        indexControl(iP) = controlIndexMatch(sortedAgeIndex);
    else
        controlIndexMatch = find(indexMark== 0 & metadataAll.diagnosis==1 & metadataAll.site==chosenSite );
        if ~isempty(controlIndexMatch)
            ageGap = abs(metadataAll.age(controlIndexMatch)-chosenAge);
            [sortedAge sortedAgeIndex] = min(ageGap);
            indexMark(controlIndexMatch(sortedAgeIndex)) =1;
            indexControl(iP) = controlIndexMatch(sortedAgeIndex);
        else
            controlIndexMatch = find(indexMark== 0 & metadataAll.diagnosis==1 & metadataAll.sex==chosenSex );
            if ~isempty(controlIndexMatch)
                ageGap = abs(metadataAll.age(controlIndexMatch)-chosenAge);
                [sortedAge sortedAgeIndex] = min(ageGap);
                indexMark(controlIndexMatch(sortedAgeIndex)) =1;
                indexControl(iP) = controlIndexMatch(sortedAgeIndex);
            end
        end
    end
end


for iGroup = 1:nGroup
    subsamplePatientIndex = patientIndex(randPatient((sampleSize*(iGroup-1)+1):sampleSize*iGroup));

    subsampleControlIndex = indexControl((sampleSize*(iGroup-1)+1):sampleSize*iGroup);


    metadata = metadataAll([subsamplePatientIndex,subsampleControlIndex'],:);
    writetable(metadata,fullfile(outDir,['iResample_',num2str(iResample),'_seed_',num2str(randomNumber),'_',num2str(iGroup)]),'Delimiter','tab');

end
end
