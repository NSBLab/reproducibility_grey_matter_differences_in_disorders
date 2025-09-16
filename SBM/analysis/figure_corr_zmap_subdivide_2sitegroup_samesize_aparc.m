clear all
% close all

smoothKernel = 10;
diaglist = 2:7;
hemis = 'lh';
diagString = {'Bipolar', 'Schizoaffective',...
    'Schizophrenia', 'Autism', 'Depression','Alzheimer' };

addpath(genpath('/projects/kg98/trangc/VBM/code'))

sampleSizeList = [10    16    25    40    63   100   158   251   398   631];
colorVec = {[225 232 255], [205 217 255], [185 202 255], [165 186 255], [145 171 255], [115 148 255], [85 125 255], [55 103 255],[5 65 255],[0 48 200],[0 36 150],[0 24 100] };
colorpalette = colororder('gem');

nSize = length(sampleSizeList);
fig = figure('Position', [200 200 700 500]);
set(fig,'color','w');
factor_x = 1.2;
factor_y = 1.5;
init_x = 0.1;
init_y = 0.2;
num_row = 1;
num_col = 1;
length_x = (0.82 - init_x)/(factor_x*(num_col-1) + 1);
length_y = (0.95 - init_y)/(factor_y*(num_row-1) + 1);
lineWidth = 2;

%
font_name = 'Arial';
font_size = 10;
fontsize_legend = 8;

ax2 = axes('Position', [init_x, init_y length_x length_y]);

%load vtk surface
filename_vtk = 'fsaverage_164k_midthickness-lh.vtk';
[vertices,faces] = read_vtk(filename_vtk);
vertices = vertices';
faces = faces';


load('output/corr_zmap_subdivide_2sitegroup_samesize_aparc.mat', 'meanCor','varCor','meanCorThres','varCorThres','meanrepliDivi','varrepliDivi');
meanCor = meanrepliDivi;
varCor = varrepliDivi;
for iDiag = 1:length(diaglist)
    diag = diaglist(iDiag)

    lengthToPlot = sum(meanCor(iDiag,:)>0);
    % Compute the upper and lower bounds for the shaded region
    upperBound = meanCor(iDiag,1:lengthToPlot) + sqrt(varCor(iDiag,1:lengthToPlot));
    lowerBound = meanCor(iDiag,1:lengthToPlot) - sqrt(varCor(iDiag,1:lengthToPlot));

    sampleSizetoPlot = sampleSizeList(1:lengthToPlot);
    % Shaded area for variance
    newColor = colorpalette(iDiag,:);
    colorfactor = 1.1;
    for i=1:3
        newColor(i) = colorpalette(iDiag,i)*colorfactor*(colorpalette(iDiag,i).*colorfactor<=1)+ colorpalette(iDiag,i)*(colorpalette(iDiag,i).*colorfactor>1);
    end
    if lengthToPlot >0
        h1 = fill(ax2,[sampleSizetoPlot fliplr(sampleSizetoPlot)], [upperBound fliplr(lowerBound)], 'b', 'FaceAlpha', 0.1, 'EdgeColor', 'none','FaceColor',newColor);
        hold on
        % Plot the mean line
        h2(iDiag) = plot(ax2, sampleSizetoPlot, meanCor(iDiag,1:lengthToPlot), 'b', 'LineWidth', 2,'Color',colorpalette(iDiag,:));

    end

end



set(ax2,'box','off')
set(ax2, 'color','none')
set(ax2, 'XScale','log')
xlim([10 700]);
ylim([0 1]);
% Customize x-axis tick marks
set(ax2, 'XTick', sampleSizeList);
sampleLabel = arrayfun(@(x) char(num2str(x)), sampleSizeList, 'UniformOutput', false);
set(ax2, 'XTickLabel', sampleLabel);
plotLegend = legend(h2, diagString,'Location','northwest')

ylabel('correlation')
xlabel({'sample size'})
legend('boxoff')


%%
savefig(fig,['output/figure_corr_zmap_subdivide_2sitegroup_samesize_aparc.fig']);
set(fig, 'PaperPositionMode', 'auto')
print(fig, '-djpeg', '-r1200', 'output/figure_corr_zmap_subdivide_2sitegroup_samesize_aparc.jpg')