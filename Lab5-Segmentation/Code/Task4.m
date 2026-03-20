clear all; close all;

f = imread('../assets/yeast-cells.tif');
if size(f, 3) == 3
    f = rgb2gray(f);
end
fDouble = im2double(f);

level = graythresh(f);
g_otsu = imbinarize(f, level);

winSize = 101;
h = fspecial('average', winSize);
localMean = imfilter(fDouble, h, 'symmetric');
localStd  = stdfilt(fDouble, ones(winSize));

a = 0.6;
b = 0.8;
T = a * localStd + b * localMean;
g_local = fDouble > T;
g_local = imclose(g_local, strel('disk', 10));
g_local = imfill(g_local, 'holes');
g_local = imclearborder(g_local);
g_local = bwareaopen(g_local, 500);

figure(1)
montage({f, g_otsu, g_local}, 'Size', [1 3]);
title(sprintf('Original | Otsu (T=%.3f) | Local (a=%.1f, b=%.1f, win=%d)', level, a, b, winSize));