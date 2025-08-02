%% read demographic information and extract subjects that satisfy criteria:
% - age: 18-60
% - each site has at least 20 subjects

% Trang Cao, Neural Systems and Behaviour Lab, Monash University, 2024.

%% make BIDS format of usable files
clear all
close all

study = 'OASIS4';

% define const
LOWAGE = 18*12; % lower bound of age
UPAGE = 60*12; % upper bound of age
NSUB = 20; % lowest number of subject per site per phenotype



% Open the input file for reading
imageTable = readtable(['/projects/kg98/trangc/VBM/data/', study, '/OASIS4_data_clinical.csv']);
useFolder = readlines(['/projects/kg98/trangc/VBM/data/', study, '/subject_copy.txt']);
siteFile = readlines(['/projects/kg98/trangc/VBM/data/', study, '/scanner_model.txt']);
IDsite = siteFile(1:3:end-1);
siteModel = siteFile(2:3:end);

site = unique(siteModel);
% list of sites and diagnose
[diag, ~, indexDiag] = unique(imageTable.final_dx);
diagList = {'HC', 'BD', 'SCA',...
    'SCZ', 'ASD', 'MDD' ,'AD'};
diagNo = [1:7];
nDiag = length(diagList);
diagIndex = {[5],[],[],[],[],[],[1:4,7]};

adult.ID = cellfun(@(x) x(5:end),IDsite, 'UniformOutput', false);

for iDiag = 1:nDiag
    for iSite = 1:length(site)
    % adult subjects in each phenotype in each site
    condition = ismember(adult.ID,...
        imageTable.oasis_id( ismember(imageTable.final_dx, diag(diagIndex{iDiag})))) & strcmp(siteModel,site(iSite));
    % number of adult subjects in each phenotype in each site
    nSubPerPhenotypePerSite(iSite, iDiag) = sum(condition);

    end
end
% the site and phenotype has >= NSUB HC subjects
siteSizeCondition = nSubPerPhenotypePerSite >= NSUB;

adult.use =  zeros(size(adult.ID));
iControl = 1;

for iSite = 1: length(site)

    % extract subject from sites having >= NSUB HC subjects and >= NSUB patients
    if siteSizeCondition(iSite, iControl) == 1 & sum(siteSizeCondition(iSite, setdiff(diagNo,iControl))) >= 1

        for iDiag = 1:nDiag

            if siteSizeCondition(iSite, iDiag) == 1

                % adult subjects in each phenotype in each site
               condition = ismember(adult.ID,...
        imageTable.oasis_id( ismember(imageTable.final_dx, diag(diagIndex{iDiag})))) & strcmp(siteModel,site(iSite));
                adult.use(condition) = 1;
            end

        end

       

    end

end
useID = adult.ID(adult.use==1);
imageTable.useID = ismember(imageTable.oasis_id,useID);
imageTable.useFile = imageTable.useID == 1 ;
[iUseFile col va] = find(imageTable.useFile);

idUse = imageTable.oasis_id(iUseFile);
[useSub iUnique iID] = unique(idUse);


useFolder = cellfun(@(x) ['sub-',char(x)],imageTable.oasis_id(iUseFile(iUnique),:), 'UniformOutput', false);

useSite = siteModel(adult.use==1);

%% create metadata to run VBM after proprocessing and cat report

IQRthres = 2.8; % threshold to determine good quality images

% read cat report
catFile = readtable(['/projects/kg98/trangc/VBM/data/', study, '/cat12_qcReport_', study, '.txt']);
subHighQR = catFile.Var1(catFile.Var2 <= IQRthres);
[La indexHighQRinUseFolder] = ismember(subHighQR, useFolder); % index in use Folder is same as in iUnique

metadata.subj_id = cellstr(useFolder(indexHighQRinUseFolder));
metadata.ses = catFile.Var3(catFile.Var2 <= IQRthres);
% matchIDHighQR = cellstr(matchID(indexHighQRinUseFolder));
metadata.dataset = cellstr(repmat(study,size(indexHighQRinUseFolder)));
% metadata.site_string = cellstr(useSite(indexHighQRinUseFolder));
% [uniqueUseSite, ~, indexSite] = unique(metadata.site_string );
% metadata.site = cellstr(num2str(indexSite+42));
metadata.site_string = metadata.dataset;
metadata.site = cellstr(repmat('43',size(indexHighQRinUseFolder)));

metadata.age = imageTable.age(iUseFile(iUnique(indexHighQRinUseFolder)));
metadata.sex_string = cellstr(num2str(imageTable.sex(iUseFile(iUnique(indexHighQRinUseFolder)))));
metadata.sex = cellstr(num2str(strcmp(metadata.sex_string,'1')));
metadata.sex_string(strcmp(metadata.sex_string,'1')) = {'M'};
metadata.sex_string(strcmp(metadata.sex_string,'2')) = {'F'};
% find diagnosis for used subjects
metadata.diagnosis_string = cellstr((imageTable.final_dx(iUseFile(iUnique(indexHighQRinUseFolder)))));

[La Lb] = ismember(metadata.diagnosis_string, diag(diagIndex{1}));

metadata.diagnosis = double(Lb);

metadata.diagnosis(Lb==0) = 7;

diagString = {'HC', 'BD', 'SCA',...
    'SCZ', 'ASD', 'MDD','AD' };
metadata.diagnosis_string(:,1) = diagString(metadata.diagnosis);
metadata.diagnosis = cellstr(num2str(metadata.diagnosis));


%% check number of subjects
diagCat = unique(metadata.diagnosis);

 for iDiag = 1: length(diagCat) % control and proband in the diag list

        % number of adult subjects in each phenotype in each site
        nSiteDiag( iDiag) = sum( strcmp(metadata.diagnosis, diagCat(iDiag)));

    end

% the site and phenotype has >= NSUB HC subjects
nSiteDiagCondition = nSiteDiag >= NSUB;
nSiteCondition = nSiteDiagCondition(:,1) & any(nSiteDiagCondition(:,2:end),2);
%%
metadata.con = zeros(size(metadata.subj_id));
  condition =    ismember(metadata.diagnosis, diagCat(nSiteDiagCondition(:)));

        metadata.con(condition) = 1;


% metadata.con(ismember(metadata.subj_id,'sub-2467ZEJ')) = 0;% remove sub with wrong site info, see note.txt
metadata.con = logical(metadata.con);
[La Lb] = ismember(metadata.subj_id(metadata.con), catFile.Var1);
metadata.CAT = cellstr(num2str(catFile.Var2(Lb)));

%%
metaTable = cell2table([metadata.subj_id(metadata.con), metadata.dataset(metadata.con), ...
    metadata.site(metadata.con), metadata.diagnosis(metadata.con), cellstr(num2str(metadata.age(metadata.con))),...
    metadata.sex(metadata.con), metadata.site_string(metadata.con), metadata.sex_string(metadata.con),metadata.ses,...
    metadata.diagnosis_string(metadata.con)], "VariableNames",["subj_id", "dataset", "site", "diagnosis",...
    "age", "sex", "site_string", "sex_string", "ses", "diagnosis_string" ]);

writetable(metaTable,['/projects/kg98/trangc/VBM/data/', study, '/',study,'_dems.csv']);

metaTable = cell2table([metadata.subj_id(metadata.con), metadata.dataset(metadata.con), ...
    metadata.site(metadata.con), metadata.diagnosis(metadata.con), cellstr(num2str(metadata.age(metadata.con))),...
    metadata.sex(metadata.con), metadata.site_string(metadata.con), metadata.sex_string(metadata.con),metadata.ses,...
    metadata.diagnosis_string(metadata.con), metadata.CAT], "VariableNames",["subj_id", "dataset", "site", "diagnosis",...
    "age", "sex", "site_string", "sex_string", "ses", "diagnosis_string", "CAT" ]);

writetable(metaTable,['/projects/kg98/trangc/VBM/data/', study, '/',study,'_dems_extended.csv']);
