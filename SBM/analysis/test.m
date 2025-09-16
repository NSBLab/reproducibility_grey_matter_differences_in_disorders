% Example data
x = 1:100;                     % X-axis values
data = randn(50, 100);         % 50 samples, 100 points each (e.g., 50 subjects, 100 time points)
meanData = mean(data, 1);      % Mean across the 50 samples
varData = var(data, 1);        % Variance across the 50 samples

% Compute the upper and lower bounds for the shaded region
upperBound = meanData + varData;
lowerBound = meanData - varData;

% Plot the mean with a shaded variance region
figure;
hold on;

% Shaded area for variance
fill([x fliplr(x)], [upperBound fliplr(lowerBound)], 'b', 'FaceAlpha', 0.2, 'EdgeColor', 'none');

% Plot the mean line
plot(x, meanData, 'b', 'LineWidth', 2);

% Formatting
xlabel('X-axis');
ylabel('Y-axis');
title('Mean with Variance');
legend('Variance', 'Mean');
grid on;
hold off;
