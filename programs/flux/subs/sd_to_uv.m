function [Un,Uw] = sd_to_uv(spd,dir)
%{
    Computes Un and Uw wind components from speed and direction,
    where Un is defined as positive for wind blowing S-to-N and Uw is
    positive for wind blowing E-to-W.  This is a right-handed convention
    and is the normal format for sonic anemometer wind components in
    all NOAA/PSD flux scripts.

    Un   + south-to-north like the met convention "v"
    Uw   + east-to-west like the met convention "-u"

    If spd/dir are in earth coordinates, U/V is true wind.
    If spd/dir are in ship coordinates, U/V is relative wind.

    dir format is the direction wind is coming FROM, 0-360 deg.

    Jan 2016, BWB
%}

Un = spd .* cos((dir+180)*pi/180);
Uw = -spd .* sin((dir+180)*pi/180);

end