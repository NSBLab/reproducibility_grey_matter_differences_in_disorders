function step9d_corr_zmap_null_combine(config, hemi, iCOMBAT, smoothKernel, nNull)
% read all the z-maps and correlate them
if nargin < 1 || isempty(config)
    config = 'config_hpc.json';
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


% list of dataset
dataDir = config.data_directories.dataset_root;

if nargin < 3 || isempty(iCOMBAT); iCOMBAT = config.analysis_settings.harmonize; end
measureShort = 'thick';
measure = 'thickness';
if nargin < 2 || isempty(hemi); hemi = 'lh'; end
if nargin < 4 || isempty(smoothKernel); smoothKernel = config.analysis_settings.sbm_smoothing_kernel; end
thres=0.05;
if nargin < 5 || isempty(nNull); nNull = 1000; end

% find all sites
datadir = fullfile(dataDir, 'derivatives', 'eigentrap');
datasets = dir(datadir);
datasets = datasets(~ismember({datasets.name}, {'.', '..'})); % Exclude '.' and '..'



%%

corzmapSurrsVerAll = cell(1,6);

corsigmapSurrsHC_PVerAll = cell(1,6);

corsigmapSurrsP_HCVerAll = cell(1,6);

corsigFdrmapSurrsHC_PVerAll = cell(1,6);

corsigFdrmapSurrsP_HCVerAll = cell(1,6);

corsigClustermapSurrsHC_PVerAll = cell(1,6);

corsigClustermapSurrsP_HCVerAll = cell(1,6);

repsigmapSurrsHC_PVerAll = cell(1,6);

repsigmapSurrsP_HCVerAll = cell(1,6);

repsigFdrmapSurrsHC_PVerAll = cell(1,6);

repsigFdrmapSurrsP_HCVerAll = cell(1,6);

repsigClustermapSurrsHC_PVerAll = cell(1,6);

repsigClustermapSurrsP_HCVerAll = cell(1,6);
%%
for iDiag = 1:length(diagString)-1

    for iNull = 1:nNull
        iNull
        % if iCOMBAT == 1 & strcmp(hemi,'lh') & smoothKernel == 10
            output_dir = fullfile(dataDir, 'results', 'SBM', 'analysis', 'output');
            data=load(fullfile(output_dir, ['zmap_null_COMBAT',num2str(iCOMBAT),'_',hemi,'_smooth',num2str(smoothKernel),'_ver_part_',char(num2str(iNull)),'.mat']), ...
                'corzmapSurrsVer', 'corsigmapSurrsHC_PVer','corsigmapSurrsP_HCVer','corsigFdrmapSurrsHC_PVer','corsigFdrmapSurrsP_HCVer','corsigClustermapSurrsHC_PVer','corsigClustermapSurrsP_HCVer', ...
                'repsigmapSurrsHC_PVer','repsigmapSurrsP_HCVer','repsigFdrmapSurrsHC_PVer','repsigFdrmapSurrsP_HCVer','repsigClustermapSurrsHC_PVer','repsigClustermapSurrsP_HCVer');
        % else
        %     data=load (['output/zmap_null_COMBAT',num2str(iCOMBAT),'_',hemi,'_smooth',num2str(smoothKernel),'_ver_part_',char(num2str(iNull)),'.mat'], ...
        %         'corzmapSurrsVer', 'corsigmapSurrsHC_PVer','corsigmapSurrsP_HCVer','corsigFdrmapSurrsHC_PVer','corsigFdrmapSurrsP_HCVer', ...
        %         'repsigmapSurrsHC_PVer','repsigmapSurrsP_HCVer','repsigFdrmapSurrsHC_PVer','repsigFdrmapSurrsP_HCVer');
        % end
        if iDiag > numel(data.corzmapSurrsVer) || isempty(data.corzmapSurrsVer{iDiag})
            fprintf('Skipping %s (diag=%d): no null correlation matrices to combine.\n', ...
                diagString{iDiag + 1}, iDiag + 1);
            break;
        end
        ids=find(triu(ones(size(data.corzmapSurrsVer{iDiag})),1));
        temp = median(data.corzmapSurrsVer{iDiag}(ids));
        corzmapSurrsVerAll{iDiag} = [corzmapSurrsVerAll{iDiag}; temp];

        % Extract upper triangular part and append for corsigmapSurrsHC_PVer
        ids = find(triu(ones(size(data.corsigmapSurrsHC_PVer{iDiag})), 1));
        temp = median(data.corsigmapSurrsHC_PVer{iDiag}(ids));
        corsigmapSurrsHC_PVerAll{iDiag} = [corsigmapSurrsHC_PVerAll{iDiag}; temp];

        % Extract upper triangular part and append for corsigmapSurrsP_HCVer
        ids = find(triu(ones(size(data.corsigmapSurrsP_HCVer{iDiag})), 1));
        temp = median(data.corsigmapSurrsP_HCVer{iDiag}(ids));
        corsigmapSurrsP_HCVerAll{iDiag} = [corsigmapSurrsP_HCVerAll{iDiag}; temp];

        % Extract upper triangular part and append for corsigFdrmapSurrsHC_PVer
        ids = find(triu(ones(size(data.corsigFdrmapSurrsHC_PVer{iDiag})), 1));
        temp = median(data.corsigFdrmapSurrsHC_PVer{iDiag}(ids));
        corsigFdrmapSurrsHC_PVerAll{iDiag} = [corsigFdrmapSurrsHC_PVerAll{iDiag}; temp];

        % Extract upper triangular part and append for corsigFdrmapSurrsP_HCVer
        ids = find(triu(ones(size(data.corsigFdrmapSurrsP_HCVer{iDiag})), 1));
        temp = median(data.corsigFdrmapSurrsP_HCVer{iDiag}(ids));
        corsigFdrmapSurrsP_HCVerAll{iDiag} = [corsigFdrmapSurrsP_HCVerAll{iDiag}; temp];

        % if iCOMBAT == 1 & hemi == 'lh' & smoothKernel == 10
            % Extract upper triangular part and append for corsigClustermapSurrsHC_PVer
            ids = find(triu(ones(size(data.corsigClustermapSurrsHC_PVer{iDiag})), 1));
            temp = median(data.corsigClustermapSurrsHC_PVer{iDiag}(ids));
            corsigClustermapSurrsHC_PVerAll{iDiag} = [corsigClustermapSurrsHC_PVerAll{iDiag}; temp];

            % Extract upper triangular part and append for corsigClustermapSurrsP_HCVer
            ids = find(triu(ones(size(data.corsigClustermapSurrsP_HCVer{iDiag})), 1));
            temp = median(data.corsigClustermapSurrsP_HCVer{iDiag}(ids));
            corsigClustermapSurrsP_HCVerAll{iDiag} = [corsigClustermapSurrsP_HCVerAll{iDiag}; temp];
        % end

        % Repeat for repsigmapSurrsHC_PVer
        ids = find(triu(ones(size(data.repsigmapSurrsHC_PVer{iDiag})), 1));
        temp = median(data.repsigmapSurrsHC_PVer{iDiag}(ids));
        repsigmapSurrsHC_PVerAll{iDiag} = [repsigmapSurrsHC_PVerAll{iDiag}; temp];

        % Repeat for repsigmapSurrsP_HCVer
        ids = find(triu(ones(size(data.repsigmapSurrsP_HCVer{iDiag})), 1));
        temp = median(data.repsigmapSurrsP_HCVer{iDiag}(ids));
        repsigmapSurrsP_HCVerAll{iDiag} = [repsigmapSurrsP_HCVerAll{iDiag}; temp];

        % Repeat for repsigFdrmapSurrsHC_PVer
        ids = find(triu(ones(size(data.repsigFdrmapSurrsHC_PVer{iDiag})), 1));
        temp = median(data.repsigFdrmapSurrsHC_PVer{iDiag}(ids));
        repsigFdrmapSurrsHC_PVerAll{iDiag} = [repsigFdrmapSurrsHC_PVerAll{iDiag}; temp];

        % Repeat for repsigFdrmapSurrsP_HCVer
        ids = find(triu(ones(size(data.repsigFdrmapSurrsP_HCVer{iDiag})), 1));
        temp = median(data.repsigFdrmapSurrsP_HCVer{iDiag}(ids));
        repsigFdrmapSurrsP_HCVerAll{iDiag} = [repsigFdrmapSurrsP_HCVerAll{iDiag}; temp];

        % if iCOMBAT == 1 & hemi == 'lh' & smoothKernel == 10
            % Repeat for repsigClustermapSurrsHC_PVer
            ids = find(triu(ones(size(data.repsigClustermapSurrsHC_PVer{iDiag})), 1));
            temp = median(data.repsigClustermapSurrsHC_PVer{iDiag}(ids));
            repsigClustermapSurrsHC_PVerAll{iDiag} = [repsigClustermapSurrsHC_PVerAll{iDiag}; temp];

            % Repeat for repsigClustermapSurrsP_HCVer
            ids = find(triu(ones(size(data.repsigClustermapSurrsP_HCVer{iDiag})), 1));
            temp = median(data.repsigClustermapSurrsP_HCVer{iDiag}(ids));
            repsigClustermapSurrsP_HCVerAll{iDiag} = [repsigClustermapSurrsP_HCVerAll{iDiag}; temp];
        % end
    end
end
%%
% if iCOMBAT == 1 & hemi == 'lh' & smoothKernel == 10
    if ~exist(output_dir, 'dir'); mkdir(output_dir); end
    save(fullfile(output_dir, ['zmap_null_COMBAT',num2str(iCOMBAT),'_',hemi,'_smooth',num2str(smoothKernel),'_ver_all.mat']),...
        'corzmapSurrsVerAll','corsigmapSurrsHC_PVerAll','corsigmapSurrsP_HCVerAll','corsigFdrmapSurrsHC_PVerAll','corsigFdrmapSurrsP_HCVerAll', 'corsigClustermapSurrsHC_PVerAll','corsigClustermapSurrsP_HCVerAll',...
        'repsigmapSurrsHC_PVerAll','repsigmapSurrsP_HCVerAll','repsigFdrmapSurrsHC_PVerAll','repsigFdrmapSurrsP_HCVerAll','repsigClustermapSurrsHC_PVerAll','repsigClustermapSurrsP_HCVerAll');
% else
%     save(['output/zmap_null_COMBAT',num2str(iCOMBAT),'_',hemi,'_smooth',num2str(smoothKernel),'_ver_all.mat'],...
%         'corzmapSurrsVerAll','corsigmapSurrsHC_PVerAll','corsigmapSurrsP_HCVerAll','corsigFdrmapSurrsHC_PVerAll','corsigFdrmapSurrsP_HCVerAll',...
%         'repsigmapSurrsHC_PVerAll','repsigmapSurrsP_HCVerAll','repsigFdrmapSurrsHC_PVerAll','repsigFdrmapSurrsP_HCVerAll');
% end
end