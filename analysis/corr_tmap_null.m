clear all
close all
addpath('/projects/kg98/trangc/library/Violinplot-Matlab-master')
addpath('/projects/kg98/trangc/VBM/code/freesurfer/freesurfer_holmesQC/step4_qdec')
iCOMBAT = 0;
smoothKernel = 6;
diagString = {'HC', 'BD', 'SCA'}; %'SCZ', 'ASD', 'MDD' ,'AD'};
if iCOMBAT == 1
    address = ['/scratch2/kg98/trangc/VBM/data/derivatives/s',num2str(smoothKernel),'COMBATnull/'];
else
    address = ['/scratch2/kg98/trangc/VBM/data/derivatives/s',num2str(smoothKernel),'null/'];
end

metadata = readtable(['/projects/kg98/trangc/VBM/data/metadataVBM_psy.csv']);
metadataAD = readtable(['/projects/kg98/trangc/VBM/data/metadataVBM_AD.csv']);

mask = logical(niftiread(['/projects/kg98/trangc/VBM/data/derivatives/s',char(num2str(smoothKernel)),'COMBAT/mask_psy/mask.nii']));
maskAD = logical(niftiread(['/projects/kg98/trangc/VBM/data/derivatives/s',char(num2str(smoothKernel)),'COMBAT/mask_AD/mask.nii']));

corNullToPlot = cell(1,length(diagString)-1);
corThresNullToPlot = cell(1,length(diagString)-1);
corThresFWENullToPlot = cell(1,length(diagString)-1);
iNullList = [1:100];%,101:160,201:246];
for i = 1:length(iNullList)
    iNull = iNullList(i);
    for iSite = 1:length(diagString)-1
        [LaDiag LbDiag] = ismember(metadata.diagnosis,num2str((iSite+1)));
        [siteString ia ic] = unique(metadata.site_string(LaDiag));
        [siteString] = change_siteName(siteString);
        if iSite==6
            [cor1{iSite}, cor2{iSite}] = cal_corr_tmap_null(address, metadataAD, diagString(iSite+1), maskAD,iNull);
            % [corThres1{iSite}, corThres2{iSite}, rowst1_without_zeros{iSite}, rowst2_without_zeros{iSite}] = cal_corr_tmap_null_thres(address, metadataAD, diagString(iSite+1), maskAD,iNull);
            % [corThresFWE1{iSite}, corThresFWE2{iSite}, rowst1_without_zerosFWE{iSite}, rowst2_without_zerosFWE{iSite}] = cal_corr_tmap_null_thres_fwe(address, metadataAD, diagString(iSite+1), maskAD,iNull);

        else
            [cor1{iSite}, cor2{iSite}] = cal_corr_tmap_null(address, metadata, diagString(iSite+1), mask, iNull);
            % [corThres1{iSite}, corThres2{iSite}, rowst1_without_zeros{iSite}, rowst2_without_zeros{iSite}] = cal_corr_tmap_null_thres(address, metadata, diagString(iSite+1), mask,iNull);
            % [corThresFWE1{iSite}, corThresFWE2{iSite}, rowst1_without_zerosFWE{iSite}, rowst2_without_zerosFWE{iSite}] = cal_corr_tmap_null_thres_fwe(address, metadata, diagString(iSite+1), mask,iNull);

        end
        ids{iSite}=find(triu(ones(size(cor1{iSite})),1));
        corNullToPlot{iSite} = [corNullToPlot{iSite};cor1{iSite}(ids{iSite})];
        % idsThres{iSite}=find(triu(ones(size(corThres1{iSite})),1));
        % corThresNullToPlot{iSite} = [corThresNullToPlot{iSite};corThres1{iSite}(idsThres{iSite})];
        % idsThresFWE{iSite}=find(triu(ones(size(corThresFWE1{iSite})),1));
        % corThresFWENullToPlot{iSite} = [corThresFWENullToPlot{iSite};corThresFWE1{iSite}(idsThresFWE{iSite})];
    end

    save(['/scratch2/kg98/trangc/VBM/data/derivatives/s',num2str(smoothKernel),'COMBATnull/',num2str(iNull),'/corr_tmap_null.mat'], 'cor1', 'cor2');%,'corThres1','corThres2','corThresFWE1','corThresFWE2');
end
%%
save(['output/corr_null_tmap_combat',num2str(iCOMBAT),'_smooth',num2str(smoothKernel),'.mat'], 'corNullToPlot', 'corThresNullToPlot', 'corThresFWENullToPlot')