function out = filter_padded(in, b, a, N)

% Modifies input array by padding the beginning and end with with copies of the
% first and last N points, respectively.  Then applies filtfilt() using the
% specified 'b' and 'a' coefficients.  N defaults to 1000 if not specified.
% Padding is stripped off and the filtered array is returned as 'out'

% This approach seeks to reduce transient effects at the ends of 'out'.

% Works with 1D and 2D input arrays.  Applies filter along longest dimension.
% 4/2015 BWB

if nargin == 3
    N = 1000;
end;

dims = size(in);    % rows and columns
if length(dims) > 2
    disp 'filter_padded(): Error, input array > 2-D';
    out = in;
    return
end;

transpose = (dims(1)<dims(2));
if transpose        % convert to column vectors if necessary
    in = in';
    dims = size(in);
end;

% if dims(1)==1   % one row only
%     front = in(1,1:N);          % copy N point data segments
%     back = in(1,dims(2)-N+1:end);
%     out = [front, in, back];    % pad front and back with data
%     out = filtfilt(b,a,out);    % filter
%     out = out(1,N+1:N+dims(2)); % remove padding
%     return
% end;

front = in(1:N,:);          % copy N point data segments
back = in(dims(1)-N+1:end,:);
out = [front;in;back];      % pad front and back with data
out = filtfilt(b,a,out);	% filter
out = out(N+1:N+dims(1),:); % remove padding

if transpose
    out = out';
end;

return


