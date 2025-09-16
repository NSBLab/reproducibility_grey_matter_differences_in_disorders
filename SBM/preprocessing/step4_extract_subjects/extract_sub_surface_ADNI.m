%% read demographic information and extract subjects that satisfy criteria:
% - age: 18-60
% - each site has at least 20 subjects

% Trang Cao, Neural Systems and Behaviour Lab, Monash University, 2022.

clear all
close all

study = 'ADNI';

% define const
LOWAGE = 18*12; % lower bound of age
UPAGE = 60*12; % upper bound of age
NSUB = 20; % lowest number of subject per site per phenotype

% read demographic files
imageFile = tdfread(['/projects/kg98/trangc/VBM/data/', study, '/image03.txt']);


imageFile.interview_age = str2double(string(imageFile.interview_age(2:end,:)));
[imageFile.interview_age iTimeOrder] = sort(imageFile.interview_age);
imageFile.scan_type = cellstr(imageFile.scan_type(2:end,:));
imageFile.scan_type = imageFile.scan_type(iTimeOrder,:);
imageFile.image_file = cellstr(imageFile.image_file(2:end,:));
imageFile.image_file = imageFile.image_file(iTimeOrder,:);
imageFile.src_subject_id = cellstr(imageFile.src_subject_id(2:end,:));
imageFile.src_subject_id = imageFile.src_subject_id(iTimeOrder,:);
imageFile.sex = cellstr(imageFile.sex(2:end,:));
imageFile.sex = imageFile.sex(iTimeOrder,:);

diagFile = tdfread(['/projects/kg98/trangc/VBM/data/', study, '/ndar_subject01.txt']);

diagFile.phenotype = cellstr(diagFile.phenotype(2:end,:));
diagFile.src_subject_id = cellstr(diagFile.src_subject_id(2:end,:));

descriptionList = {'MR structural (T1)', 'MR structural (MPRAGE)'};

imageFile.useDescription = ismember(imageFile.scan_type, descriptionList) ;

% image filename
% pat1 = ("AD"+ wildcardPattern + ".nhdr")|("submission"+ wildcardPattern + "NDA"+ wildcardPattern + ".zip")|("SAG"+ wildcardPattern + ".nii.gz")|("MP"+ wildcardPattern + ".nii.gz")|("_MP"+ wildcardPattern + ".nii.gz")|("_SAG"+ wildcardPattern + ".nii.gz");
pat1 = "submission"+ wildcardPattern + (".nhdr"|".zip"|".nii.gz");
filenameWithPattern = cellstr(extract(imageFile.image_file(imageFile.useDescription),pat1));
filename = char(extract(filenameWithPattern,"/"+ wildcardPattern+ (".nhdr"|".zip"|".nii.gz")));
fileSes = contains(cellstr(filename),'working');
imageFile.fileSes = logical(zeros(size(imageFile.useDescription)));
imageFile.fileSes(imageFile.useDescription) = fileSes;
imageFile.filename(imageFile.fileSes,1:size(filename,2)-1) = filename(fileSes,2:end);

% imageFile.useDescription = imageFile.useDescription & imageFile.fileSes; %remove this to get all the subject suitable but use this to get the nii.gz files from ealiest scans.
% folder name
imageFile.folderName = "sub-" + imageFile.src_subject_id;
% subject in the age range 18-60 at scanning time
imageFile.adult = imageFile.interview_age >= LOWAGE & imageFile.interview_age <= UPAGE;
adult.ID = unique(imageFile.src_subject_id(imageFile.adult == 1));

% list of sites and diagnose
[diag, ~, indexDiag] = unique(diagFile.phenotype);
nDiag = size(diag,1); 
control = 'typically developing control';
 [iControl ic] = find(strcmp(diag, control));


for iDiag = 1: nDiag % control and proband in the diag list
    
% adult patients
condition = ismember(adult.ID, diagFile.src_subject_id(indexDiag == iDiag));
% number of adult patients
nSubPerPhenotypePerSite(iDiag) = sum(condition);

end




% the site and phenotype has >= NSUB HC subjects
siteSizeCondition = nSubPerPhenotypePerSite >= NSUB;

adult.use =  zeros(size(adult.ID));
for iDiag = 1:length(diag)
            
            if siteSizeCondition(iDiag) == 1
                
                % adult subjects in each phenotype in each site
                condition = ismember(adult.ID,...
            diagFile.src_subject_id(indexDiag == iDiag));
                adult.use(condition) = 1;
            end
            
        end

% extract image filename satisfying: ID of usable subjects and
% scan_type in the list

useID = adult.ID(adult.use==1);
imageFile.useID = ismember(imageFile.src_subject_id,useID);




imageFile.useFile = imageFile.useID == 1 & imageFile.useDescription == 1;
[iUseFile col va] = find(imageFile.useFile);

idUse = imageFile.src_subject_id(iUseFile);
[useSub iUnique iID] = unique(idUse);

useFile(:,1) = cellstr(imageFile.filename(iUseFile(iUnique),:));
useFolder = cellstr(imageFile.folderName(iUseFile(iUnique),:));

% writelines(append(useFolder, useFile), ['/projects/kg98/trangc/VBM/data/', study, '/useFile.txt']);
% writelines(useFolder, ['/projects/kg98/trangc/VBM/data/', study, '/subject_use_extract.txt']);

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

subHighEN = arrayfun(@(x) holesFile.Var1{inSubLh(x)}(1:end-3), find(eulerNumber > (meanEN-3.29*SD_EN)), 'UniformOutput', false);
subWithOutlier = (arrayfun(@(x) holesFile.Var1{inSubLh(x)}(1:end-3), 1:length(inSubLh), 'UniformOutput', false))';
[La indexinUseFolder] = ismember(subWithOutlier, useFolder); % index in use Folder is same as in iUnique
indexinUseFolder = indexinUseFolder(indexinUseFolder>0);
subWithOutlier = useFolder(indexinUseFolder);

% read mriqc report
mriqcOutlierFile = readtable(['/projects/kg98/trangc/VBM/data/', study, '/derivatives/MRIQC/outlier_list.txt'], 'ReadVariableNames', false);
mriqcOutlier = mriqcOutlierFile.Var1;

[LinO LocO] = ismember(subHighEN, mriqcOutlier);
subWithoutOutlier = subHighEN(LinO==0);

% exclude after visualize
mark = readtable(fullfile('/projects/kg98/trangc/VBM/data', study,'sub_without_outlier_marked.txt'));
[lia locb] = ismember(subWithoutOutlier, mark.Var2);
if size(mark,2) == 3
    subWithoutOutlier(strcmp(mark.Var3(locb),'x')) = [];
end

[La indexHighQRinUseFolder] = ismember(subWithoutOutlier, useFolder); % index in use Folder is same as in iUnique
indexHighQRinUseFolder = indexHighQRinUseFolder(indexHighQRinUseFolder>0);
subWithoutOutlier = useFolder(indexHighQRinUseFolder);

% writetable(cell2table(subWithoutOutlier),['/projects/kg98/trangc/VBM/data/', study, '/sub_without_outlier.txt'],"WriteVariableNames",false);
% writetable(cell2table(subWithOutlier(ismember(subWithOutlier,subWithoutOutlier)==0)),['/projects/kg98/trangc/VBM/data/', study, '/autoQCOutlier.txt'],"WriteVariableNames",false);

metadata.subj_id = cellstr(useFolder(indexHighQRinUseFolder));
metadata.dataset = cellstr(repmat(study,size(indexHighQRinUseFolder)));
metadata.site = cellstr(repmat('22',size(indexHighQRinUseFolder)));
metadata.site_string = metadata.dataset;
metadata.age = cellstr(num2str(round(imageFile.interview_age(iUseFile(iUnique(indexHighQRinUseFolder)))./12)));
metadata.sex_string = cellstr(imageFile.sex(iUseFile(iUnique(indexHighQRinUseFolder))));
metadata.sex = cellstr(num2str(strcmp(metadata.sex_string,'M')));

% find diagnosis for used subjects
[La Lb] = ismember(imageFile.src_subject_id(iUseFile(iUnique(indexHighQRinUseFolder))), diagFile.src_subject_id);
metadata.diagnosis_string = cellstr(diagFile.phenotype(Lb));
metadata.diagnosis = double(strcmp(metadata.diagnosis_string, 'typically developing control'));
metadata.diagnosis(metadata.diagnosis==0) = 5;

diagString = {'HC', 'BD', 'SCA',...
    'SCZ', 'ASD', 'MDD' };
metadata.diagnosis_string(:,1) = diagString(metadata.diagnosis);
metadata.diagnosis = cellstr(num2str(metadata.diagnosis));

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
qdecTable = cell2table([metadata.subj_id(condition), metadata.diagnosis(condition), ...
     metadata.sex(condition), metadata.age(condition)], "VariableNames",["fsid", "diagnosis",...
    "sex", "age"]);
writetable(qdecTable,['/projects/kg98/trangc/VBM/data/', study, ...
    '/qdec_table_', char(unique(metadata.site_string(condition))),'_',char(siteDiag(iDiag)),'.dat'],'Delimiter','tab');
 writecell(table2array(qdecTable(:,2:4)),['/projects/kg98/trangc/VBM/data/', study, ...
     '/ANCOVA_matrix_', char(siteDiag(iDiag)), '_', char(unique(metadata.site_string(condition))),'.txt'],'Delimiter','tab')

    end
     
end
%%
% metaTable = cell2table([metadata.subj_id(metadata.con), metadata.dataset(metadata.con), ...
%     metadata.site(metadata.con), metadata.diagnosis(metadata.con), metadata.age(metadata.con),...
%     metadata.sex(metadata.con), metadata.site_string(metadata.con), metadata.sex_string(metadata.con),...
%     metadata.diagnosis_string(metadata.con), metadata.CAT], "VariableNames",["subj_id", "dataset", "site", "diagnosis",...
%     "age", "sex", "site_string", "sex_string",  "diagnosis_string", "CAT" ]);
% 
% writetable(metaTable,['/projects/kg98/trangc/VBM/data/', study, '/',study,'_dems_extended.csv']);



