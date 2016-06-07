inputTemplate = 'video\train\train_video_X.mp4';
outputTemplate = 'train\trainX.mfc';

for i=1:20
    input = strrep(inputTemplate,'X', num2str(i));
    output = strrep(outputTemplate,'X', num2str(i));
    
    featureExtractionVisual(input, output);
end