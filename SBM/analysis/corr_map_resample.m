% read all the z-maps and correlate them


clear all

addpath('/home/trangc/kg98/trangc/MBM/func')
outDir = ['/scratch/kg98/trangc/VBM/data/derivatives/freesurfer/s',char(num2str(smoothKernel)),'COMBAT'];


% list of dataset
dataDir = '/projects/kg98/trangc/VBM/data';
dataFile = readtable(fullfile(dataDir,'dataset_list_surface.txt'),'ReadVariableNames',false);
dataList = dataFile.Var1;

thres = 0.05;
% sczMeta=writetable(fullfile(outDir,'metadata_surface_SCZ.csv'),'Delimiter','tab');


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
    map.zmap(iSite,:) = load_mgh(fullfile(dataDir, char(map.dataSet(iSite)), 'derivatives','freesurfer', ...
    'qdec', char(map.numericFolders(iSite)), ['lh-Diff-1-', char(map.diag(iSite)),'-Intercept-thickness'], 'z.mgh'));
map.sigmap(iSite,:) = double(10.^(-abs(load_mgh(fullfile(dataDir, char(map.dataSet(iSite)), 'derivatives','freesurfer', ...
    'qdec', char(map.numericFolders(iSite)), ['lh-Diff-1-', char(map.diag(iSite)),'-Intercept-thickness'], 'sig.mgh'))))<=thres);
end

% correlation between sites

 corDiag = corr(map.zmap(:,:)');
corSig = bin_corr_mat(map.sigmap(:,:)');


save('corr_surface.mat', 'map', 'corDiag', 'corSig');
