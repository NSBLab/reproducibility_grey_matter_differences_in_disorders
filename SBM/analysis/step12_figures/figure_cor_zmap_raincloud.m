clear all
% close all
addpath('/home/trangc/kg98/trangc/library/Violinplot-Matlab-master')
addpath(genpath('/projects/kg98/trangc/VBM/code'))
iCOMBAT = 1;
smoothKernel = 10;
hemi = 'rh';
thres = 0.05;


diagnosisString = {'BD', 'SCA',...
    'SCZ', 'ASD', 'MDD','AD' };
diagnosisStr = {'Bipolar', 'Schizoaffective',...
    'Schizophrenia', 'Autism', 'Depression','Alzheimer' };
nDiag = length(diagnosisString);
plotorder = [ 3 2 4 5 1 6]; % change the order of disorder appear in the plot


light_green = [0.25 0.75 0.25];
% darkblue = [0 0 204/255];
lightblue = [0 153/255 255/255];
darkred = [150/255 0 0];
lightred = [255/255 147/255 147/255];
darkblue = [10/255 52/255 204/255];
gray = [0.5 0.5 0.5];
lightorange =  [124/255 125/255 117/255];%[255/255 211/255 147/255];%[0.75 0.5 0.25];
darkorange = [242/255 144/255 0];%[0.75 0.25 0.25]; %

fig = figure('Position', [200 200 1500 800]);
set(fig,'color','w');
factorX = 1.1;
factorY = 1.7;
initX = 0.05;
initY = 0.09;
numRow = 4;
numCol = 2;
lengthX = (0.95 - initX)/(factorX*(numCol-1) + 1);
lengthY = (0.93 - initY)/(factorY*(numRow-1) + 1);

factorMapX = 1.01;
factorMapY = 1;
initMapX = initX+lengthX*2*factorX+0.05;
initMapY = 0.01;
numRowMap = nDiag*2;
numColMap = 4;
lengthMapX = lengthX*0.15;
lengthMapY = lengthY*0.5;
lineWidth = 2;

initVioX = 0.2;

font_name = 'Arial';
font_size = 12;
fontsize_legend = 10;

%load vtk surface
filename_vtk = ['/projects/kg98/trangc/atlases/standard_mesh_atlases/resample_fsaverage/',hemi,'_fsaverage_164k_midthickness.vtk'];
[vertices,faces] = read_vtk(filename_vtk);
vertices = vertices';
faces = faces';

load(['output/corr_zmap_combat',num2str(iCOMBAT),'_smooth',num2str(smoothKernel),'_',hemi,'_all.mat'], 'map','corDiag', 'corSig','siteList')
load(['output/zmap_null_COMBAT1_',hemi,'_smooth',num2str(smoothKernel),'_ver_all.mat'],...
    'corzmapSurrsVerAll','corsigmapSurrsVerAll','repsigmapSurrsVerAll');


makeUvalue = 0;
for iDiag = 1:nDiag
iData = plotorder(iDiag); % the order in the data
    iCol = mod(iDiag+1,2);
    iRow = floor((iDiag+1)/2);
    ax1 = axes('Position', [initX+factorX*lengthX*(iCol), initY+factorY*lengthY*(numRow-iRow) lengthX lengthY]);
    ids{iDiag}=find(tril(ones(size(corDiag{iData})),-1));
    corToPlot{1,iDiag} = corDiag{iData}(ids{iDiag});
    corToPlot{2,iDiag} = corzmapSurrsVerAll{iData};


    % plot table
    nSite = length(siteList{iData});
    hm = imagesc(ax1,1:nSite, 1:nSite, tril(corDiag{iData},-1));

    clim([-1 1]);
    colormap(ax1, greenwhiteviolet(ax1));
    if iDiag == 6
        c1 =  colorbar('Position', [0.93, 0.82, 0.008, lengthY*0.9],'AxisLocation','out')
         c1.Label.String = 'correlation';
        c1.Label.Rotation = 0;
        c1.Label.Position = [0.9 1.5];
c1.Label.FontSize = fontsize_legend;

    end

    xticks(ax1,[1:nSite])
    xticklabels(ax1,arrayfun(@(x) num2str(x),[1:nSite],'UniformOutput',false));
    yticks(ax1,[1:nSite])
    yticklabels(ax1,arrayfun(@(x) num2str(x),[1:nSite],'UniformOutput',false))
    set(ax1,'box','off','TickLabelInterpreter', 'none','xaxisLocation','bottom','yaxisLocation','left','FontSize',fontsize_legend)
    grid off
    xlim([0.5,nSite+0.5])
    ylim([0.5,nSite+0.5])
    xlabel('site','FontSize',fontsize_legend)
    ylabel('site','FontSize',fontsize_legend)
    if iDiag == 1

        ax1.YTickLabel(2:end-1)= cellfun(@(i) [],ax1.XTickLabel(2:end-1),'UniformOutput',false);
        set(ax1,'TickLabelInterpreter', 'latex');
    end
if iDiag == 5

        ax1.YTickLabel(2:end-1)= cellfun(@(i) [],ax1.XTickLabel(2:end-1),'UniformOutput',false);
        set(ax1,'TickLabelInterpreter', 'latex');
    end
    %  max and min corr
    posSite = find(str2double(map.diag)==iData+1);

    maxCor = max(corToPlot{1,iDiag});
    [rowMax colMax] = find(round(maxCor,9)==round(corDiag{iData},9));
    % listSite = [rowMax colMax];

    minCor = min(corToPlot{1,iDiag});
    [rowMin colMin] = find(round(minCor,9)==round(corDiag{iData},9));
    % listSite = [rowMin colMin];

    % if colMax(1) <= colMin(1)
    colLeft = colMax; 
    colRight = colMin;
    % else
    %     colLeft = colMin;
    %     colRight = colMax;
    % end

    % plot two sites on the left
    for iSite = 1:length(colLeft)
        iMap = posSite(colLeft(iSite));
        ax3 = axes('Position', [ax1.Position(1)+ax1.Position(3)*0.28+lengthMapX*factorMapX*(iSite-1) ax1.Position(2)+ax1.Position(4)*0.76 lengthMapX lengthMapY]);

        patch(ax3, 'Vertices', vertices, 'Faces', faces, 'FaceVertexCData', map.zmap(iMap,:)', ...
            'EdgeColor', 'none', 'FaceColor', 'interp');
        if strcmp(hemi,'lh')
            view([-90 0]);
        else
            view([90 0]);
        end
        camlight('headlight')
        material dull
        if makeUvalue == 0
            unified_AxisValue = ax3;
            makeUvalue = 1;

        end
        colormap(ax3,bluewhitered(unified_AxisValue))
        axis off;
        axis image;
        clim(ax3,[-8 8])
                 a16 = annotation(fig, 'textbox', [ax3.Position(1)+ax3.Position(3)*0.17, ax3.Position(2)-ax3.Position(4)*0.18, ax3.Position(3)*2, 0.02], 'string', ['site ',char(num2str(colLeft(iSite)))], 'edgecolor', 'none', ...
        'color',darkorange,'FontName',font_name,'FontSize',fontsize_legend,  'horizontalalignment', 'left');
    end

    a15 = annotation(fig, 'textbox', [ax3.Position(1)-ax3.Position(3)*1.1, ax3.Position(2)+ax3.Position(4)*1.1, ax3.Position(3)*2, 0.02], 'string', 'r_{max}', 'edgecolor', 'none', ...
        'color',darkorange,'FontName',font_name,'FontSize',fontsize_legend,  'horizontalalignment', 'center');

    a1 = annotation(fig,'rectangle',[(ax1.Position(1)+ax1.Position(3)/nSite*(colLeft(1)-1)) (ax1.Position(2)+ax1.Position(4)/nSite*(nSite-colLeft(2))) ax1.Position(3)/nSite ax1.Position(4)/nSite],'EdgeColor',darkorange,'LineWidth',1);
     % plot maps on the right

    for iSite = 1:length(colRight)
        iMap = posSite(colRight(iSite));
        ax5 = axes('Position', [ax1.Position(1)+ax1.Position(3)*0.32+lengthMapX*factorMapX*(iSite+1) ax1.Position(2)+ax1.Position(4)*0.76 lengthMapX lengthMapY]);
        patch(ax5, 'Vertices', vertices, 'Faces', faces, 'FaceVertexCData', map.zmap(iMap,:)', ...
            'EdgeColor', 'none', 'FaceColor', 'interp');

        if strcmp(hemi,'lh')
            view([-90 0]);
        else
            view([90 0]);
        end

        camlight('headlight')
        material dull
        colormap(ax5,bluewhitered(unified_AxisValue))
        axis off;
        axis image;
        clim(ax5,[-8 8])

         a16 = annotation(fig, 'textbox', [ax5.Position(1)+ax5.Position(3)*0.1, ax5.Position(2)-ax5.Position(4)*0.2, ax5.Position(3)*2, 0.02], 'string', ['site ',char(num2str(colRight(iSite)))], 'edgecolor', 'none', ...
        'color',lightorange,'FontName',font_name,'FontSize',fontsize_legend,  'horizontalalignment', 'left');
  

    end
    a15 = annotation(fig, 'textbox', [ax5.Position(1)-ax5.Position(3)*1.1, ax5.Position(2)+ax5.Position(4)*1.1, ax5.Position(3)*2, 0.02], 'string', 'r_{min}', 'edgecolor', 'none', ...
        'color',lightorange,'FontName',font_name,'FontSize',fontsize_legend,  'horizontalalignment', 'center');
    % a6 = annotation(fig,'arrow',[ax1.Position(1)+ax1.Position(3)/length(corDiag{iDiag})*(colRight(1)-0.5) ax5.Position(1)-ax5.Position(3)*0.1],...
    % [ax1.Position(2)+ax1.Position(4)/length(corDiag{iDiag})*(length(corDiag{iDiag})-colRight(2)+0.5) ax5.Position(2)+ax5.Position(4)*0],'LineWidth',0.8,'LineWidth',0.8,'HeadLength',5,'HeadWidth',5);
    a1 = annotation(fig,'rectangle',[(ax1.Position(1)+ax1.Position(3)/nSite*(colRight(1)-1)) (ax1.Position(2)+ax1.Position(4)/nSite*(nSite-colRight(2))) ax1.Position(3)/nSite ax1.Position(4)/nSite],'EdgeColor',lightorange,'LineWidth',1);
    % a2 = annotation(fig,'rectangle',[(ax5.Position(1)-ax5.Position(3)*1.1) (ax5.Position(2)-ax5.Position(4)*0.1) ax5.Position(3)*2.3 ax5.Position(4)*1.3],'EdgeColor',darkred,'LineWidth',1);

    a15 = annotation(fig, 'textbox', [ax1.Position(1)-ax1.Position(3)*0.1, ax1.Position(2)+ax1.Position(4)*1.2, 0.09, 0.02], 'string', diagnosisStr{iData}, 'edgecolor', 'none', ...
        'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'center');
    % Wilcoxon test
    % [prs(iDiag), hrs(iDiag)] = ranksum(corToPlot{1,iDiag}, corToPlot{2,iDiag});
% Extract empirical median
empiricalMedian = median(corToPlot{1, iDiag});
nullMedian = median(corToPlot{2, iDiag});
% Calculate percentile (i.e., proportion of null values less than or equal to empirical median)
p_value(iDiag) = mean(abs(empiricalMedian - nullMedian  ) <= abs(corToPlot{2, iDiag}-nullMedian));

end

c2 = colorbar('Position', [0.93, 0.59, 0.008, lengthY*0.9],'AxisLocation','out','Ticks',[-6 6],'TickLabels',{'increased \newline in cases' 'reduced \newline in cases'})
c2.Label.String = 'map';
c2.Label.Rotation = 0;
c2.Label.Position = [0.16 11.5];
c2.Label.FontSize = fontsize_legend;
% fprintf('%.5f, ', prs);
% fprintf('%.5f, ', hrs);
C = [darkblue; lightblue]; %lines;
ViolinColor = {repmat(C,ceil(size(corToPlot,2)/length(C)),1)};

ax2 = axes('Position', [initX, initY*0.35 lengthX*numCol*factorX-initX lengthY*factorY]);
violinplot_subclass(corToPlot, diagnosisStr(plotorder),'ViolinColor',ViolinColor,'BoxColor',[0 0 0],'BoxWidth',0.07,'MarkerSize',26,'Width',0.4);
%[1 3 5 2 4 6]
set(ax2,'FontSize',fontsize_legend)
ylabel('correlation','FontSize',fontsize_legend)
set(ax2,'box','off')
tempXlim = xlim;
tempYlim = [-1 1];
dummyplot1 = scatter(ax2,[-1],[-1],'marker','o','MarkerEdgeColor',darkblue,'MarkerFaceColor',C(1,:));
dummyplot2 = scatter(ax2,[-1],[-1],'marker','o','MarkerEdgeColor',C(2,:),'MarkerFaceColor',C(2,:));

legend([dummyplot1,dummyplot2],{'Observed','Null'},'Location','northeast')
xlim([0 tempXlim(2)])
ylim(tempYlim)

legend('boxoff')
for iDiag = 1:nDiag
    if p_value(iDiag) <= thres
 a17 = annotation(fig, 'textbox', [ax2.Position(1)+ax2.Position(3)*(0.05+(iDiag-1)*0.165), ax2.Position(2)+ax2.Position(4)*0.3, 0.09, 0.02], 'string', '*', 'edgecolor', 'none', ...
        'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'left','Interpreter','none');
    end
end
% mean and range
medCor =  cellfun(@(x) median(x), corToPlot)
minCor = cellfun(@(x) min(x), corToPlot)
maxCor = cellfun(@(x) max(x), corToPlot)

a25 = annotation(fig, 'textbox', [0, 0.98, 0.02, 0.02], 'string', 'a|', 'edgecolor', 'none', ...
    'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'center');

a26 = annotation(fig, 'textbox', [0, 0.27, 0.03, 0.02], 'string', 'b|', 'edgecolor', 'none', ...
    'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'center');




%%
savefig(fig,['output/figure_corr_zmap_combat',char(num2str(iCOMBAT)),'_',hemi,'_smooth',num2str(smoothKernel),'_CiNP.fig']);
set(fig, 'PaperPositionMode', 'auto')
print(fig, '-djpeg', '-r1200', ['output/figure_corr_zmap_combat',char(num2str(iCOMBAT)),'_',hemi,'_smooth',num2str(smoothKernel),'_CiNP.jpg'])
