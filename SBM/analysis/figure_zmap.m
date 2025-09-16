clear all
% close all
addpath('/home/trangc/kg98/trangc/VBM/code/utils')

iCOMBAT = 1;
smoothKernel = 10;


diagnosisString = {'BD', 'SCA',...
    'SCZ', 'ASD', 'MDD','AD' };

nDiag = length(diagnosisString);



colorVec = {[0, 0.4470, 0.7410], [0.8500, 0.3250, 0.0980],	[0.9290, 0.6940, 0.1250],  [0.4940, 0.1840, 0.5560],  [0.4660, 0.6740, 0.1880]};

fig = figure('Position', [200 200 800 1200]);
set(fig,'color','w');
factor_x = 0.8;
factor_y = 0.8;
init_x = 0.01;
init_y = 0.01;
num_row = nDiag*2;
num_col = 4;
length_x = (0.95 - init_x)/(factor_x*(num_col-1) + 1);
length_y = (0.95 - init_y)/(factor_y*(num_row-1) + 1);
lineWidth = 2;

font_name = 'Arial';
font_size = 10;
fontsize_legend = 8;
hemisphere = 'lh';

%load vtk surface
filename_vtk = 'fsaverage_164k_midthickness-lh.vtk';
[vertices,faces] = read_vtk(filename_vtk);
vertices = vertices';
faces = faces';




load(['output/corr_zmap_combat',num2str(iCOMBAT),'_smooth',num2str(smoothKernel),'.mat'], 'map','corDiag', 'corSig')
load(['output/corr_null_zmap_combat',num2str(iCOMBAT),'_smooth',num2str(smoothKernel),'.mat'], 'corDiagNull', 'corSigNull')


for iDiag = 1:nDiag
    posSite = find(str2double(map.diag)==iDiag+1);
    ids{iDiag}=find(triu(ones(size(corDiag{iDiag})),1));
    corToPlot{1,iDiag} = corDiag{iDiag}(ids{iDiag});
    maxCor = max(corToPlot{1,iDiag});
    [rowMax colMax] = find(round(maxCor,9)==round(corDiag{iDiag},9));
    listSite = [rowMax colMax];
    %plot the two sites
    for iSite = 1:length(colMax)
        iMap = posSite(colMax(iSite));
        ax1 = axes('Position', [init_x+factor_x*length_x*(iSite-1) init_y+factor_y*length_y*(num_row-iDiag*2+1) length_x length_y]);
        patch(ax1, 'Vertices', vertices, 'Faces', faces, 'FaceVertexCData', map.zmap(iMap,:)', ...
            'EdgeColor', 'none', 'FaceColor', 'interp');
            view([-90 0]);
    
        camlight('headlight')
        material dull
        colormap(ax1,bluewhitered(ax1))
        axis off;
        axis image;
    end
     a15 = annotation(fig, 'textbox', [0.01, ax1.Position(2), 0.09, 0.02], 'string', char(diagnosisString{iDiag}), 'edgecolor', 'none', ...
    'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'center');

    for iSite = 1:length(colMax)
        iMap = posSite(colMax(iSite));
        ax1 = axes('Position', [init_x+factor_x*length_x*(iSite-1) init_y+factor_y*length_y*(num_row-iDiag*2) length_x length_y]);
        patch(ax1, 'Vertices', vertices, 'Faces', faces, 'FaceVertexCData', map.zmap(iMap,:)', ...
            'EdgeColor', 'none', 'FaceColor', 'interp');
        
            view([90 0]);
  
        camlight('headlight')
        material dull
        colormap(ax1,bluewhitered(ax1))
        axis off;
        axis image;
    end
    for iSite = 1:length(colMax)
        iMap = posSite(colMax(iSite));
        ax1 = axes('Position', [init_x+factor_x*length_x*(iSite+1)  init_y+factor_y*length_y*(num_row-iDiag*2+1) length_x length_y]);
        patch(ax1, 'Vertices', vertices, 'Faces', faces, 'FaceVertexCData', map.sigmap(iMap,:)', ...
            'EdgeColor', 'none', 'FaceColor', 'interp');
       
            view([-90 0]);
        
        camlight('headlight')
        material dull
        colormap(ax1,bluewhitered(ax1))
        axis off;
        axis image;
    end
    for iSite = 1:length(colMax)
        iMap = posSite(colMax(iSite));
        ax1 = axes('Position', [init_x+factor_x*length_x*(iSite+1)  init_y+factor_y*length_y*(num_row-iDiag*2) length_x length_y]);
        patch(ax1, 'Vertices', vertices, 'Faces', faces, 'FaceVertexCData', map.sigmap(iMap,:)', ...
            'EdgeColor', 'none', 'FaceColor', 'interp');
        
            view([90 0]);
  
        camlight('headlight')
        material dull
        colormap(ax1,bluewhitered(ax1))
        axis off;
        axis image;
    end
   
end



%%
% savefig(fig,['output/figure_corr_zmap_noCombat.fig']);
% set(fig, 'PaperPositionMode', 'auto')
% print(fig, '-djpeg', '-r1200', 'output/figure_corr_zmap_noCombat.jpg')
