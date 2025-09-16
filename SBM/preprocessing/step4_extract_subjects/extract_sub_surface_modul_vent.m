%% read demographic information and extract subjects that satisfy criteria:
% - age: 18-60
% - each site has at least 20 subjects

% Trang Cao, Neural Systems and Behaviour Lab, Monash University, 2022.

clear all
close all

study = 'Modul_vent';

% define const
LOWAGE = 18*12; % lower bound of age
UPAGE = 60*12; % upper bound of age
NSUB = 20; % lowest number of subject per site per phenotype

% read demographic files
diagFile = readtable(['/projects/kg98/trangc/VBM/data/', study, '/ndar_subject01.txt']);
imageFile = readtable(['/projects/kg98/trangc/VBM/data/', study, '/image03.txt']);
medFile = readtable(['/projects/kg98/trangc/VBM/data/', study, '/dem/medlist01.txt']);
medName = readtable(['/projects/kg98/trangc/VBM/data/medication_name_for_code.csv']);

diagFile.phenotype = cellstr(diagFile.phenotype);
diagFile.src_subject_id = cellstr(num2str(diagFile.src_subject_id));
imageFile.src_subject_id = cellstr(num2str(imageFile.src_subject_id));
imageFile.interview_age = str2double(string(imageFile.interview_age));
imageFile.image_description = cellstr(imageFile.image_description);
imageFile.image_file = cellstr(imageFile.image_file);
imageFile.sex = cellstr(imageFile.sex);
medFile.src_subject_id = cellstr(num2str(medFile.src_subject_id));

% image filename
pat1 = "impres"+wildcardPattern+".zip";
imageFile.filename = cellstr(extract(imageFile.image_file,pat1));
% check if file in Phillips folder
pat2 = "Phillips";
imageFile.Phillips = contains(imageFile.image_file,pat2);
imageFile.filename(imageFile.Phillips) = append('Phillips/projects/RDoCdb/NIMHDA/', imageFile.filename(imageFile.Phillips));
% file of session 1 or 2
pat3 = "s1/";
imageFile.ses1 = contains(imageFile.filename,pat3);
pat4 = "s2/";
imageFile.ses2 = contains(imageFile.filename,pat4);
% folder name
imageFile.folderName = "sub-" + imageFile.src_subject_id;
% subject in the age range 18-60 at scanning time
imageFile.adult = imageFile.interview_age >= LOWAGE & imageFile.interview_age <= UPAGE;
adult.ID = unique(imageFile.src_subject_id(imageFile.adult == 1));

% % list of sites and diagnose
% [site, ~, indexSite] = unique(siteFile.site);
% [diag, ~, indexDiag] = unique(siteFile.diag);
%  nSite = size(site,1); 
%  nDiag = size(diag,1);
%  if strcmp(study, 'BSNIP')
% diagList = 1:4;
%  else
%      diagList = 3:6;
%  end
%  control = 'Healthy Control';
%  [iControl ic] = find(strcmp(diag, control));


% for iSite = 1: nSite
%     for iDiag = 1: nDiag % control and proband in the diag list
%         
%         % adult subjects in each phenotype in each site
%         condition = ismember(adult.ID,...
%             siteFile.src_subject_id(indexSite == iSite & indexDiag == iDiag));
%         
%         % number of adult subjects in each phenotype in each site
%         nSubPerPhenotypePerSite(iSite, iDiag) = sum(condition);
%         
%     end
% end
% 
% % the site and phenotype has >= NSUB HC subjects
% siteSizeCondition = nSubPerPhenotypePerSite >= NSUB;
% 
% adult.use =  zeros(size(adult.ID));
% for iSite = 1: nSite
%     
%     % extract subject from sites having >= NSUB HC subjects and >= NSUB patients
%     if siteSizeCondition(iSite, iControl) == 1 & sum(siteSizeCondition(iSite, setdiff(diagList,iControl))) >= 1
%         
%         for iDiag = diagList
%             
%             if siteSizeCondition(iSite, iDiag) == 1
%                 
%                 % adult subjects in each phenotype in each site
%                 condition = ismember(adult.ID,...
%             siteFile.src_subject_id(indexSite == iSite & indexDiag == iDiag));
%                 adult.use(condition) = 1;
%             end
%             
%         end
%         
%     end
%     
% end

% extract image filename satisfying: ID of usable subjects and
% image_description in the list

useID = adult.ID;
imageFile.useID = ismember(imageFile.src_subject_id,useID);

descriptionList = {'T1_MPRAGE_Iso'};

imageFile.useDescription = ismember(imageFile.image_description, descriptionList);


imageFile.useFile1 = imageFile.useID == 1 & imageFile.useDescription == 1 & imageFile.ses1 == 1;
imageFile.useFile2 = imageFile.useID == 1 & imageFile.useDescription == 1 & imageFile.ses2 == 1;
[iUseFile1 col va] = find(imageFile.useFile1);
[iUseFile2 col va] = find(imageFile.useFile2);


[useSub1 iUnique1 iID] = unique(imageFile.folderName(iUseFile1));
[useSub2 iUnique2 iID] = unique(imageFile.folderName(iUseFile2));

useFile1 = cellstr(imageFile.filename(iUseFile1(iUnique1),:));
useFolder1 = cellstr(imageFile.folderName(iUseFile1(iUnique1),:));

useFile2 = cellstr(imageFile.filename(iUseFile2(iUnique2),:));
useFolder2 = cellstr(imageFile.folderName(iUseFile2(iUnique2),:));

% writelines(useFile1, ['/projects/kg98/trangc/VBM/data/', study, '/useFile1.txt']);
% writelines(useSub1, ['/projects/kg98/trangc/VBM/data/', study, '/subject_use1.txt']);
% 
% writelines(useFile2, ['/projects/kg98/trangc/VBM/data/', study, '/useFile2.txt']);
% writelines(useSub2, ['/projects/kg98/trangc/VBM/data/', study, '/subject_use2.txt']);

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
% subWithOutlier = (arrayfun(@(x) holesFile.Var1{inSubLh(x)}(1:end-3), 1:length(inSubLh), 'UniformOutput', false))';
% [La indexinUseFolder] = ismember(subWithOutlier, useFolder1); % index in use Folder is same as in iUnique
% indexinUseFolder = indexinUseFolder(indexinUseFolder>0);
% subWithOutlier = useFolder1(indexinUseFolder);
% 
% 
% % read mriqc report
% mriqcOutlierFile = readtable(['/projects/kg98/trangc/VBM/data/', study, '/derivatives/MRIQC/outlier_list.txt'], 'ReadVariableNames', false);
% if isempty(mriqcOutlierFile)
%     subHighEN = subHighEN;
% else
% mriqcOutlier = mriqcOutlierFile.Var1;
% 
% [LinO LocO] = ismember(subHighEN, mriqcOutlier);
% subHighEN = subHighEN(LinO==0);
% end
% 
% % check if data exist
% sesSubFile = readtable(fullfile('/projects/kg98/trangc/VBM/data', study,'ses_sub_with_recon_output.txt'));
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

[La indexHighQRinUseFolder] = ismember(subHighEN, useFolder1); % index in use Folder is same as in iUnique
indexHighQRinUseFolder = indexHighQRinUseFolder(indexHighQRinUseFolder>0);
subHighEN = useFolder1(indexHighQRinUseFolder);
% 
% writetable(cell2table(subHighEN),['/projects/kg98/trangc/VBM/data/', study, '/sub_without_outlier.txt'],"WriteVariableNames",false);
% writetable(cell2table(subWithOutlier(ismember(subWithOutlier,subHighEN)==0)),['/projects/kg98/trangc/VBM/data/', study, '/autoQCOutlier.txt'],"WriteVariableNames",false);

indexHighQRinUseFolder = indexHighQRinUseFolder(indexHighQRinUseFolder>0);

metadata.subj_id = cellstr(useFolder1(indexHighQRinUseFolder));
% metadata.ses = catFile.Var3(catFile.Var2 <= IQRthres);
metadata.dataset = cellstr(repmat(study,size(indexHighQRinUseFolder)));
metadata.site = cellstr(repmat('18',size(indexHighQRinUseFolder)));
metadata.site_string = metadata.dataset;
metadata.age = cellstr(num2str(round(imageFile.interview_age(iUseFile1(iUnique1(indexHighQRinUseFolder)))./12)));
metadata.sex_string = cellstr(imageFile.sex(iUseFile1(iUnique1(indexHighQRinUseFolder))));
metadata.sex = cellstr(num2str(strcmp(metadata.sex_string,'M')));


% find diagnosis for used subjects
[La Lb] = ismember(imageFile.src_subject_id(iUseFile1(iUnique1(indexHighQRinUseFolder))), diagFile.src_subject_id);
metadata.diagnosis_string = cellstr(diagFile.phenotype(Lb));
[La Lb] = ismember(metadata.diagnosis_string, unique(metadata.diagnosis_string));
Lb(Lb==2) = 4;
Lb(Lb==1) = 2;
Lb(Lb==4) = 1;
metadata.diagnosis = cellstr(num2str(Lb));

diagString = {'HC', 'BD', 'SCA',...
    'SCZ', 'ASD', 'MDD' };
metadata.diagnosis_string(:,1) = diagString(Lb);

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
% qdecTable = cell2table([metadata.subj_id(condition), metadata.diagnosis(condition), ...
%      metadata.sex(condition), metadata.age(condition)], "VariableNames",["fsid", "diagnosis",...
%     "sex", "age"]);
% writetable(qdecTable,['/projects/kg98/trangc/VBM/data/', study, ...
%     '/qdec_table_', char(unique(metadata.site_string(condition))),'_',char(siteDiag(iDiag)),'.dat'],'Delimiter','tab');
% 
%     writecell(table2array(qdecTable(:,2:4)),['/projects/kg98/trangc/VBM/data/', study, ...
%      '/ANCOVA_matrix_', char(siteDiag(iDiag)), '_', char(unique(metadata.site_string(condition))),'.txt'],'Delimiter','tab')
end
     
end
% [La Lb] = ismember(metadata.subj_id, catFile.Var1);
% metadata.CAT = cellstr(num2str(catFile.Var2(Lb)));
% 
% medication
metadata.antipsychotic = if_med(extract(metadata.subj_id,digitsPattern), medFile, medName, 2, 5);
metadata.moodstabiliser = if_med(extract(metadata.subj_id,digitsPattern), medFile, medName, 3, 5);
metadata.antidepression = if_med(extract(metadata.subj_id,digitsPattern), medFile, medName, 4, 5);
metadata.antianxiety = if_med(extract(metadata.subj_id,digitsPattern), medFile, medName, 5, 5);
metadata.treatment = cellstr(num2str(any(logical([metadata.antipsychotic, metadata.moodstabiliser, metadata.antidepression, metadata.antianxiety]),2)));
% 
metaTable = cell2table([metadata.subj_id(metadata.con), metadata.dataset(metadata.con), ...
    metadata.site(metadata.con), metadata.diagnosis(metadata.con), (metadata.age(metadata.con)),...
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
imageFile(ismember(cellstr(imageFile.src_subject_id),{testsub1.subj_id{1}(5:end),testsub2.subj_id{1}(5:end)}),:)

diagFile.phenotype(ismember(cellstr(diagFile.src_subject_id),{[testsub1.subj_id{1}(5:end)],[testsub2.subj_id{1}(5:end)]}))
diagFile.src_subject_id(ismember(cellstr(diagFile.src_subject_id),{[testsub1.subj_id{1}(5:end)],[testsub2.subj_id{1}(5:end)]}))

