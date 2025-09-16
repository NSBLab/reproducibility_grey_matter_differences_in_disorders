clear all
close all
addpath('/home/trangc/kg98/trangc/library/Violinplot-Matlab-master')
addpath(genpath('/projects/kg98/trangc/VBM/code'))
addpath('/home/trangc/kg98/trangc/library/fdr_bh')
iCOMBAT = 0;
smoothKernel = 10;


diagString = {'BD', 'SCA',...
    'SCZ', 'ASD', 'MDD','AD' };
diagnosisStr = {'Bipolar', 'Schizoaffective',...
    'Schizophrenia', 'Autism', 'Depression','Alzheimer' };
nDiag = length(diagString);
nTrap = 100;




ob = load(['output/corr_zmap_combat',num2str(iCOMBAT),'_smooth',num2str(smoothKernel),'_all.mat'], 'map','corDiag', 'corSig','siteList');
% load(['output/corr_null_zmap_combat',num2str(iCOMBAT),'_smooth',num2str(smoothKernel),'.mat'], 'corDiagNull', 'corSigNull')

corDiagNullAll = cell(1,6);
corSigNullAll = cell(1,6);
corDiagMaxNullAll = cell(1,6);
corSigMaxNullAll = cell(1,6);
corDiagFdrNullAll = cell(1,6);
corSigFdrNullAll = cell(1,6);
corDiagAll = cell(0,6);
corSigAll = cell(0,6);
for inJob = 1:10
    load( ['/fs04/kg98/trangc/VBM/code/freesurfer/freesurfer_holmesQC/step4_qdec/output/corr_null_eigentrap_zmap_combat',num2str(iCOMBAT),'_smooth',num2str(smoothKernel),'_inJob',char(num2str(inJob)),'.mat'])
    corDiagNull =  cell(1,length(diagString)-1);
    corSigNull =  cell(1,length(diagString)-1);

    corDiagMaxNull =  cell(1,length(diagString)-1);
    corSigMaxNull =  cell(1,length(diagString)-1);
    corDiagFdrNull =  cell(1,length(diagString)-1);
    corSigFdrNull =  cell(1,length(diagString)-1);

    for iDiag = 1:nDiag

        corDiagAll((inJob-1)*nTrap+[1:nTrap],iDiag) = corDiag(:,iDiag);
        corSigAll((inJob-1)*nTrap+[1:nTrap],iDiag)  = corSig(:,iDiag);

        for iNull = 1:nTrap
            ids=find(triu(ones(size(corDiag{iNull,iDiag})),1));
            corDiagVec = corDiag{iNull,iDiag}(ids);
            [va in] = max(abs(corDiagVec),[],'all');
            corDiagMaxNull{iDiag} = [corDiagMaxNull{iDiag};corDiagVec(in)];
            corDiagNull{iDiag} = [corDiagNull{iDiag};corDiagVec];


            corSigVec = corSig{iNull,iDiag}(ids);
            [va in] = max(abs(corSigVec),[],'all');
            corSigMaxNull{iDiag} = [corSigMaxNull{iDiag};corSigVec(in)];
            corSigNull{iDiag} = [corSigNull{iDiag};corSigVec];



        end
    end

    for iDiag = 1:nDiag
        corDiagNullAll{iDiag} = [corDiagNullAll{iDiag};corDiagNull{iDiag}];
        corSigNullAll{iDiag} = [corSigNullAll{iDiag}; corSigNull{iDiag}];
        corDiagMaxNullAll{iDiag} = [corDiagMaxNullAll{iDiag};corDiagMaxNull{iDiag}];
        corSigMaxNullAll{iDiag} = [corSigMaxNullAll{iDiag}; corSigMaxNull{iDiag}];
    end
end


for iDiag = 1:nDiag

    for iCol = 1:width(corDiagAll{1,iDiag})
        for iRow = 1:height(corDiagAll{1,iDiag})
            corDiagnulldis = cellfun(@(x) x(iRow, iCol), corDiagAll(:,iDiag));
            corSignulldis = cellfun(@(x) x(iRow, iCol), corSigAll(:,iDiag));
            % Compute two-tailed p-value
            pCorDiag{iDiag}(iRow, iCol) = mean(abs(corDiagnulldis) >= abs(ob.corDiag{iDiag}(iRow, iCol)));
            pCorSig{iDiag}(iRow, iCol) = mean(abs(corSignulldis) >= abs(ob.corSig{iDiag}(iRow, iCol)));
        end
    end

    [h, crit_p, adj_ci_cvrg, pDiagFdrNullAll{iDiag}] = fdr_bh(pCorDiag{iDiag});
    [h, crit_p, adj_ci_cvrg, pSigFdrNullAll{iDiag}] = fdr_bh(pCorSig{iDiag});
end

save(['output/corr_null_zmap_combat',num2str(iCOMBAT),'_smooth',num2str(smoothKernel),'.mat'],'corDiagNullAll','corSigNullAll','corDiagMaxNullAll','corSigMaxNullAll','pCorDiag','pCorSig')