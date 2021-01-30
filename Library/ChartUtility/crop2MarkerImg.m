function [imgOut] = crop2MarkerImg(img)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

marker = findReschartMarker(img);
marker = round(marker);
if mod(marker(1,1),2)== 0
    marker(1,1) = marker(1,1) - 1;
end
if mod(marker(1,2),2)== 0
    marker(1,1) = marker(1,1) - 1;
end

croppedImg = img(marker(1,2):marker(3,2),marker(1,1):marker(3,1));

imgOut = croppedImg;
end

