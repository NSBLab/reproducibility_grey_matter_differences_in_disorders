%% read demographic information and extract subjects that satisfy criteria:
% - age: 18-60
% - each site has at least 20 subjects

% Trang Cao, Neural Systems and Behaviour Lab, Monash University, 2022.

clear all
close all

study = 'OASIS3';
NSUB = 20;


% read demographic filefile:///home/trangc/kg98/trangc/VBM/code/freesurfer/freesurfer_holmesQC/step4_qdec/combine_corr_zmap_resample.m

subject = readtable('/projects/kg98/trangc/VBM/data/OASIS3/OASIS3_demographics.csv','Delimiter',',');
image = readtable('/projects/kg98/trangc/VBM/data/OASIS3/OASIS3_MR_json.csv','Delimiter',',');
dayses = readtable('/projects/kg98/trangc/VBM/data/OASIS3/day_ses.txt','Delimiter',' ');
diagfile = readtable('/projects/kg98/trangc/VBM/data/OASIS3/OASIS_diag.csv','Delimiter',',');
diag = unique(diagfile.dx1);

subsplit = cellfun(@(x) strsplit(x,'_'),image.label, UniformOutput=false);
image.daytemp = cellfun(@(x) x(3), subsplit,UniformOutput=false);
image.day = cellfun(@(x) str2num(x{:}(2:end)), image.daytemp);
[lia loSub] = ismember(image.subject_id, subject.OASISID);
image.age = image.day./365 + subject.AgeatEntry(loSub);
image.sex = subject.GENDER_1_M_2_F(loSub);

[lia loSub] = ismember(image.subject_id, diagfile.Subject);
image.diag = diagfile.dx1(loSub);

daysplit = cellfun(@(x) strsplit(x,'/'),dayses.folder, UniformOutput=false);
dayses.file = cellfun(@(x) x(6), daysplit);
[lia lofile] = ismember(image.label, dayses.file);
image.ses = "ses-" + dayses.ses(lofile);

% writetable(removevars(subject,{'MRID','Date','Subject','Scanner','Scans'}),'/projects/kg98/trangc/VBM/data/miriad/temp.txt');
% subject = unique(readtable('/projects/kg98/trangc/VBM/data/miriad/temp.txt'),'rows');
image.subses="sub-"+image.subject_id+image.ses;
image.sub="sub-"+image.subject_id;
% useFolder = "sub-" + unique(subject.id);

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

[La indexHighQRinUseFolder] = ismember(subHighEN, image.sub); % index in use Folder is same as in iUnique
% indexHighQRinUseFolder = indexHighQRinUseFolder(indexHighQRinUseFolder>0);
subHighEN = image.sub(indexHighQRinUseFolder);



metadata.scan = cellstr(num2str(image.DeviceSerialNumber(indexHighQRinUseFolder)));
[La Lb] = ismember(metadata.scan,unique(metadata.scan));
metadata.site = cellstr(num2str(Lb+1));
metadata.site_string = cellstr("OASIS3-"+num2str(Lb));
metadata.subj_id = cellstr("sub-"+image.subject_id(indexHighQRinUseFolder));
metadata.ses = image.ses(indexHighQRinUseFolder);
metadata.age = image.age(indexHighQRinUseFolder);
metadata.dataset = cellstr(repmat(study,size(indexHighQRinUseFolder)));

metadata.sex = cellstr(num2str((image.sex(indexHighQRinUseFolder)==1)));

metadata.sex_string(strcmp(metadata.sex,'1'),:) =  'M';
metadata.sex_string(strcmp(metadata.sex,'0'),:) =  'F';
metadata.diag = cellstr(image.diag(indexHighQRinUseFolder));
metadata.diagnosis = zeros(size(metadata.diag));
metadata.diagnosis_string = cellstr(repmat('N',size(metadata.diag)));
% find diagnosis for used subjects
unique(metadata.diag)
[La Lb] = ismember(metadata.diag, {'Cognitively normal' ,'No dementia'});
metadata.diagnosis(La==1,1) = 1;
metadata.diagnosis_string(La==1,1) = cellstr('HC');
[La Lb] = ismember(metadata.diag, {'AD Dementia','AD dem Language dysf after',...
    'AD dem Language dysf with','AD dem distrubed social- after',...
    'AD dem distrubed social- prior','AD dem distrubed social- with',...
    'AD dem w/CVD contribut','AD dem w/CVD not contrib','AD dem w/depresss- contribut',...
    'AD dem w/depresss- not contribut','AD dem w/oth (list B) contribut','AD dem w/oth (list B) not contrib','DAT'});
metadata.diagnosis(La==1,1) = 7;
metadata.diagnosis_string(La==1,1) = cellstr('AD');

%% check number of subjects
siteCat = unique(metadata.site);
diagCat = [1,7];

for iSite = 1: length(siteCat)
    for iDiag = 1: length(diagCat) % control and proband in the diag list

        % number of adult subjects in each phenotype in each site
        nSiteDiag(iSite, iDiag) = sum(strcmp(metadata.site, siteCat(iSite)) & metadata.diagnosis==diagCat(iDiag));

    end
end

% the site and phenotype has >= NSUB HC subjects
nSiteDiagCondition = nSiteDiag >= NSUB;
nSiteCondition = nSiteDiagCondition(:,1) & any(nSiteDiagCondition(:,2:end),2);
siteCon = siteCat(nSiteCondition);

%%
metadata.con = zeros(size(metadata.subj_id));
for iSite = 1:length(siteCon)

    % siteDiag = diagCat(nSiteDiagCondition(iSite,:)); % diag for this site
    for iDiag = 2:length(diagCat)
        condition = ismember(metadata.site,siteCon(iSite)) & ...
            ismember(metadata.diagnosis, diagCat);
        metadata.con = metadata.con | condition;
        qdecTable = cell2table([metadata.subj_id(condition), cellstr(num2str(metadata.diagnosis(condition))), ...
            metadata.sex(condition), cellstr(num2str(metadata.age(condition)))], "VariableNames",["fsid", "diagnosis",...
            "sex", "age"]);
        writetable(qdecTable,['/projects/kg98/trangc/VBM/data/', study, ...
            '/qdec_table_', char(unique(metadata.site_string(condition))),'_',num2str(diagCat(iDiag)),'.dat'],'Delimiter','tab');
    end
end
metaTable = cell2table([metadata.subj_id(metadata.con), metadata.dataset(metadata.con), ...
    metadata.site(metadata.con), cellstr(num2str(metadata.diagnosis(metadata.con))), cellstr(num2str(metadata.age(metadata.con))),...
    metadata.sex(metadata.con), metadata.site_string(metadata.con), cellstr(metadata.sex_string(metadata.con)),...
    metadata.diagnosis_string(metadata.con), cellstr(num2str(ENsubHighEN(ismember(subHighEN,metadata.subj_id(metadata.con)))))], "VariableNames",["subj_id", "dataset", "site", "diagnosis",...
    "age", "sex", "site_string", "sex_string",  "diagnosis_string", "EN" ]);

writetable(metaTable,['/projects/kg98/trangc/VBM/data/', study, '/',study,'_qdec_extended.csv']);
%% test
% print first line and last line of metaTable and compare with original
% info - need manual check
testsub1 = metaTable(1,:)
testsub2 = metaTable(end,:)
image(ismember(cellstr(image.subject_id),{testsub1.subj_id{1}(5:end),testsub2.subj_id{1}(5:end)}),:)
subject(ismember(cellstr(subject.OASISID),{testsub1.subj_id{1}(5:end),testsub2.subj_id{1}(5:end)}),:)

