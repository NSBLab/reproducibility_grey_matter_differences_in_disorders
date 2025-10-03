%% read demographic information and extract subjects that satisfy criteria:
% - age: 18-60
% - each site has at least 20 subjects

% Trang Cao, Neural Systems and Behaviour Lab, Monash University, 2022.

clear all
close all

study = 'OASIS3';
NSUB = 20;


% read demographic filefile:///home/trangc/kg98/trangc/VBM/code/freesurfer/freesurfer_holmesQC/step4_qdec/combine_corr_zmap_resample.m

subject = readtable('/projects/kg98/trangc/VBM/data/OASIS3/OASIS3_demographics.csv','Delimiter',',','VariableNamingRule','preserve');
image = readtable('/projects/kg98/trangc/VBM/data/OASIS3/OASIS3_MR_json.csv','Delimiter',',','VariableNamingRule','preserve');
dayses = readtable('/projects/kg98/trangc/VBM/data/OASIS3/day_ses.txt','Delimiter',' ','VariableNamingRule','preserve');
diagfile = readtable('/projects/kg98/trangc/VBM/data/OASIS3/OASIS3_UDSd1_diagnoses.csv','Delimiter',',','VariableNamingRule','preserve');



subsplit = cellfun(@(x) strsplit(x,'_'),image.label, UniformOutput=false);
image.daytemp = cellfun(@(x) x(3), subsplit,UniformOutput=false);
image.day = cellfun(@(x) str2num(x{:}(2:end)), image.daytemp);
[lia loSub] = ismember(image.subject_id, subject.OASISID);
image.age = image.day./365 + subject.AgeatEntry(loSub);
image.sex = subject.GENDER_1_M_2_F(loSub);

[lia loSub] = ismember(image.subject_id, diagfile.OASISID);
image.diag = (diagfile.NORMCOG(loSub)==1)*1+(diagfile.alzdis(loSub)==1)*7;

daysplit = cellfun(@(x) strsplit(x,'/'),dayses.folder, UniformOutput=false);
dayses.file = cellfun(@(x) x(6), daysplit);
[lia lofile] = ismember(image.label, dayses.file);
image.ses = "ses-" + dayses.ses(lofile);

% writetable(removevars(subject,{'MRID','Date','Subject','Scanner','Scans'}),'/projects/kg98/trangc/VBM/data/miriad/temp.txt');
% subject = unique(readtable('/projects/kg98/trangc/VBM/data/miriad/temp.txt'),'rows');
image.subses="sub-"+image.subject_id+image.ses;

% useFolder = "sub-" + unique(subject.id);

% create metadata
IQRthres = 2.8;
% read cat report
catFile = readtable(['/projects/kg98/trangc/VBM/data/', study, '/cat12_qcReport_', study, '.txt']);
catFile.subses = "" + catFile.Var1 + catFile.Var3;
subHighQR = catFile.subses(catFile.Var2 <= IQRthres);
[LiSub indexHighQRinUseFolder] = ismember(subHighQR, image.subses); % index in use Folder is same as in iUnique


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

% find diagnosis for used subjects
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
    
        condition = ismember(metadata.site,siteCon(iSite)) & ...
            ismember(metadata.diagnosis ,diagCat);

        metadata.con(condition) = 1;
end

metadata.con = logical(metadata.con);

[La Lb] = ismember(metadata.subj_id(metadata.con), catFile.Var1);
metadata.CAT = cellstr(num2str(catFile.Var2(Lb)));


%%
metaTable = cell2table([metadata.subj_id(metadata.con), metadata.dataset(metadata.con), ...
    metadata.site(metadata.con), cellstr(num2str(metadata.diagnosis(metadata.con))), cellstr(num2str(metadata.age(metadata.con))),...
    metadata.sex(metadata.con), metadata.site_string(metadata.con), cellstr(metadata.sex_string(metadata.con)), cellstr(metadata.ses(metadata.con)),...
    metadata.diagnosis_string(metadata.con),metadata.CAT], "VariableNames",["subj_id", "dataset", "site", "diagnosis",...
    "age", "sex", "site_string", "sex_string", "ses", "diagnosis_string","CAT"]);

writetable(metaTable,['/projects/kg98/trangc/VBM/data/', study, '/',study,'_dems_extended.csv']);

