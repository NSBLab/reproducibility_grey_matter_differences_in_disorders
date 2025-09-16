clear all
diagnosisString = {'BD', 'SCA',...
    'SCZ', 'ASD', 'MDD','AD' };

parcList=[100 200 300 400 500 600 700 800 900 1000];

for iDiag = 1:length(diagnosisString)
    iDiag
    listAll = dir(['/home/trangc/kg98/trangc/VBM/data/derivatives/roi/',char(diagnosisString(iDiag))]);
       listAll = listAll([listAll.isdir]); % Keep only directories
        listAll = listAll(~ismember({listAll.name}, {'.', '..'})); % Remove . and ..
     for iSite = 1:length(listAll)
         for iParc = 1:length(parcList)
             st = load(fullfile(listAll(iSite).folder,listAll(iSite).name,[char(num2str(parcList(iParc))),'_parcCon.mat']));
             writematrix(st.stat.tMap',fullfile(listAll(iSite).folder,listAll(iSite).name,[char(num2str(parcList(iParc))),'_parcCon_statMap.txt']))
         end
     end
end
