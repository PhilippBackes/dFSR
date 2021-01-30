function [circleMarker] = createReschartCircleMarker(imgSize)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

markerSize = ceil(imgSize/100);

if mod(markerSize,2) == 0
    markerSize = markerSize+1;
end

radius = markerSize./2;
innerRadius = markerSize./6;
circleMarker = zeros(markerSize,markerSize);

pixelVPos = repmat((1:1:markerSize)',1,markerSize);
pixelHPos = repmat(1:1:markerSize,markerSize,1);

distMap =  (pixelVPos-(markerSize+1)/2).^2 + (pixelHPos-(markerSize+1)/2).^2;

circleMarker(distMap <= radius.^2) = 1;
circleMarker(distMap <= innerRadius.^2) = 0;

end

