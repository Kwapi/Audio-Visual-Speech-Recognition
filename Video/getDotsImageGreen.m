function [ cFrame ] = getDotsImageGreen( frame, threshold )

%%get green channel
%%extract greyscale original image from the green channel
greenImg = frame(:,:,2);
    
    diffImg = imsubtract(greenImg,rgb2gray(frame));
          
    cFrame = double (diffImg > threshold);
    
end

