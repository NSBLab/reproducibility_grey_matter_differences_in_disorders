% Parameters
clear all
n_regions = 1000;            % number of brain regions
 %sample_sizes =  [10    16    25    40    63   100   158   251   398   631];   % range of sample sizes
sample_sizes =  [10  20  100  200 1000 2000 10000];   % range of sample sizes

n_iter = 5;                 % number of iterations
signal_std_list = [0 0.01:0.02:0.1 0.2:0.2:1 2 10];               % standard deviation of noise
colorVec = {[225 232 255], [205 217 255], [185 202 255], [165 186 255], [145 171 255], [115 148 255], [85 125 255], [55 103 255],[5 65 255],[0 48 200],[0 36 150],[0 24 100],[0 16 70] };

% Region-specific effects (same for both studies)
rng(1);  % for reproducibility
C = randn(1, n_regions);  % region-wise independent effects

% Store results
corrs = zeros(length(sample_sizes), n_iter);

    figure;
    ax1 = axis;
    hold on
for iSignal = 1:length(signal_std_list)
    

signal_std = signal_std_list(iSignal);

    for si = 1:length(sample_sizes)
        n_samplesize = sample_sizes(si);

        for iter = 1:n_iter
            % ---- Study 1 ----
            ctrl1 = randn(n_samplesize, n_regions);
            pat1 = randn(n_samplesize, n_regions) + C*signal_std;

            % ---- Study 2 ----
            ctrl2 = randn(n_samplesize, n_regions);
            pat2 = randn(n_samplesize, n_regions) + C*signal_std;

            % Compute t-maps
            [~, ~, ~, stats1] = ttest2(pat1, ctrl1);
            tmap1 = stats1.tstat;

            [~, ~, ~, stats2] = ttest2(pat2, ctrl2);
            tmap2 = stats2.tstat;

            % Correlation between t-maps
            corrs(si, iter) = corr(tmap1', tmap2', 'rows', 'complete');
        end
    end

    % Compute mean and std of correlation
    mean_corr{iSignal} = mean(corrs, 2);
    var_corr{iSignal} = var(corrs, 0, 2);

    
end
%%
save(['output/simulation_signal_noise_Niter_',char(num2str(n_iter)),'_samplesizerange_10_10000.mat'],'mean_corr','var_corr','sample_sizes','signal_std_list')