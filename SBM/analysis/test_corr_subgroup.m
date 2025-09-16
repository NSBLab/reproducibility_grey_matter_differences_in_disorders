% test correlation between subgroup of 3 hypos
clear all
mu = [2 3 4 5];
Sigma1 = (ones(4)-eye(4))*0.2+eye(4);
% rng('default')  % For reproducibility


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
        nElement = sampleSize(iSampleSize);
        R = mvnrnd(mu,Sigma1,nElement);

        co1group(iSampleSize, iSample) = corr(R(:,1),R(:,2));
    end

    [fi xi]=ksdensity(co1group(iSampleSize,:),'function','pdf');

    denPlot = plot(ax2, xi, fi, 'LineWidth', lineWidth,'Color',colorVec{length(colorVec)-length(sampleSize)+iSampleSize}./255);
    hold on
    % clear sample1 sample2
end

