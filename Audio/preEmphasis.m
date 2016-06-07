function [ emphasisedFrame ] = preEmphasis( frame )

originalFFT = fft(frame);
%figure;
originalMag = abs(originalFFT);
%plot(originalMag);

% start with 2 to avoid indexing the zero element
for i=2: length(frame)
    frame(i) = frame(i) - 0.97*frame(i-1);
end

emphasisedFFT = fft(frame);
%figure;
emphasisedMag = abs(emphasisedFFT);
%plot(emphasisedMag);

%figure;

emphasisedFrame = frame;
end



