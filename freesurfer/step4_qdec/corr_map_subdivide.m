% read all the z-maps and correlate them


clear all
smoothKernel = 10;
sampleSize = [20 40 60 80 100 200 300 400 500 600 700];
thres = 0.05;
diaglist = [2:7];
for iDiag = 1:length(diaglist)
    diag = diaglist(iDiag);
    hemis = 'lh';
    addpath('/home/trangc/kg98/trangc/MBM/func')
    dividemode = 'splitsite';
    outDir = fullfile('/scratch','kg98','trangc','VBM','data', 'derivatives', 'freesurfer',['s',num2str(smoothKernel),'noCOMBAT'],['diag',num2str(diag)],hemis, ['resample_2sitegroup_',dividemode]);
    subdivideList = dir(outDir);
    subdivideList = subdivideList([subdivideList.isdir]); % Keep only directories
    subdivideList = subdivideList(~ismember({subdivideList.name}, {'.', '..'})); % Remove . and ..

    for iFolder = 1:height(subdivideList)

        if exist(fullfile(outDir,subdivideList(iFolder).name, [subdivideList(iFolder).name,'_group1'],['lh-Diff-1-', num2str(diag),'-Intercept-thickness'], 'z.mgh')) ...
                & exist(fullfile(outDir,subdivideList(iFolder).name, [subdivideList(iFolder).name,'_group2'], ['lh-Diff-1-', num2str(diag),'-Intercept-thickness'], 'z.mgh'))...
                & ~exist(fullfile(outDir,subdivideList(iFolder).name,'corr_surface.mat'))

            map.zmap1(:,1) = load_mgh(fullfile(outDir,subdivideList(iFolder).name, [subdivideList(iFolder).name,'_group1'], ['lh-Diff-1-', num2str(diag),'-Intercept-thickness'], 'z.mgh'));
            map.zmap2(:,1) = load_mgh(fullfile(outDir,subdivideList(iFolder).name, [subdivideList(iFolder).name,'_group2'], ['lh-Diff-1-', num2str(diag),'-Intercept-thickness'], 'z.mgh'));
            temp1 = load_mgh(fullfile(outDir,subdivideList(iFolder).name, [subdivideList(iFolder).name,'_group1'], ['lh-Diff-1-', num2str(diag),'-Intercept-thickness'],'sig.mgh'));
            temp2 = load_mgh(fullfile(outDir,subdivideList(iFolder).name, [subdivideList(iFolder).name,'_group2'], ['lh-Diff-1-', num2str(diag),'-Intercept-thickness'],'sig.mgh'));
            map.sigmap1(:,1) = double(10.^(-(temp1))<=thres);
            map.sigmap2(:,1) = double(10.^(-(temp2))<=thres);
            [h, crit_p, adj_ci_cvrg, adj_p1] = fdr_bh(10.^(-(temp1)).*(temp1>0)+10.^((temp1)).*(temp1<=0));
            [h, crit_p, adj_ci_cvrg, adj_p2] = fdr_bh(10.^(-(temp2)).*(temp2>0)+10.^((temp2)).*(temp2<=0));
            map.sigFdrmap1(:,1) = double((adj_p1<=thres).*(temp1>0));
            map.sigFdrmap2(:,1) = double((adj_p2<=thres).*(temp2>0));


            % correlation between sites

            corDiagMat= corr([map.zmap1(:,1),map.zmap2(:,1)]);
            corDiag = corDiagMat(1,2);

            corSigMat= bin_corr_mat([map.sigmap1(:,1),map.sigmap2(:,1)]);
            corSig = corSigMat(1,2);
            save(fullfile(outDir,subdivideList(iFolder).name,'corr_surface.mat'), 'map', 'corDiag', 'corSig');
            clear  map corDiag corSig
        end


        for iSampleSize = 1:length(sampleSize)
            sampleSizeDir = fullfile(outDir,subdivideList(iFolder).name,['sampleSize_',num2str(sampleSize(iSampleSize))]);

            resampleFolderList = dir(sampleSizeDir);
            resampleFolderList = resampleFolderList([resampleFolderList.isdir]); % Keep only directories
            resampleFolderList = resampleFolderList(~ismember({resampleFolderList.name}, {'.', '..'})); % Remove . and ..
            resampleList = unique(arrayfun(@(x) x.name(1:end-2),resampleFolderList,'UniformOutput',false));
            if ~exist(fullfile(sampleSizeDir,'corr_surface.mat')) & length(resampleList)>0

                for iSite = 1:length(resampleList)


                    % read maps
                    if exist(fullfile(sampleSizeDir, [char(resampleList(iSite)),'_1'], ['lh-Diff-1-', num2str(diag),'-Intercept-thickness'], 'z.mgh')) ...
                            & exist(fullfile(sampleSizeDir, [char(resampleList(iSite)),'_2'], ['lh-Diff-1-', num2str(diag),'-Intercept-thickness'], 'z.mgh'))
                        map.zmap1(:,iSite) = load_mgh(fullfile(sampleSizeDir, [char(resampleList(iSite)),'_1'], ['lh-Diff-1-', num2str(diag),'-Intercept-thickness'], 'z.mgh'));
                        map.zmap2(:,iSite) = load_mgh(fullfile(sampleSizeDir, [char(resampleList(iSite)),'_2'], ['lh-Diff-1-', num2str(diag),'-Intercept-thickness'], 'z.mgh'));

                        map.sigmap1(:,iSite) = double(10.^(-abs(load_mgh(fullfile(sampleSizeDir, [char(resampleList(iSite)),'_1'], ['lh-Diff-1-', num2str(diag),'-Intercept-thickness'],'sig.mgh'))))<=thres);
                        map.sigmap2(:,iSite) = double(10.^(-abs(load_mgh(fullfile(sampleSizeDir, [char(resampleList(iSite)),'_2'], ['lh-Diff-1-', num2str(diag),'-Intercept-thickness'],'sig.mgh'))))<=thres);

                        % correlation between sites

                        corDiagMat= corr([map.zmap1(:,iSite),map.zmap2(:,iSite)]);
                        corDiag(iSite) = corDiagMat(1,2);

                        corSigMat= bin_corr_mat([map.sigmap1(:,iSite),map.sigmap2(:,iSite)]);
                        corSig(iSite) = corSigMat(1,2);
                    end
                end




                save(fullfile(sampleSizeDir,'corr_surface.mat'), 'map', 'corDiag', 'corSig');
                clear  map corDiag corSig
            end
        end
    end
end
