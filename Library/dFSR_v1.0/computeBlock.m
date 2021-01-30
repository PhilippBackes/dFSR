function [fullBlock] = computeBlock(block,mask,wInit,parameter,fWeights)
%COMPUTEBLOCK reconstruct one Block by FSR
%   Implemented rapid-FSR by [GenserPCS2018] and [SeilerTIP2015] with
%   slight changes made by Philipp Backes.
%   
%   block:      block Samples
%   mask:       block mask
%   wInit:      inital block weighting
%   parameter:  FSR Parameter
%   fwWeights:  FSR frequency Weights
%
%   
%   dFSR v1.0
%   Implemented by Philipp Backes, 2019


% Parameter
recSize = parameter.recSize;
blkSize = parameter.blkSize;
fftSize = parameter.fftSize;
oCorr = parameter.oCorr;
iMin = parameter.iMin;
iMax = parameter.iMax;
iConst = parameter.iConst;

sDev = std(block(mask>0));
iter = iMin + sDev*(iConst-iMin);

if fftSize > blkSize
    padBlock = zeros(fftSize);
    padMask = zeros(fftSize);
    padBlock(floor((fftSize-blkSize)/2)+(1:blkSize),floor((fftSize-blkSize)/2)+(1:blkSize)) = block;
    padMask(floor((fftSize-blkSize)/2)+(1:blkSize),floor((fftSize-blkSize)/2)+(1:blkSize)) = mask;
    block = padBlock;
    mask = padMask;
end

% Create FSR Block Weighting
w = wInit.*mask;
W = fft2(w);
Wpad = [W, W; W, W];

% init signal
G = zeros(fftSize);

% calculate initial residual signal and transform to frequency domain
Rw = fft2(block.*w);
Rw = Rw(1:fftSize, 1:fftSize/2+1);

% % DC estimation - optional
% dcEst = 0;
% tDC = 10;
% if dcEst == 1
%     lowF = abs(Rw(1:2,1:2)).^2;
%     if lowF(1,1) > tDC*lowF(2,1) && lowF(1,1) > tDC*lowF(1,2) && lowF(1,1) > tDC*lowF(2,2)
%         expansion_coefficient = lowF(1,1) / W(1);
%         G(1,1) = fftSize^2 * expansion_coefficient;
%         Rw = Rw -  expansion_coefficient * Wpad(fftSize-1:2*fftSize-1, fftSize-1:fftSize-1+fftSize/2);
%     end
% end

ic = 0;

while(ic < iter && ic < iMax)
    [~, bf2select] = max((abs(Rw(:)).*fWeights(:)));
    bf2select = bf2select(1)-1;
    v = floor(bf2select/fftSize);
    u = mod(bf2select,fftSize);
    % exclude second half of first and middle col
    if (v == 0 && u > fftSize/2 || v == fftSize/2 && u > fftSize/2)
        u_prev = u;
        u = fftSize-u;
        Rw(u+1,v+1) = conj(Rw(u_prev+1,v+1));
    end
    
    % calculate complex conjugate solution
    u_cj = -1; v_cj = -1;
    % fill first lower col (copy from first upper col)
    if (u >= 1 && u < fftSize/2 && v == 0)
        u_cj = fftSize-u;
        v_cj = v;
    end
    % fill middle lower col (copy from first middle col)
    if (u >= 1 && u < fftSize/2 && v == fftSize/2)
        u_cj = fftSize-u;
        v_cj = v;
    end
    % fill first row right (copy from first row left)
    if (u == 0 && v >= 1 && v < fftSize/2)
        u_cj = u;
        v_cj = fftSize-v;
    end
    % fill middle row right (copy from middle row left)
    if (u == fftSize/2 && v >= 1 && v < fftSize/2)
        u_cj = u;
        v_cj = fftSize-v;
    end
    % fill cell upper right (copy from lower cell left)
    if (u >= fftSize/2+1 && v >= 1 && v < fftSize/2)
        u_cj = fftSize-u;
        v_cj = fftSize-v;
    end
    % fill cell lower right (copy from upper cell left)
    if (u >= 1 && u < fftSize/2 && v >= 1 && v < fftSize/2)
        u_cj = fftSize-u;
        v_cj = fftSize-v;
    end
    
    % add coef to model and update residual
    if (u_cj ~= -1 && v_cj ~= -1)
        expansion_coefficient = oCorr * Rw(u+1, v+1) / W(1);
        G(u+1, v+1) = G(u+1, v+1) + fftSize^2 * expansion_coefficient;
        G(u_cj+1, v_cj+1) = conj(G(u+1, v+1));
        Rw = Rw -  expansion_coefficient * Wpad(fftSize-u+1:2*fftSize-u, fftSize-v+1:fftSize-v+1+fftSize/2) ...
            -  conj(expansion_coefficient) * Wpad(fftSize-u_cj+1:2*fftSize-u_cj, fftSize-v_cj+1:fftSize-v_cj+1+fftSize/2);
        ic = ic + 1; % ... as two basis functions were added
    else
        expansion_coefficient = oCorr * Rw(u+1, v+1) / W(1);
        G(u+1, v+1) = G(u+1, v+1) + fftSize^2 * expansion_coefficient;
        Rw = Rw -  expansion_coefficient * Wpad(fftSize-u+1:2*fftSize-u, fftSize-v+1:fftSize-v+1+fftSize/2);
    end
    ic = ic+1;
end

% transform back
g = ifft2(G);

% cut out interpolated pixels
fullBlock = real(g((fftSize-recSize)/2 + (1:recSize),(fftSize-recSize)/2 + (1:recSize)));
end