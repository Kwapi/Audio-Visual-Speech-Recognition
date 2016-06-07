vidreader = VideoReader('test_video_1.mp4');
frames = read(vidreader);
frame_1_org = read(vidreader,1);
frame_1_cont = getDotsImageGreen(frame_1_org,4);
imshow(frame_1_cont);
cropArea = getrect;
frame_1_cont_cropped = imcrop(frame_1_cont,cropArea);
imshow(frame_1_cont_cropped);