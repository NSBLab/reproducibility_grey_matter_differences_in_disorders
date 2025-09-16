%% read demographic information and extract subjects that satisfy criteria:
% - age: 18-60
% - each site has at least 20 subjects

% Trang Cao, Neural Systems and Behaviour Lab, Monash University, 2024.

%% make BIDS format of usable files
clear all
close all

study = 'Myelin';

% define const
LOWAGE = 18; % lower bound of age
UPAGE = 60; % upper bound of age
NSUB = 20; % lowest number of subject per site per phenotype



% Open the input file for reading
imageFile = readtable(['/projects/kg98/trangc/VBM/data/', study, '/participants.tsv'], "FileType","text",'Delimiter', '\t');
% subject in the age range 18-60 at scanning time
imageFile.adult = imageFile.age >= LOWAGE & imageFile.age <= UPAGE;
adult.ID = unique(imageFile.participant_id(imageFile.adult == 1));

% list of sites and diagnose
[diag, ~, indexDiag] = unique(imageFile.group);
diagList = [1,3];

nDiag = size(diag,1);


    for iDiag = 1: nDiag % control and proband in the diag list

        % adult subjects in each phenotype in each site
        condition = ismember(adult.ID,...
            imageFile.participant_id(indexDiag == iDiag));

        % number of adult subjects in each phenotype in each site
        nSubPerPhenotypePerSite( iDiag) = sum(condition);

    end


% the site and phenotype has >= NSUB HC subjects
siteSizeCondition = nSubPerPhenotypePerSite >= NSUB;

adult.use =  zeros(size(adult.ID));


        for iDiag = diagList

            if siteSizeCondition( iDiag) == 1

                % adult subjects in each phenotype in each site
                condition = ismember(adult.ID,...
                    imageFile.participant_id( indexDiag == iDiag));
                adult.use(condition) = 1;
            end

        end



useID = adult.ID(adult.use==1);
imageFile.useID = ismember(imageFile.participant_id,useID);
imageFile.useFile = imageFile.useID == 1 ;
[iUseFile col va] = find(imageFile.useFile);

idUse = imageFile.participant_id(iUseFile);
[useSub iUnique iID] = unique(idUse);


useFolder = cellstr(imageFile.participant_id(iUseFile(iUnique),:));






%% create metadata to run VBM after proprocessing and cat report

IQRthres = 2.8; % threshold to determine good quality images

% read cat report
catFile = readtable(['/projects/kg98/trangc/VBM/data/', study, '/cat12_qcReport_', study, '.txt']);
subHighQR = catFile.Var1(catFile.Var2 <= IQRthres & ismember(catFile.Var1,useFolder));
[La indexHighQRinUseFolder] = ismember(subHighQR, useFolder); % index in use Folder is same as in iUnique

metadata.subj_id = cellstr(useFolder(indexHighQRinUseFolder));
metadata.ses = catFile.Var3(catFile.Var2 <= IQRthres & ismember(catFile.Var1,useFolder));
% matchIDHighQR = cellstr(matchID(indexHighQRinUseFolder));
metadata.dataset = cellstr(repmat(study,size(indexHighQRinUseFolder)));
metadata.site_string = metadata.dataset;
metadata.site = cellstr(repmat('41',size(indexHighQRinUseFolder)));
metadata.age = imageFile.age(iUseFile(iUnique(indexHighQRinUseFolder)));
metadata.sex_string = cellstr(imageFile.sex(iUseFile(iUnique(indexHighQRinUseFolder))));
metadata.sex = cellstr(num2str(strcmp(metadata.sex_string,'M')));

% find diagnosis for used subjects
metadata.diagnosis_string = cellstr(imageFile.group(iUseFile(iUnique(indexHighQRinUseFolder))));
[La Lb] = ismember(metadata.diagnosis_string, diag);
control = 'HC';
[iControl ic] = find(strcmp(diag, control));
metadata.diagnosis = Lb;
metadata.diagnosis(Lb==iControl) = 1;
metadata.diagnosis(Lb==3) = 6;
diagString = {'HC', 'BD', 'SCA',...
    'SCZ', 'ASD', 'MDD' };
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
