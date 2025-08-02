clear all
% close all
addpath('/home/trangc/kg98/trangc/VBM/code/utils')

iCOMBAT = 1;
smoothKernel = 10;
thres = 0.05;

diagnosisString = {'BD', 'SCA',...
    'SCZ', 'ASD', 'MDD','AD' };
conName = {'mean age','var age','male','female','sex ratio','patients','controls','subjects','patient HC ratio','treatment','mean CAT','var CAT','mean onset','var onset','mean illness','var illness'};
nCon = length(conName);
nDiag = length(diagnosisString);



colorVec = {[0, 0.4470, 0.7410], [0.8500, 0.3250, 0.0980],	[0.9290, 0.6940, 0.1250],  [0.4940, 0.1840, 0.5560],  [0.4660, 0.6740, 0.1880]};

fig = figure('Position', [200 200 400 600]);
set(fig,'color','w');
factor_x = 1.1;
factor_y = 1.1;
init_x = 0.3;
init_y = 0.2;
num_row = 1;
num_col = 1;
length_x = (0.85 - init_x)/(factor_x*(num_col-1) + 1);
length_y = (0.95 - init_y)/(factor_y*(num_row-1) + 1);
lineWidth = 2;

font_name = 'Arial';
font_size = 10;
fontsize_legend = 8;
hemisphere = 'lh';
           
% contoplot = table;
for iDiag = 1:nDiag

    iCon = 0;
    load('/projects/kg98/trangc/VBM/code/analysis/output/confound_age.mat', 'varTable');
    if ~isempty(varTable{iDiag})
        contoplot(iDiag,iCon+1:iCon+2) = varTable{iDiag}{1,:};
     ptoplot(iDiag,iCon+1:iCon+2) = varTable{iDiag}{2,:};
    end
iCon = iCon+2;

    load('/projects/kg98/trangc/VBM/code/analysis/output/confound_sex.mat', 'varTable');
    if ~isempty(varTable{iDiag})
        contoplot(iDiag,iCon+1:iCon+3) = varTable{iDiag}{1,[1,2,4]};
     ptoplot(iDiag,iCon+1:iCon+3) = varTable{iDiag}{2,[1,2,4]};
    end
iCon = iCon+3;


    load('/projects/kg98/trangc/VBM/code/analysis/output/confound_nPC.mat', 'varTable');
    if ~isempty(varTable{iDiag})
        contoplot(iDiag,iCon+1:iCon+4) = varTable{iDiag}{1,:};
     ptoplot(iDiag,iCon+1:iCon+4) = varTable{iDiag}{2,:};
    end
     iCon = iCon+4;

    load('/projects/kg98/trangc/VBM/code/analysis/output/confound_treatment.mat', 'varTable');
    if ~isempty(varTable{iDiag})
        contoplot(iDiag,iCon+1) = varTable{iDiag}{1,:};
     ptoplot(iDiag,iCon+1) = varTable{iDiag}{2,:};
    end
    iCon = iCon+1;

    load('/projects/kg98/trangc/VBM/code/analysis/output/confound_CAT.mat', 'varTable');
    if ~isempty(varTable{iDiag})
        contoplot(iDiag,iCon+1:iCon+2) = varTable{iDiag}{1,:};
     ptoplot(iDiag,iCon+1:iCon+2) = varTable{iDiag}{2,:};
    end

iCon = iCon+2;
    load('/projects/kg98/trangc/VBM/code/analysis/output/confound_ageonset.mat', 'varTable');
    if ~isempty(varTable{iDiag})
        contoplot(iDiag,iCon+1:iCon+2) = varTable{iDiag}{1,:};
     ptoplot(iDiag,iCon+1:iCon+2) = varTable{iDiag}{2,:};
    end


     iCon = iCon+2;
    load('/projects/kg98/trangc/VBM/code/analysis/output/confound_illnessDuration.mat', 'varTable');
    if ~isempty(varTable{iDiag})
        contoplot(iDiag,iCon+1:iCon+2) = varTable{iDiag}{1,:};
     ptoplot(iDiag,iCon+1:iCon+2) = varTable{iDiag}{2,:};
    end




end
ptoplot=ptoplot';
contoplot = contoplot';

ax12 = heatmap(fig,contoplot,'Position', [init_x, init_y, length_x, length_y],...
    'Colormap',hot,'FontName',font_name,'FontSize',font_size,...%'ColorLimits', [0,0.06],...
    'XDisplayLabels',diagnosisString,...
    'YDisplayLabels',conName);
colorbar


for iRow = 1:length(conName)
    for iCol = 1:length(diagnosisString)
 if ptoplot(iRow,iCol) <= thres & ptoplot(iRow,iCol) >0
  a15 = annotation(fig, 'textbox', [0.2+length_x*(1/nDiag*iCol+0.01), 0.2+length_y*(0.38/nDiag*(nCon-iRow)+0.01), 0.09, 0.02], 'string', '*', 'edgecolor', 'none', ...
    'FontName',font_name,'FontSize',font_size,  'horizontalalignment', 'center');

 end
    end
end

%%
% savefig(fig,['output/figure_corr_zmap_noCombat.fig']);
% set(fig, 'PaperPositionMode', 'auto')
% print(fig, '-djpeg', '-r1200', 'output/figure_corr_zmap_noCombat.jpg')
