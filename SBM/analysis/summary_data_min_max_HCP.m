% Load metadata
filename = '/projects/kg98/trangc/VBM/data/metadataVBM.csv';
metadata = readtable(filename);

% Define diagnosis groups
diagnosisString = {'BD', 'SCA', 'SCZ', 'ASD', 'MDD','AD' };

% Initialize results table
hcPatientStats = table();

for iDiag = 1:length(diagnosisString)
    diag = diagnosisString{iDiag};
    
    % Filter rows for this diagnosis
    diagIdx = strcmp(metadata.diagnosis_string, diag);
    diagData = metadata(diagIdx, :);
    
    sites = unique(diagData.site_string);
    
    siteList = {};
    nHC = [];
    nPatient = [];
    
    for iSite = 1:length(sites)
        site = sites{iSite};
        siteIdx = strcmp(diagData.site_string, site);
        siteData = diagData(siteIdx, :);

        % Count HC and patients
        nHC_site = sum(strcmp(siteData.group, 'HC'));
        nPatient_site = sum(~strcmp(siteData.group, 'HC'));

        % Store counts
        siteList{end+1,1} = site;
        nHC(end+1,1) = nHC_site;
        nPatient(end+1,1) = nPatient_site;
    end
    
    % Compute min, max, and average of HC and patients for this diagnosis
    minHC = min(nHC);
    maxHC = max(nHC);
    avgMinMaxHC = mean([minHC, maxHC]);

    minPatient = min(nPatient);
    maxPatient = max(nPatient);
    avgMinMaxPatient = mean([minPatient, maxPatient]);
    
    % Store results in table
    temp = table({diag}, minHC, maxHC, avgMinMaxHC, minPatient, maxPatient, avgMinMaxPatient, ...
        'VariableNames', {'Diagnosis', 'Min_HC', 'Max_HC', 'Avg_MinMax_HC', 'Min_Patient', 'Max_Patient', 'Avg_MinMax_Patient'});
    
    hcPatientStats = [hcPatientStats; temp];
end

% Display results
disp(hcPatientStats)
