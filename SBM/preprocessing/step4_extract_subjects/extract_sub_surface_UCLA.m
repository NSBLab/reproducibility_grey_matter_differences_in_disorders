%% read demographic information and extract subjects that satisfy criteria:
% - age: 18-60
% - each site has at least 20 subjects

% Trang Cao, Neural Systems and Behaviour Lab, Monash University, 2022.

clear all
close all

study = 'UCLA';

% define const
LOWAGE = 18; % lower bound of age
UPAGE = 60; % upper bound of age
NSUB = 20; % lowest number of subject per site per phenotype

% read demographic file
subject = readtable(['/projects/kg98/trangc/VBM/data/',study,'/CNP_master_remove_rings.csv']);
medFile = readtable(['/projects/kg98/trangc/VBM/data/', study, '/dem/medication.tsv'], "FileType","text",'Delimiter', '\t');
medName = readtable(['/projects/kg98/trangc/VBM/data/medication_name_for_code.csv']);
% list of diagnosis
phenotype = unique(subject.diagnosis);

% filter subject in the age range 18-60 and have exist files
subject.adult = subject.age >= LOWAGE & subject.age <= UPAGE;
adult.ID = unique(subject.subj_id(subject.adult == 1));

[site, ~, indexSite] = unique(subject.site);
[diag, ~, indexDiag] = unique(subject.diagnosis);
iControl = 1;
nSite = size(site,1);
nDiag = size(diag,1);
for iSite = 1: nSite
    for iDiag = 1: nDiag % control and proband in the diag list

        condition = ismember(adult.ID,...
            subject.subj_id(subject.site == site(iSite) & subject.diagnosis == phenotype(iDiag)));
        nSubPerPhenotypePerSite(iSite,iDiag) = sum(condition);

    end
end
% the site and phenotype has >= NSUB HC subjects
siteSizeCondition = nSubPerPhenotypePerSite >= NSUB;

adult.use =  zeros(size(adult.ID));
for iSite = 1: nSite

    % extract subject from sites having >= NSUB HC subjects and >= NSUB patients
    if siteSizeCondition(iSite, iControl) == 1 & sum(siteSizeCondition(iSite, setdiff(1:nDiag,iControl))) >= 1

        for iDiag = 1:nDiag

            if siteSizeCondition(iSite, iDiag) == 1

                % adult subjects in each phenotype in each site
                condition = ismember(adult.ID,...
                    subject.subj_id(subject.site == site(iSite) & subject.diagnosis == phenotype(iDiag)));
                adult.use(condition) = 1;
            end

        end

    end

end
[La iUseFile] = ismember(adult.ID(adult.use==1), subject.subj_id);
useFolder = cellstr(adult.ID(adult.use==1));

writelines(useFolder, ['/projects/kg98/trangc/VBM/data/', study, '/subject_use.txt']);


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
metadata.dataset = cellstr(repmat(study,size(indexHighQRinUseFolder)));
metadata.site = subject.site(iUseFile(indexHighQRinUseFolder));
siteString = {'UCLA1'; 'UCLA2'};
metadata.site_string = siteString(metadata.site);
metadata.site = cellstr(num2str(metadata.site+29));

metadata.age = cellstr(num2str(round(subject.age(iUseFile(indexHighQRinUseFolder)))));
metadata.sex = cellstr(num2str(subject.sex(iUseFile(indexHighQRinUseFolder))==1));
metadata.sex_string(strcmp(metadata.sex,'1'),1) = {'M'};
metadata.sex_string(strcmp(metadata.sex,'0'),1) = {'F'};

% find diagnosis for used subjects
metadata.diagnosis = subject.diagnosis(iUseFile(indexHighQRinUseFolder));
metadata.diagnosis(metadata.diagnosis == 5) = 4;
metadata.diagnosis(metadata.diagnosis == 6) = 2;
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

    siteDiag = diagCat(nSiteDiagCondition(iSite,:)); % diag for this site
    for iDiag = 2:length(siteDiag)
        condition = ismember(metadata.site,siteCon(iSite)) & ...
            ismember(metadata.diagnosis, siteDiag([1,iDiag]));
        metadata.con = metadata.con | condition;
qdecTable = cell2table([metadata.subj_id(condition), metadata.diagnosis(condition), ...
     metadata.sex(condition), metadata.age(condition)], "VariableNames",["fsid", "diagnosis",...
    "sex", "age"]);
writetable(qdecTable,['/projects/kg98/trangc/VBM/data/', study, ...
    '/qdec_table_', char(unique(metadata.site_string(condition))),'_',char(siteDiag(iDiag)),'.dat'],'Delimiter','tab');
end
     
end
%% meditcation
matchIDHighQRcon = metadata.subj_id(metadata.con);

metadata.antipsychotic = if_med(matchIDHighQRcon, medFile, medName, 2, 18,study);  %maxNoMed=18
metadata.moodstabiliser = if_med(matchIDHighQRcon, medFile, medName, 3, 18,study);
metadata.antidepression = if_med(matchIDHighQRcon, medFile, medName, 4, 18,study);
metadata.antianxiety = if_med(matchIDHighQRcon, medFile, medName, 5, 18,study);
metadata.treatment = cellstr(num2str(any(logical([metadata.antipsychotic, metadata.moodstabiliser, metadata.antidepression, metadata.antianxiety]),2)));

metaTable = cell2table([metadata.subj_id(metadata.con), metadata.dataset(metadata.con), ...
    metadata.site(metadata.con), metadata.diagnosis(metadata.con), (metadata.age(metadata.con)),...
    metadata.sex(metadata.con), metadata.site_string(metadata.con), metadata.sex_string(metadata.con),...
    metadata.diagnosis_string(metadata.con), cellstr(num2str(ENsubHighEN(ismember(subHighEN,metadata.subj_id(metadata.con))))), cellstr(num2str(metadata.antipsychotic)),...
    cellstr(num2str(metadata.moodstabiliser)), cellstr(num2str(metadata.antidepression)), ...
    cellstr(num2str(metadata.antianxiety)), metadata.treatment], "VariableNames",["subj_id", "dataset", "site", "diagnosis",...
    "age", "sex", "site_string", "sex_string",  "diagnosis_string", "EN" ,"antipsychotic", "moodstabiliser", "antidepression", "antianxiety","treatment"]);

writetable(metaTable,['/projects/kg98/trangc/VBM/data/', study, '/',study,'_qdec_extended.csv']);
%% test
% print first line and last line of metaTable and compare with original
% info - need manual check
testsub1 = metaTable(1,:)
testsub2 = metaTable(end,:)
subject(ismember(cellstr(subject.subj_id),[testsub1.subj_id,testsub2.subj_id]),:)

