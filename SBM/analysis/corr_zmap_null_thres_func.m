function corr_zmap_null_thres_func(iNull, iCOMBAT, hemi, smoothKernel)
% list of disorders
diagString = {'HC', 'BD', 'SCA',...
    'SCZ', 'ASD', 'MDD' ,'AD'};
addpath('/home/trangc/kg98/trangc/MBM/func')
addpath('/home/trangc/kg98/trangc/VBM/code/utils')
addpath('/home/trangc/kg98/trangc/library/fdr_bh')
addpath(genpath('/projects/kg98/trangc/library/BrainSpace'))
addpath(genpath('/projects/kg98/trangc/library'))
% load(['eigenStruct_',hemi,'.mat']); %load structure that contains eigentrapping because the mask was changed to fix the 164k mesh error


% list of dataset
dataDir = '/projects/kg98/trangc/VBM/data';
dataFilePS = readtable(fullfile(dataDir,'dataset_list_SBM.txt'),'ReadVariableNames',false);
dataList = dataFilePS.Var1;

% iCOMBAT = 1;
measureShort = 'thick';
measure = 'thickness';
% hemi = 'rh';
% smoothKernel = 10;
thres=0.05;
nNull = 1000;

% find all sites
datadir = '/scratch2/kg98/trangc/VBM/data/eigentrap';
datasets = dir(datadir);
datasets = datasets(~ismember({datasets.name}, {'.', '..'})); % Exclude '.' and '..'


%%
% for iNull = 1:nNull
    iItem = 1;
    for iSite = 1:length(datasets)
        datasets(iSite).name
        % parcfiles = dir(fullfile(datadir,datasets(iSite).name,['parcMap_qdec_table_*','_combat',char(num2str(iCOMBAT)),'_',hemi,'_smooth',char(num2str(smoothKernel)),'*.mat']));
        % % verfiles = dir(fullfile(datadir,datasets(iSite).name,['verMap_qdec_table_*','_combat',char(num2str(iCOMBAT)),'_',hemi,'_smooth',char(num2str(smoothKernel)),'*.mat']));
        % parcThresfiles = dir(fullfile(datadir,datasets(iSite).name,['parcThresMap_qdec_table_*','_combat',char(num2str(iCOMBAT)),'_',hemi,'_smooth',char(num2str(smoothKernel)),'*.mat']));
        verThresfiles = dir(fullfile(datadir,datasets(iSite).name,['verThresMap_qdec_table_*','_combat',char(num2str(iCOMBAT)),'_',hemi,'_smooth',char(num2str(smoothKernel)),'*_newthres.mat']));
        for iFile = 1:length(verThresfiles)
            % load(fullfile(datadir,datasets(iSite).name,parcfiles(iFile).name), "zmapSurrsSF100","zmapSurrsSF500","zmapSurrsSF1000","zmapSurrsDK");
            load(fullfile(datadir,datasets(iSite).name,verThresfiles(iFile).name), "sigmapSurrsHC_PVer", "sigmapSurrsP_HCVer","sigFdrmapSurrsHC_PVer","sigFdrmapSurrsP_HCVer");
            %
            % % load(fullfile(datadir,datasets(iSite).name,parcThresfiles(iFile).name), "sigmapSurrsSF100","sigmapSurrsSF500","sigmapSurrsSF1000","sigmapSurrsDK");
            % load(fullfile(datadir,datasets(iSite).name,verThresfiles(iFile).name), "sigmapSurrsVer");


            % zmapSurrsVerAll(:,iItem) = zmapSurrsVer(:,iNull);


            sigmapSurrsHC_PVerAll(:,iItem) = sigmapSurrsHC_PVer(:,iNull);
            sigmapSurrsP_HCVerAll(:,iItem) = sigmapSurrsP_HCVer(:,iNull);
            sigFdrmapSurrsHC_PVerAll(:,iItem) = sigFdrmapSurrsHC_PVer(:,iNull);
            sigFdrmapSurrsP_HCVerAll(:,iItem) = sigFdrmapSurrsP_HCVer(:,iNull);

            % find site name
            % Split the string using '_' as the delimiter
            parts = strsplit(verThresfiles(iFile).name, '_');

            % Check if there are at least two parts
            if numel(parts) >11
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
    for iDiag = 1:length(diagString)-1

        isDiagSite = strcmp(map.diag, num2str((iDiag+1)));
        % corzmapSurrsVer{iDiag} = corr(squeeze(zmapSurrsVerAll(:,isDiagSite)));
        corsigmapSurrsHC_PVer{iDiag} = bin_corr_mat_account_zero(squeeze(sigmapSurrsHC_PVerAll(:,isDiagSite)));
        corsigmapSurrsP_HCVer{iDiag} = bin_corr_mat_account_zero(squeeze(sigmapSurrsP_HCVerAll(:,isDiagSite)));
        corsigFdrmapSurrsHC_PVer{iDiag} = bin_corr_mat_account_zero(squeeze(sigFdrmapSurrsHC_PVerAll(:,isDiagSite)));
        corsigFdrmapSurrsP_HCVer{iDiag} = bin_corr_mat_account_zero(squeeze(sigFdrmapSurrsP_HCVerAll(:,isDiagSite)));

        repsigmapSurrsHC_PVer{iDiag} = replication_mat(squeeze(sigmapSurrsHC_PVerAll(:,isDiagSite)));
        repsigmapSurrsP_HCVer{iDiag} = replication_mat(squeeze(sigmapSurrsP_HCVerAll(:,isDiagSite)));
        repsigFdrmapSurrsHC_PVer{iDiag} = replication_mat(squeeze(sigFdrmapSurrsHC_PVerAll(:,isDiagSite)));
        repsigFdrmapSurrsP_HCVer{iDiag} = replication_mat(squeeze(sigFdrmapSurrsP_HCVerAll(:,isDiagSite)));

    end
    clear sigmapSurrsHC_PVerAll sigmapSurrsP_HCVerAll sigFdrmapSurrsHC_PVerAll sigFdrmapSurrsP_HCVerAll
% end

%%
save(['output/zmap_null_COMBAT',char(num2str(iCOMBAT)),'_',hemi,'_smooth',char(num2str(smoothKernel)),'_ver_part_',char(num2str(iNull)),'_newthres.mat'],...
    'corsigmapSurrsHC_PVer','corsigmapSurrsP_HCVer','corsigFdrmapSurrsHC_PVer','corsigFdrmapSurrsP_HCVer', ...
    'repsigmapSurrsHC_PVer','repsigmapSurrsP_HCVer','repsigFdrmapSurrsHC_PVer','repsigFdrmapSurrsP_HCVer');
end