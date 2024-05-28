function [cspd,cdir] = uv_to_sd_ocean(u,v)
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
cspd   = sqrt(u.^2 + v.^2);
cdir   = cspd*nan;

nt = length(cspd);

%%%%
for i = 1:nt

    %%%%%%%% WIND DIRECTION            

    if u(i) > 0 && v(i) > 0     %% to NE
        cdir(i) = atand(abs(u(i)./v(i)));
    end

    if u(i) > 0 && v(i) < 0     %% to SE
        cdir(i) = 90+ atand(abs(v(i)./u(i)));
    end

    if u(i) < 0 && v(i) < 0     %% to SW
        cdir(i) = 180+ atand(abs(u(i)./v(i)));
    end

    if u(i) < 0 && v(i) > 0     %% to NW
        cdir(i) = 270+ atand(abs(v(i)./u(i)));
    end
            
end