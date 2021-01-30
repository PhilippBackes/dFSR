%% BUILD THE IMAGE SETS USED FOR DFSR EVALUATION
% IMPORTANT: to access the Canon files you need to install Adobe DNG
% Converter

%% Set up Workspace
clc;
close all hidden;

[ workingDir, name, ext] = fileparts( mfilename( 'fullpath'));
%cd( workingDir);

ImageDir = [ workingDir, '/Images'];

%% Prepare ARRI Images

asa = [400 400 800 800 400 800 800 800 800 400 1600 400];
colorT = [5600 5600 5600 3200 5600 5600 5600 5600 5600 3200 5600 3200];

for i = 1:12
    rawImg = imread(sprintf([ImageDir '/ARRI_ImageSet/image%02d.tif'],i));
    if i < 12
        filter = 0;
        rawImgWB = whiteBalance(rawImg,asa(i),colorT(i));
        rawImgWB = im2double(rawImgWB);
        pImg = doDemosaicking(rawImgWB,'AHD','grbg');
        [idealImg, ~ , ~] = simulateSensor(pImg,[1080 1920],'rggb');
        idealImg = uint16(idealImg*65535);
    else
        filter = 1;
        rawImgWB = whiteBalance(rawImg,asa(i),colorT(i),filter);
        idealImg = rawImgWB;
    end
    
    imwrite(idealImg,sprintf([ImageDir '/SensSim_ImageSet/Linear/image%02d.tif'],i));
    
    idealImgLogC = linear2logC(idealImg, asa(i), colorT(i), filter);
    imwrite(idealImgLogC,sprintf([ImageDir '/SensSim_ImageSet/Log/image%02d.tif'],i));
    
    idealImgRec709 = logc2rec709(idealImgLogC, asa(i), colorT(i));
    imwrite(idealImgRec709,sprintf([ImageDir '/SensSim_ImageSet/Rec709/image%02d.tif'],i));
    
    sprintf('image %02d - complete',i)
end

writetable(array2table(asa),[ImageDir '/SensSim_ImageSet/ASAImg1-12.txt']);
writetable(array2table(colorT),[ImageDir '/SensSim_ImageSet/ColorTempImg1-12.txt']);

%% Prepare Canon Files
linear2r709 = @(x)((x>=0.018).*(1.099.*x.^(0.45)-0.099) + (x<0.018).*4.5.*x);
lin2log = @(x) ((x>=0.0039).*(log2((x.*(65535)) + 4) -3)/13 + (x<0.0039).*99.0256.*x);
log2lin = @(x) (((x>=0.3862).*(2.^(13 * x + 1) - 1)/16384) + (x<0.3862).*x/99.0256);


theASN = zeros(3);
BWLevel = zeros(3,2);

for i = 13:15
        imgName = sprintf([ImageDir '/RAW/image%02d.CR2'],i);
        [rawImg, metaData] = imreadRawByDNG(imgName);
        rawImg = rawProcess(rawImg,metaData);
        rawImg = rawImg(313:end-313,:);
        rawImgWB = doWBRaw(rawImg,metaData.AsShotNeutral,'rggb');
        pImg = doDemosaicking(rawImgWB,'AHD','rggb');
        imgSize = [2250 4000];
        [idealImg, ~ , ~] = simulateSensor(pImg,imgSize,'rggb');
        idealImg = uint16(idealImg*65535);
    
        imwrite(idealImg,sprintf([ImageDir '/SensSim_ImageSet/Linear/image%02d.tif'],i));
        
        idealImgLog = lin2log(max(0,im2double(idealImg)));
        imwrite(im2uint16(idealImgLog),sprintf([ImageDir '/SensSim_ImageSet/Log/image%02d.tif'],i));
        
        myWhite = double(metaData.SubIFDs{1, 1}.WhiteLevel( 1) / 65535);
        myBlack = double(metaData.SubIFDs{1, 1}.BlackLevel( 1) / 65535);
        faktor = 1/(myWhite-myBlack);
        gainImg(:,:,1) = (im2double(idealImg(:,:,1))-myBlack/metaData.AsShotNeutral(1))*faktor;
        gainImg(:,:,2) = (im2double(idealImg(:,:,2))-myBlack)*faktor;
        gainImg(:,:,3) = (im2double(idealImg(:,:,3))-myBlack/metaData.AsShotNeutral(3))*faktor;
        
        idealImgRec709 = linear2r709(gainImg);
        imwrite(im2uint16(idealImgRec709),sprintf([ImageDir '/SensSim_ImageSet/Rec709/image%02d.tif'],i));
        
        theASN(i-12,:) = metaData.AsShotNeutral;
        BWLevel(i-12,:) = [metaData.SubIFDs{1, 1}.BlackLevel( 1) metaData.SubIFDs{1, 1}.WhiteLevel( 1)];
        
        sprintf('image %02d - complete',i)
end

 writetable(array2table(theASN),[ImageDir '/SensSim_ImageSet/AsShotNeutralIm13-15.txt']);
 writetable(array2table(BWLevel),[ImageDir '/SensSim_ImageSet/BWLevelIm13-15.txt']);
 
 %% Prepare ARRI Images OLPF

asa = [400 400 800 800 400 800 800 800 800 400 1600 400];
colorT = [5600 5600 5600 3200 5600 5600 5600 5600 5600 3200 5600 3200];

for i = 1:12
    rawImg = imread(sprintf([ImageDir '/ARRI_ImageSet/image%02d.tif'],i));
    if i < 12
        filter = 0;
        rawImgWB = whiteBalance(rawImg,asa(i),colorT(i));
        rawImgWB = im2double(rawImgWB);
        pImg = doDemosaicking(rawImgWB,'AHD','grbg');
        [idealImg, ~ , ~] = simulateSensor(pImg,[1080 1920],'rggb',1);
        idealImg = uint16(idealImg*65535);
    else
        filter = 1;
        rawImgWB = whiteBalance(rawImg,asa(i),colorT(i),filter);
        idealImg = rawImgWB;
    end
    
    imwrite(idealImg,sprintf([ImageDir '/SensSim_ImageSetOLPF/Linear/image%02d.tif'],i));
    
    idealImgLogC = linear2logC(idealImg, asa(i), colorT(i), filter);
    imwrite(idealImgLogC,sprintf([ImageDir '/SensSim_ImageSetOLPF/Log/image%02d.tif'],i));
    
    idealImgRec709 = logc2rec709(idealImgLogC, asa(i), colorT(i));
    imwrite(idealImgRec709,sprintf([ImageDir '/SensSim_ImageSetOLPF/Rec709/image%02d.tif'],i));
    
    sprintf('image %02d OLPF - complete',i)
end

writetable(array2table(asa),[ImageDir '/SensSim_ImageSetOLPF/ASAImg1-12.txt']);
writetable(array2table(colorT),[ImageDir '/SensSim_ImageSetOLPF/ColorTempImg1-12.txt']);

%% Prepare Canon Files OLPF
linear2r709 = @(x)((x>=0.018).*(1.099.*x.^(0.45)-0.099) + (x<0.018).*4.5.*x);
lin2log = @(x) ((x>=0.0039).*(log2((x.*(65535)) + 4) -3)/13 + (x<0.0039).*99.0256.*x);
log2lin = @(x) (((x>=0.3862).*(2.^(13 * x + 1) - 1)/16384) + (x<0.3862).*x/99.0256);


theASN = zeros(3);
BWLevel = zeros(3,2);

for i = 13:15
        imgName = sprintf([ImageDir '/RAW/image%02d.CR2'],i);
        [rawImg, metaData] = imreadRawByDNG(imgName);
        rawImg = rawProcess(rawImg,metaData);
        rawImg = rawImg(313:end-313,:);
        rawImgWB = doWBRaw(rawImg,metaData.AsShotNeutral,'rggb');
        pImg = doDemosaicking(rawImgWB,'AHD','rggb');
        imgSize = [2250 4000];
        [idealImg, ~ , ~] = simulateSensor(pImg,imgSize,'rggb',1);
        idealImg = uint16(idealImg*65535);
    
        imwrite(idealImg,sprintf([ImageDir '/SensSim_ImageSetOLPF/Linear/image%02d.tif'],i));
        
        idealImgLog = lin2log(max(0,im2double(idealImg)));
        imwrite(im2uint16(idealImgLog),sprintf([ImageDir '/SensSim_ImageSetOLPF/Log/image%02d.tif'],i));
        
        myWhite = double(metaData.SubIFDs{1, 1}.WhiteLevel( 1) / 65535);
        myBlack = double(metaData.SubIFDs{1, 1}.BlackLevel( 1) / 65535);
        faktor = 1/(myWhite-myBlack);
        gainImg(:,:,1) = (im2double(idealImg(:,:,1))-myBlack/metaData.AsShotNeutral(1))*faktor;
        gainImg(:,:,2) = (im2double(idealImg(:,:,2))-myBlack)*faktor;
        gainImg(:,:,3) = (im2double(idealImg(:,:,3))-myBlack/metaData.AsShotNeutral(3))*faktor;
        
        idealImgRec709 = linear2r709(gainImg);
        imwrite(im2uint16(idealImgRec709),sprintf([ImageDir '/SensSim_ImageSetOLPF/Rec709/image%02d.tif'],i));
        
        theASN(i-12,:) = metaData.AsShotNeutral;
        BWLevel(i-12,:) = [metaData.SubIFDs{1, 1}.BlackLevel( 1) metaData.SubIFDs{1, 1}.WhiteLevel( 1)];
        
        sprintf('image %02d OLPF - complete',i)
end

 writetable(array2table(theASN),[ImageDir '/SensSim_ImageSetOLPF/AsShotNeutralIm13-15.txt']);
 writetable(array2table(BWLevel),[ImageDir '/SensSim_ImageSetOLPF/BWLevelIm13-15.txt']);