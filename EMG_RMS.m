% Read in EMG raw data

load('emgdata.mat', 'emgdata')

% Specify window size for processing - ie how many samples are you looking
% back?

[rows, cols] = size(emgdata);
window = 300;

% Initialise storage array for output

RMSdata = zeros(rows-window, cols);

% Detrend raw data

emgdet = detrend(emgdata);

% Calculate RMS values for sliding window (RMS requires Signal Processing
% toolbox)

for i = window+1:rows
    RMSdata(i-window,:) = rms(emgdet(i-window:i,:));
end

% Plot raw (actually detrended) EMG data against windowed RMS (play with
% colours to make this more readable)

plot(emgdet(window+1:rows,:)); hold on
plot(RMSdata, 'LineWidth', 2)

% Downsample and save as 'predictors' for pattern recognition network

emg.predictors = downsample(RMSdata, 100);

