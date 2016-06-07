inputTemplate = 'test_audio_snr_25_babble\test_audio_snr_25_babble_X.wav';
outputTemplate = 'Test MFCC\testX.mfc';

for i=1:21
    input = strrep(inputTemplate,'X', num2str(i));
    output = strrep(outputTemplate,'X', num2str(i));
    
    [sample,fs] = audioread(input);
    sample = specsub(sample,fs);
    featureExtraction(sample, fs, output,100);
end