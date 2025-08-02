%% read demographic information and extract subjects that satisfy criteria:
% - age: 18-60
% - each site has at least 20 subjects

% Trang Cao, Neural Systems and Behaviour Lab, Monash University, 2022.

clear all
close all

study = 'MCIC';

% define const
LOWAGE = 18; % lower bound of age
UPAGE = 60; % upper bound of age
NSUB = 20; % lowest number of subject per site per phenotype

% read demographic file
subject = readtable('/projects/kg98/trangc/VBM/data/MCIC/5720_MCIC_Clinical_Data_20220224.csv');

% filter subject in the age range 18-60
subject.adult = subject.Age >= LOWAGE & subject.Age <= UPAGE;

% list of sites
site = unique(subject.Site);
phenotype = unique(subject.SubjectType);
subject.use = zeros(size(subject.adult));
for iSite = 1: length(site)
    for iPheno = 1: length(phenotype)
        % adult subjects in each phenotype in each site
        condition = strcmp(cellstr(subject.Site), site(iSite)) & strcmp(subject.SubjectType, phenotype(iPheno)) & (subject.adult == 1);

        % number of adult subjects in each phenotype in each site
        nSubPerPhenotypePerSite(iSite, iPheno) = sum(condition);

    end
end

% the site and phenotype has >= NSUB HC subjects
siteSizeCondition = nSubPerPhenotypePerSite >= NSUB;


for iSite = 1: length(site)

    % extract subject from sites having >= 20 NSUB subjects and >= NSUB patients
    if siteSizeCondition(iSite, 1) == 1 & sum(siteSizeCondition(iSite, 2:length(phenotype))) >= 1

        for iPheno = 1: length(phenotype)

            if siteSizeCondition(iSite, iPheno) == 1

                % adult subjects in each phenotype in each site
                condition = strcmp(cellstr(subject.Site), site(iSite,:)) & strcmp(subject.SubjectType, phenotype(iPheno)) & (subject.adult == 1);
                subject.use(condition) = 1;
            end

        end

    end

end

[iUseFile col va] = find(subject.use == 1);
useFolder = "sub-" + cellstr(subject.AnonymizedID(subject.use == 1));

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
%
% % read mriqc report
% mriqcOutlinerFile = readtable(['/projects/kg98/trangc/VBM/data/', study, '/derivatives/MRIQC/outlier_list.txt'], 'ReadVariableNames', false);
% mriqcOutlier = arrayfun(@(x) mriqcOutlinerFile.Var1{x}(1:end-10), 1:length(mriqcOutlinerFile.Var1), 'UniformOutput', false);
%
% [LinO LocO] = ismember(subHighEN, mriqcOutlier);
% subHighEN = subHighEN(LinO==0);

% % check if data exist
% sesSubFile = readtable(fullfile('/projects/kg98/trangc/VBM/data', study,'ses_sub_with_recon_output_marked.txt'));
% subFile = arrayfun(@(x) sesSubFile.Var1{x}(1:end-5),1:length(sesSubFile.Var1),'UniformOutput',false);
%  sesFile = arrayfun(@(x) sesSubFile.Var1{x}(end-4:end),1:length(sesSubFile.Var1),'UniformOutput',false);
%   [linS LocS] = ismember(subHighEN, subFile);
% for iSub = 1:length(subHighEN)
%     checkFile(iSub) = isfile(fullfile('/projects/kg98/trangc/VBM/data', study, ...
%         'derivatives','freesurfer', char(subHighEN(iSub)), 'surf','lh.thickness.fwhm10.fsaverage.mgh'));
% end
% subHighEN = subHighEN(checkFile);

% exclude after visualize
mark = readtable(fullfile('/projects/kg98/trangc/VBM/data', study,'sub_with_recon_output_marked.txt'),'ReadVariableNames', false);
[lia locb] = ismember(subHighEN, mark.Var1);
if size(mark,2) == 2
    subHighEN(strcmp(mark.Var2(locb),'x')) = [];
end

[La indexHighQRinUseFolder] = ismember(subHighEN, useFolder); % index in use Folder is same as in iUnique
indexHighQRinUseFolder = indexHighQRinUseFolder(indexHighQRinUseFolder>0);
subHighEN = useFolder(indexHighQRinUseFolder);


indexHighQRinUseFolder = indexHighQRinUseFolder(indexHighQRinUseFolder>0);

metadata.subj_id = cellstr(useFolder(indexHighQRinUseFolder));
metadata.dataset = cellstr(repmat(study,size(indexHighQRinUseFolder)));
metadata.site_string = cellstr(subject.Site(iUseFile(indexHighQRinUseFolder),:));
[La Lb] = ismember(metadata.site_string,unique(metadata.site_string()));
metadata.site = cellstr(num2str(Lb+23));
% metadata.ses = catFile.Var3(catFile.Var2 <= IQRthres);

metadata.age = subject.Age(iUseFile(indexHighQRinUseFolder));
metadata.sex_string = cellstr(subject.Sex(iUseFile(indexHighQRinUseFolder)));
metadata.sex = cellstr(num2str(strcmp(metadata.sex_string,'M')));


% find diagnosis for used subjects

metadata.diagnosis_string = subject.SubjectType(iUseFile(indexHighQRinUseFolder));
unique(metadata.diagnosis_string)
[La Lb] = ismember(metadata.diagnosis_string, unique(metadata.diagnosis_string));
Lb(Lb == 2) = 4;
diagString = {'HC', 'BD', 'SCA',...
    'SCZ', 'ASD', 'MDD' };
metadata.diagnosis_string(:,1) = diagString(Lb);
metadata.diagnosis = cellstr(num2str(Lb));

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
            metadata.sex(condition), cellstr(num2str(metadata.age(condition)))], "VariableNames",["fsid", "diagnosis",...
            "sex", "age"]);
        writetable(qdecTable,['/projects/kg98/trangc/VBM/data/', study, ...
            '/qdec_table_', char(unique(metadata.site_string(condition))),'_',char(siteDiag(iDiag)),'.dat'],'Delimiter','tab');
    end

end
criteria = 'IllnessDuration';
[La indexIDinMed] = ismember(extract(metadata.subj_id(metadata.con),digitsPattern), extract(subject.AnonymizedID,digitsPattern)); % index in medFile
columnNames = subject.Properties.VariableNames;
onsetIn = find(matches(columnNames, criteria)==1);
metadata.illnessDuration(:,1) = subject{indexIDinMed,onsetIn};

metadata.ageOnset = metadata.age(metadata.con) - metadata.illnessDuration;


metaTable = cell2table([metadata.subj_id(metadata.con), metadata.dataset(metadata.con), ...
    metadata.site(metadata.con), metadata.diagnosis(metadata.con), cellstr(num2str(metadata.age(metadata.con))),...
    metadata.sex(metadata.con), metadata.site_string(metadata.con), metadata.sex_string(metadata.con),...
    metadata.diagnosis_string(metadata.con), cellstr(num2str(ENsubHighEN(ismember(subHighEN,metadata.subj_id(metadata.con))))),...
    cellstr(num2str(metadata.ageOnset(metadata.con))), ...
    cellstr(num2str(metadata.illnessDuration(metadata.con)))], "VariableNames",["subj_id", "dataset", "site", "diagnosis",...
    "age", "sex", "site_string", "sex_string",  "diagnosis_string", "EN" ,"ageOnset","illnessDuration"]);

writetable(metaTable,['/projects/kg98/trangc/VBM/data/', study, '/',study,'_qdec_extended.csv']);
%% test
% print first line and last line of metaTable and compare with original
% info - need manual check
testsub1 = metaTable(1,:)
testsub2 = metaTable(end,:)
subject(ismember(cellstr(subject.AnonymizedID),{testsub1.subj_id{1}(5:end),testsub2.subj_id{1}(5:end)}),:)
