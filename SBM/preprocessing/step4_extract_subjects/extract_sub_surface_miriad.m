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
subject.subj_id = cellstr("sub-"+subject.id);

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
% [La indexinUseFolder] = ismember(subWithOutlier, subject.subj_id); % index in use Folder is same as in iUnique
% indexinUseFolder = indexinUseFolder(indexinUseFolder>0);
% subWithOutlier = subject.subj_id(indexinUseFolder);
% 
% % % read mriqc report
% % mriqcOutlierFile = readtable(['/projects/kg98/trangc/VBM/data/', study, '/derivatives/MRIQC/outlier_list.txt'], 'ReadVariableNames', false);
% % mriqcOutlier = mriqcOutlierFile.Var1;
% % 
% % [LinO LocO] = ismember(subHighEN, mriqcOutlier);
% subHighEN = subHighEN;

% exclude after visualize
mark = readtable(fullfile('/projects/kg98/trangc/VBM/data', study,'sub_with_recon_output_marked.txt'));
[lia locb] = ismember(subHighEN, mark.Var1);
if size(mark,2) == 2
    subHighEN(strcmp(mark.Var2(locb),'x')) = [];
end

[La indexHighQRinUseFolder] = ismember(subHighEN, subject.subj_id); % index in use Folder is same as in iUnique
% indexHighQRinUseFolder = indexHighQRinUseFolder(indexHighQRinUseFolder>0);
subHighEN = subject.subj_id(indexHighQRinUseFolder);


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
     siteDiag = diagCat(nSiteDiagCondition(iSite,:)); % diag for this site
    for iDiag = 2:length(siteDiag)
   
        condition = ismember(metadata.site,siteCon(iSite)) & ...
            ismember(metadata.diagnosis, siteDiag([1,iDiag]));
metadata.con = metadata.con | condition;
        qdecTable = cell2table([metadata.subj_id(condition), metadata.diagnosis(condition), ...
     metadata.sex(condition), cellstr(num2str(metadata.age(condition)))], "VariableNames",["fsid", "diagnosis",...
    "sex", "age"]);
writetable(qdecTable,['/projects/kg98/trangc/VBM/data/', study, ...
    '/qdec_table_', char(unique(metadata.site_string(condition))),'_',char(siteDiag(iDiag)),'.dat'],'Delimiter','tab');
    end
end
metaTable = cell2table([metadata.subj_id(metadata.con), metadata.dataset(metadata.con), ...
    metadata.site(metadata.con), metadata.diagnosis(metadata.con), cellstr(num2str(metadata.age(metadata.con))),...
    metadata.sex(metadata.con), metadata.site_string(metadata.con), metadata.sex_string(metadata.con),...
    metadata.diagnosis_string(metadata.con), cellstr(num2str(ENsubHighEN(ismember(subHighEN,metadata.subj_id(metadata.con)))))], "VariableNames",["subj_id", "dataset", "site", "diagnosis",...
    "age", "sex", "site_string", "sex_string",  "diagnosis_string", "EN" ]);

writetable(metaTable,['/projects/kg98/trangc/VBM/data/', study, '/',study,'_qdec_extended.csv']);
%% test
% print first line and last line of metaTable and compare with original
% info - need manual check
testsub1 = metaTable(1,:)
testsub2 = metaTable(end,:)
subject(ismember(cellstr(subject.subj_id),[testsub1.subj_id,testsub2.subj_id]),:)


