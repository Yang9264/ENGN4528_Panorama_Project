function [ T ] = computeTrans( imgs )
%% Description
% [input]
%   imgs:  ?????
% [output]
%   T:
Thresh = 10;
confidence = 0.99;
inlierRatio = 0.3;
epsilon = 1.5;

nImgs = size(imgs, 4);

T = zeros(3, 3, nImgs);
T(:, :, 1) = eye(3);
[f2, d2] = getSIFTFeatures(imgs(:, :, :, 1), Thresh);

for i = 2 : nImgs % from the second img of the img sequence
    f1 = f2;
    d1 = d2;
    [f2, d2] = getSIFTFeatures(imgs(:, :, :, i), Thresh);
%      [f2, d2,locs] = sift(imgs(:, :, :, i)); % self-made sift function
    % get matched sift point between imgs
    [matches, ~] = getMatches(f1, d1, f2, d2);
    [T(:, :, i),~] = RANSAC(confidence, inlierRatio, 1, matches, epsilon);
end
end

