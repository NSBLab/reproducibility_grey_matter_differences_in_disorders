function runGLM_null_func(datasets,isses, iNull,randomNumber,nParc)
% This script
%   After already smoothing the data, extracting the TIV, and parsing through COMBAT to remove site effects:

%   1. SPM: Basic Models - specific a design matric that explains how the preprocessed
%       data are cause
%   2. SPM: Estiamte - To actually fit the GLM to the data

% Additional steps required not file:///home/trangc/kg98/trangc/VBM/code/data_BIDS/extract_sub_surface_BNIPS.m
%avaliable through batch:
%   3. SPM: Review - to see what is in the design matrix and generally poke about.
%   4. SPM: Results - to identify any significant differences

rng(randomNumber)
addpath(genpath('/projects/kg98/trangc/MBM/func'))
addpath(genpath('/projects/kg98/trangc/MBM/utils'))


% ------------------------------------------------------------
% Prep
% ------------------------------------------------------------
%dataset = 'YMDD'
% smoothData = false
% calculateTIV = false

dataset = char(datasets)


% Directories
inDir = '/projects/kg98/trangc/VBM/data/';
outDir = ['/scratch/kg98/trangc/VBM/data/derivatives/roi/' ,num2str(iNull),'/'];
% TIVDir = [inDir, 'derivatives/s', num2str(smoothKernel),'COMBAT/' ];
% tiv_filename = [TIVDir, dataset, '_TIV_combat.txt']

% Load in metadata
metadataFilename = [inDir, dataset,'/',dataset, '_dems.csv'];
metadata = readtable(metadataFilename, 'delimiter',',');

% Get all the parcelated maps

for i=1:size(metadata,1)
    subj_id = metadata.subj_id{i}
    if isses == 1
        ses = metadata.ses{i}
        subNifti = [inDir,dataset,'/',subj_id,'/',ses,'/anat/','mwp1',subj_id,'_',ses,'_T1w_Buckner-whole_1mm_Tian_Subcortex_S1_3T_2009cAsym_Schaefer2018_',char(num2str(nParc)),'Parcels_7Networks_order_CAT12MNI.mat'];

    else
        subNifti = [inDir,dataset,'/',subj_id,'/anat/','mwp1',subj_id,'_T1w_Buckner-whole_1mm_Tian_Subcortex_S1_3T_2009cAsym_Schaefer2018_',char(num2str(nParc)),'Parcels_7Networks_order_CAT12MNI.mat'];

    end
    parMap = load(subNifti);
    subNifti_cell(i,:) = parMap.volParc;


end
% % Get list of preprocessed nifti images and cat12 reports
% subNifti_cell = {}
% subReport_cell = {}
%
% for i=1:size(metadata,1)
%     subj_id = metadata.subj_id{i}
%     if isses == 1
%         ses = metadata.ses{i};
%         subNifti = [inDir,dataset,'/',subj_id,'/',ses,'/anat/mwp1',subj_id,'_', ses,'_T1w.nii'];
%         subReport = [inDir,dataset,'/',subj_id,'/',ses,'/anat/cat_',subj_id,'_', ses, '_T1w.xml'];
%     else
%         subNifti = [inDir,dataset,'/',subj_id,'/anat/mwp1',subj_id, '_T1w.nii'];
%         subReport = [inDir,dataset,'/',subj_id,'/anat/cat_',subj_id, '_T1w.xml'];
%     end
%     subNifti_cell{i} = subNifti;
%     subReport_cell{i} = subReport;
%
% end
%
% subNifti_cell = subNifti_cell' ;% transpose so its in the correct format for functions
% subReport_cell = subReport_cell';

%  % Smooth nifti images
% if smoothData == 1
%     smooth_job(subNifti_cell, smoothKernel)
% end
%
% % Calculate TIV
% if calculateTIV == 1
%
%     estimate_tiv_job(subReport_cell, tiv_filename)
% end

% ------------------------------------------------------------
% Build the Model
% ------------------------------------------------------------

% Read in tiv
tiv_filename = [inDir, 'derivatives/roi/', dataset, '_TIV.txt']

tiv = readtable(tiv_filename,'ReadVariableNames',false);
tiv_all = table2array(tiv);

% %Get nifti smooth file names
% subNiftiSmooth_cell = {};
%
% for i=1:size(metadata,1)
%     subj_id = metadata.subj_id{i};
%     if isses == 1
%         ses = metadata.ses{i};
%         subNiftiSmooth = [inDir,dataset,'/',subj_id,'/', ses,'/anat/s',num2str(smoothKernel),'mwp1',subj_id,'_', ses, '_T1w_combat.nii'];
%     else
%         subNiftiSmooth = [inDir,dataset,'/',subj_id,'/anat/s',num2str(smoothKernel),'mwp1',subj_id, '_T1w_combat.nii'];
%     end
%     subNiftiSmooth_cell{i} = subNiftiSmooth;
%
% end
%
% subNiftiSmooth_cell = subNiftiSmooth_cell';


% Prepare to run model for each specific site
numCovs = 4;

unique_siteIDs = unique(metadata.site);
numSite = size(unique_siteIDs,1);

for s = 1:numSite

    % Get a list of all smoothed hc niftis from site X
    hcCell = subNifti_cell(metadata.diagnosis==1 & metadata.site == unique_siteIDs(s),:);

    % Prepare hc covariates
    hc_covs = ones(size(hcCell,1),numCovs);
    hc_covs(:,2) = metadata.age(metadata.diagnosis==1 & metadata.site == unique_siteIDs(s));
    hc_covs(:,3) = metadata.sex(metadata.diagnosis==1 & metadata.site == unique_siteIDs(s));
    hc_covs(:,4) = tiv_all(metadata.diagnosis==1 & metadata.site == unique_siteIDs(s));

    % Get a list of the unique diagnoses
    patients = metadata(metadata.diagnosis~=1 & metadata.site == unique_siteIDs(s),:);
    unique_patIDs = unique(patients.diagnosis);
    numPatGroups = size(unique_patIDs,1);

    for i=1:numPatGroups % For each unique patient group
        patCell = subNifti_cell(metadata.diagnosis==unique_patIDs(i) & metadata.site == unique_siteIDs(s),:);
        combineCell = [hcCell; patCell];
        combineIndex = 1:height(combineCell);
        controlIndex = randperm(height(combineCell),height(hcCell));
        patIndex = combineIndex(~ismember(combineIndex,controlIndex));
        hcNullCell = combineCell(controlIndex);
        patNullCell = combineCell(patIndex);
        % Preoare patient covariates
        pat_covs = 2*ones(size(patCell,1),numCovs);
        pat_covs(:,2) = metadata.age(metadata.diagnosis==unique_patIDs(i) & metadata.site == unique_siteIDs(s));
        pat_covs(:,3) = metadata.sex(metadata.diagnosis==unique_patIDs(i) & metadata.site == unique_siteIDs(s));
        pat_covs(:,4) = tiv_all(metadata.diagnosis==unique_patIDs(i) & metadata.site == unique_siteIDs(s));

        % Concat hc and pat covariates
        covariates = [hc_covs; pat_covs];
        covariates = covariates([controlIndex,patIndex],:);
        inputMap = [hcCell; patCell];
        inputMap = inputMap([controlIndex,patIndex],:);
        % Define each covariate
        % age = covariates(:,2);
        % sex = covariates(:,3);
        % tiv = covariates(:,4);

        % The name of the specific site we running the model on
        siteName = metadata.site_string(metadata.site==unique_siteIDs(s));
        siteName = char(siteName(1));

        % The diagnostic category of diagnosis we are running for model on
        diagnosisName = metadata.diagnosis_string(metadata.diagnosis==unique_patIDs(i));
        diagnosisName = char(diagnosisName(1));

        % The output folder
        %newSubFolder = [outDir,siteName,'/',diagnosisName];
        newSubFolder = [outDir,diagnosisName,'/',siteName];


        % file1 = ([newSubFolder,'/spmT_0001.nii']);
        % if ~isfile(file1)

        % file1
        if ~exist(newSubFolder, 'dir')
            mkdir(newSubFolder); % Create new output directory for model output
        end
        % delete([newSubFolder,'/SPM.mat']);

        %  'Basic Models' - Specify Design matrix
        % factorial_design_ttest_combat_job(newSubFolder, hcNullCell, patNullCell, age, sex, tiv, TIVDir);
        stat.test = 'ANCOVA';
        stat.designMatrix = covariates;
        stat.nPer = 1000;
        stat.pThr = 0.1;
        stat.thres = 0.05;
        stat.fdr = false;

        % calculate statistical map
        stat.statMap = mbm_stat_map(inputMap, stat);

        % permutation tests on the statitical map
        [statMapNull, stat] = mbm_perm_test_map(inputMap, stat);


        % thresholded map
        stat.thresMap = zeros(size(stat.pMap));
        stat.thresMap(stat.pMap <= stat.thres) = 1;
        save(fullfile(newSubFolder,[char(num2str(nParc)),'_parcCon.mat']),'stat');

    end
end
end
