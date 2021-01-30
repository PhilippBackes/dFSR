function [idealImg,simImg,theCFAMask] = simulateSensor(pImg,idealImgSize,theCFAPattern,olpf,cfaIn)
%SIMULATE SENSOR Simulates an Image Sensor by subsampling
%   pImg:           Img to be processed
%   idealImgSize:   Output Image Size by [width, height] or scaling Faktor
%   theCFAPattern:  The CFA Pattern to simulate
%   olpf:           std for gaussian blur simulating the OLPF
%   cfaIn:          if input image is RAW the CFA of the input image has to
%                   be specified
%
%   SensorSimulation v1.0
%   Implemented by Philipp Backes, 2019


if ~exist('cfaIn', 'var')
    cfaIn = 'grbg'; % ARRI // Canon --> 'rggb'
end

[pHeight,pWidth,~] = size(pImg);

if length(idealImgSize) == 1
    idealImgSize = floor(([pHeight pWidth])*idealImgSize);
elseif (idealImgSize(1)/pHeight) ~= (idealImgSize(2)/pWidth)
    warning('not the same aspect ratio');
end

pxSize = idealImgSize(1)/pHeight;

% OLPF Simulation
if exist('olpf', 'var')
    if length(size(pImg)) == 2
        pImg(1:2:end,1:2:end) = imgaussfilt(pImg(1:2:end,1:2:end),olpf);
        pImg(2:2:end,1:2:end) = imgaussfilt(pImg(2:2:end,1:2:end),olpf);
        pImg(1:2:end,2:2:end) = imgaussfilt(pImg(1:2:end,2:2:end),olpf);
        pImg(2:2:end,2:2:end) = imgaussfilt(pImg(2:2:end,2:2:end),olpf);
    else
        pImg = imgaussfilt(pImg,olpf);
    end
end

% Get distance Maps
if length(size(pImg)) == 2
    dMapX = repmat(0:pxSize:(pWidth-1)*pxSize,idealImgSize(2),1,2);
    dMapY = repmat((0:pxSize:(pHeight-1)*pxSize)',1,idealImgSize(1),2);
    
    dMapX(:,1:2:end,1) = -1;
    dMapX(:,2:2:end,2) = -1;
    dMapY(1:2:end,:,1) = -1;
    dMapY(2:2:end,:,2) = -1;
    
    linX = repmat((0:idealImgSize(2)-1)',1,pWidth,2);
    linY = repmat((0:idealImgSize(1)-1),pHeight,1,2);
else
    dMapX = repmat(0:pxSize:(pWidth-1)*pxSize,idealImgSize(2),1);
    dMapY = repmat((0:pxSize:(pHeight-1)*pxSize)',1,idealImgSize(1));
    
    linX = repmat((0:idealImgSize(2)-1)',1,pWidth);
    linY = repmat((0:idealImgSize(1)-1),pHeight,1);
end

diffxR = ceil(dMapX)-dMapX;
diffxL = (dMapX+pxSize)-floor(dMapX+pxSize);
diffyU = ceil(dMapY)-dMapY;
diffyO = (dMapY+pxSize)-floor(dMapY+pxSize);

% Calculate Weighting/Filtering Matrix
idxX = (floor(dMapX) == linX) - (floor(dMapX+pxSize) == linX);
idxX = diffxR.*(idxX == 1) + diffxL.*(idxX == -1);
idxX = idxX + (floor(dMapX) == linX) .* (floor(dMapX+pxSize) == linX)*pxSize;

idxY = (floor(dMapY) == linY) - (floor(dMapY+pxSize) == linY);
idxY = diffyU.*(idxY == 1) + diffyO.*(idxY == -1);
idxY = idxY + (floor(dMapY) == linY) .* (floor(dMapY+pxSize) == linY)*pxSize;

% SENSOR SIMULATION --> Project Sensor Pixels on actual Image
if length(size(pImg)) == 2
    switch cfaIn
        case 'grbg'
            r = idxY(:,:,2)'*(pImg*idxX(:,:,1)');
            wr = idxY(:,:,2)'*(ones(size(pImg))*idxX(:,:,1)');
            
            gr = idxY(:,:,2)'*(pImg*idxX(:,:,2)');
            wgr = idxY(:,:,2)'*(ones(size(pImg))*idxX(:,:,2)');
            gb = idxY(:,:,1)'*(pImg*idxX(:,:,1)');
            wgb = idxY(:,:,1)'*(ones(size(pImg))*idxX(:,:,1)');
            
            b = idxY(:,:,1)'*(pImg*idxX(:,:,2)');
            wb = idxY(:,:,1)'*(ones(size(pImg))*idxX(:,:,2)');
            
            idealImg(:,:,1) = r./wr;
            idealImg(:,:,2) = (gr+gb)./(wgr+wgb);
            idealImg(:,:,3) = b./wb;
        case 'rggb'
            r = idxY(:,:,2)'*(pImg*idxX(:,:,2)');
            wr = idxY(:,:,2)'*(ones(size(pImg))*idxX(:,:,2)');
            
            gr = idxY(:,:,2)'*(pImg*idxX(:,:,1)');
            wgr = idxY(:,:,2)'*(ones(size(pImg))*idxX(:,:,1)');
            gb = idxY(:,:,1)'*(pImg*idxX(:,:,2)');
            wgb = idxY(:,:,1)'*(ones(size(pImg))*idxX(:,:,2)');
            
            b = idxY(:,:,1)'*(pImg*idxX(:,:,1)');
            wb = idxY(:,:,1)'*(ones(size(pImg))*idxX(:,:,1)');
            
            idealImg(:,:,1) = r./wr;
            idealImg(:,:,2) = (gr+gb)./(wgr+wgb);
            idealImg(:,:,3) = b./wb;
    end
    
else
    idealImg(:,:,1) = idxY'*(pImg(:,:,1)*idxX');
    idealImg(:,:,2) = idxY'*(pImg(:,:,2)*idxX');
    idealImg(:,:,3) = idxY'*(pImg(:,:,3)*idxX');
end

% Simulate CFA
[simImg,theCFAMask] = simulateCFA(idealImg,theCFAPattern);

end

