function figure_cor_zmap_raincloud_combine_null_permut(config)
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
plot_data_dir = pipeline_resolve_relative_path(repo_root, config.data_directories.data);
output_dir = fullfile(data_root, 'results', 'SBM', 'analysis', 'output');
iCOMBAT = 1;
smoothKernel = 10;
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
midblue = [4/255 116/255 252/255];

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
% faces = faces';
paralist = {'Observed','Permutation null','Eigentrapping null'};
nPara = length(paralist);


load(fullfile(plot_data_dir, ['corr_zmap_combat',num2str(iCOMBAT),'_smooth',num2str(smoothKernel),'_',hemi,'_all.mat']), 'map','corDiag', 'corSig','siteList')


for iDiag = 1:nDiag
    iData = plotorder(iDiag); % the order in the data

    ids{iDiag}=find(tril(ones(size(corDiag{iData})),-1));
    corToPlot{1,iDiag} = corDiag{iData}(ids{iDiag});

end

load(fullfile(plot_data_dir, ['corr_null_permut_zmap_combat',num2str(iCOMBAT),'_smooth',num2str(smoothKernel),'_',hemi,'.mat']), 'corDiagNull');


for iDiag = 1:nDiag
    iData = plotorder(iDiag); % the order in the data


    corToPlot{2,iDiag} = corDiagNull{iData};
    empiricalMedian = median(corToPlot{1, iDiag});
    nullMedian = median(corToPlot{2, iDiag});
    % Calculate percentile (i.e., proportion of null values less than or equal to empirical median)
    p_permut_value(iDiag) = mean(abs(empiricalMedian - nullMedian  ) <= abs(corToPlot{2, iDiag}-nullMedian));

end

load(fullfile(plot_data_dir, ['zmap_null_COMBAT1_',hemi,'_smooth',num2str(smoothKernel),'_ver_all.mat']),...
    'corzmapSurrsVerAll');

for iDiag = 1:nDiag
    iData = plotorder(iDiag); % the order in the data

    corToPlot{3,iDiag} = corzmapSurrsVerAll{iData};
    empiricalMedian = median(corToPlot{1, iDiag});
    nullMedian = median(corToPlot{3, iDiag});
    % Calculate percentile (i.e., proportion of null values less than or equal to empirical median)
    p_eigentrap_value(iDiag) = mean(abs(empiricalMedian - nullMedian  ) <= abs(corToPlot{3, iDiag}-nullMedian));

end

% fprintf('%.5f, ', prs);
% fprintf('%.5f, ', hrs);
% make colormap
C = [darkblue; midblue; lightblue];

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
dummyplot2 = scatter(ax2,[-1],[-1],'marker','o','MarkerEdgeColor',lightblue,'MarkerFaceColor',midblue);
dummyplot3 = scatter(ax2,[-1],[-1],'marker','o','MarkerEdgeColor',lightblue,'MarkerFaceColor',lightblue);


legend([dummyplot1,dummyplot2,dummyplot3],paralist,'Location','northeast')
xlim([0 tempXlim(2)])
ylim(tempYlim)

legend('boxoff')

for iDiag = 1:nDiag
    if p_permut_value(iDiag) <= thres
        a17 = annotation(fig, 'textbox', [ax2.Position(1)+ax2.Position(3)*(0.07+(iDiag-1)*0.16), ax2.Position(2)+ax2.Position(4)*0.7, 0.09, 0.02], 'string', '*', 'edgecolor', 'none', ...
            'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'left','Interpreter','none');

    end
    if p_eigentrap_value(iDiag) <= thres
        a17 = annotation(fig, 'textbox', [ax2.Position(1)+ax2.Position(3)*(0.11+(iDiag-1)*0.16), ax2.Position(2)+ax2.Position(4)*0.7, 0.09, 0.02], 'string', '*', 'edgecolor', 'none', ...
            'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'left','Interpreter','none');

    end
end
%%
savefig(fig,fullfile(output_dir, ['figure_corr_zmap_combat',char(num2str(iCOMBAT)),'_smooth',num2str(smoothKernel),'_null_permut.fig']));
set(fig, 'PaperPositionMode', 'auto')
print(fig, '-djpeg', '-r1200', fullfile(output_dir, ['figure_corr_zmap_combat',char(num2str(iCOMBAT)),'_smooth',num2str(smoothKernel),'null_permut.jpg']))
end