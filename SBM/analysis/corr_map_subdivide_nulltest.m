% read all the z-maps and correlate them


clear all
smoothKernel = 10;
sampleSize = [20 40 60 80]% 100 200 300 400 500];
thres = 0.05;
diag = 4;
diagTest = 6;
hemis = 'lh';
addpath('/home/trangc/kg98/trangc/MBM/func')

outDir = fullfile('/scratch','kg98','trangc','VBM','data', 'derivatives', 'freesurfer',['s',num2str(smoothKernel),'noCOMBAT'],['diag',num2str(diag)],hemis, 'resample_2sitegroup');
subdivideList = dir(outDir);
subdivideList = subdivideList([subdivideList.isdir]); % Keep only directories
subdivideList = subdivideList(~ismember({subdivideList.name}, {'.', '..'})); % Remove . and ..

outDirTest = fullfile('/scratch','kg98','trangc','VBM','data', 'derivatives', 'freesurfer',['s',num2str(smoothKernel),'noCOMBAT'],['diag',num2str(diagTest)],hemis, 'resample_2sitegroup');
subdivideListTest = dir(outDirTest);
subdivideListTest = subdivideListTest([subdivideListTest.isdir]); % Keep only directories
subdivideListTest = subdivideListTest(~ismember({subdivideListTest.name}, {'.', '..'})); % Remove . and ..


for iFolder = 1:height(subdivideList)

    if exist(fullfile(outDir,subdivideList(iFolder).name, [subdivideList(iFolder).name,'_group1'],['lh-Diff-1-', num2str(diag),'-Intercept-thickness'], 'z.mgh')) & exist(fullfile(outDir,subdivideList(iFolder).name, [subdivideList(iFolder).name,'_group2'], ['lh-Diff-1-', num2str(diag),'-Intercept-thickness'], 'z.mgh'))
        map.zmap1(:,1) = load_mgh(fullfile(outDir,subdivideList(iFolder).name, [subdivideList(iFolder).name,'_group1'], ['lh-Diff-1-', num2str(diag),'-Intercept-thickness'], 'z.mgh'));
        map.zmap2(:,1) = load_mgh(fullfile(outDirTest,subdivideListTest(iFolder).name, [subdivideListTest(iFolder).name,'_group2'], ['lh-Diff-1-', num2str(diagTest),'-Intercept-thickness'], 'z.mgh'));

        map.sigmap1(:,1) = double(10.^(-abs(load_mgh(fullfile(outDir,subdivideList(iFolder).name, [subdivideList(iFolder).name,'_group1'], ['lh-Diff-1-', num2str(diag),'-Intercept-thickness'],'sig.mgh'))))<=thres);
        map.sigmap2(:,1) = double(10.^(-abs(load_mgh(fullfile(outDirTest,subdivideListTest(iFolder).name, [subdivideListTest(iFolder).name,'_group2'], ['lh-Diff-1-', num2str(diagTest),'-Intercept-thickness'],'sig.mgh'))))<=thres);

        % correlation between sites

        corDiagMat= corr([map.zmap1(:,1),map.zmap2(:,1)]);
        corDiag = corDiagMat(1,2);

        corSigMat= bin_corr_mat([map.sigmap1(:,1),map.sigmap2(:,1)]);
        corSig = corSigMat(1,2);
    end

    save(fullfile(outDir,subdivideList(iFolder).name,'corr_surface_nulltest.mat'), 'map', 'corDiag', 'corSig');
    clear  map corDiag corSig
    for iSampleSize = 1:length(sampleSize)
        sampleSizeDir = fullfile(outDir,subdivideList(iFolder).name,['sampleSize_',num2str(sampleSize(iSampleSize))]);
        resampleFolderList = dir(sampleSizeDir);
        resampleFolderList = resampleFolderList([resampleFolderList.isdir]); % Keep only directories
        resampleFolderList = resampleFolderList(~ismember({resampleFolderList.name}, {'.', '..'})); % Remove . and ..
        resampleList = unique(arrayfun(@(x) x.name(1:end-2),resampleFolderList,'UniformOutput',false));

        sampleSizeDirTest = fullfile(outDirTest,subdivideListTest(iFolder).name,['sampleSize_',num2str(sampleSize(iSampleSize))]);
        resampleFolderListTest = dir(sampleSizeDirTest);
        resampleFolderListTest = resampleFolderListTest([resampleFolderListTest.isdir]); % Keep only directories
        resampleFolderListTest = resampleFolderListTest(~ismember({resampleFolderListTest.name}, {'.', '..'})); % Remove . and ..
        resampleListTest = unique(arrayfun(@(x) x.name(1:end-2),resampleFolderListTest,'UniformOutput',false));

        for iSite = 1:length(resampleList)


            % read maps
            if exist(fullfile(sampleSizeDir, [char(resampleList(iSite)),'_1'], ['lh-Diff-1-', num2str(diag),'-Intercept-thickness'], 'z.mgh')) & exist(fullfile(sampleSizeDir, [char(resampleList(iSite)),'_2'], ['lh-Diff-1-', num2str(diag),'-Intercept-thickness'], 'z.mgh'))
                map.zmap1(:,iSite) = load_mgh(fullfile(sampleSizeDir, [char(resampleList(iSite)),'_1'], ['lh-Diff-1-', num2str(diag),'-Intercept-thickness'], 'z.mgh'));
                map.zmap2(:,iSite) = load_mgh(fullfile(sampleSizeDirTest, [char(resampleListTest(iSite)),'_2'], ['lh-Diff-1-', num2str(diagTest),'-Intercept-thickness'], 'z.mgh'));

                map.sigmap1(:,iSite) = double(10.^(-abs(load_mgh(fullfile(sampleSizeDir, [char(resampleList(iSite)),'_1'], ['lh-Diff-1-', num2str(diag),'-Intercept-thickness'],'sig.mgh'))))<=thres);
                map.sigmap2(:,iSite) = double(10.^(-abs(load_mgh(fullfile(sampleSizeDirTest, [char(resampleListTest(iSite)),'_2'], ['lh-Diff-1-', num2str(diagTest),'-Intercept-thickness'],'sig.mgh'))))<=thres);

                % correlation between sites

                corDiagMat= corr([map.zmap1(:,iSite),map.zmap2(:,iSite)]);
                corDiag(iSite) = corDiagMat(1,2);

                corSigMat= bin_corr_mat([map.sigmap1(:,iSite),map.sigmap2(:,iSite)]);
                corSig(iSite) = corSigMat(1,2);
            end
        end




        save(fullfile(sampleSizeDir,'corr_surface_nulltest.mat'), 'map', 'corDiag', 'corSig');
        clear  map corDiag corSig
    end
end
