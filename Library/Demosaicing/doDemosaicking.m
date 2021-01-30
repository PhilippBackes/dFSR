function theOutputImage = doDemosaicking( theSensorOutputImage, theDemosAlgo, theCFAMode)

%Falls nicht rggb CFA und nicht Matlab-Demosaicking -> nach rggb
%konvertieren
if exist( 'theCFAMode') && ~strcmp( theCFAMode, 'rggb') && ~strcmp( theDemosAlgo, 'Matlab') && ~strcmp(theDemosAlgo, 'AHD')
	theSensorOutputImage = convert2rggb( theSensorOutputImage, theCFAMode);
elseif strcmp(theDemosAlgo, 'AHD') && ~strcmp(theCFAMode,'grbg')
    theSensorOutputImage = convert2grbg( theSensorOutputImage, theCFAMode);
elseif ~exist( 'theCFAMode')
	theCFAMode = 'rggb';
end

switch theDemosAlgo
    case 'Fast'
        theOutputImage = doFastDemosaic( theSensorOutputImage);
    case 'AHD' % AHD implemented by Ingmar Rieger
        theOutputImage = ahd_debayer( theSensorOutputImage);
    case 'iAHD' % improved AHD implemented by Ingmar Rieger
        theOutputImage = iahd_debayer( theSensorOutputImage);
    case 'Bilinear'
        theOutputImage = doBilinearDemosaic( theSensorOutputImage);
    case 'TI' %TI US6975354 modifiziert 
        theOutputImage = doTIDemosaic( theSensorOutputImage);
    case 'POCS' %projections onto convex sets 
		theRGBImage = doBilinearDemosaic( theSensorOutputImage);
        theOutputImage = doPOCSDemosaic( theRGBImage);
	case 'Matlab'
		theOutputImage = im2double(demosaic( im2uint16( theSensorOutputImage), theCFAMode));
	otherwise %nothing to do
        theOutputImage = theSensorOutputImage;
end

end %doDemosaicking

function theRawWBImageRGGB = convert2rggb( theRawWBImage, theCFAPattern)

switch theCFAPattern
	case 'grbg'
		theRawWBImageRGGB = theRawWBImage( 1:end, 2:end-1);
	case 'rggb'
		theRawWBImageRGGB = theRawWBImage;
	case 'gbrg'
		theRawWBImageRGGB = theRawWBImage( 2:end-1, 1:end);
	case 'bggr'
		theRawWBImageRGGB = theRawWBImage( 2:end-1, 2:end-1);
	otherwise
		theRawWBImageRGGB = theRawWBImage;
end

end % convert2rggb

function theRawWBImageRGGB = convert2grbg( theRawWBImage, theCFAPattern)

switch theCFAPattern
	case 'grbg'
		theRawWBImageRGGB = theRawWBImage;
	case 'rggb'
		theRawWBImageRGGB = theRawWBImage( 1:end, 2:end-1);
	case 'gbrg'
		theRawWBImageRGGB = theRawWBImage( 2:end-1, 2:end-1);
	case 'bggr'
		theRawWBImageRGGB = theRawWBImage( 2:end-1, 1:end);
	otherwise
		theRawWBImageRGGB = theRawWBImage;
end

end % convert2grbg