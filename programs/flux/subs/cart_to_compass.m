function [dir,spd] = cart_to_compass(theta,rho)
%{
    Converts a cartesian coordinate vector (math convention)
        to a geophysical (compass) vector, all in degrees.
    Vector is 'to' the direction indicated by the angle.
        (oceanographic convention)
%}

[x,y] = pol2cart(theta*pi/180,rho);
z = x + 1i.*y;  % complex phase angle
dir = 90 - angle(z)*180/pi;
dir = mod(dir,360);
spd = rho;

end
