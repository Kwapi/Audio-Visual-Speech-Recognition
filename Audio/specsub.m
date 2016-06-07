% Noise supression using spectral subtraction
function [ audioout ] = specsub( audio, fs )

% Convert stero audio to mono
if size(audio, 2) == 2
    audio = (audio(:,1) + audio(:,2)) / 2;
end

timewindow = 0.02; % Unit: ms
time = length(audio) / fs; % Track duration in seconds
timeframes = fix(time / timewindow); % Number of frames
samplewindow = fix(length(audio) / timeframes); % Samples per frame
halfsamplewindow = samplewindow / 2; % Samples per frame / 2
noisesampleframes = 5; % How many frames to sample as noise

meanmagnitude = zeros([samplewindow 1]);
audioout = zeros([length(audio) 1]);

for i = 1 : timeframes * 2 - 1
    startsample = (i-1) * halfsamplewindow + 1;
    endsample = (i-1) * halfsamplewindow + samplewindow;
    
    hannwindow = audio(startsample : endsample) .* hann(samplewindow);
    complexspectrum = fft(hannwindow);
    magnitude = abs(complexspectrum);
    phase = angle(complexspectrum);
    
    % Extract mean noise magnitude for first 3 frames
    if i <= noisesampleframes
        meanmagnitude = meanmagnitude + magnitude;
        meanmagnitude = meanmagnitude / noisesampleframes;
        %continue;
    end
    
    cleanspec = magnitude - meanmagnitude;
    
    % Postprocessing
    %cleanspec(cleanspec < 0) = 0;
    
    threshold = 0.01;
    range = abs(min(cleanspec)) + threshold;
    for j = 1 : length(cleanspec)
        if cleanspec(j) < threshold
            x = threshold - cleanspec(j);
            cleanspec(j) = threshold - threshold * x / range;
        end
    end
    
    complexspectrum = cleanspec .* exp(phase * sqrt(-1));
    currentframe = real(ifft(complexspectrum));
    
    audioout(startsample : endsample) = audioout(startsample : endsample) + currentframe;
end

end