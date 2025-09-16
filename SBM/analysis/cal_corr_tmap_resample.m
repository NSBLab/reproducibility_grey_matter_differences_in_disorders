function [corZ, corSig] = cal_corr_tmap_resample(contrastDir,sampleList, diag, control, hemi, measure,thres)



iSiteExist = 0;
for iSite = 1: length(sampleList)
    sample = sampleList{iSite};

    con1Name = fullfile(contrastDir,sample,[hemi,'-Diff-',char(num2str(control)),'-',char(num2str(diag)),'-Intercept-',measure],'z.mgh');
    % con2Name = fullfile(contrastDir,sample,'spmT_0002.nii');

    if exist(con1Name)
        iSiteExist = iSiteExist+1;

        zmap(iSiteExist,:) = load_mgh(con1Name);
        sigmap(iSiteExist,:) = double(10.^(-abs(load_mgh(fullfile(contrastDir,sample,[hemi,'-Diff-',char(num2str(control)),'-',char(num2str(diag)),'-Intercept-',measure],'sig.mgh'))))<=thres);


    end
end

if exist("zmap")
    corZ = corr(zmap');
    corSig = bin_corr_mat(sigmap');

else
    corZ = [];
    corSig = [];
end

end
