function [h]=m_scatter(long,lat,S,data)
%    M_Scatter(X,Y,S,C) displays colored circles at the locations specified by
%    the vectors X and Y (which must be the same size).
%
% LB 20/Dec/2007



[X,Y]=m_ll2xy(long,lat);  %Converts long,lat to X,Y coordinates
[h]=scatter(X,Y,S,data);
 set(h,'tag','m_scatter');

 
if nargout==0,
 clear  h
end;
