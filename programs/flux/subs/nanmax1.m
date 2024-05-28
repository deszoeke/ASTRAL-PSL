function [varargout] = nanmax1(varargin)
%nanmax1 Maximum value, ignoring NaNs.
%   M = NANMAX1(A) returns the maximum of A with NaNs treated as missing. 
%   For vectors, M is the largest non-NaN element in A.  For matrices, M is
%   a row vector containing the maximum non-NaN element from each column.
%   For N-D arrays, nanmax1 operates along the first non-singleton
%   dimension.
%
%   [M,NDX] = NANMAX1(A) returns the indices of the maximum values in A.  If
%   the values along the first non-singleton dimension contain more than
%   one maximal element, the index of the first one is returned.
%  
%   M = NANMAX1(A,B) returns an array the same size as A and B with the
%   largest elements taken from A or B.  Either one can be a scalar.
%
%   [M,NDX] = NANMAX1(A,[],DIM) operates along the dimension DIM.
%
%   See also MAX, nanmin1, nanmean1, nanmedian1, nanmin1, nanvar1, nanstd1.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.12.2.3 $  $Date: 2004/06/25 18:52:54 $

% Call [m,ndx] = max(a,b) with as many inputs and outputs as needed
[varargout{1:nargout}] = max(varargin{:});
