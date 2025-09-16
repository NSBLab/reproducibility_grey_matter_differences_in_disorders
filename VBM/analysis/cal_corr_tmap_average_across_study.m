function [cor1, cor2, t1Map, t2Map, siteString] = cal_corr_tmap_average_across_study(address, metadata, diagnosisString,mask, nDiv)
isDiagSite = strcmp(metadata.diagnosis_string,diagnosisString);
siteIndex = find(isDiagSite==1);

[siteString ia ic] = unique(metadata.site_string(isDiagSite));
nSiteDiag = length(siteString);
nPerGroup =  floor(nSiteDiag/2);
indexList = 1:nSiteDiag;




for iSite = 1:nSiteDiag
    t1 = niftiread([ address, char(diagnosisString),'/',char(siteString(iSite)),'/spmT_0001.nii']);
    t2 = niftiread([ address, char(diagnosisString),'/',char(siteString(iSite)),'/spmT_0002.nii']);

    t1Map{iSite} = t1;
    t2Map{iSite} = t2;
    t1All(iSite,:) = reshape(t1(mask),[],1);
    t2All(iSite,:) = reshape(t2(mask),[],1);

end


for iDiv = 1:nDiv
    % divide into two groups of site
    inG1 = randperm(nSiteDiag, nPerGroup);
    inG2 = setdiff(indexList, inG1);  % indices not in the picked set
    aveMapG1 = mean(t1All(inG1,:));
    aveMapG2 = mean(t1All(inG2,:));
    cor1(iDiv) = corr(aveMapG1',aveMapG2');

    aveMapG1 = mean(t2All(inG1,:));
    aveMapG2 = mean(t2All(inG2,:));
    cor2(iDiv) = corr(aveMapG1',aveMapG2');
end



end
