clear all
method = 'VBM' % 'SBM' or 'VBM'
% Step 1: Read the CSV file
if strcmp(method,'SBM')

filename = '/projects/kg98/trangc/VBM/data/metadataSBM.csv';  % Change this to the path of your CSV file
else
    filename = '/projects/kg98/trangc/VBM/data/metadataVBM.csv';  % Change this to the path of your CSV file
end
data = readtable(filename);

% Step 2: List of diagnoses to check
diagnoses = {'HC', 'BD', 'SCA',...
    'SCZ', 'ASD', 'MDD' ,'AD'};
plotorder = [1 7 4 3 5 6 2]; % change the order of disorder appear in the plot
diagnoses = diagnoses(plotorder);
% Step 3: Initialize a table to hold all the results
results = table([],[], [], [], [],[],[],[],...
        'VariableNames', { 'Disorder', 'Number of sites','cases','male case','female case', 'controls','male control','female control'});
dispTable = table([],[], [], [], ...
        'VariableNames', { 'Diagnosis', 'Number of sites','Number of cases(male)', 'Number of controls(male)'});


for d = 2:length(diagnoses)
    
    % Filter data for current diagnosis
    current_diagnosis_data = data(strcmp(data.diagnosis_string, diagnoses{d}), :);

    % Identify relevant sites for current diagnosis
    sites_with_current_diagnosis = unique(current_diagnosis_data.site_string);
    nSite = length(sites_with_current_diagnosis);
    % for i = 1:length(sites_with_current_diagnosis)
    site_data = data(ismember(data.site_string, sites_with_current_diagnosis), :);  % Data for current site

    % Initialize counts for the current site and diagnosis
    diagnosis_count = sum(strcmp(site_data.diagnosis_string, diagnoses{d}));
    male_case_count = sum(strcmp(site_data.diagnosis_string, diagnoses{d}) & strcmp(site_data.sex_string, 'M'));
    female_case_count = sum(strcmp(site_data.diagnosis_string, diagnoses{d}) & strcmp(site_data.sex_string, 'F'));
    controls_count = sum(strcmp(site_data.diagnosis_string, diagnoses{1}));
    male_HC_count = sum(strcmp(site_data.diagnosis_string, diagnoses{1}) & strcmp(site_data.sex_string, 'M'));
    female_HC_count = sum(strcmp(site_data.diagnosis_string, diagnoses{1}) & strcmp(site_data.sex_string, 'F'));


    % Store results in the table
    new_row = {diagnoses{d}, nSite, diagnosis_count, male_case_count,female_case_count,  controls_count, male_HC_count,female_HC_count};
    results = [results; new_row];  % Append new row to the results table
     new_row = {diagnoses{d}, nSite, sprintf('%d (%.f)', diagnosis_count, male_case_count), sprintf('%d (%.f)', controls_count, male_HC_count)};
    dispTable = [dispTable; new_row];  % Append new row to the results table
 
end

nPsyPatient = sum(results.cases(2:6))
nPsyHC  = sum(strcmp(data.diagnosis_string, diagnoses{1}))-results.controls(1)
nDataset = length(unique(data.dataset))
nSite = length(unique(data.site_string))
nSub = height(data)
% Display the results table
disp(results);
disp(dispTable);

% Step 4: Write results to a CSV file
if strcmp(method,'SBM')
writetable(results, '/projects/kg98/trangc/VBM/data/diagnosis_site_counts_SBM.csv');
writetable(dispTable, '/projects/kg98/trangc/VBM/data/diagnosis_site_counts_SBM_manuscript.csv');
else
    
writetable(results, '/projects/kg98/trangc/VBM/data/diagnosis_site_counts_VBM.csv');
writetable(dispTable, '/projects/kg98/trangc/VBM/data/diagnosis_site_counts_VBM_manuscript.csv');
end