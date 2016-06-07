cleanPath = 'training audio\training_audio_X.wav';


inputTemplate = cleanPath;
outputTemplate = 'Training MFCC\trainX.mfc';

for i=1:20
    input = strrep(inputTemplate,'X', num2str(i));
    output = strrep(outputTemplate,'X', num2str(i));
   
    featureExtractionVisual(input, fs, output,100);
    
end