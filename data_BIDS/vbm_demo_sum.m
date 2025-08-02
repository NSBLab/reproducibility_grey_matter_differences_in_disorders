% sumary demo info
clear all
datalist = readlines('/projects/kg98/trangc/VBM/data/dataset_list_vbmAll.txt');
diagnosisString = {'HC','BD', 'SCA', 'SCZ', 'ASD', 'MDD','AD' };

demoFile = readtable('/projects/kg98/trangc/VBM/data/derivatives/s8COMBAT/metadataAll.csv');

[sitelist iString iList] = unique(demoFile.site_string);


index = 0;
for iSite = 1:length(sitelist)

    diagnosis = unique(demoFile.diagnosis(ismember(demoFile.site_string,sitelist(iSite))));

    for iDiag = 2:length(diagnosis)
        index = index + 1;


        demo.Index(index,1) = cellstr(num2str(index));
        demo.Site(index,1) = cellstr(sitelist(iSite));
        demo.Dataset(index,1) = unique(demoFile.dataset(ismember(demoFile.site_string,sitelist(iSite))));
        demo.Diagnosis(index,1) = cellstr(num2str(diagnosis(iDiag)));

        demo.HCn(index,1) = cellstr(num2str(sum(demoFile.diagnosis==1 & ismember(demoFile.site_string,demo.Site(index)))));
        demo.HCperMale(index,1) = cellstr(num2str(round(sum(demoFile.diagnosis==1 & demoFile.sex==1 & ismember(demoFile.site_string,demo.Site(index)))/sum(demoFile.diagnosis==1& ismember(demoFile.site_string,demo.Site(index)))*100)));
        demo.HCnMale(index,1) = cellstr([demo.HCn{index},' (',demo.HCperMale{index},')']);

        demo.HCageMedian(index,1) = cellstr(num2str(round(median(demoFile.age(demoFile.diagnosis==1& ismember(demoFile.site_string,demo.Site(index)))))));
        demo.HCageSD(index,1) = cellstr(num2str(round(std(demoFile.age(demoFile.diagnosis==1& ismember(demoFile.site_string,demo.Site(index)))))));
        demo.HCageMin(index,1) = cellstr(num2str(round(min(demoFile.age(demoFile.diagnosis==1& ismember(demoFile.site_string,demo.Site(index)))))));
        demo.HCageMax(index,1) = cellstr(num2str(round(max(demoFile.age(demoFile.diagnosis==1& ismember(demoFile.site_string,demo.Site(index)))))));
        demo.HCage(index,1) = cellstr([demo.HCageMedian{index},' (', demo.HCageSD{index},') [',demo.HCageMin{index},' ',demo.HCageMax{index},']']);

        demo.Pn(index,1) = cellstr(num2str(sum(demoFile.diagnosis==diagnosis(iDiag)& ismember(demoFile.site_string,demo.Site(index)))));
        demo.PperMale(index,1) = cellstr(num2str(round(sum(demoFile.diagnosis==diagnosis(iDiag) & demoFile.sex==1& ismember(demoFile.site_string,demo.Site(index)))/sum(demoFile.diagnosis==diagnosis(iDiag)& ismember(demoFile.site_string,demo.Site(index)))*100)));
        demo.PnMale(index,1) = cellstr([demo.Pn{index},' (',demo.PperMale{index},')']);

        demo.PageMedian(index,1) = cellstr(num2str(round(median(demoFile.age(demoFile.diagnosis==diagnosis(iDiag)& ismember(demoFile.site_string,demo.Site(index)))))));
        demo.PageSD(index,1) = cellstr(num2str(round(std(demoFile.age(demoFile.diagnosis==diagnosis(iDiag)& ismember(demoFile.site_string,demo.Site(index)))))));
        demo.PageMin(index,1) = cellstr(num2str(round(min(demoFile.age(demoFile.diagnosis==diagnosis(iDiag)& ismember(demoFile.site_string,demo.Site(index)))))));
        demo.PageMax(index,1) = cellstr(num2str(round(max(demoFile.age(demoFile.diagnosis==diagnosis(iDiag)& ismember(demoFile.site_string,demo.Site(index)))))));
        demo.Page(index,1) = cellstr([demo.PageMedian{index},' (', demo.PageSD{index},') [',demo.PageMin{index},' ',demo.PageMax{index},']']);
    end

end
    demotable = cell2table([demo.Index,demo.Dataset,demo.Site,demo.Diagnosis,demo.HCnMale,demo.HCage,demo.PnMale, demo.Page],"VariableNames",["Index","Dataset","Site","Diagnosis","HC No (%male)", "HC Age(year) median (SD) [range]","Case No (%male)", "Case Age(year) median (SD) [range]"]);
    writetable(demotable,['/projects/kg98/trangc/VBM/data/vbm_demo.csv'])

    nHC = sum(demoFile.diagnosis==1);
    nP = sum(demoFile.diagnosis==[2,3,4,5,6,7]);