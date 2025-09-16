clear all
close all

iCOMBAT = 0;
smoothKernel = 8;

if iCOMBAT == 1
    address = ['derivatives/s',num2str(smoothKernel),'COMBAT/'];
else
    address = ['derivatives/s',num2str(smoothKernel),'/'];
end

metadata = readtable(['/home/trangc/kg98/trangc/VBM/data/derivatives/s',num2str(smoothKernel),'COMBAT/metadata.csv']);

diagnosisString = unique(metadata.diagnosis_string);
diagnosisString = diagnosisString(~ismember(diagnosisString,'HC'));
nDiag = length(diagnosisString);





fig = figure('Position', [200 200 1000 2500]);
factor_x = 1.2;
factor_y = 2.2;
init_x = 0.1;
init_y = 0.1;
num_row = 6;
num_col = 3;
length_x = (0.95 - init_x)/(factor_x*(num_col-1) + 1);
length_y = (0.95 - init_y)/(factor_y*(num_row-1) + 1);
lineWidth = 2;

font_name = 'Arial';
font_size = 10;
fontsize_legend = 8;
a1 = annotation(fig, 'textbox', [0, 0.98, 0.7, 0.01], 'string', 'A', 'edgecolor', 'none', ...
    'FontName',font_name,'FontSize',font_size, 'horizontalalignment', 'center');
a2 = annotation(fig, 'textbox', [0.7, 0.98, 0.3, 0.01], 'string', 'B', 'edgecolor', 'none', ...
    'FontName',font_name,'FontSize',font_size, 'horizontalalignment', 'center');
%%


iSite = 1;
[LaDiag LbDiag] = ismember(metadata.diagnosis_string,diagnosisString(iSite));
[siteString ia ic] = unique(metadata.site_string(LaDiag));
[siteString] = change_siteName(siteString);
[cor1, cor2, rowst1_without_zeros, rowst2_without_zeros] = cal_corr_tmap_thres(address, metadata, diagnosisString(iSite));
if size(cor2,1)>1
    ids=find(triu(ones(size(cor2)),1));
    [fi xi]=ksdensity(cor2(ids),'function','pdf','npoints',200);

    ax1 = axes('Position', [init_x, init_y+length_y*factor_y*5 length_x*2 length_y]);
    a32 = annotation(fig, 'textbox', [0, ax1.Position(2)+length_y*1.3, 1, 0.01], 'string', 'ASD', 'edgecolor', 'none', ...
        'FontName',font_name,'FontSize',font_size, 'horizontalalignment', 'left');
    hm = heatmap(siteString(rowst2_without_zeros), siteString(rowst2_without_zeros), cor2,'Interpreter','none','ColorLimits',[0 0.2], 'CellLabelColor', 'None');
    hm.Colormap = parula;
    % title(['Correlation between t-maps HC > P in ', diagnosisString(iSite)]);

    ax2 = axes('Position', [init_x+length_x*factor_x*2, init_y+length_y*factor_y*5 length_x length_y]);
    denPlot = plot(ax2, xi, fi, 'LineWidth', lineWidth);
    xlim([-0.5 1]);
    xlabel('Dice coefficient')
    ylabel('density')
end

%%
iSite = 2;
[LaDiag LbDiag] = ismember(metadata.diagnosis_string,diagnosisString(iSite));
[siteString ia ic] = unique(metadata.site_string(LaDiag));
[siteString] = change_siteName(siteString);
[cor1, cor2, rowst1_without_zeros, rowst2_without_zeros] = cal_corr_tmap_thres(address, metadata, diagnosisString(iSite));
if size(cor2,1)>1
    ids=find(triu(ones(size(cor2)),1));
    [fi xi]=ksdensity(cor2(ids),'function','pdf','npoints',200);

    ax1 = axes('Position', [init_x, init_y+length_y*factor_y*4 length_x*2 length_y]);
    a32 = annotation(fig, 'textbox', [0, ax1.Position(2)+length_y*1.3, 1, 0.01], 'string', 'BD', 'edgecolor', 'none', ...
        'FontName',font_name,'FontSize',font_size, 'horizontalalignment', 'left');
    hm = heatmap(siteString(rowst2_without_zeros), siteString(rowst2_without_zeros), cor2,'Interpreter','none','ColorLimits',[0 0.1], 'CellLabelColor', 'None');
    hm.Colormap = parula;
    % title(['Correlation between t-maps HC > P in ', diagnosisString(iSite)]);

    ax2 = axes('Position', [init_x+length_x*factor_x*2, init_y+length_y*factor_y*4 length_x length_y]);
    denPlot = plot(ax2, xi, fi, 'LineWidth', lineWidth);
    xlim([-0.5 1]);
    xlabel('Dice coefficient')
    ylabel('density')
end

%%
iSite = 3;
[LaDiag LbDiag] = ismember(metadata.diagnosis_string,diagnosisString(iSite));
[siteString ia ic] = unique(metadata.site_string(LaDiag));
[siteString] = change_siteName(siteString);
[cor1, cor2, rowst1_without_zeros, rowst2_without_zeros] = cal_corr_tmap_thres(address, metadata, diagnosisString(iSite));
if size(cor2,1)>1
    ids=find(triu(ones(size(cor2)),1));
    [fi xi]=ksdensity(cor2(ids),'function','pdf','npoints',200);

    ax1 = axes('Position', [init_x, init_y+length_y*factor_y*3 length_x*2 length_y]);
    a32 = annotation(fig, 'textbox', [0, ax1.Position(2)+length_y*1.3, 1, 0.01], 'string', 'MDD', 'edgecolor', 'none', ...
        'FontName',font_name,'FontSize',font_size, 'horizontalalignment', 'left');
    hm = heatmap(siteString(rowst2_without_zeros), siteString(rowst2_without_zeros), cor2,'Interpreter','none','ColorLimits',[0 0.1], 'CellLabelColor', 'None');
    % title(['Correlation between t-maps HC > P in ', diagnosisString(iSite)]);
    hm.Colormap = parula;
    % title(['Correlation between t-maps HC > P in ', diagnosisString(iSite)]);

    ax2 = axes('Position', [init_x+length_x*factor_x*2, init_y+length_y*factor_y*3 length_x length_y]);
    denPlot = plot(ax2, xi, fi, 'LineWidth', lineWidth);
    xlim([-0.5 1]);
    xlabel('Dice coefficient')
    ylabel('density')
end

%%
iSite = 4;
[LaDiag LbDiag] = ismember(metadata.diagnosis_string,diagnosisString(iSite));
[siteString ia ic] = unique(metadata.site_string(LaDiag));
[siteString] = change_siteName(siteString);
[cor1, cor2, rowst1_without_zeros, rowst2_without_zeros] = cal_corr_tmap_thres(address, metadata, diagnosisString(iSite));
if size(cor2,1)>1
    ids=find(triu(ones(size(cor2)),1));
    [fi xi]=ksdensity(cor2(ids),'function','pdf','npoints',200);

    ax1 = axes('Position', [init_x, init_y+length_y*factor_y*2 length_x*2 length_y]);
    a32 = annotation(fig, 'textbox', [0, ax1.Position(2)+length_y*1.3, 1, 0.01], 'string', 'SCA', 'edgecolor', 'none', ...
        'FontName',font_name,'FontSize',font_size, 'horizontalalignment', 'left');
    hm = heatmap(siteString(rowst2_without_zeros), siteString(rowst2_without_zeros), cor2,'Interpreter','none','ColorLimits',[0 0.1], 'CellLabelColor', 'None');
    % title(['Correlation between t-maps HC > P in ', diagnosisString(iSite)]);
    hm.Colormap = parula;
    % title(['Correlation between t-maps HC > P in ', diagnosisString(iSite)]);

    ax2 = axes('Position', [init_x+length_x*factor_x*2, init_y+length_y*factor_y*2 length_x length_y]);
    denPlot = plot(ax2, xi, fi, 'LineWidth', lineWidth);
    xlim([-0.5 1]);
    xlabel('Dice coefficient')
    ylabel('density')
end

%%
iSite = 5;
[LaDiag LbDiag] = ismember(metadata.diagnosis_string,diagnosisString(iSite));
[siteString ia ic] = unique(metadata.site_string(LaDiag));
[siteString] = change_siteName(siteString);
[cor1, cor2, rowst1_without_zeros, rowst2_without_zeros] = cal_corr_tmap_thres(address, metadata, diagnosisString(iSite));
if size(cor2,1)>1
    ids=find(triu(ones(size(cor2)),1));
    [fi xi]=ksdensity(cor2(ids),'function','pdf','npoints',200);

    ax1 = axes('Position', [init_x, init_y length_x*2 length_y*3]);
    a32 = annotation(fig, 'textbox', [0, ax1.Position(2)+length_y*3.3, 1, 0.01], 'string', 'SCZ', 'edgecolor', 'none', ...
        'FontName',font_name,'FontSize',font_size, 'horizontalalignment', 'left');
    hm = heatmap(siteString(rowst2_without_zeros), siteString(rowst2_without_zeros), cor2,'Interpreter','none','ColorLimits',[0 1], 'CellLabelColor', 'None');
    % title(['Correlation between t-maps HC > P in ', diagnosisString(iSite)]);
    hm.Colormap = parula;
    % title(['Correlation between t-maps HC > P in ', diagnosisString(iSite)]);

    ax2 = axes('Position', [init_x+length_x*factor_x*2, init_y length_x length_y]);
    denPlot = plot(ax2, xi, fi, 'LineWidth', lineWidth);
    xlim([-0.5 1]);
    xlabel('Dice coefficient')
    ylabel('density')
end