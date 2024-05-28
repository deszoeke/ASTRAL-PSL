function uvw_rot = azm_rot(uvw,azm,ccw)
% single rotation of u and v wind vectors about w axis.
% azm is the angle in radians.
% ccw is a boolean specifying counter-clockwise rotation if True (1) or
% clockwise if False (0).  ccw is the mathematical convention for angles.
% cw is the meteorological convention for wind direction.

u = uvw(:,1);
v = uvw(:,2);
w = uvw(:,3);

if ccw
    Urot =  u*cos(azm) - v*sin(azm);
    Vrot =  u*sin(azm) + v*cos(azm);
else
    Urot =  u*cos(azm) + v*sin(azm);
    Vrot = -u*sin(azm) + v*cos(azm);
end;

uvw_rot = [Urot,Vrot,w];
