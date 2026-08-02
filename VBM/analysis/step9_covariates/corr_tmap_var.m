%% 
% Consider the confound of the number of subjects.
% 
% corDifVar1: ratio of numbers of patients between sites
% 
% corDifVar2: ratio of numbers of HC between sites
% 
% corDifSumVar: ratio of numbers of subjects between sites
% 
% DifVar1vsVar2: ratio of (P/HC) between sites

clear all
close all

iCOMBAT = 0;
smoothKernel = 8;
iter = 5000;
type = 'pearson';

if iCOMBAT == 1
    address = ['derivatives/s',num2str(smoothKernel),'COMBAT/'];
else
    address = ['derivatives/s',num2str(smoothKernel),'/'];
end

metadata = readtable(['/home/trangc/kg98/trangc/VBM/data/derivatives/s',num2str(smoothKernel),'COMBAT/metadata.csv']);

diagnosisString = unique(metadata.diagnosis_string);
diagnosisString = diagnosisString(~ismember(diagnosisString,'HC'));
nDiag = length(diagnosisString);

for iDiag = 1:nDiag
%calculate correlation matrix of tmaps
   [corTmap1, corTmap2] =  cal_cor_tmap(address, metadata, diagnosisString(iDiag));
% correlate the upper triangle of the correlation matrix of tmaps with
% variables
% if ~strcmp(diagnosisString,'ASD')
% [corvar1.sex, pval1.sex] = cal_var(nSex, corTmap1, corTmap2, iter, type);
% end
   varTable = cor_var_nPC(metadata, diagnosisString(iDiag), corTmap1, corTmap2, iter, type);
disp(char(diagnosisString(iDiag)))
disp(varTable)
end
warning('off','last')