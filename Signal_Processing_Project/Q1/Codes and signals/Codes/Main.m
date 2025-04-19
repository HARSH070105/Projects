%%%%%%%%%%%%%%%%%%%% INPUT FORMATTING %%%%%%%%%%%%%%%%%%%%%%
file_path = 'F1.wav';
[input_audio_file, fs] = audioread(file_path);
input = input_audio_file(:);
time = linspace(0, length(input_audio_file) / fs, length(input_audio_file));
    N = length(input_audio_file); 
    Y = fft(input_audio_file); 
    f = (0:N-1) * (fs / N); 

%%%%%%%%%%%%%%%%%%%% REFERENCE SIGNALS %%%%%%%%%%%%%%%%%%%%%
[bird1, sampleRate1] = audioread('bird1.wav');
B1f = flipud(bird1(:));
time1 = linspace(0, length(bird1) / sampleRate1, length(bird1));
    N1 = length(bird1);
    Y1 = fft(bird1);
    f1 = (0:N1-1) * (sampleRate1 / N1); 

[bird2, sampleRate2] = audioread('bird2.wav');
B2f = flipud(bird2(:));
time2 = linspace(0, length(bird2) / sampleRate2, length(bird2));
    N2 = length(bird2); 
    Y2 = fft(bird2); 
    f2 = (0:N2-1) * (sampleRate2 / N2); 

[bird3, sampleRate3] = audioread('bird3.wav');
B3f = flipud(bird3(:));
time3 = linspace(0, length(bird3) / sampleRate3, length(bird3));
    N3 = length(bird3); 
    Y3 = fft(bird3); 
    f3 = (0:N3-1) * (sampleRate3 / N3); 

%%%%%%%%%%%%%%%%%%%% CROSS CORRELATION %%%%%%%%%%%%%%%%%%%%%
figure

% Correlation with Bird 1
output_1 = conv(input, B1f);
subplot(3, 1, 1);
plot(output_1);
title('Correlation with Bird 1');
xlabel('Samples');
ylabel('Amplitude');
ccb1 = max(output_1);
fprintf('The correlation with Bird 1 is %f\n', ccb1);

% Correlation with Bird 2
output_2 = conv(input, B2f);
subplot(3, 1, 2);
plot(output_2);
title('Correlation with Bird 2');
xlabel('Samples');
ylabel('Amplitude');
ccb2 = max(output_2);
fprintf('The correlation with Bird 2 is %f\n', ccb2);

% Correlation with Bird 3
output_3 = conv(input, B3f);
subplot(3, 1, 3);
plot(output_3);
title('Correlation with Bird 3');
xlabel('Samples');
ylabel('Amplitude');
ccb3 = max(output_3);
fprintf('The correlation with Bird 3 is %f\n', ccb3);

%%%%%%%%%%%%%%%%%%%% COMPARISONS %%%%%%%%%%%%%%%%%%%%%%%%%%%
maximum_val = max([ccb1, ccb2, ccb3]);

%%%%%%%%%%%%%% IF BIRD 1 %%%%%%%%%%%%%%
if maximum_val == ccb1
  disp('The sound of the bird present here is of BIRD 1');
  figure
    subplot(2, 2, 1);
    plot(time1, bird1);
    title('Waveform of bird1');
    xlabel('Time (s)');
    ylabel('Amplitude');
    grid on;

    subplot(2, 2, 3);
    plot(f1(1:N1/2), abs(Y1(1:N1/2))); 
    title('Magnitude Spectrum of bird1');
    xlabel('Frequency (Hz)');
    ylabel('Magnitude');
    grid on;

    subplot(2,2,2)
    plot(time, input_audio_file);
    title('Waveform of the given bird');
    xlabel('Time (s)');
    ylabel('Amplitude');
    grid on;

    subplot(2, 2, 4);
    plot(f(1:N/2), abs(Y(1:N/2))); 
    title('Magnitude Spectrum of the given bird');
    xlabel('Frequency (Hz)');
    ylabel('Magnitude');
    grid on;

    disp(' ');
    disp('Playing sound of bird1 from refernces')
    sound(bird1, sampleRate1);
    pause(length(bird1) / sampleRate1 + 1); % Wait for audio to finish
    
    disp('Playing sound of the given bird')
    sound(input_audio_file,fs);

%%%%%%%%%%%%%% IF BIRD 2 %%%%%%%%%%%%%%
elseif maximum_val == ccb2
  disp('The sound of the bird present here is of BIRD 2');
  figure
    subplot(2, 2, 1);
    plot(time2, bird2);
    title('Waveform of bird2');
    xlabel('Time (s)');
    ylabel('Amplitude');
    grid on;

    subplot(2, 2, 3);
    plot(f2(1:N2/2), abs(Y2(1:N2/2))); 
    title('Magnitude Spectrum of bird2');
    xlabel('Frequency (Hz)');
    ylabel('Magnitude');
    grid on;

    subplot(2,2,2)
    plot(time, input_audio_file);
    title('Waveform of the given bird');
    xlabel('Time (s)');
    ylabel('Amplitude');
    grid on;

    subplot(2, 2, 4);
    plot(f(1:N/2), abs(Y(1:N/2))); 
    title('Magnitude Spectrum of the given bird');
    xlabel('Frequency (Hz)');
    ylabel('Magnitude');
    grid on;
    disp(' ');
    disp('Playing sound of bird2 from refernces')
    sound(bird2, sampleRate2);
    pause(length(bird2) / sampleRate2 + 1); % Wait for audio to finish
    
    disp('Playing sound of the given bird')
    sound(input_audio_file,fs);


%%%%%%%%%%%%%% IF BIRD 3 %%%%%%%%%%%%%%
elseif maximum_val == ccb3
  disp('The sound of the bird present here is of BIRD 3');
  figure
    subplot(2, 2, 1);
    plot(time3, bird3);
    title('Waveform of bird3');
    xlabel('Time (s)');
    ylabel('Amplitude');
    grid on;

    subplot(2, 2, 3);
    plot(f3(1:N3/2), abs(Y3(1:N3/2))); 
    title('Magnitude Spectrum of bird3');
    xlabel('Frequency (Hz)');
    ylabel('Magnitude');
    grid on;

    subplot(2,2,2)
    plot(time, input_audio_file);
    title('Waveform of the given bird');
    xlabel('Time (s)');
    ylabel('Amplitude');
    grid on;

    subplot(2, 2, 4);
    plot(f(1:N/2), abs(Y(1:N/2))); 
    title('Magnitude Spectrum of the given bird');
    xlabel('Frequency (Hz)');
    ylabel('Magnitude');
    grid on;

    disp(' ');
    disp('Playing sound of bird3 from refernces')
    sound(bird3, sampleRate3);
    pause(length(bird3) / sampleRate3 + 1); % Wait for audio to finish
    
    disp('Playing sound of the given bird')
    sound(input_audio_file,fs);
end
