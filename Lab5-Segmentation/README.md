# Lab 5 - Segmentation and Feature Detection
*_Peter Cheung, version 1.2, 19 Feb 2026_*


In this laboratory session, you will explore techniques to identify features and regions in an image. As before, clone this repository to your laptop and keep your experimental logbook on your repo.  

## Task 1: Point Detection

The file "crabpulsar.tif" contains an image of the neural star Crab Nebula, which was the remnant of the supernova SN 1054 seen on earth in the year 1054. 

The goal is to try to remove the main nebular and only highlight the surrounding stars seen in the image.

Try the following code and explain what hapens.

```
clear all
close all
f = imread('assets/crabpulsar.tif');
w = [-1 -1 -1;
     -1  8 -1;
     -1 -1 -1];
g1 = abs(imfilter(f, w));     % point detected
se = strel("disk",1);
g2 = imerode(g1, se);         % eroded
threshold = 100;
g3 = uint8((g2 >= threshold)*255); % thresholded
montage({f, g1, g2, g3});
```

<img src="Results/Task1.png">

> **Image 1 (f):** Just the raw photo of the Crab Nebula — big glowy nebula in the middle, stars scattered everywhere.

> **Image 2 (g1) — Point Detection:** The kernel does `8×centre − (sum of all 8 neighbours)`. Basically it's asking "how different is this pixel from everything around it?" In the nebula where everything fades gradually, the answer is "not very" so it goes dark. But at a star where the centre pixel is way brighter than its neighbours, you get a huge response — so all the stars light up as bright dots while the nebula mostly disappears. `abs()` is there so we catch both bright and dark outliers.

> **Image 3 (g2) — Erosion:** Shrinks everything down by taking the minimum in each neighbourhood. The faint, tiny star responses get wiped out, only the stronger ones make it through.

> **Image 4 (g3) — Thresholding:** Anything above 100 becomes white, everything else goes black. Now you're left with just the brightest, most obvious stars as clean white dots.

## Task 2: Edge Detection 

Matlab Image Processing Toolbox provides a special function *_edge( )_* which returns an output image containing edge points.  The general format of this function is:

```
[g, t] = edge(f, 'method', parameters)
```
*_f_* is the input image.  
*_g_* is the output image.  *_t_* is an optional return value giving the threshold being used in the algorithm to produce the output.  
*_'method'_* is one of several algorithm to be used for edge detection.  The table below describes three algorithms we have covered in Lecture 8.

<p align="center"> <img src="assets/edge_methods.jpg" /> </p>

The image file *_'circuits.tif'_* is part of a chip micrograph for an intergrated circuit.  The image file *_'brain_tumor.jpg'_* shows a MRI scan of a patient's brain with a tumor.

Use *_function edge( )_* and the three methods: Sobel, LoG and Canny, to extract edges from these two images.

The function *_edge_* allows the user to specify one or more threshold values with the optional input *_parameter_* to control the sensitivity to edges being detected.  The table below explains the meaning of the threshold parameters that one may use.

<p align="center"> <img src="assets/edge_threshold.jpg" /> </p>

> Below are default immages produced by default threshold 

<img src="Results/Task_2_Edge_Detection_methods_comparison.png" />
<img src="Results/Task_2_Edge_Detection_methods_2_comparison.png" />

> Default threshold results:
Sobel performs surprisingly well on the brain tumour image at default settings — there's less noise from internal brain structures, making it easy to see where the tumour starts and ends. Canny works best on the circuit image, producing more continuous and well-connected lines compared to the other methods.
Repeat the edge detection exercise with different threshold to get the best results you can for these two images.

<img src="Results/Task_2_Result_Comparison_2.png" />
<img src="Results/Task_2_Result_Comparison.png" />



>Tuning thresholds:
For LoG, thresholds between 0.005 and 0.01 give decent results — low enough to catch real edges without too much noise creeping in. For Sobel, the range [0.05, 0.15] looks good; pushing it to [0.2, 0.5] starts eating away at weaker edges. On the brain tumour image specifically, these tuned thresholds make it noticeably clearer where the tumour boundary begins and ends, which is useful for any kind of clinical interpretation.
In general, raising the threshold removes weaker edges and cleans up the result, but go too high and you start losing real structural detail.
## Task 3 - Hough Transform for Line Detection

In this task, you will be lead through the process of finding lines in an image using Hough Transform.  This task consists of 5 separate steps.


#### Step 1: Find edge points
Read the image from file 'circuit_rotated.tif' and produce an edge point image which feeds the Hough Transform.

```
% Read image and find edge points
clear all; close all;
f = imread('assets/circuit_rotated.tif');
fEdge = edge(f,'Canny');
figure(1)
montage({f,fEdge})
```
This is the same image as that used in Task 2, but rotated by 33 degrees.

<img src="Results/Task_3_Canny.png">

#### Step 2: Do the Hough Transform
Now perform the Hough Transform with the function *_hough( )_* which has the format:
```
[H, theta, rho] = hough(image)
```
where *_image_* is the input grayscale image, *_theta_* and *_rho_* are the angle and distance in the transformed parameter space, and *_H_* is the number of times that a pixel from the image falls on this parameter "bin".  Therefore, the bins at (theta,rho) coordinate with high count values belong to a line.  (See Lecture 8, slides 19-25.)  The diagram below shows the geometric relation of *_theta_* and *_rho_* to a straight line.

<p align="center"> <img src="assets/hough.jpg" /> </p>

Now perform Hough Transform in Matlab:
```
% Perform Hough Transform and plot count as image intensity
[H, theta, rho] = hough(fEdge);
figure(2)
imshow(H,[],'XData',theta,'YData', rho, ...
            'InitialMagnification','fit');
xlabel('theta'), ylabel('rho');
axis on, axis normal, hold on;
```

The image, which I shall called the **_Hough Image_**, correspond to the counts in the Hough transform parameter domain with the intensity representing the count value at each bin.  The brighter the point, the more edge points maps to this parameter.  Therefore all edge points on a straight line will map to this parameter bin and increase its brightness.

> The key idea behind the Hough Transform is a change of representation: instead of looking at edge pixels in image space (x, y), we map every edge point to all possible lines passing through it, each described by (theta, rho). A single edge point traces out a sinusoidal curve in (theta, rho) space. When multiple edge points are collinear in the image, their sinusoids all intersect at the same (theta, rho) — so that bin accumulates a high count. This turns the hard problem of "find a line through scattered points" into the much easier problem of "find a peak in a 2D histogram." The Hough Image is essentially that histogram: bright spots correspond to dominant lines in the original image.

#### Step 3: Find peaks in Hough Image
Matlab  provides a special function **_houghpeaks_** which has the format:
```
peaks = houghpeaks(H, numpeaks)
```
which returns the coordinates of the highest *_numpeaks_* peaks. 

The following Matlab snippet find the 5 tallest peaks in H and return their coordinate values in *_peaks_*.  Each element in *_peaks_* has values which are the indices into the *_theta_* and *_rho_* arrays.  

The *_plot_* function overlay on the Hough image red circles at the 5 peak locations.

```
% Find 5 larges peaks and superimpose markers on Hough image
figure(2)
peaks  = houghpeaks(H,5);
%peaks  = houghpeaks(H,5,'threshold',ceil(0.3*max(H(:))));
x = theta(peaks(:,2)); y = rho(peaks(:,1));
plot(x,y,'o','color','red', 'MarkerSize',10, 'LineWidth',1);
```

> Explore the contents of array *_peaks_* and relate this to the Hough image with the overlay red circles.

> Each row in `peaks` stores the row and column indices into the Hough matrix H, which correspond to a specific (rho, theta) pair. The red circles on the Hough Image mark exactly these peak locations — each one sits on a bright spot, confirming that the peak finder has correctly identified the bins with the highest votes, i.e. the most dominant straight lines in the original edge image.

<img src="Results/Task_3_Intersection.png">

#### Step 4: Explore the peaks in the Hough Image
It can be insightful to take a look at the Hough Image in a different way.  Try this:

```
% Plot the Hough image as a 3D plot (called SURF)
figure(3)
surf(theta, rho, H);
xlabel('theta','FontSize',16);
ylabel('rho','FontSize',16)
zlabel('Hough Transform counts','FontSize',16)
```
You will see a plot of the Hough counts in the parameter space as a 3D plot instead of an image.  You can use the mouse (or track pad) to rotate the plot in any directions and have a sense of where the peaks occurs.  The **_houghpeak_** function simply search this profile and fine the highest specified number of peaks.

<img src="Results/Task_3_3DSurf.png">

### Step 5: Fit lines into the image

The following Matlab code uses the function **_houghlines_** to 

```
% From theta and rho and plot lines
lines = houghlines(fEdge,theta,rho,peaks,'FillGap',5,'MinLength',7);
figure(4), imshow(f), 
figure(4); hold on
max_len = 0;
for k = 1:length(lines)
   xy = [lines(k).point1; lines(k).point2];
   plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
```

The function **_houghlines( )_** returns arrays of lines, which is a structure including details of line segments derived from the results from both **_hough_** and **_houghpeaks_**.  Details are given in the table below.

<p align="center"> <img src="assets/lines_struct.jpg" /> </p>

The start and end coordinates of each line segment is used to define the starting and ending point of the line which is plotted as overlay on the image.

> How many line segments are detected? Why it this not 5, the number of peaks found?
> Explore how you may detect more lines and different lines (e.g. those orthogonal to the ones detected).

> More than 5 line segments are detected even though only 5 peaks were found. This is because each peak in (theta, rho) space defines an *infinite* line, but `houghlines` breaks that line into separate *segments* wherever there are gaps in the edge pixels along it. So one peak can produce multiple disjoint segments if the edge points are not continuous. To detect more or different lines (e.g. orthogonal ones), we can increase `numpeaks` in `houghpeaks`, or lower the `'threshold'` parameter so that weaker peaks are also picked up. Below, the first image shows detection with 5 peaks and the second with 10 peaks — increasing `numpeaks` reveals additional lines in different orientations.

<img src="Results/Task_3_5_Line_Detected.png">

<img src="Results/Task_3_10_Line_Detected.png">

> Optional: Matlab also provides the function **_imfindcircles( )_**, which uses Hough Transform to detect circles instead of lines.  You are left to explore this yourself.  You will find two relevant image files for cicle detection: *_'circles.tif'_* and *_eight.png_* in the *_assets_* folder.

## Task 4 - Segmentation by Thresholding

You have used Otsu's method to perform thresholding using the function **_graythresh( )_** in Lab 3 Task 3 already.  In this task, you will explore the limitation of Otsu's method.

You will find in the *_assets_* folder the image file *_'yeast_cells.tif'_*. Use Otu's method to segment the image into background and yeast cells.  Find an alternative method to allow you separating those cells that are 'touching'. (See Lecture 9, slide 9.)

<img src="Results/Task_4_Result.png">

> The result isn't great — Otsu manages to separate cells from the background, but touching cells just merge into one big blob. I tried tweaking the threshold values quite a bit but couldn't get it to split them apart.

## Task 5 - Segmentation by k-means clustering

In this task, you will learn to apply k-means clustering method to segment an image.  

Try the following Matlab code:
```
clear all; close all;
f = imread('assets/baboon.png');    % read image
[M N S] = size(f);                  % find image size
F = reshape(f, [M*N S]);            % resize as 1D array of 3 colours
% Separate the three colour channels 
R = F(:,1); G = F(:,2); B = F(:,3);
C = double(F)/255;          % convert to double data type for plotting
figure(1)
scatter3(R, G, B, 1, C);    % scatter plot each pixel as colour dot
xlabel('RED', 'FontSize', 14);
ylabel('GREEN', 'FontSize', 14);
zlabel('BLUE', 'FontSize', 14);
```

This code reproduces the scatter plot in Lecture 9 slide 12, but in higher resolution.  Each dot and its colour in the plot corresponds to a pixel with it [R G B] vector on the XYZ axes.  The Matlab function **_scatter3( )_** produces the nice 3D plot.  
The first three inputs R, G and B are the X, Y and Z coordinates. The fourth input '1' is the size of the circle (i.e. a dot!).  The final input  is the colour of each pixel.

Note that **_scatter3( )_** expects the X, Y and Z coordinates to be 1D vectors.  Therefore the function **_reshape( )_** was used to convert the 2D image in to 1D vector.
> You can use the mouse or trackpad to move the scatter plot to different viewing angles or to zoom into the plot itself. Try it.
Matlab provides a built-in function **_imsegkmeans_** that perform k-means segmentation on an image.  This is not a general k-means algorithm in the sense that it expects the input to be a 2D image of grayscale intensity, or a 2D image of colour.  The format is:


> This is a really dizzy experience to play around with this 3D plot

```
[L, centers] = imsegkmeans(I, k)
```
where **_I_** is the input image, **_k_** is the number of clusters, **_L_** is the label matrix as described in the table below.  Each element of **_L_** contains the label for the pixel in **_I_**, which is the cluster index that pixel belongs.  **_centers_** contains the mean values for the k clusters.

>L is a label matrix with the same dimensions as the input image, where each pixel is assigned an integer from 1 to k indicating its cluster. centers is a k-by-c matrix storing the mean colour of each cluster. Together, label2rgb(L, im2double(centers)) replaces each pixel with its cluster's mean colour to produce the segmented image.
<p align="center"> <img src="assets/label_format.jpg" /> </p>

Perform k-means clustering algorithm as shown below.

```
% perform k-means clustering
k = 10;
[L,centers]=imsegkmeans(f,k);
% plot the means on the scatter plot
hold
scatter3(centers(:,1),centers(:,2),centers(:,3),100,'black','fill');
```
The last line here superimposes a large black circle at each means colour values in the scatter plot.

> Explore the outputs **_L_** and **_centers_** from the segmentation fucntion.  Explore different value of k.

> `L` labels each pixel with its cluster (1 to k), and `centers` holds the mean RGB of each cluster. Small k gives a very posterised look; as k increases the result gets closer to the original. Around k = 10 looks decent for the baboon.

Finally, use the label matrix **_L_** to segment the image into the k colours:
```
% display the segmented image along with the original
J = label2rgb(L,im2double(centers));
figure(2)
montage({f,J})
```

The Matlab function **_labe2rgb_** turns each element in **_L_** into the segmented colour stored in **_centers_**.

<img src="Results/Task_5_Baboo_Colour.png">

<img src="Results/Task_5_Baboo_segmented.png">

> Explore different value of k and comment on the results.
> Also, try segmenting the colourful image file 'assets/peppers.png'.

> Peppers work well with k-means since the colours are quite distinct — even a small k gives a clean separation.

<p align="center"> <img src="Results/Task_5_Baboo.png" /> </p>



## Task 6 - Watershed Segmentation with Distance Transform

Below is an image of a collections of dowels viewed ends-on. The objective is to segment this into regions, with each region containing only one dowel.  Touch dowels should also be separated.
<p align="center"> <img src="assets/dowels.jpg" /> </p>
This image is  suitable for watershed algorithm because touch dowels will often be merged into one object. This is not the case with watershed segmentation.

Read the image and produce a cleaned version of binary image having the dowels as foreground and cloth underneath as background.  Note how morophological operations are used to reduce the "noise" in grayscale image.  The "noise" is the result of thresholding on the pattern of the wood.

```
% Watershed segmentation with Distance Transform
clear all; close all;
I = imread('assets/dowels.tif');
f = im2bw(I, graythresh(I));
g = bwmorph(f, "close", 1);
g = bwmorph(g, "open", 1);
montage({I,g});
title('Original & binarized cleaned image')
```
<p align="center"> <img src="Results/Task_6_binarized.png" /> </p>

Instead of applying watershed transform on this binary image directly, a technique often used with watershed is to first calculate the distance transform of this binary image. The distance transform is simply the distance from every pixel to the nearest nonzero-valued (foreground) pixel.  Matlab provides the function **_bwdist( )_** to return an image where the intensity is the distance of each pixel to the nearest foreground (white) pixel.  

```
% calculate the distance transform image
gc = imcomplement(g);
D = bwdist(gc);
figure(2)
imshow(D,[min(D(:)) max(D(:))])
title('Distance Transform')
```
<p align="center"> <img src="Results/Task_6_distance_transform.png" /> </p>

> Why do we perform the distance transform on gc and not on g?

> `bwdist` computes the distance from each pixel to the nearest nonzero (white) pixel. In `g`, the dowels are white (foreground), so pixels inside the dowels already have distance 0 — no useful terrain is produced. By complementing to `gc`, the background becomes white and the dowels become black. Now `bwdist(gc)` gives each pixel inside a dowel its distance to the nearest background edge — the center of each dowel gets the highest value, forming a "peak", while the edges get low values. This terrain is what the watershed algorithm needs to find boundaries between touching dowels.

Note that the **_imshow_** function has a second parameter which stretches the distance transform image over the full range of the grayscale.

Now do the watershed transform on the distance image.

```
% perform watershed on the complement of the distance transform image
L = watershed(imcomplement(D));
figure(3)
imshow(L, [0 max(L(:))])
title('Watershed Segemented Label')
```
<p align="center"> <img src="Results/Task_6_watershed_segment.png" /> </p>

> Make sure you understand the image presented. Why is this appears as a grayscale going from dark to light from left the right?

> The watershed function returns a label matrix `L` where each segmented region is assigned a sequential integer (0 for boundaries, 1, 2, 3, ... for regions). MATLAB assigns these labels roughly in a left-to-right, top-to-bottom scanning order. When displayed with `imshow(L, [0 max(L(:))])`, the label values are linearly mapped to grayscale intensity — lower labels appear darker (left side) and higher labels appear brighter (right side). This is not actual brightness information, just a visualization of the region numbering. 

```
% Merge everything to show segmentation
W = (L==0);
g2 = g | W;
figure(4)
montage({I, g, W, g2}, 'size', [2 2]);
title('Original Image - Binarized Image - Watershed regions - Merged dowels and segmented boundaries')
```
<p align="center"> <img src="Results/Task_6_overall.png" /> </p>

> Explain the montage in this last step.

> Top-left: original dowel image. Top-right: cleaned binary image after thresholding and morphological ops. Bottom-left: watershed boundary lines (where L == 0). Bottom-right: the binary image with watershed boundaries overlaid — now touching dowels are separated by inverted watershed boundary lines.


## Challenges

You are not required to complete all challenges.  Do as many as you can given the time contraints.
1. The file **_'assets/random_matches.tif'_** is an image of matches in different orientations.  Perform edge detection on this image so that all the matches are identified.  Count the matches.
   
2. The file **_'assets/f14.png'_** is an image of the F14 fighter jet.  Produce a binary image where only the fighter jet is shown as white and the rest of the image is black.
   
3. The file **_'assets/airport.tif'_** is an aerial photograph of an airport.  Use Hough Transform to extract the main runway and report its length in number of pixel unit.  Remember that because the runway is at an angle, the number of pixels it spans is NOT the dimension.  A line at 45 degree of 100 pixels is LONGER than a horizontal line of the same number of pixels.
   
4. Use k-means clustering, perform segmentation on the file **_'assets/peppers.png'_**.
