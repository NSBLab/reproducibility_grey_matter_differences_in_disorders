%% read demographic information and extract subjects that satisfy criteria:
% - age: 18-60
% - each site has at least 20 subjects

% Trang Cao, Neural Systems and Behaviour Lab, Monash University, 2022.

clear all
close all

study = 'PARDIP';

% define const
LOWAGE = 18*12; % lower bound of age
UPAGE = 60*12; % upper bound of age
NSUB = 20; % lowest number of subject per site per phenotype

% read demographic files
imageFile = tdfread(['/projects/kg98/trangc/VBM/data/', study, '/image03.txt']);

imageFile.src_subject_id = cellstr(imageFile.src_subject_id(2:end,:));
imageFile.interview_age = str2double(string(imageFile.interview_age(2:end,:)));
imageFile.image_description = cellstr(imageFile.image_description(2:end,:));
imageFile.image_file = cellstr(imageFile.image_file(2:end,:));
imageFile.format = cellstr(imageFile.image_file_format(2:end,:));
% imageFile.site = cellstr(num2str(ismember(imageFile.format,{'parrec','PARREC'})));

imageFile.site = cellstr(imageFile.scanner_type_pd(2:end,:));
for i=1:length(imageFile.site)
    if ismember(imageFile.site(i),{'','Unknown'})
        fname = ['/home/trangc/kg98/trangc/VBM/data/PARDIP/sub-',char(imageFile.src_subject_id(i)),'/anat/anat.json'];
        if exist(fname)
        fid = fopen(fname);
        raw = fread(fid,inf);
        str = char(raw');
        fclose(fid);
        val = jsondecode(str);
        imageFile.site(i) = cellstr(val.Manufacturer);
        end
    end
end
imageFile.sex = cellstr(imageFile.sex(2:end,:));
medFile = readtable(['/projects/kg98/trangc/VBM/data/', study, '/dem/meds01.txt']);
hisFile = readtable(['/projects/kg98/trangc/VBM/data/', study, '/dem/pmh01.txt']);
medName = readtable(['/projects/kg98/trangc/VBM/data/medication_name_for_code.csv']);
diagFile = tdfread(['/projects/kg98/trangc/VBM/data/', study, '/ndar_subject01.txt']);

diagFile.phenotype = cellstr(diagFile.phenotype(2:end,:));
diagFile.src_subject_id = cellstr(diagFile.src_subject_id(2:end,:));


% image filename
pat1 = "S"+wildcardPattern+".zip";
imageFile.filename = char(extract(imageFile.image_file,pat1));
% folder name
imageFile.folderName = "sub-" + imageFile.src_subject_id;
% subject in the age range 18-60 at scanning time
imageFile.adult = imageFile.interview_age >= LOWAGE & imageFile.interview_age <= UPAGE;
adult.ID = unique(imageFile.src_subject_id(imageFile.adult == 1));

% list of sites and diagnose
[site, ~, indexSite] = unique(imageFile.site);
[diag, ~, indexDiag] = unique(diagFile.phenotype);
nSite = size(site,1);
nDiag = size(diag,1)-1; % combine BD and BDP as patients
iControl = 2;


for iSite = 1: nSite
    
    % adult patients
    condition = ismember(adult.ID, diagFile.src_subject_id(indexDiag == 1 | indexDiag == 2))...
        & ismember(adult.ID, imageFile.src_subject_id(indexSite == iSite));
    % number of adult patients
    nSubPerPhenotypePerSite(iSite,1) = sum(condition);
    
    % adult HC
    condition = ismember(adult.ID, diagFile.src_subject_id(indexDiag == 3))...
        & ismember(adult.ID, imageFile.src_subject_id(indexSite == iSite));
    
    % number of adult HC
    nSubPerPhenotypePerSite(iSite,2) = sum(condition);
    
end



% the site and phenotype has >= NSUB HC subjects
siteSizeCondition = nSubPerPhenotypePerSite >= NSUB;

adult.use =  zeros(size(adult.ID));

for iSite = 1: nSite
    
    % extract subject from sites having >= NSUB HC subjects and >= NSUB patients
    if siteSizeCondition(iSite, iControl) == 1 & sum(siteSizeCondition(iSite, setdiff(1:nDiag,iControl))) >= 1
        
        % adult patients
        condition = ismember(adult.ID, diagFile.src_subject_id(indexDiag == 1 | indexDiag == 2))...
            & ismember(adult.ID, imageFile.src_subject_id(indexSite == iSite));
        adult.use(condition) = 1;
        
        % adult HC
        condition = ismember(adult.ID, diagFile.src_subject_id(indexDiag == 3))...
            & ismember(adult.ID, imageFile.src_subject_id(indexSite == iSite));
        adult.use(condition) = 1;
        useID = adult.ID(adult.use==1);
        
indexinUse = ismember(imageFile.src_subject_id,useID) & indexSite == iSite ;
        imageFile.useID(indexinUse,1) = true; %one sub can be in two scanners so condition in the suitable scanner/site
    end
end

% extract image filename satisfying: ID of usable subjects and
% image_description in the list



descriptionList = {'WIP ADNI MPRAGE pg7 SENSE', 'BSNIP2_MPRAGE_ADNI',...
    'SAG MPRAGE', 'BSNIP2_MPRAGE_ADNI_GRAPPA', 'PARDIP Sag MPRAGE'};

imageFile.useDescription = ismember(imageFile.image_description, descriptionList);


imageFile.useFile = imageFile.useID == 1 & imageFile.useDescription == 1;
[iUseFile col va] = find(imageFile.useFile);

idUse = imageFile.src_subject_id(iUseFile);
[useSub iUnique iID] = unique(idUse);

useFile = cellstr(imageFile.filename(iUseFile(iUnique),:));
useFolder = cellstr(imageFile.folderName(iUseFile(iUnique),:));
siteSubUse = (imageFile.site(iUseFile(iUnique)));

% writelines(append(useFolder, useFile), ['/projects/kg98/trangc/VBM/data/', study, '/useFile.txt']);
% writelines(useFolder, ['/projects/kg98/trangc/VBM/data/', study, '/subject_use_extract.txt']);

%%
% create metadata
IQRthres = 2.8;
% read cat report
catFile = readtable(['/projects/kg98/trangc/VBM/data/', study, '/cat12_qcReport_', study, '.txt']);
subHighQR = catFile.Var1(catFile.Var2 <= IQRthres);

[La indexHighQRinUseFolder] = ismember(subHighQR, useFolder); % index in use Folder is same as in iUnique
indexHighQRinUseFolder = indexHighQRinUseFolder(indexHighQRinUseFolder>0);
metadata.subj_id = cellstr(useFolder(indexHighQRinUseFolder));
metadata.dataset = cellstr(repmat(study,size(indexHighQRinUseFolder)));
metadata.site_string = imageFile.site(iUseFile(iUnique(indexHighQRinUseFolder)));
siteString = unique(metadata.site_string );
metadata.site = cellstr(num2str(ismember(metadata.site_string,siteString(1))+19));

metadata.age = imageFile.interview_age(iUseFile(iUnique(indexHighQRinUseFolder)))./12;
metadata.sex_string = cellstr(imageFile.sex(iUseFile(iUnique(indexHighQRinUseFolder))));
metadata.sex = cellstr(num2str(strcmp(metadata.sex_string,'M')));
% find diagnosis for used subjects
[La Lb] = ismember(imageFile.src_subject_id(iUseFile(iUnique(indexHighQRinUseFolder))), diagFile.src_subject_id);
metadata.diagnosis_string = cellstr(diagFile.phenotype(Lb));
metadata.diagnosis = double(strcmp(metadata.diagnosis_string, 'HC'));
metadata.diagnosis(metadata.diagnosis==0) = 2;

diagString = {'HC', 'BD', 'SCA',...
    'SCZ', 'ASD', 'MDD' };
metadata.diagnosis_string(:,1) = diagString(metadata.diagnosis);
metadata.diagnosis = cellstr(num2str(metadata.diagnosis));

%% check number of subjects
siteCat = unique(metadata.site);
diagCat = unique(metadata.diagnosis);

for iSite = 1: length(siteCat)
    for iDiag = 1: length(diagCat) % control and proband in the diag list
        
        % number of adult subjects in each phenotype in each site
        nSiteDiag(iSite, iDiag) = sum(strcmp(metadata.site, siteCat(iSite)) & strcmp(metadata.diagnosis, diagCat(iDiag)));
        
    end
end

% the site and phenotype has >= NSUB HC subjects
nSiteDiagCondition = nSiteDiag >= NSUB;

nSiteCondition = nSiteDiagCondition(:,1) & any(nSiteDiagCondition(:,2:end),2);
siteCon = siteCat(nSiteCondition);

%%
metadata.con = zeros(size(metadata.subj_id));
for iSite = 1:length(siteCon)
    
        condition = ismember(metadata.site,siteCon(iSite));

        metadata.con(condition) = 1;
end
% metadata.con(ismember(metadata.subj_id,'sub-2467ZEJ')) = 0;% remove sub with wrong site info, see note.txt
metadata.con = logical(metadata.con);

[La Lb] = ismember(metadata.subj_id(metadata.con), catFile.Var1);
metadata.CAT = cellstr(num2str(catFile.Var2(Lb)));
%% meditcation
matchIDHighQRcon = extract(metadata.subj_id(metadata.con),digitsPattern);

metadata.antipsychotic = if_med(matchIDHighQRcon, medFile, medName, 2, 20,study);  %maxNoMed=18
metadata.moodstabiliser = if_med(matchIDHighQRcon, medFile, medName, 3, 20,study);
metadata.antidepression = if_med(matchIDHighQRcon, medFile, medName, 4, 20,study);
metadata.antianxiety = if_med(matchIDHighQRcon, medFile, medName, 5, 20,study);
metadata.treatment = cellstr(num2str(any(logical([metadata.antipsychotic, metadata.moodstabiliser, metadata.antidepression, metadata.antianxiety]),2)));

%%
criteria = 'bpdx';
[metadata.ageOnset, metadata.illnessDuration] = if_onset(matchIDHighQRcon, hisFile, metadata.age(metadata.con), criteria);
%%
metaTable = cell2table([metadata.subj_id(metadata.con), metadata.dataset(metadata.con), ...
    metadata.site(metadata.con), metadata.diagnosis(metadata.con), cellstr(num2str(metadata.age(metadata.con))),...
    metadata.sex(metadata.con), metadata.site_string(metadata.con), metadata.sex_string(metadata.con),...
    metadata.diagnosis_string(metadata.con), metadata.CAT, cellstr(num2str(metadata.antipsychotic)),...
    cellstr(num2str(metadata.moodstabiliser)), cellstr(num2str(metadata.antidepression)), ...
    cellstr(num2str(metadata.antianxiety)), metadata.treatment, cellstr(num2str(metadata.ageOnset)), ...
    cellstr(num2str(metadata.illnessDuration))], "VariableNames",["subj_id", "dataset", "site", "diagnosis",...
    "age", "sex", "site_string", "sex_string",  "diagnosis_string" , "CAT" ,"antipsychotic", "moodstabiliser", "antidepression", "antianxiety","treatment","ageOnset","illnessDuration"]);

writetable(metaTable,['/projects/kg98/trangc/VBM/data/', study, '/',study,'_dems_extended.csv']);
