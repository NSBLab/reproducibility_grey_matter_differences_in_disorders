function plot_map(map)
hemi = 'lh';

%load vtk surface
filename_vtk = ['/projects/kg98/trangc/atlases/standard_mesh_atlases/resample_fsaverage/',hemi,'_fsaverage_164k_midthickness.vtk'];
[vertices,faces] = read_vtk(filename_vtk);
vertices = vertices';
faces = faces';
figure
 ax3 = axes;

        patch(ax3, 'Vertices', vertices, 'Faces', faces, 'FaceVertexCData', map, ...
            'EdgeColor', 'none', 'FaceColor', 'interp');
        if strcmp(hemi,'lh')
            view([-90 0]);
        else
            view([90 0]);
        end
        camlight('headlight')
        material dull

         colormap(ax3,bluewhitered)
        axis off;
        axis image;
    