function [ Img_wb ] = whiteBalance( Img, ASAvalue, colorTemp, colorwheelFilter )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This is a function to white balance linear ARRI raw data (16 bit tiffs).
%
% Interface:
% [ Img_bayer_wb ] = whiteBalance( Img_bayer, ASAvalue, colorTemp, colorwheelFilter )
% 
% Choose ASA value and Color Temperature as given in the Image filename.
% The filter for Camera Bayer data is colorwheelFilter=0 (default).
% For the colorwheel data put colorwheelFilter=1.

% Parameter
% Color filter setting: default is camera bayer filter
if (nargin<4)|isempty(colorwheelFilter), colorwheelFilter=0; end
% offset
offset=256;
Img = Img - offset; 
% gain according to filter type
if colorwheelFilter==0
    red_gain  = [1.13;1.644962] ;
    green_gain= [1;1] ;
    blue_gain = [2.07;1.366723] ;
else if colorwheelFilter==1
        red_gain  = [1.3;1.3] ;
        green_gain= [1;1] ;
        blue_gain = [1.9; 1.9] ;
    else
        disp('There are no values for the chosen filter type: ', filtertype);
        error('Error when selecting filter type. Program stopped.');
    end 
end
temperatures = [3200; 5600 ];
selected_temperature = (temperatures == colorTemp);
if max(selected_temperature)==0
    disp('There are no values for the selected color temperature. Please choose one of the following values:');
    temperatures'
    error('Error when selecting color temperature. Program stopped.');
end
if size(Img,3)==3
    Img(:,:,1)= red_gain (selected_temperature)*Img(:,:,1);
    Img(:,:,2)=green_gain(selected_temperature)*Img(:,:,2);
    Img(:,:,3)= blue_gain(selected_temperature)*Img(:,:,3);
else 
    Img(1:2:end,2:2:end)=red_gain(selected_temperature)*Img(1:2:end,2:2:end);
    Img(2:2:end,1:2:end)=blue_gain(selected_temperature)*Img(2:2:end,1:2:end);
    Img(1:2:end,1:2:end)=green_gain(selected_temperature)*Img(1:2:end,1:2:end);
    Img(2:2:end,2:2:end)=green_gain(selected_temperature)*Img(2:2:end,2:2:end);
end
% add offset
Img_wb = Img + offset; 
end

