%% read demographic information and extract subjects that satisfy criteria:
% - age: 18-60
% - each site has at least 20 subjects

% Trang Cao, Neural Systems and Behaviour Lab, Monash University, 2024.

%% make BIDS format of usable files
clear all
close all

study = 'Specificity';

% define const
LOWAGE = 18*12; % lower bound of age
UPAGE = 60*12; % upper bound of age
NSUB = 20; % lowest number of subject per site per phenotype



% Open the input file for reading
imageTable = readtable(['/projects/kg98/trangc/VBM/data/', study, '/image03.txt']);
siteTable = readtable(['/projects/kg98/trangc/VBM/data/', study, '/ndar_subject01.txt']);
hisFile = readtable(['/projects/kg98/trangc/VBM/data/', study, '/scid_cov01.txt']);
imageFile.src_subject_id = cellstr(arrayfun(@(x) num2str(sprintf('%02d',x)), imageTable.src_subject_id, 'UniformOutput', false));
imageFile.scan_type = cellstr(imageTable.scan_type);
imageFile.image_file = cellstr(imageTable.image_file);
imageFile.sex = cellstr(imageTable.sex);
imageFile.interview_age = str2double(string(imageTable.interview_age)); % remove the first line of description
imageFile.interview_date = cellstr(imageTable.interview_date); % remove the first line of description

siteFile.src_subject_id = cellstr(arrayfun(@(x) num2str(sprintf('%02d',x)), siteTable.src_subject_id, 'UniformOutput', false));
siteFile.phenotype = cellstr(siteTable.phenotype);

% image filename
pat1 = "submission"+wildcardPattern + (".nii.gz");
imageFile.filepathlong = cellstr(char(extract(imageFile.image_file,pat1)));
% Find the first '/' in the path
firstSlashIndex = cellfun(@(x) find(x == '/', 1, 'first'), imageFile.filepathlong, 'UniformOutput', false);

imageFile.filepath = cellfun(@(x,y) x((y+1)*double(~strcmp(x(y+1),'/'))+(y+2)*double(strcmp(x(y+1),'/')):end),imageFile.filepathlong,firstSlashIndex,'UniformOutput',false);%to remove the double // in the dir

% % folder name
%   % Find the last '/' in the path
%    lastSlashIndex = cellfun(@(x) find(x == '/', 1, 'last'), imageFile.filepathlong, 'UniformOutput', false);
% imageFile.folderName = cellfun(@(x,y)  regexp(x(y:end), '\d{4}','match'), imageFile.filepathlong, lastSlashIndex,'UniformOutput', false);

% subject in the age range 18-60 at scanning time
imageFile.adult = imageFile.interview_age >= LOWAGE & imageFile.interview_age <= UPAGE;
adult.ID = unique(imageFile.src_subject_id(imageFile.adult == 1 ));

% list of sites and diagnose
[diag, ~, indexDiag] = unique(siteFile.phenotype);
diagList = {'HC', 'BD', 'SCA',...
    'SCZ', 'ASD', 'MDD' };
nDiag = length(diagList);
diagIndex = {[2],[1],[],[3],[],[]};


for iDiag = 1: nDiag % control and proband in the diag list
    % adult subjects in each phenotype in each site
    condition = ismember(adult.ID,...
        siteFile.src_subject_id(ismember(siteFile.phenotype, diag(diagIndex{iDiag})))) ;

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
            siteFile.src_subject_id( ismember(siteFile.phenotype, diag(diagIndex{iDiag}))));
        adult.use(condition) = 1;
    end

end

useID = adult.ID(adult.use==1);
imageFile.useID = ismember(imageFile.src_subject_id,useID)& ismember(imageFile.scan_type,{'MR structural (T1)'});

%find unique ID
imageFile.useFile = imageFile.useID == 1 ;
[iUseFile col va] = find(imageFile.useFile);

idUse = imageFile.src_subject_id(iUseFile);
[useSub iUnique iID] = unique(idUse);

useFile = cellstr(imageFile.filepath(iUseFile(iUnique),:));
matchID = cellstr(imageFile.src_subject_id(iUseFile(iUnique),:));
useFolderName = cellfun(@(x) [char(x(1:end))],matchID, 'UniformOutput', false);

useFolder = cellfun(@(x) ['sub-',char(x)],useFolderName, 'UniformOutput', false);


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
% indexHighQRinUseFolder = indexHighQRinUseFolder(indexHighQRinUseFolder>0);
% subHighEN = useFolder(indexHighQRinUseFolder);
metadata.subj_id = cellstr(useFolder(indexHighQRinUseFolder));
% metadata.ses = catFile.Var3(catFile.Var2 <= IQRthres);
matchIDHighQR = cellstr(matchID(indexHighQRinUseFolder));
metadata.dataset = cellstr(repmat(study,size(indexHighQRinUseFolder)));
metadata.site_string = metadata.dataset;
metadata.site = cellstr(repmat('40',size(indexHighQRinUseFolder)));
metadata.age = imageFile.interview_age(iUseFile(iUnique(indexHighQRinUseFolder)))./12;
metadata.sex_string = cellstr(imageFile.sex(iUseFile(iUnique(indexHighQRinUseFolder))));
metadata.sex = cellstr(num2str(strcmp(metadata.sex_string,'M')));

% find diagnosis for used subjects
diag
[La Lb] = ismember(imageFile.src_subject_id(iUseFile(iUnique(indexHighQRinUseFolder))), siteFile.src_subject_id);
metadata.diagnosis_string = cellstr(siteFile.phenotype(Lb));
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
% metadata.con(ismember(metadata.subj_id,'sub-2467ZEJ')) = 0;% remove sub with wrong site info, see note.txt
metadata.con = logical(metadata.con);
metadata.EN = cellstr(num2str(ENsubHighEN(ismember(subHighEN,metadata.subj_id(metadata.con)))));
criteria = 'bpd_age_onset';

[metadata.ageOnset, metadata.illnessDuration] = if_onset(matchIDHighQR, hisFile, metadata.age(metadata.con),criteria);



%%
metaTable = cell2table([metadata.subj_id(metadata.con), metadata.dataset(metadata.con), ...
    metadata.site(metadata.con), metadata.diagnosis(metadata.con), cellstr(num2str(metadata.age(metadata.con))),...
    metadata.sex(metadata.con), metadata.site_string(metadata.con), metadata.sex_string(metadata.con),...
    metadata.diagnosis_string(metadata.con), metadata.EN, cellstr(num2str(metadata.ageOnset)), ...
    cellstr(num2str(metadata.illnessDuration))], "VariableNames",["subj_id", "dataset", "site", "diagnosis",...
    "age", "sex", "site_string", "sex_string",  "diagnosis_string", "EN" ,"ageOnset","illnessDuration"]);

writetable(metaTable,['/projects/kg98/trangc/VBM/data/', study, '/',study,'_qdec_extended.csv']);
%% test
% print first line and last line of metaTable and compare with original
% info - need manual check
testsub1 = metaTable(1,:)
testsub2 = metaTable(end,:)
imageTable(ismember(cellstr(imageFile.src_subject_id),{testsub1.subj_id{1}(5:end),testsub2.subj_id{1}(5:end)}),:)

siteFile.phenotype(ismember(cellstr(siteFile.src_subject_id),{[testsub1.subj_id{1}(5:end)],[testsub2.subj_id{1}(5:end)]}))
siteFile.src_subject_id(ismember(cellstr(siteFile.src_subject_id),{[testsub1.subj_id{1}(5:end)],[testsub2.subj_id{1}(5:end)]}))
