%% read demographic information and extract subjects that satisfy criteria:
% - age: 18-60
% - each site has at least 20 subjects

% Trang Cao, Neural Systems and Behaviour Lab, Monash University, 2022.

clear all
close all

study = 'Inhi_dys';

% define const
LOWAGE = 18*12; % lower bound of age
UPAGE = 60*12; % upper bound of age
NSUB = 20; % lowest number of subject per site per phenotype

% read demographic files
imageFile = tdfread(['/projects/kg98/trangc/VBM/data/', study, '/image03.txt']);

imageFile.src_subject_id = cellstr(imageFile.src_subject_id(2:end,:));
imageFile.interview_age = str2double(string(imageFile.interview_age(2:end,:)));
imageFile.scan_type = cellstr(imageFile.scan_type(2:end,:));
imageFile.image_file = cellstr(imageFile.image_file(2:end,:));
imageFile.sex = cellstr(imageFile.sex(2:end,:));

diagFile = tdfread(['/projects/kg98/trangc/VBM/data/', study, '/ndar_subject01.txt']);

diagFile.phenotype = cellstr(diagFile.phenotype(2:end,:));
diagFile.src_subject_id = cellstr(diagFile.src_subject_id(2:end,:));

descriptionList = {'MR structural (MPRAGE)'};

imageFile.useDescription = ismember(imageFile.scan_type, descriptionList);

% image filename
pat1 = ("/G"+ wildcardPattern + ".REC");
filenameWithPattern = char(extract(imageFile.image_file(imageFile.useDescription),pat1));
imageFile.filename(imageFile.useDescription,1:size(filenameWithPattern,2)-1) = filenameWithPattern(:,2:end);

% folder name
temp = char(imageFile.src_subject_id);
imageFile.folderName = "sub-" + temp(:,2:4);

% subject in the age range 18-60 at scanning time
imageFile.adult = imageFile.interview_age >= LOWAGE & imageFile.interview_age <= UPAGE;
adult.ID = unique(imageFile.src_subject_id(imageFile.adult == 1));

% list of sites and diagnose
[diag, ~, indexDiag] = unique(diagFile.phenotype);
nDiag = size(diag,1); 
control = 'No Diagnosis';
 [iControl ic] = find(strcmp(diag, control));


for iDiag = 1: nDiag % control and proband in the diag list
    
% adult patients
condition = ismember(adult.ID, diagFile.src_subject_id(indexDiag == iDiag));
% number of adult patients
nSubPerPhenotypePerSite(iDiag) = sum(condition);

end




% the site and phenotype has >= NSUB HC subjects
siteSizeCondition = nSubPerPhenotypePerSite >= NSUB;

adult.use =  zeros(size(adult.ID));
for iDiag = 1:length(diag)
            
            if siteSizeCondition(iDiag) == 1
                
                % adult subjects in each phenotype in each site
                condition = ismember(adult.ID,...
            diagFile.src_subject_id(indexDiag == iDiag));
                adult.use(condition) = 1;
            end
            
        end

% extract image filename satisfying: ID of usable subjects and
% scan_type in the list

useID = adult.ID(adult.use==1);
imageFile.useID = ismember(imageFile.src_subject_id,useID);




imageFile.useFile = imageFile.useID == 1 & imageFile.useDescription == 1;
[iUseFile col va] = find(imageFile.useFile);

idUse = imageFile.src_subject_id(iUseFile);
[useSub iUnique iID] = unique(idUse);

useFile = cellstr(imageFile.filename(iUseFile(iUnique),:));
useFolder = cellstr(imageFile.folderName(iUseFile(iUnique),:));

% writelines(append(useFolder, useFile), ['/projects/kg98/trangc/VBM/data/', study, '/useFile.txt']);
% writelines(useFolder, ['/projects/kg98/trangc/VBM/data/', study, '/subject_use_extract.txt']);

% create metadata
IQRthres = 2.8;
% read cat report
catFile = readtable(['/projects/kg98/trangc/VBM/data/', study, '/cat12_qcReport_', study, '.txt']);
subHighQR = catFile.Var1(catFile.Var2 <= IQRthres);
[La indexHighQRinUseFolder] = ismember(subHighQR, useFolder); % index in use Folder is same as in iUnique

metadata.subj_id = cellstr(useFolder(indexHighQRinUseFolder));
metadata.ses = catFile.Var3(catFile.Var2 <= IQRthres);
metadata.dataset = cellstr(repmat(study,size(metadata.subj_id)));
metadata.site = cellstr(repmat('23',size(metadata.subj_id)));
metadata.site_string = metadata.dataset;
metadata.age = cellstr(num2str(round(imageFile.interview_age(iUseFile(iUnique(indexHighQRinUseFolder)))./12)));
metadata.sex_string = cellstr(imageFile.sex(iUseFile(iUnique(indexHighQRinUseFolder))));
metadata.sex = cellstr(num2str(strcmp(metadata.sex_string,'M')));

% find diagnosis for used subjects
[La Lb] = ismember(imageFile.src_subject_id(iUseFile(iUnique(indexHighQRinUseFolder))), diagFile.src_subject_id);
metadata.diagnosis_string = cellstr(diagFile.phenotype(Lb));
[La Lb] = ismember(metadata.diagnosis_string, diag);
Lb(Lb==1) = 5;
Lb(Lb==2) = 1;
metadata.diagnosis = cellstr(num2str(Lb));
diagString = {'Healthy Control', 'Bipolar disorder', 'Schizoaffective Disorder',...
    'Schizophrenia', 'Autistic Spectrum Disorders', 'Major depressive disorder' };
metadata.diagnosis_string(:,1) = diagString(Lb);

diagCat = unique(metadata.diagnosis);
for iDiag = 1:length(diagCat)
nSiteDiag(iDiag) = sum(strcmp(metadata.diagnosis, diagCat(iDiag)));
end
%% CAT
[La Lb] = ismember(metadata.subj_id, catFile.Var1);
metadata.CAT = cellstr(num2str(catFile.Var2(Lb)));

metaTable = cell2table([metadata.subj_id, metadata.dataset, metadata.site, metadata.diagnosis,... 
    metadata.age, metadata.sex, metadata.site_string, metadata.sex_string, metadata.ses, metadata.diagnosis_string, metadata.CAT],...
    "VariableNames",["subj_id", "dataset", "site", "diagnosis", "age", "sex", "site_string", "sex_string", "ses", "diagnosis_string", "CAT"  ]);

writetable(metaTable,['/projects/kg98/trangc/VBM/data/', study, '/',study,'_dems_extended.csv']);

