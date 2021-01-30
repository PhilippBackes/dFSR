function [center] = findSineStarCenter(inputImg)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

[height, width, samples] = size(inputImg);

windowSize = round(height/20);

if samples~=0
    img = inputImg(height/2-windowSize:height/2+windowSize,width/2-windowSize:width/2+windowSize,2);
else
    img = inputImg(height/2-windowSize:height/2+windowSize,width/2-windowSize:width/2+windowSize);
end

if mod(height,2)~= 0
    height = height-1;
elseif mod(width,2)~= 0
    width = width-1;
end

imgWhite = max(max(img));
imgBlack = min(min(img));

img = (img-imgBlack)./imgWhite;

markerImg = double(imread('Marker.png'))./255;
markerImg = markerImg(:,:,2);
[markerHeight, markerWidth, mSamples] = size(markerImg);

nXC2d = normxcorr2(markerImg,img);
nXC2d = imcrop(nXC2d,[markerWidth markerHeight width height]);

[y x v] = find(nXC2d==(max(max(nXC2d))));

center = [y+markerHeight/2+height/2-windowSize x+markerWidth/2+width/2-windowSize];
end

