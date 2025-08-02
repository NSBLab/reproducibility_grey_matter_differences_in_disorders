% read all the z-maps and correlate them
function corr_map_subdivide_aparc_func(diag,dividemode)

smoothKernel = 10;
% sampleSize = [20 40 60 80 100 200 300 400 500];
thres = 0.05;
%diag = 3;
hemis = 'lh';
addpath('/home/trangc/kg98/trangc/MBM/func')
% dividemode = 'nosplitsite';
outDir = fullfile('/scratch','kg98','trangc','VBM','data', 'derivatives', 'freesurfer',['s',num2str(smoothKernel),'noCOMBAT'],['diag',num2str(diag)],hemis, ['resample_2sitegroup_',dividemode]);
subdivideList = dir(outDir);
subdivideList = subdivideList([subdivideList.isdir]); % Keep only directories
subdivideList = subdivideList(~ismember({subdivideList.name}, {'.', '..'})); % Remove . and ..

for iFolder = 1:height(subdivideList)

    if exist(fullfile(outDir,subdivideList(iFolder).name, [subdivideList(iFolder).name,'_group1_aparc'],['lh-Diff-1-', num2str(diag),'-Intercept-thickness'], 'z.mgh')) ...
            & exist(fullfile(outDir,subdivideList(iFolder).name, [subdivideList(iFolder).name,'_group2_aparc'], ['lh-Diff-1-', num2str(diag),'-Intercept-thickness'], 'z.mgh'))
        %& ~exist(fullfile(outDir,subdivideList(iFolder).name,'corr_surface_aparc.mat'))

        map.zmap1(:,1) = load_mgh(fullfile(outDir,subdivideList(iFolder).name, [subdivideList(iFolder).name,'_group1_aparc'], ['lh-Diff-1-', num2str(diag),'-Intercept-thickness'], 'z.mgh'));
        map.zmap2(:,1) = load_mgh(fullfile(outDir,subdivideList(iFolder).name, [subdivideList(iFolder).name,'_group2_aparc'], ['lh-Diff-1-', num2str(diag),'-Intercept-thickness'], 'z.mgh'));

        map.sigmap1(:,1) = double(10.^(-abs(load_mgh(fullfile(outDir,subdivideList(iFolder).name, [subdivideList(iFolder).name,'_group1_aparc'], ['lh-Diff-1-', num2str(diag),'-Intercept-thickness'],'sig.mgh'))))<=thres);
        map.sigmap2(:,1) = double(10.^(-abs(load_mgh(fullfile(outDir,subdivideList(iFolder).name, [subdivideList(iFolder).name,'_group2_aparc'], ['lh-Diff-1-', num2str(diag),'-Intercept-thickness'],'sig.mgh'))))<=thres);

        % correlation between sites

        corDiagMat= corr([map.zmap1(:,1),map.zmap2(:,1)]);
        corDiag = corDiagMat(1,2);

        corSigMat= bin_corr_mat([map.sigmap1(:,1),map.sigmap2(:,1)]);
        corSig = corSigMat(1,2);


        % replication percentage
        if sum(map.sigmap2(:,1))>0
            repli = sum(map.sigmap1(:,1).*map.sigmap2(:,1))/sum(map.sigmap2(:,1));
        else
            repli = 0;
        end
        save(fullfile(outDir,subdivideList(iFolder).name,'corr_surface_aparc.mat'), 'map', 'corDiag', 'corSig','repli');
        clear  map corDiag corSig repli
    end



end
end