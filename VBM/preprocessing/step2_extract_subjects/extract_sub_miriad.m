%% read demographic information and extract subjects that satisfy criteria:
% - age: 18-60
% - each site has at least 20 subjects

% Trang Cao, Neural Systems and Behaviour Lab, Monash University, 2022.

clear all
close all

study = 'miriad';
NSUB = 20;


% read demographic filefile:///home/trangc/kg98/trangc/VBM/code/freesurfer/freesurfer_holmesQC/step4_qdec/combine_corr_zmap_resample.m

subject = readtable('/projects/kg98/trangc/VBM/data/miriad/miriad.csv','Delimiter',',');

subsplit = cellfun(@(x) strsplit(x,'_'),subject.MRID, UniformOutput=false);
subject.id = cellfun(@(x) x(2), subsplit,UniformOutput=false);
subject.ses = "ses-" + cellfun(@(x) x(3), subsplit, UniformOutput=false);
writetable(removevars(subject,{'MRID','Date','Subject','Scanner','Scans'}),'/projects/kg98/trangc/VBM/data/miriad/temp.txt');
subject = unique(readtable('/projects/kg98/trangc/VBM/data/miriad/temp.txt'),'rows');
subject.subses="sub-"+subject.id+subject.ses;

% useFolder = "sub-" + unique(subject.id);

% create metadata
IQRthres = 2.8;
% read cat report
catFile = readtable(['/projects/kg98/trangc/VBM/data/', study, '/cat12_qcReport_', study, '.txt']);
catFile.subses = "" + catFile.Var1 + catFile.Var3;
subHighQR = catFile.subses(catFile.Var2 <= IQRthres);
[LiSub indexHighQRinUseFolder] = ismember(subHighQR, subject.subses); % index in use Folder is same as in iUnique


metadata.subj_id = cellstr("sub-"+subject.id(indexHighQRinUseFolder));
metadata.dataset = cellstr(repmat(study,size(indexHighQRinUseFolder)));
metadata.site_string = metadata.dataset;
metadata.site = cellstr(repmat('1',size(indexHighQRinUseFolder)));
metadata.ses = subject.ses(indexHighQRinUseFolder);
metadata.age = subject.Age(indexHighQRinUseFolder);
metadata.sex_string = cellstr(subject.M_F(indexHighQRinUseFolder));
metadata.sex = cellstr(num2str(strcmp(metadata.sex_string,'M')));


% find diagnosis for used subjects
metadata.diagnosis_string = subject.Group(indexHighQRinUseFolder);
[La Lb] = ismember(metadata.diagnosis_string, 'Control');
metadata.diagnosis_string(La) = cellstr('HC');
La = double(La);
La(La==0)=7;
metadata.diagnosis = cellstr(num2str(La));


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

metadata.con = logical(metadata.con);

[La Lb] = ismember(metadata.subj_id(metadata.con), catFile.Var1);
metadata.CAT = cellstr(num2str(catFile.Var2(Lb)));


%%
metaTable = cell2table([metadata.subj_id(metadata.con), metadata.dataset(metadata.con), ...
    metadata.site(metadata.con), metadata.diagnosis(metadata.con), cellstr(num2str(metadata.age(metadata.con))),...
    metadata.sex(metadata.con), metadata.site_string(metadata.con), metadata.sex_string(metadata.con), metadata.ses(metadata.con),...
    metadata.diagnosis_string(metadata.con),metadata.CAT], "VariableNames",["subj_id", "dataset", "site", "diagnosis",...
    "age", "sex", "site_string", "sex_string", "ses", "diagnosis_string","CAT"]);

writetable(metaTable,['/projects/kg98/trangc/VBM/data/', study, '/',study,'_dems_extended.csv']);

% writematrix(subject.participant_id(subject.use == 1,:), '/projects/kg98/trangc/VBM/data/SRPBS/subject_use.txt');