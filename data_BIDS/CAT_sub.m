%% remove error subjects from subject_use_extract.txt

% Trang Cao, Neural Systems and Behaviour Lab, Monash University, 2022.

clear all
close all

study = 'BSNIP2';

sub = readlines(['/projects/kg98/trangc/VBM/data/', study, '/subject_use_extract.txt']);
subErr = readlines(['/projects/kg98/trangc/VBM/data/', study, '/subject_err.txt']);

iErr = ismember(sub, subErr);

subCAT = sub(iErr==0);

writelines(subCAT, ['/projects/kg98/trangc/VBM/data/', study, '/subject_CAT.txt']);