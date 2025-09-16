clear all
% close all

smoothKernel = 10;
diag = 4;
hemis = 'lh';
dividemode = 'nosplitsite';
dataDir = fullfile('/scratch','kg98','trangc','VBM','data', 'derivatives', 'freesurfer',['s',num2str(smoothKernel),'noCOMBAT'],['diag',num2str(diag)],hemis, ['resample_2sitegroup_',dividemode]);
addpath(genpath('/projects/kg98/trangc/VBM/code'))

sampleSizeList = [20 40 60 80 100 200 300 400 500];
colorVec = {[225 232 255], [205 217 255], [185 202 255], [165 186 255], [145 171 255], [115 148 255], [85 125 255], [55 103 255],[5 65 255],[0 48 200],[0 36 150],[0 24 100] };

nSize = length(sampleSizeList);

%load vtk surface
filename_vtk = 'fsaverage_164k_midthickness-lh.vtk';
[vertices,faces] = read_vtk(filename_vtk);
vertices = vertices';
faces = faces';

subdivideList = dir(dataDir);
subdivideList = subdivideList([subdivideList.isdir]); % Keep only directories
subdivideList = subdivideList(~ismember({subdivideList.name}, {'.', '..'})); % Remove . and ..

for iFolder = 12:12%height(subdivideList)
    %
    divideMat = load(fullfile(dataDir,subdivideList(iFolder).name,'corr_surface.mat'));

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
    %%plot maps


    ax3 = axes('Position', [init_x, init_y+length_y/2 length_x/4 length_y/4]);

    patch(ax3, 'Vertices', vertices, 'Faces', faces, 'FaceVertexCData', divideMat.map.zmap1, ...
        'EdgeColor', 'none', 'FaceColor', 'interp');
    view([-90 0]);

    camlight('headlight')
    material dull
    colormap(ax3,bluewhitered(ax3))
    axis off;
    axis image;
     a1 = annotation(fig, 'textbox', [ax3.Position(1)+ax3.Position(3) ax3.Position(2)+ax3.Position(4) 0.05 0.02], 'string', ...
    'max 2', ...
    'edgecolor', 'none', ...
    'FontName',font_name,'FontSize',font_size, 'horizontalalignment', 'left');

    ax4 = axes('Position', [init_x, init_y+length_y*3/4 length_x/4 length_y/4]);

    patch(ax4, 'Vertices', vertices, 'Faces', faces, 'FaceVertexCData', divideMat.map.zmap2, ...
        'EdgeColor', 'none', 'FaceColor', 'interp');
    view([-90 0]);

    camlight('headlight')
    material dull
    colormap(ax4,bluewhitered(ax4))
    axis off;
    axis image;
 a2 = annotation(fig, 'textbox', [ax4.Position(1)+ax4.Position(3) ax4.Position(2)+ax4.Position(4) 0.07 0.02], 'string', ...
    'max 1', ...
    'edgecolor', 'none', ...
    'FontName',font_name,'FontSize',font_size, 'horizontalalignment', 'left');
%     % read and plot null maps
% nullmap1(:,1) = load_mgh(fullfile(dataDir,subdivideList(iFolder).name,'null',[subdivideList(iFolder).name,'_null1_group1'],...
%     ['lh-Diff-1-', num2str(diag),'-Intercept-thickness'], 'z.mgh'));
% nullmap2(:,1) = load_mgh(fullfile(dataDir,subdivideList(iFolder).name,'null',[subdivideList(iFolder).name,'_null1_group2'],...
%     ['lh-Diff-1-', num2str(diag),'-Intercept-thickness'], 'z.mgh'));
%  corDiagNullMat= corr([nullmap1,nullmap2]);
% 
%         corDiagNull = corDiagNullMat(1,2)
% 
% ax5 = axes('Position', [init_x+length_x/4, init_y+length_y/2 length_x/4 length_y/4]);
% 
%     patch(ax5, 'Vertices', vertices, 'Faces', faces, 'FaceVertexCData', nullmap1, ...
%         'EdgeColor', 'none', 'FaceColor', 'interp');
%     view([-90 0]);
% 
%     camlight('headlight')
%     material dull
%     colormap(ax5,bluewhitered(ax5))
%     axis off;
%     axis image;

    % ax6 = axes('Position', [init_x+length_x/4, init_y+length_y*3/4 length_x/4 length_y/4]);
    % 
    % patch(ax6, 'Vertices', vertices, 'Faces', faces, 'FaceVertexCData', nullmap2, ...
    %     'EdgeColor', 'none', 'FaceColor', 'interp');
    % view([-90 0]);
    % 
    % camlight('headlight')
    % material dull
    % colormap(ax6,bluewhitered(ax6))
    % axis off;
    % axis image;





    % plot distribution

    ax2 = axes('Position', [init_x, init_y length_x length_y]);




    for iSampleSize=1:length(sampleSizeList)
        sampleSize = sampleSizeList(iSampleSize);

        contrastDir = fullfile(dataDir,subdivideList(iFolder).name,['sampleSize_',num2str(sampleSize)]);
        if exist(fullfile(contrastDir,'corr_surface.mat'))
        matFile = load(fullfile(contrastDir,'corr_surface.mat'));

        [fi xi]=ksdensity(matFile.corDiag,'function','pdf');

        denPlot = plot(ax2, xi, fi, 'LineWidth', lineWidth,'Color',colorVec{length(colorVec)-length(sampleSizeList)+iSampleSize}./255);
        end
        hold on


    end
    plot(ax2,divideMat.corDiag*ones(1,10),0:9,'LineWidth',lineWidth,'Color','r')
    set(ax2,'box','off')
    set(ax2, 'color','none')
    xlim([-0.4 1]);
    ylim([0 25]);
    plotLegend = legend([arrayfun(@num2str,sampleSizeList,'UniformOutput',0),'max'],'Location','southwest')

    xlabel('correlation')
    ylabel({'density'})
    legend('boxoff')

end
% a1 = annotation(fig, 'textbox', [0, 0.02, 1, 0.02], 'string', ...
%     ['Figure 1: For each disorder, the upper panel shows the between-site correlation ' ...
%     'matrix of the t-maps and the lower panel shows the kernel density estimation of all elements of the between-site correlation matrix.'], ...
%     'edgecolor', 'none', ...
%     'FontName',font_name,'FontSize',font_size, 'horizontalalignment', 'left');


%%
% savefig(fig,['output/figure_corr_tmap_noCombat.fig']);
% set(fig, 'PaperPositionMode', 'auto')
% print(fig, '-djpeg', '-r1200', 'output/figure_corr_tmap_noCombat.jpg')