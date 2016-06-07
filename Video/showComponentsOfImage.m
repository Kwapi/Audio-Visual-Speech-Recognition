vidreader = VideoReader('test_video_1.mp4');

rgbFrame = read(vidreader,70);
figure('Name','RGB Original','NumberTitle','off');
imshow(rgbFrame);

red = rgbFrame(:,:,1);
figure('Name','Red Channel','NumberTitle','off');
imshow(red);

green = rgbFrame(:,:,2);
figure('Name','Green Channel','NumberTitle','off');
imshow(green);

blue = rgbFrame(:,:,3);
figure('Name','Blue Channel','NumberTitle','off');
imshow(blue);

ycbcrmap = rgb2ycbcr(rgbFrame);

luma = ycbcrmap(:,:,1);
figure('Name','Luma Channel','NumberTitle','off');
imshow(luma);

blueDiff = ycbcrmap(:,:,2);
figure('Name','Blue-Difference Chroma Channel','NumberTitle','off');
imshow(blueDiff);

redDiff = ycbcrmap(:,:,3);
figure('Name','Red-Difference Chroma Channel','NumberTitle','off');
imshow(redDiff);

hsvmap = rgb2hsv(rgbFrame);

hue = hsvmap(:,:,1);
figure('Name','Hue Channel','NumberTitle','off');
imshow(hue);

saturation = hsvmap(:,:,2);
figure('Name','Saturation Channel','NumberTitle','off');
imshow(saturation);

value = hsvmap(:,:,3);
figure('Name','Value Channel','NumberTitle','off');
imshow(value);

autoArrangeFigures(0,0);




