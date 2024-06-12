% Script to demonstrate averaging of curves

% Generate and plot 5 sine waves of variable length for illustration purposes

figure;
subplot(2,1,1); hold on

for i = 1:5
    y0{i} = sin(0:0.1:2*pi+0.5*randn)'; % create a sine wave with (somewhat) random length
    y{i} = y0{i} + 0.1*randn(size(y0{i})); % add random noise
    plot(y{i},'b'); % plot them in blue
end

% To average them, we need to resample them to the same length

for i = 1:5
    yeq(:,i) = resample(y{i}, 100, length(y{i})); % reample to 100 points
end

subplot(2,1,2); hold on
% plot the resampled curves
plot(yeq,'m');

% Calculate the average and plot on the same axes
yav = mean(yeq, 2);
plot(yav,'m','LineWidth',3)
