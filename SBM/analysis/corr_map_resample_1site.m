% read all the z-maps and correlate them


clear all
smoothKernel = 10;
hemis = 'lh';
sampleSize = [20 40 60 80 100 200 300 400 500 700 1000];
thres = 0.05;
diag = 3;
addpath('/home/trangc/kg98/trangc/MBM/func')

outDir = fullfile('/scratch','kg98','trangc','VBM','data', 'derivatives', 'freesurfer',['s',num2str(smoothKernel),'noCOMBAT'],['diag',num2str(diag)],hemis, 'resample_1site');

map.zmap2(:,1) = load_mgh(fullfile(outDir, 'orisite', ['lh-Diff-1-', num2str(diag),'-Intercept-thickness'], 'z.mgh'));
map.sigmap2(:,1) = double(10.^(-abs(load_mgh(fullfile(outDir,'orisite', ['lh-Diff-1-', num2str(diag),'-Intercept-thickness'],'sig.mgh'))))<=thres);

for iSampleSize = 1:length(sampleSize)
    sampleSizeDir = fullfile(outDir,['sampleSize_',num2str(sampleSize(iSampleSize))]);
    resampleFolderList = dir(sampleSizeDir);
    resampleFolderList = resampleFolderList([resampleFolderList.isdir]); % Keep only directories
    resampleFolderList = resampleFolderList(~ismember({resampleFolderList.name}, {'.', '..'})); % Remove . and ..
    resampleList = unique(arrayfun(@(x) x.name(1:end-2),resampleFolderList,'UniformOutput',false));

    for iSite = 1:length(resampleList)


        % read maps
        if exist(fullfile(sampleSizeDir, [char(resampleList(iSite)),'_1'], ['lh-Diff-1-', num2str(diag),'-Intercept-thickness'], 'z.mgh')) 
map.zmap1(:,iSite) = load_mgh(fullfile(sampleSizeDir, [char(resampleList(iSite)),'_1'], ['lh-Diff-1-', num2str(diag),'-Intercept-thickness'],'z.mgh'));

            map.sigmap1(:,iSite) = double(10.^(-abs(load_mgh(fullfile(sampleSizeDir, [char(resampleList(iSite)),'_1'], ['lh-Diff-1-', num2str(diag),'-Intercept-thickness'],'sig.mgh'))))<=thres);

            % correlation between sites

            corDiagMat= corr([map.zmap1(:,iSite),map.zmap2(:,1)]);
            corDiag(iSite) = corDiagMat(1,2);

            corSigMat= bin_corr_mat([map.sigmap1(:,iSite),map.sigmap2(:,1)]);
            corSig(iSite) = corSigMat(1,2);
        end
    end




    save(fullfile(sampleSizeDir,'corr_surface.mat'), 'map', 'corDiag', 'corSig');
    clear   corDiag corSig
    map = rmfield(map,{'zmap1','sigmap1'});
end

