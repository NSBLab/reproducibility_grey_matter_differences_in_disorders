% null test using eigentrapping
% clear all
% inJob=1;
function nulltest_thres(iCOMBAT, hemi, smoothKernel, nTrap, inJob)

% list of disorders
diagString = {'HC', 'BD', 'SCA',...
    'SCZ', 'ASD', 'MDD' ,'AD'};
addpath('/projects/kg98/trangc/MBM/func')
addpath(genpath('/projects/kg98/trangc/library/NSB_utils_matlab'))
addpath('/projects/kg98/trangc/VBM/code/utils')
addpath(genpath('/projects/kg98/trangc/library/nihelp'))
addpath('/fs04/kg98/trangc/VBM/code/freesurfer/freesurfer_holmesQC/step4_qdec')
addpath('/projects/kg98/trangc/library/fdr_bh')

% list of dataset
dataDir = '/projects/kg98/trangc/VBM/data';
dataFilePS = readtable(fullfile(dataDir,'dataset_list_SBM_psy.txt'),'ReadVariableNames',false);
dataList = dataFilePS.Var1;

% parameters
% iCOMBAT = 1;
measureShort = 'thick';
measure = 'thickness';
% hemi = 'lh';
% smoothKernel = 10;
thres=0.05;
% s.vtkFile = '/projects/kg98/trangc/MBM/data/demo_emp/fsaverage_164k_midthickness-lh.vtk';
% s.maskFile = '/projects/kg98/trangc/MBM/data/demo_emp/fsaverage_164k_cortex-lh_mask.txt';
load(['eigenStruct_',hemi,'.mat'])
nEigenmode = 200;
% nTrap = 10;
rng(inJob)

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
    % map.zmap(iSite,:) = load_mgh(fullfile(dataDir, char(map.dataSet(iSite)), 'derivatives','freesurfer', ...
    %     'qdec', qdecFolder, [hemi,'-Diff-1-', char(map.diag(iSite)),'-Intercept-',measure], 'z.mgh'));
    temp =  load_mgh(fullfile(dataDir, char(map.dataSet(iSite)), 'derivatives','freesurfer', ...
        'qdec', qdecFolder, [hemi,'-Diff-1-', char(map.diag(iSite)),'-Intercept-',measure], 'sig.mgh'));
    map.sigmapHC_P(iSite,:) = double((10.^(-(temp)))<=thres);
    map.sigmapP_HC(iSite,:) = double((10.^((temp)))<=thres);

    [h, crit_p, adj_ci_cvrg, adj_p] = fdr_bh(10.^(-(temp)).*(temp>0)+10.^((temp)).*(temp<=0));
    map.sigFdrmapHC_P(iSite,:) = double((adj_p<=thres).*(temp>0));
    map.sigFdrmapP_HC(iSite,:) = double((adj_p<=thres).*(temp<=0));

end

% %% calculate eigenmodes
% [vertices,faces] = read_vtk(s.vtkFile);
%         s.vertices = vertices';
%         s.faces = faces';
%         s.mask = readmatrix(s.maskFile);
%         [s.vertices,s.faces,s.rois,s.mask] = trimExcludedRois(s.vertices,s.faces, s.mask);
%
%         % s = struct('vertices', s.vertices, 'faces', s.faces);
%         s = calc_geometric_eigenmode(s,nEigenmode);
% save('eigenStruct.mat','s');
%

%% eigentrapping for each site

for iSite = 1:nSite

    % [s zmapSurrs zmapRot] = calc_eigenstrap(s, 'map', map.zmap(iSite,s.mask==1)','nSurrogates',nTrap,'save',false);
    [s sigmapSurrsHC_P sigmapRot] = calc_eigenstrap(s, 'map', map.sigmapHC_P(iSite,s.mask==1)','nSurrogates',nTrap,'save',false,'resample',true);
      [s sigmapSurrsP_HC sigmapRot] = calc_eigenstrap(s, 'map', map.sigmapP_HC(iSite,s.mask==1)','nSurrogates',nTrap,'save',false,'resample',true);
      [s sigFdrmapSurrsHC_P sigmapRot] = calc_eigenstrap(s, 'map', map.sigFdrmapHC_P(iSite,s.mask==1)','nSurrogates',nTrap,'save',false,'resample',true);
      [s sigFdrmapSurrsP_HC sigmapRot] = calc_eigenstrap(s, 'map', map.sigFdrmapP_HC(iSite,s.mask==1)','nSurrogates',nTrap,'save',false,'resample',true);
    
    % mkdir(['/scratch2/kg98/trangc/VBM/data/eigentrap/',char(map.site{iSite})])
    save(['/scratch2/kg98/trangc/VBM/data/eigentrap/',char(map.site{iSite}),'/',map.numericFolders{iSite}(1:end-4),'_combat',char(num2str(iCOMBAT)),'_', hemi, ...
        '_smooth',char(num2str(smoothKernel)),'_',char(num2str(inJob)),'_newthres.mat'],'sigmapSurrsHC_P','sigmapSurrsP_HC','sigFdrmapSurrsHC_P','sigFdrmapSurrsP_HC')
end
end