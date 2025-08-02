clear all
% close all

smoothKernel = 10;

dataDir = ['/scratch/kg98/trangc/VBM/data/derivatives/freesurfer/s',char(num2str(smoothKernel)),'COMBAT/resample_samesite'];

sampleSizeList = [2 3 4 6 10];
nSize = length(sampleSizeList);
% 
fig = figure('Position', [200 200 1000 2500]);
set(fig,'color','w');
factor_x = 1.2;
factor_y = 1.5;
init_x = 0.1;
init_y = 0.1;
num_row = nSize;
num_col = 1;
length_x = (0.82 - init_x)/(factor_x*(num_col-1) + 1);
length_y = (0.95 - init_y)/(factor_y*(num_row-1) + 1);
lineWidth = 2;
% 
font_name = 'Arial';
font_size = 10;
fontsize_legend = 8;
%%

for iSampleSize=1:length(sampleSizeList)
    sampleSize = sampleSizeList(iSampleSize);

    contrastDir = fullfile(dataDir,['nGroup_',num2str(sampleSize)]);
matFile = load(fullfile(contrastDir,'cor.mat'));

[fi xi]=ksdensity(matFile.corZAll,'function','pdf','npoints',200);
 


ax2 = axes('Position', [init_x, init_y+length_y*factor_y*(nSize-iSampleSize) length_x length_y]);


denPlot = plot(ax2, xi, fi, 'LineWidth', lineWidth);


set(ax2,'box','off')
set(ax2, 'color','none')
xlim([-0.5 1]);
ylabel({['n=',num2str(sampleSize)],'density'})
end


xlabel('correlation')


% a1 = annotation(fig, 'textbox', [0, 0.02, 1, 0.02], 'string', ...
%     ['Figure 1: For each disorder, the upper panel shows the between-site correlation ' ...
%     'matrix of the t-maps and the lower panel shows the kernel density estimation of all elements of the between-site correlation matrix.'], ...
%     'edgecolor', 'none', ...
%     'FontName',font_name,'FontSize',font_size, 'horizontalalignment', 'left');


%%
% savefig(fig,['output/figure_corr_tmap_noCombat.fig']);
% set(fig, 'PaperPositionMode', 'auto')
% print(fig, '-djpeg', '-r1200', 'output/figure_corr_tmap_noCombat.jpg')