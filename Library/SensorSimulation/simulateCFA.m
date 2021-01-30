function [simulatedSensorImg, theCFAMask] = simulateCFA(fullRGBImg,theCFAPattern)
%SIMULATECFA Simulates a specified CFA Pattern on a RGB Image
%   fullRGBImg:     full RGB Img to be processed
%   theCFAPattern:  The CFA Pattern to be simulated
%
%   SensorSimulation v1.0
%   Implemented by Philipp Backes, 2019


if exist('theCFAPattern', 'var') && islogical(theCFAPattern)
    theCFAMask = theCFAPattern; 
elseif exist('theCFAPattern', 'var') && ischar(theCFAPattern)
    theCFAMask = createCFAMask(theCFAPattern,size(fullRGBImg(:,:,1)));
else
    theCFAMask = createCFAMask('grbg',size(fullRGBImg(:,:,1)));
end


maskedImg = fullRGBImg.*theCFAMask;
simulatedSensorImg = maskedImg(:,:,1)+maskedImg(:,:,2)+maskedImg(:,:,3);

end

