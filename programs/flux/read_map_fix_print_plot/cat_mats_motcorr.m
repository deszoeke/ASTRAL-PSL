%%% program to concatenate .mat files of 1-min and 10-min motcorr files
%%% Elizabeth Thompson. Jan 2020. elizabeth.thompson@noaa.gov
%%% NOAA PSL
%%% 
%%% search for lines with **** - alerts where user needs to set the path 
%%% where files live and decide whether to concatenate 1-min or 10-min 
%%% files, or both. Then program returns f1 or f10, which are structures 
%%% of all days for entire cruise data with the same fields as daily files,
%%% plus the readme and meta data stored in each daily file.

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
    path_prog = fullfile(data_drive,cruise,ship,'Scientific_analysis','programs');
elseif strncmp(sysType,'PCWIN64',7)  % set PSD DAC paths
    data_drive = 'D:\DATA\';
    path_prog = fullfile(data_drive,cruise,ship,'Scientific_analysis','programs');
end
% matlab script path
restoredefaultpath
cd(fullfile(path_prog,'flux'));
addpath(genpath(fullfile(path_prog,'flux')));
rehash toolboxcache;

%%% **** decide whether you want to concatenate 1-min files or 10-min files,
%%% or both... comment out whichever is not desired
for file_type = [1 10]  % for both 1-min and 10-min data
for program_type = [1] % for 1: MANUALflux_eval or 2: run_motcorr
    
% for file_type = 1  % for 1-min data
% for file_type = 10 % for 10-min data

    %%% %%% decide which directory to look into for .mat files depending on
    %%% what data is being concatenated: 1-min or 10-min.
    if program_type == 1
        dir_str_1 = [in_version '_1min'];
        dir_str_10 = [in_version '_10min'];
        path_1 = ['/Users/eliz/DATA/' cruise '/' ship '/flux/Field_Processed/' dir_str_1 '/'];
        path_10 = ['/Users/eliz/DATA/' cruise '/' ship '/flux/Field_Processed/' dir_str_10 '/'];
        mat_files_1 = dir([path_1 cruise '_1min*_jd*.mat']);
        mat_files_10 = dir([path_10 cruise '_10min*_jd*.mat']);
        nfiles_1 = length(mat_files_1);
        nfiles_10 = length(mat_files_10); 
        nfiles = nfiles_1;
    elseif program_type == 2
        dir_str = ['flux_met_sea_10min' in_version];
        thepath = ['/Users/eliz/DATA/' cruise '/' ship '/flux/Field_Processed/' dir_str '/'];
        mat_files = dir([thepath cruise '_' sprintf('%i',file_type) 'min*_jd*.mat']);
        nfiles = length(mat_files);
    end

%%% **** set your own paths for where you saved the daily files
%%% save a copy of concatenated data to Final directory
warning ('off','MATLAB:MKDIR:DirectoryExists');
path_final = ['/Users/eliz/DATA/' cruise '/' ship '/flux/Final/'];
mkdir(path_final);

%%% look for all daily .mat files in directory - those with "jd" listed
%%% (julian date)
%%% count the files
for i = 1:nfiles
    
    %%% load each file
    if program_type == 2
        file = [char(mat_files(i).folder),'/',char(mat_files(i).name)];
        disp(['Loading file # ' sprintf('%i',i) '/' sprintf('%i',nfiles)  ': ' file]);
        load(file);
    elseif program_type == 1
        if file_type == 1
            file_1 = [char(mat_files_1(i).folder),'/',char(mat_files_1(i).name)];
            disp(['Loading file # ' sprintf('%i',i) '/' sprintf('%i',nfiles_1)  ': ' file_1]);
            load(file_1);
            if isfield(f, 'year') == 0
                [f.year, f.month, f.day, f.hour, f.minute] = datevec(f.t);
                f = orderfields(f);
            end
        elseif file_type == 10
            file_10 = [char(mat_files_10(i).folder),'/',char(mat_files_10(i).name)];
            disp(['Loading file # ' sprintf('%i',i) '/' sprintf('%i',nfiles_10)  ': ' file_10]);
            load(file_10);
            if isfield(g, 'year') == 0
                [g.year, g.month, g.day, g.hour, g.minute] = datevec(g.t);
                g = orderfields(g);
            end
        end
    end

    
    %%% only grab field names once. they will be same for all files. 
    if i ==1
%       disp('first file');
        if file_type == 10 
            if program_type == 2
                the_fields = fields(ff);%%% the structure name of the 10-min flux_met_sea files is called ff
            elseif program_type ==1
                the_fields = fields(g);%%% the structure name of the 10-min flux_met_sea files is called g
            end
        elseif file_type == 1
            the_fields = fields(f);%%% the structure name of the 1-min met_sea files is called f
        end
        
        %%% load all variables into new structure: f1 for 1-min cruise
        %%% data, f10 for 10-min cruise data.
        for j = 1:length(the_fields)
                %%% grab fields from small array and put in big array with
                %%% same field names
                if file_type == 10
                    if program_type == 2
                        f10.(the_fields{j}) = ff.(the_fields{j});
                    elseif program_type == 1
                        f10.(the_fields{j}) = g.(the_fields{j});
                    end
                elseif file_type == 1
                    f1.(the_fields{j}) = f.(the_fields{j});
                end
        end
    else %% for all other days
%       disp('rest of variables');
        %%% grab and put rest of variables in big array
        for j = 1:length(the_fields)
            
            %%% CHECK: some fields might be readme or meta data, so will not have same
            %%% length as the long fields discretized by time. Don't
            %%% concatenate the metadata or readme fields. They've already
            %%% been added once in the first day. 
            
            % load each variable to check it's size
            if file_type == 10
                if program_type == 2
                    x = ff.(the_fields{j});
                elseif program_type == 1
                    x = g.(the_fields{j});
                end
            elseif file_type == 1
                x = f.(the_fields{j});
            end
           
            % if size is long enough to be a time field, concatenate it
            % with the others into the big array. The alternative is to
            % rmfield(structure, 'var') for the known non-time discretized
            % fields before running this script. 
            if length(x) > 100
                if file_type == 10
                    if program_type == 2
                        f10.(the_fields{j}) = [f10.(the_fields{j}); ff.(the_fields{j})];
                    elseif program_type == 1
                        f10.(the_fields{j}) = [f10.(the_fields{j}); g.(the_fields{j})];
                    end
                elseif file_type == 1
                    f1.(the_fields{j}) = [f1.(the_fields{j}); f.(the_fields{j})];
                end
            end
        end
    end  

end  %% array of all days

% save the resulting cruise data structure. Make sure the new all-days cruise 
% file won't be recognized by the string search at the beginning of this program
% for daily files. The alternative is to save new structure in a different folder by
% providing a different path name at the beginning and/or end of this program.
    
    if file_type == 10
        if program_type == 2
            %%% 10-min data have a 'cruise_str' field = 'ATOMIC' used for this
            %%% sort of naming procedure and plotting
            cruise_str = [f10.cruise_str '_' datestr(f10.t(1),'yyyy')];
            fname_10 = [thepath cruise_str '_10min_met_sea_flux_data_' save_version '.mat'];
            fname_10_final = [path_final cruise_str '_10min_met_sea_flux_data_' save_version '.mat'];
            save(fname_10,'f10'); 
            save(fname_10_final,'f10'); 
            disp(['Saved entire 10-min cruise data as: ' fname_10]);
            disp(['Saved entire 10-min cruise data as: ' fname_10_final]);
        elseif program_type == 1
            %%% 10-min data have a 'cruise_str' field = 'ATOMIC' used for this
            %%% sort of naming procedure and plotting
            cruise_str = [f10.cruise_str '_' datestr(f10.t(1),'yyyy')];
            gname_10 = [path_10 cruise_str '_10min_met_sea_flux_data_' save_version '.mat'];
            gname_10_final = [path_final cruise_str '_10min_met_sea_flux_data_' save_version '.mat'];
            save(gname_10,'f10'); 
            save(gname_10_final,'f10'); 
            disp(['Saved entire 10-min cruise data as: ' gname_10]);
            disp(['Saved entire 10-min cruise data as: ' gname_10_final]);
        end
    elseif file_type == 1
        %%% 10-min data have a 'cruise_str' field = 'ATOMIC' used for this
        %%% sort of naming procedure and plotting
        cruise_str = [f1.cruise_str '_' datestr(f1.t(1),'yyyy')];
        fname_1 = [path_1 cruise_str '_1min_met_sea_flux_data_' save_version '.mat'];
        fname_1_final = [path_final cruise_str '_1min_met_sea_flux_data_' save_version '.mat'];
        save(fname_1,'f1'); 
        save(fname_1_final,'f1'); 
        disp(['Saved entire 1-min cruise data as: ' fname_1]);
        disp(['Saved entire 1-min cruise data as: ' fname_1_final]);
    end
    
end %%% for loop of program_type: either 1: MANUALflux_eval or 2: run_motcorr
end %%% for loop of file_type: either 1-min or 10-min files, or both