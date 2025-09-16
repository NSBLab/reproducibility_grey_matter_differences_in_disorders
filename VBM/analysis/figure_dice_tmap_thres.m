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

disorder = {'ASD', 'BD' , 'MDD', 'SCA', 'SCZ'};



fig = figure('Position', [200 200 1000 2500]);
set(fig,'color','w');
factor_x = 1.2;
factor_y = 1.5;
init_x = 0.1;
init_y = 0.1;
num_row = 6;
num_col = 1;
length_x = (0.82 - init_x)/(factor_x*(num_col-1) + 1);
length_y = (0.95 - init_y)/(factor_y*(num_row-1) + 1);
lineWidth = 2;

font_name = 'Arial';
font_size = 10;
fontsize_legend = 8;
% a1 = annotation(fig, 'textbox', [0, 0.98, 0.7, 0.01], 'string', 'A', 'edgecolor', 'none', ...
%     'FontName',font_name,'FontSize',font_size, 'horizontalalignment', 'center');
% a2 = annotation(fig, 'textbox', [0.7, 0.98, 0.3, 0.01], 'string', 'B', 'edgecolor', 'none', ...
%     'FontName',font_name,'FontSize',font_size, 'horizontalalignment', 'center');
%%

load('output/dice.mat', 'cor1', 'cor2')

for iSite = 1:5
[LaDiag LbDiag] = ismember(metadata.diagnosis_string,diagnosisString(iSite));
[siteString ia ic] = unique(metadata.site_string(LaDiag));
[siteString] = change_siteName(siteString);
nSite = length(siteString);

ids=find(triu(ones(size(cor1{iSite})),1));
[fi xi]=ksdensity(cor1{iSite}(ids),'function','pdf','npoints',200);
 
if iSite == 5
    ax1 = axes('Position', [init_x, init_y length_x length_y*2]);
    a32 = annotation(fig, 'textbox', [0, ax1.Position(2)+length_y*2, 1, 0.01], 'string', char(disorder(iSite)), 'edgecolor', 'none', ...
    'FontName',font_name,'FontSize',font_size, 'horizontalalignment', 'left');
else
ax1 = axes('Position', [init_x, init_y+length_y*factor_y*(6-iSite) length_x length_y]);
a32 = annotation(fig, 'textbox', [0, ax1.Position(2)+length_y, 1, 0.01], 'string', char(disorder(iSite)), 'edgecolor', 'none', ...
    'FontName',font_name,'FontSize',font_size, 'horizontalalignment', 'left');
end

hm = imagesc(1:length(siteString), 1:length(siteString), triu(cor1{iSite},1));
clim([0 0.8]);
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

if iSite == 5
    ax2 = axes('Position', [init_x, init_y length_x/2 length_y]);
else
ax2 = axes('Position', [init_x, init_y+length_y*factor_y*(6-iSite) length_x/2 length_y/2]);
end

denPlot = plot(ax2, xi, fi, 'LineWidth', lineWidth);
xlim([-0.5 1]);
xlabel('correlation')
ylabel('density')
set(ax2,'box','off')
set(ax2, 'color','none')
end

% a1 = annotation(fig, 'textbox', [0, 0.02, 1, 0.02], 'string', ...
%     ['Figure 1: For each disorder, the upper panel shows the between-site correlation ' ...
%     'matrix of the t-maps and the lower panel shows the kernel density estimation of all elements of the between-site correlation matrix.'], ...
%     'edgecolor', 'none', ...
%     'FontName',font_name,'FontSize',font_size, 'horizontalalignment', 'left');


%%
savefig(fig,['output/figure_dice_tmap_thres.fig']);
set(fig, 'PaperPositionMode', 'auto')
print(fig, '-djpeg', '-r600', 'output/figure_dice_tmap_thres.jpg')