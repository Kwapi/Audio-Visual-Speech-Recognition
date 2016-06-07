function [ featureVectors ] = featureExtractionVisual(input, output)

%%  load the video
vidreader = VideoReader(input);
noFrames = vidreader.NUMBEROFFRAMES;

%%  initialising cropArea
padx = 60;
pady = 60;
cropArea = [200, 200, 250, 200];
oldCropArea = cropArea;

%%  size of the matrix that gets cropped out of the top left corner of the DCT result
DCTMatrixSize = 5;     %% CURRENTLY BEING TESTED

%%  final number of DCT vectors
DCTVectorsNum = DCTMatrixSize * DCTMatrixSize;

%%  currently width/height + markerDistance + teeth/hole count + DCT
featureVectorsNum = 2 + 12 +1 + DCTVectorsNum;
featureVectors = zeros(noFrames,featureVectorsNum);
circles = zeros(12,2);

for j=1 : noFrames
    
    frame = read(vidreader,j);
    
    %% get a rough crop for the first frame to find mouth area
    if(j ~= 1)
        cropArea(1) = cropArea(1);
        cropArea(2) = cropArea(2);
    end
    
    frame = imcrop(frame, cropArea);
    
    %% TODO de-motionblur image lucy
    if j == 105 %debug
        j=j;
    end

%     psf = fspecial('motion', 8, 90);
%     ftl = deconvlucy(frame, psf, 7);
    
    %% dominant green mask
    r = frame(:,:,1);
    g = frame(:,:,2);
    b = frame(:,:,3);
    gray = rgb2gray(frame);
    gray2 = round(r+g+b)/3;
    grayMean = mean(gray(:));
    gMarkers = g > r & g > b;
%     gMarkers = bwmorph(gMarkers, 'thicken', 1);
%     gMarkers = bwmorph(gMarkers, 'bridge', 1);
%     gMarkers = bwmorph(gMarkers, 'diag', 1);

    %% mask teeth and hole
    darkMask = gray < mean(gray(:)) / 2;
    th = 1.3;
    teethMask = abs(r - g) + abs(r - b) + abs(g - b) < 35 & r > grayMean*th & g > grayMean*th & b > grayMean*th;
    teethMask = teethMask + darkMask;
%     teethMask = abs(r - g) + abs(r - b) + abs(g - b) < 20 & r > 100 & g > 100 & b > 140;
    
    %teethMask = bwmorph(teethMask, 'thicken', 1);
    teethMask = bwmorph(teethMask, 'bridge', 1);
    teethMask = bwareaopen(teethMask, 8);
    teethMask = bwmorph(teethMask, 'thicken', 1);
    teethMask = bwmorph(teethMask, 'bridge', 1);
    teethMask = bwmorph(teethMask, 'thicken', 1);
    teethMask = bwmorph(teethMask, 'bridge', 1);
    teethMask = imfill(teethMask, 'holes');
    
    teethMaskNoCircle = teethMask;
    if j > 3
        ang = 360 / 12;
        for i=1 : 12
            circles(i,:) = [cosd(i*ang) sind(i*ang)] * height/3 + oldCenterPoint;
        end
        circleMask = roipoly(teethMask, circles(:,1), circles(:,2));
        teethMaskNoCircle = teethMask;
        teethMask = logical(teethMask + circleMask);
    end
    
    if j == 34 %debug
        j=j;
    end

    %% search for best 12 green markers
    minMarker = 12;
    n = 99;
    threshold = 1;
    
    while n > minMarker
        diffImg = imsubtract(g, gray);
        tMarkers = diffImg > mean(diffImg(:)) * threshold;
        threshold = threshold + 1;
        
        %estMarkers = ((tMarkers - teethMask) == 1);
        estMarkers = ((tMarkers - teethMask) == 1) .* gMarkers;
        %estMarkers = (gMarkers - teethMask) == 1;
%         estMarkers = bwmorph(estMarkers, 'thicken', 1);
        estMarkers = bwmorph(estMarkers, 'bridge', 1);
%         estMarkers = bwareaopen(estMarkers, 4);
%         estMarkers = bwmorph(estMarkers, 'bridge', 1);

        L = bwlabel(estMarkers);
        s = regionprops(estMarkers, 'Centroid', 'PixelList');
        n = numel(s);
        
        if n < 12
%             imshowpair([frame], [estMarkers teethMask gMarkers tMarkers], 'Montage');
%             pause();
            n=n;
        end
    end
    
    rMarkers = estMarkers;
    
    listM = zeros(n, 4);
    for i=1 : n
        listM(i, 1:2) = [s(i).Centroid(1), s(i).Centroid(2)];
    end
    
    %% remove center deviating spots
    if j > 2
        if j == 33 %debug
            j=j;
        end
        
        % list of marker data: listM - x y dist labelindex
        for i=1 : numel(s)
            dist = getEuclideanDist(oldCenterPoint, s(i).Centroid);
            listM(i, :) = [s(i).Centroid(1) s(i).Centroid(2) dist L(s(i).PixelList(1,2), s(i).PixelList(1,1))];
        end
        listM = sortrows(listM, 3);
            
        for k=1 : 15
            if n < 6
                break;
            end
            
            mdif = diff(listM(:,3));
            listMIdx = find(mdif == max(mdif)) + 1;
            % disp([j max(mdif) listMIdx]);
            if max(mdif) > 13 && listMIdx > n * 3/4
%                 imshow(rMarkers);
%                 pause();
                indm = listM(end, 4);
                L(L == indm) = 0;
                listM = listM(1:end-1, :);
                n = n - 1;
            else
                rMarkers = logical(L);
                break;
            end
            
            rMarkers = logical(L);
            
%             L = bwlabel(rMarkers);
%             s = regionprops(rMarkers, 'Centroid', 'PixelList');
%             n = numel(s);
        end
    end

    markers = rMarkers;
    
    
    
    if(j ~= 1)
        oldCenterPoint = centerPoint;
    end
    centerPoint = [mean(listM(:,1)) mean(listM(:,2))];
    if(j > 2)
        centerPoint = (centerPoint + oldCenterPoint) / 2;
    end
    
%     vislabels(L);
%     hold on;
%     plot(centerPoint(1),centerPoint(2),'r+','MarkerSize',20);
%     hold off;

    if n > 12
        disp 'ERROR: numObject > 12!'
        pause();
    end
    
    markersData = zeros(n, 5);
    % x,y,xdir,ydir,angle
    
    %% sort markers by angle
    for i=1 : n
        oppositeMag = centerPoint(2) - listM(i,2);
        adjacentMag = centerPoint(1) - listM(i,1);
        alpha = atan2d_custom(oppositeMag,adjacentMag);
        
        markersData(i,:) = [listM(i,1), listM(i,2), cosd(alpha), sind(alpha), alpha];
    end
    
    if(j ~= 1)
        oldMarkersDataSorted = markersDataSorted;
    end
    
    markersDataSorted = sortrows(markersData, 5);
    
    %% find missing points using nearest neighbor, and use its last position
    if n < 12 && j ~= 1
        if j == 276 %debug
            j=j;
        end
        
        idx = knnsearch(oldMarkersDataSorted(:,3:4),markersDataSorted(:,3:4));
        newMarkers = oldMarkersDataSorted;
        for i=1 : size(idx, 1)
            newMarkers(idx(i), :) = markersDataSorted(i, :);
        end
        markersDataSorted = newMarkers;
        
        %% add velocity to missing marker at its angle based on neighbor's
        velocity = markersDataSorted - oldMarkersDataSorted;
        idxDiff = setdiff(1:12, idx);
        %% for each missing points, find closest left and right neighbor
        for i=1 : size(idxDiff, 2)
            idxL = find(idx < idxDiff(i), 1, 'last');
            idxR = find(idx > idxDiff(i), 1, 'first');
            if isempty(idxL)
                idxL = idx(size(idx, 1));
            else
                idxL = idx(idxL);
            end
            if isempty(idxR)
                idxR = idx(1);
            else
                idxR = idx(idxR);
            end
            
            xweightL = (1.0 - abs(markersDataSorted(idxL, 3)) + 1) * 1;
            xweightR = (1.0 - abs(markersDataSorted(idxR, 3)) + 1) * 1;
            avgVelocity = (velocity(idxL, 1:2) * xweightL + velocity(idxR, 1:2) * xweightR) / (xweightL + xweightR);
            %avgVelocity = (velocity(idxL, 1:2) + velocity(idxR, 1:2)) / 2;
            markersDataSorted(idxDiff(i), 1:2) = markersDataSorted(idxDiff(i), 1:2) + avgVelocity;
            
%             if avgMag > 10
%                 avgMag = avgMag;
%             end
            
        end
    else
        lastFrame = frame;
    end
    
    %% reestimate centerpoint
    centerPoint = [mean(markersDataSorted(:,1)) mean(markersDataSorted(:,2))];
    if(j > 2)
        centerPoint = (centerPoint + oldCenterPoint) / 2;
    end
    
     lipMask = roipoly(markers, markersDataSorted(:,1), markersDataSorted(:,2));
     
     %imshow(lipMask);
     
     teethMaskCropped = bitand(lipMask,teethMaskNoCircle);
     
     
     lipImg = frame .* uint8(repmat(lipMask, [1,1,3]));
    
     
     imshowpair([frame lipImg], [teethMaskCropped markers teethMask gMarkers tMarkers], 'Montage');
     %pause(0.1);
     
     teethHoleCount = sum(teethMaskCropped(:) == 1);
     
     if (j >= 156)
         
         %pause();
     end
    
    oldCropArea = cropArea;
    cropArea = [centerPoint(1) - padx + oldCropArea(1), centerPoint(2) - pady + oldCropArea(2), padx * 2, pady * 2];
    
    %%  GET WIDTH AND HEIGHT OF THE SHAPE
    minExtremas = min(markersDataSorted(:,1:2));
    maxExtremas = max(markersDataSorted(:,1:2));
    
    height = maxExtremas(2) - minExtremas(2);   %maxY - minY
    width =  maxExtremas(1) - minExtremas(1);   %maxX - minX
    
    %% TRACK THE 12 MARKERS AS FEATURES
    distMarkers = zeros(12, 1);
    for i=1 : size(markersDataSorted, 1)
        distMarkers(i) = getEuclideanDist(markersDataSorted(i, 1:2), centerPoint);
    end
    distMarkers = distMarkers';
    
    %% DCT
    %% don't do dct on the first frame (solved with a hack later)
    %% reason: the bounding box is still not initialised for the first frame
    if(j~=1)
        
        %%  RGB2GRAY
        lipImgGrey = rgb2gray(lipImg);
        
        dct = dct2(lipImgGrey);
       
                
        %%  prepare preview
        dct(DCTMatrixSize+1:end,:)=0;
        dct(:,DCTMatrixSize+1:end)=0;
        %%  display preview
        %imshow(idct2(dct),[0 255]);
        
        
        %%  crop
        dctCropped = dct(1:DCTMatrixSize,:);
        dctCropped = dctCropped(:,1:DCTMatrixSize);
        
        %%  flatten the matrix
        temp = dctCropped';
        dctFinal = temp(:)';
        
        %pause(0.05);
    
        %% prepare feature vector
        featureVector = [width,height,teethHoleCount,distMarkers,dctFinal];

        %%  add to array of featureVectors
        featureVectors(j,:) = featureVector;
    end
    
    %%  hack 1
    if j==1
        featureVector = zeros(1, featureVectorsNum);
        featureVectors(j,:) =  featureVector; 
    end
    
    %pause(0.01);

end

%%  hack 2
featureVectors(1,:) = featureVectors(2,:);

%plot(featureVectors);
%legend('width','height')

sampPeriod = 1/25; %25fps
writeToHTKFile(output,featureVectors,sampPeriod);
end

