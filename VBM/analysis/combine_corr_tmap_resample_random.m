
clear all
% close all

smoothKernel = 8;
maskFile = ['/projects/kg98/trangc/VBM/data/derivatives/s',num2str(smoothKernel),'COMBAT/mask_group_mean_bin.nii'];

mask = logical(niftiread(maskFile));

dataDir = fullfile('/scratch','kg98','trangc','VBM','data','derivatives',['s',num2str(smoothKernel)],'resampleRandom');

sampleSizeList = [371];%[20,40,60,100,123,148,185,247,371];

for iSampleSize=1:length(sampleSizeList)
    sampleSize = sampleSizeList(iSampleSize);

    contrastDir = fullfile(dataDir,['sampleSize_',num2str(sampleSize)]);
    listAll = dir(contrastDir);
    listFolder = {listAll([listAll(:).isdir]).name};
    % command = "ls -d "+ contrastDir+ " > "+ contrastDir+"/dir.txt";
    % system(command);
    % list = readlines(fullfile(contrastDir,'dir.txt'));
    cor = [];
    for iResample = 1:length(listFolder)
        pat = "iResample_"+ char(num2str(iResample))+ "_";

        sampleList = {listFolder{contains(listFolder,pat)}};

        [cor1] = cal_corr_tmap_resample(contrastDir,sampleList, mask);

        ids=find(triu(ones(size(cor1)),1));

        cor = [cor;cor1(ids)];

    end
    save(fullfile(contrastDir,'cor.mat'),"cor");
end