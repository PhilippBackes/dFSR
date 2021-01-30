function [output] = doFastRandDemosaic(input, theCFAMask)
% The input can be on one channel, uint16 or double
%
% Output = a complete RGB image on 3 channels, half the size of the input
% image

%even number of rows and cols:
[NumY, NumX, c] = size( input);
if mod( NumY, 2)
    input( end, :) = [];
    theCFAMask( end, :) = [];
end
if mod( NumX, 2)
    input( :, end) = [];
    theCFAMask( :, end) = [];
end

%color separation
myR = input.*theCFAMask(:,:,1);
myG = input.*theCFAMask(:,:,2);
myB = input.*theCFAMask(:,:,3);


if class( input) == 'uint16'
    myG = uint16( (myG(1:2:end,1:2:end)+myG(2:2:end,1:2:end)+myG(1:2:end,2:2:end)+myG(2:2:end,2:2:end)) / 2);
elseif class( input) == 'double'
    myG = (myG(1:2:end,1:2:end)+myG(2:2:end,1:2:end)+myG(1:2:end,2:2:end)+myG(2:2:end,2:2:end)) / 2;
elseif class( input) == 'single'
    myG = (myG(1:2:end,1:2:end)+myG(2:2:end,1:2:end)+myG(1:2:end,2:2:end)+myG(2:2:end,2:2:end)) / 2;
else
    output = [];
    return;
end

output = zeros( NumY/2, NumX/2, 3, class( input));
output( :, :, 1) = myR(1:2:end,1:2:end)+myR(2:2:end,1:2:end)+myR(1:2:end,2:2:end)+myR(2:2:end,2:2:end);
output( :, :, 2) = myG;
output( :, :, 3) = myB(1:2:end,1:2:end)+myB(2:2:end,1:2:end)+myB(1:2:end,2:2:end)+myB(2:2:end,2:2:end);
