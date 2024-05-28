function [theta,rho] = compass_to_cart(dir,spd)
%{
    Converts a geophysical (compass) vector like spd/dir to
        cartesian (math convention) angle, all in degrees.
    Vector is 'to' the direction indicated by the angle.
        (oceanographic convention)
%}

z = spd.*exp(1i*((90-dir)*pi/180));
x = real(z);
y = imag(z);
[theta,rho] = cart2pol(x,y);
theta = theta*180/pi;
theta = mod(theta,360);

end
