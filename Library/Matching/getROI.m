function [pROI, rROI] = getROI(pImg, rImg, roi)

load('ResChartROIs.mat');

rMarker = findReschartMarker(rImg);
pMarker = findReschartMarker(pImg);

switch roi
    case 'full'
        pROI = [0 0 size(pImg,2) size(pImg,1)];
        rROI = [0 0 size(rImg,2) size(rImg,1)];
    case 'cropped'
        rROI = [rMarker(1,1),rMarker(1,2),rMarker(3,1)-rMarker(1,1),rMarker(3,2)-rMarker(1,2)];
        pROI = [pMarker(1,1),pMarker(1,2),pMarker(3,1)-pMarker(1,1),pMarker(3,2)-pMarker(1,2)];
    case 'centerT'
        roiNr = 3; % see DefineReschartROIs
end

%% get ROIs
if exist('roiNr')
    % Reference ROI
    rFaktor = [rMarker(3,1)-rMarker(1,1), rMarker(3,2)-rMarker(1,2),rMarker(3,1)-rMarker(1,1),rMarker(3,1)-rMarker(1,1)];
    
    rROI = round(ReschartROI(roiNr,:).*rFaktor)+[rMarker(1,1),rMarker(1,2),0,0];
    
    % Process ROI
    pFaktor = [pMarker(3,1)-pMarker(1,1), pMarker(3,2)-pMarker(1,2),pMarker(3,1)-pMarker(1,1),pMarker(3,1)-pMarker(1,1)];
    
    pROI = round(ReschartROI(roiNr,:).*pFaktor)+[pMarker(1,1),pMarker(1,2),0,0];
    
end

if size(size(rImg),2) == 2
    % keep rggb raw
    if mod(rROI(1),2) == 0 && mod(rROI(2),2) == 0
        rROI = rROI-1;
    elseif mod(rROI(1),2) == 0
        rROI(1) = rROI(1)-1;
    elseif mod(rROI(2),2) == 0
        rROI(2) = rROI(2)-1;
    end
end
if size(size(pImg),2) == 2
    % keep rggb raw
    if mod(pROI(1),2) == 0 && mod(pROI(2),2) == 0
        pROI = pROI-1;
    elseif mod(pROI(1),2) == 0
        pROI(1) = pROI(1)-1;
    elseif mod(pROI(2),2) == 0
        pROI(2) = pROI(2)-1;
    end
end

end