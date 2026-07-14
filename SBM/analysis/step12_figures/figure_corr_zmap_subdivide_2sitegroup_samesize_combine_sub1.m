clear all
% close all

smoothKernel = 10;
diaglist = 2:7;
hemis = 'lh';
diagString = {'Bipolar', 'Schizoaffective',...
    'Schizophrenia', 'Autism', 'Depression','Alzheimer' };
plotorder = [6 3 2 4 5 1]; % change the order of disorder appear in the plot
addpath(genpath('/projects/kg98/trangc/VBM/code'))

sampleSizeList = [10    16    25    40    63   100   158   251   398   631];
colorVec = {[225 232 255], [205 217 255], [185 202 255], [165 186 255], [145 171 255], [115 148 255], [85 125 255], [55 103 255],[5 65 255],[0 48 200],[0 36 150],[0 24 100] };
colorpalette = colororder('gem');
colorpalette(6,:) = [0.5 0.5 0.5];

nSize = length(sampleSizeList);
fig = figure('Position', [200 200 800 300]);
set(fig,'color','w');
factorX = 1.2;
factorY = 1.1;
initX = 0.1;
initY = 0.2;
numRow = 1;
numCol = 2;
lengthX = (0.95 - initX)/(factorX*(numCol-1) + 1);
lengthY = (0.9 - initY)/(factorY*(numRow-1) + 1);
lineWidth = 2;

%
font_name = 'Arial';
font_size = 12;
fontsize_legend = 10;


%load vtk surface
filename_vtk = 'fsaverage_164k_midthickness-lh.vtk';
[vertices,faces] = read_vtk(filename_vtk);
vertices = vertices';
faces = faces';
subplotTitle = {'a|','b|','c|','d|','e|','f|'};
% subplotTitle = {'a|Vertice-wise','b|Schaefer-1000','c|Schaefer-1000','d|Schaefer-1000'};

for iPlot = 1:2%length(subplotTitle)
    iCol = iPlot; %mod(iPlot-1,numCol);
    iRow = 1; %floor((iPlot-1)/numCol);
    ax1 = axes('Position', [initX+factorX*lengthX*(iCol-1), initY lengthX lengthY]);
    switch iPlot
        % case 1
        %     load('output/corr_zmap_subdivide_2sitegroup_samesize.mat', 'medianCor','varCor','sampleSizeListAll');
        %     medianCor = medianCor;
        %     varCor = varCor;
             case 1
            load('output/corr_zmap_subdivide_2sitegroup_samesize.mat', 'medianCorThres','varCorThres','sampleSizeListAll');
            medianCor = medianCorThres;
            varCor = varCorThres;
             case 2
            load('output/corr_zmap_subdivide_2sitegroup_samesize.mat', 'medianRepThres','varCorThres','sampleSizeListAll');
            medianCor = medianRepThres;
            varCor = varCorThres;

        % case 2
        %     load('output/corr_zmap_parc_subdivide_2sitegroup_samesize.mat', 'mediancorDiagSF1000','varcorDiagSF1000','sampleSizeListAll');
        %     medianCor = mediancorDiagSF1000;
        %     varCor = varcorDiagSF1000;
        % case 5
        %     load('output/corr_zmap_parc_subdivide_2sitegroup_samesize.mat', 'mediancorSigSF1000','varcorSigSF1000','sampleSizeListAll');
        %     medianCor = mediancorSigSF1000;
        %     varCor = varcorSigSF1000;
        % case 6
        %     load('output/corr_zmap_parc_subdivide_2sitegroup_samesize.mat', 'medianrepSigSF1000','varrepSigSF1000','sampleSizeListAll');
        %     medianCor = medianrepSigSF1000;
        %     varCor = varrepSigSF1000;
            
        otherwise
            error('no suitable data')
    end

    for iDiag = 1:length(diaglist)
        iData = plotorder(iDiag); % the order in the data
        diag = diaglist(iData);
        increaseCor{iData} = medianCor{iData}./medianCor{iData}(1);
       
  sampleSizeList = sampleSizeListAll{iData};
        lengthToPlot = sum(medianCor{iData}~=0);
        % Compute the upper and lower bounds for the shaded region
        upperBound = medianCor{iData}(1:lengthToPlot) + sqrt(varCor{iData}(1:lengthToPlot));
        lowerBound = medianCor{iData}(1:lengthToPlot) - sqrt(varCor{iData}(1:lengthToPlot));

        sampleSizetoPlot = sampleSizeListAll{iData}(1:lengthToPlot);
        % Shaded area for variance
        newColor = colorpalette(iData,:);
        colorfactor = 1.1;
        for i=1:3
            newColor(i) = colorpalette(iData,i)*colorfactor*(colorpalette(iData,i).*colorfactor<=1)+ colorpalette(iData,i)*(colorpalette(iData,i).*colorfactor>1);
        end

        h1 = fill(ax1,[sampleSizetoPlot fliplr(sampleSizetoPlot)], [upperBound fliplr(lowerBound)], 'b', 'FaceAlpha', 0.1, 'EdgeColor', 'none','FaceColor',newColor);
        hold on
        % Plot the median line
        h2(iDiag) = plot(ax1, sampleSizetoPlot, medianCor{iData}(1:lengthToPlot), 'b', 'LineWidth', 2,'Color',colorpalette(iData,:));



    end

%  increaseCor{3}(7:8)
% increaseCor{5}(7)
% increaseCor{6}(6)
    set(ax1,'box','off')
    set(ax1, 'color','none')
    set(ax1, 'XScale','log')
    xlim([10 600]);
    ylim([-0.1 1]);

%     if mod(iPlot,numCol) == 1 
%     ylabel('Correlation')
% end
if  mod(iPlot,numCol) == 1
    ylabel('Binary correlation')
end
if  mod(iPlot,numCol) == 0
    ylabel('Replication')
end
    xlabel({'sample size'})
    % Customize x-axis tick marks
    set(ax1, 'XTick', sampleSizeListAll{3});
    sampleLabel = arrayfun(@(x) char(num2str(x)), sampleSizeListAll{3}, 'UniformOutput', false);
    set(ax1, 'XTickLabel', sampleLabel);
    if iPlot == 1
    plotLegend = legend(h2, diagString(plotorder),'Location','northwest');

    legend('boxoff')
    end
    
end
 % a25 = annotation(fig, 'textbox', [0.01, 0.99, 0.1, 0.02], 'string', 'a|Vertex-wised', 'edgecolor', 'none', ...
 %    'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'left');
 % 
 %  a25 = annotation(fig, 'textbox', [0.5, 0.99, 0.1, 0.02], 'string', 'b|Schaefer-1000', 'edgecolor', 'none', ...
 %    'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'left');


    %%
    savefig(fig,['output/figure_corr_zmap_subdivide_2sitegroup_samesize_combine_sub1.fig']);
    set(fig, 'PaperPositionMode', 'auto')
    print(fig, '-djpeg', '-r1200', 'output/figure_corr_zmap_subdivide_2sitegroup_samesize_combine_sub1.jpg')