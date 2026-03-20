% Task 3: SIFT Feature Detection
clear all; close all;

% SIFT on Salvador Dali painting
I = imread('assets/salvador.tif');
f = im2gray(I);
points = detectSIFTFeatures(f);
figure(1); imshow(I);
hold on;
plot(points.selectStrongest(100));

% SIFT on Cafe Van Gogh
I2 = imread('assets/cafe_van_gogh.jpg');
f2 = im2gray(I2);
points2 = detectSIFTFeatures(f2);
figure(2); imshow(I2);
hold on;
plot(points2.selectStrongest(100));

% Explore other feature detectors
points_surf = detectSURFFeatures(f);
points_harris = detectHarrisFeatures(f);
points_orb = detectORBFeatures(f);

figure(3);
subplot(1,3,1);
imshow(I); hold on;
plot(points_surf.selectStrongest(100));
title("SURF");

subplot(1,3,2);
imshow(I); hold on;
plot(points_harris.selectStrongest(100));
title("Harris");

subplot(1,3,3);
imshow(I); hold on;
plot(points_orb.selectStrongest(100));
title("ORB");