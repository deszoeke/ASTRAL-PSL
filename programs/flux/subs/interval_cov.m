function x3 = interval_cov(t1, x1, x2, t2)
%{
computes covariance for high-rate data over intervals t2.

all inputs must be 1-D.
t2 represents interval bin edges.

Times are assumed to mark the start point of each interval.
HOWEVER, THE LAST VALUE OF T2 IS ASSUMED TO BE THE STOP POINT AND
NO AVG WILL BE COMPUTED FOR THIS VALUE.  THE RESULT ARRAY WILL
THEREFORE HAVE t2-1 ELEMENTS OR ROWS.

Uniform delta-t is not required in either t1 or t2, although in most
applications delta-t2 will be uniform.  Ranges of t1 and t2 must overlap,
but the start and end points for each time series may be different.
Intervals in t2 outside the range of t1 are set to NaN.

Returns t2(1:end-1) as first column of x2
%}

% check inputs for validity
test_t1 = (size(t1,1)~=1 && size(t1,2)~=1);
test_t2 = (size(t2,1)~=1 && size(t2,2)~=1);
if (test_t1 || test_t2)
    error('interval_cov: time arrays must be 1-D');
end
test_x1 = (size(x1,1)~=1 && size(x1,2)~=1);
test_x2 = (size(x2,1)~=1 && size(x2,2)~=1);
if (test_x1 || test_x2)
    error('interval_cov: data arrays must be 1-D');
end
if size(x1,1)==1 && size(x1,2)>1
    x1 = x1'; % if x1 is 1-D row, convert to col
end
if size(x2,1)==1 && size(x2,2)>1
    x2 = x2'; % if x2 is 1-D row, convert to col
end
if length(t1) ~= size(x1,1)
    error('interval_cov: t1 and x1 not equal length');
end
if size(x1) ~= size(x2)
    error('interval_cov: x1 and x2 not the same size');
end
if mean(diff(t2)) <= mean(diff(t1))
    error('interval_cov: delta t2 should be > delta t1');
end
if t2(1) > t1(end) || t2(end) < t1(1)
    error('interval_cov: intervals do not overlap');
end

rows = length(t2)-1;
x3 = zeros(rows,1)*NaN;

% We operate over intervals in t2, but begin and end times
% of t2 may differ from begin and end of t1.
% Therefore, find the range of t2 over which we will operate.
% Start point in t2:
ii = find(t2 <= t1(1),1,'last');   % find last t2  <= t1(1)
if isempty(ii)
    startPt = 1;     % t2 starts later than t1, so start at t2(1)
else
    startPt = ii;    % beginning of first interval is tt2[ii[-1]]
end
    
% End point in t2 will be the end of the last interval
ii = find(t2 >= t1(end),1,'first'); % find first value in t2 >= t1(end)
if isempty(ii)
    endPt = length(t2);   % t2 ends before t1, so end at t2(end)
else
    endPt = ii;        % end of last interval is t2(ii(1))
end

intvl = startPt:endPt;    % indices in t2 for valid bin edges
zz = length(intvl)-1;     % number of bin aves to compute
% compute bin covariances
for jj=1:zz
    [~,ii] = min(abs(t1-t2(intvl(jj))));  % last t1 <= start of intvl
    kk = find(t1<t2(intvl(jj)+1),1,'last'); % last t1 < next intvl
    if ii==kk  % no data for this bin
        continue
    end
    temp = nancov1(x1(ii:kk),x2(ii:kk));    % 2x2 covariance matrix
    x3(intvl(jj)) = temp(1,2);
end

% add timestamp as first col of output array
x3 = [t2(1:end-1),x3];

end
