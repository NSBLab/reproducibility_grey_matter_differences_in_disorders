% sumary demo info
clear all
datalist = readlines('/projects/kg98/trangc/VBM/data/dataset_list_vbmAll.txt');
diagnosisString = {'HC','BD', 'SCA', 'SCZ', 'ASD', 'MDD','AD' };

demoFile = readtable('/scratch/kg98/trangc/VBM/data/derivatives/freesurfer/s10COMBAT/metadata_surface_all.csv');

[sitelist iString iList] = unique(demoFile.site);
demo.Site = cellstr(num2str(sitelist));
demo.Dataset = cellstr(demoFile.dataset(iString));
demo.Index = cellstr(num2str([1:length(sitelist)]'));
demo.Diagnosis = cellstr(diagnosisString(demoFile.diagnosis(iString))');

for iSite = 1:length(sitelist)
       
        diagnosis = demoFile.diagnosis(iString(iSite));
        
        demo.HCn(iSite,1) = cellstr(num2str(sum(demoFile.diagnosis==1 & ismember(num2str(demoFile.site),demo.Site(iSite)))));
        demo.HCperMale(iSite,1) = cellstr(num2str(round(sum(demoFile.diagnosis==1 & demoFile.sex==1 & ismember(num2str(demoFile.site),demo.Site(iSite)))/sum(demoFile.diagnosis==1& ismember(num2str(demoFile.site),demo.Site(iSite)))*100)));
        demo.HCnMale(iSite,1) = cellstr([demo.HCn{iSite},' (',demo.HCperMale{iSite},')']);

        demo.HCageMedian(iSite,1) = cellstr(num2str(round(median(demoFile.age(demoFile.diagnosis==1& ismember(num2str(demoFile.site),demo.Site(iSite)))))));
        demo.HCageSD(iSite,1) = cellstr(num2str(round(std(demoFile.age(demoFile.diagnosis==1& ismember(num2str(demoFile.site),demo.Site(iSite)))))));
        demo.HCageMin(iSite,1) = cellstr(num2str(round(min(demoFile.age(demoFile.diagnosis==1& ismember(num2str(demoFile.site),demo.Site(iSite)))))));
        demo.HCageMax(iSite,1) = cellstr(num2str(round(max(demoFile.age(demoFile.diagnosis==1& ismember(num2str(demoFile.site),demo.Site(iSite)))))));
        demo.HCage(iSite,1) = cellstr([demo.HCageMedian{iSite},' (', demo.HCageSD{iSite},') [',demo.HCageMin{iSite},' ',demo.HCageMax{iSite},']']);

                demo.Pn(iSite,1) = cellstr(num2str(sum(demoFile.diagnosis==diagnosis& ismember(num2str(demoFile.site),demo.Site(iSite)))));
        demo.PperMale(iSite,1) = cellstr(num2str(round(sum(demoFile.diagnosis==diagnosis & demoFile.sex==1& ismember(num2str(demoFile.site),demo.Site(iSite)))/sum(demoFile.diagnosis==diagnosis& ismember(num2str(demoFile.site),demo.Site(iSite)))*100)));
        demo.PnMale(iSite,1) = cellstr([demo.Pn{iSite},' (',demo.PperMale{iSite},')']);

        demo.PageMedian(iSite,1) = cellstr(num2str(round(median(demoFile.age(demoFile.diagnosis==diagnosis& ismember(num2str(demoFile.site),demo.Site(iSite)))))));
        demo.PageSD(iSite,1) = cellstr(num2str(round(std(demoFile.age(demoFile.diagnosis==diagnosis& ismember(num2str(demoFile.site),demo.Site(iSite)))))));
        demo.PageMin(iSite,1) = cellstr(num2str(round(min(demoFile.age(demoFile.diagnosis==diagnosis& ismember(num2str(demoFile.site),demo.Site(iSite)))))));
        demo.PageMax(iSite,1) = cellstr(num2str(round(max(demoFile.age(demoFile.diagnosis==diagnosis& ismember(num2str(demoFile.site),demo.Site(iSite)))))));
        demo.Page(iSite,1) = cellstr([demo.PageMedian{iSite},' (', demo.PageSD{iSite},') [',demo.PageMin{iSite},' ',demo.PageMax{iSite},']']);
    end


demotable = cell2table([demo.Index,demo.Dataset,demo.Site,demo.Diagnosis,demo.HCnMale,demo.HCage,demo.PnMale, demo.Page],"VariableNames",["Index","Dataset","Site","Diagnosis","HC No (%male)", "HC Age(year) median (SD) [range]","Case No (%male)", "Case Age(year) median (SD) [range]"]);
writetable(demotable,['/projects/kg98/trangc/VBM/data/surface_demo.csv'])