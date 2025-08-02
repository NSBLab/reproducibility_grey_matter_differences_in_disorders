s.hemi = 'rh';
s.maskFile = ['/projects/kg98/trangc/atlases/Human_standard_surface/fsaverage_164k_cortex-',hemi,'_mask.txt'];
s.vtkFile = ['/projects/kg98/trangc/atlases/Human_standard_surface/fsaverage_164k_midthickness_',hemi,'.vtk'];
s.mask = readmatrix(s.maskFile);
[s.vertices,s.faces] = read_vtk(s.vtkFile);
s.vertices = s.vertices';
s.faces = s.faces';
[s.vertices,s.faces,s.rois,s.mask] = trimExcludedRois(s.vertices,s.faces, s.mask);
s.vertices = vertices;
s.faces = faces;    
s = calc_geometric_eigenmode(s, 200);
save(['eigenStruct_',s.hemi,'.mat'],'s')

