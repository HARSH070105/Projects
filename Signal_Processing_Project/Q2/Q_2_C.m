% Load the ECG Signal
load('E3.mat'); % Replace with your .mat file
fs = 128;                         % Sampling frequency (Hz)
signal_segment = E3(500:1500);    % Segment of interest
time_vector = (0:length(signal_segment)-1) / fs; % Time vector for plotting

% Preprocessing: Bandpass Filter for Noise Reduction
low_cutoff = 1.5; % Hz
high_cutoff = 35; % Hz
[b, a] = butter(4, [low_cutoff, high_cutoff] / (fs / 2), 'bandpass');
filtered_signal = filtfilt(b, a, signal_segment);

% Step 1: Signal Differentiation for Highlighting Slope Changes
differentiated_signal = [0, diff(filtered_signal)]; % Pad to maintain length

% Step 2: Squaring to Amplify Peaks
squared_signal = differentiated_signal.^2;

% Step 3: Moving Window Integration for Smoothing
integration_window = round(0.15 * fs); % 150 ms window
integrated_signal = movmean(squared_signal, integration_window);

% Step 4: Peak Detection using Dynamic Threshold
peak_threshold = max(integrated_signal) * 0.3; % Adjust threshold as 30% of max value
[~, peak_indices] = findpeaks(integrated_signal, 'MinPeakHeight', peak_threshold, 'MinPeakDistance', fs * 0.3);

% Step 5: Calculate Heart Rate (BPM)
rr_intervals = diff(peak_indices) / fs; % Time intervals between peaks (seconds)
bpm_values = 60 ./ rr_intervals;        % Convert intervals to BPM
bpm_times = time_vector(peak_indices(2:end)); % Times corresponding to BPM values

% Compute Average Heart Rate (BPM)
average_bpm = mean(bpm_values);

% Display Results in Command Window
disp('--- Heart Rate Analysis for E3 ---');
disp(['Total Peaks Detected: ', num2str(length(peak_indices))]);
disp(['Average Heart Rate (BPM): ', num2str(average_bpm, '%.2f')]);

% Plotting Results
figure;

% Plot 1: Original ECG Signal
subplot(4, 1, 1);
plot(time_vector, signal_segment, 'b', 'LineWidth', 1);
title('Original ECG Signal');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;

% Plot 2: Filtered ECG Signal
subplot(4, 1, 2);
plot(time_vector, filtered_signal, 'k', 'LineWidth', 1);
title('Filtered ECG Signal');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;

% Plot 3: Integrated Signal with Detected Peaks
subplot(4, 1, 3);
plot(time_vector, integrated_signal, 'm', 'LineWidth', 1);
hold on;
plot(time_vector(peak_indices), integrated_signal(peak_indices), 'ro', 'MarkerFaceColor', 'r');
title('Integrated Signal with Detected Peaks');
xlabel('Time (s)');
ylabel('Amplitude');
legend('Integrated Signal', 'Detected Peaks');
grid on;

% Plot 4: Heart Rate (BPM) Over Time
subplot(4, 1, 4);
plot(bpm_times, bpm_values, '-o', 'Color', [0.2, 0.6, 0.2], 'LineWidth', 1.5);
hold on;
yline(average_bpm, '--r', ['Mean BPM: ', num2str(average_bpm, '%.2f')], 'LineWidth', 1.2);
xlim([bpm_times(1), bpm_times(end)]);
title('Heart Rate (BPM) Over Time');
xlabel('Time (s)');
ylabel('BPM');
grid on;

disp('Analysis for E3 Complete. Check plots for details.');
