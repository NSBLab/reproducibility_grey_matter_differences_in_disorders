clear all
% close all
addpath('/home/trangc/kg98/trangc/library/raincloudplot/daviolinplot')
addpath('/home/trangc/kg98/trangc/VBM/code/analysis')
iCOMBAT = 1;
smoothKernel = 10;


diagnosisString = {'BD', 'SCA',...
    'SCZ', 'ASD', 'MDD','AD' };

nDiag = length(diagnosisString);



colorVec = {[0, 0.4470, 0.7410], [0.8500, 0.3250, 0.0980],	[0.9290, 0.6940, 0.1250],  [0.4940, 0.1840, 0.5560],  [0.4660, 0.6740, 0.1880]};

fig = figure('Position', [200 200 1200 400]);
set(fig,'color','w');
factor_x = 1.2;
factor_y = 1.9;
init_x = 0.1;
init_y = 0.07;
num_row = nDiag;
num_col = 3;
length_x = (0.85 - init_x)/(factor_x*(num_col-1) + 1);
length_y = (0.93 - init_y)/(factor_y*(num_row-1) + 1);

factorMap_x = 1;
factorMap_y = 1;
initMap_x = init_x+length_x*2*factor_x+0.05;
initMap_y = 0.01;
numRowMap = nDiag*2;
numColMap = 4;
lengthMap_x = (0.95 - initMap_x)/(factorMap_x*(numColMap-1) + 1);
lengthMap_y = (0.99 - initMap_y)/(factorMap_y*(numRowMap-1) + 1);
lineWidth = 2;

font_name = 'Arial';
font_size = 10;
fontsize_legend = 8;

%load vtk surface
filename_vtk = 'fsaverage_164k_midthickness-lh.vtk';
[vertices,faces] = read_vtk(filename_vtk);
vertices = vertices';
faces = faces';

load(['corr_ENIGMA.mat'], 'map','corENIGMA','siteList')
corDiag = corENIGMA;

load(['output/corr_null_zmap_combat',num2str(iCOMBAT),'_smooth',num2str(smoothKernel),'.mat'], 'corDiagNull', 'corSigNull')
% [v, L, ct] = read_annotation('/home/trangc/kg98/trangc/VBM/data/miriad/derivatives/freesurfer/sub-188/label/lh.aparc.annot');
in = [2 4 5 6];
for iDiag = 1:4
    ax1 = axes('Position', [init_x+factor_x*length_x, init_y+factor_y*length_y*(nDiag-iDiag) length_x length_y]);
  
    corToPlot{iDiag} = corDiag{in(iDiag)};
    % corToPlot{2,iDiag} = corDiagNull{iDiag};

    % plot table
    nSite = length(siteList{in(iDiag)});
    hm = imagesc(ax1,1:nSite, 1:nSite, triu(corDiag{in(iDiag)},1));

    clim([-0.2 1]);
    colormap(ax1, bluewhitered(ax1));
    if iDiag == 1
        colorbar('Position', [ax1.Position(1)-ax1.Position(3)*0.1, ax1.Position(2), 0.01, ax1.Position(4)])
    end

    xticks(ax1,[1:nSite])
    xticklabels(ax1,siteList{in(iDiag)});
    yticks(ax1,[1:nSite])
    yticklabels(ax1,siteList{in(iDiag)})
    set(ax1,'box','off','TickLabelInterpreter', 'none','xaxisLocation','top','yaxisLocation','right')
    grid off
    xlim([0.5,nSite+0.5])
    ylim([0.5,nSite+0.5])
    % if iDiag == 3

    ax1.YTickLabel(2:end-1)= cellfun(@(i) [],ax1.XTickLabel(2:end-1),'UniformOutput',false);
    % set(ax1,'TickLabelInterpreter', 'latex');
    % end
    % plot two sites that have max corr
    posSite = find(str2double(map.diag)==in(iDiag)+1);

    maxCor = max(corToPlot{1,iDiag});
    [rowMax colMax] = find(round(maxCor,9)==round(corDiag{in(iDiag)},9));
    listSite = [rowMax colMax];
    for iSite = 1:length(colMax)
        iMap = posSite(colMax(iSite));
        ax3 = axes('Position', [initMap_x+factorMap_x*lengthMap_x*(iSite-1) initMap_y+factorMap_y*lengthMap_y*(numRowMap-iDiag*2+1) lengthMap_x lengthMap_y]);
        patch(ax3, 'Vertices', vertices, 'Faces', faces, 'FaceVertexCData', map.zmap(iMap,:)', ...
            'EdgeColor', 'none', 'FaceColor', 'interp');
        view([-90 0]);

        camlight('headlight')
        material dull
        colormap(ax3,bluewhitered(ax3))
        axis off;
        axis image;
    end
   
    for iSite = 1:length(colMax)
        iMap = posSite(colMax(iSite));
        ax4 = axes('Position', [initMap_x+factorMap_x*lengthMap_x*(iSite-1) initMap_y+factorMap_y*lengthMap_y*(numRowMap-iDiag*2) lengthMap_x lengthMap_y]);
        patch(ax4, 'Vertices', vertices, 'Faces', faces, 'FaceVertexCData', map.zmap(iMap,:)', ...
            'EdgeColor', 'none', 'FaceColor', 'interp');

        view([90 0]);

        camlight('headlight')
        material dull
        colormap(ax4,bluewhitered(ax4))
        axis off;
        axis image;
    end
    % plot maps with min corr
        minCor = min(corToPlot{1,iDiag});
    [rowMin colMin] = find(round(minCor,9)==round(corDiag{in(iDiag)},9));
    listSite = [rowMin colMin];
    for iSite = 1:length(colMin)
        iMap = posSite(colMin(iSite));
        ax5 = axes('Position', [initMap_x+factorMap_x*lengthMap_x*(iSite+1)  initMap_y+factorMap_y*lengthMap_y*(numRowMap-iDiag*2+1) lengthMap_x lengthMap_y]);
        patch(ax5, 'Vertices', vertices, 'Faces', faces, 'FaceVertexCData', map.zmap(iMap,:)', ...
            'EdgeColor', 'none', 'FaceColor', 'interp');

        view([-90 0]);

        camlight('headlight')
        material dull
        colormap(ax5,bluewhitered(ax5))
        axis off;
        axis image;
    end
    for iSite = 1:length(colMin)
        iMap = posSite(colMin(iSite));
        ax6 = axes('Position', [initMap_x+factorMap_x*lengthMap_x*(iSite+1)  initMap_y+factorMap_y*lengthMap_y*(numRowMap-iDiag*2) lengthMap_x lengthMap_y]);
        patch(ax6, 'Vertices', vertices, 'Faces', faces, 'FaceVertexCData', map.zmap(iMap,:)', ...
            'EdgeColor', 'none', 'FaceColor', 'interp');

        view([90 0]);

        camlight('headlight')
        material dull
        colormap(ax6,bluewhitered(ax6))
        axis off;
        axis image;
    end


end
c=repmat([1 0 0],6,1);
ax2 = axes('Position', [init_x, init_y length_x length_y*(num_row-1)*factor_y+length_y]);
daviolinplot((fliplr(corToPlot)),'box',3,'outliers', 0,'boxwidth',0.8,...
    'boxcolor','w','scatter',2,'jitter',1,'scattercolor','same',...
    'scattersize',20,'scatteralpha',0.7,'linkline',0,...
    'xtlabels', flip(diagnosisString(in-1)),'colors',c,'legend','observed');
% daviolinplot_modified(flipdim(flipdim(corToPlot,2),1),'box',3,'outliers', 0,'boxwidth',0.8,...
%     'boxcolor','w','scatter',2,'jitter',1,'scattercolor','same',...
%     'scattersize',20,'scatteralpha',0.7,'linkline',0,...
%     'xtlabels', flip(diagnosisString),'legend',{'null','observe'});


ylabel('correlation')
set(ax2,'box','off')
set(ax2, 'color','white')
camroll(ax2,90)
set ( ax2, 'ydir', 'reverse' )
set(ax2,'XAxisLocation','top')
ax2.XAxis.Color = 'white'
ax2.XTickLabel= cellfun(@(i) ['\color{black}' char(i)],ax2.XTickLabel,'UniformOutput',false);
legend('boxoff','Location','best')

a15 = annotation(fig, 'textbox', [0.01, 0.98, 0.09, 0.02], 'string', 'a|', 'edgecolor', 'none', ...
    'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'center');
a16 = annotation(fig, 'textbox', [0.28, 0.98, 0.09, 0.02], 'string', 'b|', 'edgecolor', 'none', ...
    'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'center');

a17 = annotation(fig, 'textbox', [0.61, 0.98, 0.09, 0.02], 'string', 'c|', 'edgecolor', 'none', ...
    'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'center');


%%
% savefig(fig,['output/figure_corr_zmap_noCombat.fig']);
% set(fig, 'PaperPositionMode', 'auto')
% print(fig, '-djpeg', '-r1200', 'output/figure_corr_zmap_noCombat.jpg')
