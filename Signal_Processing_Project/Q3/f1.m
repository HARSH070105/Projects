[audio, fs] = audioread('s/Users/anshithapenubolu/Desktop/Project_LouderWordsDetection/audios/1.wav');
audio = audio / max(abs(audio));
frame_duration = 0.02;
frame_size = round(frame_duration * fs);
hop_size = round(frame_size / 2);
num_frames = floor((length(audio) - frame_size) / hop_size) + 1;
energy = zeros(1, num_frames);
for i = 1:num_frames
    frame_start = (i-1) * hop_size + 1;
    frame_end = frame_start + frame_size - 1;
    frame = audio(frame_start:frame_end);
    energy(i) = sum(frame.^2);
end
energy = energy / max(energy);
threshold = mean(energy) + 0.5 * std(energy);
loud_frames = find(energy > threshold);
loud_times = [(loud_frames - 1) * hop_size / fs; loud_frames * hop_size / fs]';
delta = hop_size / fs;
loud_segments = [];
current_start = loud_times(1, 1);
for i = 2:size(loud_times, 1)
    if loud_times(i, 1) - loud_times(i-1, 2) > delta
        loud_segments = [loud_segments; current_start, loud_times(i-1, 2)];
        current_start = loud_times(i, 1);
    end
end
loud_segments = [loud_segments; current_start, loud_times(end, 2)];
fprintf('Louder segments (start and end times in seconds):\n');
disp(loud_segments);
time = (0:length(audio)-1) / fs;
figure;
plot(time, audio); hold on;
plot((0:num_frames-1) * hop_size / fs, energy, 'r');
for i = 1:size(loud_segments, 1)
    x = loud_segments(i, :);
    y = [0, 0];
    line(x, y, 'Color', 'g', 'LineWidth', 2);
end
xlabel('Time (s)');
ylabel('Amplitude / Energy');
legend('Audio Signal', 'Energy', 'Loud Segments');