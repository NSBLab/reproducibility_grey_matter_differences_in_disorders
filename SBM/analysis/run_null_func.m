
function run_null_func(randomNumber,dataset,nullDir,sitefile,iNullMin,iNullMax)

rng(randomNumber)

% Directories
inDir = '/projects/kg98/trangc/VBM/data';
qdecStr = split(sitefile,"/");
qdecName = qdecStr{end};
for iNull = iNullMin:iNullMax
    outDir = fullfile([nullDir,'/',num2str(iNull),'/',dataset]);
    if ~exist(outDir, 'dir')
        mkdir(outDir);
    end
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
