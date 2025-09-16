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
imageFile = readtable(['/projects/kg98/trangc/VBM/data/', study, '/image03.txt']);

imageFile.interview_age = str2double(string(imageFile.interview_age)); % remove the first line of description
[imageFile.interview_age iTimeOrder] = sort(imageFile.interview_age);
imageFile.image_description = cellstr(imageFile.image_description);
imageFile.image_description = imageFile.image_description(iTimeOrder,:);
imageFile.image_file = cellstr(imageFile.image_file);
imageFile.image_file = imageFile.image_file(iTimeOrder,:);
imageFile.src_subject_id = cellstr(imageFile.src_subject_id);
imageFile.src_subject_id = imageFile.src_subject_id(iTimeOrder,:);
imageFile.sex = cellstr(imageFile.sex);
imageFile.sex = imageFile.sex(iTimeOrder,:);
medFile = readtable(['/projects/kg98/trangc/VBM/data/', study, '/dem/medlist01.txt']);
medName = readtable(['/projects/kg98/trangc/VBM/data/medication_name_for_code.csv']);

% read diagnosis file
diagFile = tdfread(['/projects/kg98/trangc/VBM/data/', study, '/ndar_subject01.txt']);

diagFile.phenotype = cellstr(diagFile.phenotype);
diagFile.src_subject_id = cellstr(diagFile.src_subject_id);

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
%%
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

indexHighQRinUseFolder = indexHighQRinUseFolder(indexHighQRinUseFolder>0);


metadata.subj_id = cellstr(useFolder(indexHighQRinUseFolder));
% metadata.ses = catFile.Var3(catFile.Var2 <= IQRthres);
metadata.dataset = cellstr(repmat(study,size(metadata.subj_id)));
metadata.site = cellstr(repmat('17',size(metadata.subj_id)));
metadata.site_string = metadata.dataset;
metadata.age = cellstr(num2str(round(imageFile.interview_age(iUseFile(iUnique(indexHighQRinUseFolder)))./12)));
metadata.sex_string = cellstr(imageFile.sex(iUseFile(iUnique(indexHighQRinUseFolder))));
metadata.sex = cellstr(num2str(strcmp(metadata.sex_string,'M')));
metadata.diagnosis = zeros(size(metadata.age));

% find diagnosis for used subjects
diag
[La Lb] = ismember(imageFile.src_subject_id(iUseFile(iUnique(indexHighQRinUseFolder))), diagFile.src_subject_id);
metadata.diagnosis_string = cellstr(diagFile.phenotype(Lb));
[La Lb] = ismember(metadata.diagnosis_string, diag);
Lb(Lb==4) = 0;
Lb(Lb==2) = 0;
Lb(Lb==3) = 4;
metadata.diagnosis = cellstr(num2str(Lb));
diagString = {'HC', 'BD', 'SCA',...
    'SCZ', 'ASD', 'MDD' };
metadata.diagnosis_string(:,1) = diagString(Lb);

siteCat = unique(metadata.site);
diagCat = unique(metadata.diagnosis);
for iDiag = 1:length(diagCat)
nSiteDiag(iDiag) = sum(strcmp(metadata.diagnosis, diagCat(iDiag)));
end

% the site and phenotype has >= NSUB HC subjects
nSiteDiagCondition = nSiteDiag >= NSUB;

nSiteCondition = nSiteDiagCondition(:,1) & any(nSiteDiagCondition(:,2:end),2);
siteCon = siteCat(nSiteCondition);

%%
metadata.con = zeros(size(metadata.subj_id));
for iSite = 1:length(siteCon)

    siteDiag = diagCat(nSiteDiagCondition(iSite,:)); % diag for this site
    for iDiag = 2:length(siteDiag)
        condition = ismember(metadata.site,siteCon(iSite)) & ...
            ismember(metadata.diagnosis, siteDiag([1,iDiag]));
        metadata.con = metadata.con | condition;
% qdecTable = cell2table([metadata.subj_id(condition), metadata.diagnosis(condition), ...
%      metadata.sex(condition), metadata.age(condition)], "VariableNames",["fsid", "diagnosis",...
%     "sex", "age"]);
% writetable(qdecTable,['/projects/kg98/trangc/VBM/data/', study, ...
%     '/qdec_table_', char(unique(metadata.site_string(condition))),'_',char(siteDiag(iDiag)),'.dat'],'Delimiter','tab');
% writecell(table2array(qdecTable(:,2:4)),['/projects/kg98/trangc/VBM/data/', study, ...
%      '/ANCOVA_matrix_', char(siteDiag(iDiag)), '_', char(unique(metadata.site_string(condition))),'.txt'],'Delimiter','tab')
    end
     
end
% [La Lb] = ismember(metadata.subj_id, catFile.Var1);
% metadata.CAT = cellstr(num2str(catFile.Var2(Lb)));
% medication
metadata.antipsychotic = if_med(extract(metadata.subj_id,digitsPattern), medFile, medName, 2, 5);
metadata.moodstabiliser = if_med(extract(metadata.subj_id,digitsPattern), medFile, medName, 3, 5);
metadata.antidepression = if_med(extract(metadata.subj_id,digitsPattern), medFile, medName, 4, 5);
metadata.antianxiety = if_med(extract(metadata.subj_id,digitsPattern), medFile, medName, 5, 5);
metadata.treatment = cellstr(num2str(any(logical([metadata.antipsychotic, metadata.moodstabiliser, metadata.antidepression, metadata.antianxiety]),2)));

metaTable = cell2table([metadata.subj_id(metadata.con), metadata.dataset(metadata.con), ...
    metadata.site(metadata.con), metadata.diagnosis(metadata.con), metadata.age(metadata.con),...
    metadata.sex(metadata.con), metadata.site_string(metadata.con), metadata.sex_string(metadata.con),...
    metadata.diagnosis_string(metadata.con), cellstr(num2str(ENsubHighEN(ismember(subHighEN,metadata.subj_id(metadata.con))))), cellstr(num2str(metadata.antipsychotic(metadata.con))),...
    cellstr(num2str(metadata.moodstabiliser(metadata.con))), cellstr(num2str(metadata.antidepression(metadata.con))), ...
    cellstr(num2str(metadata.antianxiety(metadata.con))), metadata.treatment(metadata.con)], "VariableNames",["subj_id", "dataset", "site", "diagnosis",...
    "age", "sex", "site_string", "sex_string",  "diagnosis_string", "EN" ,"antipsychotic", "moodstabiliser", "antidepression", "antianxiety","treatment"]);

writetable(metaTable,['/projects/kg98/trangc/VBM/data/', study, '/',study,'_qdec_extended.csv']);

%% test
% print first line and last line of metaTable and compare with original
% info - need manual check
testsub1 = metaTable(1,:)
testsub2 = metaTable(end,:)
imageFile(ismember(cellstr(imageFile.folderName),[testsub1.subj_id,testsub2.subj_id]),:)
diagFile.phenotype(ismember(cellstr(diagFile.src_subject_id),{['M',testsub1.subj_id{1}(5:end)],['M',testsub2.subj_id{1}(5:end)]}))
diagFile.src_subject_id(ismember(cellstr(diagFile.src_subject_id),{['M',testsub1.subj_id{1}(5:end)],['M',testsub2.subj_id{1}(5:end)]}))
