inputTemplate = 'test_audio_snr_10_babble\test_audio_10_snr_babble_X.wav';
outputTemplate = 'Test MFCC\testX.mfc';

for i=1:21
    input = strrep(inputTemplate,'X', num2str(i));
    output = strrep(outputTemplate,'X', num2str(i));
    
    [sample,fs] = audioread(input);
    sample = SpectralSubtraction(sample,fs);
    featureExtraction(sample, fs, output,80);
end