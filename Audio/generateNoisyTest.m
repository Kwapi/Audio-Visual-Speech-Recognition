inputTemplate = 'training audio\training_audio_X.wav';
outputTemplate = 'train_audio_snr_10_babble\train_audio_10_snr_babble_X.wav';

for i=1:20
    input = strrep(inputTemplate,'X', num2str(i));
    output = strrep(outputTemplate,'X', num2str(i));
    
    [sample,fs] = audioread(input);
    sample = resample(sample,16000,fs);
    [noise,fs] = audioread('babble_16k.wav');
    noisySample = addNoise(sample,noise,10);
    audiowrite(output,noisySample,fs);
    output;
end