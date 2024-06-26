%%% program to concatenate .mat files of 1-min files or 10-min files. 
%%% ethompsonabeth Thompson. Jan 2020. ethompsonabeth.thompson@noaa.gov NOAA PSL
%%% 
%%% search for lines with **** - alerts where user needs to set the path 
%%% where files live and decide whether to concatenate 1-min or 10-min 
%%% files, or both. Then program returns 1 and/or 10 min data structures 
%%% of all days for entire cruise data with the same fields as daily files.

clear vars;
close all;


% **** set cruise info
cruise = 'ASTRAL_2024';
% ship = 'Thompson';
ship = 'PSL';


%%% choose system specific path defs... or define manually below instead
% [data_drive, path_prog, ship] = setpaths(); % system specific paths as
% below...
sysType = computer;
username=char(java.lang.System.getProperty('user.name'));
if strcmp(username,'deszoeks')
    data_drive = '/Users/deszoeks/Data/';
    path_prog = fullfile('/Users/deszoeks/Projects/ASTRAL/PSL/programs');  
elseif strncmp(sysType,'MACI64',7)     % set Mac paths
    data_drive = '/Users/ethompson/DATA/';
    path_prog = fullfile(data_drive,cruise,ship,'Scientific_analysis','programs');
elseif strncmp(sysType,'PCWIN64',7)  % set PSD DAC paths
    data_drive = 'D:\DATA\';
    path_prog = fullfile(data_drive,cruise,ship,'Scientific_analysis','programs');
end



%%% **** decide whether you want to concatenate 1-min files or 10-min files,
%%% or both... comment out whichever is not desired
for file_type = [1 10]  % for both 1-min and 10-min data
for program_type = 2 % for 1: evalflux or 2: run_motcorr
    
    %%% %%% decide which directory to look into for .mat files depending on
    %%% what data is being concatenated and which program made input files
    if program_type == 1
        
        save_version = 'v1'; % v1 for Jan 2022 tests
        in_version = 'v0';

        if file_type == 1
            dir_str = [in_version '_1min']; 
            thepath = [fullfile(data_drive,cruise,ship,'/flux/Processed/',dir_str), '/'];
        elseif file_type == 10
            dir_str = [in_version '_10min'];
            thepath = [fullfile(data_drive,cruise,ship,'/flux/Processed/',dir_str), '/'];
        end
        save_file_name_type = '';

        
    elseif program_type == 2
        
        save_version = 'v1'; 
       
        dir_str = 'motcorr';
        thepath = [fullfile(data_drive,cruise,ship,'/flux/Processed/',dir_str), '/'];
        save_file_name_type = [dir_str '_'];
    
    end
    
    mat_files = dir([thepath cruise '_' sprintf('%i',file_type) 'min*_jd*.mat']);
    nfiles = length(mat_files);
    outfile = [thepath cruise '_' sprintf('%i',file_type) 'min' '_'  save_file_name_type save_version '.mat'];
        
    clear y;

    for i = 1:nfiles
        clear x;

        %%% load each file
        if program_type == 2
            file = [char(mat_files(i).folder),'/',char(mat_files(i).name)];
            disp(['Loading file # ' sprintf('%i',i) '/' sprintf('%i',nfiles)  ': ' file]);
            load(file);
            
            if file_type == 1
                x = c1;
            elseif file_type == 10
                x = c10;
            end
        elseif program_type == 1
            if file_type == 1
                file_1 = [char(mat_files(i).folder),'/',char(mat_files(i).name)];
                disp(['Loading file # ' sprintf('%i',i) '/' sprintf('%i',nfiles)  ': ' file_1]);
                load(file_1);
%                 if isfield(a1,'pa_at_zt_s') == 1
%                     a1.cd = a1.Cd;
%                     a1.ch = a1.Ch;
%                     a1.ce = a1.Ce;
%                     a1.l = a1.L;
%                     a1.u2 = a1.U2;
%                     a1.un = a1.UN;
%                     a1.u10n = a1.U10N;
%                     a1.cdn10 = a1.CdN10;
%                     a1.chn10 = a1.ChN10;
%                     a1.cen10 = a1.CeN10;
%                     a1.ta10n = a1.ta10N;
%                     a1.ta10n = a1.qa10N;
%                     a1.edis = a1.Edis;
%                     a1.pa_at_zq_s = a1.pa_at_zt_s;
%                     a1 = rmfield(a1,{'pa_at_zt_s';'t_s_s';...
%                     'Cd';'Ch';'Ce';'L';'U2';'UN';'U10N';'CdN10';'ChN10';'CeN10';'ta10N';'qa10N';'Edis'});
%                     disp('removing/renaming old vars... a1');
%                     a1 = orderfields(a1);
%                 end
                x = a1;
            elseif file_type == 10
                file_10 = [char(mat_files(i).folder),'/',char(mat_files(i).name)];
                disp(['Loading file # ' sprintf('%i',i) '/' sprintf('%i',nfiles)  ': ' file_10]);
                load(file_10);          
                x = a10;
            end
        end


        %%% only grab field names once. they will be same for all files. 
        if i == 1
    %         disp('i = 1; grabbing first set of fields');
            the_fields = fields(x);

            %%% load all variables into new structure
            for j = 1:length(the_fields)
                %%% grab fields from small array and put in big array with
                %%% same field names
                y.(the_fields{j}) = x.(the_fields{j});
            end

        else %% for all other days
    %       disp('i > 1; grabbing all fields');
    %       disp('rest of variables');
            %%% grab and put rest of variables in big array
            for j = 1:length(the_fields)

                %%% CHECK: some fields might be readme or meta data, so will not have same
                %%% length as the long fields discretized by time. Don't
                %%% concatenate the metadata or readme fields. They've already
                %%% been added once in the first day. 

                % load each variable to check it's size
                var = y.(the_fields{j});

                % if size is long enough to be a time field, concatenate it
                % with the others into the big array. The alternative is to
                % rmfield(structure, 'var') for the known non-time discretized
                % fields before running this script. 
                if length(var) > 100
                   y.(the_fields{j}) = [y.(the_fields{j}); x.(the_fields{j})];
                end
            end
        end  

    end  %% array of all days

    % save the resulting cruise data structure. Make sure the new all-days cruise 
    % file won't be recognized by the string search at the beginning of this program
    % for daily files. The alternative could be to save new structure in a different folder by
    % providing a different path name at the beginning and/or end of this program.

    if file_type == 10
        if program_type == 1
            b10 = y; 
            save(outfile,'b10');
            disp(['saving b10 eval: ' outfile]);
        elseif program_type == 2
            d10 = y; 
            save(outfile,'d10');
            disp(['saving d10 motcorr: ' outfile]);
        end
    else
        if program_type == 1
            b1 = y; 
            save(outfile,'b1');
            disp(['saving b1 eval: ' outfile]);
        elseif program_type == 2
            d1 = y; 
            save(outfile,'d1');
            disp(['saving d1 motcorr: ' outfile]);
        end
    end

end %%% for loop of program_type: either 1: evalflux or 2: run_motcorr
end %%% for loop of file_type: either 1-min or 10-min files, or both