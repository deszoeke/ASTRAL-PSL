function [rspd,rdir,rU,rV] = sd_true_to_uv_rel(spd,dir,hed,cog,sog)
%{
    Computes rU and rV, relative wind speed and direction from true spd/dir and
    ship cog/sog/heading.  rU is defined as positive for wind blowing
    toward the bow and rV is positive for wind blowing toward port.
    This is a right-handed convention and is the normal format for sonic
    anemometer wind components in all NOAA/PSD flux scripts.

    EJT interpretation: 
    
    rV positive from starboard to port
    rU positive from stern to bow 
    Un   + south-to-north like the met convention "v"
    Uw   + east-to-west like the met convention "-u"

    rwdir format is the direction wind is coming FROM, 0-360 deg.

    Relative wind components are in the ship frame (rU/rV), as
    for raw sonic anemometer wind speeds.

    Jan 2016, BWB
%}

[Un,Uw] = sd_to_uv(spd,dir);  % compute true wind N/W components

% pol2cart follows left-handed convention so components are N/E!
[hed_n, hed_e] = pol2cart(-hed*pi/180, 1);	% negate hed angle for CW rotation!
[sog_n, sog_e] = pol2cart(cog*pi/180, sog); % N/E ship speed components

% compute rel wind comps in earth frame
Un_rel = Un - sog_n;
Uw_rel = Uw + sog_e;

% rotate components CW into ship frame
rU = Un_rel.*hed_n + Uw_rel.*hed_e;     
rV = -Un_rel.*hed_e + Uw_rel.*hed_n;

% compute relative winds
rdir = atan2(-rV, rU)*180/pi + 180;
rspd = sqrt(rU.^2 + rV.^2);

end