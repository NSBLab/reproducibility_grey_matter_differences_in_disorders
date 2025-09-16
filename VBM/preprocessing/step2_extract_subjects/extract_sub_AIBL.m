%% read demographic information and extract subjects that satisfy criteria:
% - age: 18-60
% - each site has at least 20 subjects

% Trang Cao, Neural Systems and Behaviour Lab, Monash University, 2022.

clear all
close all

study = 'AIBL';
NSUB = 20;


% read demographic filefile:///home/trangc/kg98/trangc/VBM/code/freesurfer/freesurfer_holmesQC/step4_qdec/combine_corr_zmap_resample.m

subject = readtable('/projects/kg98/trangc/VBM/data/AIBL/aibl.csv','Delimiter',',');
image = readtable('/projects/kg98/trangc/VBM/data/AIBL/scanner_model.txt','Delimiter','tab');
diagfile = readtable('/projects/kg98/trangc/VBM/data/AIBL/aibl_pdxconv.csv','Delimiter',',');
sessub = readtable('/projects/kg98/trangc/VBM/data/AIBL/ses_subject_use.txt','ReadVariableNames',false);
diag = unique(diagfile.DXCURREN);

image.sessub = append(image.sub_ID,image.ses);
sessub.sub=cellfun(@(x) x(1:8), sessub.Var1,'UniformOutput', false);
 sessub.subNumber = cellfun(@(x) str2num(x(:,5:8)), sessub.sub);
sessub.ses=cellfun(@(x) x(9:13), sessub.Var1,'UniformOutput', false);
% subsplit = cellfun(@(x) strsplit(x,'_'),image.label, UniformOutput=false);
% image.daytemp = cellfun(@(x) x(3), subsplit,UniformOutput=false);
% image.day = cellfun(@(x) str2num(x{:}(2:end)), image.daytemp);
[lia loSub] = ismember(sessub.subNumber, subject.SubjectID);
sessub.age = subject.Age(loSub);
sessub.sex = subject.Sex(loSub);

[lia loSub] = ismember(sessub.subNumber, diagfile.RID);
sessub.diag = diagfile.DXCURREN(loSub);
sessub.siteFile = diagfile.SITEID(loSub);

[lia loSub] = ismember(sessub.Var1, image.sessub);
sessub.scanner = image.scannerID(loSub);
% daysplit = cellfun(@(x) strsplit(x,'/'),dayses.folder, UniformOutput=false);
% dayses.file = cellfun(@(x) x(6), daysplit);
% [lia lofile] = ismember(image.label, dayses.file);
% image.ses = "ses-" + dayses.ses(lofile);

% writetable(removevars(subject,{'MRID','Date','Subject','Scanner','Scans'}),'/projects/kg98/trangc/VBM/data/miriad/temp.txt');
% subject = unique(readtable('/projects/kg98/trangc/VBM/data/miriad/temp.txt'),'rows');
% image.subses="sub-"+image.subject_id+image.ses;

% useFolder = "sub-" + unique(subject.id);

% create metadata
IQRthres = 2.8;
% read cat report
catFile = readtable(['/projects/kg98/trangc/VBM/data/', study, '/cat12_qcReport_', study, '.txt']);
catFile.subses = "" + catFile.Var1 + catFile.Var3;
subHighQR = catFile.subses(catFile.Var2 <= IQRthres);
[LiSub indexHighQRinUseFolder] = ismember(subHighQR, sessub.Var1); % index in use Folder is same as in iUnique


metadata.scanner = cellstr((sessub.scanner(indexHighQRinUseFolder)));
[La Lb] = ismember(metadata.scanner,unique(metadata.scanner));
metadata.site = cellstr(num2str(Lb+4));
metadata.site_string = cellstr("AIBL-"+num2str(Lb));
metadata.subj_id = cellstr(sessub.sub(indexHighQRinUseFolder));
metadata.ses = sessub.ses(indexHighQRinUseFolder);
metadata.age = sessub.age(indexHighQRinUseFolder);
metadata.dataset = cellstr(repmat(study,size(indexHighQRinUseFolder)));

metadata.sex_string = sessub.sex(indexHighQRinUseFolder);

metadata.sex(strcmp(metadata.sex_string,'M'),:) =  '1';
metadata.sex(strcmp(metadata.sex_string,'F'),:) =  '0';
metadata.diag = cellstr(num2str(sessub.diag(indexHighQRinUseFolder)));

% find diagnosis for used subjects
[La Lb] = ismember(metadata.diag, {' 1'});
metadata.diagnosis(La==1,1) = 1;
metadata.diagnosis_string(La==1,1) = cellstr('HC');
[La Lb] = ismember(metadata.diag, {' 3'});
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
   cellstr(metadata.sex(metadata.con)), metadata.site_string(metadata.con), metadata.sex_string(metadata.con), metadata.ses(metadata.con),...
    metadata.diagnosis_string(metadata.con),metadata.CAT], "VariableNames",["subj_id", "dataset", "site", "diagnosis",...
    "age", "sex", "site_string", "sex_string", "ses", "diagnosis_string", "CAT"]);

writetable(metaTable,['/projects/kg98/trangc/VBM/data/', study, '/',study,'_dems_extended.csv']);

