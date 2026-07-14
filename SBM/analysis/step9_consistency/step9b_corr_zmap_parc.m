% read all the z-maps and correlate them


clear all
% list of disorders
diagString = {'HC', 'BD', 'SCA',...
    'SCZ', 'ASD', 'MDD' ,'AD'};
addpath('/home/trangc/kg98/trangc/MBM/func')
addpath('/home/trangc/kg98/trangc/VBM/code/utils')
addpath('/home/trangc/kg98/trangc/library/fdr_bh')

% list of dataset
dataDir = '/projects/kg98/trangc/VBM/data';
dataFilePS = readtable(fullfile(dataDir,'dataset_list_SBM.txt'),'ReadVariableNames',false);
dataList = dataFilePS.Var1;
% dataFileAD = readtable(fullfile(dataDir,'dataset_list_AD.txt'),'ReadVariableNames',false);
% dataListAD = dataFileAD.Var1;
% dataList = [dataListPS;dataListAD];

iCOMBAT = 1;
measureShort = 'thick';
measure = 'thickness';
hemi = 'lh';
smoothkernel = 0;
thres=0.05;

% find all sites
map.numericFolders = {};
map.dataSet = {};
for iData = 1:length(dataList)
    diagInSet = dir(fullfile(dataDir, char(dataList(iData))));
    diagName = {diagInSet.name};
    pat = "qdec_" + wildcardPattern+ ".dat";
    isQdecFile = contains(diagName,pat);
    numericFolderInSet = diagName(isQdecFile);

    map.numericFolders((end+1):(end+length(numericFolderInSet))) = numericFolderInSet;
    map.dataSet((end+1):(end+length(numericFolderInSet))) = {char(dataList(iData))};


end

% sort sites  by diagnosis
nSite = length(map.numericFolders);
map.diag = arrayfun(@(x) {map.numericFolders{x}(end-4)}, 1:nSite);

[map.diag iSort] = sort(map.diag);
map.dataSet = map.dataSet(iSort);
map.numericFolders = map.numericFolders(iSort);
for iSite = 1:nSite

    % find site name
    % Split the string using '_' as the delimiter
    parts = strsplit(map.numericFolders{iSite}, '_');

    % Check if there are at least two parts
    if numel(parts) >4
        % Extract the substring between the first and second underscores
        map.site{iSite} = [parts{3},'_',parts{4}];
    else
        % Handle the case where there are not enough underscores
        map.site{iSite} = parts{3};
    end
    % if iCOMBAT==0
    %     qdecFolder = [map.diag{iSite},'_',map.site{iSite}, '_',measureShort,'_smooth',char(num2str(smoothkernel)),'_',hemi,'_sex_age_aparc'];
    % else
    %     qdecFolder = [map.diag{iSite},'_',map.site{iSite}, '_',measureShort,'_smooth',char(num2str(smoothkernel)),'_',hemi,'_sex_age_aparc_combat'];
    % end

    % read maps
    % map.zmap(iSite,:) = load_mgh(fullfile(dataDir, char(map.dataSet(iSite)), 'derivatives','freesurfer', ...
    %     'qdec', qdecFolder, [hemi,'-Diff-1-', char(map.diag(iSite)),'-Intercept-',measure], 'z.mgh'));
    % map.sigmap(iSite,:) = double((10.^(-abs(load_mgh(fullfile(dataDir, char(map.dataSet(iSite)), 'derivatives','freesurfer', ...
    %     'qdec', qdecFolder, [hemi,'-Diff-1-', char(map.diag(iSite)),'-Intercept-',measure], 'sig.mgh')))))<=thres);
    % [map.sigFdrmap(iSite,:), crit_p, adj_ci_cvrg, map.pFdrmap(iSite,:)] = fdr_bh(10.^(-abs(load_mgh(fullfile(dataDir, char(map.dataSet(iSite)), 'derivatives','freesurfer', ...
    %     'qdec', qdecFolder, [hemi,'-Diff-1-', char(map.diag(iSite)),'-Intercept-',measure], 'sig.mgh')))), thres);
    if iCOMBAT == 0 
    qdecfolder = fullfile(dataDir,char(map.dataSet(iSite)), 'derivatives','freesurfer','qdec',...
         [char(map.diag{iSite}),'_',char(map.site{iSite}),'_',measureShort,'_smooth',char(num2str(smoothkernel)),'_',hemi,'_sex_age_SF']);
    else
     qdecfolder = fullfile(dataDir,char(map.dataSet(iSite)), 'derivatives','freesurfer','qdec',...
         [char(map.diag{iSite}),'_',char(map.site{iSite}),'_',measureShort,'_smooth',char(num2str(smoothkernel)),'_',hemi,'_sex_age_SF_combat']);
    end   
     
    load(fullfile(qdecfolder,[hemi,'.thickness.fwhm',char(num2str(smoothkernel)),'_glm.fsaverage.mat']),'pValueDK','pValueSF100','pValueSF500' ,'pValueSF1000','zDK','zSF100','zSF500','zSF1000')
      map.zmapDK(iSite,:) = zDK;
      map.zmapSF100(iSite,:) = zSF100;
      map.zmapSF500(iSite,:) = zSF500;
      map.zmapSF1000(iSite,:) = zSF1000;
      map.sigmapDK(iSite,:) = double(pValueDK <=thres);
      map.sigmapSF100(iSite,:) = double(pValueSF100 <=thres);
      map.sigmapSF500(iSite,:) = double(pValueSF500 <=thres);
      map.sigmapSF1000(iSite,:) = double(pValueSF1000 <=thres);
end
% correlation between sites
for iDiag = 1:length(diagString)-1

 isDiagSite = strcmp(map.diag, num2str((iDiag+1)));
 corDiagDK{iDiag} = corr(map.zmapDK(isDiagSite,:)');
 corDiagSF100{iDiag} = corr(map.zmapSF100(isDiagSite,:)');
 corDiagSF500{iDiag} = corr(map.zmapSF500(isDiagSite,:)');
 corDiagSF1000{iDiag} = corr(map.zmapSF1000(isDiagSite,:)');
corSigDK{iDiag} = bin_corr_mat_account_zero(map.sigmapDK(isDiagSite,:)');
corSigSF100{iDiag} = bin_corr_mat_account_zero(map.sigmapSF100(isDiagSite,:)');
corSigSF500{iDiag} = bin_corr_mat_account_zero(map.sigmapSF500(isDiagSite,:)');
corSigSF1000{iDiag} = bin_corr_mat_account_zero(map.sigmapSF1000(isDiagSite,:)');
repSigDK{iDiag} = replication_mat(map.sigmapDK(isDiagSite,:)');
repSigSF100{iDiag} = replication_mat(map.sigmapSF100(isDiagSite,:)');
repSigSF500{iDiag} = replication_mat(map.sigmapSF500(isDiagSite,:)');
repSigSF1000{iDiag} = replication_mat(map.sigmapSF1000(isDiagSite,:)');


 siteList{iDiag} = map.site(isDiagSite);
end

save(['output/zmap_aparc_COMBAT',num2str(iCOMBAT),'_smooth',num2str(smoothkernel),'_all.mat'])
