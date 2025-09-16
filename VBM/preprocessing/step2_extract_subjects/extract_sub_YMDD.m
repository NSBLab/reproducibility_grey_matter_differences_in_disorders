%% read demographic information and extract subjects that satisfy criteria:
% - age: 18-60
% - each site has at least 20 subjects

% Trang Cao, Neural Systems and Behaviour Lab, Monash University, 2022.

clear all
close all

study = 'YMDD';

% define const
LOWAGE = 18; % lower bound of age
UPAGE = 60; % upper bound of age
NSUB = 20; % lowest number of subject per site per phenotype

% read demographic file
subject = readtable(['/projects/kg98/trangc/VBM/data/',study,'/',study,'_master.csv']);

% list of diagnosis
phenotype = unique(subject.diagnosis);

% filter subject in the age range 18-60 and have exist files
subject.adult = subject.age >= LOWAGE & subject.age <= UPAGE;
adult.ID = unique(subject.subj_id(subject.adult == 1));

[site, ~, indexSite] = unique(subject.site);
[diag, ~, indexDiag] = unique(subject.diagnosis);
iControl = 1;
nSite = size(site,1);
nDiag = size(diag,1);
for iSite = 1: nSite
    for iDiag = 1: nDiag % control and proband in the diag list

        condition = ismember(adult.ID,...
            subject.subj_id(subject.site == site(iSite) & subject.diagnosis == phenotype(iDiag)));
        nSubPerPhenotypePerSite(iSite,iDiag) = sum(condition);

    end
end
% the site and phenotype has >= NSUB HC subjects
siteSizeCondition = nSubPerPhenotypePerSite >= NSUB;

adult.use =  zeros(size(adult.ID));
for iSite = 1: nSite

    % extract subject from sites having >= NSUB HC subjects and >= NSUB patients
    if siteSizeCondition(iSite, iControl) == 1 & sum(siteSizeCondition(iSite, setdiff(1:nDiag,iControl))) >= 1

        for iDiag = 1:nDiag

            if siteSizeCondition(iSite, iDiag) == 1

                % adult subjects in each phenotype in each site
                condition = ismember(adult.ID,...
                    subject.subj_id(subject.site == site(iSite) & subject.diagnosis == phenotype(iDiag)));
                adult.use(condition) = 1;
            end

        end

    end

end
[La iUseFile] = ismember(adult.ID(adult.use==1), subject.subj_id);
useFolder = cellstr(adult.ID(adult.use==1));

% writelines(useFolder, ['/projects/kg98/trangc/VBM/data/', study, '/subject_use.txt']);


% create metadata
IQRthres = 2.8;
% read cat report
catFile = readtable(['/projects/kg98/trangc/VBM/data/', study, '/cat12_qcReport_', study, '.txt']);
subHighQR = catFile.Var1(catFile.Var2 <= IQRthres);
[La indexHighQRinUseFolder] = ismember(subHighQR, useFolder); % index in use Folder is same as in iUnique

metadata.subj_id = cellstr(useFolder(indexHighQRinUseFolder));
metadata.dataset = cellstr(repmat(study,size(indexHighQRinUseFolder)));
metadata.site_string = cellstr(subject.site_string(iUseFile(indexHighQRinUseFolder)));
[La Lb] = ismember(metadata.site_string,unique(metadata.site_string));
metadata.site = cellstr(num2str(Lb+30));

metadata.age = cellstr(num2str(round(subject.age(iUseFile(indexHighQRinUseFolder)))));
metadata.sex = cellstr(num2str(subject.sex(iUseFile(indexHighQRinUseFolder))==1));
metadata.sex_string(strcmp(metadata.sex,'1'),1) = {'M'};
metadata.sex_string(strcmp(metadata.sex,'0'),1) = {'F'};

% find diagnosis for used subjects
metadata.diagnosis = double((subject.diagnosis(iUseFile(indexHighQRinUseFolder))==phenotype(1)));
metadata.diagnosis(metadata.diagnosis == 0) = 6;
diagString = {'Healthy Control', 'Bipolar disorder', 'Schizoaffective Disorder',...
    'Schizophrenia', 'Autistic Spectrum Disorders', 'Major depressive disorder', 'ADHD' };
metadata.diagnosis_string(:,1) = diagString(metadata.diagnosis);
metadata.diagnosis = cellstr(num2str(metadata.diagnosis));

%% check number of subjects
diagCat = unique(metadata.diagnosis);
siteCat = unique(metadata.site);
for iSite = 1: length(siteCat) 
for iDiag = 1: length(diagCat) % control and proband in the diag list

    % number of adult subjects in each phenotype in each site
    nSiteDiag(iSite, iDiag) = sum(strcmp(metadata.diagnosis, diagCat(iDiag)) & strcmp(metadata.site, siteCat(iSite)));

end
end

% the site and phenotype has >= NSUB HC subjects
nSiteDiagCondition = nSiteDiag >= NSUB;
nSiteCondition = nSiteDiagCondition(:,1) & nSiteDiagCondition(:,2);
siteCon = siteCat(nSiteCondition);

metadata.con = zeros(size(metadata.subj_id));
for iSite = 1:length(siteCon)
    
        condition = ismember(metadata.site,siteCon(iSite)) & ...
            ismember(metadata.diagnosis, diagCat(nSiteDiagCondition(iSite,:)));

        metadata.con(condition) = 1;
end

metadata.con = logical(metadata.con);
%% CAT
[La Lb] = ismember(metadata.subj_id(metadata.con), catFile.Var1);
metadata.CAT = cellstr(num2str(catFile.Var2(Lb)));
%%
metaTable = cell2table([metadata.subj_id(metadata.con), metadata.dataset(metadata.con), ...
    metadata.site(metadata.con), metadata.diagnosis(metadata.con), metadata.age(metadata.con),...
    metadata.sex(metadata.con), metadata.site_string(metadata.con), metadata.sex_string(metadata.con),...
    metadata.diagnosis_string(metadata.con), metadata.CAT], "VariableNames",["subj_id", "dataset", "site", "diagnosis",...
    "age", "sex", "site_string", "sex_string",  "diagnosis_string" , "CAT"]);
writetable(metaTable,['/projects/kg98/trangc/VBM/data/', study, '/',study,'_dems_extended.csv']);
