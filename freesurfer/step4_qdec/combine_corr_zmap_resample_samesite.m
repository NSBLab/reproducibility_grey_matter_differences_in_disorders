
clear all
% close all
thres = 0.05;
smoothKernel = 10;
diag = 4;
control = 1;
hemi = 'lh';
measure = 'thickness';
dataDir = ['/scratch/kg98/trangc/VBM/data/derivatives/freesurfer/s',char(num2str(smoothKernel)),'COMBAT/resample_samesite'];

sampleSizeList = [2 3 4 6 10];

for iSampleSize=1:length(sampleSizeList)
    nGroup = sampleSizeList(iSampleSize);

    contrastDir = fullfile(dataDir,['nGroup_',num2str(nGroup)]);
    listAll = dir(contrastDir);
    listFolder = {listAll([listAll(:).isdir]).name};
    % command = "ls -d "+ contrastDir+ " > "+ contrastDir+"/dir.txt";
    % system(command);
    % list = readlines(fullfile(contrastDir,'dir.txt'));
    corZAll = [];
    corSigAll = [];
    for iResample = 1:length(listFolder)
        pat = "iResample_"+ char(num2str(iResample))+ "_";

        sampleList = {listFolder{contains(listFolder,pat)}};

        [corZ, corSig] = cal_corr_tmap_resample(contrastDir, sampleList, diag, control, hemi, measure, thres);

        ids=find(triu(ones(size(corZ)),1));

        corZAll = [corZAll;corZ(ids)];
        corSigAll = [corSigAll;corSig(ids)];

    end
    save(fullfile(contrastDir,'cor.mat'),"corZAll","corSigAll");
end