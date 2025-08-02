clear all
close all

addpath('/home/trangc/kg98/trangc/VBM/code/utils')
iCOMBAT = 1;
smoothKernel = 6;
diagString = {'HC', 'BD', 'SCA',...
    'SCZ', 'ASD', 'MDD' ,'AD'};

address = ['derivatives/roi/'];

metadata = readtable(['/home/trangc/kg98/trangc/VBM/data/metadataVBM.csv']);
nParc = [100 500 1000];
nNull = 100;

corNull = cell(1,length(diagString)-1);

for iParc = 1:length(nParc)


    for iDiag = 1:length(diagString)-1

        [corNull{iDiag} corThresNull{iDiag} repThresNull{iDiag} siteList{iDiag}] = cal_corr_tmap_parcel_null( metadata, diagString(iDiag+1), nParc(iParc), nNull);
       
    end

    save(['output/corr_null_tmap_parc_',num2str(nParc(iParc)),'.mat'], 'corNull','corThresNull', 'repThresNull', 'siteList')
    clear corNull corThresNull repThresNull siteList
end