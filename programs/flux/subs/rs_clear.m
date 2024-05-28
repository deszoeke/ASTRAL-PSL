function rscl = rs_clear(jdy,Pmb,qa,lat,lon, k1, k2, oz)
%{
    Computes clear sky solar model from date/time, pressure, humidity & lat/lon

    jdy is array of decimal day-of-year at the start of averaging intervals
    lat and lon are decimal latitude (-90 to 90) and longitude (0-360 E)

   calls SolarRadiancex(), which calls solflux()
%}

% constants
min_set = mean(diff(jdy))/2*1440;  % 1/2 delta t of jdy in minutes
p = nanmean1(Pmb);  % mean pressure
% k1 = .03;           % aerosol optical depth, band 1
% k2 = .03;           % aerosol optical depth, band 2
% oz = 0.2;           % column ozone
qrat = 4.0;         % set ratio of column wat vap to surface value

watvap = qa/qrat;   % estimate total column water vapor
jdx = floor(jdy+min_set/2/60/24);   % julian day integer of each interval
tutc = (jdy+min_set/60/24-jdx)*24;  % bin centers decimal hour

[rscl,~,~,~,~] = SolarRadiance(lat,lon,jdx,tutc,watvap,p,k1,k2,oz);

end
