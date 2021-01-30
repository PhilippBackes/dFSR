function [Img_logc] = linear2logC(Img_linearRGB, ASAvalue, colorTemp, colorwheelFilter )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This is a function to convert linear data (16 bit tiffs) to LogC
% images. 
% 
% Interface:
% 
% [Img_logc] = linear2logC(Img_linear, ASAvalue, colorTemp, filtertype )
% 
% Choose ASA value and Color Temperature as given in the Image filename
% The filter type can be 'camera' or 'colorwheel'.

%% Parameter Setting
% Color filter setting: default is camera bayer filter
if (nargin<4)|isempty(colorwheelFilter), colorwheelFilter=0; end
%% Apply wide gamut color conversion matrix:
% Subtract offset
offset=256;
debayered_linear_image = double(Img_linearRGB) - offset;
% Load color matrix (depends on filter type)
if colorwheelFilter==0
    load('wgmatrix.mat');
else % colorwheelFilter==1
    load('wgmatrix_colorwheel.mat');
end
% Matrix depending on color temperature
selected_temperature = (colorTemperature == colorTemp);
if max(selected_temperature)==0
    disp('There are no values for the selected color temperature. Please  choose one of the following values:');
    temperatures'
    error('Error when selecting color temperature. Program stopped.');
end
conversion_matrix = wide_gamut_matrix(:,:,selected_temperature);
wide_gammut_lin_data(:,:,1) = conversion_matrix(1,1)*debayered_linear_image(:,:,1) + conversion_matrix(1,2)*debayered_linear_image(:,:,2)+conversion_matrix(1,3)*debayered_linear_image(:,:,3);
wide_gammut_lin_data(:,:,2) = conversion_matrix(2,1)*debayered_linear_image(:,:,1) + conversion_matrix(2,2)*debayered_linear_image(:,:,2)+conversion_matrix(2,3)*debayered_linear_image(:,:,3);
wide_gammut_lin_data(:,:,3) = conversion_matrix(3,1)*debayered_linear_image(:,:,1) + conversion_matrix(3,2)*debayered_linear_image(:,:,2)+conversion_matrix(3,3)*debayered_linear_image(:,:,3);
% Clean up
clear debayered_linear_image;
% add offset
wide_gammut_lin_data = wide_gammut_lin_data + offset;
%% Convert to logC:
% Load LogC LUT
logCFile=['Alexa-EI' num2str(ASAvalue) '-LogC-16bits'];
load(logCFile);
% Convert to LogC
wide_gammut_lin_data=uint16(wide_gammut_lin_data); 
Img_logc=eval(['LogC_' num2str(ASAvalue) 'ASA(wide_gammut_lin_data+1)']);
Img_logc=uint16(Img_logc);
% Clean up
clear wide_gammut_lin_data;
end