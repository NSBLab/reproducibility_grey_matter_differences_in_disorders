% read all the z-maps and correlate them
function corr_map_subdivide_func(config, diag, dividemode, smoothKernel)
% arguments
%     diag (1,1) {mustBeInteger, mustBeLessThanOrEqual(diag,7)}
%     dividemode (1,1) {mustBeText}
% end

% sampleSize = [20 40 60 80 100 200 300 400 500];
if nargin < 4
    error('Usage: corr_map_subdivide_func(config, diag, dividemode, smoothKernel)');
end
this_dir = fileparts(mfilename('fullpath'));
repo_root = fullfile(this_dir, '..', '..', '..');
addpath(this_dir);
addpath(genpath(fullfile(repo_root, 'utils')));
if ischar(config) || isstring(config)
    config = pipeline_load_config(char(config));
end
data_root = config.data_directories.dataset_root;
thres = 0.05;
%diag = 3;
hemis = 'lh';
% dividemode = 'nosplitsite';
outDir = fullfile(data_root, 'derivatives', 'freesurfer', ['s',num2str(smoothKernel),'noCOMBAT'], ['diag',num2str(diag)], hemis, ['resample_2sitegroup_',dividemode]);
subdivideList = dir(outDir);
subdivideList = subdivideList([subdivideList.isdir]); % Keep only directories
subdivideList = subdivideList(~ismember({subdivideList.name}, {'.', '..'})); % Remove . and ..

for iFolder = 1:height(subdivideList)

    if exist(fullfile(outDir,subdivideList(iFolder).name, [subdivideList(iFolder).name,'_group1_sm',num2str(smoothKernel)],['lh-Diff-1-', num2str(diag),'-Intercept-thickness'], 'z.mgh')) ...
            & exist(fullfile(outDir,subdivideList(iFolder).name, [subdivideList(iFolder).name,'_group2_sm',num2str(smoothKernel)], ['lh-Diff-1-', num2str(diag),'-Intercept-thickness'], 'z.mgh'))
        % & ~exist(fullfile(outDir,subdivideList(iFolder).name,'corr_surface.mat'))

        subdivideList(iFolder).name

        map.zmap1(:,1) = load_mgh(fullfile(outDir,subdivideList(iFolder).name, [subdivideList(iFolder).name,'_group1_sm',num2str(smoothKernel)], ['lh-Diff-1-', num2str(diag),'-Intercept-thickness'], 'z.mgh'));
        map.zmap2(:,1) = load_mgh(fullfile(outDir,subdivideList(iFolder).name, [subdivideList(iFolder).name,'_group2_sm',num2str(smoothKernel)], ['lh-Diff-1-', num2str(diag),'-Intercept-thickness'], 'z.mgh'));

        map.sigmap1(:,1) = double(10.^(-abs(load_mgh(fullfile(outDir,subdivideList(iFolder).name, [subdivideList(iFolder).name,'_group1_sm',num2str(smoothKernel)], ['lh-Diff-1-', num2str(diag),'-Intercept-thickness'],'sig.mgh'))))<=thres);
        map.sigmap2(:,1) = double(10.^(-abs(load_mgh(fullfile(outDir,subdivideList(iFolder).name, [subdivideList(iFolder).name,'_group2_sm',num2str(smoothKernel)], ['lh-Diff-1-', num2str(diag),'-Intercept-thickness'],'sig.mgh'))))<=thres);

        tempfile1 =fullfile(outDir,subdivideList(iFolder).name, [subdivideList(iFolder).name,'_group1_sm',num2str(smoothKernel)], ['lh-Diff-1-', num2str(diag),'-Intercept-thickness'], 'perm.th13.abs.sig.cluster.mgh');
        tempfile2 =fullfile(outDir,subdivideList(iFolder).name, [subdivideList(iFolder).name,'_group2_sm',num2str(smoothKernel)], ['lh-Diff-1-', num2str(diag),'-Intercept-thickness'], 'perm.th13.abs.sig.cluster.mgh');
        % correlation between sites

        corDiagMat= corr([map.zmap1(:,1),map.zmap2(:,1)]);
        corDiag = corDiagMat(1,2);

        corSigMat= bin_corr_mat_account_zero([map.sigmap1(:,1),map.sigmap2(:,1)]);
        corSig = corSigMat(1,2);

        corSigMat= replication_mat([map.sigmap1(:,1),map.sigmap2(:,1)]);
        repSig = corSigMat(1,2);




        if exist(tempfile1) & exist(tempfile2)
            temp = load_mgh(tempfile1);
            map.sigclustermap1(:,1) = double((temp>0));
            temp = load_mgh(tempfile2);
            map.sigclustermap2(:,1) = double((temp>0));

            corSigMat= bin_corr_mat_account_zero([map.sigclustermap1(:,1),map.sigclustermap2(:,1)]);
            corSigCluster = corSigMat(1,2);

            corSigMat= replication_mat([map.sigclustermap1(:,1),map.sigclustermap2(:,1)]);
            repSigCluster = corSigMat(1,2);
                    save(fullfile(outDir,subdivideList(iFolder).name,['corr_surface_sm',num2str(smoothKernel),'.mat']), 'map', 'corDiag', 'corSig', 'repSig',"repSigCluster","corSigCluster");
        clear  map corDiag corSig repSig corSigCluster repSigCluster
        else
                    save(fullfile(outDir,subdivideList(iFolder).name,['corr_surface_sm',num2str(smoothKernel),'.mat']), 'map', 'corDiag', 'corSig', 'repSig');
        clear  map corDiag corSig repSig
   
        end
         end


    % for iSampleSize = 1:length(sampleSize)
    %      sampleSizeDir = fullfile(outDir,subdivideList(iFolder).name,['sampleSize_',num2str(sampleSize(iSampleSize))]);
    %
    %       resampleFolderList = dir(sampleSizeDir);
    %     resampleFolderList = resampleFolderList([resampleFolderList.isdir]); % Keep only directories
    %     resampleFolderList = resampleFolderList(~ismember({resampleFolderList.name}, {'.', '..'})); % Remove . and ..
    %     resampleList = unique(arrayfun(@(x) x.name(1:end-2),resampleFolderList,'UniformOutput',false));
    %   if ~exist(fullfile(sampleSizeDir,'corr_surface.mat')) & length(resampleList)>0
    %
    %     for iSite = 1:length(resampleList)
    %
    %
    %         % read maps
    %         if exist(fullfile(sampleSizeDir, [char(resampleList(iSite)),'_1'], ['lh-Diff-1-', num2str(diag),'-Intercept-thickness'], 'z.mgh')) ...
    %                 & exist(fullfile(sampleSizeDir, [char(resampleList(iSite)),'_2'], ['lh-Diff-1-', num2str(diag),'-Intercept-thickness'], 'z.mgh'))
    %             map.zmap1(:,iSite) = load_mgh(fullfile(sampleSizeDir, [char(resampleList(iSite)),'_1'], ['lh-Diff-1-', num2str(diag),'-Intercept-thickness'], 'z.mgh'));
    %             map.zmap2(:,iSite) = load_mgh(fullfile(sampleSizeDir, [char(resampleList(iSite)),'_2'], ['lh-Diff-1-', num2str(diag),'-Intercept-thickness'], 'z.mgh'));
    %
    %             map.sigmap1(:,iSite) = double(10.^(-abs(load_mgh(fullfile(sampleSizeDir, [char(resampleList(iSite)),'_1'], ['lh-Diff-1-', num2str(diag),'-Intercept-thickness'],'sig.mgh'))))<=thres);
    %             map.sigmap2(:,iSite) = double(10.^(-abs(load_mgh(fullfile(sampleSizeDir, [char(resampleList(iSite)),'_2'], ['lh-Diff-1-', num2str(diag),'-Intercept-thickness'],'sig.mgh'))))<=thres);
    %
    %             % correlation between sites
    %
    %             corDiagMat= corr([map.zmap1(:,iSite),map.zmap2(:,iSite)]);
    %             corDiag(iSite) = corDiagMat(1,2);
    %
    %             corSigMat= bin_corr_mat([map.sigmap1(:,iSite),map.sigmap2(:,iSite)]);
    %             corSig(iSite) = corSigMat(1,2);
    %         end
    %     end
    %
    %
    %
    %
    %     save(fullfile(sampleSizeDir,'corr_surface.mat'), 'map', 'corDiag', 'corSig');
    %     clear  map corDiag corSig
    %     end
    % end
end
end
