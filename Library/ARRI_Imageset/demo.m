% How to work with the raw data
% 
% We provide the images as linear 16 bit TIFF files. Linear means that the
% digital numbers are proportional to the amount of light collected by each
% pixel. The TIFF image has one signal value per pixel, according to the
% bayer pattern it is either red, green or blue. To render the images for
% display on a monitor one could apply several tone-mapping techniques. We
% provide a global transform that is very similar to the way the camera
% generates a High Definition video image. Because of typical application
% of the camera the processing is inspired by the motion-picture film
% process. 
% Step 1 and 2 : White Balance and Demosaicking 
% First, the linear data is white balanced and demosaicked. The image
% values are still in the linaer domain and displayed on a monitor the
% image will appear mostly black. 
% Step 3: Conversion to a Log C image 
% The color correction matrix transforms the camera RGB values into values
% for a wide-gamut color space. The encoding primaries for this color space
% are chosen to avoid clipping in all but the most extreme cases. The
% wide-gamut RGB values are then non-linearly transformed by a function
% named “Log C”. It’s basically a logarithmic transform of the data
% with a small offset added, which creates a toe at the lower end of the
% curve.
% Step 4: Conversion to Monitor Color Space 
% The next step is the application of a tone-mapping curve. The 
% tone-mapped data is matrixed into the color space defined in
% ITU Recommendation 709 , which has the same primaries as the sRGB color
% space. The final transform is a compensation for the non-linear
% electro-optical transfer function of the monitor that is assumed to be a
% power function with an exponent of 2.4 .

%% Read image
% Camera bayer data
Img_in=imread('ARRI_BPI_400ASA_5600K_0000.tif');
% color wheel RGB image
% Img_in=imread('table1_pan_rgb_0000.tif');
%% Set parameters
ASAvalue=400;
colorTemp=5600;

%% Step 1: White Balance
Img_wb=whiteBalance(Img_in, ASAvalue, colorTemp, 0); 
%Img_wb=whiteBalance(Img_in, ASAvalue, colorTemp, 1); %color wheel data
%% Step 2: Demosaicking
 Img_linear= demosaic(Img_wb, 'grbg');
% Img_linear=Img_wb; %color wheel RGB data
%% Step 3: Convert to LogC domain
Img_logc= linear2logC(Img_linear, ASAvalue, colorTemp, 0);
%Img_logc= linear2logC(Img_linear, ASAvalue, colorTemp, 1); %color wheel
figure, imshow(Img_logc), title('Log C domain');
%% Step 4: Convert to Monitor (Rec709) domain
Img_monitor=logc2rec709(Img_logc, ASAvalue, colorTemp);
figure, imshow(Img_monitor), title('Monitor (Rec 709) domain');

