% modify file fsgd

% read all the z-maps and correlate them


clear all
% list of disorders
diagString = {'HC', 'BD', 'SCA',...
    'SCZ', 'ASD', 'MDD' };

% list of dataset
dataDir = '/projects/kg98/trangc/VBM/data';
dataFile = readtable(fullfile(dataDir,'dataset_list_vis.txt'),'ReadVariableNames',false);
dataList = dataFile.Var1;

% find all sites
map.numericFolders = {};
map.dataSet = {};
for iData = 1:length(dataList)
    diagInSet = dir(fullfile(dataDir, char(dataList(iData)), 'derivatives', 'freesurfer', 'qdec'));
    diagName = {diagInSet.name};
    numericFolderInSet = diagName(~cellfun('isempty', regexp(diagName, '^\d')));
    map.numericFolders((end+1):(end+length(numericFolderInSet))) = numericFolderInSet;
    map.dataSet((end+1):(end+length(numericFolderInSet))) = {char(dataList(iData))};

end

% sort sites  by diagnosis
nSite = length(map.numericFolders);
[map.numericFolders iSort] = sort(map.numericFolders);
map.dataSet = map.dataSet(iSort);
 map.diag = arrayfun(@(x) {map.numericFolders{x}(1)}, 1:nSite);

 map.site = cell(1,nSite);
for iSite = 1:nSite

   % find site name
    % Split the string using '_' as the delimiter
    parts = strsplit(map.numericFolders{iSite}, '_');
    
    % Check if there are at least two parts
    if numel(parts) >= 2
        % Extract the substring between the first and second underscores
        map.site{iSite} = parts{2};
    else
        % Handle the case where there are not enough underscores
        map.site{iSite} = 'N/A';
    end


 % read maps
    modify_fsgd_site(dataDir, char(map.dataSet(iSite)), char(map.numericFolders(iSite)));
end




