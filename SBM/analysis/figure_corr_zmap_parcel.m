clear all
close all
addpath('/home/trangc/kg98/trangc/library/Violinplot-Matlab-master')
addpath(genpath('/projects/kg98/trangc/VBM/code'))
iCOMBAT = 1;
smoothKernel = 10;


diagnosisString = {'BD', 'SCA',...
    'SCZ', 'ASD', 'MDD','AD' };

nDiag = length(diagnosisString);



darkblue = [10/255 52/255 204/255];
gray = [0.5 0.5 0.5];

fig = figure('Position', [200 200 1200 800]);
set(fig,'color','w');
factorX = 1.1;
factorY = 1.7;
initX = 0.15;
initY = 0.08;
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
lengthMapX = lengthX*0.19;
lengthMapY = lengthY*0.58;
lineWidth = 2;

font_name = 'Arial';
font_size = 10;
fontsize_legend = 8;

%load vtk surface
filename_vtk = 'fsaverage_164k_midthickness-lh.vtk';
[vertices,faces] = read_vtk(filename_vtk);
vertices = vertices';
faces = faces';

load(['output/corr_surface_aparc.mat'], 'map','corDiag', 'corSig','siteList')
load(['output/corr_aparc_null.mat'], 'corDiagNull', 'corSigNull')

%read anno
[tempVertices,tempLabel,colortable]=read_annotation('/home/trangc/kg98/trangc/VBM/data/Atypical/derivatives/freesurfer/fsaverage/label/lh.aparc.annot');
map2colortable = [2:4 6:36];
colorcode = colortable.table(map2colortable,5);
[lia locb] = ismember(tempLabel, colorcode);

for iDiag = 1:nDiag

    iCol = mod(iDiag+1,2);
    iRow = floor((iDiag+1)/2);
    ax1 = axes('Position', [initX+factorX*lengthX*(iCol), initY+factorY*lengthY*(numRow-iRow) lengthX lengthY]);
    ids{iDiag}=find(tril(ones(size(corDiag{iDiag})),-1));
    corToPlot{1,iDiag} = corDiag{iDiag}(ids{iDiag});
    corToPlot{2,iDiag} = corDiagNull{iDiag};


    % plot table
    nSite = length(siteList{iDiag});
    hm = imagesc(ax1,1:nSite, 1:nSite, tril(corDiag{iDiag},-1));

    clim([-1 1]);
    colormap(ax1, bluewhitered(ax1));
    if iDiag == 1
        c1 =  colorbar('Position', [ax1.Position(1)-ax1.Position(3)*0.2, ax1.Position(2), 0.01, ax1.Position(4)],'AxisLocation','out')
        c1.Label.String = 'Correlation/z-map';
        c1.Label.Rotation = 0;
        c1.Label.Position = [0.15 1.3];

        c2 = colorbar('Position', [ax1.Position(1)-ax1.Position(3)*0.2, ax1.Position(2), 0.01, ax1.Position(4)],'AxisLocation','in','Ticks',[-1 1],'TickLabels',{'increase \newline in patients' 'reduce \newline in patients'})

    end

    xticks(ax1,[1:nSite])
    xticklabels(ax1,arrayfun(@(x) num2str(x),[1:nSite],'UniformOutput',false));
    xticklabels(ax1,arrayfun(@(x) num2str(x),[1:nSite],'UniformOutput',false));
    yticks(ax1,[1:nSite])
    yticklabels(ax1,arrayfun(@(x) num2str(x),[1:nSite],'UniformOutput',false))
    set(ax1,'box','off','TickLabelInterpreter', 'none','xaxisLocation','bottom','yaxisLocation','left')
    grid off
    xlim([0.5,nSite+0.5])
    ylim([0.5,nSite+0.5])
    xlabel('site')
    ylabel('site')
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

    if colMax(1) <= colMin(1)
        colLeft = colMax;
        colRight = colMin;
    else
        colLeft = colMin;
        colRight = colMax;
    end

    % plot two sites on the left
    for iSite = 1:length(colLeft)
        iMap = posSite(colLeft(iSite));
        ax3 = axes('Position', [ax1.Position(1)+ax1.Position(3)*0.195+lengthMapX*factorMapX*(iSite-1) ax1.Position(2)+ax1.Position(4)*0.71 lengthMapX lengthMapY]);
        parMap = [0 map.zmap(iMap,1:34)];
        maptoplot = cell2mat(arrayfun(@(x) parMap(x+1),locb,'UniformOutput',false));
        patch(ax3, 'Vertices', vertices, 'Faces', faces, 'FaceVertexCData', maptoplot, ...
            'EdgeColor', 'none', 'FaceColor', 'interp');
        view([-90 0]);

        camlight('headlight')
        material dull
        colormap(ax3,bluewhitered(ax1))
        axis off;
        axis image;
        clim(ax3,[-8 8])
    end

    a4 = annotation(fig,'arrow',[ax1.Position(1)+ax1.Position(3)/length(corDiag{iDiag})*(colLeft(1)-0.5) ax3.Position(1)-ax3.Position(3)*0.1],...
        [ax1.Position(2)+ax1.Position(4)/length(corDiag{iDiag})*(length(corDiag{iDiag})-colLeft(2)+0.5) ax3.Position(2)+ax3.Position(4)*0],'LineWidth',0.8);


    % plot maps on the right

    for iSite = 1:length(colRight)
        iMap = posSite(colRight(iSite));
        ax5 = axes('Position', [ax1.Position(1)+ax1.Position(3)*0.22+lengthMapX*factorMapX*(iSite+1) ax1.Position(2)+ax1.Position(4)*0.35 lengthMapX lengthMapY]);
        parMap = [0 map.zmap(iMap,1:34)];
        maptoplot = cell2mat(arrayfun(@(x) parMap(x+1),locb,'UniformOutput',false));
        patch(ax5, 'Vertices', vertices, 'Faces', faces, 'FaceVertexCData', maptoplot, ...
            'EdgeColor', 'none', 'FaceColor', 'interp');

        view([-90 0]);

        camlight('headlight')
        material dull
        colormap(ax5,bluewhitered(ax1))
        axis off;
        axis image;
        clim(ax5,[-8 8])

    end

    a6 = annotation(fig,'arrow',[ax1.Position(1)+ax1.Position(3)/length(corDiag{iDiag})*(colRight(1)-0.5) ax5.Position(1)-ax5.Position(3)*0.1],...
        [ax1.Position(2)+ax1.Position(4)/length(corDiag{iDiag})*(length(corDiag{iDiag})-colRight(2)+0.5) ax5.Position(2)+ax5.Position(4)*0],'LineWidth',0.8);

    a15 = annotation(fig, 'textbox', [ax1.Position(1)-ax1.Position(3)*0.15, ax1.Position(2)+ax1.Position(4)*1.1, 0.09, 0.02], 'string', diagnosisString{iDiag}, 'edgecolor', 'none', ...
        'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'center');
end


C = [darkblue; gray]; %lines;
ViolinColor = {repmat(C,ceil(size(corToPlot,2)/length(C)),1)};

ax2 = axes('Position', [initX, initY*0.35 lengthX*numCol*factorX lengthY*factorY]);
violinplot_subclass(corToPlot, diagnosisString,'ViolinColor',ViolinColor,'BoxColor',[0 0 0],'BoxWidth',0.07);

ylabel('correlation')
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

%%
savefig(fig,['output/figure_corr_zmap_parcel.fig']);
set(fig, 'PaperPositionMode', 'auto')
print(fig, '-djpeg', '-r1200', 'output/figure_corr_zmap_parcel.jpg')
