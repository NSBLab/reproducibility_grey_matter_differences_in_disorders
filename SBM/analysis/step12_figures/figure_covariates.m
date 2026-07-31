function figure_covariates(config)
% plot confound
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

load(fullfile(plot_data_dir, 'SBM_covariates_combine.mat'), 'ptoplot','pvals_bonf','contoplot','nSiteToPlot');
contoplot = contoplot';
nCovar = height(contoplot);
ptoplot = ptoplot';
pvals_bonf = pvals_bonf';
thres=0.05;
nSiteToPlot=nSiteToPlot';
nSiteRange = [min(nSiteToPlot(nSiteToPlot>0),[],'all'):max(nSiteToPlot,[],'all')];
diagnosisString = {'BD', 'SCA',...
    'SCZ', 'ASD', 'MDD','AD' };
diagnosisStr = {'Bipolar', 'Schizoaffective',...
    'Schizophrenia', 'Autism', 'Depression','Alzheimer' };
nDiag = length(diagnosisString);
conName = {'mean age','var age','male','female','sex ratio','cases','controls','subjects','case control ratio','treatment','mean EN','var EN','mean age onset','var age onset','mean illness duration','var illness duration','scanner brand','scanner model','voxel size'};
plotorder = [6 3 2 4 5 1]; % change the order of disorder appear in the plot

colorDefault = colororder('gem');
colorDefault(6,:) = [0.5 0.5 0.5];

font_name = 'Arial';
font_size = 12;
fontsize_legend = 10;

fig = figure('Position', [200 200 1200 800]);
set(fig,'color','w');
factorX = 1.1;
factorY = 1.7;
initX = 0.15;
initY = 0.1;
numRow = 1;
numCol = nDiag;
lengthX = (0.95 - initX)/(factorX*(numCol-1) + 1);
lengthY = (0.93 - initY)/(factorY*(numRow-1) + 1);

swapin = [1 2 3 4 5 6];
for iDiag = 1:nDiag
    iData = plotorder(iDiag); % the order in the data

 ax1 = axes('Position', [initX+factorX*lengthX*(iDiag-1), initY lengthX lengthY]);
   
barplot = bar(ax1,1:nCovar,contoplot(:,iData),'EdgeColor',colorDefault(iData,:),'FaceColor',colorDefault(iData,:));

xticks(ax1,[1:nCovar])
xticklabels(ax1,conName);
yticks(ax1,[-1 -0.5 0 0.5 1])
% yticklabels(ax1,arrayfun(@(x) num2str(x),[1:nSite],'UniformOutput',false));
set(ax1,'box','off','TickLabelInterpreter', 'none')
grid off
% ax1.YGrid='on'


% legend(diagnosisString,'Location','best')
ylabel(diagnosisStr(iData))
ylim([-1 1])

set ( ax1, 'ydir', 'reverse' )
set ( ax1, 'xdir', 'reverse' )
set(ax1,'XAxisLocation','top','FontSize',fontsize_legend)
if iDiag~=1
set(ax1,'XColor','none','FontSize',fontsize_legend )
end
camroll(ax1,90)

%%


    xtips1 = barplot.XEndPoints+0.2;
    xtips2 = barplot.XEndPoints+0.7;
    ytips1 = barplot.YEndPoints;
    ytips2 = barplot.YEndPoints;
    sigMark = cell(1,size(ptoplot,1));
    sigCorrectedMark = cell(1,size(pvals_bonf,1));
    for i=1:size(ptoplot,1)
        % if ptoplot(i,iData)<=thres & ptoplot(i,iData)>0
        %     sigMark{i}='*';
        %     if ytips1(i)<0
        %         ytips1(i) = ytips1(i)-0.1;
        %     else
        %         ytips1(i) = ytips1(i)+0.1;
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
    text(ax1,xtips1,ytips1,sigMark,'HorizontalAlignment','center',...
        'VerticalAlignment','bottom')
    text(ax1,xtips2,ytips2,sigCorrectedMark,'HorizontalAlignment','center',...
        'VerticalAlignment','bottom')
    clear sigMark sigCorrectedMark


end

a1 = annotation(fig, 'textbox', [0 0.01 1, 0.02], 'string', 'Correlation', 'edgecolor', 'none', ...
        'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'center');

%%
savefig(fig,fullfile(output_dir,'confoundSVM.fig'));
set(fig, 'PaperPositionMode', 'auto')
print(fig, '-djpeg', '-r600', fullfile(output_dir, 'confoundSVM.jpg'))
end