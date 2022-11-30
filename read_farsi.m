clc
close all;
clear;
load TRAININGSET;
totalLetters=size(TRAIN,2);  
di=dir('pre_data');
st={di.name};
nam=st(3:end);
len=length(nam); 
for    i=1:len
    rgb_pic = imread(['pre_data','\',cell2mat(nam(i))]);
 
    % imshow(pic);
    pic =imresize(rgb_pic,[300 500]);
    rgb_pic = imresize(rgb_pic,[300 500]);
    pic= rgb2gray(pic);
  
 
    threshold = graythresh(pic);
    pic=~im2bw(pic,threshold);
   
  
    pic =bwareafilt(pic,500);
    pic =bwareaopen(pic,100);
  %  background=bwareaopen(pic,3000);
   % pic = pic - background;
     %imshow(pic);
    [labeledImage numberOfObjcts] = bwlabel(pic);
    
    blobMeasurements = regionprops(labeledImage,'BoundingBox');
%     hold on
%      imshow(pic);
    for n=1:size(blobMeasurements,1)         
          cropped_piece=imcrop(pic,blobMeasurements(n).BoundingBox); 
             imshow(cropped_piece);
          m=size(cropped_piece,2);
          k=size(cropped_piece,1);
          
          aspect_ratio =m/k; %aspect ratio of car plaques is 5 
          % we find the pieces with ar of aproximiately this range

          if  2 <= aspect_ratio & aspect_ratio <= 12
            
               car_plaque= cropped_piece;
                rgb_piece = imcrop(rgb_pic,blobMeasurements(n).BoundingBox);
               imshow(rgb_piece);
                diff_im = imsubtract(rgb_piece(:,:,3), rgb2gray(rgb_piece));
               %Use a median filter to filter out noise
                % check if the plaque contains blue in the rgb original
               % picture to make sure it's a plaque
              
               diff_im = medfilt2(diff_im, [3 3]);
               diff_im = im2bw(diff_im,0.18);
               diff_im = bwareaopen(diff_im,300);
               bw = bwlabel(diff_im, 8);
               stats = regionprops(bw, 'BoundingBox', 'Centroid'); 
               size_of_stats = length(stats);
               if(size_of_stats > 0)
                   
                   [L,Ne]=bwlabel(car_plaque);
                    propied=regionprops(L,'BoundingBox');
                                            
                    final_output=[];
                    t=[];
                    for j=2:Ne
                       [r,c] = find(L==j);
                       Y=car_plaque(min(r):max(r),min(c):max(c));
                       imshow(Y)
                       Y=imresize(Y,[70,50]);
                       imshow(Y)
                        
                       ro=zeros(1,totalLetters);
                       for k=1:totalLetters   
                               ro(k)=corr2(TRAIN{1,k},Y);
                               end
                                [MAXRO,pos]=max(ro);
                                if MAXRO>.45
                                    out=cell2mat(TRAIN(2,pos));       
                                    final_output=[final_output out];
                                end
                                
                    end
                    file = fopen(cell2mat(nam(i)), 'w');
                    fprintf(file,'%s\n',final_output);
                    fclose(file);
                  
               end
              
          end
    end

end
clear;
