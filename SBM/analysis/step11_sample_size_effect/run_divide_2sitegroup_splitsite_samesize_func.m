
function run_divide_2sitegroup_splitsite_samesize_func(config, diag, smoothKernel, hemis, groupsize, iSubdivide, randomSubdivide)
% This script to run GLM with a dataset subsampled from the whole dataset
if nargin < 7
    error('Usage: run_divide_2sitegroup_splitsite_samesize_func(config, diag, smoothKernel, hemis, groupsize, iSubdivide, randomSubdivide)');
end
this_dir = fileparts(mfilename('fullpath'));
repo_root = fullfile(this_dir, '..', '..', '..');
addpath(genpath(fullfile(repo_root, 'utils')));
if ischar(config) || isstring(config)
    config = pipeline_load_config(char(config));
end
data_root = config.data_directories.dataset_root;

rng(randomSubdivide)


% ------------------------------------------------------------
% Prep
% ------------------------------------------------------------



% Directories
inDir = data_root;
outDir = fullfile(data_root, 'derivatives', 'freesurfer', ['s',num2str(smoothKernel),'noCOMBAT'], ...
    ['diag',num2str(diag)], hemis, ['resample_2sitegroup_splitsite_samesize_',char(num2str(groupsize))], ...
    ['iSubdivide_',num2str(iSubdivide),'_seed2group_',num2str(randomSubdivide)]);
if ~exist(outDir, 'dir')
    mkdir(outDir);
end

% Load in metadata
metadataFilename = fullfile(inDir, 'metadataSBM.csv');
metadataAll = readtable(metadataFilename, 'delimiter',',');
% subsampling subjects
siteAll = unique(metadataAll.site_string(metadataAll.diagnosis==diag));
metadatatoPick = metadataAll(ismember(metadataAll.site_string,siteAll) & (metadataAll.diagnosis==diag | metadataAll.diagnosis==1),:);


halfTotalPatient = groupsize;

patientIndex = find(metadatatoPick.diagnosis==diag);
if length(patientIndex)>=2*groupsize
    allrand = 1:length(patientIndex);
    randPatient1 = randperm(length(patientIndex),halfTotalPatient);
    leftrand = allrand(~ismember(allrand,randPatient1));
    randPatient2 = leftrand(randperm(length(leftrand),halfTotalPatient));

    indexMark = zeros(height(metadatatoPick),1);

    for iP = 1:length(randPatient1)
        %choose match control for the patient in group 1
        chosenSex1 = metadatatoPick.sex(patientIndex(randPatient1(iP)));
        chosenAge1 = metadatatoPick.age(patientIndex(randPatient1(iP)));
        controlIndexMatch1 = find(indexMark== 0 & metadatatoPick.diagnosis==1 & metadatatoPick.sex==chosenSex1);

        if ~isempty(controlIndexMatch1)
            ageGap = abs(metadatatoPick.age(controlIndexMatch1)-chosenAge1);
            [sortedAge sortedAgeIndex] = min(ageGap);
            indexMark(controlIndexMatch1(sortedAgeIndex)) =1;
            indexControl1(iP) = controlIndexMatch1(sortedAgeIndex);
        else
            controlIndexMatch1 = find(indexMark== 0 & metadatatoPick.diagnosis==1  );
            if ~isempty(controlIndexMatch1)
                ageGap = abs(metadatatoPick.age(controlIndexMatch1)-chosenAge1);
                [sortedAge sortedAgeIndex] = min(ageGap);
                indexMark(controlIndexMatch1(sortedAgeIndex)) =1;
                indexControl1(iP) = controlIndexMatch1(sortedAgeIndex);
            end
        end
        %choose match control for the patient in group 2
        chosenSex2 = metadatatoPick.sex(patientIndex(randPatient2(iP)));
        chosenAge2 = metadatatoPick.age(patientIndex(randPatient2(iP)));
        controlIndexMatch2 = find(indexMark== 0 & metadatatoPick.diagnosis==1 & metadatatoPick.sex==chosenSex2);

        if ~isempty(controlIndexMatch2)
            ageGap = abs(metadatatoPick.age(controlIndexMatch2)-chosenAge2);
            [sortedAge sortedAgeIndex] = min(ageGap);
            indexMark(controlIndexMatch2(sortedAgeIndex)) =1;
            indexControl2(iP) = controlIndexMatch2(sortedAgeIndex);
        else
            controlIndexMatch2 = find(indexMark== 0 & metadatatoPick.diagnosis==1  );
            if ~isempty(controlIndexMatch2)
                ageGap = abs(metadatatoPick.age(controlIndexMatch2)-chosenAge2);
                [sortedAge sortedAgeIndex] = min(ageGap);
                indexMark(controlIndexMatch2(sortedAgeIndex)) =1;
                controlIndexMatch2(sortedAgeIndex)
                indexControl2(iP) = controlIndexMatch2(sortedAgeIndex);
            end
        end
    end

    % for iP2 = (iP+1):length(randPatient2)
    %     %choose match control for the patient in group 2
    %     chosenSex2 = metadatatoPick.sex(patientIndex(randPatient2(iP2)));
    %     chosenAge2 = metadatatoPick.age(patientIndex(randPatient2(iP2)));
    %     controlIndexMatch2 = find(indexMark== 0 & metadatatoPick.diagnosis==1 & metadatatoPick.sex==chosenSex2);
    %
    %     if ~isempty(controlIndexMatch2)
    %         ageGap = abs(metadatatoPick.age(controlIndexMatch2)-chosenAge2);
    %         [sortedAge sortedAgeIndex] = min(ageGap);
    %         indexMark(controlIndexMatch2(sortedAgeIndex)) =1;
    %         indexControl2(iP2) = controlIndexMatch2(sortedAgeIndex);
    %     else
    %         controlIndexMatch2 = find(indexMark== 0 & metadatatoPick.diagnosis==1  );
    %         %if number of control smaller than number of patient, can't add
    %         %control
    %         if ~isempty(controlIndexMatch2)
    %             ageGap = abs(metadatatoPick.age(controlIndexMatch2)-chosenAge2);
    %             [sortedAge sortedAgeIndex] = min(ageGap);
    %             indexMark(controlIndexMatch2(sortedAgeIndex)) =1;
    %             indexControl2(iP2) = controlIndexMatch2(sortedAgeIndex);
    %         end
    %     end
    % end

    %in number of control larger than number of patient divide the rest into
    %two
    % controlIndexMatch = find(indexMark== 0 & metadatatoPick.diagnosis==1  );
    % halfNControlLeft = floor(length(controlIndexMatch)/2);
    % indexControl1(length(randPatient1)+1:length(randPatient1)+halfNControlLeft) = controlIndexMatch(1:halfNControlLeft);
    % indexControl2(length(randPatient2)+1:length(randPatient2)+length(controlIndexMatch)-halfNControlLeft) = controlIndexMatch(halfNControlLeft+1:length(controlIndexMatch));

    metadata1 = metadatatoPick([patientIndex(randPatient1)',indexControl1],:);
    writetable(metadata1,fullfile(outDir,['iSubdivide_',num2str(iSubdivide),'_seed2group_',num2str(randomSubdivide),'_group1.txt']),'Delimiter','tab');

    metadata2 = metadatatoPick([patientIndex(randPatient2)',indexControl2],:);
    writetable(metadata2,fullfile(outDir,['iSubdivide_',num2str(iSubdivide),'_seed2group_',num2str(randomSubdivide),'_group2.txt']),'Delimiter','tab');
end
end

