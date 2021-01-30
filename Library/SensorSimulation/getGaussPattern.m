function [patternOut] = getGaussPattern(patternSize,density)
%GETICIP2018PATTERN Summary of this function goes here
%   Detailed explanation goes here
if ~exist('density')
    gDensity = 1/2;
else
    gDensity = density;
end

outSize = 0;
if patternSize(1)>128
    outSize = patternSize;
    patternSize = [128 128];
end

rbDensity = (1-gDensity)/2;
iRB = floor(patternSize(2)*patternSize(1)*rbDensity);
iG = floor(patternSize(2)*patternSize(1)*gDensity);

rG = 7;
rRB = rG*gDensity;

if iG+iRB*2 ~= patternSize(1)*patternSize(2)
    diff = (patternSize(1)*patternSize(2)) - (iG+iRB*2);
    iG = iG+diff;
end

patternSize = patternSize+2;
posX = repmat(1:patternSize(2),patternSize(1),1);
posY = repmat((1:patternSize(1))',1,patternSize(2));

patternG = zeros(patternSize);
pG = ones(patternSize);

while sum(sum(patternG(2:end-1,2:end-1))) < iG
    ind = find(pG == 1);
    if isempty(ind)
        ind = find(pG==max(max(pG)));
    end
    [y, x] = ind2sub(size(patternG),ind(randi(length(ind))));
    patternG(y,x) = 1;
    distMap = ((posX-x).*(posX-x) + (posY-y).*(posY-y))./4;
    pG = pG.*((1 - exp(-distMap)).^rG);
end

patternRB = zeros([patternSize 2]);
pRB = ones([patternSize 2]);

while sum(sum(patternRB(2:end-1,2:end-1,1))) < iRB
    for c = 1:2
        c0 = abs(2-c)+1;
        pC = pRB(:,:,c) & patternG == 0 & patternRB(:,:,c0) == 0;
        ind = find(pC);
        if isempty(ind)
            ind = find(pC==max(max(pC)));
        end
        [y, x] = ind2sub(size(patternG),ind(randi(length(ind))));
        patternRB(y,x,c) = 1;
        distMap = ((posX-x).*(posX-x) + (posY-y).*(posY-y))./4;
        pRB(:,:,c) = pRB(:,:,c).*((1 - exp(-distMap)).^rRB);
    end
end

patternOut = zeros([(patternSize - 2) 3]);
patternOut(:,:,1) = patternRB(2:end-1,2:end-1,1);
patternOut(:,:,2) = patternG(2:end-1,2:end-1);
patternOut(:,:,3) = patternRB(2:end-1,2:end-1,2);

patternOut = logical(patternOut);

if ~(outSize==0)
    patternOut = repmat(patternOut,ceil(outSize(1)/patternSize(1)),ceil(outSize(2)/patternSize(2)),1);
    patternOut = patternOut(1:outSize(1),1:outSize(2),:);
end

end