%% read demographic information and extract subjects that satisfy criteria:
% - age: 18-60
% - each site has at least 20 subjects

% Trang Cao, Neural Systems and Behaviour Lab, Monash University, 2022.

clear all
close all

study = 'Study_neura';

% define const
LOWAGE = 18*12; % lower bound of age (months)
UPAGE = 60*12; % upper bound of age (months)
NSUB = 20; % lowest number of subject per site per phenotype

% read demographic file
imageFile = tdfread(['/projects/kg98/trangc/VBM/data/', study, '/image03.txt']);

imageFile.interview_age = str2double(string(imageFile.interview_age(2:end,:))); % remove the first line of description
[imageFile.interview_age iTimeOrder] = sort(imageFile.interview_age);
imageFile.image_description = cellstr(imageFile.image_description(2:end,:));
imageFile.image_description = imageFile.image_description(iTimeOrder,:);
imageFile.image_file = cellstr(imageFile.image_file(2:end,:));
imageFile.image_file = imageFile.image_file(iTimeOrder,:);
imageFile.src_subject_id = cellstr(imageFile.src_subject_id(2:end,:));
imageFile.src_subject_id = imageFile.src_subject_id(iTimeOrder,:);
imageFile.sex = cellstr(imageFile.sex(2:end,:));
imageFile.sex = imageFile.sex(iTimeOrder,:);
medFile = readtable(['/projects/kg98/trangc/VBM/data/', study, '/dem/medlist01.txt']);
medName = readtable(['/projects/kg98/trangc/VBM/data/medication_name_for_code.csv']);

% read diagnosis file
diagFile = tdfread(['/projects/kg98/trangc/VBM/data/', study, '/ndar_subject01.txt']);

diagFile.phenotype = cellstr(diagFile.phenotype(2:end,:));
diagFile.src_subject_id = cellstr(diagFile.src_subject_id(2:end,:));

% filter T1 files
descriptionList = {'MPRAGE', 'MPRAGE_ADNI', 't1_mpr_1mm_p2_pos50'};
imageFile.useDescription = ismember(imageFile.image_description, descriptionList);

% extract image filename
pat1 = ("rdoc_"+ wildcardPattern + ".zip");
filenameWithPattern = char(extract(imageFile.image_file(imageFile.useDescription),pat1));
imageFile.filename(imageFile.useDescription,1:size(filenameWithPattern,2)) = filenameWithPattern(:,1:end);

% extract subject ID to use as folder name
temp = char(imageFile.src_subject_id);
imageFile.folderName = "sub-" + temp(:,2:9);

% subject in the age range 18-60 at scanning time
imageFile.adult = imageFile.interview_age >= LOWAGE & imageFile.interview_age <= UPAGE;
adult.ID = unique(imageFile.src_subject_id(imageFile.adult == 1));

% list of sites and diagnose
[diag, ~, indexDiag] = unique(diagFile.phenotype);
nDiag = size(diag,1)-1; %not use siblings
control = 'No Diagnosis';
[iControl ic] = find(strcmp(diag, control));

for iDiag = 1: nDiag % control and proband in the diag list

    % adult subject condition
    condition = ismember(adult.ID, diagFile.src_subject_id(indexDiag == iDiag));
    % number of adult subjects
    nSubPerPhenotypePerSite(iDiag) = sum(condition);

end

% the site and phenotype has >= NSUB HC subjects
siteSizeCondition = nSubPerPhenotypePerSite >= NSUB;

% filter subjects to be used
adult.use =  zeros(size(adult.ID));
for iDiag = 1:nDiag

    if siteSizeCondition(iDiag) == 1

        % adult subjects in each phenotype in each site
        condition = ismember(adult.ID,...
            diagFile.src_subject_id(indexDiag == iDiag));
        adult.use(condition) = 1;
    end

end

% extract image filename satisfying: ID of usable subjects and
% image_description in the list
useID = adult.ID(adult.use==1);
imageFile.useID = ismember(imageFile.src_subject_id,useID);

imageFile.useFile = imageFile.useID == 1 & imageFile.useDescription == 1;
[iUseFile col va] = find(imageFile.useFile);

idUse = imageFile.src_subject_id(iUseFile);
[useSub iUnique iID] = unique(idUse);

fileToUse = cellstr(imageFile.filename(iUseFile,:));
useFolder = cellstr(imageFile.folderName(iUseFile(iUnique),:));
% assign sessions for each subject
nUseFile = 0;
for iSub = 1:length(iUnique)
    % filename of each subject
    isSubSes = ismember(imageFile.src_subject_id(iUseFile),useSub(iSub));

    % number of session
    nSes(iSub) = sum(isSubSes);

    useFile(nUseFile+1:nUseFile+nSes(iSub)) = useFolder(iSub) + "ses-" + string((1:nSes(iSub))') + fileToUse(isSubSes);
    nUseFile = nUseFile+nSes(iSub);

end
% writelines(useFolder, ['/projects/kg98/trangc/VBM/data/', study, '/subject_use.txt']);
% create metadata
IQRthres = 2.8;
% read cat report
catFile = readtable(['/projects/kg98/trangc/VBM/data/', study, '/cat12_qcReport_', study, '.txt']);
subHighQR = catFile.Var1(catFile.Var2 <= IQRthres);
[La indexHighQRinUseFolder] = ismember(subHighQR, useFolder); % index in use Folder is same as in iUnique

metadata.subj_id = cellstr(useFolder(indexHighQRinUseFolder));
metadata.ses = catFile.Var3(catFile.Var2 <= IQRthres);
metadata.dataset = cellstr(repmat(study,size(metadata.subj_id)));
metadata.site = cellstr(repmat('17',size(metadata.subj_id)));
metadata.site_string = metadata.dataset;
metadata.age = cellstr(num2str(round(imageFile.interview_age(iUseFile(iUnique(indexHighQRinUseFolder)))./12)));
metadata.sex_string = cellstr(imageFile.sex(iUseFile(iUnique(indexHighQRinUseFolder))));
metadata.sex = cellstr(num2str(strcmp(metadata.sex_string,'M')));


% find diagnosis for used subjects
[La Lb] = ismember(imageFile.src_subject_id(iUseFile(iUnique(indexHighQRinUseFolder))), diagFile.src_subject_id);
metadata.diagnosis_string = cellstr(diagFile.phenotype(Lb));
[La Lb] = ismember(metadata.diagnosis_string, diag);
Lb(Lb==2) = 4;
metadata.diagnosis = cellstr(num2str(Lb));
diagString = {'Healthy Control', 'Bipolar disorder', 'Schizoaffective Disorder',...
    'Schizophrenia', 'Autistic Spectrum Disorders', 'Major depressive disorder' };
metadata.diagnosis_string(:,1) = diagString(Lb);

diagCat = unique(metadata.diagnosis);
for iDiag = 1:length(diagCat)
nSiteDiag(iDiag) = sum(strcmp(metadata.diagnosis, diagCat(iDiag)));
end

[La Lb] = ismember(metadata.subj_id, catFile.Var1);
metadata.CAT = cellstr(num2str(catFile.Var2(Lb)));
% medication
metadata.antipsychotic = if_med(extract(metadata.subj_id,digitsPattern), medFile, medName, 2, 5);
metadata.moodstabiliser = if_med(extract(metadata.subj_id,digitsPattern), medFile, medName, 3, 5);
metadata.antidepression = if_med(extract(metadata.subj_id,digitsPattern), medFile, medName, 4, 5);
metadata.antianxiety = if_med(extract(metadata.subj_id,digitsPattern), medFile, medName, 5, 5);
metadata.treatment = cellstr(num2str(any(logical([metadata.antipsychotic, metadata.moodstabiliser, metadata.antidepression, metadata.antianxiety]),2)));

metaTable = cell2table([metadata.subj_id, metadata.dataset, metadata.site, metadata.diagnosis,... 
    metadata.age, metadata.sex, metadata.site_string, metadata.sex_string, metadata.ses, metadata.diagnosis_string,...
    metadata.CAT, cellstr(num2str(metadata.antipsychotic)),...
    cellstr(num2str(metadata.moodstabiliser)), cellstr(num2str(metadata.antidepression)), ...
    cellstr(num2str(metadata.antianxiety)), metadata.treatment],...
    "VariableNames",["subj_id", "dataset", "site", "diagnosis", "age", "sex", "site_string", "sex_string", "ses", "diagnosis_string",...
    "CAT" ,"antipsychotic", "moodstabiliser", "antidepression", "antianxiety","treatment"]);

writetable(metaTable,['/projects/kg98/trangc/VBM/data/', study, '/',study,'_dems_extended.csv']);

% writelines(useFile, ['/projects/kg98/trangc/VBM/data/', study, '/useFile.txt']);
% writelines(metadata.useFolder, ['/projects/kg98/trangc/VBM/data/', study, '/subject_use_extract.txt']);

