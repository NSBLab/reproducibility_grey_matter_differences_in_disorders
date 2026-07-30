function step9e_corr_zmap_parc_null(config, hemi, iCOMBAT, smoothKernel, nNull)
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

if nargin < 3 || isempty(iCOMBAT); iCOMBAT = num2str(config.analysis_settings.harmonize); end
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
iItem = 1;
for iSite = 1:length(datasets)
    datasets(iSite).name
    parcfiles = dir(fullfile(datadir,datasets(iSite).name,['parcMap_qdec_table_*','_combat',iCOMBAT,'_',hemi,'_smooth',char(num2str(smoothKernel)),'*.mat']));
    % verfiles = dir(fullfile(datadir,datasets(iSite).name,['verMap_qdec_table_*','_combat',iCOMBAT,'_',hemi,'_smooth',char(num2str(smoothKernel)),'*.mat']));
    parcThresfiles = dir(fullfile(datadir,datasets(iSite).name,['parcThresMap_qdec_table_*','_combat',iCOMBAT,'_',hemi,'_smooth',char(num2str(smoothKernel)),'*.mat']));
    % verThresfiles = dir(fullfile(datadir,datasets(iSite).name,['verThresMap_qdec_table_*','_combat',iCOMBAT,'_',hemi,'_smooth',char(num2str(smoothKernel)),'*.mat']));
    for iFile = 1:length(parcfiles)
        load(fullfile(datadir,datasets(iSite).name,parcfiles(iFile).name), "zmapSurrsSF100","zmapSurrsSF500","zmapSurrsSF1000","zmapSurrsDK");
        % sZ{iItem} = load(fullfile(datadir,datasets(iSite).name,verfiles(iFile).name), "zmapSurrsVer");

        load(fullfile(datadir,datasets(iSite).name,parcThresfiles(iFile).name), "sigmapSurrsSF100","sigmapSurrsSF500","sigmapSurrsSF1000","sigmapSurrsDK");
        % sSig{iItem} = load(fullfile(datadir,datasets(iSite).name,verThresfiles(iFile).name), "sigmapSurrsVer");

        zmapSurrsSF100All(:,:,iItem) = zmapSurrsSF100;
        zmapSurrsSF500All(:,:,iItem) = zmapSurrsSF500;
        zmapSurrsSF1000All(:,:,iItem) = zmapSurrsSF1000;
        zmapSurrsDKAll(:,:,iItem) = zmapSurrsDK;
        % zmapSurrsVerAll(:,:,iItem) = zmapSurrsVer;

        sigmapSurrsSF100All(:,:,iItem) = double(sigmapSurrsSF100);
        sigmapSurrsSF500All(:,:,iItem) = double(sigmapSurrsSF500);
        sigmapSurrsSF1000All(:,:,iItem) = double(sigmapSurrsSF1000);
        sigmapSurrsDKAll(:,:,iItem) = double(sigmapSurrsDK);
        %sigmapSurrsVerAll(:,:,iItem) = sigmapSurrsVer;

        % find site name
        % Split the string using '_' as the delimiter
        parts = strsplit(parcfiles(iFile).name, '_');

        % Check if there are at least two parts
        if numel(parts) >9
            % Extract the substring between the first and second underscores
            map.diag{iItem} = parts{6};
        else
            % Handle the case where there are not enough underscores
            map.diag{iItem} = parts{5};
        end
        map.site{iItem} = datasets(iSite).name;

        iItem=iItem+1;
    end
end

%%
% for iNull = 1:nNull
%     iItem = 1;
%     for iSite = 1:length(datasets)
%         datasets(iSite).name
%         parcfiles = dir(fullfile(datadir,datasets(iSite).name,'parcMap*.mat'));
%         verfiles = dir(fullfile(datadir,datasets(iSite).name,'verMap*.mat'));
%         parcThresfiles = dir(fullfile(datadir,datasets(iSite).name,'parcThresMap*.mat'));
%         verThresfiles = dir(fullfile(datadir,datasets(iSite).name,'verThresMap*.mat'));
%         for iFile = 1:length(parcfiles)
%             % load(fullfile(datadir,datasets(iSite).name,parcfiles(iFile).name), "zmapSurrsSF100","zmapSurrsSF500","zmapSurrsSF1000","zmapSurrsDK");
%             % load(fullfile(datadir,datasets(iSite).name,verfiles(iFile).name), "zmapSurrsVer");
%             %
%             % % load(fullfile(datadir,datasets(iSite).name,parcThresfiles(iFile).name), "sigmapSurrsSF100","sigmapSurrsSF500","sigmapSurrsSF1000","sigmapSurrsDK");
%             % load(fullfile(datadir,datasets(iSite).name,verThresfiles(iFile).name), "sigmapSurrsVer");
% 
% 
%             zmapSurrsVerAll(:,iItem) = sZ{iItem}.zmapSurrsVer(:,iNull);
% 
% 
%             sigmapSurrsVerAll(:,iItem) = sSig{iItem}.sigmapSurrsVer(:,iNull);
% 
%             % % find site name
%             % % Split the string using '_' as the delimiter
%             % parts = strsplit(parcfiles(iFile).name, '_');
%             %
%             % % Check if there are at least two parts
%             % if numel(parts) >9
%             %     % Extract the substring between the first and second underscores
%             %     map.diag{iItem} = parts{6};
%             % else
%             %     % Handle the case where there are not enough underscores
%             %     map.diag{iItem} = parts{5};
%             % end
%             % map.site{iItem} = datasets(iSite).name;
%             % isDiagSite = strcmp( map.diag{iItem} , num2str((iDiag+1)));
% 
%             iItem=iItem+1;
%         end
% 
%     end
%     for iDiag = 1:length(diagString)-1
% 
%         isDiagSite = strcmp(map.diag, num2str((iDiag+1)));
%         corzmapSurrsVer{iDiag,iNull} = corr(squeeze(zmapSurrsVerAll(:,isDiagSite)));
%         corsigmapSurrsVer{iDiag,iNull} = bin_corr_mat(squeeze(sigmapSurrsVerAll(:,isDiagSite)));
%         repsigmapSurrsVer{iDiag,iNull} = replication_mat(squeeze(sigmapSurrsVerAll(:,isDiagSite)));
% 
%     end
%     clear zmapSurrsVerAll sigmapSurrsVerAll
% end
%% correlation between sites
for iDiag = 1:length(diagString)-1

    isDiagSite = strcmp(map.diag, num2str((iDiag+1)));
    for iNull = 1:nNull
        corzmapSurrsSF100{iDiag,iNull} = corr(squeeze(zmapSurrsSF100All(:,iNull,isDiagSite)));
        corzmapSurrsSF500{iDiag,iNull} = corr(squeeze(zmapSurrsSF500All(:,iNull,isDiagSite)));
        corzmapSurrsSF1000{iDiag,iNull} = corr(squeeze(zmapSurrsSF1000All(:,iNull,isDiagSite)));
        corzmapSurrsDK{iDiag,iNull} = corr(squeeze(zmapSurrsDKAll(:,iNull,isDiagSite)));

        corsigmapSurrsSF100{iDiag,iNull} = bin_corr_mat_account_zero(squeeze(sigmapSurrsSF100All(:,iNull,isDiagSite)));
        corsigmapSurrsSF500{iDiag,iNull} = bin_corr_mat_account_zero(squeeze(sigmapSurrsSF500All(:,iNull,isDiagSite)));
        corsigmapSurrsSF1000{iDiag,iNull} = bin_corr_mat(squeeze(sigmapSurrsSF1000All(:,iNull,isDiagSite)));
        corsigmapSurrsDK{iDiag,iNull} = bin_corr_mat_account_zero(squeeze(sigmapSurrsDKAll(:,iNull,isDiagSite)));

        repsigmapSurrsSF100{iDiag,iNull} = replication_mat(squeeze(sigmapSurrsSF100All(:,iNull,isDiagSite)));
        repsigmapSurrsSF500{iDiag,iNull} = replication_mat(squeeze(sigmapSurrsSF500All(:,iNull,isDiagSite)));
        repsigmapSurrsSF1000{iDiag,iNull} = replication_mat(squeeze(sigmapSurrsSF1000All(:,iNull,isDiagSite)));
        repsigmapSurrsDK{iDiag,iNull} = replication_mat(squeeze(sigmapSurrsDKAll(:,iNull,isDiagSite)));
    end
    siteList{iDiag} = map.site(isDiagSite);


end


%%
corzmapSurrsSF100All = cell(1,6);
corzmapSurrsSF500All = cell(1,6);
corzmapSurrsSF1000All = cell(1,6);
corzmapSurrsDKAll = cell(1,6);
corzmapSurrsVerAll = cell(1,6);

corsigmapSurrsSF100All = cell(1,6);
corsigmapSurrsSF500All = cell(1,6);
corsigmapSurrsSF1000All = cell(1,6);
corsigmapSurrsDKAll = cell(1,6);
corsigmapSurrsVerAll = cell(1,6);

repsigmapSurrsSF100All = cell(1,6);
repsigmapSurrsSF500All = cell(1,6);
repsigmapSurrsSF1000All = cell(1,6);
repsigmapSurrsDKAll = cell(1,6);
repsigmapSurrsVerAll = cell(1,6);
%%
for iDiag = 1:length(diagString)-1


    for iNull = 1:nNull
        ids=find(triu(ones(size(corzmapSurrsSF100{iDiag,iNull})),1));
        temp = median(corzmapSurrsSF100{iDiag,iNull}(ids));
        corzmapSurrsSF100All{iDiag} = [corzmapSurrsSF100All{iDiag}; temp];

        ids=find(triu(ones(size(corzmapSurrsSF500{iDiag,iNull})),1));
        temp = median(corzmapSurrsSF500{iDiag,iNull}(ids));
        corzmapSurrsSF500All{iDiag} = [corzmapSurrsSF500All{iDiag}; temp];

        ids=find(triu(ones(size(corzmapSurrsSF1000{iDiag,iNull})),1));
        temp = median(corzmapSurrsSF1000{iDiag,iNull}(ids));
        corzmapSurrsSF1000All{iDiag} = [corzmapSurrsSF1000All{iDiag}; temp];

        ids=find(triu(ones(size(corzmapSurrsDK{iDiag,iNull})),1));
        temp = median(corzmapSurrsDK{iDiag,iNull}(ids));
        corzmapSurrsDKAll{iDiag} = [corzmapSurrsDKAll{iDiag}; temp];

        % ids=find(triu(ones(size(corzmapSurrsVer{iDiag,iNull})),1));
        % temp = corzmapSurrsVer{iDiag,iNull}(ids);
        % corzmapSurrsVerAll{iDiag} = [corzmapSurrsVerAll{iDiag}; temp];

        ids=find(triu(ones(size(corsigmapSurrsSF100{iDiag,iNull})),1));
        temp = median(corsigmapSurrsSF100{iDiag,iNull}(ids));
        corsigmapSurrsSF100All{iDiag} = [corsigmapSurrsSF100All{iDiag}; temp];

        ids=find(triu(ones(size(corsigmapSurrsSF500{iDiag,iNull})),1));
        temp = median(corsigmapSurrsSF500{iDiag,iNull}(ids));
        corsigmapSurrsSF500All{iDiag} = [corsigmapSurrsSF500All{iDiag}; temp];

        ids=find(triu(ones(size(corsigmapSurrsSF1000{iDiag,iNull})),1));
        temp = median(corsigmapSurrsSF1000{iDiag,iNull}(ids));
        corsigmapSurrsSF1000All{iDiag} = [corsigmapSurrsSF1000All{iDiag}; temp];

        ids=find(triu(ones(size(corsigmapSurrsDK{iDiag,iNull})),1));
        temp = median(corsigmapSurrsDK{iDiag,iNull}(ids));
        corsigmapSurrsDKAll{iDiag} = [corsigmapSurrsDKAll{iDiag}; temp];

        % ids=find(triu(ones(size(corsigmapSurrsVer{iDiag,iNull})),1));
        % temp = corsigmapSurrsVer{iDiag,iNull}(ids);
        % corsigmapSurrsVerAll{iDiag} = [corsigmapSurrsVerAll{iDiag}; temp];


        ids=find(triu(ones(size(repsigmapSurrsSF100{iDiag,iNull})),1));
        temp = median(repsigmapSurrsSF100{iDiag,iNull}(ids));
        repsigmapSurrsSF100All{iDiag} = [repsigmapSurrsSF100All{iDiag}, temp];


        ids=find(triu(ones(size(repsigmapSurrsSF500{iDiag,iNull})),1));
        temp = median(repsigmapSurrsSF500{iDiag,iNull}(ids));
        repsigmapSurrsSF500All{iDiag} = [repsigmapSurrsSF500All{iDiag}, temp];


        ids=find(triu(ones(size(repsigmapSurrsSF1000{iDiag,iNull})),1));
        temp = median(repsigmapSurrsSF1000{iDiag,iNull}(ids));
        repsigmapSurrsSF1000All{iDiag} = [repsigmapSurrsSF1000All{iDiag}, temp];


        ids=find(triu(ones(size(repsigmapSurrsDK{iDiag,iNull})),1));
        temp = median(repsigmapSurrsDK{iDiag,iNull}(ids));
        repsigmapSurrsDKAll{iDiag} = [repsigmapSurrsDKAll{iDiag}, temp];


        % ids=find(triu(ones(size(repsigmapSurrsVer{iDiag,iNull})),1));
        % temp = repsigmapSurrsVer{iDiag,iNull}(ids);
        % repsigmapSurrsVerAll{iDiag} = [repsigmapSurrsVerAll{iDiag}, temp];

    end
end
%%
output_dir = fullfile(dataDir, 'results', 'SBM', 'analysis', 'output');
if ~exist(output_dir, 'dir'); mkdir(output_dir); end
save(fullfile(output_dir, ['zmap_null_COMBAT',num2str(iCOMBAT),'_',hemi,'_smooth',num2str(smoothKernel),'_parc_all.mat']),...
    'corzmapSurrsSF100All','corzmapSurrsSF500All','corzmapSurrsSF1000All','corzmapSurrsDKAll',...
    'corsigmapSurrsSF100All','corsigmapSurrsSF500All','corsigmapSurrsSF1000All','corsigmapSurrsDKAll',...
    'repsigmapSurrsSF100All','repsigmapSurrsSF500All','repsigmapSurrsSF1000All','repsigmapSurrsDKAll');
end
