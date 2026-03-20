clear all; close all;
I1 = imread('assets/cafe_van_gogh.jpg');
I2 = imresize(I1, 0.5);
f1 = im2gray(I1);
f2 = im2gray(I2);
points1 = detectSIFTFeatures(f1);
points2 = detectSIFTFeatures(f2);
Nbest = 100;
bestFeatures1 = points1.selectStrongest(Nbest);
bestFeatures2 = points2.selectStrongest(Nbest);
figure(1); imshow(I1);
hold on;
plot(bestFeatures1);
hold off;
title("Full Size image");
figure(2); imshow(I2);
hold on;
plot(bestFeatures2);
hold off;
title("Quarter Size image");

% all points
%[features1, valid_points1] = extractFeatures(f1, points1);
%[features2, valid_points2] = extractFeatures(f2, points2);

% best points
[features1, valid_points1] = extractFeatures(f1, bestFeatures1);
[features2, valid_points2] = extractFeatures(f2, bestFeatures2);

 indexPairs = matchFeatures(features1, features2, 'Unique', true);

 matchedPoints1 = valid_points1(indexPairs(:,1),:);
 matchedPoints2 = valid_points2(indexPairs(:,2),:);
 figure(3);
 showMatchedFeatures(f1,f2,matchedPoints1,matchedPoints2);

% Rotation invariance test
I2_rot = imrotate(I2, 20);
f2_rot = im2gray(I2_rot);
points2_rot = detectSIFTFeatures(f2_rot);
bestFeatures2_rot = points2_rot.selectStrongest(Nbest);
[features2_rot, valid_points2_rot] = extractFeatures(f2_rot, bestFeatures2_rot);
indexPairs_rot = matchFeatures(features1, features2_rot, 'Unique', true);
matchedPoints1_rot = valid_points1(indexPairs_rot(:,1),:);
matchedPoints2_rot = valid_points2_rot(indexPairs_rot(:,2),:);
figure(4);
showMatchedFeatures(f1, f2_rot, matchedPoints1_rot, matchedPoints2_rot);