function y = nanmedian1(x,dim)
%nanmedian1 Median value, ignoring NaNs.
%   M = nanmedian1(X) returns the sample median of X, treating NaNs as
%   missing values.  For vector input, M is the median value of the non-NaN
%   elements in X.  For matrix input, M is a row vector containing the
%   median value of non-NaN elements in each column.  For N-D arrays,
%   nanmedian1 operates along the first non-singleton dimension.
%
%   nanmedian1(X,DIM) takes the median along the dimension DIM of X.
%
%   See also MEDIAN, nanmean1, nanstd1, nanvar1, nanmin1, nanmax1, nansum1.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 2.12.2.2 $  $Date: 2004/01/24 09:34:33 $

if nargin == 1
    y = prctilex(x, 50);
else
    y = prctilex(x, 50,dim);
end
