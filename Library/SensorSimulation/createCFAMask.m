function theCFAMask = createCFAMask(type,imgSize)
%CREATECFAMASK  creates a specified CFA Pattern on a RGB Image
%   type:       The CFA Pattern to be created
%   imgSize:    Size of the pattern
%
%   SensorSimulation v1.0
%   Implemented by Philipp Backes, 2019

theCFAMask = zeros([imgSize,3],'logical');

switch type
    case 'rggb'
        theCFAMask(1:2:end,1:2:end,1) = true;
        theCFAMask(2:2:end,1:2:end,2) = true;
        theCFAMask(1:2:end,2:2:end,2) = true;
        theCFAMask(2:2:end,2:2:end,3) = true;
    case 'grbg'
        theCFAMask(1:2:end,2:2:end,1) = true;
        theCFAMask(1:2:end,1:2:end,2) = true;
        theCFAMask(2:2:end,2:2:end,2) = true;
        theCFAMask(2:2:end,1:2:end,3) = true;
    case 'gbrg'
        theCFAMask(2:2:end,1:2:end,1) = true;
        theCFAMask(1:2:end,1:2:end,2) = true;
        theCFAMask(2:2:end,2:2:end,2) = true;
        theCFAMask(1:2:end,2:2:end,3) = true;
    case 'bggr'
        theCFAMask(2:2:end,2:2:end,1) = true;
        theCFAMask(1:2:end,2:2:end,2) = true;
        theCFAMask(2:2:end,1:2:end,2) = true;
        theCFAMask(1:2:end,1:2:end,3) = true;
    case 'Random'
        randPattern = randi(4,imgSize);
        theCFAMask(:,:,1) = randPattern == 1;
        theCFAMask(:,:,2) = (randPattern == 2 | randPattern == 4);
        theCFAMask(:,:,3) = randPattern == 3;
    case 'RandomQuarterRGB'
        randPattern = zeros(imgSize);
        for i = 1:2:imgSize(1)-1
            for j = 1:2:imgSize(2)-1
                randPattern(i:i+1,j:j+1) = reshape(randperm(4),[2,2]);
            end
        end
        theCFAMask(:,:,1) = randPattern == 1;
        theCFAMask(:,:,2) = (randPattern == 2 | randPattern == 4);
        theCFAMask(:,:,3) = randPattern == 3;
    case 'RandomQuarter'
        randPattern = zeros(imgSize);
        for i = 1:2:imgSize(1)-1
            for j = 1:2:imgSize(2)-1
                randPattern(i:i+1,j:j+1) = reshape(randperm(4),[2,2]);
            end
        end
        theCFAMask = repmat(randPattern == 1,1,1,3);
    case 'RandomICIP2018'
        patternSize = 32;
        randPattern = getICIP2018pattern([patternSize patternSize]);
        randPattern = repmat(randPattern,ceil(imgSize(1)/patternSize),ceil(imgSize(1)/patternSize),1);
        theCFAMask = randPattern(1:imgSize(1),1:imgSize(2),:);
    case 'RandomICIP2018rgb'
        patternSize = 32;
        randPattern = getICIP2018pattern([patternSize patternSize 3]);
        randPattern = repmat(randPattern,ceil(imgSize(1)/patternSize),ceil(imgSize(1)/patternSize),1);
        theCFAMask = randPattern(1:imgSize(1),1:imgSize(2),:);
    case 'Condat'
        theCFAMask = getCondatPattern(imgSize);
    case 'Gauss'
        theCFAMask = getGaussPattern(imgSize);
    case 'Gauss33'
        theCFAMask = getGaussPattern(imgSize,1/3);
    case 'Gauss25'
        theCFAMask = getGaussPattern(imgSize,0.25);
end