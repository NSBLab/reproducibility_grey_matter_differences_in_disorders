clear all
% Parameters
n_regions = 1000;            % number of brain regions
sample_sizes =  [10    16    25    40    63   100   158   251   398   631];   % range of sample sizes
n_iter = 5;                 % number of iterations
signal_std_list = [0 0.01:0.02:0.1 0.2:0.2:1 2 10];               % standard deviation of noise
colorVec = {[225 232 255], [205 217 255], [185 202 255], [165 186 255], [145 171 255], [115 148 255], [85 125 255], [55 103 255],[5 65 255],[0 48 200],[0 36 150],[0 24 100],[0 16 70] };

% Region-specific effects (same for both studies)
rng(1);  % for reproducibility
C = randn(1, n_regions);  % region-wise independent effects

% Store results
corrs = zeros(length(sample_sizes), n_iter);

fig = figure('Position', [200 200 1800 500]);
set(fig,'color','w');
factorX = 1.2;
factorY = 1.1;
initX = 0.05;
initY = 0.2;
numRow = 1;
numCol = 3;
lengthX = (0.95 - initX)/(factorX*(numCol-1) + 1);
lengthY = (0.9 - initY)/(factorY*(numRow-1) + 1);

font_name = 'Arial';
font_size = 10;
fontsize_legend = 8;

iCol = 1;
ax1 = axes('Position', [initX+factorX*lengthX*(iCol-1), initY lengthX lengthY]);
hold on
load(['output/simulation_signal_noise_Niter_5_samplesizerange_10_631.mat']);
% Plot
for iSignal = 1:length(signal_std_list)

    % errorbar(ax1,sample_sizes, mean_corr{iSignal}, std_corr{iSignal}, 'o-', 'LineWidth', 2,'Color',colorVec{length(colorVec)-length(signal_std_list)+iSignal}./255);
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

        h1 = fill(ax1,[sample_sizes fliplr(sample_sizes)], [upperBound' fliplr(lowerBound')], 'b', 'FaceAlpha', 0.1, 'EdgeColor', 'none','FaceColor',newColor);
        hold on
        % Plot the median line
        h2 = plot(ax1, sample_sizes', mean_corr{iSignal}, 'b', 'LineWidth', 2,'Color',meanColor);


end
xlabel('Sample size');
ylabel('Correlation');
% title('Effect of Sample Size on t-map Correlation (Region-wise Effects)');

set(ax1,'box','off')
set(ax1, 'color','none')
set(ax1, 'XScale','log')
set(ax1, 'XTick', sample_sizes);
set(ax1, 'XTickLabel', sample_sizes);
ylim([-0.1 1]);
% leg = legend(cellstr(num2str(signal_std_list')),'Position',[0.92 0.2 0.05 0.7]);
% legend('boxoff')
% title(leg, 'SNR');

iCol = 2;
ax2 = axes('Position', [initX+factorX*lengthX*(iCol-1), initY lengthX lengthY]);
hold on
load(['output/simulation_signal_noise_Niter_5_samplesizerange_10_10000.mat']);
% Plot
for iSignal = 1:7
    % errorbar(ax2,sample_sizes, mean_corr{iSignal}, std_corr{iSignal}, 'o-', 'LineWidth', 2,'Color',colorVec{length(colorVec)-length(signal_std_list)+iSignal}./255);
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

        h1 = fill(ax2,[sample_sizes fliplr(sample_sizes)], [upperBound' fliplr(lowerBound')], 'b', 'FaceAlpha', 0.1, 'EdgeColor', 'none','FaceColor',newColor);
        hold on
        % Plot the median line
        h2 = plot(ax2, sample_sizes', mean_corr{iSignal}, 'b', 'LineWidth', 2,'Color',meanColor);


end
xlabel('Sample size');
ylabel('Correlation');
% title('Effect of Sample Size on t-map Correlation (Region-wise Effects)');

set(ax2,'box','off')
set(ax2, 'color','none')
set(ax2, 'XScale','log')
set(ax2, 'XTick', sample_sizes);
set(ax2, 'XTickLabel', sample_sizes);
ylim([-0.1 1]);
iCol = 3;
ax3 = axes('Position', [initX+factorX*lengthX*(iCol-1), initY lengthX lengthY]);
hold on
load(['output/simulation_signal_noise_Niter_50_samplesizerange_10_631.mat']);
% Plot
for iSignal = 1:length(signal_std_list)
    % errorbar(ax3,sample_sizes, mean_corr{iSignal}, std_corr{iSignal}, 'o-', 'LineWidth', 2,'Color',colorVec{length(colorVec)-length(signal_std_list)+iSignal}./255);
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

        h1 = fill(ax3,[sample_sizes fliplr(sample_sizes)], [upperBound' fliplr(lowerBound')], 'b', 'FaceAlpha', 0.1, 'EdgeColor', 'none','FaceColor',newColor);
        hold on
        % Plot the median line
        h2 = plot(ax3, sample_sizes', mean_corr{iSignal}, 'b', 'LineWidth', 2,'Color',meanColor);


end
xlabel('Sample size');
ylabel('Correlation');
% title('Effect of Sample Size on t-map Correlation (Region-wise Effects)');

set(ax3,'box','off')
set(ax3, 'color','none')
set(ax3, 'XScale','log')
set(ax3, 'XTick', sample_sizes);
set(ax3, 'XTickLabel', sample_sizes);
ylim([-0.1 1]);
%
a25 = annotation(fig, 'textbox', [0.29, 0.32, 0.05, 0.02], 'string', '0', 'edgecolor', 'none', ...
  'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'left');

a25 = annotation(fig, 'textbox', [0.29, 0.35, 0.05, 0.02], 'string', '0.01', 'edgecolor', 'none', ...
  'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'left');


a25 = annotation(fig, 'textbox', [0.29, 0.46, 0.05, 0.02], 'string', '0.03', 'edgecolor', 'none', ...
  'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'left');

a25 = annotation(fig, 'textbox', [0.29, 0.58, 0.05, 0.02], 'string', '0.05', 'edgecolor', 'none', ...
  'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'left');

a25 = annotation(fig, 'textbox', [0.29, 0.68, 0.05, 0.02], 'string', '0.07', 'edgecolor', 'none', ...
  'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'left');

a25 = annotation(fig, 'textbox', [0.29, 0.75, 0.05, 0.02], 'string', '0.09', 'edgecolor', 'none', ...
  'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'left');

a25 = annotation(fig, 'textbox', [0.29, 0.86, 0.05, 0.02], 'string', '0.2', 'edgecolor', 'none', ...
  'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'left');


a25 = annotation(fig, 'arrow', [0.13, 0.16], [0.7, 0.96]);

a25 = annotation(fig, 'textbox', [0.16, 0.95, 0.3, 0.02], 'string', 'SNR=\{0.4, 0.6, 0.8, 1, 2, 10\}', 'edgecolor', 'none', ...
  'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'left');
%
a25 = annotation(fig, 'textbox', [0.63, 0.34, 0.05, 0.02], 'string', '0', 'edgecolor', 'none', ...
  'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'left');

a25 = annotation(fig, 'textbox', [0.63, 0.52, 0.05, 0.02], 'string', '0.01', 'edgecolor', 'none', ...
  'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'left');

a25 = annotation(fig, 'textbox', [0.63, 0.8, 0.05, 0.02], 'string', '0.03', 'edgecolor', 'none', ...
  'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'left');

a25 = annotation(fig, 'textbox', [0.63, 0.85, 0.05, 0.02], 'string', '0.05', 'edgecolor', 'none', ...
  'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'left');

a25 = annotation(fig, 'textbox', [0.63, 0.88, 0.05, 0.02], 'string', '0.07', 'edgecolor', 'none', ...
  'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'left');

a25 = annotation(fig, 'textbox', [0.63, 0.91, 0.05, 0.02], 'string', '0.09', 'edgecolor', 'none', ...
  'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'left');

a25 = annotation(fig, 'textbox', [0.63, 0.94, 0.05, 0.02], 'string', '0.2', 'edgecolor', 'none', ...
'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'left');

%
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


a25 = annotation(fig, 'arrow', [0.75, 0.77], [0.66, 0.934]);

a25 = annotation(fig, 'textbox', [0.77, 0.95, 0.3, 0.02], 'string', 'SNR=\{0.4, 0.6, 0.8, 1, 2, 10\}', 'edgecolor', 'none', ...
  'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'left');

%%
a25 = annotation(fig, 'textbox', [0.001, 0.99, 0.2, 0.02], 'string', 'a|5 iterations, 1000 voxels', 'edgecolor', 'none', ...
    'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'left');

  a25 = annotation(fig, 'textbox', [0.33, 0.99, 0.2, 0.02], 'string', 'b|5 iterations, 1000 voxels', 'edgecolor', 'none', ...
    'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'left');

  a25 = annotation(fig, 'textbox', [0.66, 0.99, 0.2, 0.02], 'string', 'c|50 iterations, 1000 voxels', 'edgecolor', 'none', ...
    'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'left');
  
 %%
    savefig(fig,['output/figure_simulation_signal_noise.fig']);
    set(fig, 'PaperPositionMode', 'auto')
    print(fig, '-djpeg', '-r1200', 'output/figure_simulation_signal_noise.jpg')