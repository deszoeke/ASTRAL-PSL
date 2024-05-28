function [spd2, dir3] = interval_avg_rvect(t, spd, dir, bin2)
% takes 0-360 deg direction, averages it to different time step
% for relative wind

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
dir3 = dir2;

% leave as is if you want 0-360 deg... or 

% % convert from +/- 180 to 0-360 
dir3 = mod((dir3)+360,360);
dir3(dir3>180) = dir3(dir3>180) - 360;

% % % convert from +/- 180 to 0-360
% dir3(dir3<0)=dir3(dir3<0)+360;