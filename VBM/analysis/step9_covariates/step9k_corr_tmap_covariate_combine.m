clear all
% close all
addpath('/home/trangc/kg98/trangc/VBM/code/utils')

iCOMBAT = 1;
smoothKernel = 6;
thres = 0.05;

diagnosisString = {'BD', 'SCA',...
    'SCZ', 'ASD', 'MDD','AD' };
conName = {'mean age','var age','male','female','sex ratio','patients','controls','subjects','patient HC ratio','treatment','mean CAT','var CAT','mean age onset','var age onset','mean illness duration','var illness duration','scanner brand','scanner model','voxel size'};
nCon = length(conName);
nDiag = length(diagnosisString);




           
% contoplot = table;
for iDiag = 1:nDiag

    iCon = 0;
    iSite = 1;
    load('/projects/kg98/trangc/VBM/code/analysis/output/confound_age.mat', 'varTable','nSite');
    if ~isempty(varTable{iDiag})
        contoplot(iDiag,iCon+1:iCon+2) = varTable{iDiag}{1,:};
     ptoplot(iDiag,iCon+1:iCon+2) = varTable{iDiag}{2,:};
     nSiteToPlot(iDiag,iCon+1:iCon+2) = nSite{iDiag}*ones(1,2);
    end
iCon = iCon+2;
iSite = iSite+1;

    load('/projects/kg98/trangc/VBM/code/analysis/output/confound_sex.mat', 'varTable','nSite');
    if ~isempty(varTable{iDiag})
        contoplot(iDiag,iCon+1:iCon+3) = varTable{iDiag}{1,[1,2,4]};
     ptoplot(iDiag,iCon+1:iCon+3) = varTable{iDiag}{2,[1,2,4]};
     nSiteToPlot(iDiag,iCon+1:iCon+3) = nSite{iDiag}*ones(1,3);
    end
iCon = iCon+3;
iSite = iSite+1;


    load('/projects/kg98/trangc/VBM/code/analysis/output/confound_nPC.mat', 'varTable','nSite');
    if ~isempty(varTable{iDiag})
        contoplot(iDiag,iCon+1:iCon+4) = varTable{iDiag}{1,:};
     ptoplot(iDiag,iCon+1:iCon+4) = varTable{iDiag}{2,:};
     nSiteToPlot(iDiag,iCon+1:iCon+4) = nSite{iDiag}*ones(1,4);
    end
     iCon = iCon+4;
     iSite = iSite+1;

    load('/projects/kg98/trangc/VBM/code/analysis/output/confound_treatment.mat', 'varTable','nSite');
    if ~isempty(varTable{iDiag})
        contoplot(iDiag,iCon+1) = varTable{iDiag}{1,:};
     ptoplot(iDiag,iCon+1) = varTable{iDiag}{2,:};
     nSiteToPlot(iDiag,iCon+1) = nSite{iDiag};
    end
    iCon = iCon+1;
    iSite = iSite+1;

    load('/projects/kg98/trangc/VBM/code/analysis/output/confound_CAT.mat', 'varTable','nSite');
    if ~isempty(varTable{iDiag})
        contoplot(iDiag,iCon+1:iCon+2) = varTable{iDiag}{1,:};
     ptoplot(iDiag,iCon+1:iCon+2) = varTable{iDiag}{2,:};
    nSiteToPlot(iDiag,iCon+1:iCon+2) = nSite{iDiag}*ones(1,2);
    end
iCon = iCon+2;
iSite = iSite+1;

    load('/projects/kg98/trangc/VBM/code/analysis/output/confound_ageonset.mat', 'varTable','nSite');
    if ~isempty(varTable{iDiag})
        contoplot(iDiag,iCon+1:iCon+2) = varTable{iDiag}{1,:};
     ptoplot(iDiag,iCon+1:iCon+2) = varTable{iDiag}{2,:};
     nSiteToPlot(iDiag,iCon+1:iCon+2) = nSite{iDiag}*ones(1,2);
    end
     iCon = iCon+2;
     iSite = iSite+1;

    load('/projects/kg98/trangc/VBM/code/analysis/output/confound_illnessDuration.mat', 'varTable','nSite');
    if ~isempty(varTable{iDiag})
        contoplot(iDiag,iCon+1:iCon+2) = varTable{iDiag}{1,:};
     ptoplot(iDiag,iCon+1:iCon+2) = varTable{iDiag}{2,:};
     nSiteToPlot(iDiag,iCon+1:iCon+2) = nSite{iDiag}*ones(1,2);
    end
    iCon = iCon+2;
    iSite = iSite+1;

    load('/projects/kg98/trangc/VBM/code/analysis/output/confound_scanner.mat', 'varTable','nSite');
    if ~isempty(varTable{iDiag})
        contoplot(iDiag,iCon+1) = varTable{iDiag}{1,:};
     ptoplot(iDiag,iCon+1) = varTable{iDiag}{2,:};
     nSiteToPlot(iDiag,iCon+1) = nSite{iDiag};
    end
    iCon = iCon+1;
    iSite = iSite+1;

    load('/projects/kg98/trangc/VBM/code/analysis/output/confound_scannerModel.mat', 'varTable','nSite');
    if ~isempty(varTable{iDiag})
        contoplot(iDiag,iCon+1) = varTable{iDiag}{1,:};
     ptoplot(iDiag,iCon+1) = varTable{iDiag}{2,:};
     nSiteToPlot(iDiag,iCon+1) = nSite{iDiag};
    end
iCon = iCon+1;
iSite = iSite+1;

    load('/projects/kg98/trangc/VBM/code/analysis/output/confound_vol.mat', 'varTable','nSite');
    if ~isempty(varTable{iDiag})
        contoplot(iDiag,iCon+1) = varTable{iDiag}{1,:};
     ptoplot(iDiag,iCon+1) = varTable{iDiag}{2,:};
     nSiteToPlot(iDiag,iCon+1) = nSite{iDiag};
    end

pvals_bonf(iDiag,:) = min(ptoplot(iDiag,:).* size(ptoplot,2), 1);

end
save('output/confound_combine.mat','ptoplot','pvals_bonf','contoplot','nSiteToPlot');
