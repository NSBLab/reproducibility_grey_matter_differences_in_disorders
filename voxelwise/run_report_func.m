function run_report_func(datasets,isses,smoothKernel)



dataset = char(datasets)

% Directories
inDir = '/projects/kg98/trangc/VBM/data/';
outDir = [inDir, 'derivatives/s', num2str(smoothKernel),'/' ];

% Load in metadata
metadataFilename = [inDir, dataset,'/',dataset, '_dems.csv'];
metadata = readtable(metadataFilename, 'delimiter',',');

% % Get list of preprocessed nifti images and cat12 reports
% subNifti_cell = {}
% subReport_cell = {}
% 
% for i=1:size(metadata,1)
%     subj_id = metadata.subj_id{i}
%     if isses == 1
%         ses = metadata.ses{i}
%         subNifti = [inDir,dataset,'/',subj_id,'/',ses,'/anat/mwp1',subj_id,'_', ses,'_T1w.nii'];
%         subReport = [inDir,dataset,'/',subj_id,'/',ses,'/anat/cat_',subj_id,'_', ses, '_T1w.xml'];
%     else
%         subNifti = [inDir,dataset,'/',subj_id,'/anat/mwp1',subj_id, '_T1w.nii'];
%         subReport = [inDir,dataset,'/',subj_id,'/anat/cat_',subj_id, '_T1w.xml'];
%     end
% 
%     subNifti_cell{i} = subNifti
%     subReport_cell{i} = subReport
% 
% end
% 
% subNifti_cell = subNifti_cell' % transpose so its in the correct format for functions
% subReport_cell = subReport_cell'
% 
% % Smooth nifti images
% if smoothData == 1
%     smooth_job(subNifti_cell, smoothKernel)
% end
% 
% % Calculate TIV
%     tiv_filename = [outDir, dataset, '_TIV.txt']
% if calculateTIV == 1
% 
%     estimate_tiv_job(subReport_cell, tiv_filename)
% end
% 
% % ------------------------------------------------------------
% % Build the Model
% % ------------------------------------------------------------
% 
% % Read in tiv
% tiv = readtable(tiv_filename,'ReadVariableNames',false);
% tiv_all = table2array(tiv);
% 
% %Get nifti smooth file names
% subNiftiSmooth_cell = {}
% 
% for i=1:size(metadata,1)
%     subj_id = metadata.subj_id{i}
%     if isses == 1
%         ses = metadata.ses{i}
%         subNiftiSmooth = [inDir,dataset,'/',subj_id,'/', ses,'/anat/s',num2str(smoothKernel),'mwp1',subj_id,'_', ses, '_T1w.nii'];
%     else
%         subNiftiSmooth = [inDir,dataset,'/',subj_id,'/anat/s',num2str(smoothKernel),'mwp1',subj_id, '_T1w.nii'];
%     end
% 
%     subNiftiSmooth_cell{i} = subNiftiSmooth
% 
% end
% 
% subNiftiSmooth_cell = subNiftiSmooth_cell'


% Prepare to run model for each specific site
% numCovs = 3

unique_siteIDs = unique(metadata.site)
numSite = size(unique_siteIDs,1)

for s = 1:numSite
    % 
    % % Get a list of all smoothed hc niftis from site X
    % hcCell = subNiftiSmooth_cell(metadata.diagnosis==1 & metadata.site == unique_siteIDs(s))
    % 
    % % Prepare hc covariates
    % hc_covs = zeros(size(hcCell,1),numCovs)
    % hc_covs(:,1) = metadata.age(metadata.diagnosis==1 & metadata.site == unique_siteIDs(s))
    % hc_covs(:,2) = metadata.sex(metadata.diagnosis==1 & metadata.site == unique_siteIDs(s))
    % hc_covs(:,3) = tiv_all(metadata.diagnosis==1 & metadata.site == unique_siteIDs(s))
    
    % Get a list of the unique diagnoses
    patients = metadata(metadata.diagnosis~=1 & metadata.site == unique_siteIDs(s),:)
    unique_patIDs = unique(patients.diagnosis)
    numPatGroups = size(unique_patIDs,1)
    
    for i=1:numPatGroups % For each unique patient group
        % patCell = subNiftiSmooth_cell(metadata.diagnosis==unique_patIDs(i) & metadata.site == unique_siteIDs(s))
        % 
        % % Preoare patient covariates
        % pat_covs = zeros(size(patCell,1),numCovs)
        % pat_covs(:,1) = metadata.age(metadata.diagnosis==unique_patIDs(i) & metadata.site == unique_siteIDs(s))
        % pat_covs(:,2) = metadata.sex(metadata.diagnosis==unique_patIDs(i) & metadata.site == unique_siteIDs(s))
        % pat_covs(:,3) = tiv_all(metadata.diagnosis==unique_patIDs(i) & metadata.site == unique_siteIDs(s))
        % 
        % % Concat hc and pat covariates
        % covariates = [hc_covs; pat_covs]
        % 
        % % Define each covariate
        % age = covariates(:,1)
        % sex = covariates(:,2)
        % tiv = covariates(:,3)
        
        % The name of the specific site we running the model on
        siteName = metadata.site_string(metadata.site==unique_siteIDs(s))
        siteName = char(siteName(1))
        
        % The diagnostic category of diagnosis we are running for model on
        diagnosisName = metadata.diagnosis_string(metadata.diagnosis==unique_patIDs(i))
        diagnosisName = char(diagnosisName(1))
        
        % The output folder
        %newSubFolder = [outDir,siteName,'/',diagnosisName];
        newSubFolder = [outDir,diagnosisName,'/',siteName];

        
        % 'Estimate' - To fit the GLM to the data
        spm_file = [newSubFolder, '/SPM.mat'];
  
        % contr_job(spm_file)
spm('defaults', 'PET');
report_thres_job(spm_file)
addpath('/projects/kg98/trangc/VBM/code/voxelwise')
report_fwe_job(spm_file)
    end
end
end
