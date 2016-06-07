inputTemplate = 'video\test\test_video_X.mp4';
outputTemplate = 'test\testX.mfc';

for i=1:21
    input = strrep(inputTemplate,'X', num2str(i));
    output = strrep(outputTemplate,'X', num2str(i));
    
    disp([input]);
    featureExtractionVisual(input, output);

end