clc
close all;
clear;
load TRAININGSET;
totalLetters = size(TRAIN, 2);

[file, path] = uigetfile({'*.jpg;*.bmp;*.png;*.tif'}, 'Choose an image');
s = [path, file];
rgb_pic = imread(s);
rgb_pic = imresize(rgb_pic, [300 500]);
subplot(2, 2, 1)
imshow(rgb_pic);

% Use a median filter to filter out noise
% check if the piece contains blue in the rgb original
% picture to make sure it's a plaque
diff_im = imsubtract(rgb_pic(:, :, 3), rgb2gray(rgb_pic));
diff_im = medfilt2(diff_im, [3 3]);
diff_im = im2bw(diff_im, 0.15);
diff_im = bwareaopen(diff_im, 100);

[labeledImage, numberOfObjcts] = bwlabel(diff_im);
blobMeasurements = regionprops(labeledImage, 'BoundingBox');
hold on

for n = 1:size(blobMeasurements, 1)
    rectangle('Position', blobMeasurements(n).BoundingBox, 'EdgeColor', 'g', 'LineWidth', 2)
end

hold off

for n = 1:size(blobMeasurements, 1)
    blobMeasurements(n).BoundingBox(1) = blobMeasurements(n).BoundingBox(1) + blobMeasurements(n).BoundingBox(3);
    blobMeasurements(n).BoundingBox(2) = blobMeasurements(n).BoundingBox(2) - 15;
    blobMeasurements(n).BoundingBox(3) = blobMeasurements(n).BoundingBox(3) * 10.2;
    blobMeasurements(n).BoundingBox(4) = blobMeasurements(n).BoundingBox(4) + 15;
end

for n = 1:size(blobMeasurements, 1)

    cropped_piece = imcrop(rgb_pic, blobMeasurements(n).BoundingBox);

    subplot(2, 2, 2)
    imshow(cropped_piece);

    car_plaque = rgb2gray(cropped_piece);
    threshold = graythresh(car_plaque);
    car_plaque = ~im2bw(car_plaque, threshold);
    subplot(2, 2, 3)
    imshow(car_plaque);
    car_plaque = car_plaque - bwareaopen(car_plaque, 2000);
    subplot(2, 2, 3)
    imshow(car_plaque);
    car_plaque = bwareaopen(car_plaque, 30);
    subplot(2, 2, 3)
    imshow(car_plaque);

    bw = bwlabel(diff_im, 8);
    stats = regionprops(bw, 'BoundingBox', 'Centroid');
    size_of_stats = length(stats);

    if (size_of_stats > 0)

        [L, Ne] = bwlabel(car_plaque);
        propied = regionprops(L, 'BoundingBox');

        hold on

        for n = 1:size(propied, 1)
            rectangle('Position', propied(n).BoundingBox, 'EdgeColor', 'g', 'LineWidth', 2)
        end

        hold off

        final_output = [];
        t = [];

        for j = 1:Ne

            [r, c] = find(L == j);
            Y = car_plaque(min(r):max(r), min(c):max(c));
            subplot(2, 2, 4)
            imshow(Y)

            m = size(Y, 2);
            k = size(Y, 1);
            aspect_ratio = m / k; %aspect ratio of letters

            if (aspect_ratio >= 3) || (aspect_ratio <= 1/3)
                continue
            end

            Y = imresize(Y, [70, 50]);

            ro = zeros(1, totalLetters);

            for k = 1:totalLetters
                ro(k) = corr2(TRAIN{1, k}, Y);
            end

            [MAXRO, pos] = max(ro);

            if MAXRO > .45
                out = cell2mat(TRAIN(2, pos));
                final_output = [final_output out];
            end

        end

        file = fopen('number_Plate.txt', 'wt');
        fprintf(file, '%s\n', final_output);
        fclose(file);

    end

end

clear;
