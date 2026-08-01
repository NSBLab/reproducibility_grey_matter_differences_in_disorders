function figure_corr_zmap_subdivide_2sitegroup_samesize_combine_sub(config)
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

smoothKernel = 10;
diaglist = 2:7;
hemis = 'lh';
diagString = {'Bipolar', 'Schizoaffective',...
    'Schizophrenia', 'Autism', 'Depression','Alzheimer' };
plotorder = [6 3 2 4 5 1]; % change the order of disorder appear in the plot

sampleSizeList = [10    16    25    40    63   100   158   251   398 631];
colorVec = {[225 232 255], [205 217 255], [185 202 255], [165 186 255], [145 171 255], [0.5 0.5 0.5], [115 148 255], [85 125 255], [55 103 255],[5 65 255],[0 48 200],[0 36 150],[0 24 100] };
colorpalette = colororder('gem');
colorpalette(6,:) = [0.5 0.5 0.5];

nSize = length(sampleSizeList);
fig = figure('Position', [200 200 1200 1100]);
set(fig,'color','w');
factorX = 1.2;
factorY = 1.35;
initX = 0.05;
initY = 0.09;
numRow = 4;
numCol = 3;
lengthX = (0.98 - initX)/(factorX*(numCol-1) + 1);
lengthY = (0.95 - initY)/(factorY*(numRow-1) + 1);
lineWidth = 2;

%
font_name = 'Arial';
font_size = 12;
fontsize_legend = 10;


subplotTitle = {'a|','b|','c|','d|','e|','f|','g|','h|','i|'};

for iPlot = 1:12
    iRow = mod(iPlot-1,numRow)
    iCol = floor((iPlot-1)/numRow)
    ax1 = axes('Position', [initX+factorX*lengthX*(iCol), initY+factorY*lengthY*(numRow-iRow-1) lengthX lengthY]);
    switch iPlot
        case 1
            load(fullfile(plot_data_dir, 'corr_zmap_parc_subdivide_2sitegroup_samesize.mat'), 'mediancorDiagDK','varcorDiagDK','sampleSizeListAll');
            medianCor = mediancorDiagDK;
            varCor = varcorDiagDK;
            medianCorDK = medianCor; %dummy value to plot the same length with empty medianCor

        case 2
            load(fullfile(plot_data_dir, 'corr_zmap_parc_subdivide_2sitegroup_samesize.mat'), 'mediancorDiagSF100','varcorDiagSF100','sampleSizeListAll');
            medianCor = mediancorDiagSF100;
            varCor = varcorDiagSF100;
           
        case 3
            load(fullfile(plot_data_dir, 'corr_zmap_parc_subdivide_2sitegroup_samesize.mat'), 'mediancorDiagSF500','varcorDiagSF500','sampleSizeListAll');
            medianCor = mediancorDiagSF500;
            varCor = varcorDiagSF500;
           case 4
            load(fullfile(plot_data_dir, 'corr_zmap_parc_subdivide_2sitegroup_samesize.mat'), 'mediancorDiagSF1000','varcorDiagSF1000','sampleSizeListAll');
            medianCor = mediancorDiagSF1000;
            varCor = varcorDiagSF1000;  
        case 5
             load(fullfile(plot_data_dir, 'corr_zmap_parc_subdivide_2sitegroup_samesize.mat'), 'mediancorSigDK','varcorSigDK','sampleSizeListAll');
            medianCor = mediancorSigDK;
            varCor = varcorSigDK;
        case 6
            load(fullfile(plot_data_dir, 'corr_zmap_parc_subdivide_2sitegroup_samesize.mat'), 'mediancorSigSF100','varcorSigSF100','sampleSizeListAll');
            medianCor = mediancorSigSF100;
            varCor = varcorSigSF100;

        case 7
            load(fullfile(plot_data_dir, 'corr_zmap_parc_subdivide_2sitegroup_samesize.mat'), 'mediancorSigSF500','varcorSigSF500','sampleSizeListAll');
            medianCor = mediancorSigSF500;
            varCor = varcorSigSF500;
        case 8
            load(fullfile(plot_data_dir, 'corr_zmap_parc_subdivide_2sitegroup_samesize.mat'), 'mediancorSigSF1000','varcorSigSF1000','sampleSizeListAll');
            medianCor = mediancorSigSF1000;
            varCor = varcorSigSF1000;    
        case 9
            load(fullfile(plot_data_dir, 'corr_zmap_parc_subdivide_2sitegroup_samesize.mat'), 'medianrepSigDK','varrepSigDK','sampleSizeListAll');
            medianCor = medianrepSigDK;
            varCor = varrepSigDK;
        case 10
            load(fullfile(plot_data_dir, 'corr_zmap_parc_subdivide_2sitegroup_samesize.mat'), 'medianrepSigSF100','varrepSigSF100','sampleSizeListAll');
            medianCor = medianrepSigSF100;
            varCor = varrepSigSF100;
        case 11
            load(fullfile(plot_data_dir, 'corr_zmap_parc_subdivide_2sitegroup_samesize.mat'), 'medianrepSigSF500','varrepSigSF500','sampleSizeListAll');
            medianCor = medianrepSigSF500;
            varCor = varrepSigSF500;
            
        
        case 12
            load(fullfile(plot_data_dir, 'corr_zmap_parc_subdivide_2sitegroup_samesize.mat'), 'medianrepSigSF1000','varrepSigSF1000','sampleSizeListAll');
            medianCor = medianrepSigSF1000;
            varCor = varrepSigSF1000;
        otherwise
            error('no suitable data')
    end

    for iDiag = 1:length(diaglist)
        iData = plotorder(iDiag); % the order in the data
        diag = diaglist(iData)
  sampleSizeList = sampleSizeListAll{iData};
        lengthToPlot = sum(medianCorDK{iData}~=0);
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



    set(ax1,'box','off')
    set(ax1, 'color','none')
    set(ax1, 'XScale','log')
    xlim([10 600]);
    ylim([-0.1 1]);
if floor((iPlot-1)/numRow) == 0
    ylabel('Correlation')
end
if   floor((iPlot-1)/numRow) == 1
    ylabel('Binary correlation')
end
if   floor((iPlot-1)/numRow)  == 2
    ylabel('Replication')
end
    xlabel({'sample size'})
    % Customize x-axis tick marks
    set(ax1, 'XTick', sampleSizeListAll{3});
    sampleLabel = arrayfun(@(x) char(num2str(x)), sampleSizeListAll{3}, 'UniformOutput', false);
    set(ax1, 'XTickLabel', sampleLabel);
    if iPlot == 8
        plotLegend = legend(h2, diagString(plotorder),'Location','northwest')

        legend('boxoff')
    end
    % a25 = annotation(fig, 'textbox', [ax1.Position(1)-ax1.Position(3)*0.07, ax1.Position(2)+ax1.Position(4)*1.07, 0.02, 0.02], 'string', subplotTitle{iPlot}, 'edgecolor', 'none', ...
    %     'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'center');

end
a25 = annotation(fig, 'textbox', [0.01, 0.98 0.02, 0.02], 'string', 'a|DK', 'edgecolor', 'none', ...
        'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'left');
a25 = annotation(fig, 'textbox', [0.01, 0.73 0.02, 0.02], 'string', 'b|Schaefer-100', 'edgecolor', 'none', ...
        'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'left');
a25 = annotation(fig, 'textbox', [0.01, 0.5 0.02, 0.02], 'string', 'c|Schaefer-500', 'edgecolor', 'none', ...
        'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'left');
a25 = annotation(fig, 'textbox', [0.01, 0.27 0.02, 0.02], 'string', 'd|Schaefer-1000', 'edgecolor', 'none', ...
        'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'left');
%%
savefig(fig,fullfile(output_dir, 'figure_corr_zmap_subdivide_2sitegroup_samesize_combine_sub.fig'));
set(fig, 'PaperPositionMode', 'auto')
print(fig, '-djpeg', '-r1200', fullfile(output_dir, 'figure_corr_zmap_subdivide_2sitegroup_samesize_combine_sub.jpg'))
end