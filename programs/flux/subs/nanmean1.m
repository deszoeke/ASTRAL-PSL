function m = nanmean1(x,dim)
%nanmean1 Mean value, ignoring NaNs.
%   M = nanmean1(X) returns the sample mean of X, treating NaNs as missing
%   values.  For vector input, M is the mean value of the non-NaN elements
%   in X.  For matrix input, M is a row vector containing the mean value of
%   non-NaN elements in each column.  For N-D arrays, nanmean1 operates
%   along the first non-singleton dimension.
%
%   nanmean1(X,DIM) takes the mean along dimension DIM of X.
%
%   See also MEAN, nanmedian1, nanstd1, nanvar1, nanmin1, nanmax1, nansum1.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 2.13.4.3 $  $Date: 2004/07/28 04:38:41 $

% Find NaNs and set them to zero
nans = isnan(x);
x(nans) = 0;

if nargin == 1 % let sum deal with figuring out which dimension to use
    % Count up non-NaNs.
    n = sum(~nans);
    n(n==0) = NaN; % prevent divideByZero warnings
    % Sum up non-NaNs, and divide by the number of non-NaNs.
    m = sum(x) ./ n;
else
    % Count up non-NaNs.
    n = sum(~nans,dim);
    n(n==0) = NaN; % prevent divideByZero warnings
    % Sum up non-NaNs, and divide by the number of non-NaNs.
    m = sum(x,dim) ./ n;
end

