clear all
% close all
addpath('/home/trangc/kg98/trangc/library/Violinplot-Matlab-master')
iCOMBAT = 1;
smoothKernel = 8;

if iCOMBAT == 1
    address = ['derivatives/s',num2str(smoothKernel),'COMBAT/'];
else
    address = ['derivatives/s',num2str(smoothKernel),'/'];
end

metadata = readtable(['/home/trangc/kg98/trangc/VBM/data/derivatives/s',num2str(smoothKernel),'COMBAT/metadata.csv']);

diagnosisString = unique(metadata.diagnosis_string);
diagnosisString = diagnosisString(~ismember(diagnosisString,'HC'));
nDiag = length(diagnosisString);



colorVec = {[0, 0.4470, 0.7410], [0.8500, 0.3250, 0.0980],	[0.9290, 0.6940, 0.1250],  [0.4940, 0.1840, 0.5560],  [0.4660, 0.6740, 0.1880]};

fig = figure('Position', [200 200 600 400]);
factor_x = 1.2;
factor_y = 2.2;
init_x = 0.1;
init_y = 0.1;
num_row = 1;
num_col = 1;
length_x = (0.95 - init_x)/(factor_x*(num_col-1) + 1);
length_y = (0.95 - init_y)/(factor_y*(num_row-1) + 1);
lineWidth = 2;

font_name = 'Arial';
font_size = 10;
fontsize_legend = 8;
ax2 = axes('Position', [init_x, init_y length_x length_y]);
hold on
%%
% load('output/corr_tmap.mat', 'cor1'); %load vbm tmap cor 
%load('output/corr_tmap_thres.mat', 'cor1'); %load vbm thres-tmap cor 
% load('/projects/kg98/trangc/VBM/code/freesurfer/freesurfer_holmesQC/step4_qdec/corr_surface.mat', 'corDiag'); %load sbm zmap corr
% cor1 = corDiag;

% load('/projects/kg98/trangc/VBM/code/freesurfer/freesurfer_holmesQC/step4_qdec/corr_surface.mat', 'corSig'); %load sbm thres-zmap corr
% cor1 = corSig;

%load('/projects/kg98/trangc/VBM/code/freesurfer/freesurfer_holmesQC/step4_qdec/corr_MBM.mat', 'corDiagBeta','corDiagBetaThres'); %load sbm thres-zmap corr
% cor1 = corDiagBeta(2:6);
%cor1 = corDiagBetaThres(2:6);

load('/fs04/kg98/trangc/VBM/code/analysis/output/corr_tmap.mat', 'cor1', 'cor2')
cor1=cor2;

for iSite = 1:5
ids{iSite}=find(triu(ones(size(cor1{iSite})),1));

end

% corToPlot.ASD = cor1{4}(ids{4});
corToPlot.BD = cor1{1}(ids{1});
corToPlot.MDD = cor1{5}(ids{5});
% corToPlot.SCA = cor1{2}(ids{2});
corToPlot.SCZ = cor1{3}(ids{3});

violinplot(corToPlot, diagnosisString);

ylabel('correlation')
set(ax2,'box','off')
set(ax2, 'color','white')
%%
% savefig(fig,['output/figure_corr_zmap_noCombat.fig']);
% set(fig, 'PaperPositionMode', 'auto')
% print(fig, '-djpeg', '-r1200', 'output/figure_corr_zmap_noCombat.jpg')
