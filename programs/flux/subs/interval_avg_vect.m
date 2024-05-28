function [spd2, dir2] = interval_avg_vect(t, spd, dir, bin2)
% takes 0-360 deg direction, averages it to different time step

% d2r = pi/180;               % angle conversion constants
% r2d = 180/pi;               % angle conversion constants

% compute components in weird units:
% S-to-N (U) and E-to-W (V)

u =  spd .* cos((dir+180)*pi/180);
v = -spd .* sin((dir+180)*pi/180);

% bin average components
U = interval_avg_var(t,u, bin2);
V = interval_avg_var(t,v, bin2);

% new speed
spd2 = sqrt(U.^2 + V.^2); 

% new dir, and wrap back to 0-360 degrees
dir2 = atan2(-V, U)*180/pi + 180;
