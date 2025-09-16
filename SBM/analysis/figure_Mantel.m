clear all
close all
addpath('/home/trangc/kg98/trangc/library/Violinplot-Matlab-master')
addpath(genpath('/projects/kg98/trangc/VBM/code'))
iCOMBAT = 0;
smoothKernel = 10;
rng(3)

diagnosisString = {'BD', 'SCA',...
    'SCZ', 'ASD', 'MDD','AD' };
diagnosisStr = {'Bipolar', 'Schizoaffective',...
    'Schizoprenia', 'Autism', 'Depression','Alzheimer' };
nDiag = length(diagnosisString);



light_green = [0.25 0.75 0.25];
% darkblue = [0 0 204/255];
lightblue = [0 153/255 255/255];
darkred = [150/255 0 0];
lightred = [255/255 147/255 147/255];
darkblue = [10/255 52/255 204/255];
gray = [0.5 0.5 0.5];
lightorange =  [124/255 125/255 117/255];%[255/255 211/255 147/255];%[0.75 0.5 0.25];
darkorange = [242/255 144/255 0];%[0.75 0.25 0.25]; %

fig = figure('Position', [200 200 1200 800]);
set(fig,'color','w');
factorX = 1.1;
factorY = 1.7;
initX = 0.05;
initY = 0.08;
numRow = 4;
numCol = 2;
lengthX = (0.95 - initX)/(factorX*(numCol-1) + 1);
lengthY = (0.93 - initY)/(factorY*(numRow-1) + 1);

factorMapX = 1.05;
factorMapY = 1;
initMapX = initX+lengthX*2*factorX+0.05;
initMapY = 0.01;
numRowMap = nDiag*2;
numColMap = 4;
lengthMapX = lengthX*0.15;
lengthMapY = lengthY*0.55;
lineWidth = 2;

initVioX = 0.2;

font_name = 'Arial';
font_size = 10;
fontsize_legend = 8;
nSite = 3;
vec1 = [0.1 0.7 0.3];%randn(1,3);
mat1 = eye(3);
mat1(1,2) = vec1(1);
mat1(2,1) = vec1(1);
mat1(1,3) = vec1(2);
mat1(3,1) = vec1(2);
mat1(3,2) = vec1(3);
mat1(2,3) = vec1(3);
ax1 = axes;
  hm = imagesc(ax1,1:3, 1:3, mat1);
   colormap(ax1, greenwhiteviolet(ax1));
   xticks(ax1,[1:nSite])
    xticklabels(ax1,arrayfun(@(x) num2str(x),[1:nSite],'UniformOutput',false));
    xticklabels(ax1,arrayfun(@(x) num2str(x),[1:nSite],'UniformOutput',false));
    yticks(ax1,[1:nSite])
    yticklabels(ax1,arrayfun(@(x) num2str(x),[1:nSite],'UniformOutput',false))
    % xlabel('site')
    % ylabel('site')