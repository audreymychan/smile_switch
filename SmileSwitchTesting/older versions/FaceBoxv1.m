% Face Box
% Purpose: Face position and size estimation

clc;
clear all;

% Load training images
images = dir('face*.jpg');
k = size(images);

mean_r = 0.444;
mean_g = 0.3199;
stdev_r = 0.0501;
stdev_g = 0.0191;

% Loop through all images
for i=1:k
    origImage = imread(images(i).name);
    rgbImage = origImage;
    rgbImage = double(rgbImage);
    [rows, columns, numberOfColorPlanes] = size(rgbImage);
    redPlane = rgbImage(:,:, 1);
    greenPlane = rgbImage(:,:, 2);
    bluePlane = rgbImage(:,:, 3);

    % Loop through all pixels to convert to chromaticity transformation
    for y=1:rows
        for x=1:columns
            Red = redPlane(y,x);
            Green = greenPlane(y,x);
            Blue = bluePlane(y,x);

            NormalizedRed = Red/(Red+Green+Blue);
            NormalizedGreen = Green/(Red+Green+Blue);
            NormalizedBlue = Blue/(Red+Green+Blue);

            redPlane(y,x) = NormalizedRed;
            greenPlane(y,x) = NormalizedGreen;
            bluePlane(y,x) = NormalizedBlue;
            
            skin_yes_no = exp(-((NormalizedRed-mean_r)^2)/(2*(stdev_r^2))-((NormalizedGreen-mean_g)^2)/(2*(stdev_g^2)));
            CFM(y,x) = skin_yes_no;

       end
    end
    rgbImage(:,:,1) = redPlane;
    rgbImage (:,:,2) = greenPlane;
    rgbImage (:,:,3) = bluePlane;

    % histograms
    hist_x = sum(CFM);
    hist_y = sum(CFM,2);
    
    % centre points for x and y
    for a=1:320
        hist_x_temp(a) = a*hist_x(a);
    end
    x_centre = sum(hist_x_temp,2)/sum(hist_x,2);
    
    for b=1:240
        hist_y_temp(b) = b*hist_y(b);
    end
    y_centre = sum(hist_y_temp)/sum(hist_y);
    
    % calculating width and height
    for a=1:320
        width_temp(a) = ((a-x_centre)^2)*hist_x(a);
    end
    width = 1.5*sqrt((sum(width_temp,2)/sum(hist_x,2)));
    x_1 = x_centre-width/2;
    x_2 = x_centre+width/2;
    
    for b=1:240
        height_temp(b) = ((b-y_centre)^2)*hist_y(b);
    end
    height = 3*sqrt((sum(height_temp)/sum(hist_y)));
    y_1 = y_centre-height/2;
    y_2 = y_centre+height/2;
    
%     figure; plot(hist_x);
%     hold on
%     plot([x_centre,x_centre],[0,240]);
%     plot([x_1,x_1],[0,240]);
%     plot([x_2,x_2],[0,240]);
%     axis([0 320 0 240])
    
%     figure; plot(hist_y);
%     hold on
%     plot([y_centre,y_centre],[0,320]);
%     plot([y_1,y_1],[0,320]);
%     plot([y_2,y_2],[0,320]);
%     axis([0 240 0 320])
    
    if x_1<0
        x_1=0;
    end
    if x_2>320
        x_2=320;
    end
    if y_1<0
        y_1=0;
    end
    if y_2>240
        y_2=240;
    end

    croppedImage = origImage(y_1:y_2,x_1:x_2,:);
    
    
    
    %figure; imshow(rgbImage);
    %title (['Normalized RGB Image',int2str(i)]);
    figure; imshow(CFM);
    title (['CFM Image',int2str(i)]);
   % figure; imshow(origImage);
    figure; imshow(croppedImage);
    title (['Face Image',int2str(i)]);
    
    mouthImage = origImage((y_2-y_1)/2+y_1:y_2,x_1:x_2,:);
%     figure; imshow(mouthImage);
%     title (['Mouth Image',int2str(i)]);
   
    
    %enhance mouth segmentation
    horizontalKernel = [-1,-1,-1;2,2,2;-1,-1,-1];

    mouth = imfilter(croppedImage, horizontalKernel);
    %subplot(2,2,1), image(horizontalBuilding), title('Horizontal lines');

 
    
    grayImage = 0.2989 * mouthImage(:,:,1) + 0.5870 * mouthImage(:,:,2) + 0.1140 * mouthImage(:,:,3);
    figure; imshow(grayImage);
    title (['GrayScale Mouth Image',int2str(i)]);
    
    whiteThreshold = 250;
    
    white = 0;
    [rows, columns, numberOfColorPlanes] = size(grayImage);
    
    for y=1:rows
        for x=1:columns
            if grayImage(y,x)>whiteThreshold
                white(y,x)=1;
            end
        end
    end
    
    whiteNum(i) = sum(sum(white),2);
    
end