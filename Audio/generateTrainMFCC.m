cleanPath = 'training audio\training_audio_X.wav';
snr10BabblePath = 'train_audio_snr_10_babble\train_audio_10_snr_babble_X.wav';

inputTemplate = cleanPath;
outputTemplate = 'Training MFCC\trainX.mfc';

for i=1:20
    input = strrep(inputTemplate,'X', num2str(i));
    output = strrep(outputTemplate,'X', num2str(i));
    
    [sample,fs] = audioread(input);
    %sample = specsub(sample,fs);
    featureExtraction(sample, fs, output,80);
end