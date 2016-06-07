function [ featureVectors ] = featureExtractionVisual(input, output)

%%load the video
vidreader = VideoReader(input);

noFrames = vidreader.NUMBEROFFRAMES;

%%initialising cropArea
cropArea = 0;
featureVectors = zeros(noFrames,2);

for j=1 : noFrames
    
    frame = read(vidreader,j);

    %%tolerance threshold for green objects
    

    %%extract markers from the frame and create a binary image
    %frameMarkers = getDotsImageGreen(frame,threshold);
    
    % find above average high luminance pixels
    threshold = 3;
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
        
    if(j == 1)
%         x = (s(1).Centroid(1) + s(n).Centroid(1)) / 2;
%         y = (s(1).Centroid(2) + s(n).Centroid(2)) / 2;
%         padx = 100;
%         pady = 120;
%         cropArea = [x - padx, y - pady, padx, pady];

        %%crop the frame (set the cropping area only for the first frame)
        %imshow(frameMarkers);
        %cropArea = getrect;
        cropArea = [200, 200, 250, 150];
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
    lipCrop = imcrop(frame,cropArea);
    lipImg = lipCrop .* uint8(repmat(lipMask, [1,1,3]));
    %imshow(lipImg);
    
    %%GET WIDTH AND HEIGHT OF THE SHAPE
    minExtremas = min(markersDataSorted);
    maxExtremas = max(markersDataSorted);
    
    height = maxExtremas(2) - minExtremas(2);   %maxY - minY
    width =  maxExtremas(1) - minExtremas(1);   %maxX - minX
    
    
    
    
    %DCT
    %%don't do dct on the first frame
    if(j~=1)
        lipImgGrey = rgb2gray(lipImg);
        
        dct = dct2(lipImgGrey);
       
        size = 15;
        
        %%display
        dct(size+1:end,:)=0;
        dct(:,size+1:end)=0;
        %%preview
        imshow(idct2(dct),[0 255]);
        
        
        %%crop
        dctCropped = dct(1:size,:);
        dctCropped = dctCropped(:,1:size);
        
        %%flatten the matrix
        temp = dctCropped';
        dctFinal = temp(:)';
        
        pause(0.05);
        
    end
    
    
    
    %%ADD THE DCT TODO
    featureVector = [width,height];
    
    featureVectors(j,:) =  transpose(featureVector); 
    
    %pause();
  
end



%plot(featureVectors);
%legend('width','height')

sampPeriod = 1/25; %25fps
writeToHTKFile(output,featureVectors,sampPeriod);
end

