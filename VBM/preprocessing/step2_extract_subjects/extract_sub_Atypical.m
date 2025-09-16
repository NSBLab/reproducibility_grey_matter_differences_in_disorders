%% read demographic information and extract subjects that satisfy criteria:
% - age: 18-60
% - each site has at least 20 subjects

% Trang Cao, Neural Systems and Behaviour Lab, Monash University, 2022.

clear all
close all

study = 'Atypical';

% define const
LOWAGE = 18*12; % lower bound of age
UPAGE = 60*12; % upper bound of age
NSUB = 20; % lowest number of subject per site per phenotype

% read demographic files
imageFile = tdfread(['/projects/kg98/trangc/VBM/data/', study, '/image03.txt']);


imageFile.interview_age = str2double(string(imageFile.interview_age(2:end,:)));
[imageFile.interview_age iTimeOrder] = sort(imageFile.interview_age);
imageFile.scan_type = cellstr(imageFile.scan_type(2:end,:));
imageFile.scan_type = imageFile.scan_type(iTimeOrder,:);
imageFile.image_file = cellstr(imageFile.image_file(2:end,:));
imageFile.image_file = imageFile.image_file(iTimeOrder,:);
imageFile.src_subject_id = cellstr(imageFile.src_subject_id(2:end,:));
imageFile.src_subject_id = imageFile.src_subject_id(iTimeOrder,:);
imageFile.sex = cellstr(imageFile.sex(2:end,:));
imageFile.sex = imageFile.sex(iTimeOrder,:);

diagFile = tdfread(['/projects/kg98/trangc/VBM/data/', study, '/ndar_subject01.txt']);

diagFile.phenotype = cellstr(diagFile.phenotype(2:end,:));
diagFile.src_subject_id = cellstr(diagFile.src_subject_id(2:end,:));

descriptionList = {'MR structural (T1)', 'MR structural (MPRAGE)'};

imageFile.useDescription = ismember(imageFile.scan_type, descriptionList) ;

% image filename
% pat1 = ("AD"+ wildcardPattern + ".nhdr")|("submission"+ wildcardPattern + "NDA"+ wildcardPattern + ".zip")|("SAG"+ wildcardPattern + ".nii.gz")|("MP"+ wildcardPattern + ".nii.gz")|("_MP"+ wildcardPattern + ".nii.gz")|("_SAG"+ wildcardPattern + ".nii.gz");
pat1 = "submission"+ wildcardPattern + (".nhdr"|".zip"|".nii.gz");
filenameWithPattern = cellstr(extract(imageFile.image_file(imageFile.useDescription),pat1));
filename = char(extract(filenameWithPattern,"/"+ wildcardPattern+ (".nhdr"|".zip"|".nii.gz")));
fileSes = contains(cellstr(filename),'working');
imageFile.fileSes = logical(zeros(size(imageFile.useDescription)));
imageFile.fileSes(imageFile.useDescription) = fileSes;
imageFile.filename(imageFile.fileSes,1:size(filename,2)-1) = filename(fileSes,2:end);

% imageFile.useDescription = imageFile.useDescription & imageFile.fileSes; %remove this to get all the subject suitable but use this to get the nii.gz files from ealiest scans.
% folder name
imageFile.folderName = "sub-" + imageFile.src_subject_id;
% subject in the age range 18-60 at scanning time
imageFile.adult = imageFile.interview_age >= LOWAGE & imageFile.interview_age <= UPAGE;
adult.ID = unique(imageFile.src_subject_id(imageFile.adult == 1));

% list of sites and diagnose
[diag, ~, indexDiag] = unique(diagFile.phenotype);
nDiag = size(diag,1); 
control = 'typically developing control';
 [iControl ic] = find(strcmp(diag, control));


for iDiag = 1: nDiag % control and proband in the diag list
    
% adult patients
condition = ismember(adult.ID, diagFile.src_subject_id(indexDiag == iDiag));
% number of adult patients
nSubPerPhenotypePerSite(iDiag) = sum(condition);

end




% the site and phenotype has >= NSUB HC subjects
siteSizeCondition = nSubPerPhenotypePerSite >= NSUB;

adult.use =  zeros(size(adult.ID));
for iDiag = 1:length(diag)
            
            if siteSizeCondition(iDiag) == 1
                
                % adult subjects in each phenotype in each site
                condition = ismember(adult.ID,...
            diagFile.src_subject_id(indexDiag == iDiag));
                adult.use(condition) = 1;
            end
            
        end

% extract image filename satisfying: ID of usable subjects and
% scan_type in the list

useID = adult.ID(adult.use==1);
imageFile.useID = ismember(imageFile.src_subject_id,useID);




imageFile.useFile = imageFile.useID == 1 & imageFile.useDescription == 1;
[iUseFile col va] = find(imageFile.useFile);

idUse = imageFile.src_subject_id(iUseFile);
[useSub iUnique iID] = unique(idUse);

useFile(:,1) = cellstr(imageFile.filename(iUseFile(iUnique),:));
useFolder = cellstr(imageFile.folderName(iUseFile(iUnique),:));

% writelines(append(useFolder, useFile), ['/projects/kg98/trangc/VBM/data/', study, '/useFile.txt']);
% writelines(useFolder, ['/projects/kg98/trangc/VBM/data/', study, '/subject_use_extract.txt']);

%%
% create metadata
IQRthres = 2.8;
% read cat report
catFile = readtable(['/projects/kg98/trangc/VBM/data/', study, '/cat12_qcReport_', study, '.txt']);
subHighQR = catFile.Var1(catFile.Var2 <= IQRthres);

[La indexHighQRinUseFolder] = ismember(subHighQR, useFolder); % index in use Folder is same as in iUnique

metadata.subj_id = cellstr(useFolder(indexHighQRinUseFolder));
metadata.dataset = cellstr(repmat(study,size(indexHighQRinUseFolder)));
metadata.site = cellstr(repmat('22',size(indexHighQRinUseFolder)));
metadata.site_string = metadata.dataset;
metadata.age = cellstr(num2str(round(imageFile.interview_age(iUseFile(iUnique(indexHighQRinUseFolder)))./12)));
metadata.sex_string = cellstr(imageFile.sex(iUseFile(iUnique(indexHighQRinUseFolder))));
metadata.sex = cellstr(num2str(strcmp(metadata.sex_string,'M')));

% find diagnosis for used subjects
[La Lb] = ismember(imageFile.src_subject_id(iUseFile(iUnique(indexHighQRinUseFolder))), diagFile.src_subject_id);
metadata.diagnosis_string = cellstr(diagFile.phenotype(Lb));
metadata.diagnosis = double(strcmp(metadata.diagnosis_string, 'typically developing control'));
metadata.diagnosis(metadata.diagnosis==0) = 5;

diagString = {'Healthy Control', 'Bipolar disorder', 'Schizoaffective Disorder',...
    'Schizophrenia', 'Autistic Spectrum Disorders', 'Major depressive disorder' };
metadata.diagnosis_string(:,1) = diagString(metadata.diagnosis);
metadata.diagnosis = cellstr(num2str(metadata.diagnosis));

diagCat = unique(metadata.diagnosis);
for iDiag = 1:length(diagCat)
nSiteDiag(iDiag) = sum(strcmp(metadata.diagnosis, diagCat(iDiag)));
end

metadata.con = logical(ones(size(metadata.subj_id)));
%% CAT
[La Lb] = ismember(metadata.subj_id(metadata.con), catFile.Var1);
metadata.CAT = cellstr(num2str(catFile.Var2(Lb)));

%%
metaTable = cell2table([metadata.subj_id(metadata.con), metadata.dataset(metadata.con), ...
    metadata.site(metadata.con), metadata.diagnosis(metadata.con), metadata.age(metadata.con),...
    metadata.sex(metadata.con), metadata.site_string(metadata.con), metadata.sex_string(metadata.con),...
    metadata.diagnosis_string(metadata.con), metadata.CAT], "VariableNames",["subj_id", "dataset", "site", "diagnosis",...
    "age", "sex", "site_string", "sex_string",  "diagnosis_string", "CAT" ]);

writetable(metaTable,['/projects/kg98/trangc/VBM/data/', study, '/',study,'_dems_extended.csv']);



