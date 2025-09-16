%% read demographic information and extract subjects that satisfy criteria:
% - age: 18-60
% - each site has at least 20 subjects

% Trang Cao, Neural Systems and Behaviour Lab, Monash University, 2022.

clear all
close all

study = 'Modul_vent';

% define const
LOWAGE = 18*12; % lower bound of age
UPAGE = 60*12; % upper bound of age
NSUB = 20; % lowest number of subject per site per phenotype

% read demographic files
diagFile = tdfread(['/projects/kg98/trangc/VBM/data/', study, '/ndar_subject01.txt']);
imageFile = tdfread(['/projects/kg98/trangc/VBM/data/', study, '/image03.txt']);
medFile = readtable(['/projects/kg98/trangc/VBM/data/', study, '/dem/medlist01.txt']);
medName = readtable(['/projects/kg98/trangc/VBM/data/medication_name_for_code.csv']);

diagFile.phenotype = cellstr(diagFile.phenotype);
diagFile.src_subject_id = cellstr(diagFile.src_subject_id);
imageFile.src_subject_id = cellstr(imageFile.src_subject_id(2:end,:));
imageFile.interview_age = str2double(string(imageFile.interview_age(2:end,:)));
imageFile.image_description = cellstr(imageFile.image_description(2:end,:));
imageFile.image_file = cellstr(imageFile.image_file(2:end,:));
imageFile.sex = cellstr(imageFile.sex(2:end,:));


% image filename
pat1 = "impres"+wildcardPattern+".zip";
imageFile.filename = cellstr(extract(imageFile.image_file,pat1));
% check if file in Phillips folder
pat2 = "Phillips";
imageFile.Phillips = contains(imageFile.image_file,pat2);
imageFile.filename(imageFile.Phillips) = append('Phillips/projects/RDoCdb/NIMHDA/', imageFile.filename(imageFile.Phillips));
% file of session 1 or 2
pat3 = "s1/";
imageFile.ses1 = contains(imageFile.filename,pat3);
pat4 = "s2/";
imageFile.ses2 = contains(imageFile.filename,pat4);
% folder name
imageFile.folderName = "sub-" + imageFile.src_subject_id;
% subject in the age range 18-60 at scanning time
imageFile.adult = imageFile.interview_age >= LOWAGE & imageFile.interview_age <= UPAGE;
adult.ID = unique(imageFile.src_subject_id(imageFile.adult == 1));

% % list of sites and diagnose
% [site, ~, indexSite] = unique(siteFile.site);
% [diag, ~, indexDiag] = unique(siteFile.diag);
%  nSite = size(site,1); 
%  nDiag = size(diag,1);
%  if strcmp(study, 'BSNIP')
% diagList = 1:4;
%  else
%      diagList = 3:6;
%  end
%  control = 'Healthy Control';
%  [iControl ic] = find(strcmp(diag, control));


% for iSite = 1: nSite
%     for iDiag = 1: nDiag % control and proband in the diag list
%         
%         % adult subjects in each phenotype in each site
%         condition = ismember(adult.ID,...
%             siteFile.src_subject_id(indexSite == iSite & indexDiag == iDiag));
%         
%         % number of adult subjects in each phenotype in each site
%         nSubPerPhenotypePerSite(iSite, iDiag) = sum(condition);
%         
%     end
% end
% 
% % the site and phenotype has >= NSUB HC subjects
% siteSizeCondition = nSubPerPhenotypePerSite >= NSUB;
% 
% adult.use =  zeros(size(adult.ID));
% for iSite = 1: nSite
%     
%     % extract subject from sites having >= NSUB HC subjects and >= NSUB patients
%     if siteSizeCondition(iSite, iControl) == 1 & sum(siteSizeCondition(iSite, setdiff(diagList,iControl))) >= 1
%         
%         for iDiag = diagList
%             
%             if siteSizeCondition(iSite, iDiag) == 1
%                 
%                 % adult subjects in each phenotype in each site
%                 condition = ismember(adult.ID,...
%             siteFile.src_subject_id(indexSite == iSite & indexDiag == iDiag));
%                 adult.use(condition) = 1;
%             end
%             
%         end
%         
%     end
%     
% end

% extract image filename satisfying: ID of usable subjects and
% image_description in the list

useID = adult.ID;
imageFile.useID = ismember(imageFile.src_subject_id,useID);

descriptionList = {'T1_MPRAGE_Iso'};

imageFile.useDescription = ismember(imageFile.image_description, descriptionList);


imageFile.useFile1 = imageFile.useID == 1 & imageFile.useDescription == 1 & imageFile.ses1 == 1;
imageFile.useFile2 = imageFile.useID == 1 & imageFile.useDescription == 1 & imageFile.ses2 == 1;
[iUseFile1 col va] = find(imageFile.useFile1);
[iUseFile2 col va] = find(imageFile.useFile2);


[useSub1 iUnique1 iID] = unique(imageFile.folderName(iUseFile1));
[useSub2 iUnique2 iID] = unique(imageFile.folderName(iUseFile2));

useFile1 = cellstr(imageFile.filename(iUseFile1(iUnique1),:));
useFolder1 = cellstr(imageFile.folderName(iUseFile1(iUnique1),:));

useFile2 = cellstr(imageFile.filename(iUseFile2(iUnique2),:));
useFolder2 = cellstr(imageFile.folderName(iUseFile2(iUnique2),:));

% writelines(useFile1, ['/projects/kg98/trangc/VBM/data/', study, '/useFile1.txt']);
% writelines(useSub1, ['/projects/kg98/trangc/VBM/data/', study, '/subject_use1.txt']);
% 
% writelines(useFile2, ['/projects/kg98/trangc/VBM/data/', study, '/useFile2.txt']);
% writelines(useSub2, ['/projects/kg98/trangc/VBM/data/', study, '/subject_use2.txt']);

%%
% create metadata
IQRthres = 2.8;
% read cat report
catFile = readtable(['/projects/kg98/trangc/VBM/data/', study, '/cat12_qcReport_', study, '.txt']);
subHighQR = catFile.Var1(catFile.Var2 <= IQRthres);

[La indexHighQRinUseFolder] = ismember(subHighQR, useFolder1); % index in use Folder is same as in iUnique

metadata.subj_id = cellstr(useFolder1(indexHighQRinUseFolder));
metadata.ses = catFile.Var3(catFile.Var2 <= IQRthres);
metadata.dataset = cellstr(repmat(study,size(indexHighQRinUseFolder)));
metadata.site = cellstr(repmat('18',size(indexHighQRinUseFolder)));
metadata.site_string = metadata.dataset;
metadata.age = cellstr(num2str(round(imageFile.interview_age(iUseFile1(iUnique1(indexHighQRinUseFolder)))./12)));
metadata.sex_string = cellstr(imageFile.sex(iUseFile1(iUnique1(indexHighQRinUseFolder))));
metadata.sex = cellstr(num2str(strcmp(metadata.sex_string,'M')));


% find diagnosis for used subjects
[La Lb] = ismember(imageFile.src_subject_id(iUseFile1(iUnique1(indexHighQRinUseFolder))), diagFile.src_subject_id);
metadata.diagnosis_string = cellstr(diagFile.phenotype(Lb));
[La Lb] = ismember(metadata.diagnosis_string, unique(metadata.diagnosis_string));
Lb(Lb==2) = 4;
Lb(Lb==1) = 2;
Lb(Lb==4) = 1;
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
