function [marker] = findReschartMarker(img)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% if rgb image extract green channel
if size(size(img),2) == 3
    img = img(:,:,2);
end

[height, width] = size(img);

windowSize =  round(width/5);

if mod(windowSize,2)~= 0
    windowSize = windowSize-1;
end

%% load MarkerImg

markerImg = createReschartCircleMarker(size(img,1));

markerSize = size(markerImg,1);


%% Contrast
black = min(min(img));
white = max(max(img));
img = (img-black)./(white-black);

%% Find Markers
% Upper Left
upLeft = img(1:windowSize,1:windowSize);

nXC2d = normxcorr2(markerImg,upLeft);
nXC2d = imcrop(nXC2d,[markerSize markerSize windowSize windowSize]);

[y x v] = find(nXC2d==(max(max(nXC2d))));

marker(1,:) = [x+floor(markerSize/2) y+floor(markerSize/2)];

% Upper Right
upRight = img(1:windowSize,width-windowSize+1:width);

nXC2d = normxcorr2(markerImg,upRight);
nXC2d = imcrop(nXC2d,[markerSize markerSize windowSize windowSize]);

[y x v] = find(nXC2d==(max(max(nXC2d))));

marker(2,:) = [x+width-windowSize+floor(markerSize/2) y+floor(markerSize/2)];

% Lower Right
LoRight = img(height-windowSize+1:height,width-windowSize+1:width);

nXC2d = normxcorr2(markerImg,LoRight);
nXC2d = imcrop(nXC2d,[markerSize markerSize windowSize windowSize]);

[y x v] = find(nXC2d==(max(max(nXC2d))));

marker(3,:) = [x+width-windowSize+floor(markerSize/2) y+height-windowSize+floor(markerSize/2)];

% Lower Left
loLeft = img(height-windowSize+1:height,1:windowSize);

nXC2d = normxcorr2(markerImg,loLeft);
nXC2d = imcrop(nXC2d,[markerSize markerSize windowSize windowSize]);

[y x v] = find(nXC2d==(max(max(nXC2d))));

marker(4,:) = [x+floor(markerSize/2) y+height-windowSize+floor(markerSize/2)];

% Center

center = img(height/2-windowSize/2:height/2+windowSize/2-1,width/2-windowSize/2:width/2+windowSize/2-1);

nXC2d = normxcorr2(markerImg,center);
nXC2d = imcrop(nXC2d,[markerSize markerSize windowSize windowSize]);

[y x v] = find(nXC2d==(max(max(nXC2d))));

marker(5,:) = [x+width/2-windowSize/2+floor(markerSize/2) y+height/2-windowSize/2+floor(markerSize/2)];
end

