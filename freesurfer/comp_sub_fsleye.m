datalist = readlines('/projects/kg98/trangc/VBM/data/dataset_list_euler.txt');

for iData = 1:length(datalist)
    if isfile(fullfile('/projects/kg98/trangc/VBM/data',datalist(iData),'sub_err_to_recon.txt'))
        
        ori = readlines(fullfile('/projects/kg98/trangc/VBM/data',datalist(iData),'sub_err_to_recon.txt'));
        if isfile(fullfile('/projects/kg98/trangc/VBM/data',datalist(iData),'sub_err_to_recon1.txt'))
            new = readlines(fullfile('/projects/kg98/trangc/VBM/data',datalist(iData),'sub_err_to_recon1.txt'));
            [lia locb] = ismember(ori,new);

            if length(ori)==length(new)
                datalist(iData)
            end

            writematrix(ori(~lia), fullfile('/projects/kg98/trangc/VBM/data',datalist(iData),'sub_to_add_vis.txt'));
        else
            writematrix(ori, fullfile('/projects/kg98/trangc/VBM/data',datalist(iData),'sub_to_add_vis.txt'));
        end
    else
        datalist(iData)
    end
end