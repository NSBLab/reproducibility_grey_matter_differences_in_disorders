%% read demographic information and extract subjects that satisfy criteria:
% - age: 18-60
% - each site has at least 20 subjects

% Trang Cao, Neural Systems and Behaviour Lab, Monash University, 2024.

%% make BIDS format of usable files
clear all
close all

study = 'Determinant';

% define const
LOWAGE = 18*12; % lower bound of age
UPAGE = 60*12; % upper bound of age
NSUB = 20; % lowest number of subject per site per phenotype



% Open the input file for reading
imageTable = readtable(['/projects/kg98/trangc/VBM/data/', study, '/image03.txt']);
siteTable = readtable(['/projects/kg98/trangc/VBM/data/', study, '/ndar_subject01.txt']);

imageTable.src_subject_id = cellstr(num2str(imageTable.src_subject_id));
imageTable.scan_type = cellstr(imageTable.scan_type);
imageTable.image_file = cellstr(imageTable.image_file);
imageTable.sex = cellstr(imageTable.sex);
imageTable.interview_age = str2double(string(imageTable.interview_age)); % remove the first line of description
imageTable.interview_date = cellstr(imageTable.interview_date); % remove the first line of description
medFile = readtable(['/projects/kg98/trangc/VBM/data/', study, '/psychsoc01.txt']);
medName = readtable(['/projects/kg98/trangc/VBM/data/medication_name_for_code.csv']);

siteFile.src_subject_id = cellstr(num2str(siteTable.src_subject_id));
siteFile.phenotype_description = cellstr(siteTable.phenotype_description);

% image filename
pat1 = "submission"+wildcardPattern+".nii.gz";
imageTable.filepathlong = cellstr(char(extract(imageTable.image_file,pat1)));
% Find the first '/' in the path
firstSlashIndex = cellfun(@(x) find(x == '/', 1, 'first'), imageTable.filepathlong, 'UniformOutput', false);

imageTable.filepath = cellfun(@(x,y) x((y+1)*double(~strcmp(x(y+1),'/'))+(y+2)*double(strcmp(x(y+1),'/')):end),imageTable.filepathlong,firstSlashIndex,'UniformOutput',false);%to remove the double // in the dir

% % folder name
%   % Find the last '/' in the path
%    lastSlashIndex = cellfun(@(x) find(x == '/', 1, 'last'), imageTable.filepathlong, 'UniformOutput', false);
% imageTable.folderName = cellfun(@(x,y)  regexp(x(y:end), '\d{4}','match'), imageTable.filepathlong, lastSlashIndex,'UniformOutput', false);

% subject in the age range 18-60 at scanning time
imageTable.adult = imageTable.interview_age >= LOWAGE & imageTable.interview_age <= UPAGE;
adult.ID = unique(imageTable.src_subject_id(imageTable.adult == 1 ));

% list of sites and diagnose
[diag, ~, indexDiag] = unique(siteFile.phenotype_description);

diagList = {'HC', 'BD', 'SCA',...
    'SCZ', 'ASD', 'MDD' };
nDiag = length(diagList);
diagIndex = {[17,18,19,21,22,25,35,36],[2:16],[28:30],[31:33,37],[],[23,24]};


for iDiag = 1: nDiag % control and proband in the diag list
    % adult subjects in each phenotype in each site
    condition = ismember(adult.ID,...
        siteFile.src_subject_id(ismember(siteFile.phenotype_description, diag(diagIndex{iDiag})))) ;

    % number of adult subjects in each phenotype in each site
    nSubPerPhenotypePerSite(iDiag) = sum(condition);
end

% the site and phenotype has >= NSUB HC subjects
siteSizeCondition = nSubPerPhenotypePerSite >= NSUB;

adult.use =  zeros(size(adult.ID));
for iDiag = 1:nDiag

    if siteSizeCondition(iDiag) == 1

        % adult subjects in each phenotype in each site
        condition = ismember(adult.ID,...
            siteFile.src_subject_id( ismember(siteFile.phenotype_description, diag(diagIndex{iDiag}))));
        adult.use(condition) = 1;
    end

end

useID = adult.ID(adult.use==1);
imageTable.useID = ismember(imageTable.src_subject_id,useID)& strcmp(imageTable.scan_type,'MR structural (MPRAGE)');

%find unique ID
imageTable.useFile = imageTable.useID == 1 ;
[iUseFile col va] = find(imageTable.useFile);

idUse = imageTable.src_subject_id(iUseFile);
[useSub iUnique iID] = unique(idUse);

useFile = cellstr(imageTable.filepath(iUseFile(iUnique),:));
matchID = cellstr(imageTable.src_subject_id(iUseFile(iUnique),:));

useFolder = cellfun(@(x) ['sub-',char(x)],matchID, 'UniformOutput', false);




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

% skip MRIQC
subHighEN = subHighEN;
% exclude after visualize
mark = readtable(fullfile('/projects/kg98/trangc/VBM/data', study,'sub_with_recon_output_marked.txt'),'ReadVariableNames', false);
[lia locb] = ismember(subHighEN, mark.Var1);
if size(mark,2) == 2
    subHighEN(strcmp(mark.Var2(locb),'x')) = [];
end

[La indexHighQRinUseFolder] = ismember(subHighEN, useFolder); % index in use Folder is same as in iUnique
% indexHighQRinUseFolder = indexHighQRinUseFolder(indexHighQRinUseFolder>0);
% subHighEN = useFolder(indexHighQRinUseFolder);

metadata.subj_id = cellstr(useFolder(indexHighQRinUseFolder));
% metadata.ses = catFile.Var3(catFile.Var2 <= IQRthres);
matchIDHighQR = cellstr(matchID(indexHighQRinUseFolder));
metadata.dataset = cellstr(repmat(study,size(indexHighQRinUseFolder)));
metadata.site_string = metadata.dataset;
metadata.site = cellstr(repmat('38',size(indexHighQRinUseFolder)));
metadata.age = imageTable.interview_age(iUseFile(iUnique(indexHighQRinUseFolder)))./12;
metadata.sex_string = cellstr(imageTable.sex(iUseFile(iUnique(indexHighQRinUseFolder))));
metadata.sex = cellstr(num2str(strcmp(metadata.sex_string,'M')));

% find diagnosis for used subjects
diag
[La Lb] = ismember(imageTable.src_subject_id(iUseFile(iUnique(indexHighQRinUseFolder))), siteFile.src_subject_id);
metadata.diagnosis_string = cellstr(siteFile.phenotype_description(Lb));
metadata.diagnosis = zeros(size(metadata.diagnosis_string));
for iDiag = 1:nDiag
    [La Lb] = ismember(metadata.diagnosis_string,  diag(diagIndex{iDiag}));

    metadata.diagnosis(Lb~=0)  = iDiag;
end

metadata.diagnosis_string(:,1) = diagList(metadata.diagnosis);
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

metadata.antipsychotic = if_med(matchIDHighQR, medFile, medName, 2, 18,study);  %maxNoMed=18
 metadata.moodstabiliser = if_med(matchIDHighQR, medFile, medName, 3, 18,study);
metadata.antidepression = if_med(matchIDHighQR, medFile, medName, 4, 18,study);
metadata.antianxiety = if_med(matchIDHighQR, medFile, medName, 5, 18,study);
metadata.treatment = cellstr(num2str(any(logical([metadata.antipsychotic, metadata.moodstabiliser, metadata.antidepression, metadata.antianxiety]),2)));

metadata.con = logical(metadata.con);
metadata.EN = cellstr(num2str(ENsubHighEN(ismember(subHighEN,metadata.subj_id(metadata.con)))));

%%
metaTable = cell2table([metadata.subj_id(metadata.con), metadata.dataset(metadata.con), ...
    metadata.site(metadata.con), metadata.diagnosis(metadata.con), cellstr(num2str(metadata.age(metadata.con))),...
    metadata.sex(metadata.con), metadata.site_string(metadata.con), metadata.sex_string(metadata.con),...
    metadata.diagnosis_string(metadata.con), metadata.EN,  cellstr(num2str(metadata.antipsychotic(metadata.con))),...
    cellstr(num2str(metadata.moodstabiliser(metadata.con))), cellstr(num2str(metadata.antidepression(metadata.con))), ...
    cellstr(num2str(metadata.antianxiety(metadata.con))), metadata.treatment(metadata.con)], "VariableNames",["subj_id", "dataset", "site", "diagnosis",...
    "age", "sex", "site_string", "sex_string",  "diagnosis_string", "EN" ,"antipsychotic", "moodstabiliser", "antidepression", "antianxiety","treatment"]);

writetable(metaTable,['/projects/kg98/trangc/VBM/data/', study, '/',study,'_qdec_extended.csv']);
%% test
% print first line and last line of metaTable and compare with original
% info - need manual check
testsub1 = metaTable(1,:)
testsub2 = metaTable(end,:)
imageTable(ismember(cellstr(imageTable.src_subject_id),{testsub1.subj_id{1}(5:end),testsub2.subj_id{1}(5:end)}),:)
siteFile.phenotype_description(ismember(cellstr(siteFile.src_subject_id),{[testsub1.subj_id{1}(5:end)],[testsub2.subj_id{1}(5:end)]}))
siteFile.src_subject_id(ismember(cellstr(siteFile.src_subject_id),{[testsub1.subj_id{1}(5:end)],[testsub2.subj_id{1}(5:end)]}))
