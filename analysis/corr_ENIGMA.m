clear all

addpath(genpath('/projects/kg98/trangc/ENIGMA/matlab/'))
% list of disorders
diagString = {'HC', 'BD', 'SCA',...
    'SCZ', 'ASD', 'MDD' };
iCOMBAT = 1;
smoothKernel = 10;

% load all site maps
load(['/fs04/kg98/trangc/VBM/code/freesurfer/freesurfer_holmesQC/step4_qdec/corr_surface_aparc.mat'], 'map','corDiag', 'corSig')

% Load summary statistics for ENIGMA-BD
sum_stats = load_summary_stats('bipolar');

% Get case-control surface area table
CT = sum_stats.CortThick_case_vs_controls_adult;
CTAll{2} = CT{1:34,3};

% Load summary statistics for ENIGMA-schizophrenia
sum_stats = load_summary_stats('schizophrenia');

% Get case-control cortical thickness and surface area tables
CT = sum_stats.CortThick_case_vs_controls;
CTAll{4} = CT{1:34,3};

% Load summary statistics for ENIGMA-Autism
sum_stats = load_summary_stats('asd');

% Get case-control cortical thickness table
CT = sum_stats.CortThick_case_vs_controls_meta_analysis;
CTAll{5} = CT{1:34,3};

% Load summary statistics for ENIGMA-MDD
sum_stats = load_summary_stats('depression');

% Get case-control cortical thickness and surface area tables
CT = sum_stats.CortThick_case_vs_controls_adult;
CTAll{6} = CT{1:34,3};

for iDiag = [2,4,5,6]

 isDiagSite = strcmp(map.diag, num2str((iDiag)));
 corENIGMA{iDiag} = corr(map.zmap(isDiagSite,1:34)',CTAll{iDiag});

 siteList{iDiag} = map.site(isDiagSite);
end
save('corr_ENIGMA.mat',  'map','corENIGMA','siteList');