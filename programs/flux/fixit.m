% fixes applied after evalflux.m and cat_mats.m, before run_motcorr.m and da_red.m
% EJT 2021

clear all;
close all;
setup_cruise; % set default conversion and calibration factors, and cruise specific names

% system specific path defs
sysType = computer;
username=char(java.lang.System.getProperty('user.name'));
if strncmp(sysType,'MACI64',7)     % set Mac paths
    data_drive = '/Users/ethompson/DATA/';
    path_prog = fullfile(data_drive,cruise,ship,'Scientific_Analysis','programs');
end

% matlab script path
restoredefaultpath
cd(fullfile(path_prog,'flux'));
addpath(genpath(fullfile(path_prog,'flux')));
% addpath('/Users/ethompson/Documents/MATLAB/');
rehash toolboxcache;

% make directory for plots of fixeswarning ('off','MATLAB:MKDIR:DirectoryExists');
path_fix_plots = fullfile(data_drive,cruise,ship,'flux','Raw_Images','fixes');
mkdir(path_fix_plots);

%% load concatenated cruise data
in_version = 'v1'; % v1 for Jan 2022 tests
out_version = 'v2'; % v2 for Jan 2022 tests

% v0 met sea flux nav data
indir_1 = [data_drive cruise '/' ship '/flux/Processed/v0_1min/'];
indir_10 = [data_drive cruise '/' ship '/flux/Processed/v0_10min/'];
outdir = [data_drive cruise '/' ship '/flux/Processed/' out_version '/'];
mkdir(outdir);

load([indir_1 cruise '_1min_' in_version '.mat']); %% structure b1
load([indir_10 cruise '_10min_' in_version '.mat']); %% structure b10

% load([data_drive cruise '/' ship '/uCTD/ASTRAL23_processeduCTD_surface.mat']);
% surface_uCTD ... time, datenum, lat, lon, T, S, p

%%% v1 files to be saved in this program
m_outfile_1 = [outdir cruise '_1min_nav_met_sea_flux_' out_version '.mat'];
m_outfile_10 = [outdir cruise '_10min_nav_met_sea_flux_' out_version '.mat'];

%%% adcp data from read_adcp.m in flux code directory 
% adir = '/Users/ethompson/DATA/ASTRAL_2023/Revelle/ship/adcp/';
% matname = 'piston-WH300_RV-Sally-Ride_20190904_R0.mat';
% load([adir matname]);
have_adcp_data = 0; % no adcp data yet
% adcp_data = 1 % we have adcp data now

%%% wamos data is about every 15 min
% wamos = load('/Users/ethompson/DATA/ASTRAL_2023/Revelle/ship/wave_RR2306.mat');

% %%% load other T/s data for QC
% o1 = load([data_drive cruise '/Otter/piston-SurfOtter_RV-Sally-Ride_20190907_R0.mat']);
% o2 = load([data_drive cruise '/Otter/piston-SurfOtter_RV-Sally-Ride_20190913_R0.mat']);
% o3 = load([data_drive cruise '/Otter/piston-SurfOtter_RV-Sally-Ride_20190921_R0.mat']);

%% snake out of the water times
snake_screen = 0;
if snake_screen == 1

    % June 14, 1850 local - deployed (1320 UTC)
    % June 20 0600 - recovered (a bit earlier perhaps... ya, more like 00 Z). 
    % June 20 1639 - deployed 
    % June 24, 1950 - recovered (it looks like it got recovered sooner than that actually)
    
    bad_snake1 = find(b1.t <= datenum(2023,6,14,18,50,0));
    bad_snake2 = find(b1.t > datenum(2023,6,20,0,0,0) & b1.t < datenum(2023,6,20,16,39,0));
    bad_snake3 = find(b1.t > datenum(2023,6,24,14,10,0));
    wh_bad_snake = [bad_snake1; bad_snake2; bad_snake3];
    good_snake_ID = ones(length(b1.t),1);
    good_snake_ID(wh_bad_snake) = 0;
    wh_good_snake = find(good_snake_ID == 1);
    
    bad_snake1_10 = find(b10.t <= datenum(2023,6,14,18,50,0));
    bad_snake2_10 = find(b10.t > datenum(2023,6,20,0,0,0) & b10.t < datenum(2023,6,20,16,39,0));
    bad_snake3_10 = find(b10.t > datenum(2023,6,24,14,10,0));
    wh_bad_snake_10 = [bad_snake1_10; bad_snake2_10; bad_snake3_10];
    good_snake_ID_10 = ones(length(b10.t),1);
    good_snake_ID_10(wh_bad_snake_10) = 0;
    wh_good_snake_10 = find(good_snake_ID_10 == 1);

end
%% what's up with all the TSG and snake data?!
plot_tsgs = 1;
if plot_tsgs == 1
    %%% I think this is the time when tsg data should be nan'ed before/after
%     tsgtime = [datenum(2023,6,10,18,00,00) datenum(2023,6,24,12,00,0)];
    
    figure;
    subplot(2,1,1);
    plot(b1.t, b1.tsea_s, b1.t, b1.tsea_in_s, b1.t, b1.tsnk);
%     hold on; plot(b1.t(wh_bad_snake), b1.tsnk(wh_bad_snake),'sr');
%     plot(surface_uCTD.datenum, surface_uCTD.T,'-k');
%     plot([min(tsgtime) min(tsgtime)],ylim,'-y');
%     plot([max(tsgtime) max(tsgtime)],ylim,'-y');
    % hold on; plot(b1.t, b1.tsea3_s,'--', b1.t, b1.tsea4_s,'--');
    legend('TSG','TSG intake','snake','location','south','orientation','horizontal');
    grid on;
    xlim([min(b1.t) max(b1.t)]);
    datetick('x','DD','keeplimits');
    ylabel('T ^oC')
    title('ASTRAL 2023 raw seawater T, S');
    
    subplot(2,1,2);
    plot(b1.t, b1.ssea_s);
%     hold on; plot([min(tsgtime) min(tsgtime)],ylim,'-y');
%     plot([max(tsgtime) max(tsgtime)],ylim,'-y');
%     plot(surface_uCTD.datenum, surface_uCTD.S,'-k');
    % hold on; plot(b1.t, b1.ssea3_s,'--', b1.t, b1.ssea4_s,'--');
    grid on;
    xlim([min(b1.t) max(b1.t)]);
    datetick('x','DD','keeplimits');
    ylabel('S psu');
    
%     subplot(3,1,3);
%     plot(b1.t, b1.flowsea1_s, b1.t, b1.flowsea2_s);
%     hold on; plot([min(tsgtime) min(tsgtime)],ylim,'-y');
%     hold on; plot([max(tsgtime) max(tsgtime)],ylim,'-y');
%     % hold on; plot(b1.t, b1.flowsea3_s,'--', b1.t, b1.flowsea4_s,'--');
%     grid on;
%     xlim([min(b1.t) max(b1.t)]);
%     ylabel('flow rate');
%     datetick('x','DD','keeplimits');

    print(graphdevice,[path_fix_plots '/tsg_snake_raw_' cruise graphformat]);

end

tsg_screen = 0;
if tsg_screen == 1

    % make the executive decision that TSG data before/after tsgtime is just
    % not trustworthy. 
    bad_tsg_1 = find(b1.t <= datenum(2023,6,10,18,0,0) | b1.t >= datenum(2023,6,24,12,0,0));
    bad_tsg_10 = find(b10.t <= datenum(2023,6,10,18,0,0) | b10.t >= datenum(2023,6,24,12,0,0));
    b1.tsea_s(bad_tsg_1) = nan;
    b1.tsea_in_s(bad_tsg_1) = nan;
    b1.ssea_s(bad_tsg_1) = nan;
%     b1.ssea_s(bad_tsg_1) = nan;
%     b1.csea1_s(bad_tsg_1) = nan;
%     b1.csea2_s(bad_tsg_1) = nan;
%     b1.flowsea1_s(bad_tsg_1) = nan;
%     b1.flowsea2_s(bad_tsg_1) = nan;
    b10.tsea_s(bad_tsg_10) = nan;
    b10.tsea_in_s(bad_tsg_10) = nan;
%     b10.ssea_s(bad_tsg_10) = nan;
%     b10.ssea_s(bad_tsg_10) = nan;
%     b10.csea1_s(bad_tsg_10) = nan;
%     b10.csea2_s(bad_tsg_10) = nan;
%     b10.sigt1_s(bad_tsg_10) = nan;
%     b10.sigt2_s(bad_tsg_10) = nan;
%     b10.flowsea1_s(bad_tsg_10) = nan;
%     b10.flowsea2_s(bad_tsg_10) = nan;
    
%     % remove these 3rd and 4th TSG values because they are just repeats of 1 and 2
%     b10 = rmfield(b10,{'flowsea3_s';'flowsea4_s';'tsea3_s';'tsea4_s';'ssea3_s';'ssea4_s';'csea3_s';'csea4_s';'sigt3_s';'sigt4_s'});
%     b1 = rmfield(b1,{'flowsea3_s';'flowsea4_s';'tsea3_s';'tsea4_s';'ssea3_s';'ssea4_s';'csea3_s';'csea4_s';'sigt3_s';'sigt4_s'});
% 
    if plot_tsgs == 1
        figure; 
        plot(b1.t, b1.tsnk, surface_uCTD.datenum, surface_uCTD.T, b1.t, b1.tsea_in_s);
        legend('snake 0.05 m','uCTD 4 m','TSG 5 m');
        grid on;
        ylabel('T^oC')
        xlim([min(b1.t) max(b1.t)]);
        datetick('x','DD','keeplimits');
        title('raw seawater T');
        print(graphdevice,[path_fix_plots '/TSG_T_raw_timeseries_' cruise graphformat]);
    end

    snake_no_deck = b1.tsnk;
    snake_no_deck(wh_bad_snake) = nan;
    b1.tsnk = snake_no_deck;
    
    snake_no_deck_10 = b10.tsnk;
    snake_no_deck_10(wh_bad_snake_10) = nan;
    b10.tsnk = snake_no_deck_10;

    if plot_tsgs == 1
        hold on;
        plot(b1.t, b1.tsnk,'-m');
        legend('snake 0.05 m','uCTD 4 m','TSG 5 m','snake in water');
        title('better seawater T');
        print(graphdevice,[path_fix_plots '/TSG_T_better_timeseries_' cruise graphformat]);
    end
    
    if plot_tsgs == 1
        figure;
        subplot(3,1,1);
        plot(b1.t, b1.tsea_s, b1.t, b1.tsea_in_s, b1.t, b1.tsnk,'-');
        hold on; plot(surface_uCTD.datenum, surface_uCTD.T,'-k');
    %     hold on; plot(b1.t, snake_no_deck,'-');
    %     hold on; plot([min(tsgtime) min(tsgtime)],ylim,'-y');
    %     hold on; plot([max(tsgtime) max(tsgtime)],ylim,'-y');
        % hold on; plot(b1.t, b1.tsea3_s,'--', b1.t, b1.tsea4_s,'--');
        grid on;
        xlim([min(b1.t) max(b1.t)]);
        datetick('x','DD','keeplimits');
        ylabel('T ^oC')
        title('ASTRAL 2023 good/better subset of seawater T, S, flowrate');
        legend('TSG 1','TSG 2','snake','uCTD 4 m','location','south','orientation','horizontal');
    
        subplot(3,1,2);
        plot(b1.t, b1.ssea_s, b1.t, b1.ssea_s);
        hold on;
        plot(surface_uCTD.datenum, surface_uCTD.S,'-k');
    %     hold on; plot([min(tsgtime) min(tsgtime)],ylim,'-y');
    %     hold on; plot([max(tsgtime) max(tsgtime)],ylim,'-y');
        % hold on; plot(b1.t, b1.ssea3_s,'--', b1.t, b1.ssea4_s,'--');
        grid on;
        xlim([min(b1.t) max(b1.t)]);
        datetick('x','DD','keeplimits');
        ylabel('S psu');
        subplot(3,1,3);
        plot(b1.t, b1.flowsea1_s, b1.t, b1.flowsea2_s);
    %     hold on; plot([min(tsgtime) min(tsgtime)],ylim,'-y');
    %     hold on; plot([max(tsgtime) max(tsgtime)],ylim,'-y');
        % hold on; plot(b1.t, b1.flowsea3_s,'--', b1.t, b1.flowsea4_s,'--');
        grid on;
        xlim([min(b1.t) max(b1.t)]);
        ylabel('flow rate');
        datetick('x','DD','keeplimits');
        print(graphdevice,[path_fix_plots '/tsg_snake_good_' cruise graphformat]);
    end

end

%% EEZ: NaN the data while in EEZ
remove_eez = 0;
if remove_eez == 1

% Janet says that TSGs weren't turned on until the ship was outside the EEZ
% anyway, so the data start time is equivalent to the EEZ. on top of that,
% Devmi says: All data stopped on June 25 11:30am local time 
% EEZ Exit: 10 June around 1600 UTC
% EEZ Entry: 24 June around 1800 UTC

% %%% good looking data within sampling area
% EEZ = find(b1.t < datenum(2023,6,10,18,0,0) | b1.t >= datenum(2023,6,24,12,0,0));
% EEZ_10 = find(b10.t < datenum(2023,6,10,18,0,0) | b10.t >= datenum(2023,6,24,12,0,0));

EEZ = find(b1.t < datenum(2023,6,9,12,0,0) | b1.t >= datenum(2023,6,25,0,0,0));
EEZ_10 = find(b10.t < datenum(2023,6,9,12,0,0) | b10.t >= datenum(2023,6,25,0,0,0));
fmet = fields(b1);

    for j = 1:length(fmet)
        x1 = b1.(fmet{j});
        x10 = b10.(fmet{j});
                x1(EEZ) = [];
                x10(EEZ_10) = [];
                b1.(fmet{j}) = x1;
                b10.(fmet{j}) = x10; 
    end
end

t0 = min(b10.t);
tN = max(b10.t);

%%% redo bad snake data for new time base
if snake_screen == 1
    bad_snake1_eez = find(b1.t <= datenum(2023,6,14,18,50,0));
    bad_snake2_eez = find(b1.t > datenum(2023,6,20,0,0,0) & b1.t < datenum(2023,6,20,16,39,0));
    bad_snake3_eez = find(b1.t > datenum(2023,6,24,14,10,0));
    wh_bad_snake_eez = [bad_snake1_eez; bad_snake2_eez; bad_snake3_eez];
    
    bad_snake1_eez_10 = find(b10.t <= datenum(2023,6,14,18,50,0));
    bad_snake2_eez_10 = find(b10.t > datenum(2023,6,20,0,0,0) & b10.t < datenum(2023,6,20,16,39,0));
    bad_snake3_eez_10 = find(b10.t > datenum(2023,6,24,14,10,0));
    wh_bad_snake_eez_10 = [bad_snake1_eez_10; bad_snake2_eez_10; bad_snake3_eez_10];
end

%% jd_10bin for averaging
jd_10bin = [b10.jd; b10.jd(end) + datenum(0,0,0,0,10,0)];
t_10bin = jd_10bin + datenum(2023,0,0,0,0,0);
jd_1bin = [b1.jd; b1.jd(end) + datenum(0,0,0,0,1,0)];
t_1bin = jd_1bin + datenum(2023,0,0,0,0,0);

%% rosr data
have_rosr_data = 1;
if have_rosr_data == 1
    %%% ROSR data
%     ncload2('/Users/ethompson/DATA/ASTRAL_2024/Thompson/ekamsat_rosr_sst_leg1.nc');
%     % assign all variables to matlab structures
%     clear rosr;
%     thestr = 'rosr';
%     ncload2('/Users/ethompson/DATA/ASTRAL_2024/Thompson/ekamsat_rosr_sst_leg1.nc');
%     finfo = ncinfo('/Users/ethompson/DATA/ASTRAL_2024/Thompson/ekamsat_rosr_sst_leg1.nc');
%     % % disp(finfo);
%     f_names = {finfo.Variables.Name};
%     nf = length(f_names);
%     for i = 1:nf
%         eval([ thestr '.' f_names{i} ' = ' f_names{i} ';']); % saves variables in structure $thestr.$var
%         eval(['clear ' f_names{i} ';']); % clears all the variables loaded automatically by ncload2
%     end
%     rosr.t = datenum(1900,1,1,rosr.time,0,0); % matlab date/time... this isn't right yet... 

% ,UTC,SST,lats,lons,tsgT

T = readtable('/Users/ethompson/DATA/ASTRAL_2024/Thompson/rosr_leg1.csv');
x = load('/Users/ethompson/DATA/ASTRAL_2024/Thompson/rosr_leg1.csv');
rosr.year   = table2array(T(:,2));
rosr.month  = table2array(T(:,3));
rosr.day    = table2array(T(:,4));
rosr.hour   = table2array(T(:,5));
rosr.minute = table2array(T(:,6));
rosr.second = table2array(T(:,7));
rosr.sst    = table2array(T(:,8));
rosr.lat    = table2array(T(:,9));
rosr.lon    = table2array(T(:,10));
rosr.tsg    = table2array(T(:,11));
rosr.t = datenum(rosr.year, rosr.month, rosr.day, rosr.hour, rosr.minute, rosr.second);


    % There isn't a great way to do this interp. The ROSR outputs a value at
    % irregularly spaced time steps because its averaging period is 5 min, and
    % on top of that it does not report when rain or excessive sea spray occurs
    % automatically (i.e. when it detects enough liquid for voltage to drop on
    % its primitive optical sensor). In practice, the rain sensor is cleaned
    % off every day briefly to make sure salt or spray are artificially
    % obscuring the sensor. 
    b1.tskin_ir = interp1(rosr.t, rosr.sst, b1.t);
    b10.tskin_ir = interp1(rosr.t, rosr.sst, b10.t);

    min10 = datenum(2009,12,25,0,10,0) - datenum(2009,12,25,0,0,0);
    for i = 1:length(b1.t)
        dtime = abs(b1.t(i) - rosr.t(closetime(rosr.t, b1.t(i))));
        if dtime > min10
            b1.tskin_ir(i) = nan;
        end
    end
    for i = 1:length(b10.t)
        dtime = abs(b10.t(i) - rosr.t(closetime(rosr.t, b10.t(i))));
        if dtime > min10
            b10.tskin_ir(i) = nan;
        end
    end

    plot_rosr_interp = 1;
    if plot_rosr_interp == 1
        figure;
        subplot(2,1,1); hold on;
        plot(b1.t, b1.tskin_ir,'o');
        plot(rosr.t, rosr.sst,'x');
        legend('interp to 1 min','orig');
        grid on;
        xlim([min(b1.t) max(b1.t)]);
        datetick('x','dd','keeplimits');

        subplot(2,1,2); hold on;
        plot(b10.t, b10.tskin_ir,'o');
        plot(rosr.t, rosr.sst,'x');
        legend('interp to 10 min','orig');
        grid on;
        xlim([min(b1.t) max(b1.t)]);
        datetick('x','dd','keeplimits');

        print(graphdevice,[path_fix_plots '/rosr_check_' cruise graphformat]);
    end

end

% %% precip data
% load('/Users/ethompson/DATA/ASTRAL_2023/Revelle/pwd/ASTRAL_rain.mat');
% pwd.jd = pwd.t - datenum(2023,0,0,0,0,0);
% b1.prate = interval_avg_var(pwd.jd, pwd.prate, jd_1bin);
% b10.prate = interval_avg_var(pwd.jd, pwd.prate, jd_10bin);
% b10.prate(isnan(b10.prate) == 1) = 0.0;
% b1.prate(isnan(b1.prate) == 1) = 0.0;
% b1.paccum = cumsum(b1.prate)/60;
% b10.paccum = cumsum(b10.prate)/6;

%% wave data

doing_waves = 0;
if doing_waves == 1

    wamos.jd = wamos.time_new - datenum(2023,0,0,0,0,0);

    add_waves = 0;
    if add_waves == 1
        b1.wave_sigheight   = interp1(wamos.jd, wamos.sigh, b1.jd);
        b10.wave_sigheight  = interp1(wamos.jd, wamos.sigh, b10.jd);
        b1.wave_period      = interp1(wamos.jd, wamos.Ts, b1.jd);
        b10.wave_period     = interp1(wamos.jd, wamos.Ts, b10.jd);
        b1.wave_phasespd = (9.81*b1.wave_period)/(2*pi);
        b10.wave_phasespd = (9.81*b10.wave_period)/(2*pi);
    else
        b1.wave_sigheight   = b1.t*nan;
        b10.wave_sigheight  = b10.t*nan;
        b1.wave_period      = b1.t*nan;
        b10.wave_period     = b10.t*nan;
        b1.wave_phasespd    = b1.t*nan;
        b10.wave_phasespd   = b10.t*nan;
    end
    
    badwaves10 = find(b10.t < datenum(2023,6,10,0,0,0) & b10.wave_sigheight < 2.9);
    badwaves1 = find(b1.t < datenum(2023,6,10,0,0,0) & b1.wave_sigheight < 2.9);
    
    b1.wave_sigheight(badwaves1) = nan;
    b10.wave_sigheight(badwaves10) = nan;
    b1.wave_period(badwaves1) = nan;
    b10.wave_period(badwaves10) = nan;
    b1.wave_phasespd(badwaves1) = nan;
    b10.wave_phasespd(badwaves10) = nan;
    
    % disp(['b10.U10N ' sprintf('%i %i',size(b10.u10n))]);
    % disp(['b10.wave_sigheight ' sprintf('%i %i',size(b10.wave_sigheight))]);
    % disp(['b10.wave_period ' sprintf('%i %i',size(b10.wave_period))]);
    % disp(['b10.phasespd ' sprintf('%i %i',size(b10.wave_phasespd))]);
    % 
    % disp(['b1.U10N ' sprintf('%i %i',size(b1.u10n))]);
    % disp(['b1.wave_sigheight ' sprintf('%i %i',size(b1.wave_sigheight))]);
    % disp(['b1.wave_period ' sprintf('%i %i',size(b1.wave_period))]);
    % disp(['b1.phasespd ' sprintf('%i %i',size(b1.wave_phasespd))]);
    
    % wavelength L = gT^2/2 pi,
    % phase speed = L / T
    % so phase speed = gT/2 pi
    
    plot_waves = 0;
    if plot_waves == 1
        
        figure;
        plot(wamos.time_new, wamos.Ts,'o');
        xlim([min(wamos.time_new) max(wamos.time_new)]);
        datetick('x','DD','keeplimits');
        ylabel('wave period, s^{-1}')
        grid on;
        
        yyaxis right;
        plot(wamos.time_new, wamos.sigh,'x');
        xlim([min(wamos.time_new) max(wamos.time_new)]);
        ylabel('sig wave height, m')
        grid on;
        
        title('ASTRAL 2023 WAMOS');
        print(graphdevice,[path_fix_plots '/wamos_' cruise graphformat]);
    
        
        %%% 
        
        figure;
        plot(b1.t, b1.wave_period,'.', b10.t, b10.wave_period,'x',...
            wamos.time_new, wamos.Ts,'o');
        xlim([min(b1.t) max(b1.t)]);
        datetick('x','DD','keeplimits');
        ylabel('wave period, s^{-1}')
        grid on;
            
        yyaxis right; 
        hold on;
        plot(b1.t, b1.wave_sigheight,'.k', b10.t, b10.wave_sigheight,'xr',...
            wamos.time_new, wamos.sigh,'xb');
        xlim([min(b1.t) max(b1.t)]);
        ylabel('sig height, m')
        grid on;
            
        title('ASTRAL 2023 WAMOS');
        print(graphdevice,[path_fix_plots '/wamos_interp_' cruise graphformat]);
    
    end
end
%% add or mask data from prior / new structures if needed

if nanmean(b10.hl > 0) < 0
    disp('***need to flip ship or PSL turb fluxes eventually, they are positive by default still');
%     flips = {'hs_s';'hl_s';'hrain_s'};
%     for k = 1:length(flips)
%         eval(['b10.' flips{k} ' = -b10.' flips{k} ';']);
%         eval(['b1.' flips{k} ' = -b1.' flips{k} ';']);
end
    
test_turb_plot = 0;
if test_turb_plot == 1
    figure;
    subplot(1,3,1);
    plot(b10.t, b10.hrain, b10.t, b10.hrain_s);
    title('hrain');
    datetick('x','dd'); axis tight; grid on;
    subplot(1,3,2);
    plot(b10.t, b10.hl, b10.t, b10.hl_s);
    title('hl');
    datetick('x','dd'); axis tight; grid on;
    legend('PSL','ship','location','best');
    subplot(1,3,3);
    plot(b10.t, b10.hs, b10.t, b10.hs_s);
    title('hs');
    datetick('x','dd'); axis tight; grid on;
end

%% adjustments to temps... this is how it used to be done but has been phased out. 
%% check PIR temp offsets from night air temps
% daytime = 1.5 Z = 14 Z ish
% nighttime = 15 Z = 1 Z
wh_night = find(b1.hour > 20); %% 
tc1_adj2 = nanmean(b1.ta(wh_night)-b1.lw_case_t_1(wh_night)); disp(['tc1_adj = ',sprintf('%4.2f',tc1_adj2)]);
td1_adj2 = nanmean(b1.ta(wh_night)-b1.lw_dome_t_1(wh_night)); disp(['td1_adj = ',sprintf('%4.2f',td1_adj2)]);
tc2_adj2 = nanmean(b1.ta(wh_night)-b1.lw_case_t_2(wh_night)); disp(['tc2_adj = ',sprintf('%4.2f',tc2_adj2)]);
td2_adj2 = nanmean(b1.ta(wh_night)-b1.lw_dome_t_2(wh_night)); disp(['td2_adj = ',sprintf('%4.2f',td2_adj2)]);
% tc_sh_adj = nanmean(b1.ta(wh_night)-b1.lw_dome_t_s(wh_night)); disp(['tc_sh_adj = ',sprintf('%4.2f',tc_sh_adj)]);
% td_sh_adj = nanmean(b1.ta(wh_night)-b1.lw_dome_t_s(wh_night)); disp(['td_sh_adj = ',sprintf('%4.2f',td_sh_adj)]);


% Even if used, it was only called in evalflux.
% Currently, corrections get done instead in fix_met_sea, not here.
% but potentially, this could be used if you knew ahead of time what the
% corrections should be. We usually don't and have to do tests to figure it
% out. So we assume here that no corrections are needed initially.

% td1_adj = 0;        % PIR dome 1
% tc1_adj = 0;        % PIR case 1
% td2_adj = 0;        % PIR dome 2
% tc2_adj = 0;        % PIR case 2
% td_ship_adj = 0;    % PIR dome ship
% tc_ship_adj = 0;    % PIR case ship
% tsea_adj = 0;       % sea snake
% ta_adj = 0;         % air temp
% 
% adj = [tsea_adj,ta_adj,td1_adj,tc1_adj,td2_adj,tc2_adj];
% ship_adj = [td_ship_adj,tc_ship_adj];

%% pressure height check

% b1.psealevel_s
% b1.psealevel_reported_s
% b1.pa_s
% b1.pa

% recalculate slp for noaa sensor after the heights were corrected
b1.psealevel = b1.pa + 0.125*zp; 
% b1.qsnk = qsea_p(b1.tsnk,b1.psealevel); % don't worry about this, it's
% done later with salinity anyway

% zp_s = nanmedian((b1.psealevel_reported_s - b1.pa_s)/0.125);

plot_press = 1;
if plot_press == 1
    figure;
    plot(b1.t, b1.psealevel, b1.t, b1.psealevel_s);
    legend('PSL','ship');
    grid on;
    ylabel('SLP, mb');
    title('ASTRAL 2023');
    datetick('x','DD');
    print(graphdevice,[path_fix_plots '/press_' cruise graphformat]);  
end

%% speed through water... check to make sure it's in m/s not knots
% convert kt to m/s... spdlog_ms = spdlog_kt/1.944

spdlog = 0;
if spdlog == 1

    bad_spdlog_1 = find(abs(b1.spdlog_u_s) > 10 | abs(b1.spdlog_v_s) > 10);
    b1.spdlog_u_s(bad_spdlog_1) = nan;
    b1.spdlog_v_s(bad_spdlog_1) = nan;
    b1.spdlog_s(bad_spdlog_1) = nan;
    
    bad_spdlog_10 = find(abs(b10.spdlog_u_s) > 10 | abs(b10.spdlog_v_s) > 10);
    b10.spdlog_u_s(bad_spdlog_10) = nan;
    b10.spdlog_v_s(bad_spdlog_10) = nan;
    b10.spdlog_s(bad_spdlog_10) = nan;
    
    plot_spdlog = 0;
    if plot_spdlog == 1
        figure('position',[1,1, 1200, 400]);
        subplot(1,3,1);hold on;
        plot(b1.t, b1.spdlog_u_s, b1.t, b1.spdlog_v_s); 
        ylim([-1 6]);
        grid on;
        ylabel('m s^{-1}');
        legend('spd log u','spd log v');
        datetick('x','dd');
        title(ptitle)
    
        subplot(1,3,2);hold on;
        plot(b1.t, b1.spdlog_s, b1.t, b1.sog_s); 
        ylim([-1 6]);
        grid on;
        ylabel('m s^{-1}');
        legend('spd log','sog');
        datetick('x','dd');
    
        subplot(1,3,3);hold on;
        plot(b1.spdlog_s, b1.sog_s,'.'); 
        ylim([-1 6]); xlim([-1 6]);
        plot(ylim, ylim, '--','color',rgb('skyblue'));
        grid on;
        xlabel('spd log, m s^{-1}');
        ylabel('sog, m s^{-1}');
        axis square;
    
        print(graphdevice,[path_fix_plots '/spdlog_' cruise graphformat]);
    end
end

%% determine best nav data... fill gaps to have continuous time series
% for PISTON 2019, PSL and ship data are nearly equivalent. Just need to
% fill a few gaps. Either with fill_ga

disp(['missing 1 min sog = ' sprintf('%i',length(find(isnan(b1.sog) == 1)))]);
disp(['missing 1 min sog_s = ' sprintf('%i',length(find(isnan(b1.sog_s) == 1)))]);
disp(['missing 1 min hed = ' sprintf('%i',length(find(isnan(b1.hed) == 1)))]);
disp(['missing 1 min hed_s = ' sprintf('%i',length(find(isnan(b1.hed_s) == 1)))]);
disp(['missing 1 min cog = ' sprintf('%i',length(find(isnan(b1.cog) == 1)))]);
disp(['missing 1 min cog_s = ' sprintf('%i',length(find(isnan(b1.cog_s) == 1)))]);
disp(['missing 1 min lat = ' sprintf('%i',length(find(isnan(b1.lat) == 1)))]);
disp(['missing 1 min lat_s = ' sprintf('%i',length(find(isnan(b1.lat_s) == 1)))]);
disp(['missing 1 min lon = ' sprintf('%i',length(find(isnan(b1.lon) == 1)))]);
disp(['missing 1 min lon_s = ' sprintf('%i',length(find(isnan(b1.lon_s) == 1)))]);

plot_nav = 1;
if plot_nav == 1
figure;
subplot(2,3,1); hold on;
plot(b10.sog, b10.sog_s,'x'); axis square; xlim([0 10]);
    plot(xlim, xlim,'--y'); title('SOG'); grid on;
    axis square; xlabel('NOAA'); ylabel('ship');
subplot(2,3,2); hold on;
plot(b10.cog, b10.cog_s,'x'); axis square; xlim([0 360]);
    plot(xlim, xlim,'--y'); title('COG'); grid on;
    axis square; xlabel('NOAA'); ylabel('ship');
subplot(2,3,3); hold on;
plot(b10.hed, b10.hed_s,'x'); axis square; xlim([0 360]);
    plot(xlim, xlim,'--y'); title('HEADING'); grid on;
    axis square; xlabel('NOAA'); ylabel('ship');
subplot(2,3,4); hold on;
plot(b10.lat, b10.lat_s,'x'); axis square; xlim([min(xlim)-1 max(xlim)+1]);...
    ylim(xlim); plot(xlim, xlim,'--y'); title('LAT'); grid on;
    axis square; xlabel('NOAA'); ylabel('ship');
subplot(2,3,5); hold on;
plot(b10.lon, b10.lon_s,'x'); axis square; xlim([min(xlim)-1 max(xlim)+1]); ...
    ylim(xlim); plot(xlim, xlim,'--y'); title('LON'); grid on;
    axis square; xlabel('NOAA'); ylabel('ship');

print(graphdevice,[path_fix_plots '/nav_' cruise graphformat]);

end

%% snake and TSG corrections; loading other T/S data
tsg_other_corrections = 0;
if tsg_other_corrections == 1
    %%% decide whether to correct snake to the ROSR or the otter
    %%% and whether to correct the TSG to the snake or Otter or ROSR
    % cor_type_snk = 'o';  % correct to otter
    cor_type_tsg = 's';  % correct to snake... meaning correct to otter :)

    % cor_type = 'o';

    %   *** otter 1:
    %                   T: [21×7321 double]
    %                   z: [21×1 double]
    %                  sn: {21×1 cell}
    %                   S: [5×7321 double]
    %                  zS: [5×1 double]
    %                   p: [5×7321 double]
    %                  zp: [5×1 double]
    %                   t: [1×7321 double]
    %      S_uncalibrated: [5×7321 double]
    %     S_calibrate_idx: [1×7321 logical]
    %     T_calibrate_idx: [1×7321 logical]
    %      T_uncalibrated: [21×7321 double]
    %            T_spline: [21×7321 double]
    %                dtdz: [21×7321 double]
    %            S_spline: [21×7321 double]
    %                dSdz: [21×7321 double]
    %         pden_spline: [21×7321 double]
    %                  N2: [21×7321 double]
    % readme: 'Processed by Ken Hughes's script create_otter_ctd_matrix_piston19 on 20-Sep-2019 23:19:09.
    %           ... see below for more readme repeated

    %   *** otter 2:
    %                   T: [21×5831 double]
    %                   z: [21×1 double]
    %                  sn: {21×1 cell}
    %                   S: [5×5831 double]
    %                  zS: [5×1 double]
    %                   p: [5×5831 double]
    %                  zp: [5×1 double]
    %                   t: [1×5831 double]
    %      S_uncalibrated: [5×5831 double]
    %     S_calibrate_idx: [1×5831 logical]
    %     T_calibrate_idx: [1×5831 logical]
    %      T_uncalibrated: [21×5831 double]
    %            T_spline: [21×5831 double]
    %                dtdz: [21×5831 double]
    %            S_spline: [21×5831 double]
    %                dSdz: [21×5831 double]
    %         pden_spline: [21×5831 double]
    %                  N2: [21×5831 double]
    % readme: 'Processed by Ken Hughes's script create_otter_ctd_matrix_piston19 on 21-Sep-2019 00:35:42.
    % Temperature, salinity, and pressure data from all of the sensors on the surf otter, excluding fast thermistors (GusTs, TPods).
    % Temperature and salinity are 'calibrated' by minimizing the offset to their respective means at night, 
    % when the surface layer is assumed isothermal/isohaline unless there is an obvious, true gradient in T or S.
    % Uncalibrated T and S are included for reference. As are the time indices at which data were included in the calibration.
    % Sensors included some or all of RBR Solo T (sn=10???? or 076???), Idronaut CTDs (sn=021663?), 
    % RBR Concertos (sn=06????), and Seabird SBE37s (sn=371660?). T and S gradients calculated from spline fits.
    % Splines fit with Matlab's csaps function with a smoothing value (p) dependent on the size of the signal'

    % find otter data closest to TSG # 2 (port aft) level... between 2.3 - 3.4 m. Nominally, we're calling it 3 m.
    % wh_otter_tsea_depth_1 = find(o1.otter.z > 2.3 & o1.otter.z < 3.4);
    % wh_otter_tsea_depth_2 = find(o2.otter.z > 2.3 & o2.otter.z < 3.4);
    % wh_otter_tsea_depth_3 = find(o3.otter.z > 2.3 & o3.otter.z < 3.4);
    % 
    % wh_otter_ssea_depth_1 = find(o1.otter.zS > 2.3 & o1.otter.zS < 3.4);
    % wh_otter_ssea_depth_2 = find(o2.otter.zS > 2.3 & o2.otter.zS < 3.4);
    % wh_otter_ssea_depth_3 = find(o3.otter.zS > 2.3 & o3.otter.zS < 3.4);

    % % do a mean along depth indicies
    % o1_mean_at_tsea = nanmean(o1.otter.T(wh_otter_tsea_depth_1,:), 1);
    % o1_mean_at_ssea = o1.otter.S(wh_otter_ssea_depth_1,:);
    % o2_mean_at_tsea = nanmean(o2.otter.T(wh_otter_tsea_depth_2,:), 1);
    % o2_mean_at_ssea = o2.otter.S(wh_otter_ssea_depth_2,:);
    % o3_mean_at_tsea = nanmean(o3.otter.T(wh_otter_tsea_depth_3,:), 1);
    % o3_mean_at_ssea = o3.otter.S(wh_otter_ssea_depth_3,:);
    % 
    % o1_top_at_tsea = o1.otter.T(wh_otter_tsea_depth_1(1),:);
    % o2_top_at_tsea = o2.otter.T(wh_otter_tsea_depth_2(1),:);
    % o3_top_at_tsea = o3.otter.T(wh_otter_tsea_depth_3(1),:);
    % 
    % o1_base_at_tsea = o1.otter.T(wh_otter_tsea_depth_1(end),:);
    % o2_base_at_tsea = o2.otter.T(wh_otter_tsea_depth_2(end),:);
    % o3_base_at_tsea = o3.otter.T(wh_otter_tsea_depth_3(end),:);
    % 
    % o_mean_at_tsea = [o1_mean_at_tsea o2_mean_at_tsea o3_mean_at_tsea];
    % o_mean_at_ssea = [o1_mean_at_ssea o2_mean_at_ssea o3_mean_at_ssea];
    % 
    % o_top_at_tsea = [o1_top_at_tsea o2_top_at_tsea o3_top_at_tsea];
    % 
    % o_base_at_tsea = [o1_base_at_tsea o2_base_at_tsea o3_base_at_tsea];
    % 
    % %%% grab data
    % oT_at_snake = [o1.otter.T(1,:) o2.otter.T(1,:) o3.otter.T(1,:)];  % from 0.10 m below vehicle == 0.6 m total
    % oS_at_snake = [o1.otter.S(1,:) o2.otter.S(1,:) o3.otter.S(1,:)];  % from 0.35 m below vehicle == 0.85 m total
    % 
    % ot = [o1.otter.t o2.otter.t o3.otter.t];
    % no_otter_1 = find(b1.t < o1.otter.t(1));
    % no_otter_2 = find(b1.t > o1.otter.t(end) & b1.t < o2.otter.t(1));
    % no_otter_3 = find(b1.t > o2.otter.t(end) & b1.t < o3.otter.t(1));
    % no_otter_4 = find(b1.t > o3.otter.t(end));
    % no_otter = [no_otter_1; no_otter_2; no_otter_3; no_otter_4];
    % ID_no_otter = zeros(length(b1.t), 1);
    % ID_no_otter(no_otter) = 1;
    % ID_otter = double(~ID_no_otter);
    % wh_otter = find(ID_otter == 1);
    % 
    % ossea_mean = interp1(ot, o_mean_at_ssea, b1.t);
    % otsea_mean = interp1(ot, o_mean_at_tsea, b1.t);
    % otsea_top = interp1(ot, o_top_at_tsea, b1.t);
    % otsea_base = interp1(ot, o_base_at_tsea, b1.t);
    % oTsnake = interp1(ot, oT_at_snake, b1.t);
    % oSsnake = interp1(ot, oS_at_snake, b1.t);
    % 
    % ossea_mean(no_otter) = nan;
    % otsea_mean(no_otter) = nan;
    % otsea_top(no_otter) = nan;
    % otsea_base(no_otter) = nan;
    % oTsnake(no_otter) = nan;
    % oSsnake(no_otter) = nan;

    % %%% add a few otter variables to structures
    % b1.ID_otter = ID_otter;
    % b1.ID_no_otter = ID_no_otter;
    % b1.S_0p85 = oSsnake;
    % b10.S_0p85 = interval_avg_var(b1.jd, b1.S_0p85, jd_10bin);

    % wh_otter_10 = find(isfinite(b10.S_0p85) == 1);
    % b10.ID_otter = zeros(length(b10.t), 1);
    % b10.ID_otter(wh_otter_10) = 1;
    % b10.ID_no_otter = double(~b10.ID_otter);
    % wh_no_otter_10 = find(b10.ID_no_otter == 1);

end

%% infrared radiation
% sig_sb = 5.67e-8; % Stefan Boltzmann constant
% C2K = 273.15; % K
% c3_1 = 3.63; % coefficient k1 for PIR1 from June 2017 calibration... not the correct one but it's all we've got so far
% c3_2 = 3.37; % coefficient k2 for PIR2 from June 2017 calibration... not the correct one but it's all we've got so far
% k2_corr = 0; % start off as zero (not sure what this is)
% 
% % IDEAS: try different c3 values
% % 18 W = how much it matters if case and dome are 1 deg different. 
% % an extreme error is on the order of 10 W. 
% 
% % note: PIR2 domeT was all bad because KZ unand PIR1 caseT aren't trustworthy. 
% %%% this is perhaps a solution. Thermopile outputs look good. Then
% %%% PIR2 had best case T, but PIR2 had best case T. For these equations,
% %%% measured therm is positive and should be negative. So we add a negative
% %%% sign to the first term of this equation.
% pir1 = -b1.lw_therm_1 + sig_sb*(b1.lw_case_t_2+C2K).^4 - c3_1*sig_sb*((b1.lw_dome_t_1+C2K).^4-(b1.lw_case_t_2+C2K).^4);
% % pir2 = -b1.lw_therm_2 + sig_sb*(b1.lw2_case_t+C2K).^4 - k1*sig_sb*((b1.lw1_dome_t+C2K).^4-(b1.lw2_case_t+C2K).^4);
% pir2 = -b1.lw_therm_2 + sig_sb*(b1.lw_case_t_2+C2K).^4;
% % pir2_corr = -b1.lw_therm_2 + sig_sb*(b1.lw_case_t_2+C2K).^4 - k2_corr*b1.sw1; 
% 
% %%% ... correcting as a function of solar forcing, which is causing the dome to heat up. 
% % k2_corr is a new calibration coefficient for adjusting the IR for solar
% % heating when the unit doesn't measure dome T
% plot_sw_ir = 0;
% if plot_sw_ir == 1
%     figure; plot(b1.sw_dn_1, pir2-pir1,'.');
%     ylabel('corrected pir2 - pir1');
%     xlabel('sw dn 1');
%     print(graphdevice,[path_fix_plots '/IR_Solar_' cruise graphformat]);
% end
% 
% plot_ir = 0;
% if plot_ir == 1
%     figure;
%     plot(b1.t, b1.lw_dn_1, b1.t, pir1, b1.t, pir2);
%     legend('orig PIR1','new PIR1','new PIR2');%, 'ship');
%     datetick;
%     ylabel('W m^{-2}');
%     grid on;
%     title(['original and corrected IR_{down} ' cruise]);
%     print(graphdevice,[path_fix_plots '/IR_' cruise graphformat]);
% end
% 
% % save new 
% b1.lw_dn_1 = pir1;
% b1.lw_dn_2 = pir2;
% b10.lw_dn_1 = interval_avg_var(b1.jd, b1.lw_dn_1, jd_10bin);
% b10.lw_dn_2 = interval_avg_var(b1.jd, b1.lw_dn_2, jd_10bin);


%% bad and moderate wind flags
wh_mod_wind = find(abs(b1.rdir) > 90);
wh_bad_wind = find(abs(b1.rdir) > 120);

b1.ID_mod_wind = b1.t*0;
b1.ID_bad_wind = b1.t*0;
b1.ID_mod_wind(wh_mod_wind) = 1;
b1.ID_bad_wind(wh_bad_wind) = 1;

wh_mod_wind_10 = find(abs(b10.rdir) > 90);
wh_bad_wind_10 = find(abs(b10.rdir) > 120);

b10.ID_mod_wind = b10.t*0;
b10.ID_bad_wind = b10.t*0;
b10.ID_mod_wind(wh_mod_wind_10) = 1;
b10.ID_bad_wind(wh_bad_wind_10) = 1;


%% wind speed
% readjust wind if needed

%% snake T corrections
snake_corrections = 1;
if snake_corrections == 1     
    %%% Tsnake T correction... originally estimated at 0.12 C in the field in PISTON
    %%% Check otter and rosr at night again to be sure
%     dt_snk_est = 0.00;

    wh_pm_r = find(b1.hour >20);
    % wh_pm_o = find(b1.hour >= 16 & b1.hour <= 21 & ID_otter == 1);
    % dt_snk_otter = b1.tsnk(wh_pm_o) - oTsnake(wh_pm_o);
    dt_sst_rosr = b1.tskin(wh_pm_r) - b1.tskin_ir(wh_pm_r);

    % offset_snk_otter = prctilex(dt_snk_otter, 50);
    offset_sst_rosr = prctilex(dt_sst_rosr, 50);

    % tsnk_cor_o = b1.tsnk-offset_snk_otter;
    tsnk_cor_r = b1.tsnk-offset_sst_rosr;

    % look at resulting SST changes... but don't apply them because we'll
    % recalculate SST with COARE later anyway.
    plot_sst = 1;
    if plot_sst == 1
        figure('position',[1,1, 1200, 600]);
    %     subplot(2,3,1); hold on;
    %     plot(b1.tsnk(wh_pm_o), oTsnake(wh_pm_o),'.');
    %     ylabel('60 cm T_{otter}');
    %     xlabel('50 cm T_{snake}');
    %     ylim([28.5 29.3]);xlim([28.5 29.3]);
    %     plot(ylim, ylim, '--','color',rgb('skyblue'));
    %     title('snake offset');
    %     axis square;
    %     grid on;
    %     text(min(xlim)+0.1*diff(xlim), max(ylim)-0.05*diff(ylim), ['med = ' sprintf('%3.3f',offset_snk_otter)],...
    %         'fontsize',16);
    %     text(min(xlim)+0.1*diff(xlim), max(ylim)-0.1*diff(ylim), ...
    %         ['mean = ' sprintf('%3.3f',nanmean(dt_snk_otter))],'fontsize',16);
    % 
    % 
    %     subplot(2,3,2); hold on;
    %     plot(tsnk_cor_o(wh_pm_o), oTsnake(wh_pm_o),'.');
    %     ylabel('60 cm T_{otter}');
    %     xlabel('50 cm T_{snake}');
    %     ylim([28.5 29.3]);xlim([28.5 29.3]);
    %     plot(ylim, ylim, '--','color',rgb('skyblue'));
    %     title('Corrected snake: otter');
    %     axis square;
    %     grid on;
    %     text(min(xlim)+0.1*diff(xlim), max(ylim)-0.05*diff(ylim), ...
    %         ['rmse = ' sprintf('%3.3f',rmse(tsnk_cor_o(wh_pm_o), oTsnake(wh_pm_o)))],'fontsize',16);

    %     subplot(2,3,3); hold on;
    %     plot(tsnk_cor_r(wh_pm_o), oTsnake(wh_pm_o),'.');
    %     ylabel('60 cm T_{otter}');
    %     xlabel('50 cm T_{snake}');
    %     ylim([28.5 29.3]);xlim([28.5 29.3]);
    %     plot(ylim, ylim, '--','color',rgb('skyblue'));
    %     title('Corrected snake: rosr');
    %     axis square;
    %     grid on;
    %     text(min(xlim)+0.1*diff(xlim), max(ylim)-0.05*diff(ylim), ...
    %         ['rmse = ' sprintf('%3.3f',rmse(tsnk_cor_r(wh_pm_o), oTsnake(wh_pm_o)))],'fontsize',16);

        subplot(1,2,1); hold on;
        plot(b1.tskin(wh_pm_r), b1.tskin_ir(wh_pm_r),'.');
        ylabel('0 cm SST');
        xlabel('0 cm T_{rosr}');
        ylim([30 32.5]);xlim([30 32.5]);
        plot(ylim, ylim, '--','color',rgb('skyblue'));
        title('SST offset');
        axis square;
        grid on;
        text(min(xlim)+0.1*diff(xlim), max(ylim)-0.05*diff(ylim), ['MEDIAN = ' sprintf('%3.3f',offset_sst_rosr)],...
            'fontsize',16);
        text(min(xlim)+0.1*diff(xlim), max(ylim)-0.1*diff(ylim), ...
            ['MEAN = ' sprintf('%3.3f',nanmean(dt_sst_rosr))],'fontsize',16);

        subplot(1,2,2); hold on;
        plot(b1.tskin(wh_pm_r)-offset_sst_rosr, b1.tskin_ir(wh_pm_r),'.');
        ylabel('0 cm SST');
        xlabel('0 cm T_{rosr}');
        ylim([30 32.5]);xlim([30 32.5]);
        plot(ylim, ylim, '--','color',rgb('skyblue'));
        title('Corrected SST: rosr');
        axis square;
        grid on;
        text(min(xlim)+0.1*diff(xlim), max(ylim)-0.05*diff(ylim), ...
            ['RMSE = ' sprintf('%3.3f',rmse(b1.tskin(wh_pm_r)-offset_sst_rosr, b1.tskin_ir(wh_pm_r)))],'fontsize',16);

%         subplot(1,3,3); hold on;
%         plot(b1.tskin(wh_pm_r)-offset_snk_otter, b1.tskin_ir(wh_pm_r),'.');
%         ylabel('0 cm SST');
%         xlabel('0 cm T_{rosr}');
%         ylim([28.5 29.3]);xlim([28.5 29.3]);
%         plot(ylim, ylim, '--','color',rgb('skyblue'));
%         title('Corrected SST: otter');
%         axis square;
%         grid on;
%         text(min(xlim)+0.1*diff(xlim), max(ylim)-0.05*diff(ylim), ...
%             ['rmse = ' sprintf('%3.3f',rmse(b1.tskin(wh_pm_r)-offset_snk_otter, b1.tskin_ir(wh_pm_r)))],'fontsize',16);
        print(graphdevice,[path_fix_plots '/snake_T_' cruise graphformat]);
    end

    plot_snake_before_after = 1;
    if plot_snake_before_after == 1
        figure;
        plot(b1.t, b1.tsnk,'o', b1.t, b1.tsnk - offset_sst_rosr,'-');
        hold on;
        plot(b1.t, b1.tsea_in_s, b1.t, b1.tsea_s);
        legend('snk original','snk corr','TSG intake','TSG','location','best');
        grid on;
        axis tight;
        datetick('x','dd','keeplimits');
        title([ptitle ' May - SST']);
        print(graphdevice,[path_fix_plots '/snake_T_orig_corr_' cruise graphformat]);
    end

    %% choose corrected snake value and save... based on "other" data
    cor_type_snk = 'r';
    if cor_type_snk == 'r'
        % correct tsnk to ROSR
        b1.tsnk = b1.tsnk - offset_sst_rosr; 
    %     b1.tskin = b1.tskin - offset_sst_rosr; %%% this is going to get redone
    %     anyway
    elseif cor_type_snk == 'o'
        % correct tsnk to otter
        b1.tsnk = tsnk_cor_o; 
    %     b1.tskin = b1.tskin - offset_snk_otter; %%% this is going to get
    %     redone anyway
    end

    % redo qsnk from tsnk... uses same code as COARE
    b1.qsnk = qsea_sp(b1.tsnk, b1.psealevel, b1.ssea_s);
    b10.tsnk = interp1(b1.t, b1.tsnk, b10.t);
    b10.qsnk = qsea_sp(b10.tsnk, b10.psealevel, b10.ssea_s);
end


%% TSG corrections to T and S 

tsg_normal_corrections = 0;
if tsg_normal_corrections == 1

    
    tuctd = interp1(surface_uCTD.datenum, surface_uCTD.T, b1.t, 'nearest',1);
    tuctd(tuctd < 25) = nan;
    suctd = interp1(surface_uCTD.datenum, surface_uCTD.S, b1.t, 'nearest',1);
    suctd(suctd < 20) = nan;

    %%% determine late night - early morning offset between TSG and tsnk
    wh_pma = find(b1.hour > 20 & b1.t > datenum(2023,6,15,0,0,0) & b1.t < datenum(2023,6,19,18,0,0));
    wh_pmb = find(b1.hour > 20 & b1.t > datenum(2023,6,20,18,0,0));
    wh_pm = [wh_pma; wh_pmb];
  
    tsea_before = b1.tsea_in_s;
    tsea_best = b1.tsea_in_s;
    tsnk_before = b1.tsnk;

    %%% if snake needs correcting by TSG
    dt_snk = b1.tsnk(wh_pm) - tsea_best(wh_pm);
    offset_snk = nanmedian(dt_snk);
    %%% if snake needs correcting by uCTD
    dt_snku = b1.tsnk(wh_pm) - tuctd(wh_pm);
    offset_snku = nanmedian(dt_snku);
    
    
    perform_correction_snk = 1;
    if perform_correction_snk == 1
        tsnk_best = b1.tsnk - offset_snku;
        b1.tsnk = tsnk_best;
        b10.tsnk = interval_avg_var(b1.jd, b1.tsnk, jd_10bin); 
        b1.tsea_s = b1.tsea_in_s;
        b10.tsea_s = b10.tsea_in_s;
        b1.qsnk = qsea_p(b1.tsnk,b1.psealevel);
        b10.qsnk = qsea_p(b10.tsnk,b10.psealevel);
    end
    
    %%% TSG 2 is less noisy, but TSG 1 is more accurate to uCTD. Just
    %%% correct TSG2 for offset to uCTD/snake. 
    %%% if tsg needs correcting by snake
    dt_tsg = tsea_best(wh_pm) - b1.tsnk(wh_pm);
    offset_tsg = nanmedian(dt_tsg);   
    %%% if tsg needs correcting by uctd
    dt_tsgu = tsea_best(wh_pm) - tuctd(wh_pm);
    offset_tsgu = nanmedian(dt_tsgu);   
    
    perform_correction_tsg = 1;
    if perform_correction_tsg == 1
        tsea_bestc = tsea_best - offset_tsgu;
        b1.tsea_s = tsea_bestc;
        b10.tsea_s = interval_avg_var(b1.jd, b1.tsea_s, jd_10bin);
    end
    

    
    
    plot_t = 0;
    if plot_t == 1
        

        figure;
        subplot(2,1,1); hold on;
        plot(tsea_before(wh_pm), tsnk_before(wh_pm),'.');
        plot(tsea_before(wh_pm), tuctd(wh_pm),'.');
        ylabel('');
        xlabel('5 m T_{TSG}');
%         ylim([28.6 29.4]);xlim([28.6 29.4]);
        plot(ylim, ylim, '--','color',rgb('skyblue'));
        title('original');
        legend('snake','uCTD','location','southeast');
        axis square;
        grid on;
%         text(min(xlim)+0.1*diff(xlim), max(ylim)-0.05*diff(ylim), ...
%         ['rmse = ' sprintf('%3.3f',rmse(tsea_best(wh_pm), b1.tsnk(wh_pm)))],'fontsize',16);

        subplot(2,1,2); hold on;
        plot(b1.tsea_s(wh_pm), b1.tsnk(wh_pm),'.');
        plot(b1.tsea_s(wh_pm), tuctd(wh_pm),'.');
        ylabel('');
        xlabel('5 m T_{TSG}');
        plot(ylim, ylim, '--','color',rgb('skyblue'));
        if perform_correction_snk == 1
            title('corrected snake with uCTD');
        elseif perform_correction_tsg == 1
            title('corrected TSG and TSG with uCTD');
        end
            legend('snake','uCTD','location','southeast');
            axis square;
            grid on;           
        
        print(graphdevice,[path_fix_plots '/TSG_T_' cruise graphformat]);
        
        figure; 
        plot(b1.t, b1.tsnk, surface_uCTD.datenum, surface_uCTD.T, b1.t, b1.tsea_s);
        legend('snake 0.05 m','uCTD 4 m','TSG 5 m');
        grid on;
        ylabel('T^oC')
        xlim([min(b1.t) max(b1.t)]);
        datetick('x','DD','keeplimits');
        title('final seawater T');
        print(graphdevice,[path_fix_plots '/TSG_T_timeseries_' cruise graphformat]);

        
    end
%%% plots for if other sources of info are available to test TSG offsets
%         subplot(2,3,3); hold on;
%         plot(tsea_cor_o(wh_pre_pm), b1.tsnk(wh_pre_pm),'.');
%         plot(tsea_cor_o(wh_post_pm_A), b1.tsnk(wh_post_pm_A),'.');
%         plot(tsea_cor_o(wh_post_pm_B), b1.tsnk(wh_post_pm_B),'.');
%         legend('pre','post A','post B','location','southeast');
%         ylabel('50 cm T_{snake}');
%         xlabel('5 m T_{TSG}');
%         ylim([28.6 29.4]);xlim([28.6 29.4]);
%         plot(ylim, ylim, '--','color',rgb('skyblue'));
%         title('corrected TSG T: otter');
%         axis square;
%         grid on;
%         text(min(xlim)+0.1*diff(xlim), max(ylim)-0.05*diff(ylim), ...
%             ['rmse = ' sprintf('%3.3f',rmse(tsea_cor_o(wh_test), b1.tsnk(wh_test)))],'fontsize',16);
% 
% 
%         subplot(2,3,4); hold on;
%         plot(tsea_best(wh_pre_pm_o), otsea_mean(wh_pre_pm_o),'.');
%         plot(tsea_best(wh_post_pm_A_o), otsea_mean(wh_post_pm_A_o),'.');
%         plot(tsea_best(wh_post_pm_B_o), otsea_mean(wh_post_pm_B_o),'.');
%         legend('pre','post A','post B','location','southeast');
%         ylabel('3 m T_{otter}');
%         xlabel('3 m T_{TSG}');
%         ylim([28.6 29.4]);xlim([28.6 29.4]);
%         plot(ylim, ylim, '--','color',rgb('skyblue'));
%         title('TSG T offset');
%         axis square;
%         grid on;
% 
%         subplot(2,3,5); hold on;
%         plot(tsea_cor_o(wh_pre_pm_o), otsea_mean(wh_pre_pm_o),'.');
%         plot(tsea_cor_o(wh_post_pm_A_o), otsea_mean(wh_post_pm_A_o),'.');
%         plot(tsea_cor_o(wh_post_pm_B_o), otsea_mean(wh_post_pm_B_o),'.');
%         legend('pre','post A','post B','location','southeast');
%         ylabel('5 m T_{otter}');
%         xlabel('5 m T_{TSG} corrected');
%         ylim([28.6 29.4]);xlim([28.6 29.4]);
%         plot(ylim, ylim, '--','color',rgb('skyblue'));
%         title('corrected TSG T: otter');
%         axis square;
%         grid on;
%         print(graphdevice,[path_fix_plots '/TSG_T_' cruise graphformat]);
%         text(min(xlim)+0.1*diff(xlim), max(ylim)-0.05*diff(ylim), ...
%             ['rmse = ' sprintf('%3.3f',rmse(tsea_cor_o(wh_test_o), otsea_mean(wh_test_o)))],'fontsize',16);
% 
%         subplot(2,3,6); hold on;
%         plot(tsea_cor_s(wh_pre_pm_o), otsea_mean(wh_pre_pm_o),'.');
%         plot(tsea_cor_s(wh_post_pm_A_o), otsea_mean(wh_post_pm_A_o),'.');
%         plot(tsea_cor_s(wh_post_pm_B_o), otsea_mean(wh_post_pm_B_o),'.');
%         legend('pre','post A','post B','location','southeast');
%         ylabel('3 m T_{otter}');
%         xlabel('3 m T_{TSG} corrected');
%         ylim([28.6 29.4]);xlim([28.6 29.4]);
%         plot(ylim, ylim, '--','color',rgb('skyblue'));
%         title('corrected TSG T: snake');
%         axis square;
%         grid on;
%         text(min(xlim)+0.1*diff(xlim), max(ylim)-0.05*diff(ylim), ...
%             ['rmse = ' sprintf('%3.3f',rmse(tsea_cor_s(wh_test_o), otsea_mean(wh_test_o)))],'fontsize',16);

    


    %%% The snake is corrected to the sparse otter data, and the snake data is
    %%% then used to correct the TSG since its available for longer record


    %% seawater S
    ssea_best = b1.ssea_s;  % salinity
%     %%% determine late night - early morning offset between TSG and tsnk
%     dS_pre_o        = ssea_best(wh_pre_pm_o) - ossea_mean(wh_pre_pm_o);
%     dS_post_A_o     = ssea_best(wh_post_pm_A_o) - ossea_mean(wh_post_pm_A_o);
%     dS_post_B_o     = ssea_best(wh_post_pm_B_o) - ossea_mean(wh_post_pm_B_o);
% 
%     offset_pre_o_S = prctilex(dS_pre_o, 50);
%     offset_post_A_o_S = prctilex(dS_post_A_o, 50);
%     offset_post_B_o_S = prctilex(dS_post_B_o, 50);
% 
%     ssea_cor = ssea_best;
%     ssea_cor(wh_fix_pre) = ssea_best(wh_fix_pre) - offset_pre_o_S;
%     ssea_cor(wh_fix_post_A) = ssea_best(wh_fix_post_A) - offset_post_A_o_S;
%     ssea_cor(wh_fix_post_B) = ssea_best(wh_fix_post_B) - offset_post_B_o_S;

    ssea_offset_uctd = nanmedian(ssea_best - suctd);
    ssea_offsets = ssea_best - suctd;
    % just get the numbers
    ssea_offsetsf = ssea_offsets(isfinite(ssea_offsets)==1);
    ssea_offset_start = median(ssea_offsetsf(1:20));
    ssea_offset_end = median(ssea_offsetsf(end-20:end));
%     sseadrift_total = ssea_offset_end - ssea_offset_start;
    ds_drift = ssea_offset_end/length(ssea_best);
    sseadrift = 0:ds_drift:ssea_offset_end;
    sseadrift = sseadrift(1:end-1)'; % exclude last member. 
    ssea_bestc = ssea_best - sseadrift;
    
%     correct_s = 1;
%     if correct_s == 1
%         ssea_bestc = ssea_best - ssea_offset_uctd;
%     end
    
    b1.ssea_s = ssea_bestc;
    b10.ssea_s = interval_avg_var(b1.jd, b1.ssea_s, jd_10bin);

        
    plot_s = 0;
    if plot_s == 1
        
        %%% scatter
        
        figure('position',[1,1, 800, 400]);
        subplot(1,2,1); hold on;
        plot(ssea_best, suctd,'.');
        xlabel('5 m S TSG');
        ylabel('4 m S uCTD');
        plot(ylim, ylim, '--','color',rgb('skyblue'));
        grid on;
        title('TSG vs. uCTD S offset');
        axis square;

        subplot(1,2,2); hold on;
        plot(ssea_bestc, suctd,'.');
        xlabel('5 m S TSG corrected');
        ylabel('4 m S uCTD');
        plot(ylim, ylim, '--','color',rgb('skyblue'));
        title('TSG S corrected to uCTD');
        grid on;
        axis square;
        print(graphdevice,[path_fix_plots '/TSG_S_' cruise graphformat]);
        
        %%% time series
        
        figure; 
        plot(b1.t, ssea_best,'color',rgb('gray'));
        hold on; 
        plot(surface_uCTD.datenum, surface_uCTD.S, b1.t, b1.ssea_s);
        legend('TSG 5 m before','uCTD 4 m','TSG 5 m after');
        grid on;
        ylabel('T^oC')
        xlim([min(b1.t) max(b1.t)]);
        datetick('x','DD','keeplimits');
        title('final seawater S');
        print(graphdevice,[path_fix_plots '/TSG_S_timeseries_' cruise graphformat]);

    end


    %% seawater sigma
    b1.psea_s = sw_pres(ones(length(b1.t),1)*3,b1.lat); % dbar
    b1.rhosea_s = sw_dens(b1.ssea_s,b1.tsea_s,b1.psea_s); % kg / m3
    b10.psea_s = sw_pres(ones(length(b10.t),1)*3,b10.lat); % dbar
    b10.rhosea_s = sw_dens(b10.ssea_s,b10.tsea_s,b10.psea_s); % kg / m3

end

%% rain rate 
% a prior threshold of 0.03 mm/hr was used for ORG... why? Don't think that's necessary. 
% prate(prate<0.03) = 0;     % threshold of 0.03 mm/hr

%%% for ASTraL... all precip is bad :( there wasn't an ORD deployed, so the
%%% data in these columns is basically nonsense? 

%%% reset nan to zero... should already be taken care of in evalflux.m
% good_precip = 1;
% 
% if good_precip == 1
    
    %%% only for using ORG
%     b1.prate = real(b1.prate);
%     bad_prate1 = find(isnan(b1.prate) == 1);
%     disp(['resetting NaN prate 1-min of length = ' sprintf('%i',length(bad_prate1)) ' to zero']);
%     b1.prate(bad_prate1) = 0; % reset nan to 0
%     %%% reset nan to zero... should already be taken care of in evalflux.m
%     b10.prate = real(b10.prate);
%     bad_prate10 = find(isnan(b10.prate) == 1);
%     disp(['resetting NaN prate 10-min of length = ' sprintf('%i',length(bad_prate10)) ' to zero']);
%     b10.prate(bad_prate10) = 0; % reset nan to 0
%     
%     %%% redo paccum for full cruise of data
%     temp = b1.prate;
%     temp(isnan(temp)) = 0;
%     b1.paccum = cumsum(temp)/60; % 60 min per hour
% 
%     temp = b1.prate_s;
%     temp(isnan(temp)) = 0;
%     b1.paccum_s = cumsum(temp)/60; % 60 min per hour
% 
%     temp = b10.prate;
%     temp(isnan(temp)) = 0;
%     b10.paccum = cumsum(temp)/6; % 6 x 10 min per hour
% 
%     temp = b10.prate_s;
%     temp(isnan(temp)) = 0;
%     b10.paccum_s = cumsum(temp)/6; % 6 x 10 min per hour

% else
%     b1.prate = b1.t*nan;
%     b1.paccum = b1.t*nan;
%     b1.orgV = b1.t*nan;
%     b1.orgV_desp = b1.t*nan;
%     b1.prate_orig = b1.t*nan;
%     
%     b10.prate = b10.t*nan;
%     b10.paccum = b10.t*nan;
%     b10.orgV = b10.t*nan;
%     b10.orgV_desp = b10.t*nan;
%     b10.prate_orig = b10.t*nan;
% end


plot_rain = 0;
if plot_rain == 1
    
    figure;
    subplot(2,2,1);
    plot(b1.t, b1.paccum,'o', b10.t, b10.paccum,'x'); 
    legend('1-min','10-min','location','northwest');
    title('NOAA');
    ymax_noaa = max(b1.paccum);
    datetick('x','dd'); grid on; ylabel('\Sigma Precip (mm)');
    subplot(2,2,2);
    plot(b1.t, b1.paccum_s,'o', b10.t, b10.paccum_s,'x'); 
    ylim([0 ymax_noaa]);
    legend('1-min','10-min','location','northwest');
    title('ship');
    datetick('x','dd'); grid on; ylabel('\Sigma Precip (mm)');

    subplot(2,2,3);
    plot(b1.t, b1.prate,'o', b10.t, b10.prate,'x'); 
    legend('1-min','10-min','location','northwest');
    title('NOAA');
    ymax_noaa = max(b1.prate);
    datetick('x','dd'); grid on; ylabel('P rate (mm/hr)');
    subplot(2,2,4);
    plot(b1.t, b1.prate_s,'o', b10.t, b10.prate_s,'x'); 
    ylim([0 ymax_noaa]);
    legend('1-min','10-min','location','northwest');
    title('ship');
    datetick('x','dd'); grid on; ylabel('P rate (mm/hr)');

    print(graphdevice,[path_fix_plots '/rain_' cruise graphformat]);

end

%% fill missing holes in snake with adjusted ROSR or TSG if needed
% % would need to use something like the below code, except with
% corrections for cool skin and warm layer as applicable
% b1.tsnk_best = b1.tsnk;
% b10.tsnk_best = b10.tsnk;

% % choose what to fill the holes in the snake with ROSR - cool skin
% fill_snk = 'rosr';
% if strcmp(fill_snk,'rosr') == 1
%     wh_bad_snk_good_rosr = find(isnan(b1.tsnk) == 1 & isfinite(SSST1) == 1);
%     tsnk_best_rosr = SSST1 + b1.dt_skin;
%     b1.tsnk_best(wh_bad_snk_good_rosr) = tsnk_best_rosr(wh_bad_snk_good_rosr);
%     
%     wh_bad_snk_good_rosr = find(isnan(b10.tsnk) == 1 & isfinite(b10.tskin) == 1);
%     tsnk_best_rosr = b10.tskin + b10.dt_skin;
%     b10.tsnk_best(wh_bad_snk_good_rosr) = tsnk_best_rosr(wh_bad_snk_good_rosr);
%     
% elseif strcmp(fill_snk,'tsgs') == 1
%     wh_bad_snk_good_tsg = find(isnan(b1.tsnk) == 1 & isfinite(b1.Ttsg_s) == 1);
%     b1.tsnk_best(wh_bad_snk_good_tsg) = b1.Ttsg_s(wh_bad_snk_good_tsg);
%     
%     wh_bad_snk_good_tsg = find(isnan(b10.tsnk) == 1 & isfinite(b10.Ttsg_s) == 1);
%     b10.tsnk_best(wh_bad_snk_good_tsg) = b10.Ttsg_s(wh_bad_snk_good_tsg);
% end

%% best radiative fluxes and met data... for both b10 and b1

% Radiometer Clean... local time I think? 
% June 16, 12:26-12:29
% June 17 12:45
% June 18, 12:56
% June 19, 12:24
% June 20, 12:33
% June 20, 12:30
% June 22, 12:31
% June 23, 12:13
% June 24, 12:51

sw_dn_mean      = (b1.sw_dn_1   + b1.sw_dn_2)   /2;
sw_dn_mean10    = (b10.sw_dn_1  + b10.sw_dn_2)  /2;
lw_dn_mean      = (b1.lw_dn_1   + b1.lw_dn_2)   /2;
lw_dn_mean10    = (b10.lw_dn_1  + b10.lw_dn_2)  /2;

plot_rad = 1;
if plot_rad == 1
    figure;
    subplot(2,1,1);
    plot(b10.t,b10.sw_dn_1,b10.t,b10.sw_dn_2,b10.t, sw_dn_mean10,'--');
    hold on;
    plot(b10.t,b10.sw_dn_s,'.k');
    grid; ylabel('sw'); datetick('x','dd','keeplimits');
    legend('1','2','mean','ship','location','east outside');
    xlim([t0 tN]);
    
    subplot(2,1,2);
    plot(b10.t,b10.lw_dn_1,b10.t,b10.lw_dn_2,b10.t, lw_dn_mean10,'--');
    hold on;
    plot(b10.t,b10.lw_dn_s,'.k');
    grid; ylabel('lw'); datetick('x','dd','keeplimits');
    legend('1','2','mean','ship','location','east outside');
    xlim([t0 tN]);

    annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
    print(graphdevice,[path_fix_plots '/lw_sw_' cruise graphformat]);
end

b1.sw_dn = sw_dn_mean; % if averaging solar sensors together
b1.lw_dn = lw_dn_mean; % if averaging IR sensors together

b10.sw_dn = sw_dn_mean10; % if averaging solar sensors together
b10.lw_dn = lw_dn_mean10; % if averaging IR sensors together 



%% bad l value from ship data COARE output. Reset to nan.
% bad_L1 = find(b1.L_s > 5e5);
% bad_L10 = find(b10.L_s > 5e5);
% b1.L_s(bad_L1) = nan;
% b10.L_s(bad_L10) = nan;

%% missing PSL data.... no missing PSL data 
wh_no_tsnk = find(isnan(b1.tsnk) == 1 & isnan(b1.tsea_s) == 0);
wh_no_ta = find(isnan(b1.ta) == 1 & isnan(b1.ta_s) == 0);
wh_no_rh = find(isnan(b1.rh) == 1 & isnan(b1.rh_s) == 0);
wh_no_psealevel = find(isnan(b1.psealevel) == 1 & isnan(b1.psealevel_s) == 0);
wh_no_wspd = find(isnan(b1.wspd) == 1 & isnan(b1.wspd_s) == 0);
wh_no_wdir = find(isnan(b1.wdir) == 1 & isnan(b1.wdir_s) == 0);
wh_no_rspd = find(isnan(b1.rspd) == 1 & isnan(b1.rspd_s) == 0);
wh_no_rdir = find(isnan(b1.rdir) == 1 & isnan(b1.rdir_s) == 0);
wh_no_lat = find(isnan(b1.lat) == 1 & isnan(b1.lat_s) == 0);
wh_no_lon = find(isnan(b1.lon) == 1 & isnan(b1.lon_s) == 0);
wh_no_hed = find(isnan(b1.hed) == 1 & isnan(b1.hed_s) == 0);
wh_no_cog = find(isnan(b1.cog) == 1 & isnan(b1.cog_s) == 0);
wh_no_sog = find(isnan(b1.sog) == 1 & isnan(b1.sog_s) == 0);
 
% b1.ta_best = b1.ta;
% b1.ta_best(wh_no_ta) = b1.ta_s;
% 
% b1.rh_best = b1.rh;
% b1.rh_best(wh_no_rh) = b1.rh_s;
% 
% b1.slp_best = b1.slp;
% b1.slp_best(wh_no_slp) = b1.slp_s;
% 
% b1.wspd_best = b1.wspd;
% b1.wspd_best(wh_no_wspd) = b1.wspd_s;
% 
% b1.rspd_best = b1.rspd;
% b1.rspd_best(wh_no_rspd) = b1.rspd_s;
% 
% b1.wdir_best = b1.wdir;
% b1.wdir_best(wh_no_wdir) = b1.wdir_s;
% 
% b1.rdir_best = b1.rdir;
% b1.rdir_best(wh_no_rdir) = b1.rdir_s;

%% currents and wind speed relative to water
doing_currents = 0;
if doing_currents == 1
%%% true = relative to fixed earth coords (from gps)
%%% true_sfc = relative to ocean (from spdlog and/or currents)
%%% odec was a true ship log for speed, not used anymore. New ships have
%%% speed log though.

% note... data are not good prior to 1500 on the 10th ... or 00 Z on 11th
% can't tell exactly. 


% wind direction toward, for reference
wdir_toward = b10.wdir+180;
wdir_toward(wdir_toward>360) = wdir_toward(wdir_toward> 360) - 360;

% relative wind direction in 0-360 format
rdir2 = b10.rdir;
rdir2(rdir2<0)=rdir2(rdir2<0)+360;

if have_adcp_data == 1
    cu = interp1(a.t, a.usfc_fill, b1.t);
    cv = interp1(a.t, a.vsfc_fill, b1.t);
    cu_10 = interp1(a.t, a.usfc_fill, b10.t);
    cv_10 = interp1(a.t, a.vsfc_fill, b10.t);
end

% compute surface current from odec, head, sog_ship, cog_ship
% current direction is 'toward' = oceanographic convention, or like the
% vector would appear

%%% check to make sure the signs and equations are correct? 

if have_adcp_data == 1
    [cspd_adcp, cdir_adcp] = uv_to_sd_ocean(cu, cv);
    [cspd_adcp_10, cdir_adcp_10] = uv_to_sd_ocean(cu_10, cv_10);
end

[cspd_spdlog,cdir_spdlog]         = current(b1.spdlog_s,b1.hed,b1.sog,b1.cog);
[cspd_spdlog_10,cdir_spdlog_10]   = current(b10.spdlog_s,b10.hed,b10.sog,b10.cog);

wh_bad_cspd_spdlog = find(cspd_spdlog > 5);
wh_bad_cspd_spdlog_10 = find(cspd_spdlog_10 > 5);
cspd_spdlog(wh_bad_cspd_spdlog) = nan;
cdir_spdlog(wh_bad_cspd_spdlog) = nan;
cspd_spdlog_10(wh_bad_cspd_spdlog_10) = nan;
cdir_spdlog_10(wh_bad_cspd_spdlog_10) = nan;

% use spdlog as main version, but fill gaps from adcp. If further gaps are
% there, could just use regular wind speed and direction... ? 
cspd = cspd_spdlog; 
wh_bad_spdlog = find(isnan(cspd_spdlog) == 1);

cspd_10 = cspd_spdlog_10; 
wh_bad_spdlog_10 = find(isnan(cspd_spdlog_10) == 1);

cdir = cdir_spdlog; 
wh_bad_spdlog_dir = find(isnan(cdir_spdlog) == 1);

cdir_10 = cdir_spdlog_10; 
wh_bad_spdlog_dir_10 = find(isnan(cdir_spdlog_10) == 1);

if have_adcp_data == 1 %%% fill missing with adcp?
    cspd(wh_bad_spdlog) = cspd_adcp(wh_bad_spdlog);
    cspd_10(wh_bad_spdlog_10) = cspd_adcp_10(wh_bad_spdlog_10);
    cdir(wh_bad_spdlog_dir) = cdir_adcp(wh_bad_spdlog_dir);
    cdir_10(wh_bad_spdlog_dir_10) = cdir_adcp_10(wh_bad_spdlog_dir_10);
else %%% just use linear interpolation
    cspd = fillmissing(cspd,'linear','endvalues','none');
    cspd_10 = fillmissing(cspd_10,'linear','endvalues','none');
    cdir = fillmissing(cdir,'linear','endvalues','none');
    cdir_10 = fillmissing(cdir_10,'linear','endvalues','none');
end

disp(['missing 1 min cspd = ' sprintf('%i',length(find(isnan(cspd) == 1)))]);
disp(['missing 1 min cdir = ' sprintf('%i',length(find(isnan(cdir) == 1)))]);
disp(['missing 10 min cspd = ' sprintf('%i',length(find(isnan(cspd_10) == 1)))]);
disp(['missing 10 min cdir = ' sprintf('%i',length(find(isnan(cdir_10) == 1)))]);

plot_current = 0;
if plot_current == 1
    figure;
    subplot(1,2,1); hold on;
    plot(b1.t, cspd_spdlog,'x');
    legend('SPEED LOG');
    if have_adcp_data == 1
        hold on;
        plot(b1.t, cspd_adcp,'o');
        legend('SPEED LOG','ADCP');
    end
    xlim([min(b1.t) max(b1.t)]);
    datetick('x','DD','keeplimits'); grid on;
    ylabel('current speed, m/s');
    title(ptitle)

    subplot(1,2,2); hold on;
    plot(b1.t, cdir_spdlog,'x');
    xlim([min(b1.t) max(b1.t)]);
    legend('SPEED LOG');
    if have_adcp_data == 1
        hold on;
        plot(b1.t, cdir_adcp,'o');
        legend('SPEED LOG','ADCP');
    end
    datetick('x','DD','keeplimits'); grid on;
    ylabel('current dir, ^o');
    print(graphdevice,[path_fix_plots '/currents_' cruise graphformat]);

    if have_adcp_data == 1
        figure;
        subplot(1,2,1);
        plot(cspd_adcp,cspd_spdlog,'.k');
        hold on; plot([0 1.4],[0 1.4],'--y');
        datetick('x','DD','keeplimits'); grid on; axis square;
        xlabel('ADCP');
        ylabel('SPEED LOG');
        title('current speed, m/s');

        subplot(1,2,2);
        plot(cdir_adcp,cdir_spdlog,'.k');
        hold on; plot([0 360],[0 360],'--y');
        grid on; axis square;
        xlabel('ADCP');
        ylabel('SPEED LOG');
        title('current dir, ^o');
        print(graphdevice,[path_fix_plots '/currents_scatter' cruise graphformat]);
    end
    
    figure;
    subplot(1,2,1);
    plot(b10.t, cdir_10, 'o',b10.t, rdir2, 'x', b10.t, wdir_toward,'.');
    legend('cdir toward','rdir','wdir toward');
    grid on;
    xlim([min(b1.t) max(b1.t)]);
    datetick('x','DD','keeplimits');
    
    subplot(1,2,2);
    plot(cdir_10,rdir2, 'x', cdir_10, wdir_toward,'o');
    legend('rdir','wdir toward');
    xlabel('cdir ^o');
    grid on;
    
    print(graphdevice,[path_fix_plots '/currents_dir_' cruise graphformat]);
    
end


% sub function current wasnt working because of dimensions so I changed the function by: * -> .*
% this is how we get cspd and cdir from topmost level of ADCP
% compute wind w/respect to moving surface
[wspd_sfc,wdir_sfc] = wind_current_adjust(b1.wspd,b1.wdir,cspd,cdir);
[wspd_sfc_spdlog,wdir_sfc_spdlog] = wind_current_adjust(b1.wspd,b1.wdir,cspd_spdlog,cdir_spdlog);

[wspd_sfc_10,wdir_sfc_10] = wind_current_adjust(b10.wspd,b10.wdir,cspd_10,cdir_10);
[wspd_sfc_spdlog_10,wdir_sfc_spdlog_10] = wind_current_adjust(b10.wspd,b10.wdir,cspd_spdlog_10,cdir_spdlog_10);

if have_adcp_data == 1
    [wspd_sfc_adcp,wdir_sfc_adcp] = wind_current_adjust(b1.wspd,b1.wdir,cspd_adcp,cdir_adcp);
    [wspd_sfc_adcp_10,wdir_sfc_adcp_10] = wind_current_adjust(b10.wspd,b10.wdir,cspd_adcp_10,cdir_adcp_10);
end

% there's some weird data filling or rounding or interp error going on
% where there are no cspd or cdir data. So, reset those back to just wspd
% and wdir as the first guess. 
wspd_sfc(find(isnan(cspd)==1)) = b1.wspd(find(isnan(cspd)==1));
wdir_sfc(find(isnan(cspd)==1)) = b1.wdir(find(isnan(cdir)==1));


plot_wind_sfc = 0;
if plot_wind_sfc == 1
    
    figure;
    subplot(1,2,1);
    plot(b1.t, wspd_sfc_spdlog,'x',...
        b1.t, wspd_sfc,'o',b1.t, b1.wspd,'.');
    grid on; 
    xlim([min(b1.t) max(b1.t)]);
    datetick('x','DD','keeplimits');
    legend('wspd sfc spdlog','wspd sfc','wspd','location','southoutside');
    if have_adcp_data == 1
        hold on;
        plot(b1.t, wspd_sfc_adcp,'o')
    legend('wspd sfc spdlog','wspd sfc','wspd','wspd sfc adcp','location','southoutside');
    end
    ylabel('wind speed, m/s');
    title(ptitle);

    subplot(1,2,2);
    plot(b1.t, wdir_sfc_spdlog,'x',...
        b1.t, wdir_sfc,'o',b1.t, b1.wdir,'.');
    grid on;
    xlim([min(b1.t) max(b1.t)]);
    datetick('x','DD','keeplimits');
    legend('wdir sfc spdlog','wdir sfc','wdir','location','southoutside');
    if have_adcp_data == 1
        hold on;
        plot(b1.t, wdir_sfc_adcp,'o');
    legend('wdir sfc spdlog','wdir sfc','wdir','wdir sfc adcp','location','southoutside');
    end
    ylabel('wind dir, ^o');
    print(graphdevice,[path_fix_plots '/wind_sfc_' cruise graphformat]);

    figure;
    subplot(1,2,1);
    plot(b1.wspd, wspd_sfc_spdlog,'x', ... 
        b1.wspd, wspd_sfc, '.');
    hold on;
    plot([0 18],[0 18],'--k');
    grid on;
    xlabel('original wind speed m/s');
    ylabel('adjusted');
    legend('wspd sfc spdlog','wspd sfc','location','northwest');
    if have_adcp_data == 1
        hold on;
        plot(b1.wspd, wspd_sfc_adcp, 'o');
    legend('wspd sfc spdlog','wspd sfc','wspd sfc adcp','location','northwest');
    end
    
    title(ptitle);
    subplot(1,2,2);
    plot(b1.wdir, wdir_sfc_spdlog,'x', ...
                b1.wdir, wdir_sfc, '.');
    hold on;
    plot([0 360],[0 360],'--k');
    grid on;
    xlabel('original wind dir, ^o');
    ylabel('adjusted');
    legend('wdir sfc spdlog','wdir sfc','location','northwest');
    if have_adcp_data == 1
        hold on;
        plot(b1.wdir, wdir_sfc_adcp, 'o');
        legend('wdir sfc spdlog','wdir sfc','wdir sfc adcp','location','northwest');
    end
    print(graphdevice,[path_fix_plots '/wind_sfc_scatter_' cruise graphformat]);


    figure;
    plot(b1.t, cspd_spdlog,'x',...
        b1.t, cspd,'s', b1.t, b1.wspd/10,'.');
    xlim([min(b1.t) max(b1.t)]);
    datetick('x','dd','keeplimits');
    grid on;
    title(ptitle);
    ylabel('m/s');
    legend('cspd spdlog','cspd','wspd / 10','location','southoutside');
    if have_adcp_data == 1
        hold on;
        plot(b1.t, cspd_adcp,'o');
    legend('cspd spdlog','cspd','wspd / 10','cspd adcp','location','southoutside');
    end
    print(graphdevice,[path_fix_plots '/wind_current_' cruise graphformat]);

end

% add adcp data to structure
if have_adcp_data == 1
    b1.cspd_adcp = cspd_adcp;
    b10.cspd_adcp = cspd_adcp_10;
    b1.cdir_adcp = cdir_adcp;
    b10.cdir_adcp = cdir_adcp_10;
    b1.cspd_u_adcp = cu;
    b1.cspd_v_adcp = cv;
    b10.cspd_u_adcp = cu_10;
    b10.cspd_v_adcp = cv_10;
end

% and/or add spd log current to structure
b1.cspd_spdlog = cspd_spdlog;
b10.cspd_spdlog = cspd_spdlog_10;
b1.cdir_spdlog = cdir_spdlog;
b10.cdir_spdlog = cdir_spdlog_10;

b1.cspd = cspd;
b10.cspd = cspd_10;
b1.cdir = cdir;
b10.cdir = cdir_10;

b1.wspd_sfc = wspd_sfc; 
b1.wdir_sfc = wdir_sfc;
b10.wspd_sfc = wspd_sfc_10; 
b10.wdir_sfc = wdir_sfc_10;

%%% We think cspd/cdir from spdlog is superior for final dataset because
%%% it is more representative of the surface waters than the water sensed
%%% by the ADCP at 10-14 m (10.1, 12.1, 14.1)
else
    b1.wspd_sfc = b1.wspd; 
    b1.wdir_sfc = b1.wdir;
    b10.wspd_sfc = b10.wspd; 
    b10.wdir_sfc = b10.wdir;  
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%% wspd sfc: use spd log version, with gaps
%%%%%%%%%%%%%%%%%%%%%%%%%%%% filled by ADCP.

%% adjust licor variables if updates to qa or ta are performed, or if bad data are found

% Licor Clean... local time I think? 
% June 15, 1200ish 
% June 16, 12:22
% June 17, 12:41
% June 18, 12:50
% June 19, 12:20
% June 20, 12:30
% June 21, 12:33
% June 22, 12:26
% June 23, 12:10
% June 24, 12:49


%%% from da_red... do not change coefficients
agc_lim     = 60;   % max agc limit
CO2_LoLim   = 350;  % min CO2 ppm
CO2_HiLim   = 450;  % max CO2 ppm
sigCO2_lim  = 20;   % max sigma CO2
q_lic_LoLim = 0.1;  % min q licor
q_lic_HiLim = 26;   % max q licor
q_std_LoLim  = 0;    % min sigma q licor
q_std_HiLim  = 3;    % max sigma q licor

clear ii; 
ii = find(b10.licor_agc>agc_lim | b10.licor_qa<q_lic_LoLim | b10.licor_qa>q_lic_HiLim); 
ii1 = find(b1.licor_agc>agc_lim | b1.licor_qa<q_lic_LoLim | b1.licor_qa>q_lic_HiLim); 
%     usually we also look for.... find(b10.licor_qa_std>q_std_HiLim | b10.licor_qa_std<q_std_LoLim);
% if strcmp(cruise,'ASTRAL_2023') == 1
% %    iii = find(b10.t > bad_licor_day);
%    ii = unique([ii; iii]);
% end

% %%% special --> save these updates too
b10.licor_qa(ii) = nan;
b1.licor_qa(ii1) = nan;

%%% some more bad data, who knows why? 
% bad_licor_1 = find(b1.t < datenum(2023,6,15,7,30,0));
% bad_licor_10 = find(b10.t < datenum(2023,6,15,7,30,0));
% b1.licor_qa(bad_licor_1) = nan;
% b10.licor_qa(bad_licor_10) = nan;
% b1.licor_rh(bad_licor_1) = nan;
% b10.licor_rh(bad_licor_10) = nan;
% b1.licor_rhoa_dry(bad_licor_1) = nan;
% b10.licor_rhoa_dry(bad_licor_10) = nan;
% b1.licor_qa_dry(bad_licor_1) = nan;
% b10.licor_qa_dry(bad_licor_10) = nan;
% b1.licor_tbox(bad_licor_1) = nan;
% b10.licor_tbox(bad_licor_10) = nan;
% b1.licor_pbox(bad_licor_1) = nan;
% b10.licor_pbox(bad_licor_10) = nan;
% b1.licor_h2o(bad_licor_1) = nan;
% b10.licor_h2o(bad_licor_10) = nan;
% b1.licor_h2o_mr(bad_licor_1) = nan;
% b10.licor_h2o_mr(bad_licor_10) = nan;
% b1.licor_co2(bad_licor_1) = nan;
% b10.licor_co2(bad_licor_10) = nan;
% b1.licor_co2_mr(bad_licor_1) = nan;
% b10.licor_co2_mr(bad_licor_10) = nan;



plot_licor = 1;
if plot_licor == 1
    figure;
    subplot(2,1,1); 
        plot(b10.t,b10.qa,'or',b10.t,b10.licor_qa,'xk',b10.t,b10.qa_s,'.b'); grid; xlim([t0 tN]);
        ylabel('q, g kg^{-1}'); datetick('x','dd','keeplimits');
        title([ptitle,' specific humidity']);
        legend('Vaisala','Licor','ship','location','best');
    subplot(2,1,2);
        plot(b10.t,b10.licor_agc,'.r',[t0,tN],[agc_lim,agc_lim],'g--',[t0,tN],[50,50],'g-');
        grid; ylabel('agc'); datetick('x','dd','keeplimits');
        ylim([48,100]); xlim([t0 tN]);
    %     if strcmp(cruise,'ASTRAL_2023') == 1
    %        hold on;
    % %        plot([bad_licor_day bad_licor_day], ylim,'--k');
    % %        text(bad_licor_day-0.25, agc_lim, 'bad after this point',...
    % %            'rotation',90,'fontweight','bold','fontsize',16);
    %     end
        legend('Licor agc','agc Limit','agc = 50','location','northoutside','orientation','horizontal');
    annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 27'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
    print(graphdevice,[path_fix_plots '/licor_qa_' cruise graphformat]);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fix_humidities = 0;
plot_rh = 0;
if fix_humidities == 1
    
    disp('fixing humidity values across sensors');
    
    rhscale = [70 90];
    qascale = [15.5 19];

    % do this at 10-min resolution
    timerhl = find(b10.t > datenum(2023,6,15,20,0,0) & b10.t < datenum(2023,6,20,0,0,0));
    timerhv = find(b10.t < datenum(2023,6,21,0,0,0));
    

    %%% do this at 1-min resolution
    timerhv_bad = find(b1.t >= datenum(2023,6,21,6,50,0));
    timerhv_bad1 = find(b1.t >= datenum(2023,6,15,7,5,0) & b1.t <= datenum(2023,6,15,7,9,0));
    timerhv_bad2 = find(b1.t >= datenum(2023,6,15,7,9,0) & b1.t <= datenum(2023,6,15,7,30,0));
    timerhw1 = find(b1.t > datenum(2023,6,21,7,3,0) & b1.t < datenum(2023,6,21,7,32,0));
    timerhw2 = find(b1.t > datenum(2023,6,21,14,25,0) & b1.t < datenum(2023,6,21,14,38,0));
    timerhw3 = find(b1.t > datenum(2023,6,22,6,52,0) & b1.t < datenum(2023,6,22,7,28,0));
    timerhw4 = find(b1.t > datenum(2023,6,23,6,36,0) & b1.t < datenum(2023,6,23,6,58,0));
    timerhw5 = find(b1.t > datenum(2023,6,24,7,17,0) & b1.t < datenum(2023,6,24,7,25,0));
    
    timerhw = [timerhw1;timerhw2;timerhw3;timerhw4;timerhw5];
    
    
    %%% v 3.6 for PSL data... using TSG because there's more of it. 
    ref = 2;
    disp('running COARE: Vaisala');
    Av=coare36vnWarm_et(b10.jd, b10.wspd_sfc, zu, b10.ta, zt, b10.rh, zq, b10.psealevel, b10.tsea_s, b10.sw_dn, b10.lw_dn, b10.lat, b10.lon, 600, b10.prate, zsea_ship, b10.ssea_s, nan, nan, ref, ref, ref);
    disp('running COARE: licor');
    Al=coare36vnWarm_et(b10.jd, b10.wspd_sfc, zu, b10.ta, zt, b10.licor_rh, zlic, b10.psealevel, b10.tsea_s, b10.sw_dn, b10.lw_dn, b10.lat, b10.lon, 600, b10.prate, zsea_ship, b10.ssea_s, nan, nan, zq, zq, zq);
    disp('running COARE: ship');
    Ash=coare36vnWarm_et(b10.jd, b10.wspd_sfc, zu, b10.ta, zt, b10.rh_s, zq_ship, b10.psealevel, b10.tsea_s, b10.sw_dn, b10.lw_dn, b10.lat, b10.lon, 600, b10.prate, zsea_ship, b10.ssea_s, nan, nan, ref, ref, ref);

    cfields = {'usr';'tau';'hs';'hl';'hb';'hb_son';'hlwebb';'tsr';'qsr';'zo';'zot';'zoq';...
    'cd';'ch';'ce';'l';'zeta';'dt_skin';'dq_skin';'dz_skin';'u2';'ta2';'qa2';...
    'rh2';'u2n';'ta2n';'qa2n';'lw_net';'sw_net';'le';'rhoa';'un';'u10';'u10n';'cdn10';'chn10';'cen10';...
    'hrain';'qs';'erate';'ta10';'ta10n';'qa10';'qa10n';'rh10';'pa10';'rhoa10';'gust';'wc_frac';'edis';...
    'dt_warm';'dz_warm';'dt_warm_to_skin';'du_warm'};

for i = 1:length(cfields)
    eval([cfields{i} '_v = Av(:,i);']);
    eval([cfields{i} '_l = Al(:,i);']);
    eval([cfields{i} '_sh = Ash(:,i);']);
end


%     timerh_bad2 = find(b1.t >= datenum(2023,6,15,6,30,0) & b1.t <= datenum(2023,6,15,7,30,0));
       
    if plot_rh == 1
        %%% time series
        figure; 
        plot(b10.t, rh10_l, b10.t, rh10_sh, b10.t, rh10_v);
        legend('Licor','ship','Vaisala','location','north');
        title('RH % @ 10 m');
        ylim([60 100]);
        grid on;
        xlim([min(b10.t) max(b10.t)]);
        datetick('x','DD','keeplimits');
        print(graphdevice,[path_fix_plots '/rh10_time_before_' cruise graphformat]);
        
        figure; 
        plot(b10.t, qa10_l, b10.t, qa10_sh, b10.t, qa10_v);
        legend('Licor','ship','Vaisala','location','north');
        title('qa g/kg @ 10 m');
        ylim([15 26.5]);
        grid on;
        xlim([min(b10.t) max(b10.t)]);
        datetick('x','DD','keeplimits');
        print(graphdevice,[path_fix_plots '/qa10_time_before_' cruise graphformat]);
        
        
                %%% time series
        figure; 
        plot(b1.t, b1.licor_rh, b1.t, b1.rh_s, b1.t, b1.rh);
        legend('Licor corrected by Vaisala','ship corrected by Vaisala','Vaisala corrected by Licor','location','north');
        title('RH % @ instrument height');
        grid on;
        ylim([60 100]);
        xlim([min(b10.t) max(b10.t)]);
        datetick('x','DD','keeplimits');
        print(graphdevice,[path_fix_plots '/rh_time_correct_' cruise graphformat]);

        figure; 
        plot(b1.t, b1.licor_qa, b1.t, b1.qa_s, b1.t, b1.qa);
        legend('Licor corrected by Vaisala','ship corrected by Vaisala','Vaisala corrected by Licor','location','north');
        title('qa g/kg @ instrument height');
        ylim([15 26.5]);
        grid on;
        xlim([min(b10.t) max(b10.t)]);
        datetick('x','DD','keeplimits');
        print(graphdevice,[path_fix_plots '/qa_time_correct_' cruise graphformat]);

        
        %%% scatter 
        
        figure('position',[1,1,1200,450]);
        subplot(1,3,1);
        plot(rh10_l(timerhl), rh10_v(timerhl),'.');
        hold on; plot(rhscale, rhscale, '-y');
        xlabel('licor');
        ylabel('vaisala');
        axis square; grid on;
        xlim(rhscale); ylim(xlim);

        subplot(1,3,2);
        plot(rh10_l(timerhl), rh10_sh(timerhl),'.');
        hold on; plot(rhscale, rhscale, '-y');
        xlabel('licor');
        ylabel('ship');
        axis square; grid on;
        xlim(rhscale); ylim(xlim);
        title('ASTRAL 2023 rh before @ 10 m');
        
        subplot(1,3,3);
        plot(rh10_v(timerhv), rh10_sh(timerhv),'.');
        hold on; plot(rhscale, rhscale, '-y');
        xlabel('vaisala');
        ylabel('ship');
        axis square; grid on;
        xlim(rhscale); ylim(xlim);
        
        print(graphdevice,[path_fix_plots '/rh10_scatter_before_' cruise graphformat]);

    end
    

    % correct licor with vaisala
    lic_prior_qa = qa10_l;
    rh_offsets_lv = rh10_l(timerhl) - rh10_v(timerhl);
    rh_med_off_lv = nanmedian(rh_offsets_lv);
    licor_rh_v = rh10_l - rh_med_off_lv;
    b1.licor_rh = b1.licor_rh - rh_med_off_lv;
    b10.licor_rh = interval_avg_var(b1.jd, b1.licor_rh, jd_10bin);
   
    
    
    pa_at_lic = nanmedian(b1.psealevel - 0.125*zlic);
    b1.licor_qa = qair_p(b1.ta, b1.licor_rh,pa_at_lic);
    b10.licor_qa = qair_p(b10.ta, b10.licor_rh, pa_at_lic);
    
    mean_licor_offset = nanmedian(lic_prior_qa - b10.licor_qa);
    disp(['mean licor offset to subtract in motcorr = ' sprintf('%f',mean_licor_offset)]);
    % % correct licor with ship?
    % rh_offsets_ls = b1.licor_rh(timerhl) - b1.rh_s(timerhl);
    % rh_med_off_ls = nanmedian(rh_offsets_ls);
    % licor_rh_s = b1.licor_rh - rh_med_off_ls;

%     % correct ship rh qith vaisala
%     rh_offsets_vs = b1.rh_s(timerhv) - b1.rh(timerhv);
%     rh_med_off_vs = nanmedian(rh_offsets_vs);
%     s_rh_v = b1.rh_s - rh_med_off_vs;
%     b1.rh_s = s_rh_v;
%     b10.rh_s = interval_avg_var(b1.jd, b1.rh_s, jd_10bin);

    % correct ship rh qith vaisala
    rh_offsets_vs = rh10_sh(timerhv) - rh10_v(timerhv);
    rh_med_off_vs = nanmedian(rh_offsets_vs);
    s_rh_v = rh10_sh - rh_med_off_vs;
    b1.rh_s = b1.rh_s - rh_med_off_vs;
    b10.rh_s = interval_avg_var(b1.jd, b1.rh_s, jd_10bin);
   
    b1.qa_s = qair_p(b1.ta_s,b1.rh_s,b1.pa_at_zq_s);
    b10.qa_s = qair_p(b10.ta_s,b10.rh_s,b10.pa_at_zq_s);
    b1.rhoa_s = air_density(b1.ta_s,b1.pa_at_zq_s,b1.rh_s);
    b10.rhoa_s = air_density(b10.ta_s,b10.pa_at_zq_s,b10.rh_s);
    b1.h2o_s = b1.qa_s.*b1.rhoa_s/0.018016;
    b10.h2o_s = b10.qa_s.*b10.rhoa_s/0.018016;
    
    
    % fill bad vaisala time with corrected licor and corrected ship
    v_rh_l = b1.rh;
    v_rh_l(timerhv_bad) = b1.licor_rh(timerhv_bad);
    b1.rh = v_rh_l;
    pa_at_zq = nanmedian(b1.psealevel - 0.125*zq);
    
    b1.rh(timerhv_bad1) = nan;
    b1.rh(timerhv_bad2) = b1.licor_rh(timerhv_bad2);
    b1.rh(timerhw) = nan;
%     b1.rh = fillmissing(b1.rh,'linear');
    
    b10.rh = interval_avg_var(b1.jd, b1.rh, jd_10bin);
    b1.rhoa = air_density(b1.ta,pa_at_zq,b1.rh);
    b10.rhoa = air_density(b10.ta,pa_at_zq,b10.rh);
    b1.qa = qair_p(b1.ta,b1.rh,pa_at_zq);
    b10.qa = qair_p(b10.ta,b10.rh,pa_at_zq);
    b1.h2o = b1.qa.*b1.rhoa/0.018016;
    b10.h2o = interval_avg_var(b1.jd, b1.h2o, jd_10bin);
      


    disp('running COARE: Vaisala corrected');
    Avc=coare36vnWarm_et(b10.jd, b10.wspd_sfc, zu, b10.ta, zt, b10.rh, zq, b10.psealevel, b10.tsea_s, b10.sw_dn, b10.lw_dn, b10.lat, b10.lon, 600, b10.prate, zsea_ship, b10.ssea_s, nan, nan, ref, ref, ref);
    disp('running COARE: licor corrected');
    Alc=coare36vnWarm_et(b10.jd, b10.wspd_sfc, zu, b10.ta, zt, b10.licor_rh, zlic, b10.psealevel, b10.tsea_s, b10.sw_dn, b10.lw_dn, b10.lat, b10.lon, 600, b10.prate, zsea_ship, b10.ssea_s, nan, nan, zq, zq, zq);
    disp('running COARE: ship corrected');
    Ashc=coare36vnWarm_et(b10.jd, b10.wspd_sfc, zu, b10.ta, zt, b10.rh_s, zq_ship, b10.psealevel, b10.tsea_s, b10.sw_dn, b10.lw_dn, b10.lat, b10.lon, 600, b10.prate, zsea_ship, b10.ssea_s, nan, nan, ref, ref, ref);

    cfields = {'usr';'tau';'hs';'hl';'hb';'hb_son';'hlwebb';'tsr';'qsr';'zo';'zot';'zoq';...
    'cd';'ch';'ce';'l';'zeta';'dt_skin';'dq_skin';'dz_skin';'u2';'ta2';'qa2';...
    'rh2';'u2n';'ta2n';'qa2n';'lw_net';'sw_net';'le';'rhoa';'un';'u10';'u10n';'cdn10';'chn10';'cen10';...
    'hrain';'qs';'erate';'ta10';'ta10n';'qa10';'qa10n';'rh10';'pa10';'rhoa10';'gust';'wc_frac';'edis';...
    'dt_warm';'dz_warm';'dt_warm_to_skin';'du_warm'};

for i = 1:length(cfields)
    eval([cfields{i} '_vc = Avc(:,i);']);
    eval([cfields{i} '_lc = Alc(:,i);']);
    eval([cfields{i} '_shc = Ashc(:,i);']);
end


%%% this didn't work
% v_qa_lc = b1.qa;
% qa_med_offsets_vlend = v_qa_lc(timeqav_badbuff) - licor_qa_v(timeqav_badbuff);
% qa_med_off_vlend = nanmedian(qa_med_offsets_vlend);
% v_qa_lc(timeqav_badbuff) = v_qa_lc(timeqav_badbuff)- qa_med_off_vlend;
% va_qa_lc(timeqav_between) = licor_qa_v(timeqav_between);

%%% save all new 1 min data and interpolate all to 10 min

if plot_rh == 1
    
    %%% time series
    figure; 
    plot(b10.t, rh10_lc, b10.t, rh10_shc, b10.t, rh10_vc);
    legend('Licor corrected by Vaisala','ship corrected by Vaisala','Vaisala corrected by Licor','location','north');
    title('RH % @ 10 m');
    grid on;
    ylim([60 100]);
    xlim([min(b10.t) max(b10.t)]);
    datetick('x','DD','keeplimits');
    print(graphdevice,[path_fix_plots '/rh10_time_correct_' cruise graphformat]);
    
    figure; 
    plot(b10.t, qa10_lc, b10.t, qa10_shc, b10.t, qa10_vc);
    legend('Licor corrected by Vaisala','ship corrected by Vaisala','Vaisala corrected by Licor','location','north');
    title('qa g/kg @ 10 m');
    ylim([15 26.5]);
    grid on;
    xlim([min(b10.t) max(b10.t)]);
    datetick('x','DD','keeplimits');
    print(graphdevice,[path_fix_plots '/qa10_time_correct_' cruise graphformat]);

        %%% time series
    figure; 
    plot(b1.t, b1.licor_rh, b1.t, b1.rh_s, b1.t, b1.rh);
    legend('Licor corrected by Vaisala','ship corrected by Vaisala','Vaisala corrected by Licor','location','north');
    title('RH % @ instrument height');
    grid on;
    ylim([60 100]);
    xlim([min(b10.t) max(b10.t)]);
    datetick('x','DD','keeplimits');
    print(graphdevice,[path_fix_plots '/rh_time_correct_' cruise graphformat]);
    
    figure; 
    plot(b1.t, b1.licor_qa, b1.t, b1.qa_s, b1.t, b1.qa);
    legend('Licor corrected by Vaisala','ship corrected by Vaisala','Vaisala corrected by Licor','location','north');
    title('qa g/kg @ instrument height');
    ylim([15 26.5]);
    grid on;
    xlim([min(b10.t) max(b10.t)]);
    datetick('x','DD','keeplimits');
    print(graphdevice,[path_fix_plots '/qa_time_correct_' cruise graphformat]);

    
    %%% scatter
    
    figure('position',[1,1,1200,450]);
    subplot(1,3,1);
    plot(rh10_lc(timerhl), rh10_vc(timerhl),'.');
    hold on; plot(rhscale, rhscale, '-y');
    xlabel('licor');
    ylabel('vaisala');
    axis square; grid on;
    xlim(rhscale); ylim(xlim);

    subplot(1,3,2);
    plot(rh10_lc(timerhl), rh10_shc(timerhl),'.');
    hold on; plot(rhscale, rhscale, '-y');
    xlabel('licor');
    ylabel('ship');
    axis square; grid on;
    xlim(rhscale); ylim(xlim);
    title('ASTRAL 2023 rh corrected @ 10 m');
    
    subplot(1,3,3);
    plot(rh10_vc, rh10_shc,'.');
    hold on; plot(rhscale, rhscale, '-y');
    xlabel('vaisala');
    ylabel('ship');
    axis square; grid on;
    xlim(rhscale); ylim(xlim);

    print(graphdevice,[path_fix_plots '/rh10_scatter_correct_' cruise graphformat]);
    
end



end

%% redo clear sky values if changes are made to ta or qa, or to tune it locally
%   function coefficients can be tuned for location and aerosol loading
% b10.lw_dn_clr = (.52+.13/60*abs(f10.lat)+(.082-.03/60*abs(f10.lat)).*...
%     sqrt(f10.qa)).*(5.67e-8*(f10.ta+C2K).^4);

b10.sw_dn_clr = rs_clear(b10.jd,nanmean(b10.psealevel),b10.qa,b10.lat,b10.lon,k1,k2,oz);
b1.sw_dn_clr = rs_clear(b1.jd,nanmean(b1.psealevel),b1.qa,b1.lat,b1.lon,k1,k2,oz);

b10.lw_dn_clr = (0.52+0.13/60*abs(b10.lat)+(0.082-0.03/60.*abs(b10.lat)).*sqrt(b10.qa)).*(5.67e-8*(b10.ta+273.15).^4);
b1.lw_dn_clr = (0.52+0.13/60*abs(b1.lat)+(0.082-0.03/60.*abs(b1.lat)).*sqrt(b1.qa)).*(5.67e-8*(b1.ta+273.15).^4);



%% check for missing data

disp(['missing 1 min wspd_sfc = ' sprintf('%i',length(find(isnan(b1.wspd_sfc) == 1)))]);
disp(['missing 1 min wdir_sfc = ' sprintf('%i',length(find(isnan(b1.wdir_sfc) == 1)))]);
disp(['missing 1 min ta = ' sprintf('%i',length(find(isnan(b1.ta) == 1)))]);
disp(['missing 1 min rh = ' sprintf('%i',length(find(isnan(b1.rh) == 1)))]);
disp(['missing 1 min psealevel = ' sprintf('%i',length(find(isnan(b1.psealevel) == 1)))]);
disp(['missing 1 min tsnk = ' sprintf('%i',length(find(isnan(b1.tsnk) == 1)))]);
disp(['missing 1 min sw_dn = ' sprintf('%i',length(find(isnan(b1.sw_dn) == 1)))]);
disp(['missing 1 min lw_dn = ' sprintf('%i',length(find(isnan(b1.lw_dn) == 1)))]);
disp(['missing 1 min prate = ' sprintf('%i',length(find(isnan(b1.prate) == 1)))]);
disp(['missing 1 min ssea_s = ' sprintf('%i',length(find(isnan(b1.ssea_s) == 1)))]);
disp(['missing 1 min wspd_sfc = ' sprintf('%i',length(find(isnan(b1.wspd_sfc) == 1)))]);

disp(['missing 10 min wdir_sfc = ' sprintf('%i',length(find(isnan(b10.wdir_sfc) == 1)))]);
disp(['missing 10 min ta = ' sprintf('%i',length(find(isnan(b10.ta) == 1)))]);
disp(['missing 10 min rh = ' sprintf('%i',length(find(isnan(b10.rh) == 1)))]);
disp(['missing 10 min psealevel = ' sprintf('%i',length(find(isnan(b10.psealevel) == 1)))]);
disp(['missing 10 min tsnk = ' sprintf('%i',length(find(isnan(b10.tsnk) == 1)))]);
disp(['missing 10 min sw_dn = ' sprintf('%i',length(find(isnan(b10.sw_dn) == 1)))]);
disp(['missing 10 min lw_dn = ' sprintf('%i',length(find(isnan(b10.lw_dn) == 1)))]);
disp(['missing 10 min prate = ' sprintf('%i',length(find(isnan(b10.prate) == 1)))]);
disp(['missing 10 min ssea_s = ' sprintf('%i',length(find(isnan(b10.ssea_s) == 1)))]);


%% albedo
% check albedo function for proper year day, units/sign of lon, and lat
check_albedo = 0;
if check_albedo == 1
    % vector version of function
    [alb,T_sw,solarmax_sw,psi_sw] = albedo_vector_test(b10.sw_dn,b10.jd,b10.lon,b10.lat,'E');

    % single value version of function
    alb_k = nan(length(b10.t),1);
    T_sw_k = nan(length(b10.t),1);
    solarmax_sw_k = nan(length(b10.t),1);
    psi_sw_k = nan(length(b10.t),1);

    % single value version of function
    for k = 1:length(b10.t)
        [alb_k(k),T_sw_k(k),solarmax_sw_k(k),psi_sw_k(k)] = albedo_test(b10.sw_dn(k),b10.jd(k),b10.lon(k),b10.lat(k),'E');
    end

    plot_albedo = 0;
    if plot_albedo == 1
        figure; 
        subplot(2,2,1); hold on;
        plot(b10.t, alb); title('albedo');
        plot(b10.t, alb_k,'--');
        plot(b10.t, ones(length(b10.t), 1)*0.055);
        legend('vector function','single value function','constant value 0.0550','position',[0.5,0.5,0.01,0.01]);
        datetick('x','dd'); axis tight;
        subplot(2,2,2); hold on;
        plot(b10.t, T_sw); title('T');
        plot(b10.t, T_sw_k,'--');
        datetick('x','dd'); axis tight;
        subplot(2,2,3); hold on;
        plot(b10.t, solarmax_sw); title('solarmax');
        plot(b10.t, solarmax_sw_k,'--');
        datetick('x','dd'); axis tight;
        subplot(2,2,4); hold on;
        plot(b10.t, psi_sw); title('psi');
        plot(b10.t, psi_sw_k,'--');
        datetick('x','dd'); axis tight;
        print(graphdevice,[path_fix_plots '/albedo_' cruise graphformat]);
    end

end

%% run coare

% testing air-sea temp difference and theta expressions
grav = grv(b10.lat);
lapse=grav/cpa;

P_tq=(b10.psealevel - (0.125*zt));   % P at tq measurement height (mb)

% ta converted to K from sensor height, p in mb, theta in K
theta = (b10.ta+C2K).*(1000./P_tq).^(Rgas/cpa); % potential temp at instrument height in K
tadjK = b10.ta+C2K + lapse*zt; % adjusted temp at instrument height in K
tadj = b10.ta + lapse*zt; % adjusted temp at instrument height in C
theta_sfc = (b10.tskin+C2K).*(1000./b10.psealevel).^(Rgas/cpa); % potential temp surface in K
tadjK_sfc = b10.tskin+C2K; % adjusted temp surface in K
tadj_sfc = b10.tskin; % adjusted temp surface in C

% different versions of differences, of the same type
dtheta = theta_sfc - theta;
dtadjK = tadjK_sfc - tadjK;
dtadj = tadj_sfc - tadj;

% just for fun, mix and match the different types
dtheta_tadjK = theta_sfc - tadjK;
dtadjK_theta = tadjK_sfc - theta;

%%% test plot
plot_theta = 0;
if plot_theta == 1
    figure;
    subplot(2,2,1);
    plot(b10.t, theta, b10.t, tadjK,'--');
    legend('\theta zt','tadjK zt');
    ylabel('K');
    datetick('x','dd');
    grid on;
    
    subplot(2,2,2);
    plot(b10.t, theta_sfc, b10.t, tadjK_sfc,'--');
    legend('\theta SFC','tadjK SFC');
    ylabel('K');
    datetick('x','dd');
    grid on;   
    
    subplot(2,2,3);
    plot(b10.t, dtheta, b10.t, dtadjK,'--',b10.t, dtadj,'.');
    legend('theta sfc - theta zt','tadjK sfc - tadjK zt', 'tadj sfc - tadj zt');
    ylabel('K');
    datetick('x','dd');
    grid on;     
    
    subplot(2,2,4);
    plot(b10.t, dtheta_tadjK, b10.t, dtadjK_theta,'--');
    legend('theta sfc - tadjK zt','tadjK sfc - theta zt');
    ylabel('K');
    datetick('x','dd');
    grid on;         
    
    print(graphdevice,[path_fix_plots '/theta_' cruise graphformat]);
end

ref = 2;
%%% v 3.6 for PSL data

if have_adcp_data == 0
    b10.wspd_sfc = b10.wspd;
end

disp('COARE v3.6 for PSL data no waves');
B=coare36vnWarm_et(b10.jd, b10.wspd_sfc, zu, b10.ta, zt, b10.rh, zq, b10.psealevel, b10.tsnk, b10.sw_dn, b10.lw_dn, b10.lat, b10.lon, 600, b10.prate, zsnk, b10.ssea_s, nan, nan, ref, ref, ref);
% B_nw=coare36vnWarm_et(b10.jd, b10.wspd_sfc, zu, b10.ta, zt, b10.rh, zq, b10.psealevel, b10.tsnk, b10.sw_dn, b10.lw_dn, b10.lat, b10.lon, 600, b10.prate, zsnk, b10.ssea_s, nan, nan, ref, ref, ref);
% disp('COARE v3.6 for PSL data but ship TSG instead of sea snake no waves');
% Ds_nw=coare36vnWarm_et(b10.jd, b10.wspd_sfc, zu, b10.ta, zt, b10.rh, zq, b10.psealevel, b10.tsea_s, b10.sw_dn, b10.lw_dn, b10.lat, b10.lon, 600, b10.prate, zsea_ship, b10.ssea_s, nan, nan, ref, ref, ref);

% disp('COARE v3.6 for PSL data');
% B=coare36vnWarm_et(b10.jd, b10.wspd_sfc, zu, b10.ta, zt, b10.rh, zq, b10.psealevel, b10.tsnk, b10.sw_dn, b10.lw_dn, b10.lat, b10.lon, 600, b10.prate, zsnk, b10.ssea_s, b10.wave_phasespd, b10.wave_sigheight, ref, ref, ref);
% disp('COARE v3.6 for PSL data but ship TSG instead of sea snake');
% Ds=coare36vnWarm_et(b10.jd, b10.wspd_sfc, zu, b10.ta, zt, b10.rh, zq, b10.psealevel, b10.tsea_s, b10.sw_dn, b10.lw_dn, b10.lat, b10.lon, 600, b10.prate, zsea_ship, b10.ssea_s, b10.wave_phasespd, b10.wave_sigheight, ref, ref, ref);
disp('COARE v3.6 for ship data');
Bs=coare36vnWarm_et(b10.jd, b10.wspd_s, zu_ship, b10.ta_s, zt_ship, b10.rh_s, zq_ship, b10.psealevel_s, b10.tsea_s, b10.sw_dn_s, b10.lw_dn_s, b10.lat_s, b10.lon_s, 600, b10.prate, zsea_ship, b10.ssea_s, nan, nan, ref, ref, ref);
% disp('COARE v3.5 for PSL data');
% C=coare35vnWarm_et(b10.jd, b10.wspd_sfc, zu, b10.ta, zt, b10.rh, zq, b10.psealevel, b10.tsnk, b10.sw_dn, b10.lw_dn, b10.lat, b10.lon, 600, b10.prate, zsnk, ref);

cfields = {'usr';'tau';'hs';'hl';'hb';'hb_son';'hlwebb';'tsr';'qsr';'zo';'zot';'zoq';...
    'cd';'ch';'ce';'l';'zeta';'dt_skin';'dq_skin';'dz_skin';'u2';'ta2';'qa2';...
    'rh2';'u2n';'ta2n';'qa2n';'lw_net';'sw_net';'le';'rhoa';'un';'u10';'u10n';'cdn10';'chn10';'cen10';...
    'hrain';'qs';'erate';'ta10';'ta10n';'qa10';'qa10n';'rh10';'pa10';'rhoa10';'gust';'wc_frac';'edis';...
    'dt_warm';'dz_warm';'dt_warm_to_skin';'du_warm'};

D = B;
% D_nw = B_nw;

if snake_screen == 1
    for i = 1:length(cfields)
       D(wh_bad_snake_eez_10,i) = Ds(wh_bad_snake_eez_10,i);
       D_nw(wh_bad_snake_eez_10,i) = Ds_nw(wh_bad_snake_eez_10,i);
    end
end

% % testing buoyancy flux v3.6
% cfields = {'usr';'tau';'hs';'hl';'hb';'hb1';'hb_son';'hb_son1';'hlwebb';'tsr';'qsr';'zo';'zot';'zoq';...
%     'cd';'ch';'ce';'l';'zeta';'dt_skin';'dq_skin';'dz_skin';'u2';'T2';'qa2';...
%     'rh2';'u2n';'T2n';'qa2n';'lw_net';'sw_net';'Le';'rhoa';'uN';'u10';'u10N';'CdN10';'ChN10';'CeN10';...
%     'hrain';'qs';'erate';'T10';'T10N';'qa10';'qa10N';'rh10';'pa10';'rhoa10';'gust';'wc_frac';'Edis';...
%     'dt_warm';'dz_warm';'dt_warm_to_skin';'du_warm'};

cfields_35 = {'usr';'tau';'hs';'hl';'hb';'hb_son';'hlwebb';'tsr';'qsr';'zo';'zot';'zoq';...
    'cd';'ch';'ce';'l';'zeta';'dt_skin';'dq_skin';'dz_skin';'u2';'ta2';'qa2';...
    'rh2';'u2n';'lw_net';'sw_net';'le';'rhoa';'un';'u10';'u10n';'cdn10';'chn10';'cen10';...
    'hrain';'qs';'erate';'ta10';'ta10n';'qa10';'qa10n';'rh10';'pa10';'rhoa10';'gust';...
    'dt_warm';'dz_warm';'dt_warm_to_skin'};

missing_35 = {'du_warm';'wc_frac';'edis';'ta2n';'qa2n'};

for i = 1:length(cfields)
    % The PSL fields are used, and filled with Bs where snake is missing
%     eval([cfields{i} '_10_nw = D_nw(:,i);']);
    eval([cfields{i} '_10 = D(:,i);']);
    eval([cfields{i} ' = interp1(b10.t,' cfields{i} '_10, b1.t);' ]);
    
    % add ship fields to array
    eval(['b10.' cfields{i} '_s = Bs(:,i);']);
    eval(['b1.' cfields{i} '_s = interp1(b10.t, b10.' cfields{i} '_s, b1.t);' ]);
    
    % save arrays filled with ship tsg too
%     eval([cfields{i} '_10_ds = Ds(:,i);']);
%     eval([cfields{i} '_10_ds_nw = Ds_nw(:,i);']);
%     eval([cfields{i} '_ds = interp1(b10.t,' cfields{i} '_10_ds, b1.t);' ]);
   
end

% do any coare checks of 3.6 that are needed
plot_new_buoy_flux = 0;
if plot_new_buoy_flux == 1
    figure;
    
    subplot(1,2,1); hold on;
    plot(b10.t, hb1_10, b10.t, hb_10,'--');
    legend('original','new');
    title('buoyancy flux');
    ylabel('W m^{-2}');
    datetick('x','dd');
    grid on;
    
    subplot(1,2,2); hold on;
    plot(b10.t, hb_son1_10, b10.t, hb_son_10,'--');
    legend('original','new');
    title('sonic buoyancy flux');
    ylabel('W m^{-2}');
    datetick('x','dd');
    grid on;
    
    print(graphdevice,[path_fix_plots '/newflux_' cruise graphformat]);
end


% interpolate from 10 min to 1 min
% for i = 1:length(cfields_35)
%     eval([cfields_35{i} '_10_35 = C(:,i);']);
%     eval([cfields_35{i} '_35 = interp1(b10.t,' cfields_35{i} '_10_35, b1.t);' ]);
% end
% 
% nanfill = nan(length(tau),1);
% nanfill_10 = nan(length(tau_10),1);
% 
% for i = 1:length(missing_35)
%     eval([missing_35{i} '_10_35 = nanfill_10;']);
%     eval([missing_35{i} '_35 = nanfill;']);
% end

%%% option: sign changes of COARE fields... the bulk sensible, latent, and rain
%%% heat fluxes are defined positive by COARE. 
% flips = {'hs';'hl';'hrain'};
% for k = 1:length(flips)
%     eval([flips{k} ' = - ' flips{k} ';']);
%     eval([flips{k} '_35 = - ' flips{k} '_35;']);
%     eval([flips{k} '_10 = - ' flips{k} '_10;']);
%     eval([flips{k} '_10_35 = - ' flips{k} '_10_35;']);
% end

%% recalculate some fields using COARE output

% interface
tskin       = b1.tsnk + dt_warm_to_skin - dt_skin;
tskin_10    = b10.tsnk + dt_warm_to_skin_10 - dt_skin_10;
% tskin_10_nw    = b10.tsnk + dt_warm_to_skin_10_nw - dt_skin_10_nw;

if snake_screen == 1        
    tskin(wh_bad_snake_eez) = b1.tsea_s(wh_bad_snake_eez) + dt_warm_to_skin_ds(wh_bad_snake_eez) - dt_skin_ds(wh_bad_snake_eez);
    tskin_10(wh_bad_snake_eez_10) = b10.tsea_s(wh_bad_snake_eez_10) + dt_warm_to_skin_10_ds(wh_bad_snake_eez_10) - dt_skin_10_ds(wh_bad_snake_eez_10);
end

% tskin_10_nw(wh_bad_snake_eez_10) = b10.tsea_s(wh_bad_snake_eez_10) + dt_warm_to_skin_10_ds_nw(wh_bad_snake_eez_10) - dt_skin_10_ds_nw(wh_bad_snake_eez_10);


qskin = qsea_p(tskin,b1.psealevel);
qskin_10 = qsea_p(tskin_10,b10.psealevel);
% qskin_10_nw = qsea_p(tskin_10_nw,b10.psealevel);

% recalculate upwelling radiative fluxes
% lw_up       = lw_net - b1.lw_dn; %%% this is REALLY NOISY
lw_up_10    = lw_net_10 - b10.lw_dn;

if snake_screen == 1
 lw_up_10(wh_bad_snake_eez_10)    = lw_net_10_ds(wh_bad_snake_eez_10) - b10.lw_dn(wh_bad_snake_eez_10);
end

% sw_up       = sw_net - b1.sw_dn; %%% this is REALLY NOISY
sw_up_10    = sw_net_10 - b10.sw_dn;

lw_up = interp1(b10.jd, lw_up_10, b1.jd);
sw_up = interp1(b10.jd, sw_up_10, b1.jd);

% net heat flux: heating into the ocean... remove hrain for ASTRAL 2023
% since its nan :( unless I trust PWD rain rate from UND. 
hnet        = sw_net + lw_net - hs - hl - hrain;
hnet_10     = sw_net_10 + lw_net_10 - hs_10 - hl_10 - hrain_10;
% hnet_10_nw     = sw_net_10 + lw_net_10 - hs_10_nw - hl_10_nw - hrain_10;

% % net heat flux: heating into the ocean
% hnet        = sw_net + lw_net - hs - hl - hrain;
% hnet_10     = sw_net_10 + lw_net_10 - hs_10 - hl_10 - hrain_10;


% fields to replace now that they are checked, these already appeared in
% the original v0 b1 and b10 datasets. 
more_fields = {'hnet';'lw_up';'sw_up';'tskin';'qskin';'dtheta';'theta0';'theta10';'tsr_son'};
af = sort([cfields; more_fields]);

% save new data fields for ship too, for completeness
b10.hnet_s = b10.sw_net_s + b10.lw_net_s - b10.hs_s - b10.hl_s - b10.hrain_s;
b10.tskin_s = b10.tsea_s + b10.dt_warm_to_skin_s - b10.dt_skin_s;
b10.lw_up_s = b10.lw_net_s - b10.lw_dn_s;
b10.sw_up_s = b10.sw_net_s - b10.sw_dn_s;

b1.hnet_s = b1.sw_net_s + b1.lw_net_s - b1.hs_s - b1.hl_s - b1.hrain_s;
b1.tskin_s = b1.tsea_s + b1.dt_warm_to_skin_s - b1.dt_skin_s;
b1.lw_up_s = b1.lw_net_s - b1.lw_dn_s;
b1.sw_up_s = b1.sw_net_s - b1.sw_dn_s;

% this could be dtadj or dtadjK, but might as well do it as theta to be
% absolutely correct. The theta version is only 0.0022 greater. 
p_tq = b1.psealevel - 0.125*zt;
p_tq_10 = b10.psealevel - 0.125*zt;

theta10     = (b1.ta+C2K).*(1000./p_tq).^(Rgas/cpa);  
theta0      = (tskin+C2K).*(1000./b1.psealevel).^(Rgas/cpa);  
dtheta      = theta0 - theta10;

theta10_10  = (b10.ta+C2K).*(1000./p_tq_10).^(Rgas/cpa);  
theta0_10   = (tskin_10+C2K).*(1000./b10.psealevel).^(Rgas/cpa);  
dtheta_10   = theta0_10 - theta10_10;

tsr_son = tsr + 0.51*(b1.ta+C2K).*qsr;
tsr_son_10 = tsr_10 + 0.51*(b10.ta+C2K).*qsr_10;

%% Example: name changing if needed...
%%% if the old version had a different name but you want to compare it to the current version now
% if isfield(b1,'SSQ') == 1
%     b1.qs = b1.SSQ;
%     b10.qs = b10.SSQ;
%     b1 = rmfield(b1,'SSQ');
%     b10 = rmfield(b10,'SSQ');
% end

%% plots
plot_checks = 1;
if plot_checks == 1
%%% now check to see before after of fluxes. 
figure;
counter = 1;
type_plot = 'all';

cfields_s = cell(length(cfields),1);
for i = 1:length(cfields)
    cfields_s(i) = {[char(cfields(i)) '_s']};
end

if  strcmp(type_plot,'coare') == 1
    thefields = af; %%% if you want to plot only coare output
elseif strcmp(type_plot,'all') == 1
    %% save new COARE and post-COARE derived values in stuctures now that they've been checked
    for j = 1:length(af)
        eval(['b1.(af{j}) = ' af{j} ';']);
        eval(['b10.(af{j}) = ' af{j} '_10;']);
    end
    thefields = fields(b10); %%% if you want to plot all vars for entire experiment
end
nc = length(thefields);
for i = 1:4:nc
    clf;
    for j = 1:4
       if (i+j-1) <= nc
           subplot(2,2,j); hold on
           if strcmp(type_plot,'coare') == 1
                eval(['newvar = ' thefields{i+j-1} '_10;']);
           else 
                eval(['newvar = b10.' thefields{i+j-1} ';']);
           end
           plot(b10.t, newvar,'o');
           grid on;
           var_name = {strrep(thefields{i+j-1},'_',' ')};
           title(var_name);
           xlim([min(b10.t) max(b10.t)]);
           datetick('x','DD','keeplimits');
           grid on;
           % plot coare v 3.5 if doing the coare plots
           if strcmp(type_plot,'coare') == 1
               eval(['oldvar = ' thefields{i+j-1} '_10_35;']);
               plot(b10.t, oldvar,'x');
               legend('3.6','3.5');
           % plot prior b10 fields before any corrections were made herein
           elseif strcmp(type_plot,'allcompare') == 1
                if isfield(b10,thefields{i+j-1}) == 1
                plot(b10.t, b10.(thefields{i+j-1}),'.k','markersize',5);
                legend('3.6','3.6 prior','location','best');
                end
           % if neither coare 3.5 fields or prior b10 fields exist, just 
           %      continue plotting only new coare 3.6 fields     
           else
%                 legend('3.6');
           end
       end
    end
   print(graphdevice,[path_fix_plots '/' type_plot '_' sprintf('%i',counter) 'b_' cruise graphformat]);
   counter = counter + 1;
end  % for all vars

test_waves = 0;
if test_waves == 1
   figure('position',[1,1,1400,900]);
   subplot(3,2,1);
   plot(b10.t, hnet_10,'o', b10.t, hnet_10_nw,'.k');
   grid on; datetick('x','dd','keeplimits');
   legend('hnet');
   title('colored circles: with waves');
   
   subplot(3,2,2);
   plot(b10.t, u10_10,'o', b10.t, u10_10_nw, '.k');
   grid on; datetick('x','dd','keeplimits');
   legend('u10')
   title('black dots: no waves');
   
   subplot(3,2,3);
   plot(b10.t, tau_10,'o', b10.t, tau_10_nw,'.k');
   grid on; datetick('x','dd','keeplimits');
   legend('tau');
   
   subplot(3,2,4);
   yyaxis right;
   plot(b10.t, edis_10,'or', b10.t, edis_10_nw,'.k');
   grid on; datetick('x','dd','keeplimits');
   ylabel('edis','color','r');
   yyaxis left;
   plot(b10.t, wc_frac_10, 'ob',b10.t, wc_frac_10_nw,'.k');
   grid on; datetick('x','dd','keeplimits');
   ylabel('wc frac','color','b');
   
   subplot(3,2,5);
   plot(b10.t, zo_10, 'o', b10.t, zot_10,'d',b10.t, zoq_10,'o');hold on;
   plot(b10.t, zo_10_nw,'.k', b10.t, zot_10_nw,'.k',b10.t, zoq_10_nw,'.k');
   grid on; datetick('x','dd','keeplimits');
   legend('zo','zot','zoq');
   
   subplot(3,2,6);
   plot(b10.t, hs_10, 'o', b10.t, hl_10, 'o', b10.t, hs_10_nw, '.k', b10.t, hl_10_nw, '.k');
   grid on; datetick('x','dd','keeplimits');
   legend('hs','hl');
   
   print(graphdevice,[path_fix_plots '/wave_impact_time_' cruise graphformat]);
   
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   figure('position',[1,1,1400,1400]);
   subplot(3,3,1);
   plot(hnet_10,hnet_10_nw,'o'); 
   axis square; xlim(ylim); grid on;
   hold on; plot([xlim xlim], [ylim ylim],'--g');
   legend('hnet','location','southeast');
   xlabel('with waves'); ylabel('no waves');
   
   subplot(3,3,2);
   plot(u10_10,u10_10_nw,'o');
   axis square; xlim(ylim); grid on;
   hold on; plot([xlim xlim], [ylim ylim],'--g');
   legend('u10','location','southeast');
   xlabel('with waves'); ylabel('no waves');

   subplot(3,3,3);
   plot(tskin_10,tskin_10_nw, 'o');
   axis square; xlim(ylim); grid on;
   hold on; plot([xlim xlim], [ylim ylim],'--g');
   legend('tskin','location','southeast');
   xlabel('with waves'); ylabel('no waves');
   
   subplot(3,3,4);
   plot(tau_10,tau_10_nw,'o');
   axis square; xlim(ylim); grid on;
   hold on; plot([xlim xlim], [ylim ylim],'--g');
   legend('tau','location','southeast');
   xlabel('with waves'); ylabel('no waves');
   
   subplot(3,3,5);
   plot(edis_10,edis_10_nw,'o');
   hold on;
   plot(wc_frac_10,wc_frac_10_nw,'o');
   axis square; xlim(ylim); grid on;
   plot([xlim xlim], [ylim ylim],'--g');
   legend('edis','wc frac','location','southeast');
   xlabel('with waves'); ylabel('no waves');
   
   subplot(3,3,6);
   plot(zo_10,zo_10_nw,'o');
   axis square; xlim(ylim); grid on;
   hold on; plot([xlim xlim], [ylim ylim],'--g');
   legend('zo','location','southeast');
   xlabel('with waves'); ylabel('no waves');
   
   subplot(3,3,7);
   plot(zot_10,zot_10_nw,'o');
   hold on; plot(zoq_10,zoq_10_nw,'.');
   axis square; xlim(ylim); grid on;
   hold on; plot([xlim xlim], [ylim ylim],'--g');
   legend('zot','zoq','location','southeast');
   xlabel('with waves'); ylabel('no waves');
   
   subplot(3,3,8);
   plot(hs_10,hs_10_nw, 'o');
   axis square; xlim(ylim); grid on;
   hold on; plot([xlim xlim], [ylim ylim],'--g');
   legend('hs','location','southeast');
   xlabel('with waves'); ylabel('no waves');
   
   subplot(3,3,9);
   plot(hl_10,hl_10_nw, 'o');
   axis square; xlim(ylim); grid on;
   hold on; plot([xlim xlim], [ylim ylim],'--g');
   legend('hl','location','southeast');
   xlabel('with waves'); ylabel('no waves');

   print(graphdevice,[path_fix_plots '/wave_impact_scatter_' cruise graphformat]);
    
   
end


end %% if make plots

%% save new COARE and post-COARE derived values in stuctures now that they've been checked
for j = 1:length(af)
    eval(['b1.(af{j}) = ' af{j} ';']);
    eval(['b10.(af{j}) = ' af{j} '_10;']);
end


%% fix a few PISTON cruise-specific things
cruise_specific = ;
if cruise_specific == 1
    b1.ta_s(b1.ta_s < 20) = nan;
    b1.psealevel_s(b10.psealevel_s < 999) = nan;
end


%% save corrected data
% organize structures for saving
% put all variable names in alphabetic0al order;
b1 = orderfields(b1);
b10 = orderfields(b10);
save(m_outfile_1, 'b1');
save(m_outfile_10, 'b10');

%==========================================================================

function g=grv(lat)
% computes g [m/sec^2] given lat in deg
gamma=9.7803267715;
c1=0.0052790414;
c2=0.0000232718;
c3=0.0000001262;
c4=0.0000000007;
phi=lat*pi/180;
x=sin(phi);
g=gamma*(1+c1*x.^2+c2*x.^4+c3*x.^6+c4*x.^8);
end