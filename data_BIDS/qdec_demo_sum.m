% sumary demo info
clear all
datalist = readlines('/projects/kg98/trangc/VBM/data/dataset_list_surfaceAll.txt');
diagnosisString = {'HC','BD', 'SCA', 'SCZ', 'ASD', 'MDD','AD' };


qdecInex = 0;
qdecAll = table;
Index = 0;
for idata = 1:length(datalist)-1
    dataset = datalist(idata);

    diagInSet = dir(fullfile('/projects/kg98/trangc/VBM/data', char(dataset)));
    diagName = {diagInSet.name};
    pat = "qdec_" + wildcardPattern+ ".dat";
    isQdecFile = contains(diagName,pat);
    sitelist = diagName(isQdecFile);

    for iSite = 1:length(sitelist)
        qdecFile = char(sitelist(iSite));
        siteDemo = readtable(fullfile('/projects/kg98/trangc/VBM/data', char(dataset),qdecFile),'Delimiter','tab');
qdecAll.fsid(qdecInex+1:qdecInex+height(siteDemo)) = siteDemo.fsid;
qdecAll.diagnosis(qdecInex+1:qdecInex+height(siteDemo)) = siteDemo.diagnosis;
qdecAll.sex(qdecInex+1:qdecInex+height(siteDemo)) = siteDemo.sex;
qdecAll.age(qdecInex+1:qdecInex+height(siteDemo)) = siteDemo.age;
qdecAll.dataset(qdecInex+1:qdecInex+height(siteDemo)) = dataset;
qdecAll.site(qdecInex+1:qdecInex+height(siteDemo)) = cellstr(qdecFile(12:end-6));

    qdecInex = qdecInex+height(siteDemo);

        Index = Index +1;
        demo.Index(Index,1) = Index;
        demo.Dataset(Index,1) = cellstr(dataset);
        demo.Site(Index,1) = cellstr(qdecFile(12:end-6));
        diagnosis = str2num(qdecFile(end-4));
        demo.Diagnosis(Index,1) = cellstr(diagnosisString(diagnosis));
        demo.HCn(Index,1) = cellstr(num2str(sum(siteDemo.diagnosis==1)));
        demo.HCperMale(Index,1) = cellstr(num2str(round(sum(siteDemo.diagnosis==1 & siteDemo.sex==1)/sum(siteDemo.diagnosis==1)*100)));
        demo.HCnMale(Index,1) = cellstr([demo.HCn{Index},' (',demo.HCperMale{Index},')']);

        demo.HCageMedian(Index,1) = cellstr(num2str(round(median(siteDemo.age(siteDemo.diagnosis==1)))));
        demo.HCageSD(Index,1) = cellstr(num2str(round(std(siteDemo.age(siteDemo.diagnosis==1)))));
        demo.HCageMin(Index,1) = cellstr(num2str(round(min(siteDemo.age(siteDemo.diagnosis==1)))));
        demo.HCageMax(Index,1) = cellstr(num2str(round(max(siteDemo.age(siteDemo.diagnosis==1)))));
        demo.HCage(Index,1) = cellstr([demo.HCageMedian{Index},' (', demo.HCageSD{Index},') [',demo.HCageMin{Index},' ',demo.HCageMax{Index},']']);

                demo.Pn(Index,1) = cellstr(num2str(sum(siteDemo.diagnosis==diagnosis)));
        demo.PperMale(Index,1) = cellstr(num2str(round(sum(siteDemo.diagnosis==diagnosis & siteDemo.sex==1)/sum(siteDemo.diagnosis==diagnosis)*100)));
        demo.PnMale(Index,1) = cellstr([demo.Pn{Index},' (',demo.PperMale{Index},')']);

        demo.PageMedian(Index,1) = cellstr(num2str(round(median(siteDemo.age(siteDemo.diagnosis==diagnosis)))));
        demo.PageSD(Index,1) = cellstr(num2str(round(std(siteDemo.age(siteDemo.diagnosis==diagnosis)))));
        demo.PageMin(Index,1) = cellstr(num2str(round(min(siteDemo.age(siteDemo.diagnosis==diagnosis)))));
        demo.PageMax(Index,1) = cellstr(num2str(round(max(siteDemo.age(siteDemo.diagnosis==diagnosis)))));
        demo.Page(Index,1) = cellstr([demo.PageMedian{Index},' (', demo.PageSD{Index},') [',demo.PageMin{Index},' ',demo.PageMax{Index},']']);
    end
end

demotable = cell2table([cellstr(num2str(demo.Index)),demo.Dataset,demo.Site,demo.Diagnosis,demo.HCnMale,demo.HCage,demo.PnMale, demo.Page],"VariableNames",["Index","Dataset","Site","Diagnosis","HC No (%male)", "HC Age(year) median (SD) [range]","Case No (%male)", "Case Age(year) median (SD) [range]"]);
writetable(demotable,['/projects/kg98/trangc/VBM/data/qdec_demo.csv']);
qdecAll = unique(qdecAll);
writetable(qdecAll,['/projects/kg98/trangc/VBM/data/qdecAll.csv']);

    nHC = sum(qdecAll.diagnosis==1);
    nP = sum(qdecAll.diagnosis==[2,3,4,5,6,7]);