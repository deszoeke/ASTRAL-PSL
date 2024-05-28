function plot_eval_noship(a1, a10, path_prog, path_raw_images)
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
restoredefaultpath
cd(fullfile(path_prog,'flux'));
addpath(genpath(fullfile(path_prog,'flux')));
rehash toolboxcache;

setup_cruise;

the_jd = floor(a1.jd(1));
[the_yr, the_mo, the_day, ~, ~, ~] = datevec(a1.t(1));
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
ppath_AGC = fullfile(path_raw_images,'Licor_AGC',['AGC_' date_st graphformat]);
ppath_IR = fullfile(path_raw_images,'IR_flux',['IRflux_Comparison_' date_st graphformat]);
ppath_IR_therm = fullfile(path_raw_images,'IR_flux',['IR_therm_' date_st graphformat]);
ppath_SW = fullfile(path_raw_images,'Solar_Flux',['Solarflux_Comparison_' date_st graphformat]);
ppath_BULK = fullfile(path_raw_images,'Heat_Fluxes',['Bulk_Fluxes_' date_st graphformat]);

the_ppaths = {ppath_SLP; ppath_T1; ppath_T2; ppath_T3; ppath_RH; ppath_ORG; ppath_R; ppath_ASPIR; ppath_SST; ppath_MAP; ppath_COGSOG;...
    ppath_HED; ppath_PITCH; ppath_RW; ppath_TW; ppath_AGC; ppath_IR; ppath_IR_therm; ppath_SW; ppath_BULK};

%% Daily plots

nondata = nan(1,length(a10.jd));

%%% print blank plots if the first and last data point are both nan
if isnan(a10.psealevel(1)) == 1 && isnan(a10.psealevel(end)) == 1

    disp('no data today, so just printing blank plots');

    % print a blank plot
    figure; plot(a10.jd,nan(1,length(a10.jd))); grid on;
    title(sprintf('%s (%04i-%02i-%02i, DOY%03i).  No Data - Ship in Port',cruise_str,the_yr,the_mo,the_day,the_jd),'FontWeight','Bold','Interpreter','none')
    xlabel('Hour (UTC)');
    axis([the_jd the_jd+1 0 1]); 
    set(gca(gcf),'XTick',the_jd:2/24:the_jd+1); datetick('x','HH:MM','keepticks');
    xax = get(gca(gcf),'XTickLabel'); xax(end,:)='24:00'; set(gca(gcf),'XTickLabel',xax(:,1:2));
    annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL'},'FontSize',14,'FitBoxToText','off','LineStyle','none');

    for i = 1:length(the_ppaths)
        print(graphdevice,the_ppaths{i});
    end

else


% PRESSURE
figure; plot(a10.jd,nondata,'b-',a10.jd,a10.psealevel,'r-'); grid;
title(sprintf('%s (%04i-%02i-%02i, DOY%03i).  Sea Level Pressures',cruise_str,the_yr,the_mo,the_day,the_jd),'FontWeight','Bold','Interpreter','none')
xlabel('Hour (UTC)'); ylabel('SL Pressure (mb)');
axis([the_jd the_jd+1 median(a10.psealevel(~isnan(a10.psealevel)))-5 median(a10.psealevel(~isnan(a10.psealevel)))+5]);
set(gca(gcf),'XTick',the_jd:2/24:the_jd+1); datetick('x','HH:MM','keepticks');
xax = get(gca(gcf),'XTickLabel'); xax(end,:)='24:00'; set(gca(gcf),'XTickLabel',xax(:,1:2));
legend('ship','PSL','location','BestOutside');
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL'},'FontSize',14,'FitBoxToText','off','LineStyle','none');
    print(graphdevice,ppath_SLP);

% ALL TEMPERATURES
figure;
plot(a10.jd,a10.lw_case_t_1+tc1_adj,'-', a10.jd, a10.lw_dome_t_1+td1_adj,'-', a10.jd, a10.lw_dome_t_2+td2_adj,'-',a10.jd, a10.lw_case_t_2+tc2_adj,'-',...
    a10.jd, nondata, a10.jd, nondata, a10.jd,a10.ta, a10.jd,nondata);
title(sprintf('%s (%04i-%02i-%02i, DOY%03i). All Temperatures',cruise_str,the_yr,the_mo,the_day,the_jd),'FontWeight','Bold','Interpreter','none');
legend('case PIR-1','dome PIR-1','case PIR-2','dome PIR-2','case ship','dome ship','PSL vaisala','ship','Location','BestOutside');
xlabel('Hour (UTC)'); ylabel('Temperature (^oC)');
xlim([the_jd the_jd+1]); grid;
set(gca(gcf),'XTick',the_jd:2/24:the_jd+1); datetick('x','HH:MM','keepticks');
xax = get(gca(gcf),'XTickLabel'); xax(end,:)='24:00'; set(gca(gcf),'XTickLabel',xax(:,1:2));
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL'},'FontSize',14,'FitBoxToText','off','LineStyle','none');
    print(graphdevice,ppath_T1);
      
% AIR TEMPERATURES
figure; plot(a10.jd,nondata,'-b',a10.jd,a10.ta,'-r');
title(sprintf('%s (%04i-%02i-%02i, DOY%03i).  Air Temperatures',cruise_str,the_yr,the_mo,the_day,the_jd),'FontWeight','Bold','Interpreter','none');
legend('ship','PSL vaisala','Location','BestOutside');
xlabel('Hour (UTC)'); ylabel('Temperature (^oC)');
xlim([the_jd the_jd+1]); grid;
set(gca(gcf),'XTick',the_jd:2/24:the_jd+1); datetick('x','HH:MM','keepticks');
xax = get(gca(gcf),'XTickLabel'); xax(end,:)='24:00'; set(gca(gcf),'XTickLabel',xax(:,1:2));
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL'},'FontSize',14,'FitBoxToText','off','LineStyle','none');
    print(graphdevice,ppath_T2);

% RADIOMETER T OFFSETS
% check PIR temp offsets from night air temps
wh_night = find(a10.hour < 21 | a10.hour > 9); % for PISTON
tc1_adj2 = nanmean1(a10.ta(wh_night)-a10.lw_case_t_1(wh_night)); disp(['tc1_adj = ',sprintf('%4.2f',tc1_adj2)]);
td1_adj2 = nanmean1(a10.ta(wh_night)-a10.lw_dome_t_1(wh_night)); disp(['td1_adj = ',sprintf('%4.2f',td1_adj2)]);
tc2_adj2 = nanmean1(a10.ta(wh_night)-a10.lw_case_t_2(wh_night)); disp(['tc2_adj = ',sprintf('%4.2f',tc2_adj2)]);
td2_adj2 = nanmean1(a10.ta(wh_night)-a10.lw_dome_t_2(wh_night)); disp(['td2_adj = ',sprintf('%4.2f',td2_adj2)]);
tc_sh_adj = nan;
td_sh_adj = nan;

figure; 
% subplot(2,1,1);
plot(a10.jd,a10.ta-a10.lw_case_t_1,'-',a10.jd,a10.ta-a10.lw_dome_t_1,'-',...
    a10.jd,a10.ta-a10.lw_case_t_2,'-', a10.jd, a10.ta-a10.lw_dome_t_2,'-',...
    a10.jd,a10.ta-nondata,'-',a10.jd,a10.ta-nondata,'-');
title(sprintf('%s %4.2f %s %4.2f %s %4.2f %s %4.2f %s %4.2f %s %4.2f','air-IR \DeltaT night: case 1: ',...
    tc1_adj2,' ; dome 1: ',td1_adj2,'case 2: ',tc2_adj2,' ; dome 2: ',td2_adj2,...
    'case sh: ',tc_sh_adj,' ; dome sh: ',td_sh_adj),'FontWeight','Bold','Interpreter','none');
legend('Tc1','Td1','Tc2','Td2','sc','sd','Location','BestOutside');
xlabel('Hour (UTC)'); ylabel('Temperature (^oC)'); grid;
xlim([a10.jd(1) a10.jd(end)]);
set(gca(gcf),'XTick',the_jd:2/24:the_jd+1); datetick('x','HH:MM','keeplimits','keepticks');
xax = get(gca(gcf),'XTickLabel'); xax(end,:)='24:00'; set(gca(gcf),'XTickLabel',xax(:,1:2));

% subplot(2,1,2);
% plot(a10.jd, a10.ta-a10.lw_dome_t_2,'-');
% title(sprintf('%s %4.2f','air-IR \DeltaT night: dome 2: ',td2_adj2),'FontWeight','Bold','Interpreter','none');
% legend('Td2','Location','BestOutside');
% xlabel('Hour (UTC)'); ylabel('Temperature (^oC)'); grid;
% xlim([a10.jd(1) a10.jd(end)]);
% set(gca(gcf),'XTick',the_jd:2/24:the_jd+1); datetick('x','HH:MM','keeplimits','keepticks');
% xax = get(gca(gcf),'XTickLabel'); xax(end,:)='24:00'; set(gca(gcf),'XTickLabel',xax(:,1:2));

annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL'},'FontSize',14,'FitBoxToText','off','LineStyle','none');
    print(graphdevice,ppath_T3);

% RELATIVE HUMIDITY
figure; plot(a10.jd, nondata,'b-',a10.jd, a10.rh, 'r-'); grid;
title(sprintf('%s (%04i-%02i-%02i, DOY%03i).  Relative Humidity',cruise_str,the_yr,the_mo,the_day,the_jd),'FontWeight','Bold','Interpreter','none');
xlabel('Hour (UTC)'); ylabel('Relative Humidity (%)');
xlim([the_jd the_jd+1]); 
legend('ship','PSL','location','BestOutside');
set(gca(gcf),'XTick',the_jd:2/24:the_jd+1); datetick('x','HH:MM','keepticks');
xax = get(gca(gcf),'XTickLabel'); xax(end,:)='24:00'; set(gca(gcf),'XTickLabel',xax(:,1:2));
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL'},'FontSize',14,'FitBoxToText','off','LineStyle','none');
    print(graphdevice,ppath_RH);

% ORG background adjustment
orgV_bkgd    = nanmedian1(a1.orgV_desp); % single value
orgV_adj     = 0.06484 - orgV_bkgd; % single value
figure; hold on;
plot(a1.jd,a1.orgV,'r.',  a1.jd,  a1.orgV_desp,'og');grid;
plot([a1.jd(1) a1.jd(end)], [orgV_bkgd orgV_bkgd],'k--',...
    [a1.jd(1) a1.jd(end)], [0.06484 0.06484],'k:');
title(sprintf('%s (%04i-%02i-%02i, DOY%03i). ORG offset voltage ',cruise_str,the_yr,the_mo,the_day,the_jd),'FontWeight','Bold','Interpreter','none');
xlabel('Hour (UTC)'); ylabel('Volts'); xlim([the_jd the_jd+1]); ylim([0.03,0.15]);
text(a1.jd(10),0.14,['orgV adj = ',sprintf('%6.4f',orgV_adj),' V'],'fontsize',18);
set(gca(gcf),'XTick',the_jd:2/24:the_jd+1);datetick('x','HH:MM','keepticks');
legend({'raw','despiked raw','median offset','target offset'},'location','eastoutside');
xax = get(gca(gcf),'XTickLabel'); xax(end,:)='24:00'; set(gca(gcf),'XTickLabel',xax(:,1:2));
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL'},'FontSize',14,'FitBoxToText','off','LineStyle','none');
    print(graphdevice,ppath_ORG);

% RAIN RATE
figure; 
yyaxis left;
hold on;
plot(a10.jd, a10.prate_orig, '-');
yyaxis right;
plot(a10.jd, a10.prate, '-'); grid;
title(sprintf('%s (%04i-%02i-%02i, DOY%03i).  Rain Rate ',cruise_str,the_yr,the_mo,the_day,the_jd),'FontWeight','Bold','Interpreter','none');
xlabel('Hour (UTC)'); ylabel('Rain Rate (mm/hr)'); xlim([the_jd the_jd+1]);
set(gca(gcf),'XTick',the_jd:2/24:the_jd+1);datetick('x','HH:MM','keepticks');
legend('PSL ORG original','PSL ORG corrected','location','BestOutside');
xax = get(gca(gcf),'XTickLabel'); xax(end,:)='24:00'; set(gca(gcf),'XTickLabel',xax(:,1:2));
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL'},'FontSize',14,'FitBoxToText','off','LineStyle','none');
    print(graphdevice,ppath_R);

% PSL T/RH ASPIRATOR FAN
figure; plot(a10.jd, a10.aspir_trh,'-r');
title(sprintf('%s (%04i-%02i-%02i, DOY%03i).  PSL T/RH aspirator fan',cruise_str,the_yr,the_mo,the_day,the_jd),'FontWeight','Bold','Interpreter','none');
xlabel('Hour (UTC)');ylabel('Aspirator Fan Speed (rpm)'); xlim([the_jd,the_jd+1]);
set(gca(gcf),'XTick',the_jd:2/24:the_jd+1); datetick('x','HH:MM','keepticks'); grid;
xax = get(gca(gcf),'XTickLabel'); xax(end,:)='24:00'; set(gca(gcf),'XTickLabel',xax(:,1:2));
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL'},'FontSize',14,'FitBoxToText','off','LineStyle','none');
    print(graphdevice,ppath_ASPIR);

% SST
figure; plot(a10.jd,nondata,'-b',a10.jd,nondata,'--g', a10.jd, a10.tsnk,'-r', a10.jd, nondata,'ok'); grid;
title(sprintf('%s (%04i-%02i-%02i, DOY%03i).  Seawater T',cruise_str,the_yr,the_mo,the_day,the_jd),'FontWeight','Bold','Interpreter','none');
xlabel('Hour (UTC)');ylabel('Water Temperature (^oC)'); xlim([the_jd the_jd+1]);
legend(['ship TSG star bow ' sprintf('%3.1f',nan) ' m'],...
    ['ship TSG aft port ' sprintf('%3.1f',nan) ' m'],...
    'PSL snake 0.05 m','ROSR skin NaN','location','BestOutside');
set(gca(gcf),'XTick',the_jd:2/24:the_jd+1); datetick('x','HH:MM','keepticks');
xax = get(gca(gcf),'XTickLabel'); xax(end,:)='24:00'; set(gca(gcf),'XTickLabel',xax(:,1:2));
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL'},'FontSize',14,'FitBoxToText','off','LineStyle','none');
    print(graphdevice,ppath_SST);
    % copied

% LAT/LON TRACK PLOT - use ship lat/lon
map_day(a10.lon,a10.lat,cruise_str,PosLims,a1.t(1), the_jd)
    print(graphdevice,ppath_MAP);
    % copied

% GPS SOG/COG
figure;
subplot(2,1,1); plot(a10.jd, nondata,'-b',a10.jd, a10.sog,'--r');
xlabel('Hour (UTC)');ylabel('SOG (m/s)'); 
legend('ship','PSL','location','BestOutside'); grid;
title(sprintf('%s (%04i-%02i-%02i, DOY%03i).  GPS SOG/COG',cruise_str,the_yr,the_mo,the_day,the_jd),'FontWeight','Bold','Interpreter','none');
xlim([the_jd the_jd+1]); ylim([0 8]); set(gca(gcf),'XTick',the_jd:2/24:the_jd+1);datetick('x','HH:MM','keepticks');
xax = get(gca(gcf),'XTickLabel'); xax(end,:)='24:00'; set(gca(gcf),'XTickLabel',xax(:,1:2));

subplot(2,1,2); plot(a10.jd, nondata,'ob',a10.jd, a10.cog,'.r'); legend('ship','PSL','location','BestOutside');
xlabel('Hour (UTC)'); ylabel('COG (^o)'); axis([the_jd the_jd+1 0 360]); grid;
set(gca(gcf),'XTick',the_jd:2/24:the_jd+1); datetick('x','HH:MM','keepticks');
xax = get(gca(gcf),'XTickLabel'); xax(end,:)='24:00'; set(gca(gcf),'XTickLabel',xax(:,1:2));
orient tall;
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL'},'FontSize',14,'FitBoxToText','off','LineStyle','none');
    print(graphdevice,ppath_COGSOG);
    % copied

% HEADING
figure; plot(a10.jd, nondata, 'bo',a10.jd, a10.hed,'r.');
title(sprintf('%s (%04i-%02i-%02i, DOY%03i).  Heading',cruise_str,the_yr,the_mo,the_day,the_jd),'FontWeight','Bold','Interpreter','none');
xlabel('Hour (UTC)');ylabel('Heading (^o)'); 
legend('ship','PSL','location','BestOutside');
axis([ the_jd the_jd+1 0 360]); grid;
set(gca(gcf),'XTick',the_jd:2/24:the_jd+1); datetick('x','HH:MM','keepticks');
xax = get(gca(gcf),'XTickLabel'); xax(end,:)='24:00'; set(gca(gcf),'XTickLabel',xax(:,1:2));
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL'},'FontSize',14,'FitBoxToText','off','LineStyle','none');
    print(graphdevice,ppath_HED);

% PITCH ANGLE
figure; plot(a10.jd,r2d*a10.pitch,'r-'); grid;
title(sprintf('%s (%04i-%02i-%02i, DOY%03i).  PSL Pitch Angle ',cruise_str,the_yr,the_mo,the_day,the_jd),'FontWeight','Bold','Interpreter','none');
xlabel('Hour (UTC)'); ylabel('Pitch (^o)'); xlim([the_jd the_jd+1]);
set(gca(gcf),'XTick',the_jd:2/24:the_jd+1); datetick('x','HH:MM','keepticks');
xax = get(gca(gcf),'XTickLabel'); xax(end,:)='24:00'; set(gca(gcf),'XTickLabel',xax(:,1:2));
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL'},'FontSize',14,'FitBoxToText','off','LineStyle','none');
    print(graphdevice,ppath_PITCH);

% RELATIVE WIND SPEED & DIRECTION
figure; 
subplot(2,1,1); hold on;
plot(a10.jd, nondata, 'ob',a10.jd, a10.rdir,'.r');grid;
plot(...
    [the_jd the_jd+1],[60 60],'k:', ...
    [the_jd the_jd+1],[-60 -60],'k:', ...
    [the_jd the_jd+1],[90 90],'k-', ...
    [the_jd the_jd+1],[-90 -90],'k-');
xlabel('Hour (UTC)'); ylabel('Relative Wind Direction (^o)'); axis([the_jd the_jd+1 -180 180]); 
legend('ship','PSL','location','Northeastoutside'); 
title(sprintf('%s (%04i-%02i-%02i, DOY%03i).  Relative Wind Direction',cruise_str,the_yr,the_mo,the_day,the_jd),'FontWeight','Bold','Interpreter','none');
set(gca(gcf),'XTick',the_jd:2/24:the_jd+1); datetick('x','HH:MM','keepticks');
xax = get(gca(gcf),'XTickLabel'); xax(end,:)='24:00'; set(gca(gcf),'XTickLabel',xax(:,1:2));

subplot(2,1,2); hold on;
plot(a10.jd, nondata, '-b',a10.jd, a10.rspd, '-r');
legend('ship','PSL','location','Northeastoutside'); grid;
xlabel('Hour (UTC)'); ylabel('Relative Wind Speed (m/s)'); xlim([the_jd the_jd+1]);
title(sprintf('%s (%04i-%02i-%02i, DOY%03i).  Relative Wind Speed',cruise_str,the_yr,the_mo,the_day,the_jd),'FontWeight','Bold','Interpreter','none');
set(gca(gcf),'XTick',the_jd:2/24:the_jd+1); datetick('x','HH:MM','keepticks');
xax = get(gca(gcf),'XTickLabel'); xax(end,:)='24:00'; set(gca(gcf),'XTickLabel',xax(:,1:2));
%         orient tall;
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL'},'FontSize',14,'FitBoxToText','off','LineStyle','none');
    print(graphdevice,ppath_RW);

% TRUE WIND SPEED & DIRECTION 
figure;
subplot(2,1,1); hold on;
plot(a10.jd, nondata, 'bo',a10.jd, a10.wdir,'r.');
xlabel('Hour (UTC)'); ylabel('Wind Direction (^o)'); axis([the_jd the_jd+1 -5 365]);
legend('ship','PSL','location','Northeastoutside'); grid;
title(sprintf('%s (%04i-%02i-%02i, DOY%03i).  True Wind Direction',cruise_str,the_yr,the_mo,the_day,the_jd),'FontWeight','Bold','Interpreter','none');
set(gca(gcf),'XTick',the_jd:2/24:the_jd+1); datetick('x','HH:MM','keepticks');
set(gca(gcf),'YTick',0:45:360);
xax = get(gca(gcf),'XTickLabel'); xax(end,:)='24:00'; set(gca(gcf),'XTickLabel',xax(:,1:2));

subplot(2,1,2); hold on;
plot(a10.jd, nondata, 'b-',a10.jd, a10.wspd, 'r-'); 
xlabel('Hour (UTC)'); ylabel('Wind Speed (m/s)'); xlim([the_jd the_jd+1]);
legend('ship','PSL','location','Northeastoutside'); grid;
title(sprintf('%s (%04i-%02i-%02i, DOY%03i).  True Wind Speed',cruise_str,the_yr,the_mo,the_day,the_jd),'FontWeight','Bold','Interpreter','none');
set(gca(gcf),'XTick',the_jd:2/24:the_jd+1); datetick('x','HH:MM','keepticks');
xax = get(gca(gcf),'XTickLabel'); xax(end,:)='24:00'; set(gca(gcf),'XTickLabel',xax(:,1:2));
%         orient tall;
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL'},'FontSize',14,'FitBoxToText','off','LineStyle','none');
    print(graphdevice,ppath_TW);

% LICOR AGC
figure; hold on;
plot(a1.jd, a1.licor_agc, 'r.'); grid;
plot([a1.jd(1) a1.jd(end)], [60 60],':k');
title(sprintf('%s (%04i-%02i-%02i, DOY%03i).  Licor AGC ',cruise_str,the_yr,the_mo,the_day,the_jd),'FontWeight','Bold','Interpreter','none');
xlabel('Hour (UTC)'); ylabel('AGC'); xlim([the_jd the_jd+1]); ylim([45,100]);
legend('AGC value','upper limit for good data');
set(gca(gcf),'XTick',the_jd:2/24:the_jd+1);datetick('x','HH:MM','keepticks');
xax = get(gca(gcf),'XTickLabel'); xax(end,:)='24:00'; set(gca(gcf),'XTickLabel',xax(:,1:2));
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL'},'FontSize',14,'FitBoxToText','off','LineStyle','none');
    print(graphdevice,ppath_AGC);

% IR Radiation
% ii = find(isfinite(a10.lw_dn_clr));
figure; 
% subplot(2,1,1);
plot(a10.jd, a10.lw_dn_1,'r',a10.jd, a10.lw_dn_2,'k', a10.jd, nondata,'b',a10.jd,a10.lw_dn_clr,'--g'); xlim([the_jd the_jd+1]);
title(sprintf('%s (%04i-%02i-%02i, DOY%03i).  Downwelling Infrared Flux',cruise_str,the_yr,the_mo,the_day,the_jd),'FontWeight','Bold','Interpreter','none');
xlabel('Hour (UTC)'); ylabel('IR Flux (W/m^2)'); grid; legend('PIR1','PIR2','ship','Clearsky','Location','BestOutside');
set(gca(gcf),'XTick',the_jd:2/24:the_jd+1); datetick('x','HH:MM','keepticks');
xax = get(gca(gcf),'XTickLabel'); xax(end,:)='24:00'; set(gca(gcf),'XTickLabel',xax(:,1:2));

% subplot(2,1,2);
% plot(a10.jd, a10.lw_dn_2,'k'); xlim([the_jd the_jd+1]);
% title(sprintf('%s (%04i-%02i-%02i, DOY%03i).  Downwelling Infrared Flux',cruise_str,the_yr,the_mo,the_day,the_jd),'FontWeight','Bold','Interpreter','none');
% xlabel('Hour (UTC)'); ylabel('IR Flux (W/m^2)'); grid; legend('PIR2','Location','BestOutside');
% set(gca(gcf),'XTick',the_jd:2/24:the_jd+1); datetick('x','HH:MM','keepticks');
% xax = get(gca(gcf),'XTickLabel'); xax(end,:)='24:00'; set(gca(gcf),'XTickLabel',xax(:,1:2));
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL'},'FontSize',14,'FitBoxToText','off','LineStyle','none');
    print(graphdevice,ppath_IR);
  
%%% PIR thermopile output
figure;
plot(a10.jd,a10.lw_therm_1,'-', a10.jd, a10.lw_therm_2,'-', a10.jd, nondata,'-');
title(sprintf('%s (%04i-%02i-%02i, DOY%03i). Thermopile output',cruise_str,the_yr,the_mo,the_day,the_jd),'FontWeight','Bold','Interpreter','none');
legend('therm PIR-1','therm PIR-2','therm ship','Location','BestOutside');
xlabel('Hour (UTC)'); ylabel('W m^{-2}');
xlim([the_jd the_jd+1]); grid;
set(gca(gcf),'XTick',the_jd:2/24:the_jd+1); datetick('x','HH:MM','keepticks');
xax = get(gca(gcf),'XTickLabel'); xax(end,:)='24:00'; set(gca(gcf),'XTickLabel',xax(:,1:2));
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL'},'FontSize',14,'FitBoxToText','off','LineStyle','none');
    print(graphdevice,ppath_IR_therm);
  
    
    
% Solar Radiation
% ii = find(isfinite(a10.sw_dn_clr));
figure; plot(a10.jd, a10.sw_dn_1,'r',a10.jd, a10.sw_dn_2,'k', a10.jd, nondata,'b',a10.jd, a10.sw_dn_clr,'--g'); xlim([the_jd the_jd+1]);
title(sprintf('%s (%04i-%02i-%02i, DOY%03i).  Downwelling solar flux',cruise_str,the_yr,the_mo,the_day,the_jd),'FontWeight','Bold','Interpreter','none');
xlabel('Hour (UTC)');ylabel('Solar Flux (W/m^2)'); grid; legend('PSP1','PSP2','ship','Clearsky','Location','BestOutside');
set(gca(gcf),'XTick',the_jd:2/24:the_jd+1); datetick('x','HH:MM','keepticks');
xax = get(gca(gcf),'XTickLabel'); xax(end,:)='24:00';set(gca(gcf),'XTickLabel',xax(:,1:2));
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL'},'FontSize',14,'FitBoxToText','off','LineStyle','none');
    print(graphdevice,ppath_SW);

    
    
% 10-min bulk model plots... not doing these because fluxes will change
% when motion is finally corrected.

    % % NET HEAT FLUX
    % figure; plot(a1.jd, a1.hnet,'b-'); xlabel('Hour (UTC)'); ylabel('Heat flux (W/m^2)'); 
    % xlim([the_jd the_jd+1])
    % title(sprintf('%s (%04i-%02i-%02i, DOY%03i).  PSL Net Heat flux = %04.2f',cruise_str,the_yr,the_mo,the_day,the_jd,hm),'FontWeight','Bold','Interpreter','none');
    % set(gca(gcf),'XTick',the_jd:2/24:the_jd+1); datetick('x','HH:MM','keepticks'); grid;
    % xax = get(gca(gcf),'XTickLabel'); xax(end,:)='24:00'; set(gca(gcf),'XTickLabel',xax(:,1:2));
    % annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL'},'FontSize',14,'FitBoxToText','off','LineStyle','none');
    %     ppath = fullfile(path_raw_images,['Net_Heat'],['Net_Heat_Flux_',sprintf('%04i_%02i_%02i_%03i',the_yr,the_mo,the_day,the_jd),graphformat]);
    %     print(graphdevice,ppath);

    % Bulk fluxes
    figure; hold on;
    plot(a10.jd, a10.hnet,'-k','linewidth',2.5);
    plot(a10.jd, a10.sw_net, a10.jd, a10.lw_net, a10.jd, -a10.hl, a10.jd, -a10.hs, a10.jd, -a10.hrain);
    leg = legend('net','net solar','net infrared','-latent','-sensible','-rain','location','north');
    % title(leg,'Surface Heat Fluxes')
    datetick('x');
        title(sprintf('%s (%04i-%02i-%02i, DOY%03i).  Bulk Surface Fluxes',cruise_str,the_yr,...
            the_mo,the_day,the_jd),'FontWeight','Bold','Interpreter','none')
        xlabel('Hour UTC');ylabel('W m^{-2}'); grid;
        ylim([-450, 1000]);
        xax=get(gca(gcf),'XTickLabel');xax(end,:)='24:00';set(gca(gcf),'XTickLabel',xax(:,1:2));
        annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',...
            {'NOAA PSL'},'FontSize',15,'FitBoxToText','off','LineStyle','none');
    text(a10.jd(end)+datenum(0,0,0,0,20,0),270,'warming','fontsize',20,'fontweight','bold','horizontalalignment','left');
    text(a10.jd(end)+datenum(0,0,0,0,20,0),200,'surface','fontsize',20,'fontweight','bold','horizontalalignment','left');
    text(a10.jd(end)+datenum(0,0,0,0,20,0),-200,'cooling','fontsize',20,'fontweight','bold','horizontalalignment','left');
    text(a10.jd(end)+datenum(0,0,0,0,20,0),-270,'surface','fontsize',20,'fontweight','bold','horizontalalignment','left');
        print(graphdevice,ppath_BULK);

    % % BULK FRICTION VELOCITY
    % figure; plot(a10.jd, a10.ustar,'r'); xlabel('Hour (UTC)'); ylabel('u_*(m/s)'); xlim([the_jd the_jd+1]);
    % title(sprintf('%s (%04i-%02i-%02i, DOY%03i).  PSL Friction Velocity from COARE algorithm 3.5',cruise_str,the_yr,the_mo,the_day,the_jd),'FontWeight','Bold','Interpreter','none');
    % set(gca(gcf),'XTick',the_jd:2/24:the_jd+1);datetick('x','HH:MM','keepticks'); grid;
    % xax = get(gca(gcf),'XTickLabel'); xax(end,:)='24:00'; set(gca(gcf),'XTickLabel',xax(:,1:2));
    % annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL'},'FontSize',14,'FitBoxToText','off','LineStyle','none');
    %     ppath = fullfile(path_raw_images,['u-star'],['Friction_Velocity_',sprintf('%04i_%02i_%02i_%03i',the_yr,the_mo,the_day,the_jd),graphformat]);
    %     print(graphdevice,ppath);

    
%close all;

end %%% if loop for plotting only if data are there
end  %%% end function