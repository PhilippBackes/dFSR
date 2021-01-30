%% ExampleCode for single Image dFSR

clc;
close all hidden;

[workingDir, ~, ~] = fileparts(matlab.desktop.editor.getActiveFilename);

ImageDir = [ workingDir, '/Images'];

% name your experiment
Run = 'Run01';
%% Parameter
% choose CFA pattern and demosiacing type
% possible pattern Gauss
pattern = 'Gauss';
demosaicType = 'diff';
domain = 'rec709';

% Choose Image(s)
img_id = 1;

fsrParam = struct();
fsrParam.recSize = 2;
fsrParam.blkSize = 8;
fsrParam.fftSize = 32;

fsrParam.rho = 0.5;
fsrParam.oCorr = 0.2;
fsrParam.calcTruth = 0;

fsrParam.iMin = 32;
fsrParam.iMax = 512;
fsrParam.iConst = fsrParam.iMax*3;

%% Useful transformation functions and needed information
lin2r709 = @(x)((x>=0.018).*(1.099.*x.^(0.45)-0.099) + (x<0.018).*4.5.*x);
lin2log = @(x) ((x>=0.0039).*(log2((x.*(65535)) + 4) -3)/13 + (x<0.0039).*99.0256.*x);
log2lin = @(x) (((x>=0.3862).*(2.^(13 * x + 1) - 1)/16384) + (x<0.3862).*x/99.0256);

asa = [400 400 800 800 400 800 800 800 800 400 1600 400];
colorT = [5600 5600 5600 3200 5600 5600 5600 5600 5600 3200 5600 3200];

%% Prepare Image
if img_id <= 12
    rawImg = imread(sprintf([ImageDir '/ARRI_ImageSet/image%02d.tif'],img_id));
    if img_id < 12
        filter = 0;
        rawImgWB = whiteBalance(rawImg,asa(img_id),colorT(img_id));
        rawImgWB = im2double(rawImgWB);
        pImg = doDemosaicking(rawImgWB,'AHD','grbg');
        [idealImgLin, ~ , ~] = simulateSensor(pImg,[1080 1920],'rggb');
    else
        filter = 1;
        rawImgWB = whiteBalance(rawImg,asa(img_id),colorT(img_id),filter);
        idealImgLin = rawImgWB;
    end
    idealImgLin = uint16(idealImgLin.*65535);
    idealImgLog = linear2logC(idealImgLin, asa(img_id), colorT(img_id), filter);
    idealImgRec709 = logc2rec709(idealImgLog, asa(img_id), colorT(img_id));
else
    warning('not a valid img_id number')
end

switch domain
    case 'lin'
        img_in = idealImgLin;
    case 'log'
        img_in = idealImgLog;
    case 'rec709'
        img_in = idealImgRec709;
end

%% CALCULATION
% speed up by taking a smaller img_id (512,512) from center
ref_img = idealImgRec709(round(size(idealImgRec709,1)/2)+(-255:256),round(size(idealImgRec709,2)/2)+(-255:256),:);
img_in = im2double(img_in(round(size(idealImgRec709,1)/2)+(-255:256),round(size(idealImgRec709,2)/2)+(-255:256),:));

% get CFA Mask
cfaMask = createCFAMask(pattern,size(img_in));

% get "raw" img
rawImg = img_in.*cfaMask;

tic
recImg = doFSRDemosaic(rawImg,cfaMask,demosaicType,fsrParam);
exec_time = toc;

recImg = im2uint16(recImg);

if isequal(domain, 'lin')
    recImg = linear2logC(recImg, asa(img_id), colorT(img_id), filter);
    recImg = logc2rec709(recImg, asa(img_id), colorT(img_id));
end

if isequal(domain, 'log')
    recImg = logc2rec709(im2uint16(recImg), asa(img_id), colorT(img_id));
end

res_psnr = psnr(recImg, ref_img);
res_ssim = ssim(recImg, ref_img);

folder = [ImageDir '_' Run];
mkdir(folder)
imwrite(recImg, sprintf([folder '/rec%02d.tif'], img_id));

sprintf('ComputationTime: %.3f s - PSNR: %.2f - SSIM: %.3f', exec_time, res_psnr, res_ssim)

%% PLOT BOTH IMAGES

figure();
sgtitle('RAW');
subplot(1,1,1);
imshow(linear2sRGB(recImg));
title(gca,'Processed Image')
subplot(1,1,2);
imshow(linear2sRGB(ref_img));
title(gca,'Original Image')