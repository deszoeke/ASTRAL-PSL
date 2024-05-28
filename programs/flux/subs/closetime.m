function [closesttime]=closetime(array, target)
% find the closest index in array to the target value

if isnan(target) ~= 1
    diffs = abs(array - target);
    closesttime = min(find(diffs == min(diffs)));
else
    closesttime = 1;
end
