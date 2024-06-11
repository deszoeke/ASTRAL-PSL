function [data_drive, path_prog, ship] = setpaths()
% EDIT PATHS HERE! 
% System and cruise-specific path defs set in one place.
% Dectect the machine, user and set paths.

sysType = computer;
username=char(java.lang.System.getProperty('user.name'));
if strcmp(username,'deszoeks')
    data_drive = '/Users/deszoeks/Data/';
    path_prog = fullfile('/Users/deszoeks/Projects/ASTRAL/PSL/programs'); 
    ship = 'PSL'; % optional output hack for Simon's path hierarchy
elseif strncmp(sysType,'MACI64',7)     % set Mac paths
    data_drive = '/Users/ethompson/DATA/';
    path_prog = fullfile(data_drive,cruise,ship,'Scientific_Analysis','programs');
elseif strncmp(sysType,'PCWIN64',7)  % set PSL DAC paths
    data_drive = 'D:\DATA\';
    path_prog = fullfile(data_drive,cruise,ship,'Scientific_Analysis','programs');
end

end