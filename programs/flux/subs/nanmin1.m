function [varargout] = nanmin1(varargin)
%nanmin1 Minimum value, ignoring NaNs.
%   M = NANMIN1(A) returns the minimum of A with NaNs treated as missing. 
%   For vectors, M is the smallest non-NaN element in A.  For matrices, M
%   is a row vector containing the minimum non-NaN element from each
%   column.  For N-D arrays, NANMIN1 operates along the first non-singleton
%   dimension.
%
%   [M,NDX] = NANMIN1(A) returns the indices of the minimum values in A.  If
%   the values along the first non-singleton dimension contain more than
%   one minimal element, the index of the first one is returned.
%  
%   M = NANMIN1(A,B) returns an array the same size as A and B with the
%   smallest elements taken from A or B.  Either one can be a scalar.
%
%   [M,NDX] = NANMIN1(A,[],DIM) operates along the dimension DIM.
%
%   See also MIN, nanmax1, nanmean1, nanmedian1, nanvar1, nanstd1.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.12.2.5 $  $Date: 2004/07/28 04:38:42 $

% Call [m,ndx] = min(a,b) with as many inputs and outputs as needed
[varargout{1:nargout}] = min(varargin{:});
