clear all
% close all
addpath('/home/trangc/kg98/trangc/library/Violinplot-Matlab-master')
addpath(genpath('/projects/kg98/trangc/VBM/code'))
iCOMBAT = 1;
smoothKernel = 6;
thres = 0.05;


diagnosisString = {'BD', 'SCA',...
    'SCZ', 'ASD', 'MDD','AD' };
diagnosisStr = {'Bipolar', 'Schizoaffective',...
    'Schizophrenia', 'Autism', 'Depression','Alzheimer' };
nDiag = length(diagnosisString);

plotorder = [6 3 2 4 5 1]; % change the order of disorder appear in the plot


light_green = [0.25 0.75 0.25];
% darkblue = [0 0 204/255];
lightblue = [0 153/255 255/255];
darkred = [150/255 0 0];
lightred = [255/255 147/255 147/255];
darkblue = [10/255 52/255 204/255];
gray = [0.5 0.5 0.5];
lightorange =  [124/255 125/255 117/255];%[255/255 211/255 147/255];%[0.75 0.5 0.25];
darkorange = [242/255 144/255 0];%[0.75 0.25 0.25]; %

fig = figure('Position', [200 200 1000 300]);
set(fig,'color','w');
factorX = 1.1;
factorY = 1.7;
initX = 0.05;
initY = 0.09;
numRow = 1;
numCol = 1;
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
font_size = 12;
fontsize_legend = 10;

% %load vtk surface
% filename_vtk = ['/projects/kg98/trangc/atlases/standard_mesh_atlases/resample_fsaverage/',hemi,'_fsaverage_164k_midthickness.vtk'];
% [vertices,faces] = read_vtk(filename_vtk);
% vertices = vertices';
% faces = faces';close


s_all = load(['output/corr_tmap_combat',num2str(iCOMBAT),'_smooth',num2str(smoothKernel),'.mat'], ...
    'cor1', 'cor2','corThres1','corThres2','repThres1','repThres2', ...
    "siteList",'siteThresList','t1All','t2All','thresmap1','thresmap2');

s_study = load(['output/corr_average_across_study_tmap_combat',num2str(iCOMBAT),'_smooth',num2str(smoothKernel),'.mat'], ...
    'cor1', 'cor2','corThres1','corThres2','repThres1','repThres2', ...
    "siteList",'siteThresList','t1All','t2All','thresmap1','thresmap2');

paralist = {'cor1','corHC_P',  'repHC_P' ,'cor1','corHC_P',  'repHC_P' };
nPara = length(paralist);


makeUvalue = 0;
for iDiag = 1:nDiag

iData = plotorder(iDiag); % the order in the data
    ids = find(tril(ones(size(s_all.cor1{iData})),-1));
    corToPlot{1,iDiag} = s_all.cor1{iData}(ids);
    corToPlot{3,iDiag} = s_all.corThres1{iData}(ids);
  corToPlot{5,iDiag} = s_all.repThres1{iData}(ids);

     corToPlot{2,iDiag} = s_study.cor1{iData};
    corToPlot{4,iDiag} = s_study.corThres1{iData};
    corToPlot{6,iDiag} = s_study.repThres1{iData};


    


end


% make colormap
C = repmat([darkblue; lightblue],nPara,1);
ViolinColor = {repmat(C,ceil(size(corToPlot,2)/length(C)),1)};


    ax2 = axes('Position', [initX, initY lengthX lengthY]);
    violinplot_subclass(corToPlot, diagnosisStr(plotorder),'ViolinColor',ViolinColor,'BoxColor',[0 0 0],'BoxWidth',0.07);
    %[1 3 5 2 4 6]
    set(ax2,'FontSize',fontsize_legend)
  
    ylabel('consistency','FontSize',fontsize_legend)
    
    set(ax2,'box','off')
    tempXlim = xlim;
    tempYlim = [-0.5 1];
    xlim([0 tempXlim(2)])
    ylim(tempYlim)

 
    dummyplot1 = scatter(ax2,[-1],[-1],'marker','o','MarkerEdgeColor',darkblue,'MarkerFaceColor',darkblue);
    dummyplot2 = scatter(ax2,[-1],[-1],'marker','o','MarkerEdgeColor',lightblue,'MarkerFaceColor',lightblue);

    legend([dummyplot1,dummyplot2],{'all sites','site average'},'Location','northeast')
    
    legend('boxoff')
   
    % mean and range
    medCor =  cellfun(@(x) median(x), corToPlot,'UniformOutput',false);
    minCor = cellfun(@(x) min(x), corToPlot,'UniformOutput',false);
    maxCor = cellfun(@(x) max(x), corToPlot,'UniformOutput',false);

 % Convert data coordinates to normalized figure units
    x = [ax2.Position(1)+ax2.Position(3)*0.015, ax2.Position(1)+ax2.Position(3)*0.045];  % normalized horizontal range (0 to 1)
    y = ax2.Position(2)+ax2.Position(4)*0.35;        % normalized vertical location

    % Draw three lines to make the bracket
    annotation('line', [x(1) x(1)], [y y+0.01], 'Color', 'k', 'LineWidth', 1);
    ax3= annotation('line', [x(1) x(2)], [y y], 'Color', 'k', 'LineWidth', 1);
    annotation('line', [x(2) x(2)], [y+0.01 y], 'Color', 'k', 'LineWidth', 1);
    a17 = annotation(fig, 'textbox', [ax3.Position(1)-0.01, ax3.Position(2), ax3.Position(3)*3, ax3.Position(4)], 'string', 'correlation', 'edgecolor', 'none', ...
        'FontName',font_name,'FontSize',fontsize_legend,  'horizontalalignment', 'left','Interpreter','none');

  % Convert data coordinates to normalized figure units
    x = [ax2.Position(1)+ax2.Position(3)*0.06, ax2.Position(1)+ax2.Position(3)*0.09];  % normalized horizontal range (0 to 1)
    y = ax2.Position(2)+ax2.Position(4)*0.25;        % normalized vertical location

    % Draw three lines to make the bracket
    annotation('line', [x(1) x(1)], [y y+0.01], 'Color', 'k', 'LineWidth', 1);
    ax3= annotation('line', [x(1) x(2)], [y y], 'Color', 'k', 'LineWidth', 1);
    annotation('line', [x(2) x(2)], [y+0.01 y], 'Color', 'k', 'LineWidth', 1);
    a17 = annotation(fig, 'textbox', [ax3.Position(1)-0.02, ax3.Position(2)+0.01, ax3.Position(3)*3, ax3.Position(4)], 'string', {'binary','correlation'}, 'edgecolor', 'none', ...
        'FontName',font_name,'FontSize',fontsize_legend,  'horizontalalignment', 'left','Interpreter','none');

    % Convert data coordinates to normalized figure units
    x = [ax2.Position(1)+ax2.Position(3)*0.105, ax2.Position(1)+ax2.Position(3)*0.145];  % normalized horizontal range (0 to 1)
    y = ax2.Position(2)+ax2.Position(4)*0.1;        % normalized vertical location

    % Draw three lines to make the bracket
    annotation('line', [x(1) x(1)], [y y+0.01], 'Color', 'k', 'LineWidth', 1);
    ax3= annotation('line', [x(1) x(2)], [y y], 'Color', 'k', 'LineWidth', 1);
    annotation('line', [x(2) x(2)], [y+0.01 y], 'Color', 'k', 'LineWidth', 1);
    a17 = annotation(fig, 'textbox', [ax3.Position(1)-0.02, ax3.Position(2), ax3.Position(3)*3, ax3.Position(4)], 'string', 'replication', 'edgecolor', 'none', ...
        'FontName',font_name,'FontSize',fontsize_legend,  'horizontalalignment', 'left','Interpreter','none');


%%
savefig(fig,['output/figure_corr_tmap_combat',char(num2str(iCOMBAT)),'_smooth',num2str(smoothKernel),'_average_across_study.fig']);
set(fig, 'PaperPositionMode', 'auto')
print(fig, '-djpeg', '-r1200', ['output/figure_corr_tmap_combat',char(num2str(iCOMBAT)),'_smooth',num2str(smoothKernel),'_average_across_study.jpg'])
