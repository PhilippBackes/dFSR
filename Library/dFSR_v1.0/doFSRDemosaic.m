function [imgOut] = doFSRDemosaic(sensorImage, theCFAMask, type, fsrParameter)
%DOFSR Universal Demosaicing-Algorithm based on the FSR
%   Universal Demosaicing-Algorithm based on the Frequency Selective
%   Reconstruction as presented by [GenserPCS2018] and [SeilerTIP2015].
%   
%   sensorImage:    input Image to be demosaiced
%   theCFAMask:     logical CFA Mask of Sensor Image 
%   type:           specifies the dFSR demosaicing type
%   fsrParameter:   The FSR Parameter
%
%   dFSR v1.0
%   Implemented by Philipp Backes, 2019

[imHeight, imWidth, ~] = size(sensorImage);

%% SET PARAMETER
if exist('fsrParameter', 'var')
    param = fsrParameter;
else
    param = struct();
    
    param.recSize = 2;
    param.blkSize = 8;
    param.fftSize = 32;
    
    param.rho = 0.5;
    param.oCorr = 0.25;
    param.calcTruth = 0.2;
    
    param.iMin = 32;
    param.iMax = 512;
    param.iConst = param.iMax*3;
    
end

fWeightsLUM = getFrequencyWeights(param.fftSize,'linear');
fWeightsCHR = getFrequencyWeights(param.fftSize,'linear');

%% Prepare IMAGE - Pad Image Border
border = (param.blkSize - param.recSize)/2;
padWidth = border * 2 + ceil(imWidth/param.recSize)*param.recSize;
padHeight = border * 2 + ceil(imHeight/param.recSize)*param.recSize;
padImg = zeros(padHeight, padWidth,3);
padMask = zeros(padHeight, padWidth,3);

if length(size(sensorImage)) == 3
    padImg(border+1:imHeight+border,border+1:imWidth+border,:) = sensorImage;
else
    padImg(border+1:imHeight+border,border+1:imWidth+border,:) = repmat(sensorImage,1,1,3);
end

if length(size(theCFAMask)) == 3
    padMask(border+1:imHeight+border,border+1:imWidth+border,:) = theCFAMask;
else
    padMask(border+1:imHeight+border,border+1:imWidth+border,:) = repmat(theCFAMask,1,1,3);
end

if isinteger(sensorImage)
    padImg = im2double(padImg);
end

%% PROCESS IMAGE

if(~exist('type', 'var'))
    type = '';
end

switch type
    
    case 'diff'
        % process luminance/ green channel
        fullG = processChannel(padImg(:,:,2).*padMask(:,:,2),padMask(:,:,2),param,fWeightsLUM);
        
        % process chrominance / difference
        rg = (padImg(:,:,1) - fullG).*padMask(:,:,1);
        bg = (padImg(:,:,3) - fullG).*padMask(:,:,3);
        fullRG = processChannel(rg,padMask(:,:,1),param,fWeightsCHR);
        fullBG = processChannel(bg,padMask(:,:,3),param,fWeightsCHR);
        
        imgOut = cat(3,(fullG+fullRG),fullG,(fullG+fullBG));
        
     case 'diffLowC'
        % process luminance/ green channel
        fullG = processChannel(padImg(:,:,2).*padMask(:,:,2),padMask(:,:,2),param,fWeightsLUM);
        
        % process chrominance / difference
        rg = (padImg(:,:,1) - fullG).*padMask(:,:,1);
        bg = (padImg(:,:,3) - fullG).*padMask(:,:,3);
        
        % Set new Parameter fpr chrominance channel
        param.recSize = 4;
        param.blkSize = 28;
        param.rho = 0.6;
        param.oCorr = 0.25;
        fWeightsCHR = getFrequencyWeights(param.fftSize,'linearC');

        fullRG = processChannel(rg,padMask(:,:,1),param,fWeightsCHR);
        fullBG = processChannel(bg,padMask(:,:,3),param,fWeightsCHR);
        
        imgOut = cat(3,(fullG+fullRG),fullG,(fullG+fullBG));
        
    case 'ycbcr'
        if isequal(padMask(:,:,1),padMask(:,:,2),padMask(:,:,3))
            padImg = rgb2ycbcr(padImg);
            lum = processChannel(padImg(:,:,1).*padMask(:,:,1),padMask(:,:,1),param,fWeightsLUM);
            cb = processChannel(padImg(:,:,2).*padMask(:,:,1),padMask(:,:,1),param,fWeightsCHR);
            cr = processChannel(padImg(:,:,3).*padMask(:,:,1),padMask(:,:,1),param,fWeightsCHR);
            imgOut = ycbcr2rgb(cat(3,lum,cb,cr));
        end
        
    case 'gcocg'
         % process luminance/ green channel
        fullG = processChannel(padImg(:,:,2).*padMask(:,:,2),padMask(:,:,2),param,fWeightsLUM);
        
        % process chrominance / difference
        cg = (fullG - 0.5.*padImg(:,:,1)).*padMask(:,:,1);
        co = (fullG - 0.5.*padImg(:,:,3)).*padMask(:,:,3);
        fullCG = processChannel(cg,padMask(:,:,1),param,fWeightsCHR);
        fullCO = processChannel(co,padMask(:,:,3),param,fWeightsCHR);
        
        imgOut = cat(3,(fullG-fullCG).*2,fullG,(fullG-fullCO).*2);
        
    case 'luma'
        fullG = processChannel(padImg(:,:,2).*padMask(:,:,2),padMask(:,:,2),param,fWeightsLUM);
        imgOut = fullG;
        
    case 'plane'
        %process each rgb channel seperately
        fullR = processChannel(padImg(:,:,1).*padMask(:,:,1),padMask(:,:,1),param,fWeightsLUM);
        fullG = processChannel(padImg(:,:,2).*padMask(:,:,2),padMask(:,:,2),param,fWeightsLUM);
        fullB = processChannel(padImg(:,:,3).*padMask(:,:,3),padMask(:,:,3),param,fWeightsLUM);
        
        imgOut = cat(3,fullR,fullG,fullB);
        
    otherwise
        %process each rgb channel seperately
        fullR = processChannel(padImg(:,:,1).*padMask(:,:,1),padMask(:,:,1),param,fWeightsLUM);
        fullG = processChannel(padImg(:,:,2).*padMask(:,:,2),padMask(:,:,2),param,fWeightsLUM);
        fullB = processChannel(padImg(:,:,3).*padMask(:,:,3),padMask(:,:,3),param,fWeightsLUM);
        
        imgOut = cat(3,fullR,fullG,fullB);
end

imgOut = imgOut(border+1:imHeight+border,border+1:imWidth+border,:);

end