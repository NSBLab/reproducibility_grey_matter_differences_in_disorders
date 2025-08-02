clear all
% close all
addpath('/home/trangc/kg98/trangc/VBM/code/utils')

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
    load('/projects/kg98/trangc/VBM/code/freesurfer/freesurfer_holmesQC/step4_qdec/output/confound_age.mat', 'varTable','meanAge', 'stdAge','nSite');
    if ~isempty(varTable{iDiag})
        contoplot(iDiag,iCon+1:iCon+2) = varTable{iDiag}{1,:};
     ptoplot(iDiag,iCon+1:iCon+2) = varTable{iDiag}{2,:};
     nSiteToPlot(iDiag,iCon+1:iCon+2) = nSite{iDiag}*ones(1,2);
    end
iCon = iCon+2;
iSite = iSite+1;

    load('/projects/kg98/trangc/VBM/code/freesurfer/freesurfer_holmesQC/step4_qdec/output/confound_sex.mat', 'varTable', 'maleRatio', 'femaleRatio', 'subjectRatio', 'maleFemaleRatio','nSite');
    if ~isempty(varTable{iDiag})
        contoplot(iDiag,iCon+1:iCon+3) = varTable{iDiag}{1,[1,2,4]};
     ptoplot(iDiag,iCon+1:iCon+3) = varTable{iDiag}{2,[1,2,4]};
     nSiteToPlot(iDiag,iCon+1:iCon+3) = nSite{iDiag}*ones(1,3);
    end
iCon = iCon+3;
iSite = iSite+1;


    load('/projects/kg98/trangc/VBM/code/freesurfer/freesurfer_holmesQC/step4_qdec/output/confound_nPC.mat', 'varTable','patientRatio', 'controlRatio', 'subjectRatio', 'patientControlRatio','nSite');
    if ~isempty(varTable{iDiag})
        contoplot(iDiag,iCon+1:iCon+4) = varTable{iDiag}{1,:};
     ptoplot(iDiag,iCon+1:iCon+4) = varTable{iDiag}{2,:};
     nSiteToPlot(iDiag,iCon+1:iCon+4) = nSite{iDiag}*ones(1,4);
    end
     iCon = iCon+4;
     iSite = iSite+1;

    load('/projects/kg98/trangc/VBM/code/freesurfer/freesurfer_holmesQC/step4_qdec/output/confound_treatment.mat', 'varTable','medRatio', 'nSite');
    if ~isempty(varTable{iDiag})
        contoplot(iDiag,iCon+1) = varTable{iDiag}{1,:};
     ptoplot(iDiag,iCon+1) = varTable{iDiag}{2,:};
     nSiteToPlot(iDiag,iCon+1) = nSite{iDiag};
    end
    iCon = iCon+1;
    iSite = iSite+1;

    load('/projects/kg98/trangc/VBM/code/freesurfer/freesurfer_holmesQC/step4_qdec/output/confound_EN.mat', 'varTable','meanEN','varEN','nSite');
    if ~isempty(varTable{iDiag})
        contoplot(iDiag,iCon+1:iCon+2) = varTable{iDiag}{1,:};
     ptoplot(iDiag,iCon+1:iCon+2) = varTable{iDiag}{2,:};
    nSiteToPlot(iDiag,iCon+1:iCon+2) = nSite{iDiag}*ones(1,2);
    end
iCon = iCon+2;
iSite = iSite+1;

    load('/projects/kg98/trangc/VBM/code/freesurfer/freesurfer_holmesQC/step4_qdec/output/confound_ageonset.mat', 'varTable', 'meanAgeOnset', 'stdAgeOnset','nSite');
    if ~isempty(varTable{iDiag})
        contoplot(iDiag,iCon+1:iCon+2) = varTable{iDiag}{1,:};
     ptoplot(iDiag,iCon+1:iCon+2) = varTable{iDiag}{2,:};
     nSiteToPlot(iDiag,iCon+1:iCon+2) = nSite{iDiag}*ones(1,2);
    end
     iCon = iCon+2;
     iSite = iSite+1;

    load('/projects/kg98/trangc/VBM/code/freesurfer/freesurfer_holmesQC/step4_qdec/output/confound_illnessDuration.mat', 'varTable','meanIllness', 'varIllness','nSite');
    if ~isempty(varTable{iDiag})
        contoplot(iDiag,iCon+1:iCon+2) = varTable{iDiag}{1,:};
     ptoplot(iDiag,iCon+1:iCon+2) = varTable{iDiag}{2,:};
     nSiteToPlot(iDiag,iCon+1:iCon+2) = nSite{iDiag}*ones(1,2);
    end
    iCon = iCon+2;
    iSite = iSite+1;

    load('/projects/kg98/trangc/VBM/code/freesurfer/freesurfer_holmesQC/step4_qdec/output/confound_scanner.mat', 'varTable','scannerSim','nSite');
    if ~isempty(varTable{iDiag})
        contoplot(iDiag,iCon+1) = varTable{iDiag}{1,:};
     ptoplot(iDiag,iCon+1) = varTable{iDiag}{2,:};
     nSiteToPlot(iDiag,iCon+1) = nSite{iDiag};
    end
    iCon = iCon+1;
    iSite = iSite+1;

    load('/projects/kg98/trangc/VBM/code/freesurfer/freesurfer_holmesQC/step4_qdec/output/confound_scannerModel.mat', 'varTable','modelSim','nSite');
    if ~isempty(varTable{iDiag})
        contoplot(iDiag,iCon+1) = varTable{iDiag}{1,:};
     ptoplot(iDiag,iCon+1) = varTable{iDiag}{2,:};
     nSiteToPlot(iDiag,iCon+1) = nSite{iDiag};
    end
iCon = iCon+1;
iSite = iSite+1;

    load('/projects/kg98/trangc/VBM/code/freesurfer/freesurfer_holmesQC/step4_qdec/output/confound_vol.mat', 'varTable','volRatio','nSite');
    if ~isempty(varTable{iDiag})
        contoplot(iDiag,iCon+1) = varTable{iDiag}{1,:};
     ptoplot(iDiag,iCon+1) = varTable{iDiag}{2,:};
     nSiteToPlot(iDiag,iCon+1) = nSite{iDiag};
    end
pvals_bonf(iDiag,:) = min(ptoplot(iDiag,:).* size(ptoplot,2), 1);

end
save('output/confound_combine.mat','ptoplot','pvals_bonf','contoplot','nSiteToPlot');
