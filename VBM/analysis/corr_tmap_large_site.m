clear all
close all
addpath('/home/trangc/kg98/trangc/library/Violinplot-Matlab-master')
iCOMBAT = 0;
smoothKernel = 8;
diagString = {'HC', 'BD', 'SCA',...
    'SCZ', 'ASD', 'MDD' };
if iCOMBAT == 1
    address = ['derivatives/s',num2str(smoothKernel),'COMBAT/'];
else
    address = ['derivatives/s',num2str(smoothKernel),'/'];
end

metadata = readtable(['/home/trangc/kg98/trangc/VBM/data/derivatives/s',num2str(smoothKernel),'COMBAT/metadata.csv']);
mask = logical(niftiread(['/home/trangc/kg98/trangc/VBM/data/derivatives/s',char(num2str(smoothKernel)),'COMBAT/mask_group_mean_bin.nii']));



for iDiag = 1:length(diagString)-1
    LaDiag = metadata.diagnosis==(iDiag+1);
    [siteString ia ic] = unique(metadata.site_string(LaDiag));
    % [siteString] = change_siteName(siteString);
    nSite = length(siteString);
    clear nPC t1All t2All
    iT1 = 0;
iT2 = 0;
    for iSite = 1:nSite
         
        nPC(iSite,1) = sum(LaDiag & ismember(metadata.site_string,siteString(iSite)));
        nPC(iSite,2) = sum(ismember(metadata.diagnosis_string,'HC') & ismember(metadata.site_string,siteString(iSite)));

        if nPC(iSite,1)>=50
            iT1 = iT1+1;
            t1 = niftiread(['/projects/kg98/trangc/VBM/data/', address, char(diagString(iDiag+1)),'/',char(siteString(iSite)),'/spmT_0001.nii']);

            t1All(iT1,:) = reshape(t1(mask),[],1);
        end
        if sum(nPC(iSite,:))>=100
            iT2 = iT2+1;
            t2 = niftiread(['/projects/kg98/trangc/VBM/data/', address, char(diagString(iDiag+1)),'/',char(siteString(iSite)),'/spmT_0001.nii']);

            t2All(iT2,:) = reshape(t2(mask),[],1);
        end
    end
    if exist("t1All")
    cor1{iDiag} = corr(t1All');
    end
       if exist("t2All")
       cor2{iDiag} = corr(t2All');
       end

end

save('output/corr_tmap_large_site.mat', 'cor1', 'cor2')