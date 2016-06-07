function [ featureVectors ] = featureExtractionVisual( input, threshold,output)

%%load the video
vidreader = VideoReader(input);

noFrames = vidreader.NUMBEROFFRAMES;

%%initialising cropArea
cropArea = 0;
featureVectors = zeros(noFrames,2);

for j=1 : noFrames
    
    frame = read(vidreader,j);

    %%tolerance threshold for green objects
    threshold = 4;

    %%extract markers from the frame and create a binary image
    frameMarkers = getDotsImageGreen(frame,threshold);
    
    %%crop the frame (set the cropping area only for the first frame)
    if(j == 1)
        imshow(frameMarkers);
        cropArea = getrect;
    end
    
    frameMarkers = imcrop(frameMarkers,cropArea);
    
    %% morphological filter - open the image
    se = strel('disk',1);
    frameMarkers = imopen(frameMarkers,se);
    
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
    centerPoint = [(markerFarLeft(1)+markerFarRight(1))/2,
                  (markerFarLeft(2) + markerFarRight(2))/2];
    vislabels(objLabels); hold on;
    plot(centerPoint(1),centerPoint(2),'r+','MarkerSize',20);
    %%pause(0.1);
    hold off;
    
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
    
    %%GET WIDTH AND HEIGHT OF THE SHAPE
    minExtremas = min(markersDataSorted);
    maxExtremas = max(markersDataSorted);
    
    height = maxExtremas(2) - minExtremas(2);   %maxY - minY
    width =  maxExtremas(1) - minExtremas(1);   %maxX - minX
    
    featureVector = [width,height];
    
    featureVectors(j,:) =  transpose(featureVector); 
    
  
end



plot(featureVectors);
legend('width','height')
sampPeriod = 1/25; %25fps

writeToHTKFile(output,featureVectors,sampPeriod);
end

