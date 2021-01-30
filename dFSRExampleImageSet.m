%% ExampleCode for the dFSR
% You have to build the Image Set first (Build Image Set)

clc;
close all hidden;

[ workingDir, name, ext] = fileparts( mfilename( 'fullpath'));
%cd( workingDir);

ImageDir = [ workingDir, '/Images'];
ImageSet = '/SensSim_ImageSet';

% Name your experiment
Run = 'Run01';
mkdir([ImageDir Run])

%% Parameter
pattern = 'Gauss';
demosaicType = 'diff';

% Choose Images (1:15 equals all Images)
images = 1:2;

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

lin2r709 = @(x)((x>=0.018).*(1.099.*x.^(0.45)-0.099) + (x<0.018).*4.5.*x);
lin2log = @(x) ((x>=0.0039).*(log2((x.*(65535)) + 4) -3)/13 + (x<0.0039).*99.0256.*x);
log2lin = @(x) (((x>=0.3862).*(2.^(13 * x + 1) - 1)/16384) + (x<0.3862).*x/99.0256);

%% dFSR
folder = [ImageDir Run  '/' demosaicType];
mkdir(folder)

cfaMask = imread([ImageDir '/Masks/' pattern '.png']);
cfaMask = im2double(cfaMask);
resultList = zeros(length(images),3);

for i = images
    imgName = sprintf([ImageDir ImageSet '/Rec709/image%02d.tif'],i);
    img = imread(imgName);
    img = im2double(img(round(size(img,1)/2)+(-255:256),round(size(img,2)/2)+(-255:256),:));
    
    rawImg = img.*cfaMask;
    
    tic
    recImg = doFSRDemosaic(rawImg,cfaMask,demosaicType,fsrParam);
    resultList(i,1) = toc;
    
    resultList(i,2) = psnr(recImg,img);
    resultList(i,3) = ssim(recImg,img);
    
    recImg = max(0,recImg);
    
    imwrite(uint16(recImg.*65535),sprintf([folder '/rec%02drec709.tif'],i));
    
    sprintf('Image %02d - %3f s - psnr: %f - ssim: %f - rec709: %f',i,resultList(i,1),resultList(i,2),resultList(i,3))
end
writetable(array2table(resultList),[folder '/resultData.txt']);
writecell(struct2cell(fsrParam),[folder '/Parameter.txt']);