% to extract demo for subject avaiable for surface analysis
datalistFile = '/home/trangc/kg98/trangc/VBM/data/dataset_list_surface.txt'
datalist = readlines(datalistFile);

for iData = 1:length(datalist)
    dataset = datalist(iData);
    