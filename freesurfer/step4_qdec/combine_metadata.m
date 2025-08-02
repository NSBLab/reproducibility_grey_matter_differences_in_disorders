% Combine metadata
clear all
close all



% File containing paths to dataset folders
datasets_file = '/projects/kg98/trangc/VBM/data/dataset_list_SBM.txt';

% Output file for combined metadata
output_file = '/projects/kg98/trangc/VBM/data/metadataSBM.csv';
AD_dataset = [{'AIBL'} {'Harmonisation'} {'miriad'} {'OASIS3'} {'OASIS4'}];
% Initialize a cell array to store individual metadata tables
metadata_tables = {};

% Read the list of dataset folder paths
try
    dataset_folders = readlines(datasets_file);
    dataset_folders = dataset_folders(~ismissing(dataset_folders)); % Remove empty lines
catch
    error('Failed to read datasets.txt. Ensure the file exists and is formatted correctly.');
end

% Loop through each dataset folder
for i = 1:length(dataset_folders)-1
    folder = strtrim(dataset_folders(i)); % Remove extra spaces
    
    % Define the expected metadata file name
    metadata_file = fullfile('/projects/kg98/trangc/VBM/data',folder, [char(folder),'_qdec_extended.csv']); % Adjust if metadata file has a different name
    
    % Check if the metadata file exists
    if ~isfile(metadata_file)
        warning('Metadata file not found in folder: %s. Skipping...', folder);
        continue;
    end
    
    % Read the metadata file into a table
    try
        metadata = readtable(metadata_file);
    catch
        warning('Failed to read metadata file: %s. Skipping...', metadata_file);
        continue;
    end
    
    % Store the metadata table in the cell array
    metadata_tables{end+1} = metadata; 
end

% Combine all metadata tables, aligning columns

    % Get the union of all variable names
    all_variable_names = [  {'subj_id'}    {'dataset'}    {'site'}    {'diagnosis'}    {'age'}    {'sex'}    {'site_string'}    {'sex_string'}    {'diagnosis_string'}    {'EN'}   ];

    % Align all tables to have the same variables
    for i = 1:length(metadata_tables)
    
        metadata_tables{i} = metadata_tables{i}(:, 1:10); % Reorder columns
    end

    % Concatenate all tables
    metadata = vertcat(metadata_tables{:});

    % Write the combined metadata to a CSV file
    writetable(metadata, output_file);
    fprintf('Combined metadata saved to: %s\n', output_file);

 metadata_AD = metadata(ismember(metadata.dataset,AD_dataset),:);
    metadata_psy = metadata(~ismember(metadata.dataset,AD_dataset),:);
metadata_SCZ_patient = metadata(ismember(metadata.diagnosis_string,'SCZ'),:);
metadata_SCZ_control = metadata(ismember(metadata.diagnosis_string,'HC') & ismember(metadata.site_string,unique(metadata_SCZ_patient.site_string)),:);
metadata_SCZ = vertcat(metadata_SCZ_control, metadata_SCZ_patient);    
writetable(metadata_AD,['/home/trangc/kg98/trangc/VBM/data/metadataSBM_AD.csv']);

writetable(metadata_psy,['/home/trangc/kg98/trangc/VBM/data/metadataSBM_psy.csv']);
   writetable(metadata_SCZ,['/home/trangc/kg98/trangc/VBM/data/metadataSBM_SCZ.csv']);
   
%%

datasetList = unique(metadata.dataset);
nDataset = length(datasetList);

for iSet = 1:nDataset
    extendFile = ['/projects/kg98/trangc/VBM/data/', char(datasetList(iSet)), '/', char(datasetList(iSet)),'_qdec_extended.csv'];
    % if exist(extendFile)
        extend = readtable(extendFile);
        [isinSet Lb] = ismember(metadata.dataset, datasetList(iSet));

        [La indexSetinData] = ismember(metadata.subj_id(isinSet), extend.subj_id);
       
        if ismember('antipsychotic', extend.Properties.VariableNames)
            metadata.antipsychotic(isinSet) = extend.antipsychotic(indexSetinData);
        end
        if ismember('moodstabiliser', extend.Properties.VariableNames)
            metadata.moodstabiliser(isinSet) = extend.moodstabiliser(indexSetinData);
        end
        if ismember('antidepression', extend.Properties.VariableNames)
            metadata.antidepression(isinSet) = extend.antidepression(indexSetinData);
        end
        if ismember('antianxiety', extend.Properties.VariableNames)
            metadata.antianxiety(isinSet) = extend.antianxiety(indexSetinData);
        end
        if ismember('treatment', extend.Properties.VariableNames)
            metadata.treatment(isinSet) = extend.treatment(indexSetinData);
        end
        if ismember('ageOnset', extend.Properties.VariableNames)
            metadata.ageOnset(isinSet) = extend.ageOnset(indexSetinData);
        else
            metadata.ageOnset(isinSet) = NaN;
        end
        if ismember('illnessDuration', extend.Properties.VariableNames)
            metadata.illnessDuration(isinSet) = extend.illnessDuration(indexSetinData);
        else
            metadata.illnessDuration(isinSet) = NaN;
        end

    % end

end
metadata.ageOnset( metadata.ageOnset ==9999)= NaN;
metadata.illnessDuration(metadata.illnessDuration<=0 )= NaN;


writetable(metadata,['/home/trangc/kg98/trangc/VBM/data/metadataSBM_extended.csv']);

