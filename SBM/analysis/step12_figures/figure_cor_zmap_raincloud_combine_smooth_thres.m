function figure_cor_zmap_raincloud_combine_smooth_thres(config)
if nargin < 1 || isempty(config)
    config = 'config_hpc.json';
end
this_dir = fileparts(mfilename('fullpath'));
% Resolve repo root without leaving '..' segments (addpath mishandles those)
repo_root = fileparts(fileparts(fileparts(this_dir)));
addpath(this_dir);
addpath(genpath(fullfile(repo_root, 'utils')));
pipeline_ensure_paths();
repo_root = pipeline_get_repo_root();
if ischar(config) || isstring(config)
    cfg = char(config);
    if exist(cfg, 'file') ~= 2
        cfg = fullfile(repo_root, cfg);
    end
    config = pipeline_load_config(cfg);
end
if isfield(config.data_directories, 'utils') && ~isempty(config.data_directories.utils)
    utils_dir = pipeline_resolve_relative_path(repo_root, config.data_directories.utils);
    addpath(genpath(utils_dir));
end
data_root = config.data_directories.dataset_root;
plot_data_dir = pipeline_resolve_relative_path(repo_root, config.data_directories.data);
output_dir = fullfile(data_root, 'results', 'SBM', 'analysis', 'output');
iCOMBAT = 1;
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
factorX = 1;
factorY = 1.3;
initX = 0.05;
initY = 0.09;
numRow = 4;
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
paralist = [10 15 20];
nPara = length(paralist);
for iPara = 1:nPara

    smoothKernel = paralist(iPara);
    load(fullfile(plot_data_dir, ['corr_zmap_combat',num2str(iCOMBAT),'_smooth',num2str(smoothKernel),'_',hemi,'_all.mat']), 'map','corDiag','corSigHC_P', 'corSigP_HC','repSigHC_P','repSigP_HC',...
        'siteList')
    load(fullfile(plot_data_dir, ['zmap_null_COMBAT1_',hemi,'_smooth',num2str(smoothKernel),'_ver_all.mat']),...
        'corsigmapSurrsHC_PVerAll','corsigmapSurrsP_HCVerAll','repsigmapSurrsHC_PVerAll','repsigmapSurrsP_HCVerAll');

    makeUvalue = 0;
    for iDiag = 1:nDiag
        iData = plotorder(iDiag); % the order in the data

        ids{iDiag}=find(tril(ones(size(corSigHC_P{iData})),-1));
        corToPlot{1+(iPara-1)*8,iDiag} = corSigHC_P{iData}(ids{iDiag});
        corToPlot{2+(iPara-1)*8,iDiag} = corsigmapSurrsHC_PVerAll{iData};

        ids{iDiag}=find(tril(ones(size(corSigP_HC{iData})),-1));
        corToPlot{3+(iPara-1)*8,iDiag} = corSigP_HC{iData}(ids{iDiag});
        corToPlot{4+(iPara-1)*8,iDiag} = corsigmapSurrsP_HCVerAll{iData};

        ids{iDiag}=find(tril(ones(size(repSigHC_P{iData})),-1));
        corToPlot{5+(iPara-1)*8,iDiag} = repSigHC_P{iData}(ids{iDiag});
        corToPlot{6+(iPara-1)*8,iDiag} = repsigmapSurrsHC_PVerAll{iData};

        ids{iDiag}=find(tril(ones(size(repSigP_HC{iData})),-1));
        corToPlot{7+(iPara-1)*8,iDiag} = repSigP_HC{iData}(ids{iDiag});
        corToPlot{8+(iPara-1)*8,iDiag} = repsigmapSurrsP_HCVerAll{iData};

        % ids{iDiag}=find(tril(ones(size(corSigClusterHC_P{iData})),-1));
        % corToPlot{9+(iPara-1)*2,iDiag} = corSigClusterHC_P{iData}(ids{iDiag});
        % corToPlot{10+(iPara-1)*2,iDiag} = corsigClustermapSurrsHC_PVerAll{iData};
        %
        % ids{iDiag}=find(tril(ones(size(corSigClusterP_HC{iData})),-1));
        % corToPlot{11+(iPara-1)*2,iDiag} = corSigClusterP_HC{iData}(ids{iDiag});
        % corToPlot{12+(iPara-1)*2,iDiag} = corsigClustermapSurrsP_HCVerAll{iData};
        %
        % ids{iDiag}=find(tril(ones(size(repSigClusterHC_P{iData})),-1));
        % corToPlot{13+(iPara-1)*2,iDiag} = repSigClusterHC_P{iData}(ids{iDiag});
        % corToPlot{14+(iPara-1)*2,iDiag} = repsigClustermapSurrsHC_PVerAll{iData};
        %
        % ids{iDiag}=find(tril(ones(size(repSigClusterP_HC{iData})),-1));
        % corToPlot{15+(iPara-1)*2,iDiag} = repSigClusterP_HC{iData}(ids{iDiag});
        % corToPlot{16+(iPara-1)*2,iDiag} = repsigClustermapSurrsP_HCVerAll{iData};

        % ids{iDiag}=find(tril(ones(size(corDiag{iDiag})),-1));
        % corToPlot{1+(iPara-1)*2,iDiag} = corDiag{iDiag}(ids{iDiag});
        % corToPlot{2+(iPara-1)*2,iDiag} = corzmapSurrsVerAll{iDiag};

    end
end
paraVarlist = {'corHC_P', 'corP_HC', 'repHC_P' , 'repP_HC' };
nParaVar = length(paraVarlist);

for iPara = 1:nPara
    for iDiag = 1:nDiag
        for iParaVar = 1:nParaVar
            1+(iParaVar-1)*2+(iPara-1)*8
            % Extract empirical median
            empiricalMedian = median(corToPlot{1+(iParaVar-1)*2+(iPara-1)*8, iDiag});
            nullMedian = median(corToPlot{2+(iParaVar-1)*2+(iPara-1)*8, iDiag});

            % Calculate percentile (i.e., proportion of null values less than or equal to empirical median)
            p_value(iPara,iParaVar,iDiag) = mean(abs(empiricalMedian - nullMedian  ) <= abs(corToPlot{2+(iParaVar-1)*2+(iPara-1)*8, iDiag}-nullMedian));

        end
    end

end

% fprintf('%.5f, ', prs);
% fprintf('%.5f, ', hrs);
% make colormap
C = repmat([darkblue; lightblue],nPara,1);

ViolinColor = {repmat(C,ceil(size(corToPlot,2)/length(C)),1)};


for iRow = 1:numRow
    ax2 = axes('Position', [initX, initY+factorY*lengthY*(numRow-iRow) lengthX lengthY]);
    idx = reshape(bsxfun(@plus, (0:8:24-2)'+(iRow-1)*2, [1 2])',1,[])  % generate index pairs
    violinplot_subclass(corToPlot(idx,:), diagnosisStr(plotorder),'ViolinColor',ViolinColor,'BoxColor',[0 0 0],'BoxWidth',0.07);

  
    set(ax2,'FontSize',fontsize_legend)
    if  iRow <= 2

        ylabel('binary correlation','FontSize',fontsize_legend)
    else
        ylabel('replication','FontSize',fontsize_legend)
    end
    set(ax2,'box','off')
    tempXlim = xlim;
    tempYlim = [-0.5 1];
    dummyplot1 = scatter(ax2,[-1],[-1],'marker','o','MarkerEdgeColor',darkblue,'MarkerFaceColor',darkblue);
    dummyplot2 = scatter(ax2,[-1],[-1],'marker','o','MarkerEdgeColor',lightblue,'MarkerFaceColor',lightblue);
    if iRow == 1
        legend([dummyplot1,dummyplot2],{'Observed','Null'},'Location','southeast')
        legend('boxoff')
    end
    xlim([0 tempXlim(2)])
    ylim(tempYlim)


    for iPara = 1:nPara
        for iDiag = 1:nDiag
            if p_value(iPara,iRow,iDiag) <= thres
                a17 = annotation(fig, 'textbox', [ax2.Position(1)+ax2.Position(3)*(0.03+(iPara-1)*0.045+(iDiag-1)*0.155), ax2.Position(2)+ax2.Position(4)*0.9, 0.09, 0.02], 'string', '*', 'edgecolor', 'none', ...
                    'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'left','Interpreter','none');
            end
        end
    end
    % mean and range
    medCor =  cellfun(@(x) median(x), corToPlot);
    minCor = cellfun(@(x) min(x), corToPlot);
    maxCor = cellfun(@(x) max(x), corToPlot);

if iRow == 1
    % Convert data coordinates to normalized figure units
    x = [ax2.Position(1)+ax2.Position(3)*0.02, ax2.Position(1)+ax2.Position(3)*0.05];  % normalized horizontal range (0 to 1)
    y = ax2.Position(2)+ax2.Position(4)*0.25;        % normalized vertical location

    % Draw three lines to make the bracket
    annotation('line', [x(1) x(1)], [y y+0.01], 'Color', 'k', 'LineWidth', 1);
    ax3= annotation('line', [x(1) x(2)], [y y], 'Color', 'k', 'LineWidth', 1);
    annotation('line', [x(2) x(2)], [y+0.01 y], 'Color', 'k', 'LineWidth', 1);
    a17 = annotation(fig, 'textbox', [ax3.Position(1)-0.01, ax3.Position(2), 0.1, ax3.Position(4)], 'string', [char(num2str(paralist(1))),' mm'], 'edgecolor', 'none', ...
        'FontName',font_name,'FontSize',fontsize_legend,  'horizontalalignment', 'left');

    % Convert data coordinates to normalized figure units
    x = [ax2.Position(1)+ax2.Position(3)*(0.07), ax2.Position(1)+ax2.Position(3)*(0.1)];  % normalized horizontal range (0 to 1)
    y = ax2.Position(2)+ax2.Position(4)*0.18;        % normalized vertical location

    % Draw three lines to make the bracket
    annotation('line', [x(1) x(1)], [y y+0.01], 'Color', 'k', 'LineWidth', 1);
    ax4 = annotation('line', [x(1) x(2)], [y y], 'Color', 'k', 'LineWidth', 1);
    annotation('line', [x(2) x(2)], [y+0.01 y], 'Color', 'k', 'LineWidth', 1);
    a17 = annotation(fig, 'textbox', [ax4.Position(1)-0.01, ax4.Position(2), 0.1, ax4.Position(4)], 'string', [char(num2str(paralist(2))),' mm'], 'edgecolor', 'none', ...
        'FontName',font_name,'FontSize',fontsize_legend,  'horizontalalignment', 'left');

    % Convert data coordinates to normalized figure units
    x = [ax2.Position(1)+ax2.Position(3)*(0.11), ax2.Position(1)+ax2.Position(3)*(0.14)];  % normalized horizontal range (0 to 1)
    y = ax2.Position(2)+ax2.Position(4)*0.99;        % normalized vertical location

    % Draw three lines to make the bracket
    annotation('line', [x(1) x(1)], [y y+0.01], 'Color', 'k', 'LineWidth', 1);
    ax4 = annotation('line', [x(1) x(2)], [y+0.01 y+0.01], 'Color', 'k', 'LineWidth', 1);
    annotation('line', [x(2) x(2)], [y+0.01 y], 'Color', 'k', 'LineWidth', 1);
    a17 = annotation(fig, 'textbox', [ax4.Position(1)-0.01, ax4.Position(2)+0.02, 0.1, ax4.Position(4)], 'string', [char(num2str(paralist(3))),' mm'], 'edgecolor', 'none', ...
        'FontName',font_name,'FontSize',fontsize_legend,  'horizontalalignment', 'left');
end
end

a25 = annotation(fig, 'textbox', [0.01, 0.96, 0.2, 0.02], 'string', 'a|Controls > cases', 'edgecolor', 'none', ...
    'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'left');

a26 = annotation(fig, 'textbox', [0.01, 0.72, 0.2, 0.02], 'string', 'b|Controls < cases', 'edgecolor', 'none', ...
    'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'left');

a25 = annotation(fig, 'textbox', [0.01, 0.5, 0.2, 0.02], 'string', 'c|Controls > cases', 'edgecolor', 'none', ...
    'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'left');

a26 = annotation(fig, 'textbox', [0.01, 0.27, 0.2, 0.02], 'string', 'd|Controls < cases', 'edgecolor', 'none', ...
    'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'left');
%%
savefig(fig,fullfile(output_dir, ['figure_corr_zmap_combat',char(num2str(iCOMBAT)),'_smooth',num2str(smoothKernel),'_smooth_thres_combine.fig']));
set(fig, 'PaperPositionMode', 'auto')
print(fig, '-djpeg', '-r1200', fullfile(output_dir, ['figure_corr_zmap_combat',char(num2str(iCOMBAT)),'_smooth',num2str(smoothKernel),'_smooth_thres_combine.jpg']))
end
