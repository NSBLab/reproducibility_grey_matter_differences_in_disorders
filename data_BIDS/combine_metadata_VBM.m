clear all
% combine metadata
datalist = readlines('/projects/kg98/trangc/VBM/data/dataset_list_vbmAll.txt')
filetoread = ['/projects/kg98/trangc/VBM/data/',char(datalist(1)),'/',char(datalist(1)),'_dems.csv'];
metaAll = readtable(filetoread);
metaAll.site = cellstr(num2str(metaAll.site));
metaAll.diagnosis = cellstr(num2str(metaAll.diagnosis));
metaAll.age = cellstr(num2str(metaAll.age));
metaAll.sex = cellstr(num2str(metaAll.sex));
if ~isfield('metaAll','ses')
    metaAll.ses = repmat({[]},height(metaAll),1);
end
for i=2:length(datalist)-1
    tableHeight = height(metaAll);
    meta = readtable(['/projects/kg98/trangc/VBM/data/',char(datalist(i)),'/',char(datalist(i)),'_dems.csv']);
    addHeight = height(meta);
    if addHeight>0
        metaAll(tableHeight+1:tableHeight+addHeight,1) = meta.subj_id;
        metaAll(tableHeight+1:tableHeight+addHeight,2) = meta.dataset;
        metaAll(tableHeight+1:tableHeight+addHeight,3) = cellstr(num2str(meta.site));
        metaAll(tableHeight+1:tableHeight+addHeight,4) = cellstr(num2str(meta.diagnosis));
        metaAll(tableHeight+1:tableHeight+addHeight,5) = cellstr(num2str(meta.age));
        metaAll(tableHeight+1:tableHeight+addHeight,6) = cellstr(num2str(meta.sex));
        metaAll(tableHeight+1:tableHeight+addHeight,7) = meta.site_string;
        metaAll(tableHeight+1:tableHeight+addHeight,8) = meta.sex_string;
        metaAll(tableHeight+1:tableHeight+addHeight,9) = meta.diagnosis_string;
        if ismember('ses',meta.Properties.VariableNames)
            metaAll(tableHeight+1:tableHeight+addHeight,10) = meta.ses;
        end
    end
end



writetable(metaAll,['/projects/kg98/trangc/VBM/data/metaVBMAll.csv']);
