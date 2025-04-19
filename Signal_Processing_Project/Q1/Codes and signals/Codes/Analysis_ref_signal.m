% Define file paths for the bird audio files
filePaths = {'bird1.wav', 'bird2.wav', 'bird3.wav'};

% Create a figure for the 2x3 grid
figure;
set(gcf, 'Position', [100, 100, 1200, 600]); % Adjust figure size

% Loop through each file to process
for i = 1:length(filePaths)
    % Read the audio file
    [audioData, sampleRate] = audioread(filePaths{i});
    
    % Normalize the data for consistent visualization
    time = linspace(0, length(audioData) / sampleRate, length(audioData));
    
    % Compute the Fourier Transform
    N = length(audioData); % Number of samples
    Y = fft(audioData); % Compute FFT
    f = (0:N-1) * (sampleRate / N); % Frequency axis (positive frequencies only)
    
    % Plot the waveform (Top Row)
    subplot(2, 3, i);
    plot(time, audioData);
    title(['Waveform of ', filePaths{i}]);
    xlabel('Time (s)');
    ylabel('Amplitude');
    grid on;
    
    % Plot the Fourier Transform (Bottom Row)
    subplot(2, 3, i + 3);
    plot(f(1:N/2), abs(Y(1:N/2))); % Plot only the positive frequencies
    title(['Magnitude Spectrum of ', filePaths{i}]);
    xlabel('Frequency (Hz)');
    ylabel('Magnitude');
    grid on;
end

% Play the sounds sequentially
for i = 1:length(filePaths)
    % Highlight the current waveform plot
    subplot(2, 3, i);
    title(['Playing Waveform of ', filePaths{i}], 'Color', 'red');
    
    % Play the audio
    [audioData, sampleRate] = audioread(filePaths{i});
    disp(['Playing ', filePaths{i}, '...']);
    sound(audioData, sampleRate);
    pause(length(audioData) / sampleRate + 1); % Wait for audio to finish
    
    % Revert the title color
    title(['Waveform of ', filePaths{i}], 'Color', 'black');
end
