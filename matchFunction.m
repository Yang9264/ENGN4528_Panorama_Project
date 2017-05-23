function PairedKeypoints = matchFunction(img1_des,img2_des)
%% Description
% [Input]
%   imgDescriptor1: descriptor of first image, size #keypoints * 128
%   imgDescriptor2: descriptor of second image, size #keypoints * 128
% [Output]
%   PairedKeypoints[idx1,idx2]: #matched keypoint pairs * 2, where idx1 is
%   the keypoint index of image1, idx2 is the keypoint index of image2

    img_1_des_num = size(img1_des,1); 
    img_2_des_num = size(img2_des,1); 
    Idx2 = NaN(img_2_des_num,1);
    Idx1 = NaN(img_2_des_num,1);
    k = 0.6; % empirical series, set between 0.6-0.8 according to instruction
    j = 0; % record the number of matched pairs
    for i = 1:min(img_1_des_num,img_2_des_num) %¿É¸ÄÎªmax(Img1_Height,Img2_Height)
        % for every keypoint from img2, calcualte the distance with each
        % keypoints from img1.
        temp = repmat(img2_des(i,:),[img_1_des_num,1]) - img1_des; 
        % contains all distance between img2_[i] between img_[1,#keypoints]
        distance_vec = sqrt(sum(temp.^2,2)); 
        % loc is the index of keypoints from img1 that matches i-th keypoint of img2
        [minium, loc] = min(distance_vec);  
        distance_vec(loc) = NaN; % exclude the minimum value through set it 'invisible'
        % if the minium value is smaller than a ratio times the second
        % minimum value
        if minium <= k*min(distance_vec) % k times the 'second minimum' value
            j = j+1;
            Idx1(j) = loc; % keypoint index from img1
            Idx2(j) = i; % keypoint index from img2
        end
    end
        PairedKeypoints = [Idx1,Idx2];
end