function [dir2] = interval_avg_dir(t,dir,bin2)
% takes 0-360 deg direction, averages it to different time step

d2r = pi/180;               % angle conversion constants
r2d = 180/pi;               % angle conversion constants

% unwrap to radians
dir_unwrap = dir; 
dir_unwrap(dir_unwrap<0) = dir_unwrap(dir_unwrap<0) + 360;
dir_unwrap = unwrap(dir_unwrap*d2r);

% bin average
dir2 = interval_avg_var(t,dir_unwrap, bin2);

% wrap back to 0-360 degrees
dir2 = mod((dir2*r2d)+360,360);
dir2(dir2>180) = dir2(dir2>180) - 360;
