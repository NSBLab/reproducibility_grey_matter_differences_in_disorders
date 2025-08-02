%% read demographic information and extract subjects that satisfy criteria:
% - age: 18-60
% - each site has at least 20 subjects

% Trang Cao, Neural Systems and Behaviour Lab, Monash University, 2022.

clear all
close all

study = 'BrainGluSchi';

% define const
LOWAGE = 18; % lower bound of age
UPAGE = 60; % upper bound of age
NSUB = 20; % lowest number of subject per site per phenotype

% read demographic file
subject = readtable(['/projects/kg98/trangc/VBM/data/',study,'/2079_Demographics_20220207.csv']);
file = readtable(['/projects/kg98/trangc/VBM/data/',study,'/sublist.txt']);
filename = char(file.sub_A00000159);
medFile = readtable(['/projects/kg98/trangc/VBM/data/', study, '/dem/2079_Medication_Log_20220207.csv']);
% filter subject in the age range 18-60 and have exist files
subject.adult = subject.CurrentAge >= LOWAGE & subject.CurrentAge <= UPAGE ...
& ismember(subject.AnonymizedID, cellstr(filename(:,5:end)));
adult.ID = unique(subject.AnonymizedID(subject.adult == 1));

% list of diagnosis
phenotype = unique(subject.SubjectType);
subject.diag = double(ismember(subject.SubjectType, phenotype([2,4,6])));

% adult healthy subjects
condition = ismember(adult.ID,...
            subject.AnonymizedID(subject.diag==1));
nSubPerPhenotypePerSite(1) = sum(condition);

% adult patients
nSubPerPhenotypePerSite(2) = length(adult.ID)-nSubPerPhenotypePerSite(1);

% the site and phenotype has >= NSUB HC subjects
siteSizeCondition = nSubPerPhenotypePerSite >= NSUB;
[La iUseFile] = ismember(adult.ID, subject.AnonymizedID);
useFolder = "sub-" + cellstr(adult.ID);

writelines(useFolder, ['/projects/kg98/trangc/VBM/data/', study, '/subject_use.txt']);


% create metadata
IQRthres = 2.8;
% read cat report
catFile = readtable(['/projects/kg98/trangc/VBM/data/', study, '/cat12_qcReport_', study, '.txt']);
subHighQR = catFile.Var1(catFile.Var2 <= IQRthres);
[La indexHighQRinUseFolder] = ismember(subHighQR, useFolder); % index in use Folder is same as in iUnique

metadata.subj_id = cellstr(useFolder(indexHighQRinUseFolder));
metadata.dataset = cellstr(repmat(study,size(indexHighQRinUseFolder)));
metadata.site = cellstr(repmat('26',size(metadata.subj_id)));
metadata.site_string = metadata.dataset;

metadata.age = subject.CurrentAge(iUseFile(indexHighQRinUseFolder));
metadata.sex = cellstr(num2str(subject.Gender(iUseFile(indexHighQRinUseFolder))));
metadata.sex(strcmp(metadata.sex,'2'),1) = {'0'};
metadata.sex_string(strcmp(metadata.sex,'1'),1) = {'M'};
metadata.sex_string(strcmp(metadata.sex,'0'),1) = {'F'};


% find diagnosis for used subjects
metadata.diagnosis = subject.diag(iUseFile(indexHighQRinUseFolder));
metadata.diagnosis(metadata.diagnosis == 0) = 4;
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

%%

%% onset
criteria = 'AgeAtFirstPsychiatricIllness';
[La indexIDinMed] = ismember(extract(metadata.subj_id,digitsPattern), extract(subject.AnonymizedID,digitsPattern)); % index in medFile 
columnNames = subject.Properties.VariableNames;
onsetIn = find(matches(columnNames, criteria)==1);
metadata.ageOnset(:,1) = subject{indexIDinMed,onsetIn};

metadata.illnessDuration = metadata.age - metadata.ageOnset;

[La Lb] = ismember(metadata.subj_id, catFile.Var1);
metadata.CAT = cellstr(num2str(catFile.Var2(Lb)));

%% med
[metadata.antipsychotic Lb] = ismember(extract(metadata.subj_id,digitsPattern), extract(medFile.AnonymizedID,digitsPattern)); % index in medFile 
metadata.treatment = metadata.antipsychotic ;


metaTable = cell2table([metadata.subj_id, metadata.dataset, metadata.site, metadata.diagnosis,... 
    cellstr(num2str(metadata.age)), metadata.sex, metadata.site_string, metadata.sex_string, metadata.diagnosis_string,...
    metadata.CAT, cellstr(num2str(metadata.antipsychotic)), cellstr(num2str(metadata.treatment)), cellstr(num2str(metadata.ageOnset)), ...
    cellstr(num2str(metadata.illnessDuration))],...
    "VariableNames",["subj_id", "dataset", "site", "diagnosis", "age", "sex", "site_string", "sex_string", "diagnosis_string", "CAT","antipsychotic", "treatment" , "ageOnset","illnessDuration"]);

writetable(metaTable,['/projects/kg98/trangc/VBM/data/', study, '/',study,'_dems_extended.csv']);
