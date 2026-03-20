clear all; close all;

f = imread('../assets/yeast_cells.tif');
if size(f, 3) == 3
    f = rgb2gray(f);
end

level = graythresh(f);
g_otsu = imbinarize(f, level);

figure(1)
montage({f, g_otsu}, 'Size', [1 2]);
title(sprintf('Original | Otsu (threshold=%.3f)', level));

winSize = 15;
fDouble = im2double(f);
localMean = imfilter(fDouble, fspecial('average', winSize), 'replicate');
localStd  = stdfilt(fDouble, ones(winSize));
a = 0.5;
b = 1.0;
T = a * localStd + b * localMean;
g_local = fDouble >= T;
g_local = imopen(g_local, strel('disk', 2));
g_local = imclose(g_local, strel('disk', 2));

figure(2)
montage({f, g_otsu, g_local}, 'Size', [1 3]);
title(sprintf('Original | Otsu | Local threshold (a=%.1f, b=%.1f, win=%d)', a, b, winSize));

figure(3)
subplot(1,2,1), imshow(g_otsu), title('Otsu: cells merged');
subplot(1,2,2), imshow(g_local), title('Local: cells separated');