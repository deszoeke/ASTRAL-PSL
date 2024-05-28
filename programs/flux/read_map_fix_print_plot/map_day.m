function map_day(lon,lat,cruise_str,LatLonLim,t1,the_jd)
% Plots map of the ship track using the m_map package and
% gshhs high resolution coastline data
% Inputs:
%   lon,        longitude (dec degrees)
%   lat,        latitude (dec degrees)
%   cruise,     cruise code (string)
%   LatLonLim   Map limits (dec degrees)
%   ddd         Day-of-Year

[the_yr, the_mo, the_day, the_hr, the_min, the_sec] = datevec(t1);
disp(['map: ' cruise_str]);

width = (LatLonLim(2)-LatLonLim(1))*150;
height = (LatLonLim(4)-LatLonLim(3))*150;
maxh = max(width,height);
if maxh>700 && height>width
    width = width*700/height;
    height = 700;
elseif maxh>700 && width>height
    height = height*700/width;
    width = 700;
end

%from NGDC coastline extractor
figure('position',[300,300,width,height]);
title(sprintf('%s (%04i-%02i-%02i, DOY%03i).  Cruise Track ',cruise_str,the_yr,...
    the_mo,the_day,the_jd),'FontWeight','Bold','Interpreter','none')
m_proj('mercator','lon',[LatLonLim(1) LatLonLim(2)],'lat',[LatLonLim(3) LatLonLim(4)]);
m_grid('box','fancy','tickdir','in');
m_gshhs_i('patch',[.5 .5 .5]);

% m_line(lon,lat,'color','r','linestyle','-','linewidth',2,'marker','.','markersize',8,'markeredgecolor','k');
m_line(lon,lat,'color','r','linestyle','-','linewidth',2);
