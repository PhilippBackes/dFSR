function [reconstructedChannel] = processChannel(samples, mask, parameter, fWeights)
%PROCESSCHANNEL process one channel of dFSR
%   samples:    channel Samples
%   mask:       channel mask
%   parameter:  FSR Parameter
%   fwWeights:  FSR frequency Weights
%
%
%   dFSR v1.0
%   Implemented by Philipp Backes, 2019

% PARAMETER
[imHeight, imWidth] = size(samples);

recSize = parameter.recSize;
blkSize = parameter.blkSize;
border = (blkSize-recSize)/2;
fftSize = parameter.fftSize;
rho = parameter.rho;
calcTruthFaktor = parameter.calcTruth;

% Samples Weighting
wDx = repmat(-fftSize/2+1:1:fftSize/2,fftSize,1);
wDy = repmat((-fftSize/2+1:1:fftSize/2)',1,fftSize);
wInit = rho.^(sqrt(wDx.*wDx + wDy.*wDy));


% Block Processing
reconstructedChannel = zeros(size(samples));

for i = 1:recSize:imHeight-blkSize+1
    for j = 1:recSize:imWidth-blkSize+1
        block = samples(i:i+blkSize-1,j:j+blkSize-1);
        blkMask = mask(i:i+blkSize-1,j:j+blkSize-1);
        
        blockOut = computeBlock(block,blkMask,wInit,parameter,fWeights);
        
        reconstructedChannel(i+border:i+border+recSize-1,j+border:j+border+recSize-1) = blockOut;
        
%       UNCOMMENT ONLY IF calcTruthFaktor is set and wanted!        
%       blkMask(blkMask == 0) = calcTruthFaktor;
%       mask(i+border:i+border+recSize-1,j+border:j+border+recSize-1) = blkMask(border+1:recSize+border,border+1:recSize+border);
%       samples(mask==calcTruthFaktor) = reconstructedChannel(mask==calcTruthFaktor);

    end
end

origSamples = find(mask == 1);
reconstructedChannel(origSamples) = samples(origSamples);

end

