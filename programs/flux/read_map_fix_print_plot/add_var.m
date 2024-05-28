%%% program to add or change variables to .mat files of 1-min met_sea files
%%% or 10-min flux_met_sea files. 
%%% Elizabeth Thompson. Jan 2020. elizabeth.thompson@noaa.gov
%%% NOAA ESRL PSD

clear all;
close all;
warning ('off','MATLAB:MKDIR:DirectoryExists');

% cruise ID and paths
cruise = 'ASTRAL_2024';  % cruise name
cruise_str = 'ASTRA';  % cruise name without _
ship = 'Thompson';             % research vessel
plotit = true;                   % create plots and save to .png format
yyyy = '2024';


% system specific path defs
sysType = computer;
username=char(java.lang.System.getProperty('user.name'));
if strncmp(sysType,'MACI64',7)     % set Mac paths
    data_drive = '/Users/ethompson/DATA/';
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

%%% choose program type: 1: MANUALflux_eval or 2: run_motcorr
for program_type = [1]
    
    %------------------------------------------------------------------
        %% do something a little different for 1 or 10 min files
        for file_type = [10]

        %%% load both 1 min and 10 min files for MANUALflux_eval. 
        %%% nfiles should be same for both types of files.

        %%% choose file_type 1 or 10 (minute update interval)
        if file_type == 1 && program_type == 1
            path = ['/Users/ethompson/DATA/' cruise '/' ship '/flux/Processed/v0_1min/'];
        elseif file_type == 10 && program_type == 1
            path = ['/Users/ethompson/DATA/' cruise '/' ship '/flux/Processed/v0_10min/'];
        elseif file_type == 10 && program_type == 2
            path = ['/Users/ethompson/DATA/' cruise '/' ship '/flux/Processed/v3/'];
        end
        
%         path_v2 = ['/Users/ethompson/DATA/ATOMIC_2020/Brown/flux/Processed/' dir_str '/'];
%         mkdir(path_v2);

        mat_files = dir([path cruise '_' sprintf('%i',file_type) 'min*_jd*.mat']);
        nfiles = length(mat_files);
        
        %% for all the files of this type and program
        for i = 1:nfiles  % nfiles
            
            %% load each 1-min or 10-min file
            file = [char(mat_files(i).folder) '/' char(mat_files(i).name)];
            file_save = [path char(mat_files(i).name)];
            disp(['Loading file # ' sprintf('%i',i) '/' sprintf('%i',nfiles)  ': ' file]);
            load(file);
            
            %%% choose file_type 1 or 10 (minute update interval)
            if file_type == 1 && program_type == 1
%                 s = a1;

            %%% fix kt to m/s

%             a1.wspd_s  = a1.wspd_s./1.944;
%             a1.rspd_s  = a1.rspd_s./1.944;
%             a1.wspd2_s  = a1.wspd2_s./1.944;
%             a1.rspd2_s  = a1.rspd2_s./1.944;
%             a1.wspd3_s  = a1.wspd3_s./1.944;
%             a1.rspd3_s  = a1.rspd3_s./1.944;
%             
%             a1.u10_s = a1.u10_s./1.944;
%             a1.u10n_s = a1.u10n_s./1.944;
%             a1.u2_s = a1.u2_s./1.944;
%             a1.u2n_s = a1.u2n_s./1.944;
%             a1.un_s = a1.un_s./1.944;
% 
%             a1 = rmfield(a1,{'rUn2_s';'rUn3_s';'rUw2_s';'rUw3_s'});

            elseif file_type == 10 && program_type == 1
%                 s = a10;

            %%% fix kt to m/s
% 
%             a10.wspd_s  = a10.wspd_s*1.944;
%             a10.rspd_s  = a10.rspd_s*2*1.944;
%             a10.wspd2_s  = a10.wspd2_s*2*1.944;
%             a10.rspd2_s  = a10.rspd2_s*2*1.944;
%             a10.wspd3_s  = a10.wspd3_s*2*1.944;
%             a10.rspd3_s  = a10.rspd3_s*2*1.944;
% 
%             a10.u10_s = a10.u10_s*2*1.944;
%             a10.u10n_s = a10.u10n_s*2*1.944;
%             a10.u2_s = a10.u2_s*2*1.944;
%             a10.u2n_s = a10.u2n_s*2*1.944;
%             a10.un_s = a10.un_s*2*1.944;
% 
%             a10 = rmfield(a10,{'rUn2_s';'rUn3_s';'rUw2_s';'rUw3_s'});

            elseif file_type == 10 && program_type == 2
%                 s = c10;
            end
%    
%             the_jd = s.jd(1);
% 
%             fmet = fields(s);
%             field1 = zeros(1,length(fmet));

            % just make plots from evalflux

            path_prog = '/Users/ethompson/DATA/ASTRAL_2024/Thompson/Scientific_Analysis/programs';
            path_raw_images = '/Users/ethompson/DATA/ASTRAL_2024/Thompson/flux/Raw_Images';
        cd([path_prog '/flux/']);

        graphdevice = '-dpng'; % select graphic device
        graphformat = '.png';  % select graphics format
        the_jd = floor(a10.jd(1));
        [the_yr, the_mo, the_day, ~, ~, ~] = datevec(a10.t(1));
        [~, ~, ~, a10.hour, ~, ~] = datevec(a10.t);
        date_st = sprintf('%04i_%02i_%02i_%03i',the_yr,the_mo,the_day,the_jd);

        ppath_RW = fullfile(path_raw_images,'Relative_Wind',['Relative_Winds_' date_st graphformat]);
        ppath_TW = fullfile(path_raw_images,'True_Wind',['True_Winds_' date_st graphformat]);

        cruise = 'ASTRAL_2024';  % string for file names: acronym_year
        ptitle = 'ASTRAL 2024';  % string for plots
        cruise_str = 'ASTRAL';  % cruise acronym
        ship = 'Thompson';  % research vessel
        yr = str2double(cruise(end-3:end)); % numeric year
        yr_st = cruise(end-3:end); % year string
        


        figure; 
        subplot(2,1,1); hold on;
        plot(a10.jd, a10.rdir_s, 'ob',a10.jd, a10.rdir2_s, 'co', a10.jd, a10.rdir3_s, 'go',a10.jd, a10.rdir,'.r');grid;
        plot(...
            [the_jd the_jd+1],[60 60],'k:', ...
            [the_jd the_jd+1],[-60 -60],'k:', ...
            [the_jd the_jd+1],[90 90],'k-', ...
            [the_jd the_jd+1],[-90 -90],'k-');
        xlabel('Hour (UTC)'); ylabel('Relative Wind Direction (^o)'); axis([the_jd the_jd+1 -180 180]); 
        legend('ship mast','ship port','ship star','PSL','location','Northeastoutside'); grid on;
        title(sprintf('%s %04i-%02i-%02i DOY%03i  Relative Wind Direction',cruise_str,the_yr,the_mo,the_day,the_jd),'FontWeight','Bold','Interpreter','none');
        set(gca(gcf),'XTick',the_jd:2/24:the_jd+1); datetick('x','HH:MM','keepticks');
        xax = get(gca(gcf),'XTickLabel'); xax(end,:)='24:00'; set(gca(gcf),'XTickLabel',xax(:,1:2));
        
        subplot(2,1,2); hold on;
        plot(a10.jd, a10.rspd_s, '-b', a10.jd, a10.rspd2_s, 'c-', a10.jd, a10.rspd3_s, 'g-',a10.jd, a10.rspd, '-r');
        legend('ship mast','ship port','ship star','PSL','location','Northeastoutside'); grid;
        xlabel('Hour (UTC)'); ylabel('Relative Wind Speed (m/s)'); xlim([the_jd the_jd+1]);
        title(sprintf('%s %04i-%02i-%02i DOY%03i  Relative Wind Speed',cruise_str,the_yr,the_mo,the_day,the_jd),'FontWeight','Bold','Interpreter','none');
        set(gca(gcf),'XTick',the_jd:2/24:the_jd+1); datetick('x','HH:MM','keepticks');
        xax = get(gca(gcf),'XTickLabel'); xax(end,:)='24:00'; set(gca(gcf),'XTickLabel',xax(:,1:2));
        %         orient tall;
        annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL'},'FontSize',14,'FitBoxToText','off','LineStyle','none');
            print(graphdevice,ppath_RW);
        
        % TRUE WIND SPEED & DIRECTION 
        figure;
        subplot(2,1,1); hold on;
        plot(a10.jd, a10.wdir_s, 'bo',a10.jd, a10.wdir2_s, 'co', a10.jd, a10.wdir3_s, 'go',a10.jd, a10.wdir,'r.');
        xlabel('Hour (UTC)'); ylabel('Wind Direction (^o)'); axis([the_jd the_jd+1 -5 365]);
        legend('ship mast','ship port','ship star','PSL','location','Northeastoutside'); grid;
        title(sprintf('%s %04i-%02i-%02i DOY%03i  True Wind Direction',cruise_str,the_yr,the_mo,the_day,the_jd),'FontWeight','Bold','Interpreter','none');
        set(gca(gcf),'XTick',the_jd:2/24:the_jd+1); datetick('x','HH:MM','keepticks');
        set(gca(gcf),'YTick',0:45:360);
        xax = get(gca(gcf),'XTickLabel'); xax(end,:)='24:00'; set(gca(gcf),'XTickLabel',xax(:,1:2));
        
        subplot(2,1,2); hold on;
        plot(a10.jd, a10.wspd_s, 'b-',a10.jd, a10.wspd2_s, 'c-', a10.jd, a10.wspd3_s, 'g-',a10.jd, a10.wspd, 'r-'); 
        xlabel('Hour (UTC)'); ylabel('Wind Speed (m/s)'); xlim([the_jd the_jd+1]);
        legend('ship mast','ship port','ship star','PSL','location','Northeastoutside'); grid;
        title(sprintf('%s %04i-%02i-%02i DOY%03i  True Wind Speed',cruise_str,the_yr,the_mo,the_day,the_jd),'FontWeight','Bold','Interpreter','none');
        set(gca(gcf),'XTick',the_jd:2/24:the_jd+1); datetick('x','HH:MM','keepticks');
        xax = get(gca(gcf),'XTickLabel'); xax(end,:)='24:00'; set(gca(gcf),'XTickLabel',xax(:,1:2));
        %         orient tall;
        annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL'},'FontSize',14,'FitBoxToText','off','LineStyle','none');
            print(graphdevice,ppath_TW);


            %% other potential file actions
%             %% nan out bad snake data
%             if the_jd == 16
%                 out_for_mooring_1 = find(s.t > datenum(2020,1,16,14,0,0) & s.t < datenum(2020,1,16,20,0,0));
%                 s.Tsnk(out_for_mooring_1) = NaN;
%             end
%             if the_jd == 39
%                 pull_for_recovery = find(s.t >= datenum(2020,2,8,11,45,0) & s.t <= datenum(2020,2,8,12,30,0));
%                 s.Tsnk(pull_for_recovery) = NaN;
%             end
            
%             %% If adding a new field... remove readme so it gets added at end, reorder, and then add readme back in
%             x = s.readme;
%             s = rmfield(s,{'readme'});
%             s = orderfields(ff);
%             s.readme = x;  

save_files = 0;
if save_files == 1
            %% rename s to f or g depending on file type, save as same .mat file
            if file_type == 1 && program_type == 1
%                 f = s;
                save(file_save,'a1');
                disp(['saving a1: ' file_save]);
            elseif file_type == 10 && program_type == 1
%                 g = s;
                save(file_save,'a10');  
                disp(['saving a10: ' file_save]);
            elseif file_type == 10 && program_type == 2
%                 ff = s;
                save(file_save, 'b10');
                disp(['saving b10: ' file_save]);
            end
end
%             %% save as text file without the 1-D fields
%             allfields = fields(s);
%             ns = length(allfields);
%             %%% remove the 1D fields
%             fields_1D = allfields(field1 == 1);
%             s2 = rmfield(s,fields_1D);
%             %%% add in a human readable time array
%             [s2.year, s2.month, s2.day, s2.hour, s2.minute] = datevec(s.t);
%             s2 = orderfields(s2);
%             %%% save text file
%             fname = char(mat_files(i).name);
%             mat2txt(fname(1:end-4), 'n', path_v2 , s2);
%             %%% put entire structure into same ordered array with columns and rows
%             fields_s2 = fields(s2);
%             ns2 = length(fields_s2);


        end  %%% for all files

%         %%% num vars in each file
%         disp(['num vars in txt file: ' sprintf('%i',ns2)]);
%         disp(['num vars in mat file: ' sprintf('%i',ns)]);
%      
%         %% print header at end, just once per file type / program type
%         disp('this is the header for each file:');
%         nchars = length(s.t);
%         k = repmat('                    ',nchars,1);
%         for j = 1:ns2
%             k(j) = fprintf('%20s',char(fields_s2(j)));
%         end

        
        end % for both file types of 1 and 10 minutes
end % for both program types 1 (manual flux) and 2 (mot corr)