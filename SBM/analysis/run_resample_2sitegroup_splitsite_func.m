
function run_resample_2sitegroup_splitsite_func(diag,smoothKernel,hemis,iSubdivide,randomSubdivide,sampleSize,iResample,randomSample)
% This script to run GLM with a dataset subsampled from the whole dataset

rng(randomSample)


% ------------------------------------------------------------
% Prep
% ------------------------------------------------------------



% Directories
inDir = '/projects/kg98/trangc/VBM/data';
subdivideDir = fullfile('/scratch','kg98','trangc','VBM','data', 'derivatives', 'freesurfer',['s',num2str(smoothKernel),'noCOMBAT'],['diag',num2str(diag)],hemis, 'resample_2sitegroup_splitsite',['iSubdivide_',num2str(iSubdivide),'_seed2group_',num2str(randomSubdivide)]);

for iGroup = 1:2

    outDir = fullfile(subdivideDir,['sampleSize_',num2str(sampleSize)]);

    if ~exist(outDir, 'dir')
        mkdir(outDir);
    end

    % Load in metadata
    metadataAll = readtable(fullfile(subdivideDir,['iSubdivide_',num2str(iSubdivide),'_seed2group_',num2str(randomSubdivide),'_group',num2str(iGroup),'.txt']),'Delimiter','tab');
    % subsampling subjects
    % siteAll = unique(metadataAll.site_string(metadataAll.diagnosis==diag));
    % siteToPick = siteAll;
    % nSite  = length(siteAll);

    % get patients from one-by-one site until the number of patients
    % satisfies the sampleSize
    % nPatient = 0;
    % iSite = 1;
    % while nPatient < sampleSize
    %     indexToPick = randi(length(siteToPick));
    %     siteChosen(iSite) = siteToPick(indexToPick);
    %     siteToPick = siteToPick(1:end ~=indexToPick);
    %     iSite = iSite +1;
    %     nPatient = sum(metadataAll.diagnosis==diag & ismember(metadataAll.site_string,siteChosen));
    % end
    patientIndex = find(metadataAll.diagnosis==diag);
    allrand = 1:length(patientIndex);
    randPatient1 = randperm(length(patientIndex),sampleSize);

    indexMark = zeros(height(metadataAll),1);

    for iP = 1:length(randPatient1)
        %choose match control for the patient in group 1
        chosenSex1 = metadataAll.sex(patientIndex(randPatient1(iP)));
        chosenAge1 = metadataAll.age(patientIndex(randPatient1(iP)));
        controlIndexMatch1 = find(indexMark== 0 & metadataAll.diagnosis==1 & metadataAll.sex==chosenSex1);
        if ~isempty(controlIndexMatch1)
            ageGap = abs(metadataAll.age(controlIndexMatch1)-chosenAge1);
            [sortedAge sortedAgeIndex] = min(ageGap);
            indexMark(controlIndexMatch1(sortedAgeIndex)) =1;
            indexControl1(iP) = controlIndexMatch1(sortedAgeIndex);
        else
            controlIndexMatch1 = find(indexMark== 0 & metadataAll.diagnosis==1  );
            if ~isempty(controlIndexMatch1)
                ageGap = abs(metadataAll.age(controlIndexMatch1)-chosenAge1);
                [sortedAge sortedAgeIndex] = min(ageGap);
                indexMark(controlIndexMatch1(sortedAgeIndex)) =1;
                indexControl1(iP) = controlIndexMatch1(sortedAgeIndex);
            end
        end


    end

    metadata = metadataAll([patientIndex(randPatient1)',indexControl1],:);
    writetable(metadata,fullfile(outDir,['iResample_',num2str(iResample),'_seed_',num2str(randomSample),'_',num2str(iGroup)]),'Delimiter','tab');
end
end

