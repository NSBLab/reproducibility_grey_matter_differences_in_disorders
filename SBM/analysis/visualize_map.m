%read map
% outDir = '/';
readmap = load_mgh(fullfile('/projects/kg98/trangc/testMBM/result/lh-Diff-1-4-Intercept-thickness', 'sig.mgh'));
%map=readmap;
map = double((10.^(-abs(readmap)))<=0.05);
% datalist = readlines("text.txt");
%for i=1:length(datalist)
%    dataset = datalist(i);

%map(:,i) = load_mgh('sig.mgh');
%end

% get p value
%binaraymap = (-10^.sigmap)<0.05;

%get corr
%cortable = corr(map);

%load vtk surface
filename_vtk = 'fsaverage_164k_midthickness-lh.vtk';
[vertices,faces] = read_vtk(filename_vtk);
vertices = vertices';
faces = faces';

%%
fig = figure('Position', [200 200 700 500]);
    % set(fig,'color','w');
    % factor_x = 1.2;
    % factor_y = 1.5;
    % init_x = 0.1;
    % init_y = 0.2;
    % num_row = 1;
    % num_col = 1;
    % length_x = (0.82 - init_x)/(factor_x*(num_col-1) + 1);
    % length_y = (0.95 - init_y)/(factor_y*(num_row-1) + 1);
    % lineWidth = 2;
    %
    % font_name = 'Arial';
    % font_size = 10;
    % fontsize_legend = 8;
    %%plot maps

ax3=axes;
    % ax3 = axes('Position', [init_x, init_y+length_y/2 length_x/4 length_y/4]);

    patch(ax3, 'Vertices', vertices, 'Faces', faces, 'FaceVertexCData', map, ...
        'EdgeColor', 'none', 'FaceColor', 'interp');
    view([-90 0]);

    camlight('headlight')
    material dull
    colormap(ax3,bluewhitered(ax3))
    axis off;
    axis image;

    colorbar
