function [cor1, cor2, rep1, rep2, siteString, varargout] = cal_corr_tmap_thres_average_across_study(address, metadata, diagnosisString, mask, nDiv)

addpath('/projects/kg98/trangc/MBM/func')

isDiagSite = strcmp(metadata.diagnosis_string,diagnosisString);
siteIndex = find(isDiagSite==1);

[siteString ia ic] = unique(metadata.site_string(isDiagSite));
nSiteDiag = length(siteString);
nPerGroup =  floor(nSiteDiag/2);
indexList = 1:nSiteDiag;




for iSite = 1:nSiteDiag
    t1 = niftiread([address, char(diagnosisString),'/',char(siteString(iSite)),'/spmT_0001_binary.nii']);
    t2 = niftiread([ address, char(diagnosisString),'/',char(siteString(iSite)),'/spmT_0002_binary.nii']);

    t1Map{iSite} = t1;
    t2Map{iSite} = t2;
    t1All(iSite,:) = t1(mask);
    t2All(iSite,:) = t2(mask);

end

for iDiv = 1:nDiv
    % divide into two groups of site
    inG1 = randperm(nSiteDiag, nPerGroup);
    inG2 = setdiff(indexList, inG1);  % indices not in the picked set
    sigMapHC_P1 = double(mean(t1All(inG1,:))>=0.5);
    sigMapHC_P2 = double(mean(t1All(inG2,:))>=0.5);
    sigMapP_HC1 = double(mean(t2All(inG1,:))>=0.5);
    sigMapP_HC2 = double(mean(t2All(inG2,:))>=0.5);



    temp = bin_corr_mat_account_zero([sigMapHC_P1',sigMapHC_P2']);
    cor1(iDiv) = temp(1,2);
    temp=bin_corr_mat_account_zero([sigMapP_HC1',sigMapP_HC1']);
    cor2(iDiv) = temp(1,2);
    temp = replication_mat([sigMapHC_P1',sigMapHC_P2']);
    rep1(iDiv) = temp(1,2);
    temp = replication_mat([sigMapP_HC1',sigMapP_HC1']);
    rep2(iDiv) = temp(1,2);

end

varargout{1} = t1Map;
varargout{2} = t2Map;
end
