%check exist parcelated maps
clear all
dataset = 'OASIS3';
% read subject list
    subList = readtable(fullfile('/home/trangc/kg98/trangc/VBM/data',dataset, [dataset,'_dems.csv']));

    for i=1:height(subList)

        if exist(['/home/trangc/kg98/trangc/VBM/data/',dataset, '/',char(subList.subj_id(i)),'/',char(subList.ses(i)),'/anat/mwp1', ...
                char(subList.subj_id(i)),'_',char(subList.ses(i)),'_T1w_Buckner-whole_1mm_Tian_Subcortex_S1_3T_2009cAsym_Schaefer2018_1000Parcels_7Networks_order_CAT12MNI.mat'])
            subList.mark(i)=1;
        end
    end

demsTable = subList(subList.mark==0,:);
    writetable(demsTable(1:end,:),['/home/trangc/kg98/trangc/VBM/data/',dataset,'/',dataset,'_dems1.csv'])
   