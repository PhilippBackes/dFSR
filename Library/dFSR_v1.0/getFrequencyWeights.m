function [frequencyWeights] = getFrequencyWeights(fftSize, weightType)
%GETFREQENCYWEIGHTS get Frequency Weights for FSR
%   fftSize:    Size of fft to be weighted
%   weightType: type of weighting luma linear or chroma linear or none
%
%
%   dFSR v1.0
%   Implemented by Philipp Backes, 2019

frequencyWeights = zeros(fftSize , fftSize/2 + 1);

switch weightType
    case 'linear'
        for y=0:fftSize-1
            for x=0:fftSize/2
                yy = fftSize/2 - abs(y - fftSize/2);
                xx = fftSize/2 - abs(x - fftSize/2);
                frequencyWeights(y+1, x+1) = 1 - sqrt(xx*xx + yy*yy)*sqrt(2)/fftSize;
            end
        end
        
     case 'linearC'
        for y=0:fftSize-1
            for x=0:fftSize/2
                yy = fftSize/2 - abs(y - fftSize/2);
                xx = fftSize/2 - abs(x - fftSize/2);
                frequencyWeights(y+1, x+1) = 1 - sqrt(xx*xx + yy*yy)*sqrt(4)/fftSize;
            end
        end
        frequencyWeights(frequencyWeights<0) = 0;
        
    case 'none'
        frequencyWeights = ones(fftSize , fftSize/2 + 1);
        
    otherwise
        frequencyWeights = ones(fftSize , fftSize/2 + 1);
end

end

