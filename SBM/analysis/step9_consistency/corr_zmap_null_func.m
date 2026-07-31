function corr_zmap_null_func(config, iNull, iCOMBAT, hemi, smoothKernel)
if nargin < 2
    error('Usage: corr_zmap_null_func(config, iNull, iCOMBAT, hemi, smoothKernel)');
end
this_dir = fileparts(mfilename('fullpath'));
repo_root = fullfile(this_dir, '..', '..', '..');
addpath(this_dir);
addpath(genpath(fullfile(repo_root, 'utils')));
if ischar(config) || isstring(config)
    config = pipeline_load_config(char(config));
end
% list of disorders
diagString = {'HC', 'BD', 'SCA',...
    'SCZ', 'ASD', 'MDD' ,'AD'};
% load(['eigenStruct_',hemi,'.mat']); %load structure that contains eigentrapping because the mask was changed to fix the 164k mesh error


dataDir = config.data_directories.dataset_root;
iCOMBAT = local_default(iCOMBAT, config.analysis_settings.harmonize);
hemi = char(local_default(hemi, 'lh'));
smoothKernel = local_default(smoothKernel, config.analysis_settings.sbm_smoothing_kernel);

% iCOMBAT = 1;
measureShort = 'thick';
measure = 'thickness';
% hemi = 'rh';
% smoothKernel = 10;
thres=0.05;
nNull = 1000;

% find all sites
datadir = fullfile(dataDir, 'derivatives', 'eigentrap');
datasets = dir(datadir);
datasets = datasets(~ismember({datasets.name}, {'.', '..'})); % Exclude '.' and '..'


%%
% for iNull = 1:nNull
    iItem = 1;
    for iSite = 1:length(datasets)
        datasets(iSite).name
        % parcfiles = dir(fullfile(datadir,datasets(iSite).name,['parcMap_qdec_table_*','_combat',char(num2str(iCOMBAT)),'_',hemi,'_smooth',char(num2str(smoothKernel)),'*.mat']));
        verfiles = dir(fullfile(datadir,datasets(iSite).name,['verMap_qdec_table_*','_combat',char(num2str(iCOMBAT)),'_',hemi,'_smooth',char(num2str(smoothKernel)),'*.mat']));
        % parcThresfiles = dir(fullfile(datadir,datasets(iSite).name,['parcThresMap_qdec_table_*','_combat',char(num2str(iCOMBAT)),'_',hemi,'_smooth',char(num2str(smoothKernel)),'*.mat']));
        verThresfiles = dir(fullfile(datadir,datasets(iSite).name,['verThresMap_qdec_table_*','_combat',char(num2str(iCOMBAT)),'_',hemi,'_smooth',char(num2str(smoothKernel)),'*.mat']));
        for iFile = 1:length(verfiles)
            % load(fullfile(datadir,datasets(iSite).name,parcfiles(iFile).name), "zmapSurrsSF100","zmapSurrsSF500","zmapSurrsSF1000","zmapSurrsDK");
            load(fullfile(datadir,datasets(iSite).name,verfiles(iFile).name), "zmapSurrsVer");
            %
            % % load(fullfile(datadir,datasets(iSite).name,parcThresfiles(iFile).name), "sigmapSurrsSF100","sigmapSurrsSF500","sigmapSurrsSF1000","sigmapSurrsDK");
            load(fullfile(datadir,datasets(iSite).name,verThresfiles(iFile).name),  "sigmapSurrsHC_PVer", "sigmapSurrsP_HCVer","sigFdrmapSurrsHC_PVer","sigFdrmapSurrsP_HCVer","sigClustermapSurrsHC_PVer","sigClustermapSurrsP_HCVer");


            zmapSurrsVerAll(:,iItem) = zmapSurrsVer(:,iNull);


               sigmapSurrsHC_PVerAll(:,iItem) = sigmapSurrsHC_PVer(:,iNull);
            sigmapSurrsP_HCVerAll(:,iItem) = sigmapSurrsP_HCVer(:,iNull);
            sigFdrmapSurrsHC_PVerAll(:,iItem) = sigFdrmapSurrsHC_PVer(:,iNull);
            sigFdrmapSurrsP_HCVerAll(:,iItem) = sigFdrmapSurrsP_HCVer(:,iNull);
            sigClustermapSurrsHC_PVerAll(:,iItem) = sigClustermapSurrsHC_PVer(:,iNull);
            sigClustermapSurrsP_HCVerAll(:,iItem) = sigClustermapSurrsP_HCVer(:,iNull);

            % find site name
            % Split the string using '_' as the delimiter
            parts = strsplit(verfiles(iFile).name, '_');

            % Check if there are at least two parts
            if numel(parts) >9
                % Extract the substring between the first and second underscores
                map.diag{iItem} = parts{6};
            else
                % Handle the case where there are not enough underscores
                map.diag{iItem} = parts{5};
            end
            map.site{iItem} = datasets(iSite).name;
            % isDiagSite = strcmp( map.diag{iItem} , num2str((iDiag+1)));

            iItem=iItem+1;
        end

    end
    nDiag = length(diagString) - 1;
    corzmapSurrsVer = cell(1, nDiag);
    corsigmapSurrsHC_PVer = cell(1, nDiag);
    corsigmapSurrsP_HCVer = cell(1, nDiag);
    corsigFdrmapSurrsHC_PVer = cell(1, nDiag);
    corsigFdrmapSurrsP_HCVer = cell(1, nDiag);
    corsigClustermapSurrsHC_PVer = cell(1, nDiag);
    corsigClustermapSurrsP_HCVer = cell(1, nDiag);
    repsigmapSurrsHC_PVer = cell(1, nDiag);
    repsigmapSurrsP_HCVer = cell(1, nDiag);
    repsigFdrmapSurrsHC_PVer = cell(1, nDiag);
    repsigFdrmapSurrsP_HCVer = cell(1, nDiag);
    repsigClustermapSurrsHC_PVer = cell(1, nDiag);
    repsigClustermapSurrsP_HCVer = cell(1, nDiag);

    for iDiag = 1:nDiag
        isDiagSite = strcmp(map.diag, num2str(iDiag + 1));
        nDiagSites = sum(isDiagSite);
        if nDiagSites < 2
            fprintf('Skipping %s (diag=%d): found %d site(s); need >=2 to compute correlation.\n', ...
                diagString{iDiag + 1}, iDiag + 1, nDiagSites);
            continue;
        end

        corzmapSurrsVer{iDiag} = corr(squeeze(zmapSurrsVerAll(:,isDiagSite)));
        corsigmapSurrsHC_PVer{iDiag} = bin_corr_mat_account_zero(squeeze(sigmapSurrsHC_PVerAll(:,isDiagSite)));
        corsigmapSurrsP_HCVer{iDiag} = bin_corr_mat_account_zero(squeeze(sigmapSurrsP_HCVerAll(:,isDiagSite)));
        corsigFdrmapSurrsHC_PVer{iDiag} = bin_corr_mat_account_zero(squeeze(sigFdrmapSurrsHC_PVerAll(:,isDiagSite)));
        corsigFdrmapSurrsP_HCVer{iDiag} = bin_corr_mat_account_zero(squeeze(sigFdrmapSurrsP_HCVerAll(:,isDiagSite)));
        corsigClustermapSurrsHC_PVer{iDiag} = bin_corr_mat_account_zero(squeeze(sigClustermapSurrsHC_PVerAll(:,isDiagSite)));
        corsigClustermapSurrsP_HCVer{iDiag} = bin_corr_mat_account_zero(squeeze(sigClustermapSurrsP_HCVerAll(:,isDiagSite)));

        repsigmapSurrsHC_PVer{iDiag} = replication_mat(squeeze(sigmapSurrsHC_PVerAll(:,isDiagSite)));
        repsigmapSurrsP_HCVer{iDiag} = replication_mat(squeeze(sigmapSurrsP_HCVerAll(:,isDiagSite)));
        repsigFdrmapSurrsHC_PVer{iDiag} = replication_mat(squeeze(sigFdrmapSurrsHC_PVerAll(:,isDiagSite)));
        repsigFdrmapSurrsP_HCVer{iDiag} = replication_mat(squeeze(sigFdrmapSurrsP_HCVerAll(:,isDiagSite)));
        repsigClustermapSurrsHC_PVer{iDiag} = replication_mat(squeeze(sigClustermapSurrsHC_PVerAll(:,isDiagSite)));
        repsigClustermapSurrsP_HCVer{iDiag} = replication_mat(squeeze(sigClustermapSurrsP_HCVerAll(:,isDiagSite)));
    end
    clear zmapSurrsVerAll sigmapSurrsHC_PVerAll sigmapSurrsP_HCVerAll sigFdrmapSurrsHC_PVerAll sigFdrmapSurrsP_HCVerAll sigClustermapSurrsHC_PVerAll sigClustermapSurrsP_HCVerAll
% end

%%
output_dir = fullfile(dataDir, 'results', 'SBM', 'analysis', 'output');
if ~exist(output_dir, 'dir'); mkdir(output_dir); end
save(fullfile(output_dir, ['zmap_null_COMBAT',char(num2str(iCOMBAT)),'_',hemi,'_smooth',char(num2str(smoothKernel)),'_ver_part_',char(num2str(iNull)),'.mat']),...
    'corzmapSurrsVer',  'corsigmapSurrsHC_PVer','corsigmapSurrsP_HCVer','corsigFdrmapSurrsHC_PVer','corsigFdrmapSurrsP_HCVer','corsigClustermapSurrsHC_PVer','corsigClustermapSurrsP_HCVer', ...
    'repsigmapSurrsHC_PVer','repsigmapSurrsP_HCVer','repsigFdrmapSurrsHC_PVer','repsigFdrmapSurrsP_HCVer','repsigClustermapSurrsHC_PVer','repsigClustermapSurrsP_HCVer');
end

function out = local_default(value, fallback)
if nargin < 1 || isempty(value)
    out = fallback;
else
    out = value;
end
end