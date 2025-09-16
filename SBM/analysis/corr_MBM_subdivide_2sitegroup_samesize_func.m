function corr_MBM_subdivide_2sitegroup_samesize_func(sampleSize,diag,nMode)

smoothKernel = 10;
% diaglist = 4;
hemis = 'lh';

addpath(genpath('/projects/kg98/trangc/VBM/code'))



% for iDiag = 1:length(diaglist)
    % diag = 4;
    % for isampleSize = 1:length(sampleSizeList);

        % sampleSize = sampleSizeList(isampleSize);


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
                mbm1.MBM.maps.recon= mbm1.MBM.eig.beta(1:nMode) * mbm1.MBM.eig.eig(:,1:nMode)';
                mbm2.MBM.maps.recon = mbm2.MBM.eig.beta(1:nMode) * mbm2.MBM.eig.eig(:,1:nMode)';
                mbm1.MBM.maps.reconSig= mbm1.MBM.eig.significantBeta(1:nMode) * mbm1.MBM.eig.eig(:,1:nMode)';
                mbm2.MBM.maps.reconSig = mbm2.MBM.eig.significantBeta(1:nMode) * mbm2.MBM.eig.eig(:,1:nMode)';

                corDiagBeta(icor) = corr(mbm1.MBM.eig.beta(1:nMode)',mbm2.MBM.eig.beta(1:nMode)');
                cortemp = bin_corr_mat_account_zero([double(mbm1.MBM.eig.significantBeta(1:nMode)>0)',double(mbm2.MBM.eig.significantBeta(1:nMode)>0)']);
                corDiagBetaThres(icor) = cortemp(1,2);

                % corDiagGamma(icor) = corr(mbm1.MBM.map.gamma(1:nMode)', mbm2.MBM.map.gamma(1:nMode)');
                % corDiagGammaThres(icor) = bin_corr_mat_account_zero(mbm1.MBM.map.gammaThres(1:nMode)', mbm2.MBM.map.gammaThres(1:nMode)');

                corRecon(icor) = corr(mbm1.MBM.maps.recon', mbm2.MBM.maps.recon');
                corReconSig(icor) = corr(mbm1.MBM.maps.reconSig', mbm2.MBM.maps.reconSig');
                % corDivi(icor) = divideMat.corDiag;
                icor=icor+1;
            end
        end
        if exist('corDiagBeta','var')
            meancorDiagBeta= mean(corDiagBeta(~isnan(corDiagBeta)));
            varcorDiagBeta = var(corDiagBeta(~isnan(corDiagBeta)));

            meancorDiagBetaThres = mean(corDiagBetaThres(~isnan(corDiagBetaThres)));
            varcorDiagBetaThres = var(corDiagBetaThres(~isnan(corDiagBetaThres)));

            meancorRecon = mean(corRecon(~isnan(corRecon)));
            varcorRecon = var(corRecon(~isnan(corRecon)));

            meancorReconSig = mean(corReconSig(~isnan(corReconSig)));
            varcorReconSig = var(corReconSig(~isnan(corReconSig)));


        end
        save(['output/corr_MBM_diag',char(num2str(diag)),'_subdivide_2sitegroup_samesize_',char(num2str(sampleSize)),'_nMode',char(num2str(nMode)),'.mat'],...
            "corDiagBeta",  "corDiagBetaThres",  "corRecon", "corReconSig", "meancorDiagBeta", "varcorDiagBeta", "meancorDiagBetaThres",...
            "varcorDiagBetaThres", "meancorRecon", "varcorRecon","meancorReconSig", "varcorReconSig")
        % clear corDiagBeta  corDiagBetaThres  corRecon %corDiagGamma corDiagGammaThres meancorDiagBeta varcorDiagBeta meancorDiagBetaThres varcorDiagBetaThres meancorRecon varcorRecon

    % end



 end


