function [ cFrame ] = getDotsImageGreen( frame, threshold )

%%get green channel
%%extract greyscale original image from the green channel

hsvMap = rgb2hsv(frame);

invSat = 1 - hsvMap(:,:,2);
invSat = invSat*255;
    
          
    cFrame = double (invSat > threshold);
    
end

