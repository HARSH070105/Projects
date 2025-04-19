% Load the ECG Signal
load('E2.mat'); % Replace with your .mat file
fs = 128;                        % Sampling frequency (Hz)
signal_segment = E2(500:1500);   % Segment of interest
t = (0:length(signal_segment)-1) / fs; % Time vector for the signal

% Preprocessing: Bandpass Filter
% Bandpass filter settings to isolate desired ECG frequency range
low_cutoff = 1.5; % Hz
high_cutoff = 35; % Hz
[b, a] = butter(4, [low_cutoff, high_cutoff] / (fs / 2), 'bandpass');
filtered_signal = filtfilt(b, a, signal_segment);

% Step 1: Differentiation to Highlight Slope Changes
diff_signal = diff(filtered_signal);
diff_signal = [0 diff_signal]; % Pad to maintain same length as the original

% Step 2: Squaring for Peak Emphasis
squared_signal = diff_signal.^2;

% Step 3: Moving Window Integration
integration_window = round(0.15 * fs); % 150 ms window
integrated_signal = filter(ones(1, integration_window) / integration_window, 1, squared_signal);

% Step 4: Dynamic Threshold-Based Peak Detection
threshold = max(integrated_signal) * 0.2; % Threshold set at 20% of the max value
[~, peak_indices] = findpeaks(integrated_signal, 'MinPeakHeight', threshold, 'MinPeakDistance', fs * 0.3);

% Step 5: Calculate Heart Rate (BPM)
rr_intervals = diff(peak_indices) / fs; % Time intervals between R-peaks (in seconds)
bpm_values = 60 ./ rr_intervals;        % Convert to BPM
bpm_times = t(peak_indices(2:end));     % Time corresponding to BPM values

% Compute Mean BPM
average_bpm = mean(bpm_values);

% Display Results in Command Window
disp('--- Heart Rate Analysis for E2 ---');
disp(['Total Peaks Detected: ', num2str(length(peak_indices))]);
disp(['Average Heart Rate (BPM): ', num2str(average_bpm, '%.2f')]);

% Plotting Results
figure;

% Plot 1: Original ECG Signal
subplot(4, 1, 1);
plot(t, signal_segment, 'b', 'LineWidth', 1);
title('Original ECG Signal');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;

% Plot 2: Filtered ECG Signal
subplot(4, 1, 2);
plot(t, filtered_signal, 'k', 'LineWidth', 1);
title('Filtered ECG Signal');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;

% Plot 3: Integrated Signal and Peaks
subplot(4, 1, 3);
plot(t, integrated_signal, 'm', 'LineWidth', 1);
hold on;
plot(t(peak_indices), integrated_signal(peak_indices), 'ro', 'MarkerFaceColor', 'r');
title('Integrated Signal with Detected Peaks');
xlabel('Time (s)');
ylabel('Amplitude');
legend('Integrated Signal', 'Detected Peaks');
grid on;

% Plot 4: Heart Rate (BPM) Over Time
subplot(4, 1, 4);
plot(bpm_times, bpm_values, '-o', 'Color', [0.2 0.6 0.2], 'LineWidth', 1.5);
hold on;
yline(average_bpm, '--r', ['Mean BPM: ', num2str(average_bpm, '%.2f')], 'LineWidth', 1.2);
xlim([bpm_times(1), bpm_times(end)]);
title('Heart Rate (BPM) Over Time');
xlabel('Time (s)');
ylabel('BPM');
grid on;

disp('Analysis Complete. See plots for results.');
