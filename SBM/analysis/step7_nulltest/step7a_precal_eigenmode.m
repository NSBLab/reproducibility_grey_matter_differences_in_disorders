function step7a_precal_eigenmode(config, hemi)
% Precompute geometric eigenmodes for eigentrapping nulltest (step7b).
% Saves eigenStruct_<hemi>.mat under config data_directories.dataset_root.
%
% Usage:
%   step7a_precal_eigenmode('config_hpc.json')
%   step7a_precal_eigenmode('config_hpc.json', 'lh')
%   step7a_precal_eigenmode(config, 'rh')

if nargin < 1 || isempty(config)
    error('Usage: step7a_precal_eigenmode(config [, hemi])');
end
if nargin < 2 || isempty(hemi)
    hemi = 'lh';
end
hemi = char(hemi);

this_dir = fileparts(mfilename('fullpath'));
repo_root = fullfile(this_dir, '..', '..', '..');
utils_dir = fullfile(repo_root, 'utils');
addpath(genpath(utils_dir));   % utils/ + utils/modes/ (calc_geometric_eigenmode, trimExcludedRois, read_vtk, ...)

if ischar(config) || isstring(config)
    config = pipeline_load_config(char(config));
end

if ~isfield(config.data_directories, 'atlas_dir') || isempty(config.data_directories.atlas_dir)
    error('config.data_directories.atlas_dir is required for step7a');
end
atlas_dir = config.data_directories.atlas_dir;
data_root = config.data_directories.dataset_root;

fprintf('=== STEP7A: PRECAL EIGENMODE ===\n');
fprintf('hemi:      %s\n', hemi);
fprintf('atlas_dir: %s\n', atlas_dir);
fprintf('data_root: %s\n', data_root);

s = struct();
s.hemi = hemi;
s.maskFile = fullfile(atlas_dir, sprintf('fsaverage_164k_cortex-%s_mask.txt', hemi));
s.vtkFile  = fullfile(atlas_dir, sprintf('fsaverage_164k_midthickness_%s.vtk', hemi));

if ~exist(s.maskFile, 'file')
    error('Mask file not found: %s', s.maskFile);
end
if ~exist(s.vtkFile, 'file')
    error('VTK file not found: %s', s.vtkFile);
end

s.mask = readmatrix(s.maskFile);
[s.vertices, s.faces] = read_vtk(s.vtkFile);
s.vertices = s.vertices';
s.faces = s.faces';
[s.vertices, s.faces, s.rois, s.mask] = trimExcludedRois(s.vertices, s.faces, s.mask);
s = calc_geometric_eigenmode(s, 200);

if ~exist(data_root, 'dir')
    mkdir(data_root);
end
outFile = fullfile(data_root, sprintf('eigenStruct_%s.mat', hemi));
save(outFile, 's');
fprintf('Saved: %s\n', outFile);
fprintf('=== STEP7A COMPLETED ===\n');
end
