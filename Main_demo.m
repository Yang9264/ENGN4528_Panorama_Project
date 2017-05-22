path='imgs/ucsb3';
s=imageSet(fullfile(path));

f=1000;
size_bound=400.0;
full=0;
img=read(s,1);
size_1=size(img,1);
    if size_1>size_bound
        img=imresize(img,size_bound/size_1);
    end
    imgs=zeros(size(img,1),size(img,2),size(img,3),s.Count,'like',img);
     for i=1:s.Count
        new_img=read(s,i);
        if size_1>size_bound
            imgs(:,:,:,i)=imresize(new_img,size_bound/size_1);
        else
            imgs(:,:,:,i)=new_img;
        end
        
     end
    panorama=create( imgs, f, full);
    imshow(panorama);