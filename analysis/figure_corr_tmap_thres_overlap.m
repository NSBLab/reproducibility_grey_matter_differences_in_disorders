%plot overlap

font_name = 'Arial';
font_size = 10;
fontsize_legend = 8;

load('output/overlap.mat')

fig = figure('Position', [200 200 800 400]);
set(fig,'color','w');
factor_x = 1.2;
factor_y = 1.5;
init_x = 0.1;
init_y = 0.1;
num_row = 1;
num_col = 2;
length_x = (0.92 - init_x)/(factor_x*(num_col-1) + 1);
length_y = (0.94 - init_y)/(factor_y*(num_row-1) + 1);


ax1 = axes('Position', [init_x, init_y length_x length_y]);
bar(ax1, overlapTime1(3:end), overlapCount1(:,3:end))
xlabel('overlap times')
ylabel('number of voxels')

ax2 = axes('Position', [init_x+length_x*factor_x, init_y length_x length_y]);
bar(ax2, overlapTime2(3:end), overlapCount2(:,3:end))
xlabel('overlap times')

legend('ASD', 'BD' , 'MDD', 'SCA', 'SCZ');

a32 = annotation(fig, 'textbox', [0, 0.99, 0.1, 0.01], 'string', 'A', 'edgecolor', 'none', ...
    'FontName',font_name,'FontSize',font_size, 'horizontalalignment', 'left');

a32 = annotation(fig, 'textbox', [0.5, 0.99, 0.1, 0.01], 'string', 'B', 'edgecolor', 'none', ...
    'FontName',font_name,'FontSize',font_size, 'horizontalalignment', 'left');

% savefig(fig,['output/overlap.fig']);
% set(fig, 'PaperPositionMode', 'auto')
% print(fig, '-djpeg', '-r600', 'output/overlap.jpg')