function runGLM_func(datasets,isses,nParc)
% This script
%   1.SPM: Smooth (8mm) - voxel intensities become a weighted average of the
%       surrounding voxels. This is required to render the data more normally
%       distributed and to correct for some error in the registration process.
%   2. SPM: Estimate TIV - Total intracanial volume(TIV) interates GM, VM, and
%       CSF, or attempts to measure the skull volume directly. TIV is modelled
%       as a confounding parameter. Note: We want it to be orthogonal
%       (independent) to any other parameter of interest (ie no correlation).
%       Othwewise not only the ariance explained by TIV is removed from your
%       data, but also parts of the variance of your parameter of interest.
%       The larger the correlation between TIV and any parameter of interest
%       the more the need to not use TIV as nuisance parameter. In this case
%       an alternative approach is to use global scaling with TIV.
%   3. SPM: Basic Models - specific a design matric that explains how the preprocessed
%       data are cause
%   5. SPM: Estiamte - To actually fit the GLM to the data

% Additional steps required not avaliable through batch:
%   4. SPM: Review - to see what is in the design matrix and generally poke about.
%   6. SPM: Results - to identify any significant differences and to generate tmap files



rng('default')
addpath('/projects/kg98/trangc/MBM/func')
addpath('/projects/kg98/trangc/MBM/utils')
addpath('/projects/kg98/trangc/MBM/utils/gifti-matlab')
addpath('/projects/kg98/trangc/MBM/utils/PALM-master')
addpath('/projects/kg98/trangc/MBM/utils/fdr_bh')

% ------------------------------------------------------------
% Prep
% ------------------------------------------------------------
%dataset = 'YMDD'

dataset = char(datasets)

% Directories
inDir = '/projects/kg98/trangc/VBM/data/';
outDir = [inDir, 'derivatives/roi/' ];

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

% subNifti_cell = subNifti_cell' % transpose so its in the correct format for functions




% ------------------------------------------------------------
% Build the Model
% ------------------------------------------------------------

% Read in tiv
tiv_filename = [outDir, dataset, '_TIV.txt']
if ~exist(tiv_filename)
    copyfile([inDir,'derivatives/s6/',dataset,'_TIV.txt'], [outDir, dataset, '_TIV.txt']);
end
tiv = readtable(tiv_filename,'ReadVariableNames',false);
tiv_all = table2array(tiv);



% Prepare to run model for each specific site
numCovs = 4

unique_siteIDs = unique(metadata.site)
numSite = size(unique_siteIDs,1)

for s = 1:numSite

    % Get a list of all smoothed hc niftis from site X
    hcCell = subNifti_cell(metadata.diagnosis==1 & metadata.site == unique_siteIDs(s),:)

    % Prepare hc covariates
    hc_covs = ones(size(hcCell,1),numCovs)

    hc_covs(:,2) = metadata.age(metadata.diagnosis==1 & metadata.site == unique_siteIDs(s))
    hc_covs(:,3) = metadata.sex(metadata.diagnosis==1 & metadata.site == unique_siteIDs(s))
    hc_covs(:,4) = tiv_all(metadata.diagnosis==1 & metadata.site == unique_siteIDs(s))

    % Get a list of the unique diagnoses
    patients = metadata(metadata.diagnosis~=1 & metadata.site == unique_siteIDs(s),:)
    unique_patIDs = unique(patients.diagnosis)
    numPatGroups = size(unique_patIDs,1)

    for i=1:numPatGroups % For each unique patient group
        patCell = subNifti_cell(metadata.diagnosis==unique_patIDs(i) & metadata.site == unique_siteIDs(s),:)

        % Preoare patient covariates
        pat_covs = zeros(size(patCell,1),numCovs)
        pat_covs(:,2) = metadata.age(metadata.diagnosis==unique_patIDs(i) & metadata.site == unique_siteIDs(s))
        pat_covs(:,3) = metadata.sex(metadata.diagnosis==unique_patIDs(i) & metadata.site == unique_siteIDs(s))
        pat_covs(:,4) = tiv_all(metadata.diagnosis==unique_patIDs(i) & metadata.site == unique_siteIDs(s))

        % Concat hc and pat covariates
        covariates = [hc_covs; pat_covs];
        inputMap = [hcCell; patCell];
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

        if ~exist(newSubFolder, 'dir')
            mkdir(newSubFolder); % Create new output directory for model output
        end

        % %  'Basic Models' - Specify Design matrix
        % stat.test = 'ANCOVA';
        % stat.designMatrix = covariates;
        % stat.nPer = 100;
        % stat.pThr = 0.1;
        stat.thres = 0.05;
        % stat.fdr = false;
        %
        % % calculate statistical map
        % stat.statMap = mbm_stat_map(inputMap, stat);
        %
        % % permutation tests on the statitical map
        % [statMapNull, stat] = mbm_perm_test_map(inputMap, stat);



        % Perform regression (controlling for age & sex)
        % X = [ones(size(age)) age sex]; % Design matrix with covariates
        for iRoi = 1:size(inputMap,2)
            mdl = fitlm(covariates,inputMap(:,iRoi));

            
            % Calculate the t-statistics
            stat.tMap(iRoi) = mdl.Coefficients.tStat(2);
            pValue(iRoi) = mdl.Coefficients.pValue(2);
        end
        % thresholded map
        stat.thresMap = zeros(size(stat.tMap));
        stat.thresMap(pValue <= stat.thres) = 1;
        save(fullfile(newSubFolder,[char(num2str(nParc)),'_parcCon.mat']),'stat');

    end
end
end
