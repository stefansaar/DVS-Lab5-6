% Task 5: SIFT vs SURF
clear all; close all;

% Read the two traffic frames
I1 = imread('assets/traffic_1.jpg');
I2 = imread('assets/traffic_2.jpg');
f1 = im2gray(I1);
f2 = im2gray(I2);

% SIFT matching
Nbest = 100;
points1_sift = detectSIFTFeatures(f1);
points2_sift = detectSIFTFeatures(f2);
bestFeatures1_sift = points1_sift.selectStrongest(Nbest);
bestFeatures2_sift = points2_sift.selectStrongest(Nbest);
[features1_sift, valid_points1_sift] = extractFeatures(f1, bestFeatures1_sift);
[features2_sift, valid_points2_sift] = extractFeatures(f2, bestFeatures2_sift);
indexPairs_sift = matchFeatures(features1_sift, features2_sift, 'Unique', true);
matchedPoints1_sift = valid_points1_sift(indexPairs_sift(:,1),:);
matchedPoints2_sift = valid_points2_sift(indexPairs_sift(:,2),:);
figure(1);
showMatchedFeatures(f1, f2, matchedPoints1_sift, matchedPoints2_sift);
title("SIFT matching");

% SURF matching
points1_surf = detectSURFFeatures(f1);
points2_surf = detectSURFFeatures(f2);
bestFeatures1_surf = points1_surf.selectStrongest(Nbest);
bestFeatures2_surf = points2_surf.selectStrongest(Nbest);
[features1_surf, valid_points1_surf] = extractFeatures(f1, bestFeatures1_surf);
[features2_surf, valid_points2_surf] = extractFeatures(f2, bestFeatures2_surf);
indexPairs_surf = matchFeatures(features1_surf, features2_surf, 'Unique', true);
matchedPoints1_surf = valid_points1_surf(indexPairs_surf(:,1),:);
matchedPoints2_surf = valid_points2_surf(indexPairs_surf(:,2),:);
figure(2);
showMatchedFeatures(f1, f2, matchedPoints1_surf, matchedPoints2_surf);
title("SURF matching");