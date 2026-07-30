function figure_covariates(config)
if nargin < 1 || isempty(config)
    config = 'config_hpc.json';
end
close all
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

% Load the confound data that has been pre-processed
load(fullfile(plot_data_dir, 'confound_combine.mat'), 'ptoplot', 'pvals_bonf','contoplot', 'nSiteToPlot');

% Transpose data to match expected format for plotting
contoplot = contoplot';
nCovar = height(contoplot);  % Number of confound variables
ptoplot = ptoplot';
pvals_bonf = pvals_bonf';
thres = 0.05; % Significance threshold for plotting
nSiteToPlot = nSiteToPlot';  % Number of sites
nSiteRange = [min(nSiteToPlot(nSiteToPlot > 0), [], 'all'):max(nSiteToPlot, [], 'all')]; % Range of sites
diagnosisString = {'BD', 'SCA', 'SCZ', 'ASD', 'MDD', 'AD'};  % List of diagnoses
diagnosisStr = {'Bipolar', 'Schizoaffective',...
    'Schizophrenia', 'Autism', 'Depression','Alzheimer' };
nDiag = length(diagnosisString);  % Number of diagnoses
conName = {'mean age', 'var age', 'male', 'female', 'sex ratio', ...
    'cases', 'controls', 'subjects', 'case control ratio', 'treatment', ...
    'mean IQR', 'var IQR', 'mean age onset', 'var age onset', ...
    'mean illness duration', 'var illness duration', ...
    'scanner brand', 'scanner model', 'voxel size'};  % List of confound names
plotorder = [6 3 2 4 5 1]; % change the order of disorder appear in the plot

% Set default color scheme
colorDefault = colororder('gem');
colorDefault(6,:) = [0.5 0.5 0.5];

% Set font and figure properties for the plot
font_name = 'Arial';
font_size = 12;
fontsize_legend = 10;

% Create a figure with specified dimensions
fig = figure('Position', [200 200 1200 800]);
set(fig, 'color', 'w');
factorX = 1.1;  % Scaling factor for X-axis
factorY = 1.7;  % Scaling factor for Y-axis
initX = 0.15;  % Initial X position of first subplot
initY = 0.1;  % Initial Y position of first subplot
numRow = 1;    % Number of rows for subplots
numCol = nDiag; % Number of columns equals the number of diagnoses
lengthX = (0.95 - initX) / (factorX * (numCol - 1) + 1);  % Width of each subplot
lengthY = (0.93 - initY) / (factorY * (numRow - 1) + 1);  % Height of each subplot

% Loop through each diagnosis and create bar plots
for iDiag = 1:nDiag
    iData = plotorder(iDiag); % the order in the data

    % Define position for the subplot in the figure
    ax1 = axes('Position', [initX + factorX * lengthX * (iDiag - 1), initY, lengthX, lengthY]);

    % Create the bar plot for this diagnosis's confounds
    barplot = bar(ax1, 1:nCovar, contoplot(:, iData), 'EdgeColor', colorDefault(iData, :), 'FaceColor', colorDefault(iData, :));
    xticks(ax1, [1:nCovar]);  % Set X-axis tick positions
    xticklabels(ax1, conName);  % Set X-axis tick labels
    yticks(ax1,[-1 -0.5 0 0.5 1])
    set(ax1, 'box', 'off', 'TickLabelInterpreter', 'none');  % Remove box and set tick label interpreter
    grid off  % Turn off grid

    % Set Y-axis label for this plot based on the diagnosis
    ylabel(diagnosisStr{iData});
    ylim([-1 1]);  % Set Y-axis limits

    % Customize plot direction and appearance
    set(ax1, 'ydir', 'reverse');  % Reverse the Y-axis direction
    set(ax1, 'xdir', 'reverse');  % Reverse the X-axis direction
    set(ax1, 'XAxisLocation', 'top','FontSize',fontsize_legend);  % Place X-axis on top
    if iDiag ~= 1
        set(ax1, 'XColor', 'none','FontSize',fontsize_legend);  % Remove X-axis color for all but the first plot
    end
    camroll(ax1, 90);  % Rotate the plot by 90 degrees for better visibility

    % Add significance markers for p-values less than threshold
    xtips1 = barplot.XEndPoints + 0.2;  % X position for significance markers
    xtips2 = barplot.XEndPoints+0.7;
    ytips1 = barplot.YEndPoints;  % Y position for significance markers
    ytips2 = barplot.YEndPoints;
    sigMark = cell(1, size(ptoplot, 1));  % Initialize cell array for significance markers
    sigCorrectedMark = cell(1,size(pvals_bonf,1));
    for i = 1:size(ptoplot, 1)
        % if ptoplot(i, iData) <= thres && ptoplot(i, iData) > 0  % Check if p-value is significant
        %     sigMark{i} = '*';  % Mark as significant
        %     if ytips1(i) < 0
        %         ytips1(i) = ytips1(i) - 0.1;  % Adjust Y position for negative values
        %     else
        %         ytips1(i) = ytips1(i) + 0.1;  % Adjust Y position for positive values
        %     end
        % end
        if pvals_bonf(i,iData)<=thres & pvals_bonf(i,iData)>0
            sigCorrectedMark{i}='*';
            if ytips2(i)<0
                ytips2(i) = ytips2(i)-0.1;
            else
                ytips2(i) = ytips2(i)+0.1;
            end
        end
    end
    % Place significance markers on the plot
    text(ax1, xtips1, ytips1, sigMark, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
    text(ax1,xtips2,ytips2,sigCorrectedMark,'HorizontalAlignment','center',...
        'VerticalAlignment','bottom')
    clear sigMark  sigCorrectedMark % Clear temporary variable for significance markers
end

% Add annotation for the entire figure
a1 = annotation(fig, 'textbox', [0 0.01 1, 0.02], 'string', 'Correlation', 'edgecolor', 'none', ...
    'FontName', font_name, 'FontSize', font_size, 'horizontalalignment', 'center');

%% Save figure
% Uncomment the following lines to save the figure as a .fig and .jpg file
savefig(fig, fullfile(output_dir, 'confoundVBM.fig'));
set(fig, 'PaperPositionMode', 'auto')
print(fig, '-djpeg', '-r600', fullfile(output_dir, 'confoundVBM.jpg'));
end
