clear all
% combine metadata
datalist = readlines('/projects/kg98/trangc/VBM/data/dataset_list.txt')
filetoread = ['/projects/kg98/trangc/VBM/data/',char(datalist(1)),'/',char(datalist(1)),'_qdec_extended.csv'];
meta = readtable(filetoread);
metaAll = table;
metaAll.subj_id = meta.subj_id;
metaAll.diagnosis = cellstr(num2str(meta.diagnosis));
metaAll.sex = cellstr(num2str(meta.sex));
metaAll.age = cellstr(num2str(meta.age));
metaAll.dataset = meta.dataset;
metaAll.site_string = meta.site_string;
metaAll.diagnosis_string = meta.diagnosis_string;

for i=2:length(datalist)-1
    tableHeight = height(metaAll);
    meta = readtable(['/projects/kg98/trangc/VBM/data/',char(datalist(i)),'/',char(datalist(i)),'_qdec_extended.csv']);
    addHeight = height(meta);
    if addHeight>0
        metaAll(tableHeight+1:tableHeight+addHeight,1) = meta.subj_id;
        metaAll(tableHeight+1:tableHeight+addHeight,2) = cellstr(num2str(meta.diagnosis));
        metaAll(tableHeight+1:tableHeight+addHeight,3) = cellstr(num2str(meta.sex));
        metaAll(tableHeight+1:tableHeight+addHeight,4) = cellstr(num2str(meta.age));
        metaAll(tableHeight+1:tableHeight+addHeight,5) = meta.dataset;
        metaAll(tableHeight+1:tableHeight+addHeight,6) = meta.site_string;
        metaAll(tableHeight+1:tableHeight+addHeight,7) = meta.diagnosis_string;
      
     
    end
end



writetable(metaAll,['/projects/kg98/trangc/VBM/data/metaSBMAll.csv']);
