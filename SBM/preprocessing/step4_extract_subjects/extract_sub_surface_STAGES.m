%% read demographic information and extract subjects that satisfy criteria:
% - age: 18-60
% - each site has at least 20 subjects

% Trang Cao, Neural Systems and Behaviour Lab, Monash University, 2022.

clear all
close all

study = 'STAGES';

% define const
LOWAGE = 18; % lower bound of age
UPAGE = 60; % upper bound of age
NSUB = 20; % lowest number of subject per site per phenotype

% read demographic file
subject = readtable(['/projects/kg98/trangc/VBM/data/',study,'/stages_data_for_trang.xlsx']);
medFile = readtable(['/projects/kg98/trangc/VBM/data/', study, '/dem/STAGES_demog_clin_massive_temp.xlsx']);

% list of diagnosis
phenotype = unique(subject.group_bl);

% filter subject in the age range 18-60 and have exist files
subject.adult = subject.Age >= LOWAGE & subject.Age <= UPAGE;
adult.ID = unique(subject.BIDS_ID(subject.adult == 1));


% subject.diag = double(ismember(subject.phenotype, phenotype(1)));

% adult healthy subjects
condition = ismember(adult.ID,...
    subject.BIDS_ID(subject.group_bl == phenotype(1)));
nSubPerPhenotypePerSite(1) = sum(condition);

% adult patients
nSubPerPhenotypePerSite(2) = length(adult.ID)-nSubPerPhenotypePerSite(1);

% the site and phenotype has >= NSUB HC subjects
siteSizeCondition = nSubPerPhenotypePerSite >= NSUB;
[La iUseFile] = ismember(adult.ID, subject.BIDS_ID);
useFolder = cellstr(adult.ID);

% writelines(useFolder, ['/projects/kg98/trangc/VBM/data/', study, '/subject_use.txt']);


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
if isempty(mriqcOutlierFile)
    subWithoutOutlier = subHighEN;
else
    mriqcOutlier = mriqcOutlierFile.Var1;

    [LinO LocO] = ismember(subHighEN, mriqcOutlier);
    subWithoutOutlier = subHighEN(LinO==0);
end

% check if data exist
sesSubFile = readtable(fullfile('/projects/kg98/trangc/VBM/data', study,'ses_sub_with_recon_output.txt'));
subFile = arrayfun(@(x) sesSubFile.Var1{x}(1:end-5),1:length(sesSubFile.Var1),'UniformOutput',false);
sesFile = arrayfun(@(x) sesSubFile.Var1{x}(end-4:end),1:length(sesSubFile.Var1),'UniformOutput',false);
[linS LocS] = ismember(subWithoutOutlier, subFile);
for iSub = 1:length(subWithoutOutlier)
    checkFile(iSub) = isfile(fullfile('/projects/kg98/trangc/VBM/data', study, ...
        'derivatives','freesurfer', char(subWithoutOutlier(iSub)), 'surf','lh.thickness.fwhm10.fsaverage.mgh'));
end
subWithoutOutlier = subWithoutOutlier(checkFile);


[La indexHighQRinUseFolder] = ismember(subWithoutOutlier, useFolder); % index in use Folder is same as in iUnique
% indexHighQRinUseFolder = indexHighQRinUseFolder(indexHighQRinUseFolder>0);
subWithoutOutlier = useFolder(indexHighQRinUseFolder);

writetable(cell2table(subWithoutOutlier),['/projects/kg98/trangc/VBM/data/', study, '/sub_without_outlier.txt'],"WriteVariableNames",false);
writetable(cell2table(subWithOutlier(ismember(subWithOutlier,subWithoutOutlier)==0)),['/projects/kg98/trangc/VBM/data/', study, '/autoQCOutlier.txt'],"WriteVariableNames",false);

% indexHighQRinUseFolder = indexHighQRinUseFolder(indexHighQRinUseFolder>0);

metadata.subj_id = cellstr(useFolder(indexHighQRinUseFolder));
metadata.dataset = cellstr(repmat(study,size(indexHighQRinUseFolder)));
metadata.site = cellstr(repmat('29',size(metadata.subj_id)));
metadata.site_string = metadata.dataset;

metadata.age = cellstr(num2str(round(subject.Age(iUseFile(indexHighQRinUseFolder)))));
metadata.sex = cellstr(num2str(subject.sex(iUseFile(indexHighQRinUseFolder))==2));
metadata.sex_string(strcmp(metadata.sex,'1'),1) = {'M'};
metadata.sex_string(strcmp(metadata.sex,'0'),1) = {'F'};

% find diagnosis for used subjects
metadata.diagnosis = double((subject.group_bl(iUseFile(indexHighQRinUseFolder))==phenotype(2)));
metadata.diagnosis(metadata.diagnosis == 0) = 4;
diagString = {'Healthy Control', 'Bipolar disorder', 'Schizoaffective Disorder',...
    'Schizophrenia', 'Autistic Spectrum Disorders', 'Major depressive disorder' };
metadata.diagnosis_string(:,1) = diagString(metadata.diagnosis);
metadata.diagnosis = cellstr(num2str(metadata.diagnosis));

%% check number of subjects
diagCat = unique(metadata.diagnosis);

for iDiag = 1: length(diagCat) % control and proband in the diag list

    % number of adult subjects in each phenotype in each site
    nSiteDiag( iDiag) = sum(strcmp(metadata.diagnosis, diagCat(iDiag)));

end

% the site and phenotype has >= NSUB HC subjects
nSiteDiagCondition = nSiteDiag >= NSUB;

nSiteCondition = nSiteDiagCondition(:,1) & any(nSiteDiagCondition(:,2:end),2);

%%
metadata.con = zeros(size(metadata.subj_id));

siteDiag = diagCat(nSiteDiagCondition); % diag for this site
for iDiag = 2:length(siteDiag)
    condition = ismember(metadata.diagnosis, siteDiag([1,iDiag]));
    qdecTable = cell2table([metadata.subj_id(condition), metadata.diagnosis(condition), ...
        metadata.sex(condition), metadata.age(condition)], "VariableNames",["fsid", "diagnosis",...
        "sex", "age"]);
    writetable(qdecTable,['/projects/kg98/trangc/VBM/data/', study, ...
        '/qdec_table_', char(unique(metadata.site_string(condition))),'_',char(siteDiag(iDiag)),'.dat'],'Delimiter','tab');

    writecell(table2array(qdecTable(:,2:4)),['/projects/kg98/trangc/VBM/data/', study, ...
        '/ANCOVA_matrix_', char(siteDiag(iDiag)), '_', char(unique(metadata.site_string(condition))),'.txt'],'Delimiter','tab')
end

