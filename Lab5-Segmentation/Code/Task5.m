clear all; close all;
%% Read baboon image and create 3D scatter plot of RGB values
f = imread('../assets/baboon.png');
[M, N, S] = size(f);
F = reshape(f, [M*N S]);
R = F(:,1); G = F(:,2); B = F(:,3);
C = double(F)/255;

figure(1)
scatter3(R, G, B, 1, C);
xlabel('RED', 'FontSize', 14);
ylabel('GREEN', 'FontSize', 14);
zlabel('BLUE', 'FontSize', 14);
title('Baboon RGB Scatter Plot');

%% k-means clustering with different k values
k_values = [3, 5, 10, 15];
figure(2)
for i = 1:length(k_values)
    k = k_values(i);
    [L, centers] = imsegkmeans(f, k);
    J = label2rgb(L, im2double(centers));
    subplot(2, length(k_values), i)
    imshow(f)
    title(sprintf('Original (k=%d)', k));
    subplot(2, length(k_values), i + length(k_values))
    imshow(J)
    title(sprintf('Segmented k=%d', k));
end
sgtitle('Baboon - k-means Segmentation');

%% Scatter plot with k=10 cluster centers overlaid
k = 10;
[L, centers] = imsegkmeans(f, k);
figure(3)
scatter3(R, G, B, 1, C);
hold on
scatter3(centers(:,1), centers(:,2), centers(:,3), 100, 'black', 'filled');
xlabel('RED', 'FontSize', 14);
ylabel('GREEN', 'FontSize', 14);
zlabel('BLUE', 'FontSize', 14);
title(sprintf('Baboon RGB Scatter with k=%d Cluster Centers', k));

%% Display baboon segmented result (k=10)
J = label2rgb(L, im2double(centers));
figure(4)
montage({f, J});
title(sprintf('Baboon: Original vs Segmented (k=%d)', k));

%% Repeat for peppers.png
f2 = imread('../assets/peppers.png');
[M2, N2, S2] = size(f2);
F2 = reshape(f2, [M2*N2 S2]);
R2 = F2(:,1); G2 = F2(:,2); B2 = F2(:,3);
C2 = double(F2)/255;

figure(5)
subplot(1, length(k_values)+1, 1)
imshow(f2)
title('Original');
for i = 1:length(k_values)
    k = k_values(i);
    [L2, centers2] = imsegkmeans(f2, k);
    J2 = label2rgb(L2, im2double(centers2));
    subplot(1, length(k_values)+1, i+1)
    imshow(J2)
    title(sprintf('k=%d', k));
end
sgtitle('Peppers - k-means Segmentation');
