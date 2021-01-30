function tformMatrix = alignImages(procImg,pROI,refImg,rROI,type)
%ALIGN IMAGES

% get scale and  Region of Interest
scale = double(size(refImg,1))/size(procImg,1);

if size(size(refImg),2) == 3
    refROI = refImg(rROI(2):rROI(2)+rROI(4)-1,rROI(1):rROI(1)+rROI(3)-1,2);
else
    refROI = refImg(rROI(2):rROI(2)+rROI(4)-1,rROI(1):rROI(1)+rROI(3)-1);
    % Weiﬂabgleich um gleichm‰ﬂiges "Grauwertbild" zu bekommen
    refROI = doWBRaw(refROI,'','rggb');
end

if size(size(procImg),2) == 3
    procROI = procImg(pROI(2):pROI(2)+pROI(4)-1,pROI(1):pROI(1)+pROI(3)-1,2);
else
    procROI = procImg(pROI(2):pROI(2)+pROI(4)-1,pROI(1):pROI(1)+pROI(3)-1);
    % Weiﬂabgleich um gleichm‰ﬂiges "Grauwertbild" zu bekommen
    procROI = doWBRaw(procROI,'','rggb');
end

% set 2d reference
ref2d = imref2d(size(refROI));
proc2d = imref2d(size(procROI),scale,scale);

% Similarity MeanSquareError Optimizer
[optimizer, metric] = imregconfig('multimodal');
optimizer = registration.optimizer.RegularStepGradientDescent;
metric = registration.metric.MeanSquares;
optimizer.GradientMagnitudeTolerance = 1e-10;
optimizer.MinimumStepLength = 1e-12;
optimizer.MaximumIterations = 100;

tform = imregtform(procROI,proc2d,refROI,ref2d,type,optimizer,metric);

tformMatrix = tform.T;

% imwarp Neuberechnung zur Kontrolle
[procROIwarp,proc2dtmp] = imwarp(procROI,proc2d,tform,'OutputView',ref2d);
figure;
imshowpair(refROI,ref2d,procROIwarp,proc2dtmp,'falsecolor','Scaling','none');

% % Ganzpixel verschieben
% dXY = tform.T(3,1:2)./scale;
% roiPosCorrected = procROIpos-fix(dXY);
% procROI = procImg(roiPosCorrected(2):roiPosCorrected(2)+round(windowSize/(scale*tform.T(1,1)))-1,roiPosCorrected(1):roiPosCorrected(1)+round(windowSize/(scale*tform.T(1,1)))-1,:);
% 
% % Scaling Faktor
% proc2d = imref2d(size(procROI(:,:,2)),scale*tform.T(1,1),scale*tform.T(1,1));
% 
% % Subpixel-Rest wird im Referenzraum verrechnet
% dXY = mod(dXY,fix(dXY)).*tform.T(1,1);
% proc2d.XWorldLimits = proc2d.XWorldLimits+dXY(1)*scale;
% proc2d.YWorldLimits = proc2d.YWorldLimits+dXY(2)*scale;
% 
% if exist('display')
%     figure;
%     subplot(1,3,1);
%     imshowpair(refROI,ref2d,procROI(:,:,1),proc2d,'falsecolor','Scaling','none');
%     title('red');
%     subplot(1,3,2);
%     imshowpair(refROI,ref2d,procROI(:,:,2),proc2d,'falsecolor','Scaling','none');
%     title('green');
%     subplot(1,3,3);
%     imshowpair(refROI,ref2d,procROI(:,:,3),proc2d,'falsecolor','Scaling','none');
%     title('blue');
%     figure;
%     imshowpair(refROI,ref2d,procROIwarp(:,:,2),proc2dtmp,'falsecolor','Scaling','none');
% end
end