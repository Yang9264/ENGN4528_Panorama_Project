clc
clear 
close all

%% User interface
yz=0;
while yz == 0
VideoNumber = input('Please input the number of video clip you want to run (from 1 to 6):\n','s');
switch VideoNumber
    case '1'
        Video = 'Clip1.mp4';
        yz = 1;
    case '2'
        Video = 'Clip2.mp4';
        yz = 1;
    case '3'
        Video = 'Clip3.mp4';
        yz = 1;
    case '4'
        Video = 'Clip4.mp4';
        yz = 1;
    case '5'
        Video = 'Clip5.mp4';
        yz = 1;
    case '6'
        Video = 'Clip6.mp4';
        yz = 1;
    otherwise
        fprintf('Your input is your correct! Please do it again!\n');
end
end

% create a multimedia reader object in mov, and read its frame into the
% NumberOfFrames
mov=VideoReader(Video);
NumberOfFrames = round(mov.FrameRate*mov.Duration);

%% Initilized variables
% banana, apple, tomato, pear, not fruit, these variables stands for
% whether the specific fruit is recognised in each frame. If it is, the
% value will be 1, otherwise, will be 0
banana = zeros(NumberOfFrames,1);
apple = zeros(NumberOfFrames,1);
tomato = zeros(NumberOfFrames,1);
pear = zeros(NumberOfFrames,1);
notfruit = zeros(NumberOfFrames,1);
% bananas, apples, tomatos, pears, not fruits are variables that represent
% accumulated numbers of the furits that have been tracked 
bananas = 0;
apples = 0;
tomatoes = 0;
pears = 0;
oranges = 0;
nonfruits = 0;
errors = 0;
% ’≈ŒƒÓ£–¥
IndicatorNow = zeros(1,720);
IndicatorLast = zeros(1,720);
IndicatorNow_Uni = [];
IndicatorLast_Uni = [];
data = [];
UpdataTrigger = 1;

%% main loop for reading, processing, ouputing each image of video
for FrameNumber=1:NumberOfFrames
    
    CurrentImg = readFrame(mov); % read next frame
    I=CurrentImg;
    Iout = I;
    Iout = double(Iout); % Iout is output frame
    %% image preprocessing to extract target objects in binary image 
    I2=rgb2gray(I); % convert rgb image of each frame into gray scale image 
    BW=im2bw(I2,0.7); % set threshold 0.7 to distinguish background and fore ground objects
    BW(:,1:20) = 0; % make pixels of firt 20 column in binary image into black 
    BW(:,690:720) = 0; % make  pixels from 690 column to 720 column in the bianry image into black
    J2 = imfill(BW,'holes'); %fill holes of binary image
    [LabelJ2,numJ2] = bwlabel(J2,8); % index each object in the binary image 
    for i=1:numJ2 % eliminate the objects that are smaller than 300 pixels area
        if length(find(LabelJ2==i))<300
            J2(LabelJ2==i)=0; 
        end
    end
    
    %% check if fruit across the upper and lower boundary
    % If the fruit touch on upper and lower boundary of the out put image,
    % the fruit will be erased from the image
    [row,~] = size(J2); %caculate total rows of pixels of binary image 
    xx1=unique(LabelJ2(5,:)); %xx1 records index of objects that touch 5th row(upper boundary)
    xx2=unique(LabelJ2(row-5,:));%xx2 records index of objects that touch the fifth last row(lower boundary)
    % eliminate the objects from the binary image if they touch lower and upper boundary
    for i=1:length(xx1) 
        J2(LabelJ2==xx1(i))=0; 
    end
    for i=1:length(xx2) 
        J2(LabelJ2==xx2(i))=0; 
    end
    [LabelJ2,numJ2] = bwlabel(J2,8);   
    
    %% Calculae features values
    J3 = bwperim(J2);
    [Label,num] = bwlabel(J3,8); 
    Perimeter = zeros(1,num);
    [row,col] = size(Label);
    for i = 1 : row %calculate the perimeter
        for j = 1 : col
            if(Label(i,j) > 0)
                Perimeter(Label(i,j)) = Perimeter(Label(i,j)) + 1;
            end
        end
    end  
    

    FilledLabel = imfill(Label,'holes');
    Area = zeros(1,num);
    
    for i = 1 : num
        Area(i) = 0;
    end 
    [row,col] = size(FilledLabel);
    for i = 1 : row %calculate the size of area
        for j = 1 : col
            if(FilledLabel(i,j) > 0)
                Area(FilledLabel(i,j)) = Area(FilledLabel(i,j)) + 1;
            end
        end
    end

    
    %calculate the mean of hue
    HSV = rgb2hsv(I);
    [row,col] = size(FilledLabel);
    MeanHue = zeros(1,num);
    for i = 1 : num
        Hue = zeros(Area(i),1);
        nPoint = 0;
        for j = 1 : row
            for k = 1 : col
                if(FilledLabel(j,k) == i)
                    nPoint = nPoint + 1;
                    Hue(nPoint,1) = HSV(j,k,1);
                end
            end
        end
        
        Hue(:,1) = sort(Hue(:,1));
        for j = floor(nPoint*0.1) : floor(nPoint*0.9) % get rid of some extrem values
            MeanHue(i) = MeanHue(i) + Hue(j,1);
        end
        MeanHue(i) = MeanHue(i) / (0.8*nPoint);
    end   
    

    Ellipseratio = zeros(1,num);
    Product = zeros(1,num);
    
    for i = 1 : num
        Ellipseratio(i) = 4*pi*Area(i)/Perimeter(i)^2; %calculate the Ellipseratio
        Product(i) = Ellipseratio(i)*Area(i)*MeanHue(i); %calculate the Product, which is the product of Area, Ellipseratio, and MeanHue
        if MeanHue(i)>0.23||MeanHue(i)<0.07||Area(i)<500||Area(i)<2500&&MeanHue(i)>0.13
            LabelJ2(LabelJ2==i)=0;
        end
    end
    
    %% Drawing bounding box and display the features
    xmin=zeros(1,num);
    xmax=zeros(1,num);
    ymin=zeros(1,num);
    ymax=zeros(1,num);
    Iout = uint8(Iout);
    if num>=1
        for i=1:num % Identify the fruit based on the current features values
            
            if MeanHue(i)<0.14&&Area(i)<4000
                fruit = 'tomato';
            elseif Area(i)>16000
                fruit = '2 bananas';
            elseif Ellipseratio(i)<0.5&&Area(i)>8000||Ellipseratio(i)<0.65&&Area(i)>10000
                fruit = 'banana';
                
            elseif MeanHue(i)>0.1950&&Area(i)>7000||Ellipseratio(i)>1.04&&Area(i)>7000||...
                    Product(i)>1650&&Area(i)>7000||Area(i)>10000&&MeanHue(i)>0.16||...
                    MeanHue(i)>0.18&&Ellipseratio(i)>0.98&&Area(i)>8500
                fruit = 'apple';
            elseif MeanHue(i)>0.168&&Area(i)>4000&&Area(i)<11000
                fruit = 'pear';
            elseif Area(i)>7000
                fruit = 'orange';
            elseif Area(i)>3000
                fruit = 'nonfruit';
            else fruit = 'error!';
                
            end
            
            if ~strcmp(fruit,'error!') % drawing four green lines as each side of bounding box based on the maximum row and column coordinate of each fruit
                [x,y]=find(Label==i);
                xmin(1,i)=min(x);
                xmax(1,i)=max(x);
                ymin(1,i)=min(y);
                ymax(1,i)=max(y);
                Iout(xmin(i):xmin(i)+1,ymin(i):ymax(i),1)=0;
                Iout(xmin(i):xmin(i)+1,ymin(i):ymax(i),2)=255;
                Iout(xmin(i):xmin(i)+1,ymin(i):ymax(i),3)=7;
                Iout(xmax(i):xmax(i)+1,ymin(i):ymax(i),1)=0;
                Iout(xmax(i):xmax(i)+1,ymin(i):ymax(i),2)=255;
                Iout(xmax(i):xmax(i)+1,ymin(i):ymax(i),3)=7;
                Iout(xmin(i):xmax(i),ymin(i):ymin(i)+1,1)=0;
                Iout(xmin(i):xmax(i),ymin(i):ymin(i)+1,2)=255;
                Iout(xmin(i):xmax(i),ymin(i)-1:ymin(i),3)=7;
                Iout(xmin(i):xmax(i),ymax(i):ymax(i)+1,1)=0;
                Iout(xmin(i):xmax(i),ymax(i):ymax(i)+1,2)=255;
                Iout(xmin(i):xmax(i),ymax(i):ymax(i)+1,3)=7;
                string = sprintf('%s\nM=%0.4f\nE=%0.4f\nA=%1.0f\nP=%1.0f',fruit,MeanHue(i),Ellipseratio(i),Area(i),Product(i));
                Iout = insertText(Iout,[ymax(i),xmin(i)],string,'TextColor','white','BoxColor','black');
            end
            
            
        end
    end
    
    Iout = uint8(Iout); % shown the frame after bounding box drawing and features showing
    imshow(Iout);
    
    %% Counting
    IndicatorNow = zeros(1,720); 
    % IndicatorNow is a vector with length equals to the column number of the frame,
    % indicating wether each pixel on the 220 row of the frame is fruit
    % piexel of background pixel
    % IndicatorLast is the IndicatorNow vector from last frame
    N = 1;
    if FrameNumber >4
        for i=2:720
            if LabelJ2(220,i)~=0
                if N>=2&&LabelJ2(220,i)==LabelJ2(220,floor(mean(find(IndicatorNow==N-1))))
                    N=N-1;
                end
                IndicatorNow(i)=N;
            elseif LabelJ2(220,i-1)~=0
                N=N+1;
            end
        end
    end
    % The background pixels are indicated as 0, the fruit pixels are
    % indicated as 1,2,3... for different fruits
    
    IndicatorNow_Uni = unique(IndicatorNow(IndicatorNow~=0));
    % IndicatorNow_Uni deletes the 0s and repetitive elements in
    % IndicatorNow, remaining only non-zero values without repetition. The
    % length of IndicatorNow_Uni should be equal to the number of fruits
    % hitting the 220th row of current frame.
    
    for i = 1:length(IndicatorLast_Uni)
        if sum(IndicatorNow(IndicatorLast==i))==0 % check if the fruit in last frame has left the 220th row
            DataSize = size(data);
            if i>DataSize(2)
                k=i-1;
                if k==0
                    k=1; % It is for avoiding some potential bugs
                end
            else
                k=i;
            end
            % If a fruit was on the 220th row in the last frame, but
            % not this frame anymore, that means the fruit has left the
            % 220th row. We can calculate the mean value of its features
            % and identify what fruit it is.
            
            data(:,k) = data(:,k)/data(5,k); 
            % calculate the mean value of features the row 1-4  in
            % data is the summed features values and the row 5 is the
            % number of how much time the feathers have been plused.
            UpdataTrigger = 1; % The trigger variable indicate we need to change the displayed data
            
            if data(1,k)<0.14&&data(3,k)<4000 % Identify the fruit from its mean features values
                tomatoes = tomatoes + 1;
            elseif data(3,k)>16000
                bananas = bananas + 2;
            elseif data(2,k)<0.5000&&data(3,k)>8000||data(2,k)<0.65&&data(3,k)>10000
                bananas = bananas + 1;
            elseif data(1,k)>0.1950&&data(3,k)>7000||data(2,k)>1.04&&data(3,k)>7000||data(4,k)>1650&&data(3,k)>7000||...
                    data(3,k)>10000&&data(1,k)>0.16||data(1,k)>0.18&&data(2,k)>0.98&&data(3,k)>8500
                apples = apples + 1;
            elseif data(1,k)>0.168&&data(3,k)>4000&&data(3,k)<11000
                pears = pears + 1;
            elseif data(3,k)>7000
                oranges = oranges + 1;
            elseif data(3,k)>3000
                nonfruits = nonfruits + 1;
                [y, fs]=audioread('alarm1.mp3');
                sound(y, 41000);
            else
                errors = errors + 1;
            end
            
            data = [data(:,1:k-1) data(:,k+1:end)];
            % delete the data of identified fruit
        end
    end
    
    for i = 1:length(IndicatorNow_Uni)
        if sum(IndicatorLast(IndicatorNow==i))==0 
            position = find(IndicatorNow==i);
            position =position(1);
            data = [data(:,1:(i-1)) [MeanHue(LabelJ2(220,position));Ellipseratio(LabelJ2(220,position));...
                Area(LabelJ2(220,position));Product(LabelJ2(220,position));1] data(:,i:end)];
            % If a new fruit appears, create a new column in data matrix to
            % store its summed features
        else
            DataSize = size(data);
            if i>DataSize(2)
                break
            end
            position = find(IndicatorNow==i);
            position =position(1);
            data(:,i) = data(:,i) + [MeanHue(LabelJ2(220,position));Ellipseratio(LabelJ2(220,position));...
                Area(LabelJ2(220,position));Product(LabelJ2(220,position));1];
            % If the fruit is not new, plus the features values to the
            % corresponding column in data matrix.
        end
    end
    
    
    
    IndicatorLast = IndicatorNow;
    % IndicatorLast is the IndicatorNow vector from last frame
    IndicatorLast_Uni = IndicatorNow_Uni;
    % IndicatorLast_Uni is the IndicatorNow_Uni vector from last frame
    
    if UpdataTrigger == 1
        fprintf('Apples:%1.0f\nPears:%1.0f\nTomatoes:%1.0f\nBananas:%1.0f\nOranges:%1.0f\nNon-fruits:%1.0f\n\n',...
            apples,pears,tomatoes,bananas,oranges,nonfruits);
    end % update the displayed number of the fruits
    
    UpdataTrigger = 0;
end

%% Calculating success rate
switch mov.name
    case 'Clip1.mp4'
        SuccessRate = (1-(apples+pears+tomatoes+abs(bananas-10)+oranges)/10)*100;
    case 'Clip2.mp4'
        SuccessRate = (1-(apples+abs(pears-4)+abs(tomatoes-12)+bananas+abs(oranges-3))/19)*100;
    case 'Clip3.mp4'
        SuccessRate = (1-(apples+pears+abs(tomatoes-12)+bananas+abs(oranges-7))/19)*100;
    case 'Clip4.mp4'
        SuccessRate = (1-(abs(apples-3)+abs(pears-5)+tomatoes+bananas+oranges)/8)*100;
    case 'Clip5.mp4'
        SuccessRate = (1-(abs(apples-9)+abs(pears-10)+abs(tomatoes-7)+bananas+oranges)/26)*100;
    case 'Clip6.mp4'
        SuccessRate = (1-(abs(apples-41)+abs(pears-59)+abs(bananas-49)+oranges+tomatoes)/149)*100;
end

fprintf('Success rate:%1.0f%s\n\n',SuccessRate,'%');