clear all
% close all
addpath('/home/trangc/kg98/trangc/library/Violinplot-Matlab-master')
addpath(genpath('/projects/kg98/trangc/VBM/code'))
iCOMBAT = 1;
smoothKernel = 0;
hemi = 'lh';
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

fig = figure('Position', [200 200 1200 1000]);
set(fig,'color','w');
factorX = 1.1;
factorY = 1.3;
initX = 0.05;
initY = 0.09;
numRow = 3;
numCol = 1;
lengthX = (0.98 - initX)/(factorX*(numCol-1) + 1);
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
% faces = faces';







nParcList = [100 500 1000];
nPara = length(nParcList)*3;
for iParc = 1:3
nParc = nParcList(iParc);
load(['output/corr_tmap_parc_',num2str(nParc),'.mat']);
load(['output/corr_null_tmap_parc_',num2str(nParc),'.mat']);

makeUvalue = 0;
for iDiag = 1:nDiag
iData = plotorder(iDiag); % the order in the data

    ids{iDiag}=find(tril(ones(size(cor1{iData})),-1));
    corToPlot{1+(iParc-1)*2,iDiag} = cor1{iData}(ids{iDiag});
    corToPlot{2+(iParc-1)*2,iDiag} = corNull{iData};

    ids{iDiag}=find(tril(ones(size(corThres1{iData})),-1));
    corToPlot{7+(iParc-1)*2,iDiag} = corThres1{iData}(ids{iDiag});
    corToPlot{8+(iParc-1)*2,iDiag} = corThresNull{iData};

    ids{iDiag}=find(tril(ones(size(rep1{iData})),-1));
    corToPlot{13+(iParc-1)*2,iDiag} = rep1{iData}(ids{iDiag});
    corToPlot{14+(iParc-1)*2,iDiag} = repThresNull{iData};

   

end
end

for iPara = 1:nPara
    for iDiag = 1:nDiag
        % Extract empirical median
        empiricalMedian = median(corToPlot{1+(iPara-1)*2, iDiag});
        nullMedian = median(corToPlot{2+(iPara-1)*2, iDiag});
        % Calculate percentile (i.e., proportion of null values less than or equal to empirical median)
        p_value(iPara,iDiag) = mean(abs(empiricalMedian - nullMedian  ) <= abs(corToPlot{2+(iPara-1)*2, iDiag}-nullMedian));

    end

end


% fprintf('%.5f, ', prs);
% fprintf('%.5f, ', hrs);
% make colormap
C = repmat([darkblue; lightblue],nPara,1);
ViolinColor = {repmat(C,ceil(size(corToPlot,2)/length(C)),1)};

for iRow = 1:numRow
    ax2 = axes('Position', [initX, initY+factorY*lengthY*(numRow-iRow) lengthX lengthY]);
    violinplot_subclass(corToPlot((1+(iRow-1)*6):(6+(iRow-1)*6),:), diagnosisStr(plotorder),'ViolinColor',ViolinColor,'BoxColor',[0 0 0],'BoxWidth',0.07);
    %[1 3 5 2 4 6]
    set(ax2,'FontSize',fontsize_legend)
    if iRow == 1
        ylabel('correlation','FontSize',fontsize_legend)
    elseif iRow == 2
        ylabel('binary correlation','FontSize',fontsize_legend)
    else
        ylabel('replication','FontSize',fontsize_legend)
    end
    set(ax2,'box','off')
    tempXlim = xlim;
    tempYlim = [-0.5 1];
    xlim([0 tempXlim(2)])
    ylim(tempYlim)
if iRow == 3
    for iP = 1:3
        for iDiag = 1:nDiag
            if p_value((iRow-1)*3+iP,iDiag) <= thres
                a17 = annotation(fig, 'textbox', [ax2.Position(1)+ax2.Position(3)*(0.023+(iP-1)*0.046+(iDiag-1)*0.155), ax2.Position(2)+ax2.Position(4)*1, 0.09, 0.02], 'string', '*', 'edgecolor', 'none', ...
                    'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'left','Interpreter','latex');
            end
        end
    end
else
    for iP = 1:3
        for iDiag = 1:nDiag
            if p_value((iRow-1)*3+iP,iDiag) <= thres
                a17 = annotation(fig, 'textbox', [ax2.Position(1)+ax2.Position(3)*(0.023+(iP-1)*0.046+(iDiag-1)*0.155), ax2.Position(2)+ax2.Position(4)*0.85, 0.09, 0.02], 'string', '*', 'edgecolor', 'none', ...
                    'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'left','Interpreter','latex');
            end
        end
    end
end
    if iRow == 1
        dummyplot1 = scatter(ax2,[-1],[-1],'marker','o','MarkerEdgeColor',darkblue,'MarkerFaceColor',darkblue);
        dummyplot2 = scatter(ax2,[-1],[-1],'marker','o','MarkerEdgeColor',lightblue,'MarkerFaceColor',lightblue);

        legend([dummyplot1,dummyplot2],{'Observed','Null'},'Location','southeast')

        legend('boxoff')



        % Convert data coordinates to normalized figure units
        x = [ax2.Position(1)+ax2.Position(3)*0.02, ax2.Position(1)+ax2.Position(3)*0.05];  % normalized horizontal range (0 to 1)
        y = ax2.Position(2)+ax2.Position(4)*0.2;        % normalized vertical location

        % Draw three lines to make the bracket
        annotation('line', [x(1) x(1)], [y y+0.01], 'Color', 'k', 'LineWidth', 1);
        ax3= annotation('line', [x(1) x(2)], [y y], 'Color', 'k', 'LineWidth', 1);
        annotation('line', [x(2) x(2)], [y+0.01 y], 'Color', 'k', 'LineWidth', 1);
        a17 = annotation(fig, 'textbox', [ax3.Position(1)-0.01, ax3.Position(2), ax3.Position(3)*2, ax3.Position(4)], 'string', 'SF100', 'edgecolor', 'none', ...
            'FontName',font_name,'FontSize',fontsize_legend,  'horizontalalignment', 'left','Interpreter','none');

        % Convert data coordinates to normalized figure units
        x = [ax2.Position(1)+ax2.Position(3)*0.06, ax2.Position(1)+ax2.Position(3)*0.095];  % normalized horizontal range (0 to 1)
        y = ax2.Position(2)+ax2.Position(4)*0.15;        % normalized vertical location

        % Draw three lines to make the bracket
        annotation('line', [x(1) x(1)], [y y+0.01], 'Color', 'k', 'LineWidth', 1);
        ax3= annotation('line', [x(1) x(2)], [y y], 'Color', 'k', 'LineWidth', 1);
        annotation('line', [x(2) x(2)], [y+0.01 y], 'Color', 'k', 'LineWidth', 1);
        a17 = annotation(fig, 'textbox', [ax3.Position(1)-0.01, ax3.Position(2), ax3.Position(3)*2, ax3.Position(4)], 'string', 'SF500', 'edgecolor', 'none', ...
            'FontName',font_name,'FontSize',fontsize_legend,  'horizontalalignment', 'left','Interpreter','none');

        % Convert data coordinates to normalized figure units
        x = [ax2.Position(1)+ax2.Position(3)*0.11, ax2.Position(1)+ax2.Position(3)*0.14];  % normalized horizontal range (0 to 1)
        y = ax2.Position(2)+ax2.Position(4)*0.9;        % normalized vertical location

        % Draw three lines to make the bracket
        annotation('line', [x(1) x(1)], [y y+0.01], 'Color', 'k', 'LineWidth', 1);
        ax3= annotation('line', [x(1) x(2)], [y+0.01 y+0.01], 'Color', 'k', 'LineWidth', 1);
        annotation('line', [x(2) x(2)], [y+0.01 y], 'Color', 'k', 'LineWidth', 1);
        a17 = annotation(fig, 'textbox', [ax3.Position(1)-0.01, ax3.Position(2)+0.03, ax3.Position(3)*2, ax3.Position(4)], 'string', 'SF1000', 'edgecolor', 'none', ...
            'FontName',font_name,'FontSize',fontsize_legend,  'horizontalalignment', 'left','Interpreter','none');
        

    end
end
a25 = annotation(fig, 'textbox', [0.01, 0.96, 0.02, 0.02], 'string', 'a|', 'edgecolor', 'none', ...
    'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'left');

a26 = annotation(fig, 'textbox', [0.01, 0.65, 0.03, 0.02], 'string', 'b|', 'edgecolor', 'none', ...
    'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'left');

a25 = annotation(fig, 'textbox', [0.01, 0.35, 0.02, 0.02], 'string', 'c|', 'edgecolor', 'none', ...
    'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'left');

%%
savefig(fig,['output/figure_corr_tmap_combat',char(num2str(iCOMBAT)),'_smooth',num2str(smoothKernel),'_parc_combine.fig']);
set(fig, 'PaperPositionMode', 'auto')
print(fig, '-djpeg', '-r1200', ['output/figure_corr_tmap_combat',char(num2str(iCOMBAT)),'_smooth',num2str(smoothKernel),'_parc_combine.jpg'])
