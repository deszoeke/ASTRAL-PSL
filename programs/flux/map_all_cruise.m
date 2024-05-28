function map_all_cruise(lon, lat, ptitle, LatLonLim)
% function map_Xcruise2009(lon,lat,cruise,year,ship,LatLonLim)
% Makes a map of the ship track using the m_map package.
% Inputs: 
%   lon,        longitude (dec degrees)
%   lat,        latitude (dec degrees)
%   LatLonLim   Map limits (dec degrees)
%   leg         Leg number

%from NGDC coastline extractor
figure('position',[200,200,600,600]);
hold on;
title(['Cruise Track ' ptitle]);
m_proj('mercator','lon',[LatLonLim(1) LatLonLim(2)],'lat',[LatLonLim(3) LatLonLim(4)]);
m_grid('box','fancy','tickdir','in');
m_gshhs_f('patch',[.5 .5 .5]);

% m_line(lon,lat,'color','r','linestyle','-','linewidth',2,'marker','.','markersize',8,'markeredgecolor','k');
m_line(lon,lat,'color','r','linestyle','-','linewidth',2);
