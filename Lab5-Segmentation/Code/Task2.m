clear all; close all;
%% Read images
f1 = imread('../assets/circuit.tif');
f2 = imread('../assets/brain_tumor.jpg');
if size(f2, 3) == 3
    f2 = rgb2gray(f2);
end

%% ===== Part 1: Edge detection with default thresholds =====
[g1_sobel, t1_sobel] = edge(f1, 'Sobel');
[g1_log,   t1_log]   = edge(f1, 'log');
[g1_canny, t1_canny] = edge(f1, 'Canny');
figure(1)
montage({f1, g1_sobel, g1_log, g1_canny}, 'Size', [1 4]);
title(sprintf('Circuit - Default | Sobel(t=%.4f) | LoG(t=%.4f) | Canny(t=[%.4f,%.4f])', ...
    t1_sobel, t1_log, t1_canny(1), t1_canny(2)));

[g2_sobel, t2_sobel] = edge(f2, 'Sobel');
[g2_log,   t2_log]   = edge(f2, 'log');
[g2_canny, t2_canny] = edge(f2, 'Canny');
figure(2)
montage({f2, g2_sobel, g2_log, g2_canny}, 'Size', [1 4]);
title(sprintf('Brain - Default | Sobel(t=%.4f) | LoG(t=%.4f) | Canny(t=[%.4f,%.4f])', ...
    t2_sobel, t2_log, t2_canny(1), t2_canny(2)));

%% ===== Part 2: Circuit image - all methods in one figure =====
sobel_thresh = [0.02, 0.05, 0.10, 0.15];
log_thresh   = [0.001, 0.003, 0.005, 0.010];
canny_thresh = {[0.02 0.05], [0.05 0.15], [0.10 0.30], [0.20 0.50]};

f1_bw = im2uint8(mat2gray(f1));
results1 = cell(3, 5);
for row = 1:3
    results1{row, 1} = f1_bw;
end
for i = 1:4
    results1{1, i+1} = uint8(edge(f1, 'Sobel', sobel_thresh(i))) * 255;
    results1{2, i+1} = uint8(edge(f1, 'log',   log_thresh(i))) * 255;
    results1{3, i+1} = uint8(edge(f1, 'Canny', canny_thresh{i})) * 255;
end

figure(3)
montage(reshape(results1', [], 1), 'Size', [3 5]);
title(sprintf(['Circuit Edge Detection (Col1=Original)\n' ...
    'Row1 Sobel: t=%.2f | %.2f | %.2f | %.2f\n' ...
    'Row2 LoG: t=%.3f | %.3f | %.3f | %.3f\n' ...
    'Row3 Canny: [%.2f,%.2f] | [%.2f,%.2f] | [%.2f,%.2f] | [%.2f,%.2f]'], ...
    sobel_thresh, log_thresh, ...
    canny_thresh{1}, canny_thresh{2}, canny_thresh{3}, canny_thresh{4}));

%% ===== Part 3: Brain tumor - all methods in one figure =====
sobel_thresh2 = [0.02, 0.05, 0.10, 0.15];
log_thresh2   = [0.001, 0.003, 0.005, 0.010];
canny_thresh2 = {[0.02 0.05], [0.05 0.15], [0.10 0.30], [0.20 0.50]};

f2_bw = im2uint8(mat2gray(f2));
results2 = cell(3, 5);
for row = 1:3
    results2{row, 1} = f2_bw;
end
for i = 1:4
    results2{1, i+1} = uint8(edge(f2, 'Sobel', sobel_thresh2(i))) * 255;
    results2{2, i+1} = uint8(edge(f2, 'log',   log_thresh2(i))) * 255;
    results2{3, i+1} = uint8(edge(f2, 'Canny', canny_thresh2{i})) * 255;
end

figure(4)
montage(reshape(results2', [], 1), 'Size', [3 5]);
title(sprintf(['Brain Tumor Edge Detection (Col1=Original)\n' ...
    'Row1 Sobel: t=%.2f | %.2f | %.2f | %.2f\n' ...
    'Row2 LoG: t=%.3f | %.3f | %.3f | %.3f\n' ...
    'Row3 Canny: [%.2f,%.2f] | [%.2f,%.2f] | [%.2f,%.2f] | [%.2f,%.2f]'], ...
    sobel_thresh2, log_thresh2, ...
    canny_thresh2{1}, canny_thresh2{2}, canny_thresh2{3}, canny_thresh2{4}));