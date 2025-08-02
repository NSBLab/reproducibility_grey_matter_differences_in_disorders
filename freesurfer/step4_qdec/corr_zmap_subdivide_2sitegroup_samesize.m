clear all
% close all

smoothKernel = 10;
diaglist = 2:7;
hemis = 'lh';

addpath(genpath('/projects/kg98/trangc/VBM/code'))

sampleSizeListAll = {[10    16    25    40    63   100   158   210],...
    [10    16    25    40    63   100   136],...
    [10    16    25    40    63   100   158   251   398 527],...
    [10    16    25    40    63  100 111],...
    [10    16    25    40    63   100   158   231],...
    [10    16    25    40    63   100   158   251   327]};


medianCor = cell(1,length(diaglist));
varCor = cell(1,length(diaglist));

medianCorThres = cell(1,length(diaglist));
varCorThres = cell(1,length(diaglist));

medianRepThres = cell(1,length(diaglist));
varRepThres = cell(1,length(diaglist));

medianCorThresCluster = cell(1,length(diaglist));
varCorThresCluster = cell(1,length(diaglist));

medianRepThresCluster = cell(1,length(diaglist));
varRepThresCluster = cell(1,length(diaglist));
for iDiag = 1:length(diaglist)
    diag = diaglist(iDiag)

    sampleSizeList = sampleSizeListAll{iDiag};
    for isampleSize = 1:length(sampleSizeList);

        sampleSize = sampleSizeList(isampleSize)

        dividemode = ['splitsite_samesize_',char(num2str(sampleSize))]
        dataDir = fullfile('/scratch','kg98','trangc','VBM','data', 'derivatives', 'freesurfer',['s',num2str(smoothKernel),'noCOMBAT'],['diag',num2str(diag)],hemis, ['resample_2sitegroup_',dividemode]);

        subdivideList = dir(dataDir);
        subdivideList = subdivideList([subdivideList.isdir]); % Keep only directories
        subdivideList = subdivideList(~ismember({subdivideList.name}, {'.', '..'})); % Remove . and ..


        icor=1;
        for iFolder = 1:height(subdivideList)
            iFolder
            if exist(fullfile(dataDir,subdivideList(iFolder).name,'corr_surface.mat'))
                divideMat = load(fullfile(dataDir,subdivideList(iFolder).name,'corr_surface.mat'));
                if isfield(divideMat,'repSig')
                    corDivi(icor) = divideMat.corDiag;
                    corDiviThres(icor) = divideMat.corSig;
                    repDiviThres(icor) = divideMat.repSig;

                    if isfield(divideMat,'corSigCluster')
                        corDiviThresCluster(icor) = divideMat.corSigCluster;
                        repDiviThresCluster(icor) = divideMat.repSigCluster;
                    end
                    icor=icor+1;
                end
            end
        end
        if exist('corDivi','var')
            medianCor{iDiag}(isampleSize) = mean(corDivi);
            varCor{iDiag}(isampleSize) = var(corDivi);

            medianCorThres{iDiag}(isampleSize) = mean(corDiviThres);
            varCorThres{iDiag}(isampleSize) = var(corDiviThres);

            medianRepThres{iDiag}(isampleSize) = mean(repDiviThres);
            varCorThres{iDiag}(isampleSize) = var(repDiviThres);
        end
        if exist('corDiviThresCluster','var')

            medianCorThresCluster{iDiag}(isampleSize) = mean(corDiviThresCluster);
            varCorThresCluster{iDiag}(isampleSize) = var(corDiviThresCluster);

            medianRepThresCluster{iDiag}(isampleSize) = mean(repDiviThresCluster);
            varCorThresCluster{iDiag}(isampleSize) = var(repDiviThresCluster);
        end
        clear corDivi corDiviThres repDiviThres corDiviThresCluster repDiviThresCluster
    end

end




save('output/corr_zmap_subdivide_2sitegroup_samesize1.mat')
