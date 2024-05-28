function [spd,dir,Un,Uw] = uv_rel_to_sd_true(rU,rV,hed,cog,sog)
%{
    Computes true wind speed and direction, and Un, Uw components
    from ship-relative wind components rU and rV, where U 
    is defined as positive for wind blowing
    toward the bow and V is positive for wind blowing toward port.
    This is a right-handed convention and is the normal format for sonic
    anemometer wind components in all NOAA/PSD flux scripts.

    EJT interpretation: 
    
    rV positive from starboard to port
    rU positive from stern to bow 
    Un   + south-to-north like the met convention "v"
    Uw   + east-to-west like the met convention "-u"

    Ship heading (0-360 deg true) and speed/course are used to compute
    the true wind.

    dir format is the direction wind is coming FROM, 0-360 deg.

    True wind components in the earth frame, Un/Uw, are also returned.

    Jan 2016, BWB
%}

% pol2cart follows left-handed convention so components are N/E!
[hed_n, hed_e] = pol2cart(hed*pi/180, 1);   % N/E heading components
[sog_n, sog_e] = pol2cart(cog*pi/180, sog); % N/E ship speed components

% true wind components in earth frame: do CCW rotation & sum with ship speed
Un = rU.*hed_n + rV.*hed_e + sog_n;   % Un is positive to North
Uw = -rU.*hed_e + rV.*hed_n - sog_e;	% Uw is positive when to the West; use minus sog_e since sog_e is positive to East!

[spd,dir] = uv_to_sd(Un,Uw);

end
