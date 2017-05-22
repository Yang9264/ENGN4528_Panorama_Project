clc;
clear all;
close all;

mov = VideoReader('3.mp4') 
NumberOfFrames = round(mov.FrameRate*mov.Duration);
for i = 1:2*mov.FrameRate:mov.numberofframes
    b = read(mov,i); 
%     imwrite(b,strcat('m',int2str(i),'.jpg'),'bmp')
imwrite(b,['./ucsb5/',int2str(i),'.jpg']);
end