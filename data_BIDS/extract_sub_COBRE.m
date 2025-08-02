%% read demographic information and extract subjects that satisfy criteria:
% - age: 18-60
% - each site has at least 20 subjects

% Trang Cao, Neural Systems and Behaviour Lab, Monash University, 2022.

clear all
close all

study = 'COBRE';

% define const
LOWAGE = 18; % lower bound of age
UPAGE = 60; % upper bound of age
NSUB = 20; % lowest number of subject per site per phenotype

% read demographic file
subject = readtable(['/projects/kg98/trangc/VBM/data/',study,'/COBRE_phenotypic_data.csv']);
subject.ID = cellstr(num2str(subject.ID));
% list of diagnosis
phenotype = unique(subject.SubjectType);

% filter subject in the age range 18-60 and have exist files
subject.adult = subject.CurrentAge >= LOWAGE & subject.CurrentAge <= UPAGE ...
    & ismember(subject.SubjectType, phenotype([1,3]));
adult.ID = unique(subject.ID(subject.adult == 1));


% subject.diag = double(ismember(subject.SubjectType, phenotype(1)));

% adult healthy subjects
condition = ismember(adult.ID,...
            subject.ID(strcmp(subject.SubjectType, phenotype(1))));
nSubPerPhenotypePerSite(1) = sum(condition);

% adult patients
nSubPerPhenotypePerSite(2) = length(adult.ID)-nSubPerPhenotypePerSite(1);

% the site and phenotype has >= NSUB HC subjects
siteSizeCondition = nSubPerPhenotypePerSite >= NSUB;
[La iUseFile] = ismember(adult.ID, subject.ID);
useFolder = "sub-" + cellstr(adult.ID);

% writelines(useFolder, ['/projects/kg98/trangc/VBM/data/', study, '/subject_use.txt']);


% create metadata
IQRthres = 2.8;
% read cat report
catFile = readtable(['/projects/kg98/trangc/VBM/data/', study, '/cat12_qcReport_', study, '.txt']);
subHighQR = catFile.Var1(catFile.Var2 <= IQRthres);
[La indexHighQRinUseFolder] = ismember(subHighQR, useFolder); % index in use Folder is same as in iUnique

metadata.subj_id = cellstr(useFolder(indexHighQRinUseFolder));
metadata.dataset = cellstr(repmat(study,size(indexHighQRinUseFolder)));
metadata.site = cellstr(repmat('27',size(metadata.subj_id)));
metadata.site_string = metadata.dataset;

metadata.age = cellstr(num2str(subject.CurrentAge(iUseFile(indexHighQRinUseFolder))));
metadata.sex = cellstr(num2str(strcmp(subject.Gender(iUseFile(indexHighQRinUseFolder)),'Male')));
metadata.sex_string(strcmp(metadata.sex,'1'),1) = {'M'};
metadata.sex_string(strcmp(metadata.sex,'0'),1) = {'F'};


% find diagnosis for used subjects
[La Lb] = ismember(subject.SubjectType(iUseFile(indexHighQRinUseFolder)),phenotype);
phenotype

metadata.diagnosis = Lb;
metadata.diagnosis(metadata.diagnosis == 3) = 4;
diagString = {'Healthy Control', 'Bipolar disorder', 'Schizoaffective Disorder',...
    'Schizophrenia', 'Autistic Spectrum Disorders', 'Major depressive disorder' };
metadata.diagnosis_string(:,1) = diagString(metadata.diagnosis);
metadata.diagnosis = cellstr(num2str(metadata.diagnosis));

%% check number of subjects
diagCat = unique(metadata.diagnosis);

    for iDiag = 1: length(diagCat) % control and proband in the diag list

        % number of adult subjects in each phenotype in each site
        nSiteDiag( iDiag) = sum(strcmp(metadata.diagnosis, diagCat(iDiag)));

    end

%% CAT
[La Lb] = ismember(metadata.subj_id, catFile.Var1);
metadata.CAT = cellstr(num2str(catFile.Var2(Lb)));


metaTable = cell2table([metadata.subj_id, metadata.dataset, metadata.site, metadata.diagnosis,... 
    metadata.age, metadata.sex, metadata.site_string, metadata.sex_string, metadata.diagnosis_string, metadata.CAT],...
    "VariableNames",["subj_id", "dataset", "site", "diagnosis", "age", "sex", "site_string", "sex_string", "diagnosis_string" , "CAT" ]);

writetable(metaTable,['/projects/kg98/trangc/VBM/data/', study, '/',study,'_dems_extended.csv']);
