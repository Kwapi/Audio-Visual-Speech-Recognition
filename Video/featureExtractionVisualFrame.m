function [ featureVectors ] = featureExtractionVisual( input,frameNum )

%%load the video
vidreader = VideoReader(input);

%%initialising cropArea
cropArea = 0;

    
    frame = read(vidreader,frameNum);

    %%tolerance threshold for green objects
    threshold = 6;

    %%extract markers from the frame and create a binary image
    frameMarkers = getDotsImageGreen(frame,threshold);
    
    %%crop the frame (set the cropping area only for the first frame)
 
        imshow(frameMarkers);
        cropArea = getrect;

    
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
    
    markersData = zeros(numObjects,4);
    %%x,y,alpha,old
    
    points = zeros(numObjects,1);
    for i=1 : numObjects
        marker = stats(i).Centroid;
        oppositeMag =   centerPoint(2)- marker(2);
        adjacentMag =   centerPoint(1) - marker(1) ;
        alpha = atan2d_custom(oppositeMag,adjacentMag);
        
        markerData = [marker(1),marker(2),alpha,i];
        markersData(i,:,:,:) = markerData;
        
        fprintf('Marker %d : angle %f \n',i,alpha);
        
        
        
    end
    
    markersDataSorted = sortrows(markersData,3);
    
    display('done');
    
    %%TODO: pointless since the distance is going to be the same
   %% markerFarLeftDist = getEuclideanDist(markerFarLeft,centerPoint);
   %% markerFarRightDist = getEuclideanDist(markerFarRight,centerPoint);
   %% 
   %% featureVectors(i,:) = [markerFarLeftDist,markerFarRightDist];
    
  



end

