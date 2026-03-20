% Task 1

clear all;
close all;

img = imread("assets/cafe_van_gogh.jpg");

imshow(img);

g1 = img(1:2:end, 1:2:end, :);
g2 = img(1:4:end, 1:4:end, :);
g3 = img(1:8:end, 1:8:end, :);
g4 = img(1:16:end, 1:16:end, :);
g5 = img(1:32:end, 1:32:end, :);

figure;
montage({g1, g2, g3, g4, g5}, 'Size', [1 5]);
title("Image downscaling by removing pixels in rows and cols");


% Actual resize function

r1 = imresize(img, 0.5);
r2 = imresize(img, 0.25);
r3 = imresize(img, 0.125);
r4 = imresize(img, 0.0625);
r5 = imresize(img, 0.03125);

figure;
montage({r1, r2, r3, r4, r5}, 'Size', [1 5]);
title("Image downscaling using imresize");

figure;
montage({g1, g2, g3, g4, g5, r1, r2, r3, r4, r5}, 'Size', [2 5]);
title("Comparison between cutting pixels vs imresize");