%% read demographic information and extract subjects that satisfy criteria:
% - age: 18-60
% - each site has at least 20 subjects

% Trang Cao, Neural Systems and Behaviour Lab, Monash University, 2024.

%% make BIDS format of usable files
clear all
close all

study = 'ContrastRes';

% define const
LOWAGE = 18; % lower bound of age
UPAGE = 60; % upper bound of age
NSUB = 20; % lowest number of subject per site per phenotype



% Open the input file for reading
imageTable = readtable(['/projects/kg98/trangc/VBM/data/', study, '/participants.tsv'], "FileType","text",'Delimiter', '\t');
% subject in the age range 18-60 at scanning time
imageTable.adult = imageTable.age >= LOWAGE & imageTable.age <= UPAGE;
adult.ID = unique(imageTable.participant_id(imageTable.adult == 1));

% list of sites and diagnose
[diag, ~, indexDiag] = unique(imageTable.group);
diagList = 1:2;

nDiag = size(diag,1);


    for iDiag = 1: nDiag % control and proband in the diag list

        % adult subjects in each phenotype in each site
        condition = ismember(adult.ID,...
            imageTable.participant_id(indexDiag == iDiag));

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
                    imageTable.participant_id( indexDiag == iDiag));
                adult.use(condition) = 1;
            end

        end



useID = adult.ID(adult.use==1);
imageTable.useID = ismember(imageTable.participant_id,useID);
imageTable.useFile = imageTable.useID == 1 ;
[iUseFile col va] = find(imageTable.useFile);

idUse = imageTable.participant_id(iUseFile);
[useSub iUnique iID] = unique(idUse);


useFolder = cellstr(imageTable.participant_id(iUseFile(iUnique),:));




%% create metadata to run VBM after proprocessing and cat report

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
ENsubHighEN = eulerNumber((eulerNumber > (meanEN-3.29*SD_EN)));
subHighEN = arrayfun(@(x) holesFile.Var1{inSubLh(x)}(1:end-3), find(eulerNumber > (meanEN-3.29*SD_EN)), 'UniformOutput', false);
% subWithOutlier = (arrayfun(@(x) holesFile.Var1{inSubLh(x)}(1:end-3), 1:length(inSubLh), 'UniformOutput', false))';
% [La indexinUseFolder] = ismember(subWithOutlier, useFolder); % index in use Folder is same as in iUnique
% indexinUseFolder = indexinUseFolder(indexinUseFolder>0);
% subWithOutlier = useFolder(indexinUseFolder);

% skip MRIQC
subWithoutOutlier = subHighEN;
% exclude after visualize
mark = readtable(fullfile('/projects/kg98/trangc/VBM/data', study,'sub_with_recon_output_marked.txt'),'ReadVariableNames', false);
[lia locb] = ismember(subWithoutOutlier, mark.Var1);
if size(mark,2) == 2
    subWithoutOutlier(strcmp(mark.Var2(locb),'x')) = [];
end

[La indexHighQRinUseFolder] = ismember(subWithoutOutlier, useFolder); % index in use Folder is same as in iUnique
% indexHighQRinUseFolder = indexHighQRinUseFolder(indexHighQRinUseFolder>0);
% subWithoutOutlier = useFolder(indexHighQRinUseFolder);

metadata.subj_id = cellstr(useFolder(indexHighQRinUseFolder));
% metadata.ses = catFile.Var3(catFile.Var2 <= IQRthres);
% matchIDHighQR = cellstr(matchID(indexHighQRinUseFolder));
metadata.dataset = cellstr(repmat(study,size(indexHighQRinUseFolder)));
metadata.site_string = metadata.dataset;
metadata.site = cellstr(repmat('46',size(indexHighQRinUseFolder)));
metadata.age = imageTable.age(iUseFile(iUnique(indexHighQRinUseFolder)));
metadata.sex_string = cellstr(imageTable.sex(iUseFile(iUnique(indexHighQRinUseFolder))));
metadata.sex = cellstr(num2str(strcmp(metadata.sex_string,'m')));
metadata.sex_string(strcmp(metadata.sex_string,'m')) = {'M'};
metadata.sex_string(strcmp(metadata.sex_string,'f')) = {'F'};

% find diagnosis for used subjects
metadata.diagnosis_string = cellstr(imageTable.group(iUseFile(iUnique(indexHighQRinUseFolder))));
[La Lb] = ismember(metadata.diagnosis_string, diag);
control = 'Neurotypical';
[iControl ic] = find(strcmp(diag, control));
metadata.diagnosis = Lb;
metadata.diagnosis(Lb==iControl) = 1;
metadata.diagnosis(Lb~=iControl) = 5;
diagString = {'HC', 'BD', 'SCA',...
    'SCZ', 'ASD', 'MDD' };
metadata.diagnosis_string(:,1) = diagString(metadata.diagnosis);
metadata.diagnosis = cellstr(num2str(metadata.diagnosis));


%% check number of subjects
siteCat = unique(metadata.site);
diagCat = unique(metadata.diagnosis);


    for iDiag = 1: length(diagCat) % control and proband in the diag list

        % number of adult subjects in each phenotype in each site
        nSiteDiag( iDiag) = sum( strcmp(metadata.diagnosis, diagCat(iDiag)));

    end

% the site and phenotype has >= NSUB HC subjects
nSiteDiagCondition = nSiteDiag >= NSUB;
nSiteCondition = nSiteDiagCondition(:,1) & any(nSiteDiagCondition(:,2:end),2);
siteCon = siteCat(nSiteCondition);

%%
metadata.con = zeros(size(metadata.subj_id));
for iSite = 1:length(siteCon)
     siteDiag = diagCat(nSiteDiagCondition(iSite,:)); % diag for this site
  
    for iDiag = 2: length(siteDiag) % control and proband in the diag list


        condition = ismember(metadata.site,siteCon(iSite)) & ...
            ismember(metadata.diagnosis, siteDiag([1,iDiag]));

        metadata.con(condition) = 1;

        qdecTable = cell2table([metadata.subj_id(condition), metadata.diagnosis(condition), ...
            metadata.sex(condition), cellstr(num2str(metadata.age(condition)))], "VariableNames",["fsid", "diagnosis",...
            "sex", "age"]);
        writetable(qdecTable,['/projects/kg98/trangc/VBM/data/', study, ...
            '/qdec_table_', char(unique(metadata.site_string(condition))),'_',char(siteDiag(iDiag)),'.dat'],'Delimiter','tab');

    end
end
% metadata.con(ismember(metadata.subj_id,'sub-2467ZEJ')) = 0;% remove sub with wrong site info, see note.txt
metadata.con = logical(metadata.con);
metadata.EN = cellstr(num2str(ENsubHighEN(ismember(subHighEN,metadata.subj_id(metadata.con)))));




%%
metaTable = cell2table([metadata.subj_id(metadata.con), metadata.dataset(metadata.con), ...
    metadata.site(metadata.con), metadata.diagnosis(metadata.con), cellstr(num2str(metadata.age(metadata.con))),...
    metadata.sex(metadata.con), metadata.site_string(metadata.con), metadata.sex_string(metadata.con),...
    metadata.diagnosis_string(metadata.con), metadata.EN], "VariableNames",["subj_id", "dataset", "site", "diagnosis",...
    "age", "sex", "site_string", "sex_string",  "diagnosis_string", "EN" ]);

writetable(metaTable,['/projects/kg98/trangc/VBM/data/', study, '/',study,'_qdec_extended.csv']);
