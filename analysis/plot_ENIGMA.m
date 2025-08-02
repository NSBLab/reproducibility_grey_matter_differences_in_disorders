clear all

addpath(genpath('/projects/kg98/trangc/ENIGMA/matlab/'))
% list of disorders
diagString = {'HC', 'BD', 'SCA',...
    'SCZ', 'ASD', 'MDD' };
iCOMBAT = 1;
smoothKernel = 10;

% load all site maps
load(['/fs04/kg98/trangc/VBM/code/freesurfer/freesurfer_holmesQC/step4_qdec/corr_surface_aparc.mat'], 'map','corDiag', 'corSig')
[vert,label,colortable]=read_annotation('/home/trangc/kg98/trangc/VBM/data/HCP/derivatives/freesurfer/fsaverage/label/lh.aparc.annot');

%load vtk surface
filename_vtk = 'fsaverage_164k_midthickness-lh.vtk';
[vertices,faces] = read_vtk(filename_vtk);
vertices = vertices';
faces = faces';

% Load summary statistics for ENIGMA-BD
sum_stats = load_summary_stats('bipolar');

% Get case-control surface area table
CT = sum_stats.CortThick_case_vs_controls_adult;
CTAll{2} = CT{1:34,3};

% Load summary statistics for ENIGMA-schizophrenia
sum_stats = load_summary_stats('schizophrenia');

% Get case-control cortical thickness and surface area tables
CT = sum_stats.CortThick_case_vs_controls;
CTAll{4} = CT{1:34,3};

% Load summary statistics for ENIGMA-Autism
sum_stats = load_summary_stats('asd');

% Get case-control cortical thickness table
CT = sum_stats.CortThick_case_vs_controls_meta_analysis;
CTAll{5} = CT{1:34,3};

% Load summary statistics for ENIGMA-MDD
sum_stats = load_summary_stats('depression');

% Get case-control cortical thickness and surface area tables
CT = sum_stats.CortThick_case_vs_controls_adult;
CTAll{6} = CT{1:34,3};

iDiag = 4;

ENIGMAParmap = CTAll{iDiag};
ENIGMAParmapExtend(1) =  0;
ENIGMAParmapExtend(5) =  0;
ENIGMAParmapExtend(2:4) =  ENIGMAParmap(1:3);
ENIGMAParmapExtend(6:36) =  ENIGMAParmap(4:34);
[ia parLabel] = ismember(label,colortable.table(:,5));
parLabel(parLabel==0) = 1;

ENIGMAMap = ENIGMAParmapExtend(parLabel);

 isDiagSite = strcmp(map.diag, num2str((iDiag)));
 siteParMap = map.zmap(isDiagSite,1:34)';

siteMapExtend(2:4,:) =  siteParMap(1:3,:);
siteMapExtend(6:36,:) =  siteParMap(4:34,:);
siteMapExtend(1,:) =  0;
siteMapExtend(5,:) =  0;

siteMap = siteMapExtend(parLabel,:);

 siteList = map.site(isDiagSite);

 fig = figure('Position', [200 200 1200 800]);
set(fig,'color','w');
factorX = 1.1;
factorY = 1.5;
initX = 0.1;
initY = 0.07;
numRow = 5;
numCol = 6;
lengthX = (0.95 - initX)/(factorX*(numCol-1) + 1);
lengthY = (0.93 - initY)/(factorY*(numRow-1) + 1);

 for iMap = 1:width(siteMap)

         ax3 = axes('Position', [initX+mod(iMap-1,6)*lengthX*factorX initY+(4-floor((iMap-1)/6))*lengthY*factorY lengthX lengthY]);
        patch(ax3, 'Vertices', vertices, 'Faces', faces, 'FaceVertexCData', siteMap(:,iMap), ...
            'EdgeColor', 'none', 'FaceColor', 'interp');
        view([-90 0]);

        camlight('headlight')
        material dull
        colormap(ax3,bluewhitered(ax3))
        axis off;
        axis image;
 end

 iMap = 30;

              ax3 = axes('Position', [initX+mod(iMap-1,6)*lengthX*factorX initY+(4-floor((iMap-1)/6))*lengthY*factorY lengthX lengthY]);
        patch(ax3, 'Vertices', vertices, 'Faces', faces, 'FaceVertexCData', ENIGMAMap', ...
            'EdgeColor', 'none', 'FaceColor', 'interp');
        view([-90 0]);

        camlight('headlight')
        material dull
        colormap(ax3,bluewhitered(ax3))
        axis off;
        axis image;

% save('corr_ENIGMA.mat',  'map','corENIGMA','siteList');