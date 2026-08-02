function [corTmap1, corTmap2] = cal_cor_tmap(address, metadata, diagnosisString)
% calculate correlation matix of the t-maps for each disorder
%
% input:
%       address: part of path
%       metadata
%       diagnosisString
%
% output:
%       corTmap1: correlation matrix of tmap HC>P
%       corTmap2: correlation matrix of tmap HC<P


[LaDiag LbDiag] = ismember(metadata.diagnosis_string,diagnosisString);
[siteString ia ic] = unique(metadata.site_string(LaDiag));
nSite = length(siteString);

 mask = logical(niftiread(['/home/trangc/kg98/trangc/VBM/data/derivatives/s8COMBAT/mask_group_mean_bin.nii']));

for iSite = 1:nSite
    t1 = niftiread(['/projects/kg98/trangc/VBM/data/', address, char(diagnosisString),'/',char(siteString(iSite)),'/spmT_0001.nii']);
    t2 = niftiread(['/projects/kg98/trangc/VBM/data/', address, char(diagnosisString),'/',char(siteString(iSite)),'/spmT_0002.nii']);

    t1All(iSite,:) = reshape(t1(mask),[],1);
    t2All(iSite,:) = reshape(t2(mask),[],1);

end


corTmap1 = corr(t1All');
corTmap2 = corr(t2All');

end