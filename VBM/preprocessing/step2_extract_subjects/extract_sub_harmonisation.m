%% read demographic information and extract subjects that satisfy criteria:
% - age: 18-60
% - each site has at least 20 subjects

% Trang Cao, Neural Systems and Behaviour Lab, Monash University, 2024.

%% make BIDS format of usable files
clear all
close all

study = 'Harmonisation';
study_path = '/projects/kg98/trangc/VBM/data/Harmonisation';
% define const

NSUB = 20; % lowest number of subject per site per phenotype



% Open the input file for reading
imageFile = readtable(['/projects/kg98/trangc/VBM/data/', study, '/Harmonisation_demo.csv'], "FileType","text",'Delimiter', ',');



adult.ID = unique(imageFile.subid);

% list of sites and diagnose
[diag, ~, indexDiag] = unique(imageFile.dx);
diagList = [1,4];

nDiag = length(diagList);


    for iDiag = 1: nDiag % control and proband in the diag list

        % adult subjects in each phenotype in each site
        condition = ismember(adult.ID,...
            imageFile.subid(indexDiag == diagList(iDiag)));

        % number of adult subjects in each phenotype in each site
        nSubPerPhenotypePerSite( iDiag) = sum(condition);

    end


% the site and phenotype has >= NSUB HC subjects
siteSizeCondition = nSubPerPhenotypePerSite >= NSUB;

adult.use =  zeros(size(adult.ID));


        for iDiag = 1: nDiag

            if siteSizeCondition( iDiag) == 1

                % adult subjects in each phenotype in each site
                condition = ismember(adult.ID,...
                    imageFile.subid( indexDiag == diagList(iDiag)));
                adult.use(condition) = 1;
            end

        end



useID = adult.ID(adult.use==1);
imageFile.useID = ismember(imageFile.subid,useID);
imageFile.useFile = imageFile.useID == 1 ;
[iUseFile col va] = find(imageFile.useFile);

idUse = imageFile.subid(iUseFile);
[useSub iUnique iID] = unique(idUse);


useFolder = cellfun(@(x) ['sub-',char(x)],imageFile.subid(iUseFile(iUnique),:), 'UniformOutput', false);







%% create metadata to run VBM after proprocessing and cat report

IQRthres = 2.8; % threshold to determine good quality images

% read cat report
catFile = readtable(['/projects/kg98/trangc/VBM/data/', study, '/cat12_qcReport_', study, '.txt']);
subHighQR = catFile.Var1(catFile.Var2 <= IQRthres & ismember(catFile.Var1,useFolder));
sesHishHQ =  catFile.Var3(catFile.Var2 <= IQRthres & ismember(catFile.Var1,useFolder));
% Check if visual inspection exclusion list exists
visual_exclusion_file = fullfile(study_path, 'derivatives','volume_visualisation','subject_list_excluded_after_visualisation.txt');
if exist(visual_exclusion_file, 'file')
    visual_excluded_subjects = readlines(visual_exclusion_file);
     % Remove empty lines that may be created by bash
    visual_excluded_subjects = visual_excluded_subjects(~strcmp(visual_excluded_subjects, ''));
   fprintf('Found %d subjects excluded after visual inspection\n', length(visual_excluded_subjects));
    
    % Remove visually excluded subjects from CAT12 passed list
    [useFoldervis ia] = setdiff(subHighQR, visual_excluded_subjects);
    fprintf('After visual inspection exclusion: %d subjects remaining\n', length(useFoldervis));
else
    fprintf('No visual inspection exclusion list found. Using all CAT12 passed subjects.\n');
    useFoldervis = cat12_passed_subjects;
end

% [LiSub indexHighQRinUseFolder] = ismember(useFolder, image.subses); % index in use Folder is same as in iUnique

[La indexHighQRinUseFolder] = ismember(useFoldervis, useFolder); % index in use Folder is same as in iUnique

metadata.subj_id = cellstr(useFolder(indexHighQRinUseFolder));
metadata.ses = sesHishHQ(ia);
% matchIDHighQR = cellstr(matchID(indexHighQRinUseFolder));
metadata.dataset = cellstr(repmat(study,size(indexHighQRinUseFolder)));
metadata.site_string = metadata.dataset;
metadata.site = cellstr(repmat('42',size(indexHighQRinUseFolder)));
metadata.age = imageFile.interview_age(iUseFile(iUnique(indexHighQRinUseFolder)));
metadata.sex_string = cellstr(num2str(imageFile.gender(iUseFile(iUnique(indexHighQRinUseFolder)))));
metadata.sex = cellstr(num2str(strcmp(metadata.sex_string,'1')));
metadata.sex_string(strcmp(metadata.sex_string,'1')) = {'M'};
metadata.sex_string(strcmp(metadata.sex_string,'2')) = {'F'};
% find diagnosis for used subjects
metadata.diagnosis_string = cellstr(num2str(imageFile.dx(iUseFile(iUnique(indexHighQRinUseFolder)))));
[La Lb] = ismember(metadata.diagnosis_string, cellstr(num2str(diag)));

metadata.diagnosis = Lb;
metadata.diagnosis(Lb==1) = 1;
metadata.diagnosis(Lb==4) = 7;
diagString = {'HC', 'BD', 'SCA',...
    'SCZ', 'ASD', 'MDD' ,'AD'};
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
    "age", "sex", "site_string", "sex_string", "ses", "diagnosis_string"]);

writetable(metaTable,['/projects/kg98/trangc/VBM/data/', study, '/',study,'_dems.csv']);
metaTable = cell2table([metadata.subj_id(metadata.con), metadata.dataset(metadata.con), ...
    metadata.site(metadata.con), metadata.diagnosis(metadata.con), cellstr(num2str(metadata.age(metadata.con))),...
    metadata.sex(metadata.con), metadata.site_string(metadata.con), metadata.sex_string(metadata.con),metadata.ses,...
    metadata.diagnosis_string(metadata.con), metadata.CAT], "VariableNames",["subj_id", "dataset", "site", "diagnosis",...
    "age", "sex", "site_string", "sex_string", "ses", "diagnosis_string", "CAT" ]);

writetable(metaTable,['/projects/kg98/trangc/VBM/data/', study, '/',study,'_dems_extended.csv']);

