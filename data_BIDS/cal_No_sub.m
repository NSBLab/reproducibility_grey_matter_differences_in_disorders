% cal number of subjects before QC
clear all
datalist = readlines('/projects/kg98/trangc/VBM/data/dataset_list_surfaceAll.txt');


index = 0;
subAll = table;
for idata = 1:length(datalist)-1
    sub = readtable(fullfile('/projects/kg98/trangc/VBM/data',char(datalist{idata}),'subject_use.txt'),'ReadVariableNames',false);
    subAll(index+1:index+height(sub),1) = sub;
    index = index+height(sub);
    datalist{idata}
    height(sub)
end