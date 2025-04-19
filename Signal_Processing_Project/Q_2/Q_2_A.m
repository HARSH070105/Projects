% Load ECG Signal
load('E1.mat'); % Replace with your .mat file
fs = 128;               % Sampling frequency (Hz)
signal_segment = E1(500:1000); % Segment of interest
t = (0:length(signal_segment)-1) / fs; % Time vector for signal

% Preprocessing (Optional Bandpass Filter)
% Uncomment if needed for noise reduction
% [b, a] = butter(4, [0.5, 50] / (fs / 2), 'bandpass');
% filtered_signal = filtfilt(b, a, signal_segment);

% Step 1: Differentiation to Highlight Changes
diff_signal = diff(signal_segment);
diff_signal = [0 diff_signal]; % Pad with 0 to maintain same length

% Step 2: Squaring to Enhance Peaks
squared_signal = diff_signal.^2;

% Step 3: Moving Average for Integration
integration_window = round(0.15 * fs); % 150 ms window size
integrated_signal = filter(ones(1, integration_window) / integration_window, 1, squared_signal);

% Step 4: Dynamic Threshold-Based Peak Detection
threshold = max(integrated_signal) * 0.2; % 20% of max value
[~, peak_indices] = findpeaks(integrated_signal, 'MinPeakHeight', threshold, 'MinPeakDistance', fs * 0.3);

% Step 5: Calculate Heart Rate (BPM)
rr_intervals = diff(peak_indices) / fs; % Time intervals between peaks in seconds
bpm_values = 60 ./ rr_intervals;        % Convert to BPM
bpm_times = t(peak_indices(2:end));     % Corresponding time for each BPM

% Compute Mean BPM
average_bpm = mean(bpm_values);

% Results Display
disp('--- Heart Rate Analysis ---');
disp(['Total Peaks Detected: ', num2str(length(peak_indices))]);
disp(['Average Heart Rate (BPM): ', num2str(average_bpm)]);

% Plot Results
figure;

% Plot 1: Original ECG Signal
subplot(3, 1, 1);
plot(t, signal_segment, 'b', 'LineWidth', 1);
title('Original ECG Signal');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;

% Plot 2: Integrated Signal and Peaks
subplot(3, 1, 2);
plot(t, integrated_signal, 'k', 'LineWidth', 1);
hold on;
plot(t(peak_indices), integrated_signal(peak_indices), 'ro', 'MarkerFaceColor', 'r');
title('Integrated Signal with Detected Peaks');
xlabel('Time (s)');
ylabel('Amplitude');
legend('Integrated Signal', 'Detected Peaks');
grid on;

% Plot 3: Heart Rate (BPM) Over Time
subplot(3, 1, 3);
plot(bpm_times, bpm_values, '-o', 'Color', [0.2 0.6 0.2], 'LineWidth', 1.5);
title('Heart Rate (BPM) Over Time');
xlabel('Time (s)');
ylabel('BPM');
grid on;

% Highlight Mean BPM
hold on;
yline(average_bpm, '--r', ['Mean BPM: ', num2str(average_bpm, '%.2f')], 'LineWidth', 1.2);

% Final Message
disp('Analysis Complete. See plots for results.');
