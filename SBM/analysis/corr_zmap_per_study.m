% read all the z-maps and correlate them


clear all
% list of disorders
diagString = {'HC', 'BD', 'SCA',...
    'SCZ', 'ASD', 'MDD' ,'AD'};
addpath('/projects/kg98/trangc/MBM/func')
addpath('/projects/kg98/trangc/VBM/code/utils')
addpath('/projects/kg98/trangc/library/fdr_bh')

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
smoothKernel = 10;
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
    if iCOMBAT==0
        qdecFolder = [map.diag{iSite},'_',map.site{iSite}, '_',measureShort,'_smooth',char(num2str(smoothKernel)),'_',hemi,'_sex_age'];
    else
        qdecFolder = [map.diag{iSite},'_',map.site{iSite}, '_',measureShort,'_smooth',char(num2str(smoothKernel)),'_',hemi,'_sex_age_combat'];
    end

    % read maps
    map.zmap(iSite,:) = load_mgh(fullfile(dataDir, char(map.dataSet(iSite)), 'derivatives','freesurfer', ...
        'qdec', qdecFolder, [hemi,'-Diff-1-', char(map.diag(iSite)),'-Intercept-',measure], 'z.mgh'));

    temp = load_mgh(fullfile(dataDir, char(map.dataSet(iSite)), 'derivatives','freesurfer', ...
        'qdec', qdecFolder, [hemi,'-Diff-1-', char(map.diag(iSite)),'-Intercept-',measure], 'sig.mgh'));
    map.sigmapHC_P(iSite,:) = double((10.^(-(temp)))<=thres);
    map.sigmapP_HC(iSite,:) = double((10.^((temp)))<=thres);
    map.polemap(iSite,:) = map.sigmapHC_P(iSite,:)-map.sigmapP_HC(iSite,:);

    [h, crit_p, adj_ci_cvrg, adj_p] = fdr_bh(10.^(-(temp)).*(temp>0)+10.^((temp)).*(temp<=0));
    map.sigFdrmapHC_P(iSite,:) = double((adj_p<=thres).*(temp>0));
    map.sigFdrmapP_HC(iSite,:) = double((adj_p<=thres).*(temp<=0));
    map.poleFdrmap(iSite,:) = sign(temp).*double(adj_p<=thres);

 temp = load_mgh(fullfile(dataDir, char(map.dataSet(iSite)), 'derivatives','freesurfer', ...
        'qdec', qdecFolder, [hemi,'-Diff-1-', char(map.diag(iSite)),'-Intercept-',measure], 'perm.th13.abs.sig.cluster.mgh'));
map.sigClustermapHC_P(iSite,:) = double((temp>0));
    map.sigClustermapP_HC(iSite,:) = double(temp<0);
end
% correlation between sites

for iDiag = 1:length(diagString)-1

    isDiagSite = strcmp(map.diag, num2str((iDiag+1)));
    siteIndex = find(isDiagSite==1);
    
    datasetList{iDiag} = map.dataSet(isDiagSite); %datasets in the diagnosis
uniquedatasetList{iDiag} = unique(map.dataSet(isDiagSite));
iConsiderDataset = 0;
for iDataset = 1:length(uniquedatasetList{iDiag})

    isSiteInDataset = strcmp(datasetList{iDiag},uniquedatasetList{iDiag}(iDataset)) %where the dataset appears in the list
if sum(isSiteInDataset) >= 3 % where there are three or more sites in the dataset
    iConsiderDataset = iConsiderDataset + 1;
    siteInDataset{iDiag,iConsiderDataset} = map.site(siteIndex(isSiteInDataset)); %sites in the dataset
 datasettoCor{iDiag,iConsiderDataset} = map.dataSet(siteIndex(isSiteInDataset));
    corDiag{iDiag,iConsiderDataset} = corr(map.zmap(siteIndex(isSiteInDataset),:)');

    sigMapHC_P = map.sigmapHC_P(siteIndex(isSiteInDataset),:);
    sigMapP_HC = map.sigmapP_HC(siteIndex(isSiteInDataset),:);
    corSigHC_P{iDiag,iConsiderDataset} = bin_corr_mat_account_zero(sigMapHC_P');
    corSigP_HC{iDiag,iConsiderDataset} = bin_corr_mat_account_zero(sigMapP_HC');
    repSigHC_P{iDiag,iConsiderDataset} = replication_mat(sigMapHC_P');
    repSigP_HC{iDiag,iConsiderDataset} = replication_mat(sigMapP_HC');


    sigFdrMapHC_P = map.sigFdrmapHC_P(siteIndex(isSiteInDataset),:);
    sigFdrMapP_HC = map.sigFdrmapP_HC(siteIndex(isSiteInDataset),:);
    corSigFdrHC_P{iDiag,iConsiderDataset} = bin_corr_mat_account_zero(sigFdrMapHC_P');
    corSigFdrP_HC{iDiag,iConsiderDataset} = bin_corr_mat_account_zero(sigFdrMapP_HC');
    repSigFdrHC_P{iDiag,iConsiderDataset} = replication_mat(sigFdrMapHC_P');
    repSigFdrP_HC{iDiag,iConsiderDataset} = replication_mat(sigFdrMapP_HC');

    sigClusterMapHC_P = map.sigClustermapHC_P(siteIndex(isSiteInDataset),:);
    sigClusterMapP_HC = map.sigClustermapP_HC(siteIndex(isSiteInDataset),:);
    corSigClusterHC_P{iDiag,iConsiderDataset} = bin_corr_mat_account_zero(sigClusterMapHC_P');
    corSigClusterP_HC{iDiag,iConsiderDataset} = bin_corr_mat_account_zero(sigClusterMapP_HC');
    repSigClusterHC_P{iDiag,iConsiderDataset} = replication_mat(sigClusterMapHC_P');
    repSigClusterP_HC{iDiag,iConsiderDataset} = replication_mat(sigClusterMapP_HC');

end
end
end

save(['output/corr_per_study_zmap_combat',num2str(iCOMBAT),'_smooth',num2str(smoothKernel),'_',hemi,'_all.mat'],...
    'map', 'corDiag','corSigHC_P', 'corSigP_HC','corSigFdrHC_P','corSigFdrP_HC', ...
    'repSigHC_P','repSigP_HC','repSigFdrHC_P','repSigFdrP_HC','corSigClusterHC_P','corSigClusterP_HC','repSigClusterHC_P','repSigClusterP_HC','siteInDataset','datasettoCor');
