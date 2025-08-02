clear all
% Step 1: Read the CSV file
filename = '/projects/kg98/trangc/VBM/data/metadataSBM.csv';  % Change this to the path of your CSV file
data = readtable(filename);
% data.site_string(strcmp(data.site_string,'Signa HDxt')==1) = {'Signa_HDxt'};
load(['output/corr_zmap_combat1_smooth10_lh_all.mat'], 'siteList')
 % load('/home/trangc/kg98/trangc/VBM/code/analysis/output/corr_tmap_combat1_smooth6.mat', 'siteList')
%% Step 2: List of diagnoses to check
diagnoses = {'HC', 'BD', 'SCA',...
    'SCZ', 'ASD', 'MDD' ,'AD'};

% Step 3: Initialize a table to hold all the results
results = table([],[],[],[],[], 'VariableNames', {'Diagnosis', 'Index', 'Site', 'Dataset', ...
    'sub_No'});

inAll = 0;
for d = 2:length(diagnoses) % Start from 2 to skip 'HC' as it is used as control
     index = 0;
    % Filter data for current diagnosis
    current_diagnosis_data = data(strcmp(data.diagnosis_string, diagnoses{d}), :);

    % Identify relevant sites for current diagnosis
    sites_with_current_diagnosis = unique(current_diagnosis_data.site_string);
    % Step 5: Reorder the results based on siteList
    [~, order] = ismember(siteList{d-1}, sites_with_current_diagnosis);
    sites_with_current_diagnosis = sites_with_current_diagnosis(order);

    for s = 1:length(sites_with_current_diagnosis)
        inAll = inAll + 1;
        site = sites_with_current_diagnosis{s};
        siteChangedName = change_siteName({site});
        site_data = data(strcmp(data.site_string, site), :);

        dataset = change_siteName(unique(site_data.dataset));
        % Control group data (HC)
        hc_data = site_data(strcmp(site_data.diagnosis_string, 'HC'), :);
        hc_count(inAll) = height(hc_data);
        hc_males = sum(strcmp(hc_data.sex_string, 'M'));
        hc_age = median(hc_data.age);
        hc_age_sd = std(hc_data.age);
        hc_age_range = [min(hc_data.age), max(hc_data.age)];

        % Case group data (current diagnosis)
        case_data = site_data(strcmp(site_data.diagnosis_string, diagnoses{d}), :);
        case_count(inAll) = height(case_data);
        case_males = sum(strcmp(case_data.sex_string, 'M'));
        case_age = median(case_data.age);
        case_age_sd = std(case_data.age);
        case_age_range = [min(case_data.age), max(case_data.age)];

        % Store results in the table
        index = index + 1;
        new_row = {diagnoses{d}, index, siteChangedName, dataset{1}, sprintf('%d', hc_count(inAll) + case_count(inAll))};
        results = [results; new_row];
        hc_diag(s) = hc_count(inAll);
        patient_diag(s) = case_count(inAll);
    end

    minHCDiag(d) = min(hc_diag);
    maxHCDiag(d) = max(hc_diag);
    minPDiag(d) = min(patient_diag);
    maxPDiag(d) = max(patient_diag);
    clear hc_diag patient_diag
end

minHCaverage = mean(minHCDiag(2:6))
maxHCaverage = mean(maxHCDiag)
minPaverage = mean(minPDiag)
maxPaverage = mean(maxPDiag)
% Display the results table
% disp(results);


% 
%% Step 4: Write results to a CSV file
% writetable(results, '/projects/kg98/trangc/VBM/data/diagnosis_site_sub_counts_detailed_SBM.csv');

