clear all
% close all

smoothKernel = 10;
% diag = 4;
hemis = 'lh';
dividemode = 'splitsite';

addpath(genpath('/projects/kg98/trangc/VBM/code'))

sampleSizeList = [20 40 60 80 100 200 300 400 500];
colorVec = {[225 232 255], [205 217 255], [185 202 255], [165 186 255], [145 171 255], [115 148 255], [85 125 255], [55 103 255],[5 65 255],[0 48 200],[0 36 150],[0 24 100] };

nSize = length(sampleSizeList);
fig = figure('Position', [200 200 700 500]);
set(fig,'color','w');
factor_x = 1.2;
factor_y = 1.5;
init_x = 0.1;
init_y = 0.2;
num_row = 1;
num_col = 1;
length_x = (0.82 - init_x)/(factor_x*(num_col-1) + 1);
length_y = (0.95 - init_y)/(factor_y*(num_row-1) + 1);
lineWidth = 2;
%
font_name = 'Arial';
font_size = 10;
fontsize_legend = 8;
ax2 = axes('Position', [init_x, init_y length_x length_y]);

%load vtk surface
filename_vtk = 'fsaverage_164k_midthickness-lh.vtk';
[vertices,faces] = read_vtk(filename_vtk);
vertices = vertices';
faces = faces';

for diag = 2:7
    dataDir = fullfile('/scratch','kg98','trangc','VBM','data', 'derivatives', 'freesurfer',['s',num2str(smoothKernel),'noCOMBAT'],['diag',num2str(diag)],hemis, ['resample_2sitegroup_',dividemode]);

    subdivideList = dir(dataDir);
    subdivideList = subdivideList([subdivideList.isdir]); % Keep only directories
    subdivideList = subdivideList(~ismember({subdivideList.name}, {'.', '..'})); % Remove . and ..


    icor=1;
    for iFolder = 1:height(subdivideList)
        %
        if exist(fullfile(dataDir,subdivideList(iFolder).name,'corr_surface.mat'))
            divideMat = load(fullfile(dataDir,subdivideList(iFolder).name,'corr_surface.mat'));

            corDivi(icor) = divideMat.corDiag;
            icor=icor+1;
        end
    end

    [fi xi]=ksdensity(corDivi,'function','pdf');

    denPlot = plot(ax2, xi, fi, 'LineWidth', lineWidth);
    hold on
end


set(ax2,'box','off')
set(ax2, 'color','none')
xlim([-0.4 1]);
ylim([0 25]);
xlabel('correlation')
ylabel({'density'})
plotLegend = legend({'Bipolar', 'Schizoaffective',...
    'Schizophrenia', 'Autism', 'Depression','Alzheimer' },'Location','best')
legend('boxoff')

%%
savefig(fig,['output/figure_corr_zmap_subdivide_2sitegroup_combine_',dividemode,'.fig']);
set(fig, 'PaperPositionMode', 'auto')
print(fig, '-djpeg', '-r1200', ['output/figure_corr_zmap_subdivide_2sitegroup_combine_',dividemode,'.jpg'])