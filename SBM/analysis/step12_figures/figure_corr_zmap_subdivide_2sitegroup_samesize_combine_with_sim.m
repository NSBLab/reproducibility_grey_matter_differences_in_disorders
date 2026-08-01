function figure_corr_zmap_subdivide_2sitegroup_samesize_combine_with_sim(config)
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
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

smoothKernel = 10;
diaglist = 2:7;
hemis = 'lh';
diagString = {'Bipolar', 'Schizoaffective',...
    'Schizophrenia', 'Autism', 'Depression','Alzheimer' };
plotorder = [6 3 2 4 5 1]; % change the order of disorder appear in the plot

sampleSizeList = [10    16    25    40    63   100   158   251   398   631];
colorVec = {[225 232 255], [205 217 255], [185 202 255], [165 186 255], [145 171 255], [115 148 255], [85 125 255], [55 103 255],[5 65 255],[0 48 200],[0 36 150],[0 24 100],[0 16 70] };
colorpalette = colororder('gem');
colorpalette(6,:) = [0.5 0.5 0.5];

nSize = length(sampleSizeList);
fig = figure('Position', [200 200 1200 500]);
set(fig,'color','w');
factorX = 1.2;
factorY = 1.1;
initX = 0.05;
initY = 0.2;
numRow = 1;
numCol = 2;
lengthX = (0.95 - initX)/(factorX*(numCol-1) + 1);
lengthY = (0.9 - initY)/(factorY*(numRow-1) + 1);
lineWidth = 2;

%
font_name = 'Arial';
font_size = 12;
fontsize_legend = 10;


subplotTitle = {'a|','b|','c|','d|','e|','f|'};

    iCol = 1;

    ax1 = axes('Position', [initX+factorX*lengthX*(iCol-1), initY lengthX lengthY]);

            load(fullfile(plot_data_dir, 'corr_zmap_subdivide_2sitegroup_samesize.mat'), 'medianCor','varCor','sampleSizeListAll');
            medianCor = medianCor;
            varCor = varCor;
 

    for iDiag = 1:length(diaglist)
        iData = plotorder(iDiag); % the order in the data
        diag = diaglist(iData);
        increaseCor{iData} = medianCor{iData}./medianCor{iData}(1);

        sampleSizeList = sampleSizeListAll{iData};
        lengthToPlot = sum(medianCor{iData}~=0);
        % Compute the upper and lower bounds for the shaded region
        upperBound = medianCor{iData}(1:lengthToPlot) + sqrt(varCor{iData}(1:lengthToPlot));
        lowerBound = medianCor{iData}(1:lengthToPlot) - sqrt(varCor{iData}(1:lengthToPlot));

        sampleSizetoPlot = sampleSizeListAll{iData}(1:lengthToPlot);
        % Shaded area for variance
        newColor = colorpalette(iData,:);
        colorfactor = 1.1;
        for i=1:3
            newColor(i) = colorpalette(iData,i)*colorfactor*(colorpalette(iData,i).*colorfactor<=1)+ colorpalette(iData,i)*(colorpalette(iData,i).*colorfactor>1);
        end

        h1 = fill(ax1,[sampleSizetoPlot fliplr(sampleSizetoPlot)], [upperBound fliplr(lowerBound)], 'b', 'FaceAlpha', 0.1, 'EdgeColor', 'none','FaceColor',newColor);
        hold on
        % Plot the median line
        h2(iDiag) = plot(ax1, sampleSizetoPlot, medianCor{iData}(1:lengthToPlot), 'b', 'LineWidth', 2,'Color',colorpalette(iData,:));



    end

    %  increaseCor{3}(7:8)
    % increaseCor{5}(7)
    % increaseCor{6}(6)
    set(ax1,'box','off')
    set(ax1, 'color','none')
    set(ax1, 'XScale','log')
    xlim([10 600]);
    ylim([-0.1 1]);

    % if mod(iPlot,numCol) == 0
        ylabel('Correlation','FontSize',font_size)
    % end
    % if  mod(iPlot,numCol) == 2
    %     ylabel('Binary correlation')
    % end
    % if  mod(iPlot,numCol) == 0
    %     ylabel('Replication')
    % end
    xlabel({'Sample size'},'FontSize',font_size)
    % Customize x-axis tick marks
    set(ax1, 'XTick', sampleSizeListAll{3});
    sampleLabel = arrayfun(@(x) char(num2str(x)), sampleSizeListAll{3}, 'UniformOutput', false);
    set(ax1, 'XTickLabel', sampleLabel,'FontSize',fontsize_legend);
    % if iPlot == 1
        plotLegend = legend(h2, diagString(plotorder),'Location','northwest','FontSize',font_size);

        legend('boxoff')
    % end

% end

iCol = 2;
ax4 = axes('Position', [initX+factorX*lengthX*(iCol-1), initY lengthX lengthY]);
hold on
load(fullfile(plot_data_dir, 'simulation_signal_noise_Niter_5_samplesizerange_10_631_100kVoxel_mean.mat'));
% Plot
for iSignal = 1:length(signal_std_list)
    
    % errorbar(ax4,sample_sizes, mean_corr{iSignal}, std_corr{iSignal}, 'o-', 'LineWidth', 2,'Color',colorVec{length(colorVec)-length(signal_std_list)+iSignal}./255);

% Compute the upper and lower bounds for the shaded region
        upperBound = mean_corr{iSignal} + sqrt(var_corr{iSignal});
        lowerBound = mean_corr{iSignal} - sqrt(var_corr{iSignal});


        % Shaded area for variance
        meanColor = colorVec{length(colorVec)-length(signal_std_list)+iSignal}./255;
        newColor = meanColor;
        colorfactor = 1.1;
        for i=1:3
            newColor(i) = meanColor(i)*colorfactor*(meanColor(i).*colorfactor<=1)+ meanColor(i)*(meanColor(i).*colorfactor>1);
        end

        h1 = fill(ax4,[sample_sizes fliplr(sample_sizes)], [upperBound' fliplr(lowerBound')], 'b', 'FaceAlpha', 0.1, 'EdgeColor', 'none','FaceColor',newColor);
        hold on
        % Plot the median line
        h2(iDiag) = plot(ax4, sample_sizes', mean_corr{iSignal}, 'b', 'LineWidth', 2,'Color',meanColor);







end
xlabel('Sample size');
ylabel('Correlation');
% title('Effect of Sample Size on t-map Correlation (Region-wise Effects)');
ylim([-0.1 1]);
set(ax4,'box','off')
set(ax4, 'color','none')
set(ax4, 'XScale','log')
set(ax4, 'XTick', sample_sizes);
set(ax4, 'XTickLabel', sample_sizes);

a25 = annotation(fig, 'textbox', [0.925, 0.26, 0.05, 0.02], 'string', '0', 'edgecolor', 'none', ...
  'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'left');

a25 = annotation(fig, 'textbox', [0.925, 0.3, 0.05, 0.02], 'string', '0.01', 'edgecolor', 'none', ...
  'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'left');

a25 = annotation(fig, 'textbox', [0.925, 0.41, 0.05, 0.02], 'string', '0.03', 'edgecolor', 'none', ...
  'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'left');

a25 = annotation(fig, 'textbox', [0.925, 0.55, 0.05, 0.02], 'string', '0.05', 'edgecolor', 'none', ...
  'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'left');

a25 = annotation(fig, 'textbox', [0.925, 0.66, 0.05, 0.02], 'string', '0.07', 'edgecolor', 'none', ...
  'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'left');

a25 = annotation(fig, 'textbox', [0.925, 0.73, 0.05, 0.02], 'string', '0.09', 'edgecolor', 'none', ...
  'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'left');

a25 = annotation(fig, 'textbox', [0.925, 0.86, 0.05, 0.02], 'string', '0.2', 'edgecolor', 'none', ...
  'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'left');


a25 = annotation(fig, 'arrow', [0.71, 0.77], [0.754, 0.934]);

a25 = annotation(fig, 'textbox', [0.77, 0.95, 0.3, 0.02], 'string', 'SNR={0.4, 0.6, 0.8, 1, 2, 10}', 'edgecolor', 'none', ...
  'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'left');

a25 = annotation(fig, 'textbox', [0.01, 0.99, 0.2, 0.02], 'string', 'a|Bootstrap analysis', 'edgecolor', 'none', ...
   'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'left');

a25 = annotation(fig, 'textbox', [0.5, 0.99, 0.1, 0.02], 'string', 'b|Simulation', 'edgecolor', 'none', ...
  'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'left');

% leg = legend(cellstr(num2str(signal_std_list')),'Position',[0.92 0.2 0.05 0.7],'FontSize',font_size);
% legend('boxoff')
% title(leg, 'SNR');

savefig(fig,fullfile(output_dir, 'figure_corr_zmap_subdivide_2sitegroup_samesize_combine.fig'));
set(fig, 'PaperPositionMode', 'auto')
print(fig, '-djpeg', '-r1200', fullfile(output_dir, 'figure_corr_zmap_subdivide_2sitegroup_samesize_combine.jpg'))
end