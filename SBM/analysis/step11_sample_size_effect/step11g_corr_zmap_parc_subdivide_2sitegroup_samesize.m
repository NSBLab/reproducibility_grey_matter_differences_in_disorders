clear all
% close all

smoothKernel = 10;
diaglist = 2:7;
hemis = 'lh';

addpath(genpath('/projects/kg98/trangc/VBM/code'))

sampleSizeListAll = {[10    16    25    40    63   100   158   197],...
    [10    16    25    40    63   100   134],...
    [10    16    25    40    63   100   158   251   398 591],...
    [10    16    25    40    63   106],...
    [10    16    25    40    63   100   158   230],...
    [10    16    25    40    63   100   158   251   327]};



medianCor = cell(1,length(diaglist));
varCor = cell(1,length(diaglist));
for iDiag = 1:length(diaglist)
    diag = diaglist(iDiag)
    sampleSizeList = sampleSizeListAll{iDiag};
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
            if exist(fullfile(dataDir,subdivideList(iFolder).name,'corr_furface_SF.mat'))
                divideMat = load(fullfile(dataDir,subdivideList(iFolder).name,'corr_furface_SF.mat'));


                corDiagDK(icor) = divideMat.corDiagDK(1,2);
                corDiagSF100(icor) = divideMat.corDiagSF100(1,2);
                corDiagSF500(icor) = divideMat.corDiagSF500(1,2);
                corDiagSF1000(icor) = divideMat.corDiagSF1000(1,2);
                corSigDK(icor) = divideMat.corSigDK(1,2);
                corSigSF100(icor) = divideMat.corSigSF100(1,2);
                corSigSF500(icor) = divideMat.corSigSF500(1,2);
                corSigSF1000(icor) = divideMat.corSigSF1000(1,2);
                repSigDK(icor) = divideMat.repSigDK(1,2);
                repSigSF100(icor) = divideMat.repSigSF100(1,2);
                repSigSF500(icor) = divideMat.repSigSF500(1,2);
                repSigSF1000(icor) = divideMat.repSigSF1000(1,2);


                icor=icor+1;
            end
        end
        if exist('corDiagDK','var')
            mediancorDiagDK{iDiag}(isampleSize) = median(corDiagDK);
            varcorDiagDK{iDiag}(isampleSize) = var(corDiagDK);

            mediancorDiagSF100{iDiag}(isampleSize) = median(corDiagDK);
            varcorDiagSF100{iDiag}(isampleSize) = var(corDiagSF100);

            mediancorDiagSF500{iDiag}(isampleSize) = median(corDiagSF500);
            varcorDiagSF500{iDiag}(isampleSize) = var(corDiagSF500);

            mediancorDiagSF1000{iDiag}(isampleSize) = median(corDiagSF1000);
            varcorDiagSF1000{iDiag}(isampleSize) = var(corDiagSF1000);

            mediancorSigDK{iDiag}(isampleSize) = mean(corSigDK);
            varcorSigDK{iDiag}(isampleSize) = var(corSigDK);

            mediancorSigSF100{iDiag}(isampleSize) = median(corSigSF100);
            varcorSigSF100{iDiag}(isampleSize) = var(corSigSF100);

            mediancorSigSF500{iDiag}(isampleSize) = median(corSigSF500);
            varcorSigSF500{iDiag}(isampleSize) = var(corSigSF500);

            mediancorSigSF1000{iDiag}(isampleSize) = median(corSigSF1000);
            varcorSigSF1000{iDiag}(isampleSize) = var(corSigSF1000);

            medianrepSigDK{iDiag}(isampleSize) = mean(repSigDK);
            varrepSigDK{iDiag}(isampleSize) = var(repSigDK);

            medianrepSigSF100{iDiag}(isampleSize) = median(repSigSF100);
            varrepSigSF100{iDiag}(isampleSize) = var(repSigSF100);

            medianrepSigSF500{iDiag}(isampleSize) = median(repSigSF500);
            varrepSigSF500{iDiag}(isampleSize) = var(repSigSF500);

            medianrepSigSF1000{iDiag}(isampleSize) = median(repSigSF1000);
            varrepSigSF1000{iDiag}(isampleSize) = var(repSigSF1000);

           
        end
         clear corDiagDK  corDiagDK corDiagSF500  corDiagSF1000 corSigDK corSigSF100 corSigSF500 corSigSF1000  repSigDK repSigSF100 repSigSF500 repSigSF1000

    end


end

save('output/corr_zmap_parc_subdivide_2sitegroup_samesize.mat')
