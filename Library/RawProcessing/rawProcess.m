function [imgOut] = rawProcess(rawImg, rawMetaData,imgType)
%RGB Gain Sets the RGB gain
%   linear interpolation of brightness -> black = 0 / white = 1
%   uses mean black and mean white of image


% get variables and convert to linear
subIFDs = rawMetaData.SubIFDs;
maxSampleValue = subIFDs{1,1}.MaxSampleValue;
activeArea = subIFDs{1,1}.ActiveArea;
defaultCropSize = subIFDs{1,1}.DefaultCropSize;
myWhite = subIFDs{1, 1}.WhiteLevel( 1);
myBlack = subIFDs{1, 1}.BlackLevel( 1);


if(~isfloat(rawImg))
    rawImg = double(rawImg)./maxSampleValue;
end

croppedImage = rawImg(activeArea(1)+1:defaultCropSize(2)+activeArea(1),activeArea(2)+1:defaultCropSize(1)+activeArea(2));

imgOut = croppedImage;

% rgb Gain
gainImg = zeros(size(croppedImage));

if exist('imgType','var') && isequal(imgType, 'ReschartROIWB')
    % get ROIs - white patch and black patch
    posMarker = findReschartMarker(croppedImage);
    mFaktor = [posMarker(3,1)-posMarker(1,1), posMarker(3,2)-posMarker(1,2),posMarker(3,1)-posMarker(1,1),posMarker(3,1)-posMarker(1,1)];
    load('ResChartROIs.mat');
    
    ReschartROI = round(ReschartROI.*mFaktor)+[posMarker(1,1),posMarker(1,2),0,0];
    
    % keep rggb raw
    for i=1:2
        if mod(ReschartROI(i,1),2) == 0 && mod(ReschartROI(i,2),2) == 0
            ReschartROI(i,:) = ReschartROI(i,:)-1;
        elseif mod(ReschartROI(i,1),2) == 0
            ReschartROI(i,1) = ReschartROI(i,1)-1;
        elseif mod(ReschartROI(i,2),2) == 0
            ReschartROI(i,2) = ReschartROI(i,2)-1;
        end
    end
    
    blackPatch = imcrop(croppedImage, ReschartROI(1,:));
    whitePatch = imcrop(croppedImage, ReschartROI(2,:));
    
    meanBlack(1) = mean(mean(blackPatch(1:2:end,1:2:end)));
    meanBlack(2) = (mean(mean(blackPatch(1:2:end,2:2:end)))+mean(mean(blackPatch(2:2:end,1:2:end))))/2;
    meanBlack(3) = mean(mean(blackPatch(2:2:end,2:2:end)));
    meanWhite(1) = mean(mean(whitePatch(1:2:end,1:2:end)));
    meanWhite(2) = (mean(mean(whitePatch(1:2:end,2:2:end)))+mean(mean(whitePatch(2:2:end,1:2:end))))/2;
    meanWhite(3) = mean(mean(whitePatch(2:2:end,2:2:end)));
    gainImg(1:2:end,1:2:end) = (croppedImage(1:2:end,1:2:end)-meanBlack(1))./(meanWhite(2)-meanBlack(1));
    gainImg(2:1:end,1:2:end) = (croppedImage(2:1:end,1:2:end)-meanBlack(2))./(meanWhite(2)-meanBlack(2));
    gainImg(1:2:end,2:1:end) = (croppedImage(1:2:end,2:1:end)-meanBlack(2))./(meanWhite(2)-meanBlack(2));
    gainImg(2:2:end,2:2:end) = (croppedImage(2:2:end,2:2:end)-meanBlack(3))./(meanWhite(2)-meanBlack(3));
    imgOut = gainImg;
else
    myBlackSingle = single(myBlack/maxSampleValue);
    myWhiteSingle = single(myWhite/maxSampleValue);
    faktor = 1/(myWhiteSingle-myBlackSingle);
    gainImg = (croppedImage-myBlackSingle)*faktor;
    imgOut = gainImg;
end

end

