clc;
clear all;
close all;

mov = VideoReader('./imgs/PlayGround2.MOV');
% mov = VideoReader('./imgs/SportsHall.MOV');
% mov = VideoReader('./imgs/UnionCourt.MOV');

NumberOfFrames = round(mov.FrameRate*mov.Duration);
for i = 1:2*mov.FrameRate:mov.numberofframes
    b = read(mov,i); 
%     imwrite(b,strcat('m',int2str(i),'.jpg'),'bmp')
imwrite(b,['./imgs/img_video4/',int2str(i),'.jpg']);
end

%% Section: 
% Input