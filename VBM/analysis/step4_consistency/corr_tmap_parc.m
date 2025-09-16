clear all
close all

addpath('/home/trangc/kg98/trangc/VBM/code/utils')
iCOMBAT = 1;

diagString = {'HC', 'BD', 'SCA',...
    'SCZ', 'ASD', 'MDD','AD' };

    address = ['derivatives/roi/'];


metadata = readtable(['/home/trangc/kg98/trangc/VBM/data/metadataVBM.csv']);
nParc = [100 200 300 400 500 600 700 800 900 1000];

for iParc = 1:length(nParc)
    for iDiag = 1:length(diagString)-1


        [cor1{iDiag} corThres1{iDiag} rep1{iDiag} t1All{iDiag} t1Thres{iDiag} siteList{iDiag}] = cal_corr_tmap_parcel(address, metadata, diagString(iDiag+1), nParc(iParc));

    end

    save(['output/corr_tmap_parc_',num2str(nParc(iParc)),'.mat'], 'cor1', 'corThres1','rep1','t1All', 't1Thres','siteList')
    clear cor1 corThres1 rep1 siteList t1All  t1Thres
end