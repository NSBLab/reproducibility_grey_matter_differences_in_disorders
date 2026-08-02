function step9k_corr_tmap_covariate_combine(config)
% STEP9K: Stack confound_*.mat from step9a-j into confound_combine.mat for figures.
% Usage: step9k_corr_tmap_covariate_combine('config_hpc.json')
% Prereq: run step9a through step9j first.
% --- Load config and set paths ---
if nargin < 1 || isempty(config)
    config = 'config_hpc.json';
end
this_dir = fileparts(mfilename('fullpath'));
repo_root = fullfile(this_dir, '..', '..', '..');
addpath(this_dir);
addpath(genpath(fullfile(repo_root, 'utils')));
if ischar(config) || isstring(config)
    config = pipeline_load_config(char(config));
end

% --- Paths from config ---
data_root = config.data_directories.dataset_root;
output_dir = fullfile(data_root, 'results', 'VBM', 'analysis', 'output');

diagnosisString = {'BD', 'SCA',...
    'SCZ', 'ASD', 'MDD','AD' };
conName = {'mean age','var age','male','female','sex ratio','patients','controls','subjects','patient HC ratio','treatment','mean CAT','var CAT','mean age onset','var age onset','mean illness duration','var illness duration','scanner brand','scanner model','voxel size'};
nCon = length(conName);
nDiag = length(diagnosisString);

% --- Load confound_*.mat and build combined tables ---
% contoplot = table;
for iDiag = 1:nDiag

    iCon = 0;
    iSite = 1;
    load(fullfile(output_dir, 'confound_age.mat'), 'varTable','nSite');
    if ~isempty(varTable{iDiag})
        contoplot(iDiag,iCon+1:iCon+2) = varTable{iDiag}{1,:};
     ptoplot(iDiag,iCon+1:iCon+2) = varTable{iDiag}{2,:};
     nSiteToPlot(iDiag,iCon+1:iCon+2) = nSite{iDiag}*ones(1,2);
    end
iCon = iCon+2;
iSite = iSite+1;

    load(fullfile(output_dir, 'confound_sex.mat'), 'varTable','nSite');
    if ~isempty(varTable{iDiag})
        contoplot(iDiag,iCon+1:iCon+3) = varTable{iDiag}{1,[1,2,4]};
     ptoplot(iDiag,iCon+1:iCon+3) = varTable{iDiag}{2,[1,2,4]};
     nSiteToPlot(iDiag,iCon+1:iCon+3) = nSite{iDiag}*ones(1,3);
    end
iCon = iCon+3;
iSite = iSite+1;


    load(fullfile(output_dir, 'confound_nPC.mat'), 'varTable','nSite');
    if ~isempty(varTable{iDiag})
        contoplot(iDiag,iCon+1:iCon+4) = varTable{iDiag}{1,:};
     ptoplot(iDiag,iCon+1:iCon+4) = varTable{iDiag}{2,:};
     nSiteToPlot(iDiag,iCon+1:iCon+4) = nSite{iDiag}*ones(1,4);
    end
     iCon = iCon+4;
     iSite = iSite+1;

    load(fullfile(output_dir, 'confound_treatment.mat'), 'varTable','nSite');
    if ~isempty(varTable{iDiag})
        contoplot(iDiag,iCon+1) = varTable{iDiag}{1,:};
     ptoplot(iDiag,iCon+1) = varTable{iDiag}{2,:};
     nSiteToPlot(iDiag,iCon+1) = nSite{iDiag};
    end
    iCon = iCon+1;
    iSite = iSite+1;

    load(fullfile(output_dir, 'confound_CAT.mat'), 'varTable','nSite');
    if ~isempty(varTable{iDiag})
        contoplot(iDiag,iCon+1:iCon+2) = varTable{iDiag}{1,:};
     ptoplot(iDiag,iCon+1:iCon+2) = varTable{iDiag}{2,:};
    nSiteToPlot(iDiag,iCon+1:iCon+2) = nSite{iDiag}*ones(1,2);
    end
iCon = iCon+2;
iSite = iSite+1;

    load(fullfile(output_dir, 'confound_ageonset.mat'), 'varTable','nSite');
    if ~isempty(varTable{iDiag})
        contoplot(iDiag,iCon+1:iCon+2) = varTable{iDiag}{1,:};
     ptoplot(iDiag,iCon+1:iCon+2) = varTable{iDiag}{2,:};
     nSiteToPlot(iDiag,iCon+1:iCon+2) = nSite{iDiag}*ones(1,2);
    end
     iCon = iCon+2;
     iSite = iSite+1;

    load(fullfile(output_dir, 'confound_illnessDuration.mat'), 'varTable','nSite');
    if ~isempty(varTable{iDiag})
        contoplot(iDiag,iCon+1:iCon+2) = varTable{iDiag}{1,:};
     ptoplot(iDiag,iCon+1:iCon+2) = varTable{iDiag}{2,:};
     nSiteToPlot(iDiag,iCon+1:iCon+2) = nSite{iDiag}*ones(1,2);
    end
    iCon = iCon+2;
    iSite = iSite+1;

    load(fullfile(output_dir, 'confound_scanner.mat'), 'varTable','nSite');
    if ~isempty(varTable{iDiag})
        contoplot(iDiag,iCon+1) = varTable{iDiag}{1,:};
     ptoplot(iDiag,iCon+1) = varTable{iDiag}{2,:};
     nSiteToPlot(iDiag,iCon+1) = nSite{iDiag};
    end
    iCon = iCon+1;
    iSite = iSite+1;

    load(fullfile(output_dir, 'confound_scannerModel.mat'), 'varTable','nSite');
    if ~isempty(varTable{iDiag})
        contoplot(iDiag,iCon+1) = varTable{iDiag}{1,:};
     ptoplot(iDiag,iCon+1) = varTable{iDiag}{2,:};
     nSiteToPlot(iDiag,iCon+1) = nSite{iDiag};
    end
iCon = iCon+1;
iSite = iSite+1;

    load(fullfile(output_dir, 'confound_vol.mat'), 'varTable','nSite');
    if ~isempty(varTable{iDiag})
        contoplot(iDiag,iCon+1) = varTable{iDiag}{1,:};
     ptoplot(iDiag,iCon+1) = varTable{iDiag}{2,:};
     nSiteToPlot(iDiag,iCon+1) = nSite{iDiag};
    end

pvals_bonf(iDiag,:) = min(ptoplot(iDiag,:).* size(ptoplot,2), 1);

end
% --- Save confound_combine.mat ---
save(fullfile(output_dir, 'confound_combine.mat'),'ptoplot','pvals_bonf','contoplot','nSiteToPlot');
end
