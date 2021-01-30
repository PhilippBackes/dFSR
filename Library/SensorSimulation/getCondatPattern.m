function [patternOut] = getCondatPattern(patternSize)
%GETICIP2018PATTERN Summary of this function goes here
%   Detailed explanation goes here

patternOut = zeros(ceil(patternSize/3)*3);

tiles = {[1 2 3], [1 3 2], [2 3 1], [2 1 3], [3 1 2], [3 2 1]};
nextTileOpt = {[2 4],[1 5], [4 6], [1 3], [2 6], [3 5]};

lastTile = randi(6);
patternOut(1,1:3) = tiles{lastTile};

% create first Row
for i = 4:3:size(patternOut,1)-2
    nextTile = nextTileOpt{lastTile};
    lastTile = nextTile(randi(2));
    patternOut(1,i:i+2) = tiles{lastTile};
end

% create first Column
lastTile = randi(6);
firstColTile = tiles{lastTile};
while(firstColTile(1) ~= patternOut(1,1))
    lastTile = randi(6);
    firstColTile = tiles{lastTile};
end
patternOut(1:3,1) = firstColTile;
for i = 4:3:size(patternOut,1)-2
    nextTile = nextTileOpt{lastTile};
    lastTile = nextTile(randi(2));
    patternOut(i:i+2,1) = tiles{lastTile};
end

for i = 2:size(patternOut,1)
    for j = 2:size(patternOut,2)
        left = patternOut(i,j-1);
        up = patternOut(i-1,j);
        if (left == 1 && up == 2) || (left == 2 && up == 1)
            patternOut(i,j) = 3;
        elseif (left == 1 && up == 3) || (left == 3 && up == 1)
            patternOut(i,j) = 2;
        elseif (left == 2 && up == 3) || (left == 3 && up == 2)
            patternOut(i,j) = 1;
        else
            if (patternOut(i-1,j-1) == 1 && left == 2) || (patternOut(i-1,j-1) == 2 && left == 1)
                patternOut(i,j) = 3;
            elseif (patternOut(i-1,j-1) == 1 && left == 3) || (patternOut(i-1,j-1) == 3 && left == 1)
                patternOut(i,j) = 2;
            elseif (patternOut(i-1,j-1) == 2 && left == 3) || (patternOut(i-1,j-1) == 3 && left == 2)
                patternOut(i,j) = 1;
            end
        end
    end
end

patternOut = repmat(patternOut,1,1,3);

patternOut(:,:,1) = patternOut(:,:,1) == 1;
patternOut(:,:,2) = patternOut(:,:,2) == 2;
patternOut(:,:,3) = patternOut(:,:,3) == 3;

patternOut = logical(patternOut(1:patternSize(1),1:patternSize(2),:));    
end