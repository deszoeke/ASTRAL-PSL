function [wspd,wdir] = uv_to_sd_met(u,v)
%{
    Computes speed and direction [from] wind components from u and v, in
    meteorological standard sign convention, not sonic anemometer way.
    Where v is defined as positive for wind blowing S-to-N
    and u is positive for wind blowing W-to-E.

    wspd   true wind direction
    wdir   true wind direction

    If spd/dir are in earth coordinates, u & v are true wind.
    If spd/dir are in ship coordinates, u & v are relative wind.

    dir format is the direction wind is coming FROM, 0-360 deg,
    meteorological convention

    June 2021, EJT
%}

%%%%%%%% WIND SPEED
wspd   = sqrt(u.^2 + v.^2);
wdir   = wspd*nan;

nt = length(wspd);

%%%%
for i = 1:nt

    %%%%%%%% WIND DIRECTION            
    beta = nan;

    alpha = atand(u(i)/v(i));

    if u(i) > 0 && v(i) > 0     %% SW wind to NE
          beta = 180+alpha;
    end

    if u(i) > 0 && v(i) < 0     %% NW wind to SE
        beta = 360+alpha;
    end

    if u(i) < 0 && v(i) < 0     %% NE wind to SW
        beta = 0+alpha;
    end

    if u(i) < 0 && v(i) > 0     %% SE wind to NW
        beta = 180+alpha;
    end

    wdir(i) = beta;
            
end