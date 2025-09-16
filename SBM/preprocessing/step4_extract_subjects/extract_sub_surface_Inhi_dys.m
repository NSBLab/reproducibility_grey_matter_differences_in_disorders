%% read demographic information and extract subjects that satisfy criteria:
% - age: 18-60
% - each site has at least 20 subjects

% Trang Cao, Neural Systems and Behaviour Lab, Monash University, 2022.

clear all
close all

study = 'Inhi_dys';

% define const
LOWAGE = 18*12; % lower bound of age
UPAGE = 60*12; % upper bound of age
NSUB = 20; % lowest number of subject per site per phenotype

% read demographic files
imageFile = readtable(['/projects/kg98/trangc/VBM/data/', study, '/image03.txt']);

imageFile.src_subject_id = cellstr(imageFile.src_subject_id);
imageFile.interview_age = str2double(string(imageFile.interview_age));
imageFile.scan_type = cellstr(imageFile.scan_type);
imageFile.image_file = cellstr(imageFile.image_file);
imageFile.sex = cellstr(imageFile.sex);

diagFile = readtable(['/projects/kg98/trangc/VBM/data/', study, '/ndar_subject01.txt']);

diagFile.phenotype = cellstr(diagFile.phenotype);
diagFile.src_subject_id = cellstr(diagFile.src_subject_id);

descriptionList = {'MR structural (MPRAGE)'};

imageFile.useDescription = ismember(imageFile.scan_type, descriptionList);

% image filename
pat1 = ("/G"+ wildcardPattern + ".REC");
filenameWithPattern = char(extract(imageFile.image_file(imageFile.useDescription),pat1));
imageFile.filename(imageFile.useDescription,1:size(filenameWithPattern,2)-1) = filenameWithPattern(:,2:end);

% folder name
temp = char(imageFile.src_subject_id);
imageFile.folderName = "sub-" + temp(:,2:4);

% subject in the age range 18-60 at scanning time
imageFile.adult = imageFile.interview_age >= LOWAGE & imageFile.interview_age <= UPAGE;
adult.ID = unique(imageFile.src_subject_id(imageFile.adult == 1));

% list of sites and diagnose
[diag, ~, indexDiag] = unique(diagFile.phenotype);
nDiag = size(diag,1); 
control = 'No Diagnosis';
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

useFile = cellstr(imageFile.filename(iUseFile(iUnique),:));
useFolder = cellstr(imageFile.folderName(iUseFile(iUnique),:));

% writelines(append(useFolder, useFile), ['/projects/kg98/trangc/VBM/data/', study, '/useFile.txt']);
% writelines(useFolder, ['/projects/kg98/trangc/VBM/data/', study, '/subject_use_extract.txt']);

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
% if isempty(mriqcOutlierFile)
%     subHighEN = subHighEN;
% else
% mriqcOutlier = mriqcOutlierFile.Var1;
% 
% [LinO LocO] = ismember(subHighEN, mriqcOutlier);
% subHighEN = subHighEN(LinO==0);
% end

% exclude after visualize
mark = readtable(fullfile('/projects/kg98/trangc/VBM/data', study,'sub_with_recon_output_marked.txt'));
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
metadata.site = cellstr(repmat('23',size(metadata.subj_id)));
metadata.site_string = metadata.dataset;
metadata.age = cellstr(num2str(round(imageFile.interview_age(iUseFile(iUnique(indexHighQRinUseFolder)))./12)));
metadata.sex_string = cellstr(imageFile.sex(iUseFile(iUnique(indexHighQRinUseFolder))));
metadata.sex = cellstr(num2str(strcmp(metadata.sex_string,'M')));

% find diagnosis for used subjects
diag
[La Lb] = ismember(imageFile.src_subject_id(iUseFile(iUnique(indexHighQRinUseFolder))), diagFile.src_subject_id);
metadata.diagnosis_string = cellstr(diagFile.phenotype(Lb));
[La Lb] = ismember(metadata.diagnosis_string, diag);
Lb(Lb==1) = 5;
Lb(Lb==2) = 1;
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
imageFile(ismember(cellstr(imageFile.src_subject_id),{['G',testsub1.subj_id{1}(5:end)],['G',testsub2.subj_id{1}(5:end)]}),:)
diagFile.phenotype(ismember(cellstr(diagFile.src_subject_id),{['G',testsub1.subj_id{1}(5:end)],['G',testsub2.subj_id{1}(5:end)]}))
diagFile.src_subject_id(ismember(cellstr(diagFile.src_subject_id),{['G',testsub1.subj_id{1}(5:end)],['G',testsub2.subj_id{1}(5:end)]}))

