function [patternOut] = getICIP2018pattern(patternSize)
%GETICIP2018PATTERN Summary of this function goes here
%   Detailed explanation goes here

lum = 0;
if length(patternSize) == 2
    lum = 1;
end
patternSize = patternSize(1:2);

tmpPattern = zeros(patternSize);
% get simple random quarter mask
for i = 1:2:patternSize(1)-1
    for j = 1:2:patternSize(2)-1
        tmpPattern(i:i+1,j:j+1) = reshape(randperm(4),[2,2]);
    end
end
%tmpPattern = (tmpPattern == 1);

% structures to be removed
spx2 = ones(2,1);
spx4 = ones(2,2);
reg = [1 0 1 0 1];
zigzag = [1 0 1 0 1;0 1 0 1 0];
zagzig = [0 1 0 1 0;1 0 1 0 1];
dia = diag([1 1 1]);
diaI = [0 0 1; 0 1 0; 1 0 0];
structs = {spx2; spx2'; spx4; reg; reg'; zigzag; zigzag'; zagzig; zagzig'; dia; diaI};

% remove structures
toDo = 1;
while(toDo > 0)
    structID = 1;
    while(structID<=length(structs))
            cc = xcorr2(tmpPattern == 1,structs{structID});
            ind = find(cc == sum(sum(structs{structID})));
        if isempty(ind) && structID == length(structs)
            toDo = 0;
            break
        elseif isempty(ind)
            structID = structID+1;
        else
            break
        end
    end
    if toDo > 0
        [posY, posX] = ind2sub(size(cc),ind(1));
        blockPos = [(posY-size(structs{structID},1)+1) (posX-size(structs{structID},2)+1) size(structs{structID})];
        block = tmpPattern(ceil(blockPos(1)/2)*2-1:floor((blockPos(1)+blockPos(3))/2)*2,ceil(blockPos(2)/2)*2-1:floor((blockPos(2)+blockPos(4))/2)*2);
        blockInd = [randi(size(block,1)/2) randi(size(block,2)/2)];
        block(blockInd(1)*2-1:blockInd(1)*2,blockInd(2)*2-1:blockInd(2)*2) = reshape(randperm(4),[2,2]);
        tmpPattern(ceil(blockPos(1)/2)*2-1:floor((blockPos(1)+blockPos(3))/2)*2,ceil(blockPos(2)/2)*2-1:floor((blockPos(2)+blockPos(4))/2)*2) = block;
    end
end

if lum == 1
    patternOut(:,:,1) = (tmpPattern==1);
    patternOut(:,:,2) = (tmpPattern==1);
    patternOut(:,:,3) = (tmpPattern==1);
else
    patternOut(:,:,1) = (tmpPattern==2);
    patternOut(:,:,2) = (tmpPattern==1 | tmpPattern==4);
    patternOut(:,:,3) = (tmpPattern==3);
end


end