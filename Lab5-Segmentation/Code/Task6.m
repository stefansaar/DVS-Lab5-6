clear all; close all;

%% Step 1: Read image and produce cleaned binary image
I = imread('../assets/dowels.tif');
f = im2bw(I, graythresh(I));
g = bwmorph(f, "close", 5);
g = bwmorph(g, "open", 5);
g = bwmorph(g, "close", 5);
g = imfill(g, "holes");
figure(1)
montage({I, g});
title('Original & Binarized Cleaned Image');

%% Step 2: Distance transform
gc = imcomplement(g);
D = bwdist(gc);
figure(2)
imshow(D, [min(D(:)) max(D(:))])
title('Distance Transform');

%% Step 3: Watershed on complement of distance transform
L = watershed(imcomplement(D));
figure(3)
imshow(L, [0 max(L(:))])
title('Watershed Segmented Label');

%% Step 4: Merge to show segmentation
W = (L == 0);
g2 = g & ~W;
figure(4)
montage({I, g, W, g2}, 'Size', [2 2]);
title('Original - Binarized - Watershed Regions - Merged Boundaries');
