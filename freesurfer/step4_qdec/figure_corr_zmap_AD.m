clear all
close all
    
    load('corr_surface_AD.mat');

diagnosis = {'HC', 'BD', 'SCA',...
    'SCZ', 'ASD', 'MDD' ,'AD'};
plotOrder = [7]; %to match with plot in vbm

nDiag = length(diagnosis); 

fig = figure('Position', [200 200 1000 2500]);
set(fig,'color','w');
factor_x = 1.2;
factor_y = 1.5;
init_x = 0.1;
init_y = 0.1;
num_row = 2;
num_col = 1;
length_x = (0.82 - init_x)/(factor_x*(num_col-1) + 1);
length_y = (0.95 - init_y)/(factor_y*(num_row-1) + 1);
lineWidth = 2;

font_name = 'Arial';
font_size = 10;
fontsize_legend = 8;
%%


for iDiag = 1:nDiag-1
    
[isDiag locDiag] = ismember(map.diag,num2str(plotOrder(iDiag)));
siteString = (map.site(isDiag));
[siteString] = change_siteName(siteString);
nSite = length(siteString);

ids=find(triu(ones(size(corDiag{plotOrder(iDiag)-1})),1));
[fi xi]=ksdensity(corDiag{plotOrder(iDiag)-1}(ids),'function','pdf','npoints',200);
 
if iDiag == 1
    ax1 = axes('Position', [init_x, init_y length_x length_y*2]);
    a32 = annotation(fig, 'textbox', [0, ax1.Position(2)+length_y*2, 1, 0.01], 'string', char(diagnosis(plotOrder(iDiag))), 'edgecolor', 'none', ...
    'FontName',font_name,'FontSize',font_size, 'horizontalalignment', 'left');
else
ax1 = axes('Position', [init_x, init_y+length_y*factor_y*(6-iDiag) length_x length_y]);
a32 = annotation(fig, 'textbox', [0, ax1.Position(2)+length_y, 1, 0.01], 'string', char(diagnosis(plotOrder(iDiag))), 'edgecolor', 'none', ...
    'FontName',font_name,'FontSize',font_size, 'horizontalalignment', 'left');
end

hm = imagesc(1:length(siteString), 1:length(siteString), triu(corDiag{plotOrder(iDiag)-1},1));
clim([-0.2 1]);
colormap(ax1, bluewhitered(ax1));
colorbar('Position', [0.93, ax1.Position(2), 0.02, ax1.Position(4)])
set(ax1,'xaxisLocation','top','yaxisLocation','right');
xticks(ax1,[1:nSite])
xticklabels(ax1,siteString(1:end))
yticks(ax1,[1:nSite])
yticklabels(ax1,siteString(1:end))
set(ax1,'box','off')
grid off
xlim([0.5,nSite+0.5])
ylim([0.5,nSite+0.5])

if iDiag == 1
    ax2 = axes('Position', [init_x, init_y length_x/2 length_y]);
else
ax2 = axes('Position', [init_x, init_y+length_y*factor_y*(6-iDiag) length_x/2 length_y/2]);
end

denPlot = plot(ax2, xi, fi, 'LineWidth', lineWidth);
xlim([-0.5 1]);
if iDiag == 1
xlabel('correlation')
end
ylabel('density')
set(ax2,'box','off')
set(ax2, 'color','none')
end

% a1 = annotation(fig, 'textbox', [0, 0.02, 1, 0.02], 'string', ...
%     ['Figure 1: For each diagnosis, the upper panel shows the between-site correlation ' ...
%     'matrix of the t-maps and the lower panel shows the kernel density estimation of all elements of the between-site correlation matrix.'], ...
%     'edgecolor', 'none', ...
%     'FontName',font_name,'FontSize',font_size, 'horizontalalignment', 'left');


%%
% savefig(fig,['figure_corr_zmap_surface.fig']);
% set(fig, 'PaperPositionMode', 'auto')
% print(fig, '-djpeg', '-r600', 'figure_corr_zmap_surface.jpg')