
function run_resample_1site_orisite_func(diag,smoothKernel,hemis)
% This script to run GLM with a dataset subsampled from the whole dataset



% ------------------------------------------------------------
% Prep
% ------------------------------------------------------------



% Directories
inDir = '/projects/kg98/trangc/VBM/data';
outDir = fullfile('/scratch','kg98','trangc','VBM','data', 'derivatives', 'freesurfer',['s',num2str(smoothKernel),'noCOMBAT'],['diag',num2str(diag)],hemis, 'resample_1site');
if ~exist(outDir, 'dir')
        mkdir(outDir);
    end 

    % Load in metadata
    % metadataAll = readtable(fullfile(subdivideDir,['iSubdivide_',num2str(iSubdivide),'_seed2group_',num2str(randomSubdivide),'_group',num2str(iGroup),'.txt']),'Delimiter','tab');
    metadataFilename = fullfile(inDir, 'metadataqdecAll.csv');
    metadataAll = readtable(metadataFilename, 'delimiter',',');
    % subsampling subjects
    siteAll = unique(metadataAll.site_string(metadataAll.diagnosis==diag));
   
   
 % nPatient = sum(metadataAll.diagnosis==diag & ismember(metadataAll.site_string,siteChosen));
 
    patientIndex = find(metadataAll.diagnosis==diag & ismember(metadataAll.site_string,siteAll));
 controlIndex = find(metadataAll.diagnosis==1 & ismember(metadataAll.site_string,siteAll));


    

    metadata = metadataAll([patientIndex',controlIndex'],:);
    writetable(metadata,fullfile(outDir,'orisite'),'Delimiter','tab');

end

