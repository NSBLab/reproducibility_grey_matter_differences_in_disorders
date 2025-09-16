%% read demographic information and extract subjects that satisfy criteria:
% - age: 18-60
% - each site has at least 20 subjects

% Trang Cao, Neural Systems and Behaviour Lab, Monash University, 2022.

clear all
close all

study = 'BSNIP2';

% define const
LOWAGE = 18*12; % lower bound of age
UPAGE = 60*12; % upper bound of age
NSUB = 20; % lowest number of subject per site per phenotype

% read demographic files
siteFile = readtable(['/projects/kg98/trangc/VBM/data/', study, '/site.txt']);
imageFile = readtable(['/projects/kg98/trangc/VBM/data/', study, '/image03.txt']);
medFile = readtable(['/projects/kg98/trangc/VBM/data/', study, '/dem/meds01.txt']);
hisFile = readtable(['/projects/kg98/trangc/VBM/data/', study, '/dem/pmh01.txt']);
medName = readtable(['/projects/kg98/trangc/VBM/data/medication_name_for_code.csv']);
siteFile.diag = cellstr(siteFile.study);
siteFile.src_subject_id = cellstr(num2str(siteFile.src_subject_id));
imageFile.src_subject_id = cellstr(num2str(imageFile.src_subject_id));
medFile.src_subject_id = cellstr(num2str(medFile.src_subject_id));
hisFile.src_subject_id = cellstr(num2str(hisFile.src_subject_id));
% image filename
pat1 = "S"+wildcardPattern+".zip";
imageFile.filename = char(extract(imageFile.image_file,pat1));

% folder name
imageFile.folderName = "sub-" + imageFile.filename(:,2:8);

% subject in the age range 18-60 at scanning time
imageFile.adult = imageFile.interview_age >= LOWAGE & imageFile.interview_age <= UPAGE;
adult.ID = unique(imageFile.src_subject_id(imageFile.adult == 1));


% list of sites and diagnose
[site, ~, indexSite] = unique(siteFile.site);
[diag, ~, indexDiag] = unique(siteFile.diag);
nSite = size(site,1);
nDiag = size(diag,1);
diag
if strcmp(study, 'BSNIP')
    diagList = 1:4;
else
    diagList = [2 3 5 6];
end
control = 'Healthy Control';
[iControl ic] = find(strcmp(diag, control));


for iSite = 1: nSite
    for iDiag = 1: nDiag % control and proband in the diag list

        % adult subjects in each phenotype in each site
        condition = ismember(adult.ID,...
            siteFile.src_subject_id(indexSite == iSite & indexDiag == iDiag));

        % number of adult subjects in each phenotype in each site
        nSubPerPhenotypePerSite(iSite, iDiag) = sum(condition);

    end
end

% the site and phenotype has >= NSUB HC subjects
siteSizeCondition = nSubPerPhenotypePerSite >= NSUB;

adult.use =  zeros(size(adult.ID));
for iSite = 1: nSite

    % extract subject from sites having >= NSUB HC subjects and >= NSUB patients
    if siteSizeCondition(iSite, iControl) == 1 & sum(siteSizeCondition(iSite, setdiff(diagList,iControl))) >= 1

        for iDiag = diagList

            if siteSizeCondition(iSite, iDiag) == 1

                % adult subjects in each phenotype in each site
                condition = ismember(adult.ID,...
                    siteFile.src_subject_id(indexSite == iSite & indexDiag == iDiag));
                adult.use(condition) = 1;
            end

        end

        % site infor
        imageFile.site(ismember(imageFile.src_subject_id, siteFile.src_subject_id(indexSite == iSite))) = iSite;


    end

end

% extract image filename satisfying: ID of usable subjects and
% image_description in the list

useID = adult.ID(adult.use==1);
imageFile.useID = ismember(imageFile.src_subject_id,useID);

if strcmp(study, 'BSNIP')
    descriptionList = {'ADNI MPRAGE pg7 SENSE', 'WIP ADNI MPRAGE pg7 SENSE', ...
        'ADNI MPRAGE SENSE', 'SAG MPRAGE T1 MPRAGE', 'T1 MPRAGE', 'MPRAGE', 'MPRAGE_SAG', ...
        'Bsnip Sag MPRAGE-like ADNI', 'Sagittal MPRAGE-like ADNI', 'Sagittal MPRAGE',...
        'T1 MPRAGE Repeat', 'MPRAGE_repeat', 'MPRAGE Repeat', 'MPRAGE_SAG Repeat'};

else
    descriptionList = {'BSNIP2_MPRAGE_ADNI_GRAPPA', 'FSPGR BRAVO', 'MPRAGE_SENSE SENSE',...
        'SAG MPRAGE', 'SAG MPRAGE ASSET', 'T1 no asset', 'T1asset', 'WIP ADNI Double_TSE SENSE',...
        'WIP ADNI MPRAGE pg7 SENSE', 'WIP MPRage SENSE', 'WIP MPRage SENSE2 SENSE',...
        'WIP MPRAGE_SENSE SENSE', 'WIP T1 W 3D - SENSE2', 'WIP T1 W 3D - SENSE2 SENSE',...
        'WIP T1 W 3D SENSE', 'WIP T1W3D TFE Sag', 'WIP T1W3D TFE Sag SENSE'};
end

imageFile.useDescription = ismember(imageFile.image_description, descriptionList);


imageFile.useFile = imageFile.useID == 1 & imageFile.useDescription == 1;
[iUseFile col va] = find(imageFile.useFile);

idUse = imageFile.src_subject_id(iUseFile);
[useSub iUnique iID] = unique(idUse);

useFile = cellstr(imageFile.filename(iUseFile(iUnique),:));
useFolder = cellstr(imageFile.folderName(iUseFile(iUnique),:));
matchID = cellstr(imageFile.src_subject_id(iUseFile(iUnique),:));
siteSubUse = double(imageFile.site(iUseFile(iUnique)))-1;

% create metadata
% read euler number
holesFile = readtable(['/projects/kg98/trangc/VBM/data/', study, '/derivatives/euler/', study, '_holes.csv'], 'ReadVariableNames', false);
if ~all(arrayfun(@(x) strcmp(holesFile.Var1{x}(1:end-3),holesFile.Var1{x+1}(1:end-3)),1:2:length(holesFile.Var1)))
    error('Error. Do not have both hemispheres.')
end

inSubLh = 1:2:length(holesFile.Var1);
eulerNumber = mean([2 - 2*holesFile.Var2(inSubLh), 2 - 2*holesFile.Var2(inSubLh+1)],2);
meanEN = mean(2 - 2*holesFile.Var2);
SD_EN = std(2 - 2*holesFile.Var2);

ENsubHighEN = eulerNumber((eulerNumber > (meanEN-3.29*SD_EN)));
subHighEN = arrayfun(@(x) holesFile.Var1{inSubLh(x)}(1:end-3), find(eulerNumber > (meanEN-3.29*SD_EN)), 'UniformOutput', false);


% exclude after visualize
mark = readtable(fullfile('/projects/kg98/trangc/VBM/data', study,'sub_with_recon_output_marked.txt'),'ReadVariableNames', false);
[lia locb] = ismember(subHighEN, mark.Var1);
if size(mark,2) == 2
    subHighEN(strcmp(mark.Var2(locb),'x')) = [];
end

[La indexHighQRinUseFolder] = ismember(subHighEN, useFolder); % index in use Folder is same as in iUnique
indexHighQRinUseFolder = indexHighQRinUseFolder(indexHighQRinUseFolder>0);
subHighEN = useFolder(indexHighQRinUseFolder);

% writetable(cell2table(subHighEN),['/projects/kg98/trangc/VBM/data/', study, '/sub_without_outlier.txt'],"WriteVariableNames",false);
% writetable(cell2table(subWithOutlier(ismember(subWithOutlier,subHighEN)==0)),['/projects/kg98/trangc/VBM/data/', study, '/autoQCOutlier.txt'],"WriteVariableNames",false);

metadata.subj_id = cellstr(useFolder(indexHighQRinUseFolder));
matchIDHighQR = cellstr(matchID(indexHighQRinUseFolder));
metadata.dataset = cellstr(repmat(study,size(indexHighQRinUseFolder)));
metadata.site_string = site(imageFile.site(iUseFile(iUnique(indexHighQRinUseFolder))));
[La Lb] = ismember(metadata.site_string,unique(metadata.site_string));
if strcmp(study, 'BSNIP')
    metadata.site = cellstr(num2str(Lb));
else
    metadata.site = cellstr(num2str(Lb+4));
end
metadata.age = imageFile.interview_age(iUseFile(iUnique(indexHighQRinUseFolder)))./12;
metadata.sex_string = cellstr(imageFile.sex(iUseFile(iUnique(indexHighQRinUseFolder))));
metadata.sex = cellstr(num2str(strcmp(metadata.sex_string,'M')));

% find diagnosis for used subjects
[La Lb] = ismember(imageFile.src_subject_id(iUseFile(iUnique(indexHighQRinUseFolder))), siteFile.src_subject_id);
metadata.diagnosis_string = cellstr(siteFile.diag(Lb));
[La Lb] = ismember(metadata.diagnosis_string, diag);
diag
if ~strcmp(study, 'BSNIP')
    Lb(Lb==iControl) = 1;
    Lb(Lb==2) = 2;
    Lb(Lb==5) = 3;
    Lb(Lb==6) = 4;
end
metadata.diagnosis = cellstr(num2str(Lb));
diagString = {'HC', 'BD', 'SCA',...
    'SCZ', 'ASD', 'MDD' };

metadata.diagnosis_string(:,1) = diagString(Lb);

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
nSiteCondition = nSiteDiagCondition(:,1) & any(nSiteDiagCondition(:,2:4),2);
siteCon = siteCat(nSiteCondition);

%%
metadata.con = zeros(size(metadata.subj_id));
for iSite = 1:length(siteCon)

    siteDiag = diagCat(nSiteDiagCondition(iSite,:)); % diag for this site
    for iDiag = 2:length(siteDiag)
        condition = ismember(metadata.site,siteCon(iSite)) & ...
            ismember(metadata.diagnosis, siteDiag([1,iDiag]));
        metadata.con = metadata.con | condition;
        qdecTable = cell2table([metadata.subj_id(condition), metadata.diagnosis(condition), ...
            metadata.sex(condition), cellstr(num2str(metadata.age(condition)))], "VariableNames",["fsid", "diagnosis",...
            "sex", "age"]);
        writetable(qdecTable,['/projects/kg98/trangc/VBM/data/', study, ...
            '/qdec_table_', char(unique(metadata.site_string(condition))),'_',char(siteDiag(iDiag)),'.dat'],'Delimiter','tab');
    end

end

metadata.antipsychotic = if_med(matchIDHighQR, medFile, medName, 2, 18);  %maxNoMed=18
metadata.moodstabiliser = if_med(matchIDHighQR, medFile, medName, 3, 18);
metadata.antidepression = if_med(matchIDHighQR, medFile, medName, 4, 18);
metadata.antianxiety = if_med(matchIDHighQR, medFile, medName, 5, 18);
metadata.treatment = cellstr(num2str(any(logical([metadata.antipsychotic, metadata.moodstabiliser, metadata.antidepression, metadata.antianxiety]),2)));

%%
if strcmp(study, 'BSNIP')
    criteria = 'szsadbponset';
else
    criteria = 'szsadbpdx';
end
[metadata.ageOnset, metadata.illnessDuration] = if_onset(matchIDHighQR, hisFile, metadata.age,criteria);


%%
metaTable = cell2table([metadata.subj_id(metadata.con), metadata.dataset(metadata.con), ...
    metadata.site(metadata.con), metadata.diagnosis(metadata.con), cellstr(num2str(metadata.age(metadata.con))),...
    metadata.sex(metadata.con), metadata.site_string(metadata.con), metadata.sex_string(metadata.con),...
    metadata.diagnosis_string(metadata.con), cellstr(num2str(ENsubHighEN(ismember(subHighEN,metadata.subj_id(metadata.con))))), ...
    cellstr(num2str(metadata.antipsychotic(metadata.con))),...
    cellstr(num2str(metadata.moodstabiliser(metadata.con))), cellstr(num2str(metadata.antidepression(metadata.con))), ...
    cellstr(num2str(metadata.antianxiety(metadata.con))), metadata.treatment(metadata.con), cellstr(num2str(metadata.ageOnset(metadata.con))), ...
    cellstr(num2str(metadata.illnessDuration(metadata.con)))], "VariableNames",["subj_id", "dataset", "site", "diagnosis",...
    "age", "sex", "site_string", "sex_string",  "diagnosis_string", "EN" ,"antipsychotic", "moodstabiliser",...
    "antidepression", "antianxiety","treatment","ageOnset","illnessDuration"]);

writetable(metaTable,['/projects/kg98/trangc/VBM/data/', study, '/',study,'_qdec_extended.csv']);

%% test
% print first line and last line of metaTable and compare with original
% info - need manual check
testsub1 = metaTable(1,:)
testsub2 = metaTable(end,:)
imageFile(ismember(cellstr(imageFile.folderName),[testsub1.subj_id,testsub2.subj_id]),:)
siteFile(ismember(cellstr(siteFile.src_subject_id),imageFile.src_subject_id(ismember(cellstr(imageFile.folderName),[testsub1.subj_id,testsub2.subj_id]),:)),:)

