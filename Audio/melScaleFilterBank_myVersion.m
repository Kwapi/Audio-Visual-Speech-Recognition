function [ coefficients ] = melScaleFilterbank( mag, numChannels )

%initialise array of size channels
coefficients = zeros(numChannels,1);

%width of melbank filter rectangular frame
frameSizeFreq =floor( length(mag)/numChannels);
channelIndex = 1;
currentSample = 0;
%Outer loop (between frames)
for i=1 : numChannels
    
    sum = 0.0;
    
    %Inner loop (averages magnitudes within the frames)
    for j=1 : frameSizeFreq
        currentSample = (i-1)*frameSizeFreq + j;
        if( currentSample <= length(mag))
            sum = sum + mag(currentSample); 
        end
    end
    
    if(channelIndex<=numChannels)
     coefficients(channelIndex) = sum/frameSizeFreq;
    end
    
    channelIndex = channelIndex + 1;
    
    
end

