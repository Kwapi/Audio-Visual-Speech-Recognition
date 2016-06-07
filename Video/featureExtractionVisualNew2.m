function [ featureVectors ] = featureExtractionVisual(input, output)

%%load the video
vidreader = VideoReader(input);

noFrames = vidreader.NUMBEROFFRAMES;

%%initialising cropArea
padx = 100;
pady = 80;
cropArea = [200, 200, 250, 150];
oldCropArea = cropArea;
featureVectors = zeros(noFrames,2);

for j=1 : noFrames
    
    frame = read(vidreader,j);

    %%tolerance threshold for green objects
    

    %%extract markers from the frame and create a binary image
    %frameMarkers = getDotsImageGreen(frame,threshold);
    
    % find above average high luminance pixels
    threshold = 2;
    diffImg = imsubtract(frame(:,:,2), rgb2gray(frame));
    frameMarkers = diffImg > mean(diffImg(:)) * threshold;
    
    %% morphological filter - open the image
    frameMarkers = imopen(frameMarkers, strel('disk', 1));
    
        
    s = regionprops(frameMarkers,'Centroid');
    n = numel(s);

    while n > 12
        threshold = threshold + 1;
        diffImg = imsubtract(frame(:,:,2), rgb2gray(frame));
        frameMarkers = diffImg > mean(diffImg(:)) * threshold;
        frameMarkers = imopen(frameMarkers, strel('disk', 1));

        s = regionprops(frameMarkers,'Centroid');
        n = numel(s); 
    end
        
    if(j ~= 1)
        cropArea(1) = cropArea(1) + oldCropArea(1);
        cropArea(2) = cropArea(2) + oldCropArea(2);
    end
    
    frameMarkers = imcrop(frameMarkers,cropArea);
    
    %%isolate the markers and set them as separate objects
    [objLabels,numObjects] = bwlabel(frameMarkers);
    
    %%get center of mass for each object
    stats = regionprops(objLabels,'centroid');
    
    %%get position for center of mass of far left and far right markers
    markerFarLeft = stats(1).Centroid;
    markerFarRight = stats(numObjects).Centroid;
    
    %markerXYZ(1) = x value
    %markerXYZ(2) = y value
    
    %find the center point of the mouth from those two markers
    centerPoint = [(markerFarLeft(1) + markerFarRight(1))/2,
                    (markerFarLeft(2) + markerFarRight(2))/2];
    vislabels(objLabels); hold on;
    plot(centerPoint(1),centerPoint(2),'r+','MarkerSize',20);
    %%pause(0.1);
    hold off;
    
    if numObjects > 12
        disp 'ERROR: numObject > 12!'
        imshow(frameMarkers);
        %pause();
    end
    
    markersData = zeros(numObjects,4);
     %%x,y,alpha,old
    
    for i=1 : numObjects
        marker = stats(i).Centroid;
        oppositeMag =   centerPoint(2)- marker(2);
        adjacentMag =   centerPoint(1) - marker(1) ;
        alpha = atan2d_custom(oppositeMag,adjacentMag);
        
        markerData = [marker(1),marker(2),alpha,i];
        markersData(i,:,:,:) = markerData;
        
        
    end
    
    markersDataSorted = sortrows(markersData,3);
    
    lipMask = roipoly(frameMarkers, markersDataSorted(:,1), markersDataSorted(:,2));
    lipCrop = imcrop(frame, cropArea);
    lipImg = lipCrop .* uint8(repmat(lipMask, [1,1,3]));
    imshow(lipImg);
    
    oldCropArea = cropArea;
    cropArea = [centerPoint(1) - padx, centerPoint(2) - pady, padx * 2, pady * 2];
    
    %%GET WIDTH AND HEIGHT OF THE SHAPE
    minExtremas = min(markersDataSorted);
    maxExtremas = max(markersDataSorted);
    
    height = maxExtremas(2) - minExtremas(2);   %maxY - minY
    width =  maxExtremas(1) - minExtremas(1);   %maxX - minX
    
    featureVector = [width,height];
    
    
    featureVectors(j,:) =  transpose(featureVector); 
    
    
    %pause();
  
end

%%hack
featureVectors(1,:) = featureVectors(2,:);

%plot(featureVectors);
%legend('width','height')

sampPeriod = 1/25; %25fps
writeToHTKFile(output,featureVectors,sampPeriod);
end

