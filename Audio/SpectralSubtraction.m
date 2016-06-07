function [audioout] = SpectralSubtraction(audio,fs)
%Load in noisy speech file
noisySpeech = audio;
numSamples = length(noisySpeech);

frameSizeMS = 0.02; %20ms
overlapSizeMS = 0.01; %10ms
overlapSizeSamples = overlapSizeMS * fs; %size in samples
frameSizeSamples = frameSizeMS * fs;     %size in samples   


%GET THE NOISE ESTIMATE
noiseEstimate = 0.0;
noiseEstimateSum = 0.0;
noiseEstimateNumFrames = 0;
noiseEstimateSample = noisySpeech(numSamples - 1000 : numSamples -1);
noiseFrameIndex = 1;

for  j=1 : overlapSizeSamples : length(noiseEstimateSample) - frameSizeSamples - 1
    
    startFrame = j;
    endFrame = j + frameSizeSamples;
    frame = noiseEstimateSample(startFrame:endFrame);
    %Extract frame and apply Hann window
    hannedFrame = hann(length(frame)) .* frame;
    %Take FFT to obtain complex spectrum
    complexSpectrum = fft(hannedFrame);
    %Convert to magnitude spectrum
    mag = abs(complexSpectrum);
    %mag = mag(1:length(mag)/2);
    
    noiseEstimateSum = noiseEstimateSum + mag;
    
    noiseFrameIndex = noiseFrameIndex + 1;
       
end

noiseEstimate = noiseEstimateSum/noiseFrameIndex;

cleanSpeech = zeros(length(noisySpeech),1);

%MAIN LOOP
%loop by calculating new frame after every overlap period
for  i=1 : overlapSizeSamples : length(noisySpeech) - frameSizeSamples - 1
    startFrame = i;
    endFrame = i + frameSizeSamples;
    frame = noisySpeech(startFrame:endFrame);
    %Extract frame and apply Hann window
    hannedFrame = hann(length(frame)) .*frame;
    %Take FFT to obtain complex spectrum
    complexSpectrum = fft(hannedFrame);
    %Convert to magnitude spectrum
    mag = abs(complexSpectrum);
    %mag = mag(1:length(mag)/2);
    %Convert to phase spectrum
    phase = angle(complexSpectrum);
    %phase = phase(1:length(phase)/2);
    
    %apply spectral subtraction to noisy magnitude spectrum
    subtracted = mag - noiseEstimate;
    
    %post-processing 
    subtracted(subtracted<0)=0;
    
    
    %Combine enhanced magnitude spectrum with noisy phase to
    %get complex spectrum
    complexSpectrum2 = subtracted.* exp(phase* sqrt(-1));
        
    %Take inverse FFT
    infft = ifft(complexSpectrum2);
    
    
    cleanSpeech(startFrame:endFrame) = cleanSpeech(startFrame:endFrame) + infft;
end

cleanSpeech = real(cleanSpeech);

audioout = cleanSpeech;

end