[speech, fs] = audioread('/Users/anshithapenubolu/Desktop/Project_LouderWordsDetection/audios/1.wav');

filename_txt = '/Users/anshithapenubolu/Desktop/Project_LouderWordsDetection/text/1.txt';
fileID = fopen(filename_txt, 'r');
data = {};
while ~feof(fileID)
    line = fgetl(fileID);
    if ischar(line)
        parts = strsplit(line);
        if length(parts) == 4
            data = [data; parts];
        end
    end
end
fclose(fileID);

words = data(:, 1);
startTimes = str2double(data(:, 2));
endTimes = str2double(data(:, 3));
loudnessMarkers = str2double(data(:, 4));

dataTable = table(words, startTimes, endTimes, loudnessMarkers, ...
    'VariableNames', {'Word', 'StartTime', 'EndTime', 'LoudnessMarker'});

wordEnergies = zeros(height(dataTable), 1);
for i = 1:height(dataTable)

    startSample = round(dataTable.StartTime(i) * fs);
    endSample = round(dataTable.EndTime(i) * fs);
    
    startSample = max(1, startSample);
    endSample = min(length(speech), endSample);

    segment = speech(startSample:endSample);
    energy = sum(segment.^2);
    wordEnergies(i) = energy;
end

disp('Energy of all word segments:');
disp(table(dataTable.Word, wordEnergies, 'VariableNames', {'Word', 'Energy'}));

figure;
bar(wordEnergies);
set(gca, 'xtick', 1:height(dataTable), 'xticklabel', dataTable.Word, 'XTickLabelRotation', 45);
xlabel('Words');
ylabel('Energy');
title('Energy of All Word Segments');
grid on;