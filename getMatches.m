function [potential_matches, scores] = getMatches(f1, d1, f2, d2)
%% Description
% [Input]
%   f1: figure 1, size: 4 * #keypoints
%   d1: descriptor of f1, size: 128 * #keypoints
%   f2: figure 2, size: 4 * #keypoints
%   d2: descriptor of f2, size: 128 * #keypoints
% [Output]
%   potential_matches:
%   scores: each pair's difference
 
[matches1, scores1] = vl_ubcmatch(d1, d2); % size: 2 * #matches; 
[matches] = matchFunction(d1', d2'); % size: 2 * #matches; 
matches = matches';
% matches(1,:) = matches( ~ isnan(matches(1,:)));
 
for num = 1:size(matches,2)
    fprintf('num is %d',num);
    if ~isnan(matches(1,num))
%         matches(:,num)=matches(:,num);
          matches(:,num)=0;
    else
        matches(:,num)=[];
    end
end

numMatches = size(matches,2); % get #matches 
pairs = nan(numMatches, 3, 2);
pairs(:,:,1)=[f1(2,matches(1,:)); % all x value from keypoints of f1
              f1(1,matches(1,:)); % all y value from keypoints of f1
              ones(1,numMatches)]'; % ???
pairs(:,:,2)=[f2(2,matches(2,:)); % all x value from keypoints of f2
              f2(1,matches(2,:)); % all y value from keypoints of f2
              ones(1,numMatches)]'; % ???

potential_matches = pairs;

end