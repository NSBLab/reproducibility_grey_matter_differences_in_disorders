clear all
% close all

smoothKernel = 10;
diaglist = 2:7;
hemis = 'lh';

addpath(genpath('/projects/kg98/trangc/VBM/code'))

sampleSizeList = [10    16    25    40    63   100   158   251   398   631];


meanCor = zeros(length(diaglist),length(sampleSizeList));
varCor = zeros(length(diaglist),length(sampleSizeList));
for iDiag = 1:length(diaglist)
    diag = diaglist(iDiag)
    for isampleSize = 1:length(sampleSizeList);

        sampleSize = sampleSizeList(isampleSize);

        dividemode = ['splitsite_samesize_',char(num2str(sampleSize))];
        dataDir = fullfile('/scratch','kg98','trangc','VBM','data', 'derivatives', 'freesurfer',['s',num2str(smoothKernel),'noCOMBAT'],['diag',num2str(diag)],hemis, ['resample_2sitegroup_',dividemode]);

        subdivideList = dir(dataDir);
        subdivideList = subdivideList([subdivideList.isdir]); % Keep only directories
        subdivideList = subdivideList(~ismember({subdivideList.name}, {'.', '..'})); % Remove . and ..


        icor=1;
        for iFolder = 1:height(subdivideList)
            %
            if exist(fullfile(dataDir,subdivideList(iFolder).name,'corr_surface_aparc.mat'))
                divideMat = load(fullfile(dataDir,subdivideList(iFolder).name,'corr_surface_aparc.mat'));

                corDivi(icor) = divideMat.corDiag;
                corDiviThres(icor) = divideMat.corSig;
                repliDivi(icor) = divideMat.repli;
                icor=icor+1;
            end
        end
        if exist('corDivi','var')
            meanCor(iDiag,isampleSize) = mean(corDivi);
            varCor(iDiag,isampleSize) = var(corDivi);

            meanCorThres(iDiag,isampleSize) = mean(corDiviThres);
            varCorThres(iDiag,isampleSize) = var(corDiviThres);

            meanrepliDivi(iDiag,isampleSize) = mean(repliDivi);
            varrepliDivi(iDiag,isampleSize) = var(repliDivi);
            clear corDivi corDiviThres repliDivi
        end

    end


end

save('output/corr_zmap_subdivide_2sitegroup_samesize_aparc.mat')
