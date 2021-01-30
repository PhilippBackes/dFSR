function [ Img_rec709 ] = logc2rec709( Img_logc, ASAvalue, colorTemp)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This is a function to convert LogC data (16 bit tiffs) to Monitor ready
% images in Rec709 color space.
%
% Interface:
% 
% [Img_out] = logC2monitor( Img_logc, ASAvalue, colorTemp)
% 
% Choose ASA value and Color Temperature as given in the Image filename
% 
% 
%% Tone mapping
load alexaToneMap
Img_logc=alexaToneMapInt(Img_logc+1);
Img_logc = double(Img_logc);
%% Convert to Rec_709 color space
Img_rec709 = Img_logc;
load('Alexa_wide_gamut_to_Rec_709');
Img_rec709(:,:,1) = Alexa_wide_gamut_to_Rec_709(1,1)*Img_logc(:,:,1) + Alexa_wide_gamut_to_Rec_709(1,2)*Img_logc(:,:,2)+Alexa_wide_gamut_to_Rec_709(1,3)*Img_logc(:,:,3);
Img_rec709(:,:,2) = Alexa_wide_gamut_to_Rec_709(2,1)*Img_logc(:,:,1) + Alexa_wide_gamut_to_Rec_709(2,2)*Img_logc(:,:,2)+Alexa_wide_gamut_to_Rec_709(2,3)*Img_logc(:,:,3);
Img_rec709(:,:,3) = Alexa_wide_gamut_to_Rec_709(3,1)*Img_logc(:,:,1) + Alexa_wide_gamut_to_Rec_709(3,2)*Img_logc(:,:,2)+Alexa_wide_gamut_to_Rec_709(3,3)*Img_logc(:,:,3);
%% Gamma correction
load('Alexa-Gamma-ITU709');
Img_rec709 = uint16(Img_rec709);
Img_rec709=Gamma_ITU709(Img_rec709+1);
Img_rec709 = uint16(Img_rec709);
end

