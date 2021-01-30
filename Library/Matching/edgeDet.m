function [tformEdge] = edgeDet(movingImg,fixedImg)
%Edge Detection Transform

scale = double(size(fixedImg,1))/size(movingImg,1);

fixEdgeHor = edge(fixedImg,'sobel','horizontal');
movEdgeHor = edge(movingImg,'sobel','horizontal');

fixEdgeVer = edge(fixedImg,'sobel','vertical');
movEdgeVer = edge(movingImg,'sobel','vertical');

[fixRow,~] = find(fixEdgeHor);
[movRow,~] = find(movEdgeHor);
[~,fixCol] = find(fixEdgeVer);
[~,movCol] = find(movEdgeVer);

[~,fixLinesH] = maxk(histcounts(fixRow,1:size(fixRow,1)),5);
[~,movLinesH] = maxk(histcounts(movRow,1:size(fixRow,1)),5);

[~,fixLinesV] = maxk(histcounts(fixCol,1:size(fixCol,1)),5);
[~,movLinesV] = maxk(histcounts(movCol,1:size(movCol,1)),5);

projLinesH = movLinesH.*scale;
projLinesV = movLinesV.*scale;

dEdge = ([median(min(abs(repmat(fixLinesV,5,1)-repmat(projLinesV',1,5)))) median(min(abs(repmat(fixLinesH,5,1)-repmat(projLinesH',1,5))))])/scale;

tformEdge = affine2d([1 0 0; 0 1 0; dEdge(1) dEdge(2) 1]);
end