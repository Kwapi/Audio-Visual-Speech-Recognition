function [] = getDotsVideoRedSubGreen(inputFilename,outputFilename, threshold)

vidreader = VideoReader(inputFilename);

nFrames = get(vidreader,'NumberOfFrames');

vidwriter = VideoWriter(outputFilename);
vidwriter.FrameRate = 25;



open(vidwriter);

for frame = 1 : nFrames
    frameImg = read(vidreader,frame);
    
    diffImg = frameImg(:,:,1)-frameImg(:,:,2);
    writeVideo(vidwriter,diffImg);
end

close(vidwriter);
end

