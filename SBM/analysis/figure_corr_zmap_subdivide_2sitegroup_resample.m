clear all
close all

smoothKernel = 10;
% diag = 4;
hemis = 'lh';
dividemode = 'splitsite';
addpath(genpath('/projects/kg98/trangc/VBM/code'))
dataDir = fullfile('/scratch','kg98','trangc','VBM','data', 'derivatives', 'freesurfer',['s',num2str(smoothKernel),'noCOMBAT']);
sampleSizeList = [20 40 60 80 100 200 300 400 500 600 700];
targetValues = 0.1:0.1:1;
colorVec = {[225 232 255], [205 217 255], [185 202 255], [165 186 255], [145 171 255], ...
    [115 148 255], [85 125 255], [55 103 255],[5 65 255],[0 48 200],[0 36 150],[0 24 100] };

nSize = length(sampleSizeList);
fig = figure('Position', [200 200 1200 900]);
set(fig,'color','w');
factor_x = 1.2;
factor_y = 1.5;
init_x = 0.1;
init_y = 0.2;
num_row = 3;
num_col = 3;
length_x = (0.82 - init_x)/(factor_x*(num_col-1) + 1);
length_y = (0.95 - init_y)/(factor_y*(num_row-1) + 1);
lineWidth = 2;
%
font_name = 'Arial';
font_size = 10;
fontsize_legend = 8;



for diag = 2:7
    ax2 = axes('Position', [init_x+(mod(diag-2,3))*length_x*factor_x init_y+(num_row-floor((diag-2)/3)-2)*length_y*factor_y length_x length_y]);

    resultsFile = fullfile(dataDir,['diag',num2str(diag)],hemis, ['resample_2sitegroup_',dividemode],'targetFolder.txt');
    divideFolder = readlines(resultsFile);
    corMean = zeros(length(targetValues),length(sampleSizeList));

    for iTar = 1:length(divideFolder)-1
        parts = strsplit(divideFolder(iTar), '\t');
        [va inTarget] = min(abs(str2num(parts{1})- targetValues));
        str2num(parts{1})
        inTarget
        for iSize = 1:length(sampleSizeList)
            matFileName = fullfile(dataDir,['diag',num2str(diag)],hemis, ['resample_2sitegroup_',dividemode],parts{2},['sampleSize_',char(num2str(sampleSizeList(iSize)))],'corr_surface.mat');
            if exist(matFileName)
                matFile = load(matFileName);

                corMean(iSize,inTarget) = mean(matFile.corDiag);
            end

        end
    end

% set(ax2,'YDir', 'reverse');
    h = imagesc(ax2,sampleSizeList, targetValues,corMean)
   set(ax2,'box','off')
set(ax2, 'color','none')
clim([-1 1]);
colormap(ax2,  greenwhiteviolet(ax2));
% yticks(ax2,targetValues)
%  yticklabels(ax2,arrayfun(@(x) num2str(x),targetValues,'UniformOutput',false));
%  xticks(ax2,sampleSizeList)
%  xticklabels(ax2,arrayfun(@(x) num2str(x),sampleSizeList,'UniformOutput',false))
    
 xlabel('correlation')
ylabel({'density'})  
set(ax2,'box','off')
set(ax2, 'color','none')
end

 c1 =  colorbar('Position', [ax2.Position(1)+ax2.Position(3)*1.1, ax2.Position(2)+ax2.Position(4)*0.5, 0.01, 0.05],'AxisLocation','out')
        % c1 =  colorbar('Position', [ax1.Position(1)-ax1.Position(3)*0.2, ax1.Position(2), 0.01, ax1.Position(4)],'AxisLocation','out')
       c1.Label.String = 'Correlation';
        c1.Label.Rotation = 0;
       c1.Label.Position = [0.15 1.3];


%%
% savefig(fig,['output/figure_corr_tmap_noCombat.fig']);
% set(fig, 'PaperPositionMode', 'auto')
% print(fig, '-djpeg', '-r1200', 'output/figure_corr_tmap_noCombat.jpg')