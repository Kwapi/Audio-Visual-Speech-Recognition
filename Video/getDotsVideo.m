function [] = getDotsVideo(inputFilename,outputFilename, threshold)

vidreader = VideoReader(inputFilename);

nFrames = get(vidreader,'NumberOfFrames');

vidwriter = VideoWriter(outputFilename);
vidwriter.FrameRate = 25;



open(vidwriter);

for frame = 1 : nFrames
    frameImg = read(vidreader,frame);
    
    greenImg = frameImg(:,:,2);
    
    diffImg = imsubtract(greenImg,rgb2gray(frameImg));
            
    diffImg = double (diffImg > threshold);
    
    writeVideo(vidwriter,diffImg);
end

close(vidwriter);
end

