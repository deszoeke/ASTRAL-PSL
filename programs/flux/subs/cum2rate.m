function [prate_mm_hr]=cum2rate(x, t)
% function [xd]=cum2rate(x)
% function converts cumulative precipitation in mm to precipitation rate in mm/hr
% time array should be in matlab time or the equivalent jd fractions.
% EJT Sep 2019 

hr1 = datenum(2019,8,27,1,0,0) - datenum(2019,8,27,0,0,0);

dcum = diff(x);
% the cumulative precip array will periodically start over at zero if it
% reaches a max number. Just ignore this entry. 
dcum(dcum<0.1) = 0;
dt = diff(t);
the_dt = median(dt);
% check it - datestr(the_dt, 0);

%%% add a 2nd diff value to the beginning of cum array to account for the diff
%%% function ignoring the first value, and thereby shortening the array
dcum_full = [dcum(1) dcum];
    
% how many of these time steps are in 1 hr? % use ceiling to round / account for
% rounding errors.
num_samples_per_hr = ceil(hr1/the_dt);

% mm that would have fallen if instantaneous accumulation had lasted 1 hr
prate_mm_hr = dcum_full*num_samples_per_hr;

%==========================================================================
%%% Testing:
% % a) create array that accumulates to 1 mm after 1 hour
% %       time spacing is in seconds, so there are 3600 data points. Prate =
% %       an array of values all equal to 1 mm/hr.
% % b) create a second array that just has one instance of 1 mm accumulation
% %       over a single second. Prate = 3600 mm/hr 
% cum_a = linspace(0,1,3600);
% cum_b = zeros(1,3600); 
% cum_b(20) = 1;
% 
% % create time array that spans 1 hour with 1 sec spacing. 
% t = linspace(0, hr1, 3600);