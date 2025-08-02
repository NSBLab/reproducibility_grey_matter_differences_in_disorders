function [cor1] = cal_corr_tmap_resample(contrastDir,sampleList,mask)



iSiteExist = 0;
for iSite = 1: length(sampleList)
    sample = sampleList{iSite};

    con1Name = fullfile(contrastDir,sample,'spmT_0001.nii');
    % con2Name = fullfile(contrastDir,sample,'spmT_0002.nii');

    if exist(con1Name) %& exist(con2Name)
        iSiteExist = iSiteExist+1;
        %HC>P
        t1 = niftiread(con1Name);
        %HC<P
        % t2 = niftiread(con2Name);

        t1All(iSiteExist,:) = reshape(t1(mask),[],1);
        % t2All(iSiteExist,:) = reshape(t2(mask),[],1);

    end
end

if exist("t1All")
cor1 = corr(t1All');
% cor2 = corr(t2All');
else
    cor1=[];
end

end
