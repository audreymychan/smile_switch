%% File Name: mouthInitialization
%% Purpose: Training of pre-loaded lip colour images within same directory 
%%          to obtain average of skin pixels
%% Output: Mean_Red, Mean_Green, Mean_Blue in 
%%          'mouthParameters.txt'

clc;
close all;
clear all;

% Constants
frame_x = 320;
frame_y = 240;

% Load training images from same directory
images = dir('lip*.jpg');
k = size(images);

% Loop through all images
for a=1:k
    rgbImage = imread(images(a).name);
    rgbImage = double(rgbImage);
    [rows, columns, numberOfColorPlanes] = size(rgbImage);
    redPlane = rgbImage(:,:,1);
    greenPlane = rgbImage(:,:,2);
    bluePlane = rgbImage(:,:,3);

    % Loop through all pixels to convert into chromaticity transformation
    for y=1:rows
        for x=1:columns
            red = redPlane(y,x);
            green = greenPlane(y,x);
            blue = bluePlane(y,x);

            normalizedRed = red/(red+green+blue);
            normalizedGreen = green/(red+green+blue);
            normalizedBlue = blue/(red+green+blue);

            redPlane(y,x) = normalizedRed;
            greenPlane(y,x) = normalizedGreen;
            bluePlane(y,x) = normalizedBlue;
       end
    end
    
    % Load chromaticity transformation pixels into new image
    chromImage(:,:,1) = redPlane;
    chromImage(:,:,2) = greenPlane;
    chromImage(:,:,3) = bluePlane;

    % Matrices to keep information for all pixels of each training image
    allPixels_r(:,:,a)= redPlane;
    allPixels_g(:,:,a) = greenPlane;
    allPixels_b(:,:,a) = bluePlane;
    
    % Calculate the average of red and green pixel components and matrices
    % to keep information of each training image
    mean_r(a,1) = mean2(redPlane);
    mean_g(a,1) = mean2(greenPlane);
    mean_b(a,1) = mean2(bluePlane);
    
    % Display Images
%     figure; imshow(rgbImage);
%     title (['RGB Image',int2str(a)]);
%     figure; imshow(chromImage);
%     title (['Chromaticity Image',int2str(a)]);
end

% Calculate average of skin pixels of all training images
meanAll_r = mean2(mean_r);
meanAll_g = mean2(mean_g);
meanAll_b = mean2(mean_b);

% Write results to mouthParameters.txt
file = fopen('mouthParameters.txt','wt');
fprintf(file,'Mean_Red = %6.4f\n', meanAll_r);
fprintf(file,'Mean_Green = %6.4f\n', meanAll_g);
fprintf(file,'Mean_Blue = %6.4f\n\n', meanAll_b);
fprintf('End!');
fclose(file);