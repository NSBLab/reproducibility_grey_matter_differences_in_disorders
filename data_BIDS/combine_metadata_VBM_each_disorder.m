clear all
% combine metadata
datalist = readlines('/projects/kg98/trangc/VBM/data/dataset_list_vbmAll.txt')
diagString = {'HC', 'BD', 'SCA',...
    'SCZ', 'ASD', 'MDD', 'AD' };
for iDiag = 2:length(diagString)
    tableHeight = 0;
    iStart = 1;
    metaAll = table;
    while tableHeight == 0
        filetoread = ['/projects/kg98/trangc/VBM/data/',char(datalist(iStart)),'/',char(datalist(iStart)),'_dems.csv'];
        metaread = readtable(filetoread);
        if ismember(diagString{iDiag},metaread.diagnosis_string)
            metaread.use = ismember(metaread.diagnosis_string,diagString([1,iDiag]))
            metaAll.subj_id = metaread.subj_id(metaread.use==1);
            metaAll.dataset = metaread.dataset(metaread.use==1);
            metaAll.site = cellstr(num2str(metaread.site(metaread.use==1)));
            metaAll.diagnosis = cellstr(num2str(metaread.diagnosis(metaread.use==1)));
            metaAll.age = cellstr(num2str(metaread.age(metaread.use==1)));
            metaAll.sex = cellstr(num2str(metaread.sex(metaread.use==1)));
            metaAll.site_string = metaread.site_string(metaread.use==1);
            metaAll.sex_string = metaread.sex_string(metaread.use==1);
            metaAll.diagnosis_string = metaread.diagnosis_string(metaread.use==1);
            if ismember('ses',metaread.Properties.VariableNames)
                metaAll.ses = metaread.ses(metaread.use==1);
            else
                metaAll.ses = repmat({[]},sum(metaread.use),1);
            end
            tableHeight = height(metaAll);
        else
            iStart=iStart+1;
        end
    end
    for i=iStart+1:length(datalist)-1
        tableHeight = height(metaAll);
        meta = readtable(['/projects/kg98/trangc/VBM/data/',char(datalist(i)),'/',char(datalist(i)),'_dems.csv']);
        meta.use = ismember(meta.diagnosis_string,diagString([1,iDiag]))
            
        addHeight = sum(meta.use);
        if addHeight>0 & ismember(diagString{iDiag},meta.diagnosis_string)
            
            metaAll(tableHeight+1:tableHeight+addHeight,1) = meta.subj_id(meta.use==1);
            metaAll(tableHeight+1:tableHeight+addHeight,2) = meta.dataset(meta.use==1);
            metaAll(tableHeight+1:tableHeight+addHeight,3) = cellstr(num2str(meta.site(meta.use==1)));
            metaAll(tableHeight+1:tableHeight+addHeight,4) = cellstr(num2str(meta.diagnosis(meta.use==1)));
            metaAll(tableHeight+1:tableHeight+addHeight,5) = cellstr(num2str(meta.age(meta.use==1)));
            metaAll(tableHeight+1:tableHeight+addHeight,6) = cellstr(num2str(meta.sex(meta.use==1)));
            metaAll(tableHeight+1:tableHeight+addHeight,7) = meta.site_string(meta.use==1);
            metaAll(tableHeight+1:tableHeight+addHeight,8) = meta.sex_string(meta.use==1);
            metaAll(tableHeight+1:tableHeight+addHeight,9) = meta.diagnosis_string(meta.use==1);
            if ismember('ses',meta.Properties.VariableNames)
                metaAll(tableHeight+1:tableHeight+addHeight,10) = meta.ses(meta.use==1);
            end
        end
    end



    writetable(metaAll,['/projects/kg98/trangc/VBM/data/metaVBM_',char(diagString{iDiag}),'.csv']);
end
