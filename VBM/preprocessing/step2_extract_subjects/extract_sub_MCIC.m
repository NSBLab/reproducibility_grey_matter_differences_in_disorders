%% read demographic information and extract subjects that satisfy criteria:
% - age: 18-60
% - each site has at least 20 subjects

% Trang Cao, Neural Systems and Behaviour Lab, Monash University, 2022.

clear all
close all

study = 'MCIC';

% define const
LOWAGE = 18; % lower bound of age
UPAGE = 60; % upper bound of age
NSUB = 20; % lowest number of subject per site per phenotype

% read demographic file
subject = readtable('/projects/kg98/trangc/VBM/data/MCIC/5720_MCIC_Clinical_Data_20220224.csv');

% filter subject in the age range 18-60
subject.adult = subject.Age >= LOWAGE & subject.Age <= UPAGE;

% list of sites
site = unique(subject.Site);
phenotype = unique(subject.SubjectType);
subject.use = zeros(size(subject.adult));
for iSite = 1: length(site)
         for iPheno = 1: length(phenotype)
        % adult subjects in each phenotype in each site
        condition = strcmp(cellstr(subject.Site), site(iSite)) & strcmp(subject.SubjectType, phenotype(iPheno)) & (subject.adult == 1);
        
        % number of adult subjects in each phenotype in each site
        nSubPerPhenotypePerSite(iSite, iPheno) = sum(condition);
        
    end
end

% the site and phenotype has >= NSUB HC subjects
siteSizeCondition = nSubPerPhenotypePerSite >= NSUB;


for iSite = 1: length(site)
    
    % extract subject from sites having >= 20 NSUB subjects and >= NSUB patients
    if siteSizeCondition(iSite, 1) == 1 & sum(siteSizeCondition(iSite, 2:length(phenotype))) >= 1
        
        for iPheno = 1: length(phenotype)
            
            if siteSizeCondition(iSite, iPheno) == 1
                
                % adult subjects in each phenotype in each site
                condition = strcmp(cellstr(subject.Site), site(iSite,:)) & strcmp(subject.SubjectType, phenotype(iPheno)) & (subject.adult == 1);
                subject.use(condition) = 1;
            end
            
        end
        
    end
    
end

[iUseFile col va] = find(subject.use == 1);
useFolder = "sub-" + cellstr(subject.AnonymizedID(subject.use == 1));

% create metadata
IQRthres = 2.8;
% read cat report
catFile = readtable(['/projects/kg98/trangc/VBM/data/', study, '/cat12_qcReport_', study, '.txt']);
subHighQR = catFile.Var1(catFile.Var2 <= IQRthres);
[La indexHighQRinUseFolder] = ismember(subHighQR, useFolder); % index in use Folder is same as in iUnique

metadata.subj_id = cellstr(useFolder(indexHighQRinUseFolder));
metadata.dataset = cellstr(repmat(study,size(indexHighQRinUseFolder)));
metadata.site_string = cellstr(subject.Site(iUseFile(indexHighQRinUseFolder),:));
[La Lb] = ismember(metadata.site_string,unique(metadata.site_string()));
metadata.site = cellstr(num2str(Lb+23));
metadata.ses = catFile.Var3(catFile.Var2 <= IQRthres);

metadata.age = subject.Age(iUseFile(indexHighQRinUseFolder));
metadata.sex_string = cellstr(subject.Sex(iUseFile(indexHighQRinUseFolder)));
metadata.sex = cellstr(num2str(strcmp(metadata.sex_string,'M')));


% find diagnosis for used subjects
metadata.diagnosis_string = subject.SubjectType(iUseFile(indexHighQRinUseFolder));
[La Lb] = ismember(metadata.diagnosis_string, unique(metadata.diagnosis_string));
Lb(Lb == 2) = 4;
diagString = {'Healthy Control', 'Bipolar disorder', 'Schizoaffective Disorder',...
    'Schizophrenia', 'Autistic Spectrum Disorders', 'Major depressive disorder' };
metadata.diagnosis_string(:,1) = diagString(Lb);
metadata.diagnosis = cellstr(num2str(Lb));

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

criteria = 'IllnessDuration';
[La indexIDinMed] = ismember(extract(metadata.subj_id(metadata.con),digitsPattern), extract(subject.AnonymizedID,digitsPattern)); % index in medFile 
columnNames = subject.Properties.VariableNames;
onsetIn = find(matches(columnNames, criteria)==1);
metadata.illnessDuration(:,1) = subject{indexIDinMed,onsetIn};

metadata.ageOnset = metadata.age(metadata.con) - metadata.illnessDuration;

%%
metaTable = cell2table([metadata.subj_id(metadata.con), metadata.dataset(metadata.con), ...
    metadata.site(metadata.con), metadata.diagnosis(metadata.con), cellstr(num2str(metadata.age(metadata.con))),...
    metadata.sex(metadata.con), metadata.site_string(metadata.con), metadata.sex_string(metadata.con), metadata.ses(metadata.con),...
    metadata.diagnosis_string(metadata.con),metadata.CAT, cellstr(num2str(metadata.ageOnset)), ...
    cellstr(num2str(metadata.illnessDuration))], "VariableNames",["subj_id", "dataset", "site", "diagnosis",...
    "age", "sex", "site_string", "sex_string", "ses", "diagnosis_string","CAT","ageOnset","illnessDuration" ]);

writetable(metaTable,['/projects/kg98/trangc/VBM/data/', study, '/',study,'_dems_extended.csv']);

% writematrix(subject.participant_id(subject.use == 1,:), '/projects/kg98/trangc/VBM/data/SRPBS/subject_use.txt');