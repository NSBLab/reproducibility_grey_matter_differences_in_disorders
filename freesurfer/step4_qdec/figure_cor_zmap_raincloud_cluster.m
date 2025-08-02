clear all
close all
addpath('/home/trangc/kg98/trangc/library/Violinplot-Matlab-master')
addpath(genpath('/projects/kg98/trangc/VBM/code'))
iCOMBAT = 1;
smoothKernel = 10;
hemi = 'lh';


diagnosisString = {'BD', 'SCA',...
    'SCZ', 'ASD', 'MDD','AD' };
diagnosisStr = {'Bipolar', 'Schizoaffective',...
    'Schizophrenia', 'Autism', 'Depression','Alzheimer' };
nDiag = length(diagnosisString);



darkblue = [10/255 52/255 204/255];
gray = [0.5 0.5 0.5];
lightorange =  [124/255 125/255 117/255];%[255/255 211/255 147/255];%[0.75 0.5 0.25];
darkorange = [242/255 144/255 0];%[0.75 0.25 0.25]; %

fig = figure('Position', [200 200 1200 800]);
set(fig,'color','w');
factorX = 1.1;
factorY = 1.7;
initX = 0.05;
initY = 0.09;
numRow = 4;
numCol = 2;
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
font_size = 10;
fontsize_legend = 8;

%load vtk surface
filename_vtk = ['/projects/kg98/trangc/atlases/standard_mesh_atlases/resample_fsaverage/',hemi,'_fsaverage_164k_midthickness.vtk'];
[vertices,faces] = read_vtk(filename_vtk);
vertices = vertices';
faces = faces';

load(['output/corr_zmap_combat',num2str(iCOMBAT),'_smooth',num2str(smoothKernel),'_',hemi,'_all.mat'], 'map', ...
    'corSigClusterHC_P','corSigClusterP_HC','repSigClusterHC_P','repSigClusterP_HC','siteList')
load(['output/zmap_null_COMBAT',num2str(iCOMBAT),'_',hemi,'_smooth',num2str(smoothKernel),'_ver_all_newthres.mat'],...
    'corsigFdrmapSurrsHC_PVerAll','corsigFdrmapSurrsP_HCVerAll','repsigFdrmapSurrsHC_PVerAll','repsigFdrmapSurrsP_HCVerAll');

vari = 'repHC_P'; % 'repHC_P' , 'repP_HC', 'corHC_P', or 'corP_HC'

switch vari
    case 'corHC_P'
        corSigCluster = corSigClusterHC_P;
        corsigFdrmapSurrsP_HCVerAll = corsigFdrmapSurrsHC_PVerAll;
        map.sigClustermap = map.sigClustermapHC_P;
    case 'corP_HC'
        corSigCluster = corSigClusterP_HC;
        corsigFdrmapSurrsP_HCVerAll = corsigFdrmapSurrsHC_PVerAll;
        map.sigClustermap = map.sigClustermapP_HC;
    case 'repHC_P'
        corSigCluster = repSigClusterHC_P;
        corsigFdrmapSurrsP_HCVerAll = repsigFdrmapSurrsHC_PVerAll;
        map.sigClustermap = map.sigClustermapHC_P;
    case 'repP_HC'
        corSigCluster = repSigClusterP_HC;
        corsigFdrmapSurrsP_HCVerAll = repsigFdrmapSurrsP_HCVerAll;
        map.sigClustermap = map.sigClustermapP_HC;
    otherwise
        error('not valid');
end
markColorbar = 0;
makeUvalue = 0;
for iDiag = 1:nDiag
    corSigCluster{iDiag}(corSigCluster{iDiag}==1) = 0;

    iCol = mod(iDiag+1,2);
    iRow = floor((iDiag+1)/2);
    ax1 = axes('Position', [initX+factorX*lengthX*(iCol), initY+factorY*lengthY*(numRow-iRow) lengthX lengthY]);
    ids{iDiag}=find(tril(ones(size(corSigCluster{iDiag})),-1));
    corToPlot{1,iDiag} = corSigCluster{iDiag}(ids{iDiag});
    corToPlot{2,iDiag} = corsigFdrmapSurrsP_HCVerAll{iDiag};


    % plot table
    nSite = length(siteList{iDiag});
    hm = imagesc(ax1,1:nSite, 1:nSite, tril(corSigCluster{iDiag},-1));

      if strcmp(vari,'corHC_P') | strcmp(vari,'corP_HC')
        clim([-1 1]);

    else
        clim([0 1]);

    end
    colormap(ax1, greenwhiteviolet(ax1));
    if iDiag == 1
        c1 =  colorbar('Position', [initX*0.6, initY, 0.01, lengthY],'AxisLocation','out')
        if strcmp(vari,'corHC_P') | strcmp(vari,'corP_HC')
            c1.Label.String = 'Correlation';
        else
            c1.Label.String = 'Replication';
        end
        c1.Label.Rotation = 0;
        c1.Label.Position = [0.15 1.3];


    end

    xticks(ax1,[1:nSite])
    xticklabels(ax1,arrayfun(@(x) num2str(x),[1:nSite],'UniformOutput',false));
    xticklabels(ax1,arrayfun(@(x) num2str(x),[1:nSite],'UniformOutput',false));
    yticks(ax1,[1:nSite])
    yticklabels(ax1,arrayfun(@(x) num2str(x),[1:nSite],'UniformOutput',false))
    set(ax1,'box','off','TickLabelInterpreter', 'none','xaxisLocation','bottom','yaxisLocation','left')
    grid off
    xlim([0.5,nSite+0.5])
    ylim([0.5,nSite+0.5])
    xlabel('site')
    ylabel('site')
    if iDiag == 3

        ax1.YTickLabel(2:end-1)= cellfun(@(i) [],ax1.XTickLabel(2:end-1),'UniformOutput',false);
        set(ax1,'TickLabelInterpreter', 'latex');
    end

    %  max and min corr
    posSite = find(str2double(map.diag)==iDiag+1);

    maxCor = max(corToPlot{1,iDiag});
    if maxCor ~= 0
        [rowMax colMax] = find(round(maxCor,9)==round(corSigCluster{iDiag},9));
        rowMaxNoDiagonal = rowMax(rowMax~=colMax);
        colMaxNoDiagonal = colMax(rowMax~=colMax);
        colLeft = [colMaxNoDiagonal(1) rowMaxNoDiagonal(1)];
        % plot two sites on the left
        for iSite = 1:length(colLeft)
            iMap = posSite(colLeft(iSite));
            ax3 = axes('Position', [ax1.Position(1)+ax1.Position(3)*0.3+lengthMapX*factorMapX*(iSite-1) ax1.Position(2)+ax1.Position(4)*0.65 lengthMapX lengthMapY]);

            patch(ax3, 'Vertices', vertices, 'Faces', faces, 'FaceVertexCData', map.sigClustermap(iMap,:)', ...
                'EdgeColor', 'none', 'FaceColor', 'interp');
            if strcmp(hemi,'lh')
                view([-90 0]);
            else
                view([90 0]);
            end

            camlight('headlight')
            material dull
        % Initialize unified color limits
            if makeUvalue == 0
                lims = get(ax3, 'CLim');
                unified_AxisValue = ax3;
                makeUvalue = 1;
            end
            clim(ax3, [-max(abs(lims)), max(abs(lims))]);
               % Apply colormap
            colormap(ax3, bluewhitered(unified_AxisValue));
            axis off;
            axis image;
            clim(ax3,[-1 1])
        end
        a15 = annotation(fig, 'textbox', [ax3.Position(1)-ax3.Position(3)*1.1, ax3.Position(2)+ax3.Position(4)*1.1, ax3.Position(3)*2, 0.02], 'string', 'r_{max}', 'edgecolor', 'none', ...
            'color',darkorange,'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'center');

        a1 = annotation(fig,'rectangle',[(ax1.Position(1)+ax1.Position(3)/nSite*(colLeft(1)-1)) (ax1.Position(2)+ax1.Position(4)/nSite*(nSite-colLeft(2))) ax1.Position(3)/nSite ax1.Position(4)/nSite],'EdgeColor',darkorange,'LineWidth',1);
if markColorbar == 0
            c2 = colorbar('Position', [initX*1.6, initY, 0.01, lengthY],'AxisLocation','in','Ticks',[-1 1],'TickLabels',{'increased \newline in patients' 'reduced \newline in patients'})
            c2.Label.String = 'map';
            c2.Label.Rotation = 0;
            c2.Label.Position = [0.15 12.5];
            c2.Label.FontSize = fontsize_legend;
            % c2.TickLabels.FontSize = fontsize_legend;
            markColorbar = 1;
        end
    end

    minCor = min(corToPlot{1,iDiag});
    if (sum(corToPlot{1,iDiag}==0) == 1 & minCor == 0) | (minCor ~= 1 & minCor ~= 0)
        [rowMin colMin] = find(round(minCor,9)==round(corSigCluster{iDiag},9));
        rowMinNoDiagonal = rowMin(rowMin~=colMin);
        colMinNoDiagonal = colMin(rowMin~=colMin);
        colRight = [colMinNoDiagonal(1) rowMinNoDiagonal(1)];




        % plot maps on the right

        for iSite = 1:length(colRight)
            iMap = posSite(colRight(iSite));
            ax5 = axes('Position', [ax1.Position(1)+ax1.Position(3)*0.35+lengthMapX*factorMapX*(iSite+1) ax1.Position(2)+ax1.Position(4)*0.35 lengthMapX lengthMapY]);
            patch(ax5, 'Vertices', vertices, 'Faces', faces, 'FaceVertexCData', map.sigClustermap(iMap,:)', ...
                'EdgeColor', 'none', 'FaceColor', 'interp');

            if strcmp(hemi,'lh')
                view([-90 0]);
            else
                view([90 0]);
            end

            camlight('headlight')
            material dull
            % Initialize unified color limits
            if makeUvalue == 0
                lims = get(ax5, 'CLim');
                unified_AxisValue = ax3;
                makeUvalue = 1;
            end
            clim(ax5, [-max(abs(lims)), max(abs(lims))]);
               % Apply colormap
            colormap(ax5, bluewhitered(unified_AxisValue));
            axis off;
            axis image;
            clim(ax5,[-1 1])

        end
        a15 = annotation(fig, 'textbox', [ax5.Position(1)-ax5.Position(3)*1.1, ax5.Position(2)+ax5.Position(4)*1.1, ax5.Position(3)*2, 0.02], 'string', 'r_{min}', 'edgecolor', 'none', ...
            'color',lightorange,'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'center');
        a1 = annotation(fig,'rectangle',[(ax1.Position(1)+ax1.Position(3)/nSite*(colRight(1)-1)) (ax1.Position(2)+ax1.Position(4)/nSite*(nSite-colRight(2))) ax1.Position(3)/nSite ax1.Position(4)/nSite],'EdgeColor',lightorange,'LineWidth',1);


        if markColorbar == 0
            c2 = colorbar('Position', [initX*1.6, initY, 0.01, lengthY],'AxisLocation','in','Ticks',[-1 1],'TickLabels',{'increased \newline in patients' 'reduced \newline in patients'})
            c2.Label.String = 'map';
            c2.Label.Rotation = 0;
            c2.Label.Position = [0.15 12.5];
            c2.Label.FontSize = fontsize_legend;
            % c2.TickLabels.FontSize = fontsize_legend;
            markColorbar = 1;
        end
    end
    a15 = annotation(fig, 'textbox', [ax1.Position(1)-ax1.Position(3)*0.1, ax1.Position(2)+ax1.Position(4)*1.2, 0.09, 0.02], 'string', diagnosisStr{iDiag}, 'edgecolor', 'none', ...
        'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'center');

    % a6 = annotation(fig,'arrow',[ax1.Position(1)+ax1.Position(3)/length(corSig{iDiag})*(colRight(1)-0.5) ax5.Position(1)-ax5.Position(3)*0.1],...
    % [ax1.Position(2)+ax1.Position(4)/length(corSig{iDiag})*(length(corSig{iDiag})-colRight(2)+0.5) ax5.Position(2)+ax5.Position(4)*0],'LineWidth',0.8);
    %
    % a15 = annotation(fig, 'textbox', [ax1.Position(1)-ax1.Position(3)*0.15, ax1.Position(2)+ax1.Position(4)*1.1, 0.09, 0.02], 'string', diagnosisString{iDiag}, 'edgecolor', 'none', ...
    %   'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'center');
    % ks test
    [h, p, ksstat(iDiag)] = kstest2(corToPlot{1,iDiag}, corToPlot{2,iDiag});
end


C = [darkblue; gray]; %lines;
ViolinColor = {repmat(C,ceil(size(corToPlot,2)/length(C)),1)};

ax2 = axes('Position', [initVioX, initY*0.35 lengthX*numCol*factorX-initVioX lengthY*factorY]);
violinplot_subclass(corToPlot, diagnosisString,'ViolinColor',ViolinColor,'BoxColor',[0 0 0],'BoxWidth',0.07);

set(ax2,'FontSize',fontsize_legend)
if strcmp(vari,'corHC_P') | strcmp(vari,'corP_HC')
ylabel('correlation','FontSize',font_size)
 else
ylabel('replication','FontSize',font_size)
 end
set(ax2,'box','off')
tempXlim = xlim;
tempYlim =ylim;
dummyplot1 = scatter(ax2,[-1],[-1],'marker','hexagram','MarkerEdgeColor',darkblue,'MarkerFaceColor',C(1,:));
dummyplot2 = scatter(ax2,[-1],[-1],'marker','hexagram','MarkerEdgeColor',C(2,:),'MarkerFaceColor',C(2,:));

legend([dummyplot1,dummyplot2],{'Observed','Null'},'Location','best')
xlim([0 tempXlim(2)])
ylim(tempYlim)

legend('boxoff')

% mean and range
meanCor =  cellfun(@(x) mean(x), corToPlot);
minCor = cellfun(@(x) min(x), corToPlot);
maxCor = cellfun(@(x) max(x), corToPlot);
a25 = annotation(fig, 'textbox', [0, 0.98, 0.02, 0.02], 'string', 'a|', 'edgecolor', 'none', ...
    'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'center');

a26 = annotation(fig, 'textbox', [0.14, 0.27, 0.03, 0.02], 'string', 'b|', 'edgecolor', 'none', ...
    'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'center');


%%
switch vari
    case 'corHC_P'
        savefig(fig,['output/figure_corr_zmap_thres_fdr_combat',char(num2str(iCOMBAT)),'_',hemi,'_smooth',num2str(smoothKernel),'_HC_P.fig']);
        set(fig, 'PaperPositionMode', 'auto')
        print(fig, '-djpeg', '-r1200', ['output/figure_corr_zmap_thres_fdr_combat',char(num2str(iCOMBAT)),'_',hemi,'_smooth',num2str(smoothKernel),'_HC_P.jpg'])
    case 'corP_HC'
        savefig(fig,['output/figure_corr_zmap_thres_fdr_combat',char(num2str(iCOMBAT)),'_',hemi,'_smooth',num2str(smoothKernel),'_P_HC.fig']);
        set(fig, 'PaperPositionMode', 'auto')
        print(fig, '-djpeg', '-r1200', ['output/figure_corr_zmap_thres_fdr_combat',char(num2str(iCOMBAT)),'_',hemi,'_smooth',num2str(smoothKernel),'_P_HC.jpg'])
    case 'repHC_P'
        savefig(fig,['output/figure_rep_zmap_thres_fdr_combat',char(num2str(iCOMBAT)),'_',hemi,'_smooth',num2str(smoothKernel),'_HC_P.fig']);
        set(fig, 'PaperPositionMode', 'auto')
        print(fig, '-djpeg', '-r1200', ['output/figure_rep_zmap_thres_fdr_combat',char(num2str(iCOMBAT)),'_',hemi,'_smooth',num2str(smoothKernel),'_HC_P.jpg'])
    case 'repP_HC'
        savefig(fig,['output/figure_rep_zmap_thres_fdr_combat',char(num2str(iCOMBAT)),'_',hemi,'_smooth',num2str(smoothKernel),'_P_HC.fig']);
        set(fig, 'PaperPositionMode', 'auto')
        print(fig, '-djpeg', '-r1200', ['output/figure_rep_zmap_thres_fdr_combat',char(num2str(iCOMBAT)),'_',hemi,'_smooth',num2str(smoothKernel),'_P_HC.jpg'])
    otherwise
        error('not valid');
end

