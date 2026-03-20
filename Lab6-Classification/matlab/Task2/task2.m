% Task 2: Pattern Matching with Normalized Cross Correlation
clear all;
close all;

f = imread('assets/salvador_grayscale.tif');
w1 = imread('assets/template1.tif');
w2 = imread('assets/template2.tif');

figure;
montage({f, w1, w2}, 'Size', [1 3]);

% NCC with template 1
c1 = normxcorr2(w1, f);
figure;
surf(c1);
shading interp;
title("NCC surface - template1");

% Find peak and draw rectangle
[ypeak1, xpeak1] = find(c1 == max(c1(:)));
yoffset1 = ypeak1 - size(w1, 1);
xoffset1 = xpeak1 - size(w1, 2);
figure;
imshow(f);
drawrectangle(gca, 'Position', [xoffset1, yoffset1, size(w1, 2), size(w1, 1)], 'FaceAlpha', 0);
title("Template 1 match");

% NCC with template 2
c2 = normxcorr2(w2, f);
figure;
surf(c2);
shading interp;
title("NCC surface - template2");

[ypeak2, xpeak2] = find(c2 == max(c2(:)));
yoffset2 = ypeak2 - size(w2, 1);
xoffset2 = xpeak2 - size(w2, 2);
figure;
imshow(f);
drawrectangle(gca, 'Position', [xoffset2, yoffset2, size(w2, 2), size(w2, 1)], 'FaceAlpha', 0);
title("Template 2 match");