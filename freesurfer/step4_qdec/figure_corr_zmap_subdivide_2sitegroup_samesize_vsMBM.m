clear all
% close all

smoothKernel = 10;
diaglist = 2:7;
hemis = 'lh';
nMode = 200;


addpath(genpath('/projects/kg98/trangc/VBM/code'))
iDiag = 3
diag = diaglist(iDiag)
%
%sampleSizeList =  [10    16    25    40    63   100   158 210]; 
%sampleSizeList =  [10    16    25    40    63   100   136];
sampleSizeList = [10    16    25    40    63   100   158 251 398 527];
% sampleSizeList = [10    16    25    40    63   100 111];
%sampleSizeList =  [10    16    25    40    63   100 158 231];
% # adding the max number that each diagnosis can have, corresponding to the diaglist (210, 136, 527, 111, 231, 327)  
colorVec = {[225 232 255], [205 217 255], [185 202 255], [165 186 255], [145 171 255], [115 148 255], [85 125 255], [55 103 255],[5 65 255],[0 48 200],[0 36 150],[0 24 100] };
colorpalette = colororder('gem');

nSize = length(sampleSizeList);
fig = figure('Position', [200 200 1200 800]);
set(fig,'color','w');
factor_x = 1.2;
factor_y = 1.1;
init_x = 0.15;
init_y = 0.2;
num_row = 1;
num_col = 1;
length_x = (0.95 - init_x)/(factor_x*(num_col-1) + 1);
length_y = (0.9 - init_y)/(factor_y*(num_row-1) + 1);
lineWidth = 2;

%
font_name = 'Arial';
font_size = 20;
fontsize_legend = 16;

ax2 = axes('Position', [init_x, init_y length_x length_y]);

%load vtk surface
filename_vtk = 'fsaverage_164k_midthickness-lh.vtk';
[vertices,faces] = read_vtk(filename_vtk);
vertices = vertices';
faces = faces';



load(['output/corr_zmap_subdivide_2sitegroup_samesize.mat'], 'medianCor','varCor','medianCorThres','varCorThres');



lengthToPlot = sum(medianCor{iDiag}>0);

% Compute the upper and lower bounds for the shaded region
meanPlot(1,:) = medianCor{iDiag};
upperBoundPlot(1,:) = medianCor{iDiag} + sqrt(varCor{iDiag});
lowerBoundPlot(1,:) = medianCor{iDiag} - sqrt(varCor{iDiag});

meanPlot(3,:) = medianCorThres{iDiag};
upperBoundPlot(3,:) = medianCorThres{iDiag} + sqrt(varCorThres{iDiag});
lowerBoundPlot(3,:) = medianCorThres{iDiag} - sqrt(varCorThres{iDiag});

for isampleSize = 1:length(sampleSizeList)
    sampleSize = sampleSizeList(isampleSize);
    load(['output/corr_MBM_diag',char(num2str(diag)),'_subdivide_2sitegroup_samesize_',char(num2str(sampleSize)),'_nMode',char(num2str(nMode)),'.mat'],...
            "corDiagBeta",  "corDiagBetaThres",  "corRecon", "meancorDiagBeta", "varcorDiagBeta", "meancorDiagBetaThres",...
            "varcorDiagBetaThres", "meancorRecon", "varcorRecon","meancorReconSig", "varcorReconSig")


iPlot = 2;
    meanPlot(iPlot,isampleSize) = meancorDiagBeta;
upperBoundPlot(iPlot,isampleSize) = meancorDiagBeta + sqrt(varcorDiagBeta);
lowerBoundPlot(iPlot,isampleSize) = meancorDiagBeta - sqrt(varcorDiagBeta);

% iPlot = iPlot+1;
% meanPlot(iPlot,isampleSize) = meancorDiagBetaThres;
% upperBoundPlot(iPlot,isampleSize) = meancorDiagBetaThres + sqrt(varcorDiagBetaThres);
% lowerBoundPlot(iPlot,isampleSize) = meancorDiagBetaThres - sqrt(varcorDiagBetaThres);

% iPlot = iPlot+1;
% meanPlot(iPlot,isampleSize) = meancorRecon;
% upperBoundPlot(iPlot,isampleSize) = meancorRecon + sqrt(varcorRecon);
% lowerBoundPlot(iPlot,isampleSize) = meancorRecon - sqrt(varcorRecon);

iPlot = 4;
meanPlot(iPlot,isampleSize) = meancorReconSig;
upperBoundPlot(iPlot,isampleSize) = meancorReconSig + sqrt(varcorReconSig);
lowerBoundPlot(iPlot,isampleSize) = meancorReconSig - sqrt(varcorReconSig);

end

sampleSizetoPlot = sampleSizeList(1:lengthToPlot);

for iDiag = 1:height(meanPlot)
% Shaded area for variance
newColor = colorpalette(iDiag,:);
colorfactor = 1.1;
for i=1:3
newColor(i) = colorpalette(iDiag+2,i)*colorfactor*(colorpalette(iDiag+2,i).*colorfactor<=1)+ colorpalette(iDiag+2,i)*(colorpalette(iDiag+2,i).*colorfactor>1);
end

h1 = fill(ax2,[sampleSizetoPlot fliplr(sampleSizetoPlot)], [upperBoundPlot(iDiag,:) fliplr(lowerBoundPlot(iDiag,:))], 'b', 'FaceAlpha', 0.5, 'EdgeColor', 'none','FaceColor',newColor);
hold on
% Plot the mean line
h2(iDiag) = plot(ax2, sampleSizetoPlot, meanPlot(iDiag,1:lengthToPlot), 'b', 'LineWidth', 2,'Color',colorpalette(iDiag+2,:));

end




 set(ax2, 'XScale','log')
set(ax2,'box','off')
set(ax2, 'color','none','FontSize',font_size)
set(ax2, 'XTick', sampleSizeList);
    sampleLabel = arrayfun(@(x) char(num2str(x)), sampleSizeList, 'UniformOutput', false);
   set(ax2, 'XTickLabel', sampleLabel,'FontSize',fontsize_legend);
xlim([10 550]);
ylim([0 1]);
legendString = {'statistical map','MBM beta spectrum',  'thresholded map',...
    'MBM reconstructed map' };
% legendString = {'stat-map', 'thresholded map',...
%     'beta', 'significant beta', 'reconstructed map', 'reconstructed significant map' };
plotLegend = legend(h2, legendString,'Location','northwest','FontSize',font_size)

ylabel('correlation','FontSize',font_size)
xlabel({'sample size'},'fontsize',font_size)
legend('boxoff')


%%
savefig(fig,['output/figure_corr_zmap_subdivide_2sitegroup_samesize_vsMBM_diag',char(num2str(diag)),'_nMode',char(num2str(nMode)),'1.fig']);
set(fig, 'PaperPositionMode', 'auto')
print(fig, '-djpeg', '-r1200',[ 'output/figure_corr_zmap_subdivide_2sitegroup_samesize_vsMBM_diag',char(num2str(diag)), ...
    '_nMode',char(num2str(nMode)),'1.jpg'])
