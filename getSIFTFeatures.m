function [f, d] = getSIFTFeatures(image, edgeThresh)
% f is : [4*N] (N is SIFT feature points)
%   4=[X;Y;S;TH], where X,Y
%   is the (fractional) center of the frame, S is the scale and TH is
%   the orientation (in radians).

% d is : [128*N] 
%   128-d discriptor of SIFT point N

%convert images to greyscale
if (size(image, 3) == 3)
    Im = single(rgb2gray(image));
else
    Im = single(image);
end

% get features and descriptors
[f, d] = vl_sift(Im, 'EdgeThresh', edgeThresh);

end