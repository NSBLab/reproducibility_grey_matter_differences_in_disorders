% plot confound
clear all
close all

load('output/confound_combine.mat', 'ptoplot','contoplot','nSiteToPlot');
contoplot = contoplot';
ptoplot = ptoplot';
nSiteToPlot=nSiteToPlot';
nSiteRange = [min(nSiteToPlot(nSiteToPlot>0),[],'all'):max(nSiteToPlot,[],'all')];
cMap = colormap(sky(length(nSiteRange)));
% darkblue = [0 32/255 96/255];%[0 0 204/255];
% lightblue = [157/255 195/255 230/255];%[189/255 215/255 238/255];%[0 153/255 255/255];
darkred = [150/255 0 0];
lightred = [255/255 147/255 147/255];

% h = correlationCircles(confound);
fig = figure('Position', [200 200 500 1200]);
set(fig,'color','w');
factor_x = 1.1;
factor_y = 1.5;
init_x = 0.3;
init_y = 0.1;
[num_row, num_col] = size(contoplot);
length_x = (0.92 - init_x)/(factor_x*(num_col-1) + 1);
length_y = (0.9 - init_y)/(factor_y*(num_row-1) + 1);

font_name = 'Arial';
font_size = 10;
fontsize_legend = 8;

for iRow = 1:num_row
    for iCol = 1:num_col
        ax1 = axes('Position', [init_x + length_x*factor_x*(iCol -1), init_y+length_y*factor_y*(num_row-iRow) length_x length_x]);
        axis equal
        color = cMap(nSiteToPlot(iRow,iCol)==nSiteRange,:) ;
        if  abs(contoplot(iRow,iCol))>0
            h1 = drawcircle('center', [0.5, 0.5],'Color',color,'radius', abs(contoplot(iRow,iCol)),'FaceAlpha',1,'EdgeAlpha',0);
            if ptoplot(iRow,iCol)<= 0.05
                h2 = drawcircle('Color','r','center',[0.5, 0.5],'radius', abs(contoplot(iRow, iCol)),'FaceAlpha',0,'LineWidth',3);
             end
            % if contoplot(iRow,iCol)>0
            %     h3=annotation(fig, 'rectangle', [ax1.Position(1)+ax1.Position(3)/2-abs(contoplot(iRow, iCol))*ax1.Position(3), ax1.Position(2)+ax1.Position(4)/2-abs(contoplot(iRow, iCol)), abs(contoplot(iRow, iCol))*ax1.Position(3), abs(contoplot(iRow, iCol))*2*ax1.Position(4)],'FaceColor','white','Color','black');
            % else
            %     h3=annotation(fig, 'rectangle', [ax1.Position(1)+ax1.Position(3)/2, ax1.Position(2)+ax1.Position(4)/2-abs(contoplot(iRow, iCol))*ax1.Position(4), abs(contoplot(iRow, iCol))*ax1.Position(3), abs(contoplot(iRow, iCol))*2*ax1.Position(4)],'FaceColor','white','Color','black');
            % end
        end
        axis off
    end


end

ax1 = axes('Position', [init_x + length_x*factor_x*(-2.5), init_y+length_y*factor_y*(num_row-iRow-1) length_x length_x]);
h1 = drawcircle('center', [0.5, 0.5],'Color','black','radius', 1,'FaceAlpha',1,'EdgeAlpha',0);
h3=annotation(fig, 'rectangle', [ax1.Position(1), ax1.Position(2), ax1.Position(3)/2, ax1.Position(4)],'FaceColor','white','Color','white');
        
a32 = annotation(fig, 'textbox', [ax1.Position(1)+length_x*1.2, ax1.Position(2)+length_y*0.5, 0.3, 0.01], 'string', 'r=1', 'edgecolor', 'none', ...
    'FontName',font_name,'FontSize',font_size, 'horizontalalignment', 'left');

axis equal
axis off

ax1 = axes('Position', [init_x + length_x*factor_x*(1), init_y+length_y*factor_y*(num_row-iRow-1) length_x length_x]);
h1 = drawcircle('center', [0.5, 0.5],'Color',lightblue,'radius', 1/2,'FaceAlpha',1,'EdgeAlpha',0);
a32 = annotation(fig, 'textbox', [ax1.Position(1)+length_x*1.2, ax1.Position(2)+length_y*0.5, 0.3, 0.01], 'string', 'r=-1', 'edgecolor', 'none', ...
    'FontName',font_name,'FontSize',font_size, 'horizontalalignment', 'left');

axis equal
axis off


ax1 = axes('Position', [init_x + length_x*factor_x*(4), init_y+length_y*factor_y*(num_row-iRow-1) length_x length_x]);
h2 = drawcircle('Color','r','center',[0.5, 0.5],'radius', 1/2,'FaceAlpha',0,'LineWidth',3);
a32 = annotation(fig, 'textbox', [ax1.Position(1)+length_x*1.2, ax1.Position(2)+length_y*0.5, 0.3, 0.01], 'string', 'p<=0.05', 'edgecolor', 'none', ...
    'FontName',font_name,'FontSize',font_size, 'horizontalalignment', 'left');

axis equal
axis off

a32 = annotation(fig, 'textbox', [init_x + length_x*factor_x*(0), init_y+length_y*factor_y*(num_row) length_x length_y*0.1], 'string', 'ASD', 'edgecolor', 'none', ...
    'FontName',font_name,'FontSize',font_size, 'horizontalalignment', 'left');
a32 = annotation(fig, 'textbox', [init_x + length_x*factor_x*(1), init_y+length_y*factor_y*(num_row) length_x length_y*0.1], 'string', 'BD', 'edgecolor', 'none', ...
    'FontName',font_name,'FontSize',font_size, 'horizontalalignment', 'left');
a32 = annotation(fig, 'textbox', [init_x + length_x*factor_x*(2), init_y+length_y*factor_y*(num_row) length_x length_y*0.1], 'string', 'MDD', 'edgecolor', 'none', ...
    'FontName',font_name,'FontSize',font_size, 'horizontalalignment', 'left');
a32 = annotation(fig, 'textbox', [init_x + length_x*factor_x*(3), init_y+length_y*factor_y*(num_row) length_x length_y*0.1], 'string', 'SCA', 'edgecolor', 'none', ...
    'FontName',font_name,'FontSize',font_size, 'horizontalalignment', 'left');
a32 = annotation(fig, 'textbox', [init_x + length_x*factor_x*(4), init_y+length_y*factor_y*(num_row) length_x length_y*0.1], 'string', 'SCZ', 'edgecolor', 'none', ...
    'FontName',font_name,'FontSize',font_size, 'horizontalalignment', 'left');
a32 = annotation(fig, 'textbox', [init_x + length_x*factor_x*(5), init_y+length_y*factor_y*(num_row) length_x length_y*0.1], 'string', 'All', 'edgecolor', 'none', ...
    'FontName',font_name,'FontSize',font_size, 'horizontalalignment', 'left');


a32 = annotation(fig, 'textbox', [init_x + length_x*factor_x*(-2.5), init_y+length_y*factor_y*(num_row-0.5) length_x*3.5 length_y*0.1], 'string', 'patient numbers', 'edgecolor', 'none', ...
    'FontName',font_name,'FontSize',font_size, 'horizontalalignment', 'left');
a32 = annotation(fig, 'textbox', [init_x + length_x*factor_x*(-2.5), init_y+length_y*factor_y*(num_row-1.5) length_x*3.5 length_y*0.1], 'string', 'HC numbers', 'edgecolor', 'none', ...
    'FontName',font_name,'FontSize',font_size, 'horizontalalignment', 'left');
a32 = annotation(fig, 'textbox', [init_x + length_x*factor_x*(-2.5), init_y+length_y*factor_y*(num_row-2.5) length_x*3.5 length_y*0.1], 'string', 'subject numbers', 'edgecolor', 'none', ...
    'FontName',font_name,'FontSize',font_size, 'horizontalalignment', 'left');
a32 = annotation(fig, 'textbox', [init_x + length_x*factor_x*(-2.5), init_y+length_y*factor_y*(num_row-3.5) length_x*3.5 length_y*0.1], 'string', 'patient/HC', 'edgecolor', 'none', ...
    'FontName',font_name,'FontSize',font_size, 'horizontalalignment', 'left');

a32 = annotation(fig, 'textbox', [init_x + length_x*factor_x*(-2.5), init_y+length_y*factor_y*(num_row-4.5) length_x*3.5 length_y* 0.1], 'string', 'male numbers', 'edgecolor', 'none', ...
    'FontName',font_name,'FontSize',font_size, 'horizontalalignment', 'left');
a32 = annotation(fig, 'textbox', [init_x + length_x*factor_x*(-2.5), init_y+length_y*factor_y*(num_row-5.5) length_x*3.5 length_y* 0.1], 'string', 'female numbers', 'edgecolor', 'none', ...
    'FontName',font_name,'FontSize',font_size, 'horizontalalignment', 'left');
a32 = annotation(fig, 'textbox', [init_x + length_x*factor_x*(-2.5), init_y+length_y*factor_y*(num_row-6.5) length_x*3.5 length_y* 0.1], 'string', 'male/female', 'edgecolor', 'none', ...
    'FontName',font_name,'FontSize',font_size, 'horizontalalignment', 'left');


a32 = annotation(fig, 'textbox', [init_x + length_x*factor_x*(-2.5), init_y+length_y*factor_y*(num_row-7.5) length_x*3.5 length_y* 0.1], 'string', 'age mean', 'edgecolor', 'none', ...
    'FontName',font_name,'FontSize',font_size, 'horizontalalignment', 'left');
a32 = annotation(fig, 'textbox', [init_x + length_x*factor_x*(-2.5), init_y+length_y*factor_y*(num_row-8.5) length_x*3.5 length_y* 0.1], 'string', 'age variance', 'edgecolor', 'none', ...
    'FontName',font_name,'FontSize',font_size, 'horizontalalignment', 'left');

%%
% savefig(fig,['output/confound.fig']);
% set(fig, 'PaperPositionMode', 'auto')
% print(fig, '-djpeg', '-r600', 'output/confound.jpg')