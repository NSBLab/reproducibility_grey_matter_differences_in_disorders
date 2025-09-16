%% read demographic information and extract subjects that satisfy criteria:
% - age: 18-60
% - each site has at least 20 subjects

% Trang Cao, Neural Systems and Behaviour Lab, Monash University, 2024.

%% make BIDS format of usable files
clear all
close all

study = 'Brain45';

% define const
LOWAGE = 18*12; % lower bound of age
UPAGE = 60*12; % upper bound of age
NSUB = 20; % lowest number of subject per site per phenotype

% Define the input and output file paths
outputFile = '/home/trangc/kg98/trangc/VBM/data/Brain45/extracted_paths.txt';

% Open the input file for reading
imageTable = readtable(['/projects/kg98/trangc/VBM/data/', study, '/image03.txt']);
siteTable = readtable(['/projects/kg98/trangc/VBM/data/', study, '/ndar_subject01.txt']);

imageFile.src_subject_id = cellstr(num2str(imageTable.src_subject_id(2:end,:)));
imageFile.scan_type = cellstr(imageTable.scan_type(2:end,:));
imageFile.image_file = cellstr(imageTable.image_file(2:end,:));
imageFile.sex = cellstr(imageTable.sex(2:end,:));
imageFile.interview_age = str2double(string(imageTable.interview_age(2:end,:))); % remove the first line of description
imageFile.interview_date = cellstr(imageTable.interview_date(2:end,:)); % remove the first line of description

siteFile.src_subject_id = cellstr(num2str(siteTable.src_subject_id));
siteFile.phenotype_description = cellstr(siteTable.phenotype_description);

% image filename
pat1 = "submission"+wildcardPattern+".nii";
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
[diag, ~, indexDiag] = unique(siteFile.phenotype_description);

nDiag = size(diag,1);

% diagList = [1,5];



for iDiag = 1: nDiag % control and proband in the diag list
    % adult subjects in each phenotype in each site
    condition = ismember(adult.ID,...
        siteFile.src_subject_id(indexDiag == iDiag)) ;

    % number of adult subjects in each phenotype in each site
    nSubPerPhenotypePerSite( iDiag) = sum(condition);

end


% the site and phenotype has >= NSUB HC subjects
siteSizeCondition = nSubPerPhenotypePerSite >= NSUB;

adult.use =  zeros(size(adult.ID));

for iDiag = 1:nDiag

    if siteSizeCondition(iDiag) == 1

        % adult subjects in each phenotype in each site
        condition = ismember(adult.ID,...
            siteFile.src_subject_id( indexDiag == iDiag));
        adult.use(condition) = 1;
    end

end

useID = adult.ID(adult.use==1);
imageFile.useID = ismember(imageFile.src_subject_id,useID)& strcmp(imageFile.scan_type,'MR structural (MPRAGE)');

%find unique ID
imageFile.useFile = imageFile.useID == 1 ;
[iUseFile col va] = find(imageFile.useFile);

idUse = imageFile.src_subject_id(iUseFile);
[useSub iUnique iID] = unique(idUse);

useFile = cellstr(imageFile.filepath(iUseFile(iUnique),:));
matchID = cellstr(imageFile.src_subject_id(iUseFile(iUnique),:));

useFolder = cellfun(@(x) ['sub-',char(x)],matchID, 'UniformOutput', false);
% only write one time at the begining and then comment
% writelines(useFolder, ['/projects/kg98/trangc/VBM/data/', study, '/subject_use.txt']);


%% create metadata to run VBM after proprocessing and cat report

IQRthres = 2.8; % threshold to determine good quality images

% read cat report
catFile = readtable(['/projects/kg98/trangc/VBM/data/', study, '/cat12_qcReport_', study, '.txt']);
subHighQR = catFile.Var1(catFile.Var2 <= IQRthres);
[La indexHighQRinUseFolder] = ismember(subHighQR, useFolder); % index in use Folder is same as in iUnique

metadata.subj_id = cellstr(useFolder(indexHighQRinUseFolder));
metadata.ses = catFile.Var3(catFile.Var2 <= IQRthres);
matchIDHighQR = cellstr(matchID(indexHighQRinUseFolder));
metadata.dataset = cellstr(repmat(study,size(indexHighQRinUseFolder)));
metadata.site_string = metadata.dataset;
metadata.site = cellstr(repmat('39',size(indexHighQRinUseFolder)));
metadata.age = imageFile.interview_age(iUseFile(iUnique(indexHighQRinUseFolder)))./12;
metadata.sex_string = cellstr(imageFile.sex(iUseFile(iUnique(indexHighQRinUseFolder))));
metadata.sex = cellstr(num2str(strcmp(metadata.sex_string,'M')));

% find diagnosis for used subjects
[La Lb] = ismember(imageFile.src_subject_id(iUseFile(iUnique(indexHighQRinUseFolder))), siteFile.src_subject_id);
metadata.diagnosis_string = cellstr(siteFile.phenotype_description(Lb));
[La Lb] = ismember(metadata.diagnosis_string, diag);
control = 'TD';
[iControl ic] = find(strcmp(diag, control));
metadata.diagnosis = Lb;
metadata.diagnosis(Lb~=iControl) = 5;
metadata.diagnosis(Lb==iControl) = 1;
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
    
        condition = ismember(metadata.site,siteCon(iSite)) & ...
            ismember(metadata.diagnosis, diagCat(nSiteDiagCondition(iSite,:)));

        metadata.con(condition) = 1;
end
% metadata.con(ismember(metadata.subj_id,'sub-2467ZEJ')) = 0;% remove sub with wrong site info, see note.txt
metadata.con = logical(metadata.con);
[La Lb] = ismember(metadata.subj_id(metadata.con), catFile.Var1);
metadata.CAT = cellstr(num2str(catFile.Var2(Lb)));

%%
metaTable = cell2table([metadata.subj_id(metadata.con), metadata.dataset(metadata.con), ...
    metadata.site(metadata.con), metadata.diagnosis(metadata.con), cellstr(num2str(metadata.age(metadata.con))),...
    metadata.sex(metadata.con), metadata.site_string(metadata.con), metadata.sex_string(metadata.con),metadata.ses,...
    metadata.diagnosis_string(metadata.con)], "VariableNames",["subj_id", "dataset", "site", "diagnosis",...
    "age", "sex", "site_string", "sex_string", "ses", "diagnosis_string" ]);

writetable(metaTable,['/projects/kg98/trangc/VBM/data/', study, '/',study,'_dems.csv']);

metaTable = cell2table([metadata.subj_id(metadata.con), metadata.dataset(metadata.con), ...
    metadata.site(metadata.con), metadata.diagnosis(metadata.con), cellstr(num2str(metadata.age(metadata.con))),...
    metadata.sex(metadata.con), metadata.site_string(metadata.con), metadata.sex_string(metadata.con),metadata.ses,...
    metadata.diagnosis_string(metadata.con), metadata.CAT], "VariableNames",["subj_id", "dataset", "site", "diagnosis",...
    "age", "sex", "site_string", "sex_string", "ses", "diagnosis_string", "CAT" ]);

writetable(metaTable,['/projects/kg98/trangc/VBM/data/', study, '/',study,'_dems_extended.csv']);
