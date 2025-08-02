
function run_resample_null_func(diag,smoothKernel,iSubdivide,randomSubdivide,iNullMin,iNullMax)

rng(randomSubdivide)

% Directories
inDir = fullfile('/scratch','kg98','trangc','VBM','data', 'derivatives', 'freesurfer',['s',num2str(smoothKernel),'noCOMBAT'], 'resample_2sitegroup',['iSubdivide_',num2str(iSubdivide),'_seed2group_',num2str(randomSubdivide)]);
outDir = fullfile(inDir,'null');
if ~exist(outDir, 'dir')
    mkdir(outDir);
end

sitefile = fullfile(inDir,['iSubdivide_',num2str(iSubdivide),'_seed2group_',num2str(randomSubdivide),'_group2.txt']);
for iNull = iNullMin:iNullMax
    qdecName = ['iSubdivide_',num2str(iSubdivide),'_seed2group_',num2str(randomSubdivide),'_null',num2str(iNull),'_group2.txt'];


    % load qdec table
    metadataAll = readtable(sitefile, 'delimiter','tab');

    % subsampling subjects
    diagnosis = unique(metadataAll.diagnosis);
    patientIndex = find(metadataAll.diagnosis~=1);
    nPatient = length(patientIndex);
    controlIndex = find(metadataAll.diagnosis==1);
    nControl = length(controlIndex);
    combineIndex = [patientIndex;controlIndex];

    randPatient = randperm(length(combineIndex),nPatient);

    % randControl = randperm(length(combineIndex),sampleSize*nGroup);

    subsamplePatientIndex = combineIndex(randPatient);

    metadataAll.diagnosis(subsamplePatientIndex) = diagnosis(diagnosis~=1);
    subsampleControlIndex = combineIndex(~ismember(combineIndex,subsamplePatientIndex));
    metadataAll.diagnosis(subsampleControlIndex) = 1;

    writetable(metadataAll,fullfile(outDir,qdecName),'Delimiter','tab');

end
end
