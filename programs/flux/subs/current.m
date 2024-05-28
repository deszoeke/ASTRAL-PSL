function [cspd,cdir] = current(odec,hed,sog,cog)
%{
    Computes current speed and direction from doppler speed
        log (odec) velocity, heading, sog, and cog.
    Speeds are all m/s.  Angles in degrees from N.
%}

% convert angles from compass to cartesian
[cogm,sogm] = compass_to_cart(cog,sog);
[hedm,odecm] = compass_to_cart(hed,odec);

% sog vector is sum of odec and current vectors
% so, current vector is sog vector minus odec vector
% so, reverse heading by 180 deg and sum odec & sog vectors

% components
odecx = odecm .* cos((hedm-180)*pi/180);
odecy = odecm .* sin((hedm-180)*pi/180);
sogx = sogm .* cos(cogm*pi/180);
sogy = sogm .* sin(cogm*pi/180);
% sum components
cspdx = odecx + sogx;
cspdy = odecy + sogy;
% compute mag and direction of sum
cspdm = sqrt(cspdx.^2 + cspdy.^2);
cdirm = atan2(cspdy,cspdx)*180/pi;
% convert cartesian angle to compass direction
[cdir,cspd] = cart_to_compass(cdirm,cspdm);

end