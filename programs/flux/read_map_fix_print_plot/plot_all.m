%%% program to plot .mat files of 1-min met_sea files or 10-min
%%% flux_met_sea files. 
%%% Elizabeth Thompson. Jan 2020. elizabeth.thompson@noaa.gov
%%% NOAA ESRL PSD
%%% 
%%% search for lines with **** - alerts where user needs to set the path 
%%% where files live and decide whether to concatenate 1-min or 10-min 
%%% files, or both. Then program returns c1 or c10, which are structures 
%%% of all days for entire cruise data with the same fields as daily files,
%%% plus the readme and meta data stored in each daily file.

clear all;
close all;

for plot_type = [2]
    
    %------------------------------------------------------------------
    if plot_type == 1
        %%% load both 1 min and 10 min files. nfiles should be same for
        %%% both types of files.
        path_raw_images = '/Users/eliz/DATA/PISTON_2019/Sally/flux/Raw_Images';
        dir_str1 = 'met_sea_1min_v0';
        dir_str10 = 'met_sea_10min_v0';
        path1 = ['/Users/eliz/DATA/PISTON_2019/Sally/flux/Field_Processed/' dir_str1 '/'];
        path10 = ['/Users/eliz/DATA/PISTON_2019/Sally/flux/Field_Processed/' dir_str10 '/'];
        mat_1_files = dir([path1 'PISTON_2019_1min*_jd*.mat']);
        nfiles_1 = length(mat_1_files);
        mat_10_files = dir([path10 'PISTON_2019_10min*_jd*.mat']);
        nfiles_10 = length(mat_10_files);

        for i = 6:6
%         for i = [(27:28)-8 (35:37)-8]  % days in port
%         for i = 1:nfiles_1
            %%% load each 1 min file
            file_1 = [char(mat_1_files(i).folder),'/',char(mat_1_files(i).name)];
            disp(['Loading file # ' sprintf('%i',i) '/' sprintf('%i',nfiles_1)  ': ' file_1]);
            load(file_1);
            %%% load each 10 min file
            file_10 = [char(mat_10_files(i).folder),'/',char(mat_10_files(i).name)];
            disp(['Loading file # ' sprintf('%i',i) '/' sprintf('%i',nfiles_10)  ': ' file_10]);
            load(file_10);            
            %%% make plots of 1 and 10 min data
            plot_MANUALflux_eval(f, g, path_raw_images);
        end 

    %----------------------------------------------------------------------
    elseif plot_type == 2
        %%% load 10 min files
        path_dailyPlots = '/Users/eliz/DATA/PISTON_2019/Sally_Ride/flux/Processed_Images/Daily_decorr';
        path = '/Users/eliz/DATA/PISTON_2019/Sally_Ride/flux/Processed/motcorr/';
        mat_10_files = dir([path 'PISTON_2019_10min*_jd*.mat']);
        nfiles = length(mat_10_files);
        % titles
        cruise = 'PISTON_2019';  % string for file names
        ptitle = 'PISTON 2019';  % string for file names
        cruise_str = 'PISTON';  % title string for plots (no underscore chr)
        % b10 = v1 corrected met sea flux nav data
        in_version = 'v1';
        indir = ['/Users/eliz/DATA/PISTON_2019/Sally_Ride/flux/Processed/' in_version '/'];
        infile_10 = [indir cruise '_10min_nav_met_sea_flux_' in_version '.mat'];
        load(infile_10);

        for i = 1:nfiles
%         for i = 20:20
%         for i = [(26:28)-8 (35:37)-8] % days in port
            %%% load each 10 min file
            file_10 = [char(mat_10_files(i).folder),'/',char(mat_10_files(i).name)];
            disp(['Loading file # ' sprintf('%i',i) '/' sprintf('%i',nfiles)  ': ' file_10]);
            load(file_10);            
            %%% make plots of 10 min data
            plot_motcorr(c10,b10,path_dailyPlots, cruise, cruise_str);
        end
    end
    
    %----------------------------------------------------------------------

end %%% for manualflux_eval or run_motcorr