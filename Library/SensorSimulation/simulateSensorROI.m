function [simImg] = simulateSensorROI(pImg,pROI,rImg,rROI,tform,OLPF,theCFAPattern)
%SIMULATESENSOR 
%   Calculates an ideal RGB Image and simulates a Sensor-CFA
%   pImg/rImg - Processing Image / Reference Image
%   pROI/rROI - Rectangle describing the ROIs
%   tform - the Transformation Matrix
%   OLPF - sdv for gaussian blur
%   theCFAPattern - Name of CFAPattern or 3-D logical Array

% get scale and  processing Image plus needed border
pxSize = double(size(rImg,1))/size(pImg,1);
scale = rROI(3)/pROI(3);

border = ceil(max(abs(tform(3,1:2)./(pxSize*scale)))*2);
pROI = [pROI(1:2)-border, (pROI(3:4)+border*2)];
borderImg = pImg(pROI(2):pROI(2)+pROI(4)-1,pROI(1):pROI(1)+pROI(3)-1,:);

% OLPF Simulation
if exist('OLPF','var') && OLPF>0
    borderImg = imgaussfilt(borderImg,OLPF);
end

% Get Pixel Coordinates and Transform them with tform
dMapX = -border*pxSize:pxSize:(pROI(3)-border-1)*pxSize;
dMapY = -border*pxSize:pxSize:(pROI(4)-border-1)*pxSize;

linX = 0:rROI(3)-1;
linY = 0:rROI(4)-1;

tMapX = [repmat(dMapX,1,rROI(3));reshape(repmat(linX,pROI(3),1),[1 pROI(3)*rROI(3)]);ones(1,pROI(3)*rROI(3))];
tMapX = tMapX'*tform;
tMapY = [reshape(repmat(linY,pROI(4),1),[1 pROI(4)*rROI(4)]);repmat(dMapY,1,rROI(4));ones(1,pROI(4)*rROI(4))];
tMapY = tMapY'*tform;

dMapX = reshape(tMapX(:,1),[pROI(3) rROI(3)])';
dMapY = reshape(tMapY(:,2),[pROI(4) rROI(4)]);

diffxR = ceil(dMapX)-dMapX;
diffxL = (dMapX+pxSize)-floor(dMapX+pxSize);
diffyU = ceil(dMapY)-dMapY;
diffyO = (dMapY+pxSize)-floor(dMapY+pxSize);

% Calculate Weighting/Filtering Matrix
linX = repmat((0:rROI(3)-1)',1,size(borderImg,2));
linY = repmat((0:rROI(4)-1),size(borderImg,1),1);

idxX = (floor(dMapX) == linX) - (floor(dMapX+pxSize) == linX);
idxX = diffxR.*(idxX == 1) + diffxL.*(idxX == -1);
idxX = idxX + (floor(dMapX) == linX) .* (floor(dMapX+pxSize) == linX)*pxSize;

idxY = (floor(dMapY) == linY) - (floor(dMapY+pxSize) == linY);
idxY = diffyU.*(idxY == 1) + diffyO.*(idxY == -1);
idxY = idxY + (floor(dMapY) == linY) .* (floor(dMapY+pxSize) == linY)*pxSize;

idealImg(:,:,1) = idxY'*(borderImg(:,:,1)*idxX');
idealImg(:,:,2) = idxY'*(borderImg(:,:,2)*idxX');
idealImg(:,:,3) = idxY'*(borderImg(:,:,3)*idxX');

% Get CFA Pattern and simulate Sensor
if exist('theCFAPattern') && islogical(theCFAPattern)
    theCFAMask = theCFAPattern; 
elseif exist('theCFAPattern') && ischar(theCFAPattern)
    theCFAMask = createCFAMask(theCFAPattern,[rROI(4),rROI(3)]);
else
    theCFAMask = createCFAMask('rggb',[rROI(4),rROI(3)]);
end

simImg = zeros(rROI(4),rROI(3));
maskedImg = idealImg.*theCFAMask;
simImg = maskedImg(:,:,1)+maskedImg(:,:,2)+maskedImg(:,:,3);

if exist('theCFAPattern') && strcmp(theCFAPattern,'RandomQuarter')
    save('RandomCFAMask.mat','theCFAMask');
end

end

