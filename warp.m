function [output]=warp(img,f)
    output=zeros(size(img),'like',img);
    if length(size(img))==2
        Layers=1; % [Unconfirmed]if img is a gray scale img
    else
        Layers=size(img,3); % [as input img(:,:,:,i) must be 4d, this could be commented out]
    end
    for layer=1:Layers
        x_center=size(img,2)/2;
        y_center=size(img,1)/2;
        x=(1:size(img,2))-x_center;
        y=(1:size(img,1))-y_center;
        [xx,yy]=meshgrid(x,y); % [-200:200]*[-356:356] 
        % apply cylindrical transformation indicated by the tutorial pdf P14
        yy=f*yy./sqrt(xx.^2+double(f)^2)+y_center; % y = f*(y/sqrt(x^2+f^2))
        xx=f*atan(xx/double(f))+x_center; % x = f*arctan(x/f)
        % projected coordinates on the img plane
        xx=floor(xx+.5); 
        yy=floor(yy+.5);

        idx=sub2ind([size(img,1),size(img,2)], yy, xx);
      
        cylinderImg=zeros(size(img,1),size(img,2),'like',img);
        cylinderImg(idx)=img(:,:,layer); % e.g value of[400,712]-->[400,677]

        output(:,:,layer)=cylinderImg; % 
%         imshow(cylinderImg);
    end
end