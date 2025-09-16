
function run_divide_2sitegroup_func(diag,smoothKernel,hemis,iSubdivide,randomSubdivide)
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
metadataFilename = fullfile(inDir, 'metaSBMAll.csv');
metadataAll = readtable(metadataFilename, 'delimiter',',');
% subsampling subjects
siteAll = unique(metadataAll.site_string(metadataAll.diagnosis==diag));
siteToPick = siteAll;
nSite  = length(siteAll);
halfTotalPatient = sum(metadataAll.diagnosis==diag)/2;
% get site indeces for the first group until the number of patients are half
% of the total
nPatient = 0;
iSite = 1;
while nPatient < halfTotalPatient
    indexToPick = randi(length(siteToPick));
    siteChosen(iSite) = siteToPick(indexToPick);
    siteToPick = siteToPick(1:end ~=indexToPick);
    iSite = iSite +1;
    nPatient = sum(metadataAll.diagnosis==diag & ismember(metadataAll.site_string,siteChosen));
end
% patientIndex = find(metadataAll.diagnosis==diag & ismember(metadataAll.site_string,siteChosen));
%  allIndex = 1:height(metadataAll);
%     indexMark = zeros(height(metadataAll),1);
%         chosenSex = metadataAll.sex(patientIndex);
%         chosenAge = metadataAll.age(patientIndex);
% controlIndexMatch = find(indexMark== 0 & metadataAll.diagnosis==1 & ismember(metadataAll.site_string,siteChosen) & metadataAll.sex==chosenSex);
%
% if ~isempty(controlIndexMatch)
%             ageGap = abs(metadataAll.age(controlIndexMatch)-chosenAge);
%             [sortedAge sortedAgeIndex] = min(ageGap);
%             indexMark(controlIndexMatch(sortedAgeIndex)) =1;
%             indexControl = controlIndexMatch(sortedAgeIndex);
% else
%     controlIndexMatch = find(indexMark== 0 & metadataAll.diagnosis==1 & ismember(metadataAll.site_string,chosenSite) );
%
%                 ageGap = abs(metadataAll.age(controlIndexMatch)-chosenAge);
%                 [sortedAge sortedAgeIndex] = min(ageGap);
%                 indexMark(controlIndexMatch(sortedAgeIndex)) =1;
%                 indexControl = controlIndexMatch(sortedAgeIndex);
% end
%     metadata = metadataAll([patientIndex',indexControl],:);

metadata1 = metadataAll(ismember(metadataAll.site_string,siteChosen) & (metadataAll.diagnosis==diag | metadataAll.diagnosis==1),:);
writetable(metadata1,fullfile(outDir,['iSubdivide_',num2str(iSubdivide),'_seed2group_',num2str(randomSubdivide),'_group1.txt']),'Delimiter','tab');

metadata2 = metadataAll(ismember(metadataAll.site_string,siteToPick(~ismember(siteToPick,siteChosen))) & (metadataAll.diagnosis==diag | metadataAll.diagnosis==1),:);
writetable(metadata2,fullfile(outDir,['iSubdivide_',num2str(iSubdivide),'_seed2group_',num2str(randomSubdivide),'_group2.txt']),'Delimiter','tab');

end

