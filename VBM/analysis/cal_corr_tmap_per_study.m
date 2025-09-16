function [cor1, cor2, t1Map, t2Map, siteString] = cal_corr_tmap_per_study(address, metadata, diagnosisString,mask)
isDiagSite = strcmp(metadata.diagnosis_string,diagnosisString);
siteIndex = find(isDiagSite==1);

[siteString ia ic] = unique(metadata.site_string(isDiagSite));
datasetList = metadata.dataset(siteIndex(ia)); %datasets in the diagnosis
uniquedatasetList = unique(metadata.dataset(isDiagSite)); %datasets in the diagnosis
nSite = length(siteString);




for iSite = 1:nSite
    t1 = niftiread([ address, char(diagnosisString),'/',char(siteString(iSite)),'/spmT_0001.nii']);
    t2 = niftiread([ address, char(diagnosisString),'/',char(siteString(iSite)),'/spmT_0002.nii']);

    t1Map{iSite} = t1;
    t2Map{iSite} = t2;
    t1All(iSite,:) = reshape(t1(mask),[],1);
    t2All(iSite,:) = reshape(t2(mask),[],1);

end


iConsiderDataset = 0;
 
         cor1={};
          cor2={};
for iDataset = 1:length(uniquedatasetList)

    isSiteInDataset = strcmp(datasetList,uniquedatasetList(iDataset)) %where the dataset appears in the list
    if sum(isSiteInDataset) >= 3 % where there are three or more sites in the dataset
        iConsiderDataset = iConsiderDataset + 1;
        

        cor1{iConsiderDataset} = corr(t1All(isSiteInDataset,:)');
        cor2{iConsiderDataset} = corr(t2All(isSiteInDataset,:)');

   
    end
end


end
