clear all
method = 'VBM' % 'SBM' or 'VBM'
% Step 1: Read the CSV file
if strcmp(method,'SBM')
    filename = '/projects/kg98/trangc/VBM/data/metadataSBM.csv';  % Change this to the path of your CSV file
    load(['output/corr_zmap_combat1_smooth10_lh_all.mat'], 'siteList')
else
    filename = '/projects/kg98/trangc/VBM/data/metadataSBM.csv';  % Change this to the path of your CSV file
    load('/home/trangc/kg98/trangc/VBM/code/analysis/output/corr_tmap_combat1_smooth6.mat', 'siteList')
    
end
data = readtable(filename);
% Step 2: List of diagnoses to check
diagnoses = {'HC', 'BD', 'SCA',...
    'SCZ', 'ASD', 'MDD' ,'AD'};
plotorder = [1 7 4 3 5 6 2]; % change the order of disorder appear in the plot
diagnoses = diagnoses(plotorder);
siteList = siteList([6 3 2 4 5 1]);
% Step 3: Initialize a table to hold all the results
results = table([],[],[],[],[],[],[],[], 'VariableNames', {'Diagnosis', 'Index', 'Site', 'Dataset', ...
    'Control Number (%male)', 'Control age median (SD) [range](year)', 'Case Number (%male)', 'Case age median (SD) [range](year)'});

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
        new_row = {diagnoses{d}, index, siteChangedName, dataset{1}, sprintf('%d (%.f)', hc_count(inAll), 100 * hc_males / hc_count(inAll)), ...
            sprintf('%.f (%.f) [%.f %.f]', hc_age, hc_age_sd, hc_age_range), sprintf('%d (%.f)', case_count(inAll), 100 * case_males / case_count(inAll)), ...
            sprintf('%.f (%.f) [%.f %.f]', case_age, case_age_sd, case_age_range)};
        results = [results; new_row];
    end
end


% Display the results table
disp(results);

%% Step 4: Write results to a CSV file
if strcmp(method,'SBM')
    writetable(results, '/projects/kg98/trangc/VBM/data/diagnosis_site_counts_detailed_SBM.csv');
else
    writetable(results, '/projects/kg98/trangc/VBM/data/diagnosis_site_counts_detailed_VBM.csv');
end
