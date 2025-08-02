clear all
study = readlines('/projects/kg98/trangc/VBM/data/dataset_list.txt')

tableAll=readtable(['/projects/kg98/trangc/VBM/data/', study{8}, '/',study{8},'_qdec_extended.csv']);
  columnNames = tableAll.Properties.VariableNames;
for i=[1:length(study)-1]
    tempTable = readtable(['/projects/kg98/trangc/VBM/data/', study{i}, '/',study{i},'_qdec_extended.csv']);
    columnTempNames = tempTable.Properties.VariableNames; 
    % [lia locb] = ismember(columnNames,columnTempNames);
    % tempTable.Properties.VariableNames(lia==0)=columnNames(lia==0)
    % tempTable{:,lia==0} = 0;
    tableAll = outerjoin(tableAll,tempTable,'MergeKeys',1);%'dataset','site','diagnosis','age','sex','site_string','sex_string',...
    %'diagnosis_string','CAT','antipsychotic','moodstabiliser','antidepression','antianxiety','treatment','ageOnset','illnessDuration');
end
writetable(tableAll,'/home/trangc/kg98/trangc/VBM/data/metadataQdecExtended_new.csv')