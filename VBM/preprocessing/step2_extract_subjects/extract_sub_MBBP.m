%% read demographic information and extract subjects that satisfy criteria:
% - age: 18-60
% - each site has at least 20 subjects

% Trang Cao, Neural Systems and Behaviour Lab, Monash University, 2022.

clear all
close all

study = 'MBBP';

% define const
LOWAGE = 18; % lower bound of age
UPAGE = 60; % upper bound of age
NSUB = 20; % lowest number of subject per site per phenotype

% read demographic files
imageFile = readtable(['/projects/kg98/trangc/VBM/data/', study, '/MBBP_dems_ori.csv']);
medFile = readtable(['/projects/kg98/trangc/VBM/data/', study,'/MonashBrainAndBehavi-MedicationUse_DATA_2024-06-14_1453.csv']);
medName = readtable(['/projects/kg98/trangc/VBM/data/medication_name_for_code.csv']);

% subject in the age range 18-60 at scanning time
imageFile.adult = imageFile.age >= LOWAGE & imageFile.age <= UPAGE;
imageFile.exist = zeros(size(imageFile.adult));
for iSub = [1:length(imageFile.exist)]
        if exist(['/home/trangc/kg98_scratch/Toby/WHOLEMBBP/workspace/processed_niftis/',char(imageFile.subj_id(iSub)),'/anat/',char(imageFile.subj_id(iSub)),'_T1w.nii'])
              imageFile.exist(iSub) = 1;
          end
end
adult.ID = unique(imageFile.subj_id(imageFile.adult == 1 & imageFile.exist == 1));

% list of sites and diagnose
[diag, ~, indexDiag] = unique(imageFile.diagnosis_string);
diagList = 1:2;

nDiag = size(diag,1);



    for iDiag = 1: nDiag % control and proband in the diag list

        % adult subjects in each phenotype in each site
        condition = ismember(adult.ID,...
            imageFile.subj_id( indexDiag == iDiag));

        % number of adult subjects in each phenotype in each site
        nSubPerPhenotypePerSite( iDiag) = sum(condition);

    end


% the site and phenotype has >= NSUB HC subjects
siteSizeCondition = nSubPerPhenotypePerSite >= NSUB;

adult.use =  zeros(size(adult.ID));


    
        for iDiag = diagList

        

                % adult subjects in each phenotype in each site
                condition = ismember(adult.ID,...
                    imageFile.subj_id( indexDiag == iDiag));
                adult.use(condition) = 1;
          

        end

       
useID = adult.ID(adult.use==1);
imageFile.useID = ismember(imageFile.subj_id,useID);
imageFile.useFile = imageFile.useID == 1 ;
[iUseFile col va] = find(imageFile.useFile);

idUse = imageFile.subj_id(iUseFile);
[useSub iUnique iID] = unique(idUse);



useFolder = cellstr(imageFile.subj_id(iUseFile(iUnique),:));
useFolder = cellfun(@(x) [x(1:4),sprintf('%04d',str2num(x(5:end)))], useFolder,'UniformOutput',false);





%% create metadata to run VBM after proprocessing and cat report

IQRthres = 2.8; % threshold to determine good quality images

% read cat report
catFile = readtable(['/projects/kg98/trangc/VBM/data/', study, '/cat12_qcReport_', study, '.txt']);
subHighQR = catFile.Var1(catFile.Var2 <= IQRthres);
[La indexHighQRinUseFolder] = ismember(subHighQR, useFolder); % index in use Folder is same as in iUnique

metadata.subj_id = cellstr(useFolder(indexHighQRinUseFolder));

metadata.dataset = cellstr(repmat(study,size(indexHighQRinUseFolder)));
metadata.site_string = metadata.dataset;
metadata.site = cellstr(repmat('44',size(indexHighQRinUseFolder)));
metadata.age = imageFile.age(iUseFile(iUnique(indexHighQRinUseFolder)));
metadata.sex_string = cellstr(imageFile.sex_string(iUseFile(iUnique(indexHighQRinUseFolder))));
metadata.sex = cellstr(num2str(strcmp(metadata.sex_string,'M')));

% find diagnosis for used subjects
metadata.diagnosis_string = cellstr(imageFile.diagnosis_string(iUseFile(iUnique(indexHighQRinUseFolder))));
[La Lb] = ismember(metadata.diagnosis_string, diag);

metadata.diagnosis = Lb;
metadata.diagnosis(Lb==1) = 1;
metadata.diagnosis(Lb==2) = 6;
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
 matchIDHighQR = cellfun(@(x) ['MBBP_', x(6:end)],cellstr(useFolder(indexHighQRinUseFolder)),'UniformOutput',false);
metadata.antipsychotic = if_med(matchIDHighQR, medFile, medName, 2, 9,study);  %maxNoMed=18
 metadata.moodstabiliser = if_med(matchIDHighQR, medFile, medName, 3, 9,study);
metadata.antidepression = if_med(matchIDHighQR, medFile, medName, 4, 9,study);
metadata.antianxiety = if_med(matchIDHighQR, medFile, medName, 5, 9,study);
metadata.treatment = cellstr(num2str(any(logical([metadata.antipsychotic, metadata.moodstabiliser, metadata.antidepression, metadata.antianxiety]),2)));



%%
metaTable = cell2table([metadata.subj_id(metadata.con), metadata.dataset(metadata.con), ...
    metadata.site(metadata.con), metadata.diagnosis(metadata.con), cellstr(num2str(metadata.age(metadata.con))),...
    metadata.sex(metadata.con), metadata.site_string(metadata.con), metadata.sex_string(metadata.con),...
    metadata.diagnosis_string(metadata.con)], "VariableNames",["subj_id", "dataset", "site", "diagnosis",...
    "age", "sex", "site_string", "sex_string",  "diagnosis_string" ]);

writetable(metaTable,['/projects/kg98/trangc/VBM/data/', study, '/',study,'_dems.csv']);

metaTable = cell2table([metadata.subj_id(metadata.con), metadata.dataset(metadata.con), ...
    metadata.site(metadata.con), metadata.diagnosis(metadata.con), cellstr(num2str(metadata.age(metadata.con))),...
    metadata.sex(metadata.con), metadata.site_string(metadata.con), metadata.sex_string(metadata.con),...
    metadata.diagnosis_string(metadata.con), metadata.CAT,cellstr(num2str(metadata.antipsychotic(metadata.con))),...
    cellstr(num2str(metadata.moodstabiliser(metadata.con))), cellstr(num2str(metadata.antidepression(metadata.con))), ...
    cellstr(num2str(metadata.antianxiety(metadata.con))), metadata.treatment(metadata.con)], "VariableNames",["subj_id", "dataset", "site", "diagnosis",...
    "age", "sex", "site_string", "sex_string",  "diagnosis_string", "CAT","antipsychotic", "moodstabiliser",...
    "antidepression", "antianxiety","treatment" ]);

writetable(metaTable,['/projects/kg98/trangc/VBM/data/', study, '/',study,'_dems_extended.csv']);
