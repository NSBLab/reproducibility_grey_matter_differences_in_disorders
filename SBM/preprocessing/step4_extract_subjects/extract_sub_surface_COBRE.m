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
% subWithOutlier = (arrayfun(@(x) holesFile.Var1{inSubLh(x)}(1:end-3), 1:length(inSubLh), 'UniformOutput', false))';
% [La indexinUseFolder] = ismember(subWithOutlier, useFolder); % index in use Folder is same as in iUnique
% indexinUseFolder = indexinUseFolder(indexinUseFolder>0);
% subWithOutlier = useFolder(indexinUseFolder);
%
% % read mriqc report
% mriqcOutlierFile = readtable(['/projects/kg98/trangc/VBM/data/', study, '/derivatives/MRIQC/outlier_list.txt'], 'ReadVariableNames', false);
% mriqcOutlier = mriqcOutlierFile.Var1;
%
% [LinO LocO] = ismember(subHighEN, mriqcOutlier);
% subHighEN = subHighEN(LinO==0);

% exclude after visualize
mark = readtable(fullfile('/projects/kg98/trangc/VBM/data', study,'sub_with_recon_output_marked.txt'),'ReadVariableNames', false);
[lia locb] = ismember(subHighEN, mark.Var1);
if size(mark,2) == 2
    subHighEN(strcmp(mark.Var2(locb),'x')) = [];
end

[La indexHighQRinUseFolder] = ismember(subHighEN, useFolder); % index in use Folder is same as in iUnique
% indexHighQRinUseFolder = indexHighQRinUseFolder(indexHighQRinUseFolder>0);
subHighEN = useFolder(indexHighQRinUseFolder);


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

metaTable = cell2table([metadata.subj_id(metadata.con), metadata.dataset(metadata.con), ...
    metadata.site(metadata.con), metadata.diagnosis(metadata.con), (metadata.age(metadata.con)),...
    metadata.sex(metadata.con), metadata.site_string(metadata.con), metadata.sex_string(metadata.con),...
    metadata.diagnosis_string(metadata.con), cellstr(num2str(ENsubHighEN(ismember(subHighEN,metadata.subj_id(metadata.con)))))], "VariableNames",["subj_id", "dataset", "site", "diagnosis",...
    "age", "sex", "site_string", "sex_string",  "diagnosis_string", "EN" ]);

writetable(metaTable,['/projects/kg98/trangc/VBM/data/', study, '/',study,'_qdec_extended.csv']);

%% test
% print first line and last line of metaTable and compare with original
% info - need manual check
testsub1 = metaTable(1,:)
testsub2 = metaTable(end,:)
subject(ismember(cellstr(subject.ID),{testsub1.subj_id{1}(5:end),testsub2.subj_id{1}(5:end)}),:)
subject.SubjectType(ismember(cellstr(subject.ID),{testsub1.subj_id{1}(5:end),testsub2.subj_id{1}(5:end)}),:)