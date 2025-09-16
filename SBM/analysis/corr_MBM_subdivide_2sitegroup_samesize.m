clear all
% close all

smoothKernel = 10;
diaglist = 4;
hemis = 'lh';
nMode = 200;
addpath(genpath('/projects/kg98/trangc/VBM/code'))

sampleSizeList = [10    16    25    40    63   100   158   251   398   631];


meanCor = zeros(length(diaglist),length(sampleSizeList));
varCor = zeros(length(diaglist),length(sampleSizeList));
for iDiag = 1:length(diaglist)
    diag = diaglist(iDiag)
    for isampleSize = 1:length(sampleSizeList);

        sampleSize = sampleSizeList(isampleSize);


        dataDir = fullfile('/scratch','kg98','trangc','VBM','data', 'derivatives', 'freesurfer',['s',num2str(smoothKernel),'noCOMBAT'],...
            ['diag',num2str(diag)],hemis, ['resample_2sitegroup_splitsite_samesize_',char(num2str(sampleSize))]);

        subdivideList = dir(dataDir);
        subdivideList = subdivideList([subdivideList.isdir]); % Keep only directories
        subdivideList = subdivideList(~ismember({subdivideList.name}, {'.', '..'})); % Remove . and ..


        icor=1;
        for iFolder = 1:height(subdivideList)
            %
            if exist(fullfile(dataDir,subdivideList(iFolder).name,[subdivideList(iFolder).name,'_group1'],'mbm_uncorrected_1000mode.mat')) & ...
                    exist(fullfile(dataDir,subdivideList(iFolder).name,[subdivideList(iFolder).name,'_group2'],'mbm_uncorrected_1000mode.mat'))
                mbm1 = load(fullfile(dataDir,subdivideList(iFolder).name,[subdivideList(iFolder).name,'_group1'],'mbm_uncorrected_1000mode.mat'));
                mbm2 = load(fullfile(dataDir,subdivideList(iFolder).name,[subdivideList(iFolder).name,'_group2'],'mbm_uncorrected_1000mode.mat'));
                mbm1.MBM.maps.recon= mbm1.MBM.eig.significantBeta(1:nMode) * mbm1.MBM.eig.eig(:,1:nMode)';
                mbm2.MBM.maps.recon = mbm2.MBM.eig.significantBeta(1:nMode) * mbm2.MBM.eig.eig(:,1:nMode)';

                corDiagBeta(icor) = corr(mbm1.MBM.eig.beta(1:nMode)',mbm2.MBM.eig.beta(1:nMode)');
                cortemp = bin_corr_mat_account_zero([double(mbm1.MBM.eig.significantBeta(1:nMode)>0)',double(mbm2.MBM.eig.significantBeta(1:nMode)>0)']);
                corDiagBetaThres(icor) = cortemp(1,2);

                % corDiagGamma(icor) = corr(mbm1.MBM.map.gamma(1:nMode)', mbm2.MBM.map.gamma(1:nMode)');
                % corDiagGammaThres(icor) = bin_corr_mat_account_zero(mbm1.MBM.map.gammaThres(1:nMode)', mbm2.MBM.map.gammaThres(1:nMode)');

                corRecon(icor) = corr(mbm1.MBM.maps.recon', mbm2.MBM.maps.recon');
                % corDivi(icor) = divideMat.corDiag;
                icor=icor+1;
            end
        end
        if exist('corDiagBeta','var')
            meancorDiagBeta(iDiag,isampleSize) = mean(corDiagBeta(~isnan(corDiagBeta)));
            varcorDiagBeta(iDiag,isampleSize) = var(corDiagBeta(~isnan(corDiagBeta)));

            meancorDiagBetaThres(iDiag,isampleSize) = mean(corDiagBetaThres(~isnan(corDiagBetaThres)));
            varcorDiagBetaThres(iDiag,isampleSize) = var(corDiagBetaThres(~isnan(corDiagBetaThres)));

            meancorRecon(iDiag,isampleSize) = mean(corRecon(~isnan(corRecon)));
            varcorRecon(iDiag,isampleSize) = var(corRecon(~isnan(corRecon)));


        end
        save(['output/corr_MBM_diag',char(num2str(diag)),'_subdivide_2sitegroup_samesize_',char(num2str(sampleSize)),'.mat'])
        clear corDiagBeta  corDiagBetaThres  corRecon %corDiagGamma corDiagGammaThres meancorDiagBeta varcorDiagBeta meancorDiagBetaThres varcorDiagBetaThres meancorRecon varcorRecon

    end



end


