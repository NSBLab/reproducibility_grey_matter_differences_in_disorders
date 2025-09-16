clear all
% close all

smoothKernel = 8;

dataVBMDir = fullfile('/scratch','kg98','trangc','VBM','data','derivatives',['s',num2str(smoothKernel)],'resample_match');
sampleSizeList = [20 40 60 100 150 200 300 350];
sampleSizeSBMList = [20 40 60 100 150 200 300 400 550];

nSize = length(sampleSizeList);
%
fig = figure('Position', [200 200 800 400]);
set(fig,'color','w');
factor_x = 1.2;
factor_y = 1.5;
init_x = 0.1;
init_y = 0.1;
num_row = 1;
num_col = 2;
length_x = (0.82 - init_x)/(factor_x*(num_col-1) + 1);
length_y = (0.95 - init_y)/(factor_y*(num_row-1) + 1);
lineWidth = 2;
%
font_name = 'Arial';
font_size = 10;
fontsize_legend = 8;
%%

colorVec = {[225 232 255], [205 217 255], [185 202 255], [165 186 255], [145 171 255], [115 148 255], [85 125 255], [55 103 255],[5 65 255],[0 48 200],[0 36 150],[0 24 100] };
%VBM
ax2 = axes('Position', [init_x, init_y length_x length_y]);

for iSampleSize=1:length(sampleSizeList)
    sampleSize = sampleSizeList(iSampleSize);

    contrastDir = fullfile(dataVBMDir,['sampleSize_',num2str(sampleSize)]);
matFile = load(fullfile(contrastDir,'cor.mat'));

[fi xi]=ksdensity(matFile.cor,'function','pdf','npoints',200);
 


denPlot = plot(ax2, xi, fi, 'LineWidth', lineWidth,'Color',colorVec{length(colorVec)-length(sampleSizeSBMList)+iSampleSize}./255);
hold on

set(ax2,'box','off')
set(ax2, 'color','none')
xlim([-0.4 1]);
ylim([0 25]);
end
plotLegend = legend(arrayfun(@num2str,sampleSizeList,'UniformOutput',0),'Location','best')

xlabel('correlation')
ylabel({'density'})
legend('boxoff')


%SBM
smoothKernel = 10;

dataDir = ['/scratch/kg98/trangc/VBM/data/derivatives/freesurfer/s',char(num2str(smoothKernel)),'COMBAT/resample_match'];
  
nSize = length(sampleSizeSBMList);  
ax1 = axes('Position', [init_x+length_x*factor_x, init_y length_x length_y]);


for iSampleSize=1:length(sampleSizeSBMList)
    sampleSize = sampleSizeSBMList(iSampleSize);

    contrastDir = fullfile(dataDir,['sampleSize_',num2str(sampleSize)]);
    matFile = load(fullfile(contrastDir,'cor.mat'));

    [fi xi]=ksdensity(matFile.corZAll,'function','pdf','npoints',200);




    denPlot = plot(ax1, xi, fi, 'LineWidth', lineWidth,'Color',colorVec{length(colorVec)-length(sampleSizeSBMList)+iSampleSize}./255);
hold on

    set(ax1,'box','off')
    set(ax1, 'color','none')
    xlim([-0.4 1]);
    
end
plotLegend = legend(arrayfun(@num2str,sampleSizeSBMList,'UniformOutput',0),'Location','best')

xlabel('correlation')
ylabel({'density'})
legend('boxoff')

a15 = annotation(fig, 'textbox', [0.01, 0.98, 0.09, 0.02], 'string', 'a|', 'edgecolor', 'none', ...
    'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'center');
a16 = annotation(fig, 'textbox', [0.38, 0.98, 0.09, 0.02], 'string', 'b|', 'edgecolor', 'none', ...
    'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'center');

% a1 = annotation(fig, 'textbox', [0, 0.02, 1, 0.02], 'string', ...
%     ['Figure 1: For each disorder, the upper panel shows the between-site correlation ' ...
%     'matrix of the t-maps and the lower panel shows the kernel density estimation of all elements of the between-site correlation matrix.'], ...
%     'edgecolor', 'none', ...
%     'FontName',font_name,'FontSize',font_size, 'horizontalalignment', 'left');


%%
% savefig(fig,['output/figure_corr_tmap_noCombat.fig']);
% set(fig, 'PaperPositionMode', 'auto')
% print(fig, '-djpeg', '-r1200', 'output/figure_corr_tmap_noCombat.jpg')