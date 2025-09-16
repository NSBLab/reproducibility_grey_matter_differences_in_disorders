%% read demographic information and extract subjects that satisfy criteria:
% - age: 18-60
% - each site has at least 20 subjects

% Trang Cao, Neural Systems and Behaviour Lab, Monash University, 2024.

%% make BIDS format of usable files
clear all
close all

study = 'Transdiagnostic';

% define const
LOWAGE = 18*12; % lower bound of age
UPAGE = 60*12; % upper bound of age
NSUB = 20; % lowest number of subject per site per phenotype



% Open the input file for reading
imageFile = readtable(['/projects/kg98/trangc/VBM/data/', study, '/demos.csv'], "FileType","text",'Delimiter', ',');
% Assuming the column is named 'subjectkey' and contains entries like 'NDAR_INVYT858CBN'
raw_ids = string(imageFile.subjectkey);  % Convert to string array for easier manipulation

% Remove underscores and add 'sub-' prefix
imageFile.participant_id = 'sub-' + replace(raw_ids, '_', '');
% subject in the age range 18-60 at scanning time
imageFile.adult = imageFile.interview_age >= LOWAGE & imageFile.interview_age <= UPAGE;
adult.ID = unique(imageFile.participant_id(imageFile.adult == 1));

% list of sites and diagnose
[site, ~, indexSite] = unique(imageFile.Site);
[diag, ~, indexDiag] = unique(imageFile.Primary_Dx);
diagList = 1:2;
nSite = size(site,1);
nDiag = 2;
control = '999';
BPindexList = [3:6];
[iControl ic] = find(strcmp(diag, control));
diagIndex = {[1],[3:6],[22],[19:20],[],[9:10]};
for iSite = 1: nSite
    for iDiag = 1: nDiag % control and proband in the diag list

        % adult subjects in each phenotype in each site
        % adult subjects in each phenotype in each site
        condition = ismember(adult.ID,...
            imageFile.participant_id(indexSite == iSite & ismember(indexDiag, 1)));

        % number of adult subjects in each phenotype in each site
        nSubPerPhenotypePerSite(iSite, 1) = sum(condition);

        % adult subjects in each phenotype in each site
        condition = ismember(adult.ID,...
            imageFile.participant_id(indexSite == iSite & ismember(indexDiag, BPindexList)));

        % number of adult subjects in each phenotype in each site
        nSubPerPhenotypePerSite(iSite, 2) = sum(condition);
    end
end

% the site and phenotype has >= NSUB HC subjects
siteSizeCondition = nSubPerPhenotypePerSite >= NSUB;

adult.use =  zeros(size(adult.ID));
for iSite = 1: nSite

    % extract subject from sites having >= NSUB HC subjects and >= NSUB patients
    if siteSizeCondition(iSite, iControl) == 1 & sum(siteSizeCondition(iSite, setdiff(diagList,iControl))) >= 1

        iDiag = 1;

        if siteSizeCondition(iSite, iDiag) == 1

            % adult subjects in each phenotype in each site
            condition = ismember(adult.ID,...
                imageFile.participant_id(indexSite == iSite & indexDiag == iDiag));
            adult.use(condition) = 1;
        end

        iDiag = 2;
        if siteSizeCondition(iSite, iDiag) == 1

            % adult subjects in each phenotype in each site
            condition = ismember(adult.ID,...
                imageFile.participant_id(indexSite == iSite & ismember(indexDiag, BPindexList)));
            adult.use(condition) = 1;
        end

        % site infor
        imageFile.Site(ismember(imageFile.participant_id, imageFile.participant_id(indexSite == iSite))) = iSite;


    end

end

useID = adult.ID(adult.use==1);
imageFile.useID = ismember(imageFile.participant_id,useID);
imageFile.useFile = imageFile.useID == 1 ;
[iUseFile col va] = find(imageFile.useFile);

idUse = imageFile.participant_id(iUseFile);
[useSub iUnique iID] = unique(idUse);


useFolder = cellstr(imageFile.participant_id(iUseFile(iUnique),:));


%% create metadata to run VBM after proprocessing and cat report


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
metadata.subj_id = cellstr(useFolder(indexHighQRinUseFolder));
metadata.dataset = cellstr(repmat(study,size(indexHighQRinUseFolder)));

metadata.site = cellstr(num2str(imageFile.Site(iUseFile(iUnique(indexHighQRinUseFolder)))+41));
metadata.site_string = strcat(metadata.dataset,cellstr(num2str(imageFile.Site(iUseFile(iUnique(indexHighQRinUseFolder))))));
metadata.age = imageFile.interview_age(iUseFile(iUnique(indexHighQRinUseFolder)))./12;
metadata.sex_string = cellstr(imageFile.sex(iUseFile(iUnique(indexHighQRinUseFolder))));
metadata.sex = cellstr(num2str(strcmp(metadata.sex_string,'M')));

metadata.diagnosis_string = cellstr(imageFile.Primary_Dx(iUseFile(iUnique(indexHighQRinUseFolder))));
metadata.diagnosis = zeros(size(metadata.diagnosis_string));
diag
for iDiag = 1:nDiag
    [La Lb] = ismember(metadata.diagnosis_string,  diag(diagIndex{iDiag}));

    metadata.diagnosis(Lb~=0)  = iDiag;
end
% [La Lb] = ismember(metadata.diagnosis_string, diag);
%
% metadata.diagnosis = Lb;
% metadata.diagnosis(Lb==1) = 1;
% metadata.diagnosis(Lb~=1) = 2;
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

    for iDiag = 2: length(siteDiag) % control and proband in the diag list


        condition = ismember(metadata.site,siteCon(iSite)) & ...
            ismember(metadata.diagnosis, siteDiag([1,iDiag]));

        metadata.con(condition) = 1;

        qdecTable = cell2table([metadata.subj_id(condition), metadata.diagnosis(condition), ...
            metadata.sex(condition), cellstr(num2str(metadata.age(condition)))], "VariableNames",["fsid", "diagnosis",...
            "sex", "age"]);
        writetable(qdecTable,['/projects/kg98/trangc/VBM/data/', study, ...
            '/qdec_table_', char(unique(metadata.site_string(condition))),'_',char(siteDiag(iDiag)),'.dat'],'Delimiter','tab');

    end
end
% metadata.con(ismember(metadata.subj_id,'sub-2467ZEJ')) = 0;% remove sub with wrong site info, see note.txt
metadata.con = logical(metadata.con);
metadata.EN = cellstr(num2str(ENsubHighEN(ismember(subHighEN,metadata.subj_id(metadata.con)))));




%%
metaTable = cell2table([metadata.subj_id(metadata.con), metadata.dataset(metadata.con), ...
    metadata.site(metadata.con), metadata.diagnosis(metadata.con), cellstr(num2str(metadata.age(metadata.con))),...
    metadata.sex(metadata.con), metadata.site_string(metadata.con), metadata.sex_string(metadata.con),...
    metadata.diagnosis_string(metadata.con), metadata.EN], "VariableNames",["subj_id", "dataset", "site", "diagnosis",...
    "age", "sex", "site_string", "sex_string",  "diagnosis_string", "EN" ]);

writetable(metaTable,['/projects/kg98/trangc/VBM/data/', study, '/',study,'_qdec_extended.csv']);
%% test
% print first line and last line of metaTable and compare with original
% info - need manual check
testsub1 = metaTable(1,:)
testsub2 = metaTable(end,:)
imageFile(ismember(cellstr(imageFile.participant_id),[testsub1.subj_id,testsub2.subj_id]),:)
