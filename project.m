clc
clear all
close all 

motionVideoObject = VideoReader('09_04.mpg');
v = VideoWriter('09_04_Compressed' );
open(v)

%Ensure it is same duration as the given video 
motionVideoObject.Duration
%Read the number of frames contained inside the video 
numFrames = get(motionVideoObject,'NumberOfFrames');
distortion=zeros(1,3);

 opts = statset('Display','final');
tic
 %Iterate over the frames 
for k=1:numFrames
    fprintf('============================ Frame  (%d  / %d) ============================\n' , k , numFrames );
     crntFrame = read(motionVideoObject,k);
     a = double(crntFrame(:,:,1));
     b = double(crntFrame(:,:,2));
     c = double(crntFrame(:,:,3));
     % Original frame  
     %	Write PNG Image of original file  [usefule for debug] 
     if k <= 0% or rather do it for a specified number of frames     
         imwrite (crntFrame,strcat(strcat('Orig',int2str(k)),'.png'))
     end 
     %%%%%%%%                            %%%%%%%%
     [clustNumR,centroidsR] = kmeans( a(:) ,18,'Distance','cityblock',...
    'Replicates',5,'Options',opts);
     [clustNumG,centroidsG] = kmeans( b (:),18,'Distance','cityblock',...
    'Replicates',5,'Options',opts);
     [clustNumB,centroidsB] = kmeans( c(:) ,18,'Distance','cityblock',...
    'Replicates',5,'Options',opts);

     
    [r,c,d]=size(crntFrame);
    clustNumR=reshape(clustNumR,r,c);
    clustNumG=reshape(clustNumG,r,c);
    clustNumB=reshape(clustNumB,r,c);
     
    
   crntFrameCompressed = zeros(r,c,3);
     %%iterate over the frame 
     for i=1:r
         for j=1:c
            
            crntFrameCompressed(i,j,1)=round(centroidsR(clustNumR(i,j)));
            crntFrameCompressed(i,j,2)=round(centroidsG(clustNumG(i,j)));
            crntFrameCompressed(i,j,3)=round(centroidsB(clustNumB(i,j)));           
         end
     end
     crntFrameCompressed=uint8(crntFrameCompressed);

             
     %Diplay the compressed images [usefule for debug] 
     if k <= 0% or rather do it for a specified number of frames 
         
         thisfig = figure();
         thisax = axes('Parent', thisfig);
         image(crntFrame, 'Parent', thisax);
         title(thisax, sprintf('Frame #%d', k));
         
         imwrite (crntFrameCompressed,strcat(strcat('Compressed',int2str(k)),'.png'))

     end 
     clear clustNumR;
     clear clustNumG;
     clear clustNumB;
     %produce the compressed file 
     writeVideo(v,crntFrameCompressed)
     %%%%%
     %Calculate the new distortion ratio 
     distortion(1)=distortion(1)+ (sum(sum( (crntFrameCompressed(:,:,1) > crntFrame(:,:,1)+2) | (crntFrameCompressed(:,:,1) < crntFrame(:,:,1)-2)    ))/(c*r))
     distortion(2)=distortion(2)+(sum(sum( (crntFrameCompressed(:,:,2) > crntFrame(:,:,2)+2) | crntFrameCompressed(:,:,2) < crntFrame(:,:,2)-2   ))/(c*r))
     distortion(3)=distortion(3)+(sum(sum( (crntFrameCompressed(:,:,3) > crntFrame(:,:,3)+2) | crntFrameCompressed(:,:,3) < crntFrame(:,:,3)-2   ))/(c*r))
     
     %clear crntFrameCompressed;

end
toc


close(v)
%Compression Ratio 
%Uncompressed file size : Compressed file size 
v1_stats = dir('09_04.mpg');
v2_stats = dir('09_04_Compressed.avi');
Data_Compression_Ratio = (v1_stats.bytes ./v2_stats.bytes);
fprintf('Data compression ratio = %10.5f : 1\n',Data_Compression_Ratio)
%Distortion ratio 
%The portion of original sample points which are replaced by the centroid
%of the clusters
fprintf('Distortion Ration [R Component]  = %10.5f %%\n',100*distortion(1)/numFrames)
fprintf('Distortion Ration [G Component]  = %10.5f %%\n',100*distortion(2)/numFrames)
fprintf('Distortion Ration [B Component]  = %10.5f %%\n',100*distortion(3)/numFrames)
fprintf('Distortion Ration [Overall]  = %10.5f %%\n',100*(sum(distortion))/(3*numFrames))

            
