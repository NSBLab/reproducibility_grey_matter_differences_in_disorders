function figure_cor_tmap_raincloud_combat_noncombat(config)
if nargin < 1 || isempty(config)
    config = 'config_hpc.json';
end
this_dir = fileparts(mfilename('fullpath'));
repo_root = fullfile(this_dir, '..', '..', '..');
addpath(genpath(fullfile(repo_root, 'utils')));
if ischar(config) || isstring(config)
    config = pipeline_load_config(char(config));
end
data_root = config.data_directories.dataset_root;
if isfield(config.data_directories, 'data') && ~isempty(config.data_directories.data)
    plot_data_dir = pipeline_resolve_relative_path(repo_root, config.data_directories.data);
else
    plot_data_dir = fullfile(repo_root, 'data');
end
output_dir = fullfile(data_root, 'results', 'VBM', 'analysis', 'output');

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

fig = figure('Position', [200 200 1000 350]);
set(fig,'color','w');
factorX = 1;
factorY = 1.7;
initX = 0.05;
initY = 0.09;
numRow = 1;
numCol = 1;
lengthX = (0.99 - initX)/(factorX*(numCol-1) + 1);
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
paralist = [1 0];
nPara = length(paralist);
for iPara = 1:nPara
    
iCOMBAT = paralist(iPara);
    load(fullfile(plot_data_dir, ['corr_tmap_combat',num2str(iCOMBAT),'_smooth',num2str(smoothKernel),'.mat']), 'map','cor1','siteList')
    load(fullfile(plot_data_dir, ['tmap_null_brainsmash_COMBAT', num2str(iCOMBAT), '_smooth', num2str(config.analysis_settings.vbm_smoothing_kernel), '_ver_all.mat']),...
        'cortmapBrainsmashSurrsVerAll');

    makeUvalue = 0;
    for iDiag = 1:nDiag

        iData = plotorder(iDiag); % the order in the data
        ids{iDiag}=find(tril(ones(size(cor1{iData})),-1));
        corToPlot{1+(iPara-1)*2*(iPara<3)+3*(iPara>=3),iDiag} = cor1{iData}(ids{iDiag});
        corToPlot{2,iDiag} = cortmapBrainsmashSurrsVerAll{iData};



        % Extract empirical median
        empiricalMedian = median(corToPlot{1+(iPara-1)*2*(iPara<3)+3*(iPara>=3), iDiag});
nullMedian = median(corToPlot{2, iDiag});
        % Calculate percentile (i.e., proportion of null values less than or equal to empirical median)
        p_value(iPara,iDiag) = mean(abs(empiricalMedian - nullMedian  ) <= abs(corToPlot{2, iDiag}-nullMedian));

    end


end

% fprintf('%.5f, ', prs);
% fprintf('%.5f, ', hrs);
% make colormap
    C = repmat([darkblue; lightblue; darkblue; darkblue],nPara,1);

ViolinColor = {repmat(C,ceil(size(corToPlot,2)/length(C)),1)};

ax2 = axes('Position', [initX, initY lengthX lengthY]);
violinplot_subclass(corToPlot, diagnosisStr(plotorder),'ViolinColor',ViolinColor,'BoxColor',[0 0 0],'BoxWidth',0.07);
%[1 3 5 2 4 6]
set(ax2,'FontSize',fontsize_legend)
ylabel('correlation','FontSize',fontsize_legend)
set(ax2,'box','off')
tempXlim = xlim;
tempYlim = [-0.5 1];
dummyplot1 = scatter(ax2,[-1],[-1],'marker','o','MarkerEdgeColor',darkblue,'MarkerFaceColor',darkblue);
dummyplot2 = scatter(ax2,[-1],[-1],'marker','o','MarkerEdgeColor',lightblue,'MarkerFaceColor',lightblue);

legend([dummyplot1,dummyplot2],{'Observed','Null'},'Location','southeast')
xlim([0 tempXlim(2)])
ylim(tempYlim)

legend('boxoff')
for iPara = 1:nPara-1
for iDiag = 1:nDiag
    if p_value(iPara,iDiag) <= thres
        a17 = annotation(fig, 'textbox', [ax2.Position(1)+ax2.Position(3)*(0.03+(iPara-1)*0.065+(iDiag-1)*0.159), ax2.Position(2)+ax2.Position(4)*0.9, 0.09, 0.02], 'string', '*', 'edgecolor', 'none', ...
            'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'left','Interpreter','none');
    end
end
end



% Convert data coordinates to normalized figure units
x = [ax2.Position(1)+ax2.Position(3)*0.04, ax2.Position(1)+ax2.Position(3)*0.08];  % normalized horizontal range (0 to 1)
y = ax2.Position(2)+ax2.Position(4)*0.23;        % normalized vertical location

% Draw three lines to make the bracket
annotation('line', [x(1) x(1)], [y y+0.03], 'Color', 'k', 'LineWidth', 1);
ax3= annotation('line', [x(1) x(2)], [y y], 'Color', 'k', 'LineWidth', 1);
annotation('line', [x(2) x(2)], [y+0.03 y], 'Color', 'k', 'LineWidth', 1);
a17 = annotation(fig, 'textbox', [ax3.Position(1)-0.01, ax3.Position(2), 0.1, ax3.Position(4)], 'string', 'ComBat', 'edgecolor', 'none', ...
            'FontName',font_name,'FontSize',fontsize_legend,  'horizontalalignment', 'left');


% Convert data coordinates to normalized figure units
x = [ax2.Position(1)+ax2.Position(3)*(0.11), ax2.Position(1)+ax2.Position(3)*(0.13)];  % normalized horizontal range (0 to 1)
y = ax2.Position(2)+ax2.Position(4)*0.9;        % normalized vertical location

% Draw three lines to make the bracket
annotation('line', [x(1) x(1)], [y y+0.03], 'Color', 'k', 'LineWidth', 1);
ax4 = annotation('line', [x(1) x(2)], [y+0.03 y+0.03], 'Color', 'k', 'LineWidth', 1);
annotation('line', [x(2) x(2)], [y+0.03 y], 'Color', 'k', 'LineWidth', 1);
a17 = annotation(fig, 'textbox', [ax4.Position(1)-0.02, ax4.Position(2)+0.07, 0.1, ax4.Position(4)], 'string', 'non-ComBat', 'edgecolor', 'none', ...
            'FontName',font_name,'FontSize',fontsize_legend,  'horizontalalignment', 'left');

%%
savefig(fig,fullfile(output_dir,['figure_corr_tmap_combat',char(num2str(iCOMBAT)),'_smooth',num2str(smoothKernel),'_combat_noncomnbat.fig']));
set(fig, 'PaperPositionMode', 'auto')
print(fig, '-djpeg', '-r1200', fullfile(output_dir,['figure_corr_tmap_combat',char(num2str(iCOMBAT)),'_smooth',num2str(smoothKernel),'_combat_noncombat.jpg']))
end
