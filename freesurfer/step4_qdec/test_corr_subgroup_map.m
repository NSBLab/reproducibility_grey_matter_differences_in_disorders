% test correlation between subgroup of 3 hypos
clear all
% rng('default')  % For reproducibility
%read in groundtruth map
HCID = 'sub-0185GOH';
BDID = 'sub-1872DNU';
SCAID = 'sub-0193RQW';
SCZID = 'sub-0542LBG';
mapHC = load_mgh(['/home/trangc/kg98/trangc/VBM/data/BSNIP/derivatives/freesurfer/',HCID,'/surf/lh.thickness.fwhm10.fsaverage.mgh']);
mapBD = load_mgh(['/home/trangc/kg98/trangc/VBM/data/BSNIP/derivatives/freesurfer/',BDID,'/surf/lh.thickness.fwhm10.fsaverage.mgh']);
mapSCA = load_mgh(['/home/trangc/kg98/trangc/VBM/data/BSNIP/derivatives/freesurfer/',SCAID,'/surf/lh.thickness.fwhm10.fsaverage.mgh']);
mapSCZ = load_mgh(['/home/trangc/kg98/trangc/VBM/data/BSNIP/derivatives/freesurfer/',SCZID,'/surf/lh.thickness.fwhm10.fsaverage.mgh']);
nVer = length(mapSCZ);

corr([mapHC mapBD mapSCA mapSCZ])
%%
nSample = 100;

sampleSize = [20 40 60 100 200 400 1000]
colorVec = {[225 232 255], [205 217 255], [185 202 255], [165 186 255], [145 171 255], [115 148 255], [85 125 255], [55 103 255],[5 65 255],[0 48 200],[0 36 150],[0 24 100] };

%% subsample from 1 group

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

for iSampleSize = 1:length(sampleSize)

    for iSample = 1:nSample
        nSub = sampleSize(iSampleSize);

        muNoise = ones(1,nSub);
sigmaNoise = (ones(nSub)-eye(nSub))*0.2+eye(nSub);
mapHCNoise = mvnrnd(muNoise,sigmaNoise,nVer);
mapBD1Noise = mvnrnd(muNoise,sigmaNoise,nVer);
mapBD2Noise = mvnrnd(muNoise,sigmaNoise,nVer);
        
        mapHCgen = mapHC + mapHCNoise;
mapBD1gen = mapBD + mapBD1Noise;
         mapBD2gen = mapBD + mapBD2Noise;
          [h, p, ci, stats] = ttest2(mapHCgen', mapBD1gen');
        statMap1 = stats.tstat;
      [h, p, ci, stats] = ttest2(mapHCgen', mapBD2gen');
        statMap2 = stats.tstat;

        co1group(iSampleSize, iSample) = corr(statMap1,statMap2);
    end

    [fi xi]=ksdensity(co1group(iSampleSize,:),'function','pdf');

    denPlot = plot(ax2, xi, fi, 'LineWidth', lineWidth,'Color',colorVec{length(colorVec)-length(sampleSize)+iSampleSize}./255);
    hold on
    % clear sample1 sample2
end

