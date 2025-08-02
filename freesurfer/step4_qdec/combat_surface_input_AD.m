% create metadata and combine surface inputs for combat
clear all

smoothKernel = 10;
outDir = ['/scratch/kg98/trangc/VBM/data/derivatives/freesurfer/s',char(num2str(smoothKernel)),'COMBAT'];
% list of disorders
diagString = {'HC', 'BD', 'SCA',...
    'SCZ', 'ASD', 'MDD','AD' };
addpath('/projects/kg98/trangc/MBM/func')
% list of dataset
dataDir = '/projects/kg98/trangc/VBM/data';
dataFile = readtable(fullfile(dataDir,'dataset_list_AD.txt'),'ReadVariableNames',false);
dataList = dataFile.Var1;

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
% map.site = cell(1,nSite);

%% combine demo files
metadata = cell2table({});
uniqueSite={};
nUniqueSite = 0;
for iSite = 1:nSite


    demoInfo = readtable(fullfile(dataDir, char(map.dataSet(iSite)),char(map.numericFolders(iSite))));

    splitFilename = split(map.numericFolders(iSite),'_');
    [lia locb] = ismember(splitFilename{3},uniqueSite);
    if ~lia
        uniqueSite=[uniqueSite,splitFilename{3}];
        nUniqueSite = nUniqueSite+1;
        demoInfo.site = nUniqueSite*ones(height(demoInfo),1);
    else
        iSite
        demoInfo.site = locb*ones(height(demoInfo),1);
    end
    

    demoInfo.dataset = ((repelem({map.dataSet(iSite)}, height(demoInfo)))');
    metadata((end+1):(end+height(demoInfo)),:) = demoInfo;

end
writetable(metadata,fullfile(outDir,'metadata_AD.csv'),'Delimiter','tab');
metadata = unique(readtable(fullfile(outDir,'metadata_AD.csv'),'Delimiter','tab'));%cant use unique directly due to cell format
writetable(metadata,fullfile(outDir,'metadata_AD.csv'),'Delimiter','tab');

%scz sub
sczSite = unique(metadata.site(metadata.diagnosis==4));
sczMeta = metadata(ismember(metadata.site, sczSite) & (metadata.diagnosis==4|metadata.diagnosis==1),:);
writetable(sczMeta, fullfile(outDir,'metadata_surface_AD.csv'),'Delimiter','tab');
%% combine maps

for iSub = 1:height(metadata)
    thickmap(:,iSub) = squeeze(load_mgh(fullfile(dataDir, char(metadata.dataset{iSub}), 'derivatives','freesurfer', char(metadata.fsid(iSub)),'surf', ['lh.thickness.fwhm',char(num2str(smoothKernel)),'.fsaverage.mgh'])));
end

writematrix(thickmap, fullfile(outDir,['thickness_s',char(num2str(smoothKernel)),'_AD.txt']))