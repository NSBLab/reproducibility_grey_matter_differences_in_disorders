clear all
% close all
addpath('/home/trangc/kg98/trangc/library/Violinplot-Matlab-master')
addpath(genpath('/projects/kg98/trangc/VBM/code'))
iCOMBAT = 1;
smoothKernel = 10;
nMode =200;

diagnosisString = {'BD', 'SCA',...
    'SCZ', 'ASD', 'MDD','AD' };
diagnosisStr = {'Bipolar', 'Schizoaffective',...
    'Schizophrenia', 'Autism', 'Depression','Alzheimer' };
nDiag = length(diagnosisString);

mask = readmatrix('/projects/kg98/trangc/MBM/data/demo_emp/fsaverage_164k_cortex-lh_mask.txt');

light_green = [0.25 0.75 0.25];
% darkblue = [0 0 204/255];
lightblue = [0 153/255 255/255];
darkred = [150/255 0 0];
lightred = [255/255 147/255 147/255];
darkblue = [10/255 52/255 204/255];
gray = [0.5 0.5 0.5];
lightorange =  [124/255 125/255 117/255];%[255/255 211/255 147/255];%[0.75 0.5 0.25];
darkorange = [242/255 144/255 0];%[0.75 0.25 0.25]; %

fig = figure('Position', [200 200 1200 800]);
set(fig,'color','w');
factorX = 1.1;
factorY = 1.7;
initX = 0.05;
initY = 0.09;
numRow = 4;
numCol = 2;
lengthX = (0.95 - initX)/(factorX*(numCol-1) + 1);
lengthY = (0.93 - initY)/(factorY*(numRow-1) + 1);

factorMapX = 1.05;
factorMapY = 1;
initMapX = initX+lengthX*2*factorX+0.05;
initMapY = 0.01;
numRowMap = nDiag*2;
numColMap = 4;
lengthMapX = lengthX*0.15;
lengthMapY = lengthY*0.55;
lineWidth = 2;

initVioX = 0.2;

font_name = 'Arial';
font_size = 10;
fontsize_legend = 8;

%load vtk surface
filename_vtk = 'fsaverage_164k_midthickness-lh.vtk';
[vertices,faces] = read_vtk(filename_vtk);
vertices = vertices';
faces = faces';

load(['output/corr_MBM_uncorrected_',char(num2str(nMode)),'mode.mat'], 'map','corDiagBetaThres', 'siteList')
 %load(['output/corr_null_zmap_combat',num2str(iCOMBAT),'_smooth',num2str(smoothKernel),'.mat'], 'corDiagNullAll','corSigNullAll','corDiagMaxNullAll','corSigMaxNullAll','pCorDiag','pCorSig')
corDiag = corDiagBetaThres;



for iDiag = 1:nDiag

    iCol = mod(iDiag+1,2);
    iRow = floor((iDiag+1)/2);
    ax1 = axes('Position', [initX+factorX*lengthX*(iCol), initY+factorY*lengthY*(numRow-iRow) lengthX lengthY]);
    ids{iDiag}=find(tril(ones(size(corDiag{iDiag})),-1));
    corToPlot{1,iDiag} = corDiag{iDiag}(ids{iDiag});
    %corToPlot{2,iDiag} = corDiagMaxNullAll{iDiag};


    % plot table
    nSite = length(siteList{iDiag});
    hm = imagesc(ax1,1:nSite, 1:nSite, tril(corDiag{iDiag},-1));

    clim([-1 1]);
    colormap(ax1, greenwhiteviolet(ax1));
    if iDiag == 1
       c1 =  colorbar('Position', [initX*0.6, initY, 0.01, lengthY],'AxisLocation','out')
        % c1 =  colorbar('Position', [ax1.Position(1)-ax1.Position(3)*0.2, ax1.Position(2), 0.01, ax1.Position(4)],'AxisLocation','out')
       c1.Label.String = 'Correlation';
        c1.Label.Rotation = 0;
       c1.Label.Position = [0.15 1.3];

    
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
    if iDiag == 3

    ax1.YTickLabel(2:end-1)= cellfun(@(i) [],ax1.XTickLabel(2:end-1),'UniformOutput',false);
    set(ax1,'TickLabelInterpreter', 'latex');
    end

    %  max and min corr
    posSite = find(str2double(map.diag)==iDiag+1);

    maxCor = max(corToPlot{1,iDiag});
    [rowMax colMax] = find(round(maxCor,9)==round(corDiag{iDiag},9));
    % listSite = [rowMax colMax];

            minCor = min(corToPlot{1,iDiag});
    [rowMin colMin] = find(round(minCor,9)==round(corDiag{iDiag},9));
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
        ax3 = axes('Position', [ax1.Position(1)+ax1.Position(3)*0.3+lengthMapX*factorMapX*(iSite-1) ax1.Position(2)+ax1.Position(4)*0.65 lengthMapX lengthMapY]);
        maptoplot(mask==1) = map.recon(iMap,:);
        patch(ax3, 'Vertices', vertices, 'Faces', faces, 'FaceVertexCData', maptoplot', ...
            'EdgeColor', 'none', 'FaceColor', 'interp');
        view([-90 0]);

        camlight('headlight')
        material dull
        colormap(ax3,bluewhitered(ax1))
        axis off;
        axis image;
       clim(ax3,[-8 8])
           end

 a15 = annotation(fig, 'textbox', [ax3.Position(1)-ax3.Position(3)*1.1, ax3.Position(2)+ax3.Position(4)*1.1, ax3.Position(3)*2, 0.02], 'string', 'r_{max}', 'edgecolor', 'none', ...
    'color',darkorange,'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'center');
  %   a4 = annotation(fig,'arrow',[ax1.Position(1)+ax1.Position(3)/length(corDiag{iDiag})*(colLeft(1)-0.5) ax3.Position(1)-ax3.Position(3)*0.1],...
  % [ax1.Position(2)+ax1.Position(4)/length(corDiag{iDiag})*(length(corDiag{iDiag})-colLeft(2)+0.5) ax3.Position(2)+ax3.Position(4)*0],'LineWidth',0.8,'HeadLength',5,'HeadWidth',5);

a1 = annotation(fig,'rectangle',[(ax1.Position(1)+ax1.Position(3)/nSite*(colLeft(1)-1)) (ax1.Position(2)+ax1.Position(4)/nSite*(nSite-colLeft(2))) ax1.Position(3)/nSite ax1.Position(4)/nSite],'EdgeColor',darkorange,'LineWidth',1);
% a2 = annotation(fig,'rectangle',[(ax3.Position(1)-ax3.Position(3)*1.05) (ax3.Position(2)-ax3.Position(4)*0.1) ax3.Position(3)*2.1 ax3.Position(4)*1.1],'EdgeColor',darkblue,'LineWidth',1);
if iDiag == 1
    c2 = colorbar('Position', [initX*1.6, initY, 0.01, lengthY],'AxisLocation','in','Ticks',[-8 8],'TickLabels',{'increased \newline in patients' 'reduced \newline in patients'})
c2.Label.String = 'map';
 c2.Label.Rotation = 0;
       c2.Label.Position = [0.15 12.5];
       c2.Label.FontSize = fontsize_legend;
        % c2.TickLabels.FontSize = fontsize_legend;
end
    % plot maps on the right

    for iSite = 1:length(colRight)
        iMap = posSite(colRight(iSite));
        ax5 = axes('Position', [ax1.Position(1)+ax1.Position(3)*0.35+lengthMapX*factorMapX*(iSite+1) ax1.Position(2)+ax1.Position(4)*0.35 lengthMapX lengthMapY]);
        maptoplot(mask==1) = map.recon(iMap,:);
        patch(ax5, 'Vertices', vertices, 'Faces', faces, 'FaceVertexCData', maptoplot', ...
            'EdgeColor', 'none', 'FaceColor', 'interp');

        view([-90 0]);

        camlight('headlight')
        material dull
        colormap(ax5,bluewhitered(ax1))
        axis off;
        axis image;
        clim(ax5,[-8 8])
       
    end
 a15 = annotation(fig, 'textbox', [ax5.Position(1)-ax5.Position(3)*1.1, ax5.Position(2)+ax5.Position(4)*1.1, ax5.Position(3)*2, 0.02], 'string', 'r_{min}', 'edgecolor', 'none', ...
    'color',lightorange,'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'center');
  % a6 = annotation(fig,'arrow',[ax1.Position(1)+ax1.Position(3)/length(corDiag{iDiag})*(colRight(1)-0.5) ax5.Position(1)-ax5.Position(3)*0.1],...
  % [ax1.Position(2)+ax1.Position(4)/length(corDiag{iDiag})*(length(corDiag{iDiag})-colRight(2)+0.5) ax5.Position(2)+ax5.Position(4)*0],'LineWidth',0.8,'LineWidth',0.8,'HeadLength',5,'HeadWidth',5);
a1 = annotation(fig,'rectangle',[(ax1.Position(1)+ax1.Position(3)/nSite*(colRight(1)-1)) (ax1.Position(2)+ax1.Position(4)/nSite*(nSite-colRight(2))) ax1.Position(3)/nSite ax1.Position(4)/nSite],'EdgeColor',lightorange,'LineWidth',1);
% a2 = annotation(fig,'rectangle',[(ax5.Position(1)-ax5.Position(3)*1.1) (ax5.Position(2)-ax5.Position(4)*0.1) ax5.Position(3)*2.3 ax5.Position(4)*1.3],'EdgeColor',darkred,'LineWidth',1);

  a15 = annotation(fig, 'textbox', [ax1.Position(1)-ax1.Position(3)*0.1, ax1.Position(2)+ax1.Position(4)*1.2, 0.09, 0.02], 'string', diagnosisStr{iDiag}, 'edgecolor', 'none', ...
    'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'center');
end


C = [darkblue; gray]; %lines;
 ViolinColor = {repmat(C,ceil(size(corToPlot,2)/length(C)),1)};
 
ax2 = axes('Position', [initVioX, initY*0.35 lengthX*numCol*factorX-initVioX lengthY*factorY]);
violinplot_subclass(corToPlot, diagnosisStr,'ViolinColor',ViolinColor,'BoxColor',[0 0 0],'BoxWidth',0.07);
%[1 3 5 2 4 6]
set(ax2,'FontSize',fontsize_legend)
ylabel('correlation','FontSize',font_size)
set(ax2,'box','off')
 tempXlim = xlim;
 tempYlim =ylim;
 dummyplot1 = scatter(ax2,[-1],[-1],'marker','hexagram','MarkerEdgeColor',darkblue,'MarkerFaceColor',C(1,:));
  dummyplot2 = scatter(ax2,[-1],[-1],'marker','hexagram','MarkerEdgeColor',C(2,:),'MarkerFaceColor',C(2,:));

 legend([dummyplot1,dummyplot2],{'Observed','Null'},'Location','best')
 xlim([0 tempXlim(2)])
 ylim(tempYlim)

legend('boxoff')

% mean and range
meanCor =  cellfun(@(x) mean(x), corToPlot);
minCor = cellfun(@(x) min(x), corToPlot);
maxCor = cellfun(@(x) max(x), corToPlot);

  a25 = annotation(fig, 'textbox', [0, 0.98, 0.02, 0.02], 'string', 'a|', 'edgecolor', 'none', ...
    'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'center');

    a26 = annotation(fig, 'textbox', [0.14, 0.27, 0.03, 0.02], 'string', 'b|', 'edgecolor', 'none', ...
    'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'center');

%%
% savefig(fig,['output/figure_corr_zmap_combat',char(num2str(iCOMBAT)),'_maxstat.fig']);
% set(fig, 'PaperPositionMode', 'auto')
% print(fig, '-djpeg', '-r1200', ['output/figure_corr_zmap_combat',char(num2str(iCOMBAT)),'_maxstat.jpg'])
