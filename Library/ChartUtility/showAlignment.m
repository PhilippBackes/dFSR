function [] = showAlignment(refImgIn,procImgIn,refMarker,procMarker,refImgOut,procImgOut)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

linear2sRGB = @(x)((x>0.0031308).*(1.055.*x.^(1/2.4)-0.055) + (x<=0.0031308).*12.92.*x);

width = 20;

figure();
hold on
subplot(2,2,1);
imshow(linear2sRGB(refImgIn));
for i=1:5
    rectangle('Position',[refMarker(i,1)-width/2,refMarker(i,2)-width/2,width,width],'LineWidth',2,'LineStyle','--');
end

subplot(2,2,2);
imshow(linear2sRGB(procImgIn));
for i=1:5
    rectangle('Position',[procMarker(i,1)-width/2,procMarker(i,2)-width/2,width,width],'LineWidth',2,'LineStyle','--');
end

subplot(2,2,3);
imshow(linear2sRGB(refImgOut));
for i=1:5
    rectangle('Position',[refMarker(i,1)-width/2,refMarker(i,2)-width/2,width,width],'LineWidth',2,'LineStyle','--');
end

subplot(2,2,4);
imshow(linear2sRGB(procImgOut));
procOmarker = findReschartMarker(procImgOut);
for i=1:5
    rectangle('Position',[procOmarker(i,1)-width/2,procOmarker(i,2)-width/2,width,width],'LineWidth',2,'LineStyle','--');
end
end

