function plot_eval_10(a10, path_prog, path_raw_images)
%%% function to read in 1 day of met, seawater, flux data and make plots
%%% that are normally produced by run_motcoor.m program. Function reads in
%%% the daily matlab structure ff produced by this program. 
%%% 
%%% EJT Jan 2020
%%%
%%% input: 
%%%     a1, a10 = structures at 1-min and 10-min with data for plotting

%%% Notes: 
%%%     WXT is not plotted currently



% matlab script path
% restoredefaultpath
% cd(fullfile(path_prog,'flux'));
% addpath(genpath(fullfile(path_prog,'flux')));
% rehash toolboxcache;

% setup_cruise;
cruise = 'ASTRAL_2024';  % string for file names: acronym_year
ptitle = 'ASTRAL 2024';  % string for plots
cruise_str = 'ASTRAL';  % cruise acronym
ship = 'Thompson';  % research vessel
yr = str2double(cruise(end-3:end)); % numeric year
yr_st = cruise(end-3:end); % year string
graphdevice = '-dpng'; % select graphic device
graphformat = '.png';  % select graphics format

the_jd = floor(a10.jd(1));
[the_yr, the_mo, the_day, ~, ~, ~] = datevec(a10.t(1));
[~, ~, ~, a10.hour, ~, ~] = datevec(a10.t);

% constants
tdk = 273.15;               % T conversion constant
d2r = pi/180;               % angle conversion constants
r2d = 180/pi;
Rgas = 287.1;               % Pa m-3 kg-1 K-1 for dry air
Rgas_universal = 8.314472;	% Pa m3 K-1 mol-1
Mw = 18.01528;              % molar mass of H20 a10/mol
Md = 28.964;                % molar mass dry air
epsilon = Mw/Md;            % mass of water to mass of dry air = 0.622... epsilon = 0.9715; % mean emissivity of the ocean
cpa  = 1004.67;             % heat capacity air
sigma = 5.67E-8;            % stephan boltzmann constant W m-2 K-4

% %%% note - not saving these 10-min fluxes to structure because they will be 
% %%% corrected in next program. Just plotting here to have a look. 
% a10.ustar = usr;
% a10.hl = hlb;
% a10.hs = hsb;
% a10.lw_dn = -a10.lw1; % change to sign convention where negative = down
% a10.lw_net = 0.97*(5.67e-8*(a10.tsnk+tdk).^4 + a10.lw_dn);    % net longwave
% a10.lw_up = a10.lw_net - a10.lw_dn;                       % upward longwave
% a10.sw_net = -0.955*a10.sw1;                            % net shortwave
% a10.sw_up = a10.sw_net - a10.sw1;                       % upward shortwave
% a10.hr =  -rf;
% a10.hnet = a10.sw_net + a10.lw_net + a10.hs + a10.hl + a10.hr;      % net


%% plot info
graphformat = '.png';  % select graphics format
graphdevice = '-dpng'; % select graphic device

%% adjustments to radiometers, snake, and air temp from MANUALflux_eval.m
td1_adj = 0;        % ?
tc1_adj = 0;        % ?
td2_adj = 0;        % ?
tc2_adj = 0;        % ?
td_scs_adj = 0;     % ?
tc_scs_adj = 0;     % ?
tsea_adj = 0;       % sea snake
ta_adj = 0;         % air temp

date_st = sprintf('%04i_%02i_%02i_%03i',the_yr,the_mo,the_day,the_jd);
ppath_SLP = fullfile(path_raw_images,'SL_pressure',['Pressure_' date_st graphformat]);
ppath_T1 = fullfile(path_raw_images,'Temps',['Temperatures_All_' date_st graphformat]);
ppath_T2 = fullfile(path_raw_images,'Temps',['Temperatures_' date_st graphformat]);
ppath_T3 = fullfile(path_raw_images,'Temps',['Radiometer_T_vs_air_T_' date_st graphformat]);
ppath_RH = fullfile(path_raw_images,'RH',['RH_' date_st graphformat]);
ppath_ORG = fullfile(path_raw_images,'Rainrate',['ORG_offset_' date_st graphformat]);
ppath_R = fullfile(path_raw_images,'Rainrate',['Rainrate_' date_st graphformat]);
ppath_ASPIR = fullfile(path_raw_images,'T_RH_fan',['Backflow_indicator_' date_st graphformat]);
ppath_SST = fullfile(path_raw_images,'SST',['SST_' date_st graphformat]);
ppath_MAP = fullfile(path_raw_images,'Track_plot',['GPS_track_LAT_LON_' date_st graphformat]);
ppath_COGSOG = fullfile(path_raw_images,'COG_SOG',['COG_SOG_' date_st graphformat]);
ppath_HED = fullfile(path_raw_images,'Heading',['Heading_' date_st graphformat]);
ppath_PITCH = fullfile(path_raw_images,'Pitch',['Pitch_' date_st graphformat]);
ppath_RW = fullfile(path_raw_images,'Relative_Wind',['Relative_Winds_' date_st graphformat]);
ppath_TW = fullfile(path_raw_images,'True_Wind',['True_Winds_' date_st graphformat]);
ppath_agc = fullfile(path_raw_images,'Licor_agc',['agc_' date_st graphformat]);
ppath_IR = fullfile(path_raw_images,'IR_flux',['IRflux_Comparison_' date_st graphformat]);
ppath_IR_therm = fullfile(path_raw_images,'IR_flux',['IR_therm_' date_st graphformat]);
ppath_SW = fullfile(path_raw_images,'Solar_Flux',['Solarflux_Comparison_' date_st graphformat]);
ppath_BULK = fullfile(path_raw_images,'Heat_Fluxes',['Bulk_Fluxes_' date_st graphformat]);

the_ppaths = {ppath_SLP; ppath_T1; ppath_T2; ppath_T3; ppath_RH; ppath_ORG; ppath_R; ppath_ASPIR; ppath_SST; ppath_MAP; ppath_COGSOG;...
    ppath_HED; ppath_PITCH; ppath_RW; ppath_TW; ppath_agc; ppath_IR; ppath_IR_therm; ppath_SW; ppath_BULK};


% RELATIVE WIND SPEED & DIRECTION
figure; 
subplot(2,1,1); hold on;
plot(a10.jd, a10.rdir_s, 'ob',a10.jd, a10.rdir2_s, 'co', a10.jd, a10.rdir3_s, 'go',a10.jd, a10.rdir,'.r');grid;
plot(...
    [the_jd the_jd+1],[60 60],'k:', ...
    [the_jd the_jd+1],[-60 -60],'k:', ...
    [the_jd the_jd+1],[90 90],'k-', ...
    [the_jd the_jd+1],[-90 -90],'k-');
xlabel('Hour (UTC)'); ylabel('Relative Wind Direction (^o)'); axis([the_jd the_jd+1 -180 180]); 
legend('ship mast','ship port','ship star','PSL','location','Northeastoutside'); grid;
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

%close all;

end %%% if loop for plotting only if data are there
end  %%% end function