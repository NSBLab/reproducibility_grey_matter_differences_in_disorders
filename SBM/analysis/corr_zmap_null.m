% read all the z-maps and correlate them


clear all
% list of disorders
diagString = {'HC', 'BD', 'SCA',...
    'SCZ', 'ASD', 'MDD' ,'AD'};
addpath('/home/trangc/kg98/trangc/MBM/func')
addpath('/home/trangc/kg98/trangc/VBM/code/utils')
% list of dataset
dataDir = '/projects/kg98/trangc/VBM/data';
dataList = readlines(fullfile(dataDir,'dataset_list_surfaceAll.txt'));
% dataList = dataFile.Var1;
% dataFileAD = readtable(fullfile(dataDir,'dataset_list_AD.txt'),'ReadVariableNames',false);
% dataListAD = dataFileAD.Var1;
% dataList = [dataListPS;dataListAD];
nullDir = '/scratch/kg98/trangc/VBM/data/derivatives/freesurfer/s10COMBAT/null';

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

corDiagNull =  cell(1,length(diagString)-1);
corSigNull =  cell(1,length(diagString)-1);
corSigFdrNull =  cell(1,length(diagString)-1);
for iNull = [5:300]
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
        map.zmap(iSite,:) = load_mgh(fullfile(nullDir, num2str(iNull),char(map.dataSet(iSite)), ...
            qdecFolder, [hemi,'-Diff-1-', char(map.diag(iSite)),'-Intercept-',measure], 'z.mgh'));
        map.sigmap(iSite,:) = double(10.^(-abs(load_mgh(fullfile(nullDir, num2str(iNull),char(map.dataSet(iSite)), ...
            qdecFolder, [hemi,'-Diff-1-', char(map.diag(iSite)),'-Intercept-',measure], 'sig.mgh'))))<=thres);
        map.sigfdrmap(iSite,:) = load_mgh(fullfile(nullDir, num2str(iNull),char(map.dataSet(iSite)), ...
         qdecFolder, [hemi,'-Diff-1-', char(map.diag(iSite)),'-Intercept-',measure], 'perm.th13.abs.sig.voxel.mgh'));

    end

    % correlation between sites

    for iDiag = 1:length(diagString)-1

        isDiagSite = strcmp(map.diag, num2str((iDiag+1)));
        corDiag{iDiag} = corr(map.zmap(isDiagSite,:)');
        corSig{iDiag} = bin_corr_mat_account_zero(map.sigmap(isDiagSite,:)');
        corSigFdr{iDiag} = bin_corr_mat_account_zero(double(map.sigfdrmap(isDiagSite,:)~=0)');
        ids=find(triu(ones(size(corDiag{iDiag})),1));
        corDiagNull{iDiag} = [corDiagNull{iDiag};corDiag{iDiag}(ids)];
        corSigNull{iDiag} = [corSigNull{iDiag};corSig{iDiag}(ids)];
        corSigFdrNull{iDiag} = [corSigFdrNull{iDiag};corSigFdr{iDiag}(ids)];
    end

    save([nullDir,'/', num2str(iNull),'/corr_zmap_combat',num2str(iCOMBAT),'_smooth',num2str(smoothKernel),'.mat'], 'map', 'corDiag', 'corSig','corSigFdr');
end

save(['output/corr_null_zmap_combat',num2str(iCOMBAT),'_smooth',num2str(smoothKernel),'.mat'], 'corDiagNull','corSigNull','corSigFdrNull');