clear all
close all

smoothKernel = 10;
diaglist = 2:7;
hemis = 'lh';

addpath(genpath('/projects/kg98/trangc/VBM/code'))

sampleSizeList = [10    16    25    40    63   100   158   251   398   631];
colorVec = {[225 232 255], [205 217 255], [185 202 255], [165 186 255], [145 171 255], [115 148 255], [85 125 255], [55 103 255],[5 65 255],[0 48 200],[0 36 150],[0 24 100] };


meanCor = zeros(length(diaglist),length(sampleSizeList));
varCor = zeros(length(diaglist),length(sampleSizeList));
for iDiag = 1:length(diaglist)
    diag = diaglist(iDiag)
 %
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

    for isampleSize = 1:length(sampleSizeList);

        sampleSize = sampleSizeList(isampleSize);


       

        %
        dividemode = ['splitsite_samesize_',char(num2str(sampleSize))];
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
        if exist('corDivi','var')
            meanCor(iDiag,isampleSize) = mean(corDivi);
            varCor(iDiag,isampleSize) = var(corDivi);
            [fi xi]=ksdensity(corDivi,'function','pdf');

            denPlot(isampleSize) = plot(ax2, xi, fi, 'LineWidth', lineWidth,'Color',colorVec{isampleSize}./255);
            hold on
            clear corDivi
        end

    end
arrayfun(@(x) num2str(x),sampleSizeList,'UniformOutput',false)
set(ax2,'box','off')
set(ax2, 'color','none')
xlim([-1 1]);
ylim([0 30]);
plotLegend = legend(denPlot, arrayfun(@(x) num2str(x),sampleSizeList,'UniformOutput',false),'Location','best')

ylabel('correlation')
xlabel({'sample size'})
legend('boxoff')


end


