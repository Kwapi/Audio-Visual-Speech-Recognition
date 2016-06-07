function [] = getDotsVideo(inputFilename,outputFilename, threshold)

vidreader = VideoReader(inputFilename);

nFrames = get(vidreader,'NumberOfFrames');

vidwriter = VideoWriter(outputFilename);
vidwriter.FrameRate = 25;



open(vidwriter);

for frame = 1 : nFrames
    frameImg = read(vidreader,frame);
    
    hsv = rgb2hsv(frameImg);
    hue = hsv(:,:,1);
    
    diffImg = imsubtract(hue,rgb2gray(frameImg));
            
    diffImg = double (diffImg > threshold);
    
    writeVideo(vidwriter,diffImg);
end

close(vidwriter);
end

