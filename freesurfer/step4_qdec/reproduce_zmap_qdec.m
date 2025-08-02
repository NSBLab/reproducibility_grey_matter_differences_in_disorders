% reproduce zmap from qdec

clear all
% list of disorders
diagString = {'HC', 'BD', 'SCA',...
    'SCZ', 'ASD', 'MDD' };
brainMeasure = 'thickness';
smooth = '10'; % smoothing kernel fwhm

% list of dataset
dataDir = '/projects/kg98/trangc/VBM/data';
dataFile = readtable(fullfile(dataDir,'dataset_list_surface1.txt'),'ReadVariableNames',false);
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

% for iSite = 1:nSite
iSite = 1;
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

% read subject ID
datasetDir = fullfile(dataDir, char(map.dataSet(iSite)));
subFile = readtable(fullfile(datasetDir,"sub_without_outlier.txt"),'ReadVariableNames',false);
subList = subFile.Var1;

% for iSub = 1: length(subList)
%     %% read in thickness map
%     thickness(iSub,:) = load_mgh(fullfile(datasetDir, 'derivatives','freesurfer', ...
%         char(subList(iSub)), 'surf',  ['lh.', brainMeasure,'.fwhm', smooth, '.fsaverage.mgh']));
% 
% end

% read qdec table
qdecFile = readtable(fullfile(datasetDir,['qdec_table_', char(map.site(iSite)),'_', char(map.diag(iSite)),'.dat']));
% doss
ymap = squeeze(load_mgh(fullfile(dataDir, char(map.dataSet(iSite)), 'derivatives','freesurfer','qdec', char(map.numericFolders(iSite)), 'y.mgh')))';
betamap = squeeze(load_mgh(fullfile(dataDir, char(map.dataSet(iSite)), 'derivatives','freesurfer','qdec', char(map.numericFolders(iSite)), 'beta.mgh')))';
rvarmap = squeeze(load_mgh(fullfile(dataDir, char(map.dataSet(iSite)), 'derivatives','freesurfer','qdec', char(map.numericFolders(iSite)), 'rvar.mgh')))';

Fmap = squeeze(load_mgh(fullfile(dataDir, char(map.dataSet(iSite)), 'derivatives','freesurfer', ...
    'qdec', char(map.numericFolders(iSite)), ['lh-Diff-1-', char(map.diag(iSite)),'-Intercept-thickness'], 'F.mgh')))';
gammamap = squeeze(load_mgh(fullfile(dataDir, char(map.dataSet(iSite)), 'derivatives','freesurfer', ...
    'qdec', char(map.numericFolders(iSite)), ['lh-Diff-1-', char(map.diag(iSite)),'-Intercept-thickness'], 'gamma.mgh')))';
sigmap = squeeze(load_mgh(fullfile(dataDir, char(map.dataSet(iSite)), 'derivatives','freesurfer', ...
    'qdec', char(map.numericFolders(iSite)), ['lh-Diff-1-', char(map.diag(iSite)),'-Intercept-thickness'], 'sig.mgh')))';
zmap = squeeze(load_mgh(fullfile(dataDir, char(map.dataSet(iSite)), 'derivatives','freesurfer', ...
    'qdec', char(map.numericFolders(iSite)), ['lh-Diff-1-', char(map.diag(iSite)),'-Intercept-thickness'], 'z.mgh')))';

matrixX(:,1) = double(qdecFile.diagnosis==1);
matrixX(:,2) = double(qdecFile.diagnosis==4);
matrixX(:,3) = qdecFile.sex;
matrixX(:,4) = qdecFile.age;

W = eye(size(matrixX,1));
    B = (matrixX'*W'*W*matrixX)\(matrixX'*W'*ymap);
eres = ymap - W*matrixX*B;
DOF = size(matrixX,1) - size(matrixX,2);
rvar = sum(eres.^2,1)/DOF;
C = [1 -1 0 0];
J = sum(C~=0,2)-1;
G = C*B;

for iC = 1:size(C,1)
 F(iC,:) = (G(iC,:).*inv(C(iC,:)*inv(matrixX'*W'*W*matrixX) *C(iC,:)').*G(iC,:))./(J(iC,:)*rvar);
end


%% dods
ymap = squeeze(load_mgh(fullfile(dataDir, char(map.dataSet(iSite)), 'derivatives','freesurfer','qdec', '4_HCP_thick_smooth10_lh_sex_age_test', 'y.mgh')))';
betamap = squeeze(load_mgh(fullfile(dataDir, char(map.dataSet(iSite)), 'derivatives','freesurfer','qdec', '4_HCP_thick_smooth10_lh_sex_age_test', 'beta.mgh')))';
rvarmap = squeeze(load_mgh(fullfile(dataDir, char(map.dataSet(iSite)), 'derivatives','freesurfer','qdec', '4_HCP_thick_smooth10_lh_sex_age_test', 'rvar.mgh')))';

Fmap = squeeze(load_mgh(fullfile(dataDir, char(map.dataSet(iSite)), 'derivatives','freesurfer', ...
    'qdec', '4_HCP_thick_smooth10_lh_sex_age_test', ['lh-Diff-1-', char(map.diag(iSite)),'-Intercept-thickness'], 'F.mgh')))';
gammamap = squeeze(load_mgh(fullfile(dataDir, char(map.dataSet(iSite)), 'derivatives','freesurfer', ...
    'qdec', '4_HCP_thick_smooth10_lh_sex_age_test', ['lh-Diff-1-', char(map.diag(iSite)),'-Intercept-thickness'], 'gamma.mgh')))';
sigmap = squeeze(load_mgh(fullfile(dataDir, char(map.dataSet(iSite)), 'derivatives','freesurfer', ...
    'qdec', '4_HCP_thick_smooth10_lh_sex_age_test', ['lh-Diff-1-', char(map.diag(iSite)),'-Intercept-thickness'], 'sig.mgh')))';
zmap = squeeze(load_mgh(fullfile(dataDir, char(map.dataSet(iSite)), 'derivatives','freesurfer', ...
    'qdec', '4_HCP_thick_smooth10_lh_sex_age_test', ['lh-Diff-1-', char(map.diag(iSite)),'-Intercept-thickness'], 'z.mgh')))';

matrixX(:,1) = double(qdecFile.diagnosis==1);
matrixX(:,2) = double(qdecFile.diagnosis==4);
matrixX((matrixX(:,1)==1),3) = qdecFile.sex(matrixX(:,1)==1);
matrixX((matrixX(:,1)==0),4) = qdecFile.sex(matrixX(:,1)==0);
matrixX((matrixX(:,1)==1),5) = qdecFile.age(matrixX(:,1)==1);
matrixX((matrixX(:,1)==0),6) = qdecFile.age(matrixX(:,1)==0);

W = eye(size(matrixX,1));
    B = (matrixX'*W'*W*matrixX)\(matrixX'*W'*ymap);
eres = ymap - W*matrixX*B;
DOF = size(matrixX,1) - size(matrixX,2);
rvar = sum(eres.^2,1)/DOF;
C = [1 -1 0 0 0 0];
J = sum(C~=0,2)-1;
G = C*B;

for iC = 1:size(C,1)
 F(iC,:) = (G(iC,:).*inv(C(iC,:)*inv(matrixX'*W'*W*matrixX) *C(iC,:)').*G(iC,:))./(J(iC,:)*rvar);
end

%%
    sig = -log10(1-fcdf(Fmap,1,150));
n1=sum(matrixX(:,1)==1,1);
n2=sum(matrixX(:,2)==1,1);
    (mean(ymap(matrixX(:,1)==1,1))-mean(ymap(matrixX(:,2)==1,1)))/(sqrt(((n1-1)*var(ymap(matrixX(:,1)==1,1))+(n2-1)*var(ymap(matrixX(:,2)==1,1)))/(n1+n2-2))*sqrt(1/n1+1/n2))
   y1=ymap(matrixX(:,1)==1,1);
   y2=ymap(matrixX(:,2)==1,1);
sum((y1-mean(y1)).^2)/sum((y2-mean(y2)).^2)*(n2-1)/(n1-1)