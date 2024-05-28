function [U_sfc,dir_sfc] = wind_current_adjust(wspd,wdir,cspd,cdir)
%{
    Adjusts wspd/wdir for ocean surface current.
    Result is wind speed and direction with respect to
        ocean surface.
    Speeds are m/s, angles are degrees from N in compass coords
    cspd is 'to' cdir - oceanographic convention
%}

CN = -cspd.*cos(cdir*pi/180);  % current 'from' North (meteorological convention)
CE = -cspd.*sin(cdir*pi/180);  % current 'from' East

% compute U and dir relative to water
UN = wspd.*cos(wdir*pi/180);   % U 'from' North
UE = wspd.*sin(wdir*pi/180);   % U 'from' East

% Wind speed (m/s) relative to water
U_sfc = sqrt((UN-CN).^2+(UE-CE).^2);
% Wind direction 'from' relative to water
dir_sfc  = mod(atan2((UE-CE),(UN-CN))*180/pi+360,360);

end
