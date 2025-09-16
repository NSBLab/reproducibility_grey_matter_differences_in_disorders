function [cor1, cor2] = cal_corr_tmap_brainsmash_null(address, metadata, diagnosisString,mask,iNull)
[LaDiag LbDiag] = ismember(metadata.diagnosis_string,diagnosisString);
[siteString ia ic] = unique(metadata.site_string(LaDiag));
nSite = length(siteString);



for iSite = 1:nSite
    file1 = ([address,'/',char(diagnosisString),'/',char(siteString(iSite)),'/spmT_0001_surrogate.txt']);
    % file2 = ([address,'/', char(diagnosisString),'/',char(siteString(iSite)),'/spmT_0002.nii']);
    
    % if isfile(file1) & isfile(file2)
    t1 = readmatrix(file1);
    % t2 = niftiread(file2);
    t1All(iSite,:) = reshape(t1,[],1);
    % t2All(iSite,:) = reshape(t2(mask),[],1);
    % else
    %     cor1 = [];
    %     cor2= [];
    % end

end


cor1 = corr(t1All');
% cor2 = corr(t2All');




end
