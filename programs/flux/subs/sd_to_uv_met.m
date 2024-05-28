function [u,v] = sd_to_uv_met(spd,dir)
%{
    Computes u and v wind components from speed and direction, in
    meteorological standard sign convention, not sonic anemometer way.
    Where v is defined as positive for wind blowing S-to-N
    and u is positive for wind blowing W-to-E.

    v   + south-to-north
    u   + west-to-east

    If spd/dir are in earth coordinates, u & v are true wind.
    If spd/dir are in ship coordinates, u & v are relative wind.

    dir format is the direction wind is coming FROM, 0-360 deg,
    meteorological convention

    Jan 2016, BWB
    June 2021, EJT
%}

v = spd .* cos((dir+180)*pi/180);
u = spd .* sin((dir+180)*pi/180);

end