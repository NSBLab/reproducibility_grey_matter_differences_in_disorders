function step10k_corr_zmap_covariate_combine(config)
if nargin < 1 || isempty(config)
    config = 'config_hpc.json';
end
this_dir = fileparts(mfilename('fullpath'));
repo_root = fullfile(this_dir, '..', '..', '..');
addpath(genpath(fullfile(repo_root, 'utils')));
if ischar(config) || isstring(config)
    config = pipeline_load_config(char(config));
end
data_root = config.data_directories.dataset_root;
output_dir = fullfile(data_root, 'results', 'SBM', 'analysis', 'output');

iCOMBAT = 1;
smoothKernel = 10;
thres = 0.05;
hemi = 'lh'

diagnosisString = {'BD', 'SCA',...
    'SCZ', 'ASD', 'MDD','AD' };
conName = {'mean age','var age','male','female','sex ratio','patients','controls','subjects','patient HC ratio','treatment','mean EN','var EN','mean age onset','var age onset','mean illness duration','var illness duration','scanner brand','scanner model','voxel volume'};
nCon = length(conName);
nDiag = length(diagnosisString);




           
% contoplot = table;
for iDiag = 1:nDiag

    iCon = 0;
    iSite = 1;
    load(fullfile(output_dir, 'confound_age.mat'), 'varTable','meanAge', 'stdAge','nSite');
    if ~isempty(varTable{iDiag})
        contoplot(iDiag,iCon+1:iCon+2) = varTable{iDiag}{1,:};
     ptoplot(iDiag,iCon+1:iCon+2) = varTable{iDiag}{2,:};
     nSiteToPlot(iDiag,iCon+1:iCon+2) = nSite{iDiag}*ones(1,2);
    end
iCon = iCon+2;
iSite = iSite+1;

    load(fullfile(output_dir, 'confound_sex.mat'), 'varTable', 'maleRatio', 'femaleRatio', 'subjectRatio', 'maleFemaleRatio','nSite');
    if ~isempty(varTable{iDiag})
        contoplot(iDiag,iCon+1:iCon+3) = varTable{iDiag}{1,[1,2,4]};
     ptoplot(iDiag,iCon+1:iCon+3) = varTable{iDiag}{2,[1,2,4]};
     nSiteToPlot(iDiag,iCon+1:iCon+3) = nSite{iDiag}*ones(1,3);
    end
iCon = iCon+3;
iSite = iSite+1;


    load(fullfile(output_dir, 'confound_nPC.mat'), 'varTable','patientRatio', 'controlRatio', 'subjectRatio', 'patientControlRatio','nSite');
    if ~isempty(varTable{iDiag})
        contoplot(iDiag,iCon+1:iCon+4) = varTable{iDiag}{1,:};
     ptoplot(iDiag,iCon+1:iCon+4) = varTable{iDiag}{2,:};
     nSiteToPlot(iDiag,iCon+1:iCon+4) = nSite{iDiag}*ones(1,4);
    end
     iCon = iCon+4;
     iSite = iSite+1;

    load(fullfile(output_dir, 'confound_treatment.mat'), 'varTable','medRatio', 'nSite');
    if ~isempty(varTable{iDiag})
        contoplot(iDiag,iCon+1) = varTable{iDiag}{1,:};
     ptoplot(iDiag,iCon+1) = varTable{iDiag}{2,:};
     nSiteToPlot(iDiag,iCon+1) = nSite{iDiag};
    end
    iCon = iCon+1;
    iSite = iSite+1;

    load(fullfile(output_dir, 'confound_EN.mat'), 'varTable','meanEN','varEN','nSite');
    if ~isempty(varTable{iDiag})
        contoplot(iDiag,iCon+1:iCon+2) = varTable{iDiag}{1,:};
     ptoplot(iDiag,iCon+1:iCon+2) = varTable{iDiag}{2,:};
    nSiteToPlot(iDiag,iCon+1:iCon+2) = nSite{iDiag}*ones(1,2);
    end
iCon = iCon+2;
iSite = iSite+1;

    load(fullfile(output_dir, 'confound_ageonset.mat'), 'varTable', 'meanAgeOnset', 'stdAgeOnset','nSite');
    if ~isempty(varTable{iDiag})
        contoplot(iDiag,iCon+1:iCon+2) = varTable{iDiag}{1,:};
     ptoplot(iDiag,iCon+1:iCon+2) = varTable{iDiag}{2,:};
     nSiteToPlot(iDiag,iCon+1:iCon+2) = nSite{iDiag}*ones(1,2);
    end
     iCon = iCon+2;
     iSite = iSite+1;

    load(fullfile(output_dir, 'confound_illnessDuration.mat'), 'varTable','meanIllness', 'varIllness','nSite');
    if ~isempty(varTable{iDiag})
        contoplot(iDiag,iCon+1:iCon+2) = varTable{iDiag}{1,:};
     ptoplot(iDiag,iCon+1:iCon+2) = varTable{iDiag}{2,:};
     nSiteToPlot(iDiag,iCon+1:iCon+2) = nSite{iDiag}*ones(1,2);
    end
    iCon = iCon+2;
    iSite = iSite+1;

    load(fullfile(output_dir, 'confound_scanner.mat'), 'varTable','scannerSim','nSite');
    if ~isempty(varTable{iDiag})
        contoplot(iDiag,iCon+1) = varTable{iDiag}{1,:};
     ptoplot(iDiag,iCon+1) = varTable{iDiag}{2,:};
     nSiteToPlot(iDiag,iCon+1) = nSite{iDiag};
    end
    iCon = iCon+1;
    iSite = iSite+1;

    load(fullfile(output_dir, 'confound_scannerModel.mat'), 'varTable','modelSim','nSite');
    if ~isempty(varTable{iDiag})
        contoplot(iDiag,iCon+1) = varTable{iDiag}{1,:};
     ptoplot(iDiag,iCon+1) = varTable{iDiag}{2,:};
     nSiteToPlot(iDiag,iCon+1) = nSite{iDiag};
    end
iCon = iCon+1;
iSite = iSite+1;

    load(fullfile(output_dir, 'confound_vol.mat'), 'varTable','volRatio','nSite');
    if ~isempty(varTable{iDiag})
        contoplot(iDiag,iCon+1) = varTable{iDiag}{1,:};
     ptoplot(iDiag,iCon+1) = varTable{iDiag}{2,:};
     nSiteToPlot(iDiag,iCon+1) = nSite{iDiag};
    end
pvals_bonf(iDiag,:) = min(ptoplot(iDiag,:).* size(ptoplot,2), 1);

end
save(fullfile(output_dir, 'confound_combine.mat'),'ptoplot','pvals_bonf','contoplot','nSiteToPlot');
end
