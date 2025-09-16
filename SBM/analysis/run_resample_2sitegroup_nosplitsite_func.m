
function run_resample_2sitegroup_nosplitsite_func(diag,smoothKernel,hemis,iSubdivide,randomSubdivide,sampleSize,iResample,randomSample)
% This script to run GLM with a dataset subsampled from the whole dataset

rng(randomSample)


% ------------------------------------------------------------
% Prep
% ------------------------------------------------------------



% Directories
inDir = '/projects/kg98/trangc/VBM/data';
subdivideDir = fullfile('/scratch','kg98','trangc','VBM','data', 'derivatives', 'freesurfer',['s',num2str(smoothKernel),'noCOMBAT'],['diag',num2str(diag)],hemis, 'resample_2sitegroup_nosplitsite',['iSubdivide_',num2str(iSubdivide),'_seed2group_',num2str(randomSubdivide)]);

for iGroup = 1:2

    outDir = fullfile(subdivideDir,['sampleSize_',num2str(sampleSize)]);

    if ~exist(outDir, 'dir')
        mkdir(outDir);
    end

    % Load in metadata
    metadataAll = readtable(fullfile(subdivideDir,['iSubdivide_',num2str(iSubdivide),'_seed2group_',num2str(randomSubdivide),'_group',num2str(iGroup),'.txt']),'Delimiter','tab');
    % subsampling subjects
    siteAll = unique(metadataAll.site_string(metadataAll.diagnosis==diag));
    siteToPick = siteAll;
    nSite  = length(siteAll);

    % get patients from one-by-one site until the number of patients
    % satisfies the sampleSize
    nPatient = 0;
    iSite = 1;
    while nPatient < sampleSize
        indexToPick = randi(length(siteToPick));
        siteChosen(iSite) = siteToPick(indexToPick);
        siteToPick = siteToPick(1:end ~=indexToPick);
        iSite = iSite +1;
        nPatient = sum(metadataAll.diagnosis==diag & ismember(metadataAll.site_string,siteChosen));
    end
    patientIndex = find(metadataAll.diagnosis==diag & ismember(metadataAll.site_string,siteChosen));
    randPatient = randperm(length(patientIndex),sampleSize);
    allIndex = 1:height(metadataAll);
    indexMark = zeros(height(metadataAll),1);

    for iP = 1:length(randPatient)
        chosenSite = metadataAll.site_string(patientIndex(randPatient(iP)));
        chosenSex = metadataAll.sex(patientIndex(randPatient(iP)));
        chosenAge = metadataAll.age(patientIndex(randPatient(iP)));
        controlIndexMatch = find(indexMark== 0 & metadataAll.diagnosis==1 & ismember(metadataAll.site_string,chosenSite) & metadataAll.sex==chosenSex);

        if ~isempty(controlIndexMatch)
            ageGap = abs(metadataAll.age(controlIndexMatch)-chosenAge);
            [sortedAge sortedAgeIndex] = min(ageGap);
            indexMark(controlIndexMatch(sortedAgeIndex)) =1;
            indexControl(iP) = controlIndexMatch(sortedAgeIndex);
        else
            controlIndexMatch = find(indexMark== 0 & metadataAll.diagnosis==1 & ismember(metadataAll.site_string,chosenSite) );
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
                else
                    controlIndexMatch = find(indexMark== 0 & metadataAll.diagnosis==1);
                    ageGap = abs(metadataAll.age(controlIndexMatch)-chosenAge);
                    [sortedAge sortedAgeIndex] = min(ageGap);
                    indexMark(controlIndexMatch(sortedAgeIndex)) =1;
                    controlIndexMatch(sortedAgeIndex)
                    indexControl(iP) = controlIndexMatch(sortedAgeIndex);
                end
            end
        end
    end

    metadata = metadataAll([patientIndex(randPatient)',indexControl],:);
    writetable(metadata,fullfile(outDir,['iResample_',num2str(iResample),'_seed_',num2str(randomSample),'_',num2str(iGroup)]),'Delimiter','tab');
end
end

