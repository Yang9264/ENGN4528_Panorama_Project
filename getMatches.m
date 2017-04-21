function [potential_matches, scores] = getMatches(f1, d1, f2, d2)
%% Description
% [Input]
%   f1: figure 1, size: original image size
%   d1: descriptor of f1, size: #keypoints * 1
%   f2: figure 1, size: original image size
%   d2: descriptor of f1, size: #keypoints * 1
% [Output]
%   potential_matches:
%   scores:
 
[matches, scores] = vl_ubcmatch(d1, d2); % 2 * #matches

numMatches = size(matches,2); % get #matches 
pairs = nan(numMatches, 3, 2);
pairs(:,:,1)=[f1(2,matches(1,:));f1(1,matches(1,:));ones(1,numMatches)]';
pairs(:,:,2)=[f2(2,matches(2,:));f2(1,matches(2,:));ones(1,numMatches)]';

potential_matches = pairs;

end
