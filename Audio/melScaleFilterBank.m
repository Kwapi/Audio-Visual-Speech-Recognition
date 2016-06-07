function [ coefficients ] = melScaleFilterbank( mag, numChannels )

%initialise array of size channels
coefficients = zeros(numChannels,1);

%width of melbank filter rectangular frame
frameSizeFreq =round( length(mag)/numChannels);
channelIndex = 1;
%Outer loop (between frames)
for i=1 : numChannels
    
    sum = 0.0;
    
    %Inner loop (averages magnitudes within the frames)
    for j=1 : frameSizeFreq
           
           sum = sum + mag((i-1)*frameSizeFreq + j); 
        
    end
    
    sum = sum/frameSizeFreq;
    coefficients(i) = sum;
       
    channelIndex = channelIndex + 1;
    
    
end

