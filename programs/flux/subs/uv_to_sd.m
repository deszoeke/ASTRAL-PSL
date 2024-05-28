function [spd,dir] = uv_to_sd(rU,rV)
%{
    Computes wind speed and direction from wind components rU and rV,
    where rU is defined as positive for wind blowing S-to-N and rV is
    positive for wind blowing E-to-W.  This is a right-handed convention
    and is the normal format for sonic anemometer wind components in
    all NOAA/PSD flux scripts.

    EJT interpretation: 
    
    rV positive from starboard to port
    rU positive from stern to bow 
    Un   + south-to-north like the met convention "v"
    Uw   + east-to-west like the met convention "-u"

    If rU,rV are true (earth) coordinates, spd/dir is true wind.
    If rU,rV are in ship coordinates (raw sonic wind), spd/dir is relative wind.

    dir format is the direction wind is coming FROM, 0-360 deg.

    Jan 2016, BWB
%}

spd = sqrt(rU.^2 + rV.^2);
dir = atan2(-rV, rU)*180/pi + 180;

end
