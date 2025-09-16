function corr_zmap_fdr_null_func(iNull, iCOMBAT, hemi, smoothKernel)
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
        % verfiles = dir(fullfile(datadir,datasets(iSite).name,['verMap_qdec_table_*','_combat',char(num2str(iCOMBAT)),'_',hemi,'_smooth',char(num2str(smoothKernel)),'*.mat']));
        % parcThresfiles = dir(fullfile(datadir,datasets(iSite).name,['parcThresMap_qdec_table_*','_combat',char(num2str(iCOMBAT)),'_',hemi,'_smooth',char(num2str(smoothKernel)),'*.mat']));
        verThresfiles = dir(fullfile(datadir,datasets(iSite).name,['verThresMap_qdec_table_*','_combat',char(num2str(iCOMBAT)),'_',hemi,'_smooth',char(num2str(smoothKernel)),'*.mat']));
        for iFile = 1:length(parcfiles)
            % load(fullfile(datadir,datasets(iSite).name,parcfiles(iFile).name), "zmapSurrsSF100","zmapSurrsSF500","zmapSurrsSF1000","zmapSurrsDK");
            % load(fullfile(datadir,datasets(iSite).name,verfiles(iFile).name), "zmapSurrsVer");
            %
            % % load(fullfile(datadir,datasets(iSite).name,parcThresfiles(iFile).name), "sigmapSurrsSF100","sigmapSurrsSF500","sigmapSurrsSF1000","sigmapSurrsDK");
            load(fullfile(datadir,datasets(iSite).name,verThresfiles(iFile).name), "sigmapSurrsVer");


            % zmapSurrsVerAll(:,iItem) = zmapSurrsVer(:,iNull);


            sigFdrmapSurrsVerAll(:,iItem) = sigmapSurrsVer(:,iNull);

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
            % isDiagSite = strcmp( map.diag{iItem} , num2str((iDiag+1)));

            iItem=iItem+1;
        end

    end
    for iDiag = 1:length(diagString)-1

        isDiagSite = strcmp(map.diag, num2str((iDiag+1)));
        corzmapSurrsVer{iDiag} = corr(squeeze(zmapSurrsVerAll(:,isDiagSite)));
        corsigmapSurrsVer{iDiag} = bin_corr_mat(squeeze(sigmapSurrsVerAll(:,isDiagSite)));
        repsigmapSurrsVer{iDiag} = replication_mat(squeeze(sigmapSurrsVerAll(:,isDiagSite)));

    end
    clear zmapSurrsVerAll sigmapSurrsVerAll
% end

%%
save(['output/zmap_null_COMBAT',char(num2str(iCOMBAT)),'_',hemi,'_smooth',char(num2str(smoothKernel)),'_ver_part_',char(num2str(iNull)),'.mat'],...
    'corzmapSurrsVer','corsigmapSurrsVer','repsigmapSurrsVer');
end