% plot pipeline
close all
clear all

% Setup working directory and add utility path
wdir = pwd();
addpath(fullfile(wdir(1:strfind(wdir,'analysis')-2),'utils'));

% Define font styles and sizes
font_name = 'Arial';
font_size = 10;
fontsize_legend = 8;
fontsize_tick = 7;

% Define hemisphere to process
hemisphere = 'lh';

% %% load data to plot
% subList = readtable('/projects/kg98/trangc/VBM/data/HCP/qdec_table_HCP_4.dat');
% for imap = 1:18
% thick(imap,:) = load_mgh(['/projects/kg98/trangc/VBM/data/HCP/derivatives/freesurfer/',subList.fsid{imap},'/surf/lh.thickness.fwhm10.fsaverage.combat.mgh']);
% end
% zmap(1,:) = load_mgh('/projects/kg98/trangc/VBM/data/HCP/derivatives/freesurfer/qdec/4_HCP_thick_smooth10_lh_sex_age_combat/lh-Diff-1-4-Intercept-thickness/z.mgh');
% zmap(2,:) = load_mgh('/projects/kg98/trangc/VBM/data/COBRE/derivatives/freesurfer/qdec/4_COBRE_thick_smooth10_lh_sex_age_combat/lh-Diff-1-4-Intercept-thickness/z.mgh');
% zmap(3,:) = load_mgh('/projects/kg98/trangc/VBM/data/BSNIP/derivatives/freesurfer/qdec/4_Boston_thick_smooth10_lh_sex_age_combat/lh-Diff-1-4-Intercept-thickness/z.mgh');

%%
load('Figure_1_pipeline.mat');

% load vtk surface
filename_vtk = '/home/trangc/kg98/trangc/VBM/code/utils/fsaverage_164k_midthickness-lh.vtk';
[vertices,faces] = read_vtk(filename_vtk);
vertices = vertices';
faces = faces';

% define figure model
fig = figure('Position', [200 200 900 250]);
set(fig,'color','w');

% define axis para for SBM
factor_x = 1.05;
factor_y = 0.12;
init_x = 0.03;
init_y = 0.02;
init_yTmap = 0.05;
init_yNullmap = -0.13;
num_row = 3;    %No of subjects
num_col = 8;    %No of groups
numSite = 3; %Number of sites
length_x = (0.9)/((num_col-1)+1);
length_y = (0.41)/(factor_y*(num_row-1)+1)/2;

length_xmap = length_x*1.4;
length_ymap = length_y*1.4;


group = {'Controls' 'Cases'};
%% Loop to plot surface maps for each group and subject
for i = 1:num_col-2 %No of group

    for ii = 1:num_row %No of subjects

        ax1 = axes('Position', [init_x*2.3+factor_x*length_x*(i-mod(i+1,2)*0.2-1+ii*0.1) init_y+factor_y*length_y*(num_row-ii+1)+0.5 length_x length_y]);
        patch(ax1, 'Vertices', vertices, 'Faces', faces, 'FaceVertexCData', thick((i-1)*3+ii,:)', ...
            'EdgeColor', 'none', 'FaceColor', 'interp');
        if strcmpi(hemisphere, 'lh')
            view([-90 0]);
        elseif strcmpi(hemisphere, 'rh')
            view([90 0]);
        end
        camlight('headlight')
        material dull
        colormap(ax1,parula)
        caxis(ax1,[0,4])
        axis off;
        axis image;

    end
    if i==6
        % colorbar for thickness map
        c2 = colorbar('Position', [init_x ax1.Position(2)+ax1.Position(4)*0.25 length_xmap*0.06 length_ymap*0.7],'AxisLocation','in','Ticks',[0 4])
        c2.Label.String = 'individual \newline map';
        c2.Label.Rotation = 0;
        c2.Label.Position = [1.4 7.5];
        c2.Label.FontSize = fontsize_legend;


    end
    a1 = annotation(fig, 'textbox', [ax1.Position(1) + ax1.Position(3)*0, ax1.Position(2)+ax1.Position(4)*1.6, 0.1, 0.02], 'string', [char(group(mod(i+1,2)+1))], 'edgecolor', 'none', ...
        'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'center');

    if mod(i,2)==1
        a2 = annotation(fig, 'textbox', [ax1.Position(1)+ ax1.Position(3)*0.4, ax1.Position(2)+ax1.Position(4)*2, 0.1, 0.02], 'string', ['Site ',num2str(ceil(i/2))], 'edgecolor', 'none', ...
            'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'center');

        % plot statistical map
        ax7 = axes('Position', [ax1.Position(1)+ ax1.Position(3)*0.3 ax1.Position(2)-ax1.Position(4)*2 length_xmap length_ymap]);

        patch(ax7, 'Vertices', vertices, 'Faces', faces, 'FaceVertexCData', zmap(round(i/2),:)', ...
            'EdgeColor', 'none', 'FaceColor', 'interp');
        if strcmpi(hemisphere, 'lh')
            view([-90 0]);
        elseif strcmpi(hemisphere, 'rh')
            view([90 0]);
        end
        camlight('headlight')
        material dull
        colormap(ax7,bluewhitered(ax7));
        axis off;
        axis image;

        a6 = annotation(fig,'arrow',[ax1.Position(1)+ax1.Position(3)*0.7 ax7.Position(1)+ax7.Position(3)*0.5],...
            [ax1.Position(2)-ax1.Position(4)*0.05 ax7.Position(2)+ax7.Position(4)*1.1],'HeadLength',7,'HeadWidth',7);

    else
        a6 = annotation(fig,'arrow',[ax1.Position(1)+ax1.Position(3)*0.6 ax7.Position(1)+ax7.Position(3)*0.6],...
            [ax1.Position(2)-ax1.Position(4)*0.05 ax7.Position(2)+ax7.Position(4)*1.1],'HeadLength',7,'HeadWidth',7);
    end
    if i==5
        % colorbar for stat map
        c2 = colorbar('Position', [init_x ax7.Position(2)-ax7.Position(4)*0.25 length_xmap*0.06 length_ymap*0.7],'AxisLocation','in','Ticks',[-3 3],'TickLabels',{'increased \newline in cases' 'reduced \newline in cases'})
        c2.Label.String = 'statistical \newline map';
        c2.Label.Rotation = 0;
        c2.Label.Position = [1.4 9.5];
       
        c2.FontSize = fontsize_tick;
         c2.Label.FontSize = fontsize_legend;


    end
    if i==1
        a5 = annotation(fig, 'textbox', [ax7.Position(1)- ax7.Position(3)*0.3, ax7.Position(2)+ax7.Position(4)*1.1, 0.1, 0.02], 'string', 'Statistical map', 'edgecolor', 'none', ...
            'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'center');

    end
    if i==1|i==3
        % plotting arrows
        ax2 = axes('Position', [ax7.Position(1)+ ax7.Position(3)*0.7 ax7.Position(2)-ax7.Position(4)*0.2 length_xmap*1.1 length_ymap*2]);
        xdummy = [-1:0.001:1];
        radDummy = 5;
        ydummy = -sqrt(radDummy^2-xdummy.^2);
        ap = plot(ax2,xdummy,ydummy,'color','k');
        ax2.YLim = [-5 -3];
        axis off
        a6 = annotation('arrow','HeadLength',8,'HeadWidth',8);
        a6.Parent=ax2;
        a6.X=[xdummy(end) xdummy(end)]
        a6.Y=[ydummy(end) ydummy(end)];
        a7 = annotation('arrow','HeadLength',8,'HeadWidth',8);
        a7.Parent=ax2;
        a7.X=[xdummy(2) xdummy(1)]
        a7.Y=[ydummy(1) ydummy(1)];
        if i==1
            a10 = annotation(fig, 'textbox', [ax2.Position(1)+ax2.Position(3)*0.4 , ax2.Position(2)+ax2.Position(4)*0.15,  ax2.Position(3)*0.2, 0.02], 'string', '$r_{1,2}$', 'edgecolor', 'none', ...
                'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'center','Interpreter','latex');
        else
            a10 = annotation(fig, 'textbox', [ax2.Position(1)+ax2.Position(3)*0.4 , ax2.Position(2)+ax2.Position(4)*0.15,  ax2.Position(3)*0.2, 0.02], 'string', '$r_{2,3}$', 'edgecolor', 'none', ...
                'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'center','Interpreter','latex');
        end

    end


end


% Plotting arrows
ax3 = axes('Position', [ax2.Position(1)-ax2.Position(3)*1.4 ax2.Position(2)-ax2.Position(4)*0.1 length_xmap*2.7 length_ymap*2]);
xdummy = [-1:0.001:1];
radDummy = 5;
ydummy = -sqrt(radDummy^2-xdummy.^2);
plot(ax3,xdummy,ydummy,'color','k');
ax3.YLim = [-5 -4];
axis off

a8 = annotation('arrow','HeadLength',8,'HeadWidth',8);
a8.Parent=ax3;
a8.X=[xdummy(end) xdummy(end)];
a8.Y=[ydummy(end) ydummy(end)];
a9 = annotation('arrow','HeadLength',8,'HeadWidth',8);
a9.Parent=ax3;
a9.X=[xdummy(2) xdummy(1)];
a9.Y=[ydummy(1) ydummy(1)];
a10 = annotation(fig, 'textbox', [ax3.Position(1)+ax3.Position(3)*0.4 , ax3.Position(2)+ax3.Position(4)*0.15,  ax3.Position(3)*0.2, 0.02], 'string', '$r_{1,3}$', 'edgecolor', 'none', ...
    'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'center','Interpreter','latex');

%% Plotting correlation matrix table
ax4 = axes('Position', [ax7.Position(1)+ax7.Position(3)*1.2 ax7.Position(2)-ax7.Position(4)*0.1 length_xmap*1.1 length_ymap*1.9]);
nSite = 3;
corDiag = corr(zmap');
hm = imagesc(ax4,1:nSite, 1:nSite, corDiag);

clim([-1 1]);
colormap(ax4, greenwhiteviolet(ax4));



% Colorbar setup for correlation matrix
c1 =  colorbar('south','Position', [ax4.Position(1)+ax4.Position(3)*0.1 ax4.Position(2)+ax4.Position(4)*1.1 ax4.Position(3)*0.8 ax4.Position(4)*0.05],'AxisLocation','out')
c1.Label.String = 'cross-site correlation';
c1.Label.Rotation = 0;
c1.Label.Position = [0.1 5];
c1.Label.FontSize = fontsize_legend;
xlabel('Site','FontSize',fontsize_legend)
ylabel('Site','FontSize',fontsize_legend)

a10 = annotation(fig, 'textbox', [ax4.Position(1)+ax4.Position(3)*0.08 , ax4.Position(2)+ax4.Position(4)*0.25,  ax4.Position(3)/3, 0.02], 'string', '$r_{1,3}$', 'edgecolor', 'none', ...
    'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'left','Interpreter','latex');
a10 = annotation(fig, 'textbox', [ax4.Position(1)+ax4.Position(3)*0.08 , ax4.Position(2)+ax4.Position(4)*0.55,  ax4.Position(3)/3, 0.02], 'string', '$r_{1,2}$', 'edgecolor', 'none', ...
    'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'left','Interpreter','latex');
a10 = annotation(fig, 'textbox', [ax4.Position(1)+ax4.Position(3)*0.42 , ax4.Position(2)+ax4.Position(4)*0.25,  ax4.Position(3)/3, 0.02], 'string', '$r_{2,3}$', 'edgecolor', 'none', ...
    'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'left','Interpreter','latex');

a11 = annotation(fig, 'textbox', [0.001 0.97 0.1 0.02], 'string', 'a|', 'edgecolor', 'none', ...
    'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'left');
a11 = annotation(fig, 'textbox', [0.001 0.53 0.1 0.02], 'string', 'b|', 'edgecolor', 'none', ...
    'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'left');
a11 = annotation(fig, 'textbox', [ax4.Position(1)-0.04 0.97 0.1 0.02], 'string', 'c|', 'edgecolor', 'none', ...
    'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'left');


%% Save figure
savefig(fig,['output/figure1_pipeline.fig']);
set(fig, 'PaperPositionMode', 'auto')
print(fig, '-djpeg', '-r1200', 'output/figure1_pipeline.jpg')
