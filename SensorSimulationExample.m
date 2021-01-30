%% Simulate Sensor Main Test
% Example Sensor Simulation
% To access Canon Files you need to install Adobe DNG converter

clc;
close all hidden;

%% Set up Workspace
[ workingDir, name, ext] = fileparts( mfilename( 'fullpath'));
%cd( workingDir);

ImageDir = [ workingDir, '/Images/RAW'];

% useful variables and formulas
linear2sRGB = @(x)((x>0.0031308).*(1.055.*x.^(1/2.4)-0.055) + (x<=0.0031308).*12.92.*x);
sRGB2linear = @(x)((x>0.04045).*((x+0.055)./1.055).^2.4 + (x<=0.04045).*(x./12.92));

%% Open Reference Image and Processing Image
% Get Reference Image
%[RefImageFile, ImageDir] = uigetfile( '*.*', 'Select Reference-Raw-File:', ImageDir);
RefImageFile = '/D30_f4_100_noOLPF.CRW'; % Ohne OLPF
% Get Process Image
%[ProcImageFile, ImageDir] = uigetfile( '*.*', 'Select Process-Raw-File:', ImageDir);
ProcImageFile = '/77D_f4_100.CR2';

refImageFile = [ ImageDir, RefImageFile];
[rawRefImg, refMetaData] = imreadRawByDNG(refImageFile);
procImageFile = [ ImageDir, ProcImageFile];
[rawProcImg, procMetaData] = imreadRawByDNG(procImageFile);

% Raw Processing --> RGBGain / Crop to active Area
rawRefImg = rawProcess(rawRefImg, refMetaData,'ResChart');
rawProcImg = rawProcess(rawProcImg, procMetaData,'ResChart');

rawProcImg = doWBRaw(rawProcImg,'','rggb');

procImgRGB = doDemosaicking(rawProcImg,'AHD','rggb');

%% Align Images and get Region of Interest
% Find ROI (center) and Align Images
[pROI, rROI] = getROI(procImgRGB, rawRefImg, 'centerT');

tForm = alignImages(procImgRGB,pROI,rawRefImg,rROI,'similarity');

%% Simulate Sensor on the Region of Interest

simROI = simulateSensorROI(procImgRGB,pROI,rawRefImg,rROI,tForm,0,'gbrg');

% AWB and Demosaicking
refROI = rawRefImg(rROI(2):rROI(2)+rROI(4)-1,rROI(1):rROI(1)+rROI(3)-1);
refROIwb = doWBRaw(refROI,'','rggb');
simROIwb = doWBRaw(simROI,'','rggb');

refRGB = doDemosaicking(refROIwb,'AHD','rggb');
simRGB = doDemosaicking(simROIwb,'AHD','rggb');

%% Show Results and Evaluation
% Show RAW
figure();
sgtitle('RAW');
subplot(1,3,1);
imshow(linear2sRGB(refROI));
title(gca,'Reference Raw')
subplot(1,3,2);
imshow(linear2sRGB(simROI));
title(gca,'Simulated Raw')
subplot(1,3,3);
imshowpair(linear2sRGB(simROI),linear2sRGB(refROI),'falsecolor','Scaling','none');
title(gca,'Difference')

% Show RGB
figure();
sgtitle('RGB');
subplot(1,3,1);
imshow(linear2sRGB(refRGB));
title(gca,'Reference RGB')
subplot(1,3,2);
imshow(linear2sRGB(simRGB));
title(gca,'Simulated RGB')
subplot(1,3,3);
%imshow(refRGB-simRGB);
imshowpair(linear2sRGB(simRGB),linear2sRGB(refRGB),'falsecolor','Scaling','none');
title(gca,'Difference')

% Show G
figure();
sgtitle('Green Channel');
subplot(1,3,1);
imshow(linear2sRGB(refRGB(:,:,2)));
title(gca,'Reference RGB')
subplot(1,3,2);
imshow(linear2sRGB(simRGB(:,:,2)));
title(gca,'Simulated RGB')
subplot(1,3,3);
%imshow(refRGB-simRGB);
imshowpair(linear2sRGB(simRGB(:,:,2)),linear2sRGB(refRGB(:,:,2)),'falsecolor','Scaling','none');
title(gca,'Difference')

psnrValueRaw = psnr(simROI,refROI);
mseRaw = immse(simROI,refROI);

psnrValueRGB = psnr(simRGB,refRGB);
mseRGB = immse(simRGB,refRGB);