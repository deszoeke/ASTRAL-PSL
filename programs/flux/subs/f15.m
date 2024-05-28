function [xd]=f15(x)
% function [xd]=deglitch(x,npts,nstd,side)
% x is the series to be deglitched
% npts - number of points to deglitch at a time 
%      - this shold be tuned the data
% nstd - number of std. dev. to remove outliers
% side - outliers will be removed only on positive 
%     (if side='+') or negative (if side='-')
%      side of the mean. If no side is defined, 
%      than outlier will be removed on both sides
% $Revision: 1.3 $  $Date: 2010/04/28 17:56:39 $
% Originally J. Moum

nx=length(x);
xd=x;

for i=16:nx-16
   istart = i-15;
   ifinish = i+15;
   iwindow = (istart:1:ifinish);
   xd(i) =nanmean1(x(iwindow));
end
%   if size(xd,1)~=size(x,1);xd=xd';end

