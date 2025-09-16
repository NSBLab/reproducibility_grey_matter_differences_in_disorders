datalist = readtable('/home/trangc/kg98/trangc/VBM/data/dataset_list_SBM.txt','ReadVariableNames',false);
nSub = 0;

for i = 1:height(datalist)
    sublist = readtable(['/home/trangc/kg98/trangc/VBM/data/',datalist.Var1{i},'/subject_use.txt'],'ReadVariableNames',false);
nSub = nSub + height(sublist);
end