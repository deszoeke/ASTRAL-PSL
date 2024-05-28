%%% program to concatenate .txt files of 1-min met_sea files or 10-min
%%% flux_met_sea files. 
%%% Elizabeth Thompson. Jan 2020. elizabeth.thompson@noaa.gov
%%% NOAA ESRL PSD
%%% 
%%% search for lines with **** - alerts where user needs to set the path 
%%% where files live and decide whether to concatenate 1-min or 10-min 
%%% files, or both. Then program returns one long .txt file
%%% of all days for entire cruise data with the same fields as daily files.

clear all;
close all;

cruise = 'PISTON_2019';
ship = 'Sally_Ride';
save_version = 'v0';
in_version = 'v0';

% system specific path defs
sysType = computer;
username=char(java.lang.System.getProperty('user.name'));
if strncmp(sysType,'MACI64',7)     % set Mac paths
    data_drive = '/Users/eliz/DATA/';
    path_prog = fullfile(data_drive,cruise,ship,'scientific_analysis','programs');
elseif strncmp(sysType,'PCWIN64',7)  % set PSD DAC paths
    data_drive = 'D:\DATA\';
    path_prog = fullfile(data_drive,cruise,ship,'scientific_analysis','programs');
end
% matlab script path
restoredefaultpath
cd(fullfile(path_prog,'flux'));
addpath(genpath(fullfile(path_prog,'flux')));
rehash toolboxcache;

%%% **** decide whether you want to concatenate 1-min files or 10-min files,
%%% or both... comment out whichever is not desired
for file_type = [1 10]  % for both 1-min and 10-min data
%%% for 1: MANUALflux_eval or 2: run_motcorr
for program_type = [1]
    
    %%% decide which directory to look into for .mat files depending on
    %%% what data is being concatenated: 1-min or 10-min.
    if program_type == 1
        dir_str = [in_version '_1min'];
        pathin = ['/Users/eliz/DATA/' cruise '/' ship '/flux/Field_Processed/' dir_str '/'];
    elseif program_type == 2
        dir_str = [in_version '_10min'];
        pathin = ['/Users/eliz/DATA/' cruise '/' ship '/flux/Field_Processed/' dir_str '/'];
    end
%%% **** set your own paths for where you saved the daily files, and where
%%% you want all-cruise file to go. Right now, all-cruise data will go to
%%% same folder as daily data but have a different output name. 
path_final = ['/Users/eliz/DATA/' cruise '/' ship '/flux/Final/'];
pathout = pathin;

%%% Specify the output file name
if program_type == 1
    nameout = [cruise '_' sprintf('%i',file_type) 'min_met_sea_flux_data_' save_version '.txt'];
elseif program_type == 2
    nameout = [cruise '_' sprintf('%i',file_type) 'min_flux_met_sea_data_' save_version '.txt'];
end

% concatenate daily files into one whole-cruise file. Overwrite
% any pre-existing whole-cruise files.
filecat([pathin cruise '_1*min*_jd*.txt'],[pathout nameout],'Overwrite');
% filecat([pathin cruise '_' sprintf('%i',file_type) 'min*_jd*.txt'],[pathout nameout],'Overwrite');
% filecat([pathin cruise '_' sprintf('%i',file_type) 'min*_jd*.txt'],[path_final nameout],'Overwrite'); 
                                                % added star because of typo in file names saved

disp(['Saved entire ' sprintf('%i',file_type) '-min cruise data as: ' [pathout nameout]]);
% disp(['Saved entire ' sprintf('%i',file_type) '-min cruise data as: ' [path_final nameout]]);

end %%% for loop of program_type: either 1: MANUALflux_eval or 2: run_motcorr
end %%% for loop of file_type: either 1-min or 10-min files, or both