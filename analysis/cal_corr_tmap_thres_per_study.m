function [cor1, cor2, rep1, rep2, siteString, varargout] = cal_corr_tmap_thres_per_study(address, metadata, diagnosisString, mask)

addpath('/projects/kg98/trangc/MBM/func')

isDiagSite = strcmp(metadata.diagnosis_string,diagnosisString);
siteIndex = find(isDiagSite==1);

[siteString ia ic] = unique(metadata.site_string(isDiagSite));
datasetList = metadata.dataset(siteIndex(ia)); %datasets in the diagnosis
uniquedatasetList = unique(metadata.dataset(isDiagSite)); %datasets in the diagnosis
nSite = length(siteString);



for iSite = 1:nSite
    t1 = niftiread([address, char(diagnosisString),'/',char(siteString(iSite)),'/spmT_0001_binary.nii']);
    t2 = niftiread([ address, char(diagnosisString),'/',char(siteString(iSite)),'/spmT_0002_binary.nii']);

    t1Map{iSite} = t1;
    t2Map{iSite} = t2;
    t1All(iSite,:) = t1(mask);
    t2All(iSite,:) = t2(mask);

end

iConsiderDataset = 0;

         cor1={};
          cor2={};
          rep1 = {};
          rep2 = {};
for iDataset = 1:length(uniquedatasetList)

    isSiteInDataset = strcmp(datasetList,uniquedatasetList(iDataset)) %where the dataset appears in the list
    if sum(isSiteInDataset) >= 3 % where there are three or more sites in the dataset
        iConsiderDataset = iConsiderDataset + 1;

    cor1{iConsiderDataset} = bin_corr_mat_account_zero(t1All(isSiteInDataset,:)');
    cor2{iConsiderDataset} = bin_corr_mat_account_zero(t2All(isSiteInDataset,:)');

    rep1{iConsiderDataset} = replication_mat(t1All(isSiteInDataset,:)');
    rep2{iConsiderDataset} = replication_mat(t2All(isSiteInDataset,:)');

    end
end
varargout{1} = t1Map;
varargout{2} = t2Map;
end
