function N = replace_NaN_nearest_neighbor(M)

% Replaces NaNs in 1D array with nearest finite value.
% Returns filled array N without altering input array M.
% If number of NaNs is more than 20%, abort.
% 1/2015 BWB

N = M;


bads = find(isnan(N));    % indices for all nans
if isempty(bads)
    return
elseif length(bads) > 0.20*length(N)
    return
else
    fins = find(~isnan(N));   % indices for all finites
    for ii=1:length(bads)     % for all NaNs
        [mins,locs] = min(abs(fins-bads(ii))); % locate nearest finite
        N(bads(ii)) = N(fins(locs)); % replace NaN with nearest finite
    end;
end;