clear all;
close all;

warning ('off','MATLAB:MKDIR:DirectoryExists');

cruise = 'ATOMIC_2020';     % Cruise name
cruise_str = 'ATOMIC';  % cruise name without _
yyyy = '2020';         % year string
ship = 'Brown';        % Research vessel

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
set(0,'DefaultLegendAutoUpdate','off')


fluxdir         = '/Users/eliz/DATA/ATOMIC_2020/Brown/flux/Field_Processed/flux_met_sea/';
metdir          = '/Users/eliz/DATA/ATOMIC_2020/Brown/flux/Field_Processed/met_sea/';
plotdir         = '/Users/eliz/DATA/ATOMIC_2020/Brown/flux/Processed_Images/cruise/';
the_10flux_file = 'ATOMIC_2020_10min_flux_met_sea_data_v1.mat';
the_1met_file   = 'ATOMIC_2020_1min_met_sea_data_v1.mat';
the_10met_file  = 'ATOMIC_2020_10min_met_sea_data_v1.mat';
cruise_title    = 'ATOMIC 2020';
cruise_file_str = 'ATOMIC_2020';

graphformat     = '.png';  % select graphics format
graphdevice     = '-dpng'; % select graphic device

load([fluxdir   the_10flux_file]);  % c10
load([metdir    the_1met_file]);    % c1
load([metdir    the_10met_file]);   % g10

leg_pos = [0.25,0.85,0.1,0.1];


plot_day = 0;
if plot_day == 1
    xrange = [datenum(2019,9,23,0,0,0) max(c10.t)];
    pst = '_dwl';
    fst = 'dd'; % for plotting labels by hour
else
    xrange = [min(c10.t) max(c10.t)];
    pst = '';
    fst = 'dd'; % for plotting labels by day
end

%==========================================================================
%%% calculate things for buoyancy flux;

% PSD sensor heights above sea level (m)... see ATOMIC_hght_sensors.m
zu = 18.0;          % wind speed measurement height (m)
zt = 17.0;          % air T measurement height (m)
zq = 17.0;          % air q measurement height (m)
zp = 14.40;         % psd pressure sensor height (m)
zwxt = 15;          % wxt height height (m)
zsnk = 0.05;      % depth of snake

c10.P10          = c10.slp - 0.125*10;    
c10.rhoa10       = sw_airden(c10.T10,c10.P10,c10.rh10);
c10.rhoas        = sw_airden(c10.sst,c10.slp,100);
% c10.rhoa       = c10.rhoa;  % output from coare, saved already ... is it different?
c10.thetav10     = sw_virtpottmp(c10.T10,c10.P10,c10.rh10);
c10.thetavs      = sw_virtpottmp(c10.sst,c10.slp,100);
x = (9.81 ./ c10.thetav10) .* (1./(1004*c10.rhoa));

[F, lhf_ef, coeff_lhf] = buoy_flux_atm(c10.sst,6,c10.hl,c10.hs,c10.rhoa, c10.thetav10);

mean_SST_K = movmean(c10.sst,6)+273.15;
F_dT_coeff_bulk = 1.25*1004*c10.Ch;
F_dq_coeff_bulk = 0.61*1.25*1004*mean_SST_K.*c10.Ce*(1E-3);
thermo_bulk = F_dT_coeff_bulk.*c10.dT + F_dq_coeff_bulk.*c10.dq;
thermo_dT = F_dT_coeff_bulk.*c10.dT;
thermo_dq = F_dq_coeff_bulk.*c10.dq;

perc_dT_thermo_hr = 100*(thermo_dT/thermo_bulk);
perc_dq_thermo_hr = 100*(thermo_dq/thermo_bulk);

U_norm_F = c10.U10./F;
therm_norm_F = thermo_bulk./F;

num_days = (c10.t(end-143) - c10.t(1))+1;
hnet_finite = c10.hnet;
bad_hnet = find(isnan(c10.hnet) == 1 | isfinite(c10.hnet) ~= 1);
hnet_finite(bad_hnet) = 0;
sum_hnet = sum(hnet_finite);
daily_sum_hnet = sum_hnet / num_days;

[y0, m0, d0, h0, min0, s0] = datevec(c10.t);
hnet_hrs = [];
hr_hrs = [];
sw_hrs = [];
lw_hrs = [];
hl_hrs = [];
hs_hrs = [];
prate_hrs = [];
tau_hrs = [];
tau_cov_hrs = [];
tau_ida_hrs = [];
hl_covW_hrs = [];
hs_covW_hrs = [];
hl_id_hrs = [];
hs_id_hrs = [];
buoy_hrs = [];
buoy_thermo_hrs = [];
sst_hrs = [];
u_hrs = [];

for i = 0:23
%     the_hr = find(h0 == i);
%     disp(i);
%     the_avg = nanmean1(c10.hnet(h0 == i));
%     eval(['hnet_' sprintf('%i',i) ' = the_avg;' ]);
    hnet_hrs = [hnet_hrs; nanmean1(c10.hnet(h0 == i))];
    hr_hrs = [hr_hrs; nanmean1(c10.hr(h0 == i))];
    sw_hrs = [sw_hrs; nanmean1(c10.sw_net(h0 == i))];
    lw_hrs = [lw_hrs; nanmean1(c10.lw_net(h0 == i))];
    hl_hrs = [hl_hrs; nanmean1(c10.hl(h0 == i))];
    hl_covW_hrs = [hl_covW_hrs; nanmean1(c10.hl_covW(h0 == i))];
    hl_id_hrs = [hl_id_hrs; nanmean1(c10.hl_id(h0 == i))];
    hs_hrs = [hs_hrs; nanmean1(c10.hs(h0 == i))];
    hs_covW_hrs = [hs_covW_hrs; nanmean1(c10.hs_covW(h0 == i))];
    hs_id_hrs = [hs_id_hrs; nanmean1(c10.hs_id(h0 == i))];
    prate_hrs = [prate_hrs; nanmean1(c10.prate(h0 == i))];
    tau_hrs = [tau_hrs; nanmean1(c10.tau(h0 == i))];
    tau_cov_hrs = [tau_cov_hrs; nanmean1(c10.tau_cov(h0 == i))];
    tau_ida_hrs = [tau_ida_hrs; nanmean1(c10.tau_ida(h0 == i))];
    buoy_hrs = [buoy_hrs; nanmean1(F(h0 == i))];
    buoy_thermo_hrs = [buoy_thermo_hrs; nanmean1(thermo_bulk(h0 == i))];
    sst_hrs = [sst_hrs; nanmean1(c10.sst(h0 == i))];
    u_hrs = [u_hrs; nanmean1(c10.U10(h0 == i))];
    dT_hrs = [dT_hrs; nanmean1(c10.U10(h0 == i))];
    dq_hrs = [dq_hrs; nanmean1(c10.U10(h0 == i))];

end

hnet_day_mean = nanmean1(hnet_hrs);

% calculate daily net heat flux for days when we sampled the full day
jd_i = floor(c10.jd);
[jd_u,id_u] = unique(jd_i);
hnet_day = nan(1,length(jd_u));

for i = 1:length(jd_u)
    wh_today = find(jd_i == jd_u(i));
    wh_good_today = find(isfinite(c10.hnet(wh_today)) == 1);
    if length(wh_good_today) > 130
        hnet_day(i) = nanmean1(c10.hnet(wh_today));
    end
end

t_u = jd_u + datenum(y0(1), 0,0,0,0,0);

hnet_mean = nanmean1(hnet_day);


%==========================================================================

%%% daily avg net heat flux
figure; hold on;
plot(t_u, hnet_day,'-o');
plot(max(xlim)-2,hnet_mean,'pb','markersize',20,'markerfacecolor','b');
title([cruise_title ' Mean Net Surface Heat Flux']);
grid on;
xlim(xrange); datetick('x','dd','keeplimits');
ylabel('W m^{-2}');
xlabel('UTC');
text(max(xlim)-1,hnet_mean-10,'mean','horizontalalignment','center','fontsize',20,'color','b');
text(max(xlim)+0.5,50,'UP','fontsize',20,'fontweight','bold','horizontalalignment','center');
text(max(xlim)+0.5,-50,'DOWN','fontsize',20,'fontweight','bold','horizontalalignment','center');
leg = legend('h_{net}','location','southwest');
title(leg,'daily mean');
plot(xlim,[0 0],'--','color',rgb('gray'));
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',...
    {'NOAA ESRL PSD'},'FontSize',16,'color','b','FitBoxToText','off','LineStyle','none');
ppath = [plotdir cruise_file_str '_mean_heat' pst];
print(graphdevice,ppath);

%%% hourly average net heat flux
figure('position',[1,1,600,700]); hold on;
plot(0:24,[hnet_hrs; hnet_hrs(1)],'-o','linewidth',3);
plot(24,hnet_day_mean,'pb','markersize',20,'markerfacecolor','b');
title([cruise_title ' Mean Net Surface Heat Flux']);
grid on;
ylim([-800 300]);
xlim([0 24]);
set(gca,'xtick',0:4:24);
ylabel('W m^{-2}');
xlabel('UTC');
text(24,hnet_day_mean+50,'daily mean','horizontalalignment','center','fontsize',20,'color','b');
text(10,-50,'sunrise','horizontalalignment','center','fontsize',20,'color',rgb('darkorange'));
text(21,-50,'sunset','horizontalalignment','center','fontsize',20,'color',rgb('darkorange'));
text(24.4,200,'UP','fontsize',20,'fontweight','bold','horizontalalignment','center');
text(24.4,-200,'DOWN','fontsize',20,'fontweight','bold','horizontalalignment','center');
leg = legend('h_{net}','location','southwest');
title(leg,'hourly composite');
plot(xlim,[0 0],'--','color',rgb('gray'));
plot([21 21], ylim,'--','color',rgb('orange'));
plot([10 10], ylim,'--','color',rgb('orange'));
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',...
    {'NOAA ESRL PSD'},'FontSize',16,'color','b','FitBoxToText','off','LineStyle','none');
ppath = [plotdir cruise_file_str '_day_heat' pst];
print(graphdevice,ppath);
    
    


%%% hourly average components of heat flux
figure('position',[1,1,600,700]); hold on;
plot(0:24,[hnet_hrs; hnet_hrs(1)],'-k','linewidth',3);
plot(0:24,[sw_hrs; sw_hrs(1)],'-');
plot(0:24,[lw_hrs; lw_hrs(1)],'-');
plot(0:24,[hl_hrs; hl_hrs(1)],'-');
plot(0:24,[hs_hrs; hs_hrs(1)],'-');
plot(0:24,[hr_hrs; hr_hrs(1)],'-');
plot(24,hnet_day_mean,'pb','markersize',20,'markerfacecolor','b');
leg = legend('net','solar','infrared','latent','sensible','rain','location','southwest');
title(leg,'hourly composite');
title([cruise_title ' Mean Surface Heat Flux Components']);
grid on;
ylim([-800 300]);
xlim([0 24]);
set(gca,'xtick',0:4:24);
ylabel('W m^{-2}');
xlabel('UTC');
text(23.5,hnet_day_mean+50,'daily net mean','horizontalalignment','center','fontsize',20,'color','b');
text(10,-50,'sunrise','horizontalalignment','center','fontsize',20,'color',rgb('darkorange'));
text(21,-50,'sunset','horizontalalignment','center','fontsize',20,'color',rgb('darkorange'));
text(24.4,200,'UP','fontsize',20,'fontweight','bold','horizontalalignment','center');
text(24.4,-200,'DOWN','fontsize',20,'fontweight','bold','horizontalalignment','center');
plot(xlim,[0 0],'--','color',rgb('gray'));
plot([21 21], ylim,'--','color',rgb('orange'));
plot([10 10], ylim,'--','color',rgb('orange'));
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',...
    {'NOAA ESRL PSD'},'FontSize',16,'color','b','FitBoxToText','off','LineStyle','none');
ppath = [plotdir cruise_file_str '_day_heat_parts' pst];
print(graphdevice,ppath);

%%% hourly average stress
figure('position',[1,1,600,700]); hold on;
plot(0:24,[tau_hrs; tau_hrs(1)],'-k');
plot(0:24,[tau_cov_hrs; tau_cov_hrs(1)],'-');
plot(0:24,[tau_ida_hrs; tau_ida_hrs(1)],'-');
leg = legend('bulk','eddy covariance','inertial dissipation','location','southwest');
title(leg,'hourly composite');
title([cruise_title ' Mean Surface \tau']);
grid on;
xlim([0 24]);
set(gca,'xtick',0:4:24);
plot(xlim,[0 0],'-','color',rgb('gray'));
plot([21 21], ylim,'--','color',rgb('orange'));
plot([10 10], ylim,'--','color',rgb('orange'));
ylabel('N m^{-2}');
xlabel('UTC');
text(10,mean(ylim),'sunrise','horizontalalignment','center','fontsize',20,'color',rgb('darkorange'));
text(21,mean(ylim),'sunset','horizontalalignment','center','fontsize',20,'color',rgb('darkorange'));
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',...
    {'NOAA ESRL PSD'},'FontSize',16,'color','b','FitBoxToText','off','LineStyle','none');
ppath = [plotdir cruise_file_str '_day_tau' pst];
print(graphdevice,ppath);

%%% hourly average hl
figure('position',[1,1,600,700]); hold on;
plot(0:24,[hl_hrs; hl_hrs(1)],'-k');
plot(0:24,[hl_covW_hrs; hl_covW_hrs(1)],'-');
plot(0:24,[hl_id_hrs; hl_id_hrs(1)],'-');
leg = legend('bulk','eddy covariance','inertial dissipation','location','southwest');
title(leg,'hourly composite');
title([cruise_title ' Mean Surface h_l']);
grid on;
xlim([0 24]);
set(gca,'xtick',0:4:24);
plot(xlim,[0 0],'-','color',rgb('gray'));
plot([21 21], ylim,'--','color',rgb('orange'));
plot([10 10], ylim,'--','color',rgb('orange'));
ylabel('W m^{-2}');
xlabel('UTC');
text(10,mean(ylim),'sunrise','horizontalalignment','center','fontsize',20,'color',rgb('darkorange'));
text(21,mean(ylim),'sunset','horizontalalignment','center','fontsize',20,'color',rgb('darkorange'));
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',...
    {'NOAA ESRL PSD'},'FontSize',16,'color','b','FitBoxToText','off','LineStyle','none');
ppath = [plotdir cruise_file_str '_day_hl' pst];
print(graphdevice,ppath);


%%% hourly average hs
figure('position',[1,1,600,700]); hold on;
plot(0:24,[hs_hrs; hs_hrs(1)],'-k');
plot(0:24,[hs_covW_hrs; hs_covW_hrs(1)],'-');
plot(0:24,[hs_id_hrs; hs_id_hrs(1)],'-');
leg = legend('bulk','eddy covariance','inertial dissipation','location','southwest');
title(leg,'hourly composite');
title([cruise_title ' Mean Surface h_s']);
grid on;
xlim([0 24]);
set(gca,'xtick',0:4:24);
plot(xlim,[0 0],'-','color',rgb('gray'));
plot([21 21], ylim,'--','color',rgb('orange'));
plot([10 10], ylim,'--','color',rgb('orange'));
ylabel('W m^{-2}');
xlabel('UTC');
text(10,mean(ylim),'sunrise','horizontalalignment','center','fontsize',20,'color',rgb('darkorange'));
text(21,mean(ylim),'sunset','horizontalalignment','center','fontsize',20,'color',rgb('darkorange'));
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',...
    {'NOAA ESRL PSD'},'FontSize',16,'color','b','FitBoxToText','off','LineStyle','none');
ppath = [plotdir cruise_file_str '_day_hs' pst];
print(graphdevice,ppath);

%%% hourly average buoyancy
figure('position',[1,1,600,700]); hold on;
yyaxis right;
plot(0:24,[buoy_hrs; buoy_hrs(1)],'-');
ylabel('m^2 s^{-3}');

yyaxis left; hold on;
plot(0:24,[buoy_thermo_hrs; buoy_thermo_hrs(1)],'-');

% legend('\tau','F','F_{thermo}','location','best');
ylabel('m s^{-2}');
xlabel('UTC');

leg = legend('F','F_{thermo}','location','southwest');
title(leg,'hourly composite');
title([cruise_title ' Mean Buoyancy Flux into Air']);
grid on;
% ylim([-600 300]);
xlim([0 24]);
set(gca,'xtick',0:4:24);
plot(xlim,[0 0],'-','color',rgb('gray'));
plot([21 21], ylim,'--','color',rgb('orange'));
plot([10 10], ylim,'--','color',rgb('orange'));
ylabel('W m^{-2}');
xlabel('UTC');
text(10,mean(buoy_thermo_hrs),'sunrise','horizontalalignment','center','fontsize',20,'color',rgb('darkorange'));
text(21,mean(buoy_thermo_hrs),'sunset','horizontalalignment','center','fontsize',20,'color',rgb('darkorange'));
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',...
    {'NOAA ESRL PSD'},'FontSize',16,'color','b','FitBoxToText','off','LineStyle','none');
ppath = [plotdir cruise_file_str '_day_buoy' pst];
print(graphdevice,ppath);

%%% hourly average net heat flux
figure('position',[1,1,600,700]); hold on;
yyaxis left;
plot(0:24,[sst_hrs; sst_hrs(1)],'-');
ylabel('^oC');

yyaxis right;
plot(0:24,[prate_hrs; prate_hrs(1)],'-');

title([cruise_title ' Mean SST and rain']);
grid on;
xlim([0 24]);
set(gca,'xtick',0:4:24);
ylabel('mm hr^{-1}');
xlabel('UTC');
text(10,mean(ylim),'sunrise','horizontalalignment','center','fontsize',20,'color',rgb('darkorange'));
text(21,mean(ylim),'sunset','horizontalalignment','center','fontsize',20,'color',rgb('darkorange'));
leg = legend('SST','rain rate','location','northwest');
title(leg,'hourly composite');
plot(xlim,[0 0],'--','color',rgb('gray'));
plot([21 21], ylim,'--','color',rgb('orange'));
plot([10 10], ylim,'--','color',rgb('orange'));
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',...
    {'NOAA ESRL PSD'},'FontSize',16,'color','b','FitBoxToText','off','LineStyle','none');
ppath = [plotdir cruise_file_str '_day_sst_rain' pst];
print(graphdevice,ppath);

%%% hourly average wind
figure('position',[1,1,600,700]); hold on;
plot(0:24,[u_hrs; u_hrs(1)],'-k');
leg = legend('U_{10}','location','southwest');
title(leg,'hourly composite');
title([cruise_title ' Mean Surface Wind Speed']);
grid on;
ylim([7.5 9]);
xlim([0 24]);
set(gca,'xtick',0:4:24);
plot(xlim,[0 0],'-','color',rgb('gray'));
plot([21 21], ylim,'--','color',rgb('orange'));
plot([10 10], ylim,'--','color',rgb('orange'));
ylabel('m s^{-1}');
xlabel('UTC');
text(10,mean(ylim),'sunrise','horizontalalignment','center','fontsize',20,'color',rgb('darkorange'));
text(21,mean(ylim),'sunset','horizontalalignment','center','fontsize',20,'color',rgb('darkorange'));
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',...
    {'NOAA ESRL PSD'},'FontSize',16,'color','b','FitBoxToText','off','LineStyle','none');
ppath = [plotdir cruise_file_str '_day_u' pst];
print(graphdevice,ppath);

%--------------------------------------------------------------------------

make_plots = 0;
if make_plots == 1
    
    
%%% radiation
figure; hold on;
plot(c10.t, c10.sw_net); datetick;
plot(c10.t, c10.sw_dn); 
% plot(c10.t, c10.sw_cl,'--'); 
plot(c10.t, c10.sw_up); 
plot(c10.t, c10.lw_net); 
plot(c10.t, c10.lw_dn);
% plot(c10.t, c10.IRdn_clear,'--'); 
plot(c10.t, c10.lw_up,'--'); 
xlim(xrange); datetick('x','dd','keeplimits');
ylabel('W m^{-2}');
title([cruise_title ' radiative fluxes']);
% leg = legend('Solarnet','Solardn','Solardn clear','Solarup','IRnet','IRdn','IRdn clear','IRup','location','eastoutside');
leg = legend('solar net','solar down','solar up','IR net','IR down','IR up');
set(leg,'location','eastoutside');
set(leg,'fontsize',22);
grid on;
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',...
    {'NOAA ESRL PSD'},'FontSize',16,'color','b','FitBoxToText','off','LineStyle','none');
annotation(gcf,'textbox',[0.2 0.03 0.4498 0.02462],'String',...
    {'Jan'},'FontSize',16,'color','k','fontweight','bold','FitBoxToText','off','LineStyle','none');
annotation(gcf,'textbox',[0.7 0.03 0.4498 0.02462],'String',...
    {'Feb'},'FontSize',20,'color','k','fontweight','bold','FitBoxToText','off','LineStyle','none');

ppath = [plotdir cruise_file_str '_rad' pst];
print(graphdevice,ppath);
    
% all fluxes 
figure; hold on;
plot(c10.t, c10.hnet,'-k','linewidth',2.5);
plot(c10.t, c10.sw_net, c10.t, c10.lw_net, c10.t, c10.hl, c10.t, c10.hs, c10.t, c10.hr);
leg = legend('net','solar','infrared','latent','sensible','rain');
set(leg,'location','eastoutside');
xlim(xrange); datetick('x','dd','keeplimits');
ylabel('W m^{-2}');
title([cruise_title ' net heat flux (- into ocean): hnet = Solarnet + IRnet + hs + hl + hr']);
% 'location','eastoutside');
set(leg,'fontsize',22);
grid on;
% text(c10.t(100),-950,['Integrated Daily Avg Surface Heat Flux: ' sprintf('%.0f',sum_hnet)],...
%     'fontsize',20);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',...
    {'NOAA ESRL PSD'},'FontSize',16,'color','b','FitBoxToText','off','LineStyle','none');
annotation(gcf,'textbox',[0.2 0.03 0.4498 0.02462],'String',...
    {'Jan'},'FontSize',16,'color','k','fontweight','bold','FitBoxToText','off','LineStyle','none');
annotation(gcf,'textbox',[0.7 0.03 0.4498 0.02462],'String',...
    {'Feb'},'FontSize',20,'color','k','fontweight','bold','FitBoxToText','off','LineStyle','none');
ppath = [plotdir cruise_file_str '_net' pst];
print(graphdevice,ppath);

%%% momentum
figure; hold on;
plot(c10.t, c10.ustar, c10.t, c10.tau);
xlim(xrange); datetick('x','dd','keeplimits');
leg = legend('u*','\tau');
set(leg,'position',leg_pos+[0.3 -0.04 0 0]);
set(leg,'fontsize',22);
grid on;
ylabel('m s^{-1} or N m^{-2}');
title([cruise_title ' momentum flux']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',...
    {'NOAA ESRL PSD'},'FontSize',16,'color','b','FitBoxToText','off','LineStyle','none');
annotation(gcf,'textbox',[0.2 0.03 0.4498 0.02462],'String',...
    {'Jan'},'FontSize',16,'color','k','fontweight','bold','FitBoxToText','off','LineStyle','none');
annotation(gcf,'textbox',[0.7 0.03 0.4498 0.02462],'String',...
    {'Feb'},'FontSize',20,'color','k','fontweight','bold','FitBoxToText','off','LineStyle','none');
ppath = [plotdir cruise_file_str '_tau' pst];
print(graphdevice,ppath);

%%% moisture
fig = figure;
left_color = rgb('black');
right_color = rgb('coral');
set(fig,'defaultAxesColorOrder',[left_color; right_color]);
yyaxis left; hold on;
plot(c10.t, c10.qs,'-b');
plot(c10.t, c10.q10,'-','color',rgb('gray'));
ylabel('q, g kg^{-1}');
yyaxis right;
plot(c10.t, c10.dq,'-','color',rgb('coral'));
leg = legend('qs: from sst','q_{10}','dq: qs - q_{10}');
set(leg,'position',leg_pos+[-0.02 0.01 0 0]);
set(leg,'fontsize',22);
ylabel('dq, g kg^{-1}');
xlim(xrange); datetick('x','dd','keeplimits');
grid on;
title([cruise_title ' air-sea humidity gradients']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',...
    {'NOAA ESRL PSD'},'FontSize',16,'color','b','FitBoxToText','off','LineStyle','none');
annotation(gcf,'textbox',[0.2 0.03 0.4498 0.02462],'String',...
    {'Jan'},'FontSize',16,'color','k','fontweight','bold','FitBoxToText','off','LineStyle','none');
annotation(gcf,'textbox',[0.7 0.03 0.4498 0.02462],'String',...
    {'Feb'},'FontSize',20,'color','k','fontweight','bold','FitBoxToText','off','LineStyle','none');
ppath = [plotdir cruise_file_str '_q' pst];
print(graphdevice,ppath);

%%% rain and evap
fig = figure;
left_color = rgb('purple');
right_color = rgb('deepskyblue');
set(fig,'defaultAxesColorOrder',[left_color; right_color]);
yyaxis left;
plot(c1.t, c1.prate, 'color',rgb('purple'));
ylabel('P: mm h^{-1}');
yyaxis right;
plot(c10.t, c10.evap,'color',rgb('deepskyblue'));
xlim(xrange); datetick('x','dd','keeplimits');
leg = legend('Rain Rate','Evaporation Rate');
set(leg,'position',leg_pos+[0.3 -0.04 0 0]);
set(leg,'fontsize',22);
ylabel('E: mm h^{-1}');
grid on;
title([cruise_title ' freshwater']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',...
    {'NOAA ESRL PSD'},'FontSize',16,'color','b','FitBoxToText','off','LineStyle','none');
annotation(gcf,'textbox',[0.2 0.03 0.4498 0.02462],'String',...
    {'Jan'},'FontSize',16,'color','k','fontweight','bold','FitBoxToText','off','LineStyle','none');
annotation(gcf,'textbox',[0.7 0.03 0.4498 0.02462],'String',...
    {'Feb'},'FontSize',20,'color','k','fontweight','bold','FitBoxToText','off','LineStyle','none');
ppath = [plotdir cruise_file_str '_rain' pst];
print(graphdevice,ppath);


%%% seawater temperature
figure; hold on;
plot(c10.t, c10.Tskin,'o', c10.t, c10.sst, c10.t, c10.Tsnk,...
    c10.t, c10.Ttsg); %c10.t, c10.T10N);
% plot(c10.t, c10.Ttsg,':k');
xlim(xrange); datetick('x','dd','keeplimits');
ylabel('^o C');
leg = legend('T_{skin}: ROSR','T_{skin}: T_{snake} - cool skin',...
    ['T_{snake} @ 0.05 m'],...
    ['T_{TSG} @ ' sprintf('%3.1f',c10.ztsg_ship) ' m']);
set(leg,'position',leg_pos+[0 -0.05 0 0 ]);
%     'sst = Tsnake - skin dT - 0.12^oC correction','Tsnake: 0.05 m','location','northwest');
set(leg,'fontsize',22);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',...
    {'NOAA ESRL PSD'},'FontSize',16,'color','b','FitBoxToText','off','LineStyle','none');
annotation(gcf,'textbox',[0.2 0.03 0.4498 0.02462],'String',...
    {'Jan'},'FontSize',16,'color','k','fontweight','bold','FitBoxToText','off','LineStyle','none');
annotation(gcf,'textbox',[0.7 0.03 0.4498 0.02462],'String',...
    {'Feb'},'FontSize',20,'color','k','fontweight','bold','FitBoxToText','off','LineStyle','none');
grid on;
title([cruise_title ' seawater T']);
ppath = [plotdir cruise_file_str '_Tsea' pst];
print(graphdevice,ppath);


%%% air temperature, and air-sea difference
fig = figure;
left_color = rgb('black');
right_color = rgb('coral');
set(fig,'defaultAxesColorOrder',[left_color; right_color]);
yyaxis left; hold on;
plot(c10.t, c10.sst,'-b');
plot(c10.t, c10.T10,'-','color',rgb('gray'));
xlim(xrange); datetick('x','dd','keeplimits');
ylabel('T, ^o C');
grid on;
yyaxis right;
plot(c10.t, c10.dT,'-','color',rgb('coral'));
ylabel('dT, ^o C');
xlim(xrange); datetick('x','dd','keeplimits');
leg = legend('sst','T_{10}','dT: sst - T_{10}');
set(leg,'position',leg_pos);
set(leg,'fontsize',22);
grid on;
title([cruise_title ' air-sea T gradients']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',...
    {'NOAA ESRL PSD'},'FontSize',16,'color','b','FitBoxToText','off','LineStyle','none');
annotation(gcf,'textbox',[0.2 0.03 0.4498 0.02462],'String',...
    {'Jan'},'FontSize',16,'color','k','fontweight','bold','FitBoxToText','off','LineStyle','none');
annotation(gcf,'textbox',[0.7 0.03 0.4498 0.02462],'String',...
    {'Feb'},'FontSize',20,'color','k','fontweight','bold','FitBoxToText','off','LineStyle','none');
ppath = [plotdir cruise_file_str '_Tair' pst];
print(graphdevice,ppath);


% %%% wind and fluxes
% figure; hold on;
% plot(c10.t, c10.dT,'-','color',rgb('coral'));
% plot(c10.t, c10.U10,'-','color',rgb('seagreen'));
% plot(c10.t, c10.hs,'-','color',rgb('black'));
% legend('air-sea \DeltaT');
% legend('


%%% IR
figure;
yyaxis left;
plot(c10.t, c10.lw_net);
ylabel('W m^{-2}');
yyaxis right;
plot(c10.t, c10.lw_dn);
ylabel('W m^{-2}');
xlim(xrange); datetick('x','dd','keeplimits');
leg = legend('IR net','IR down');
set(leg,'position',leg_pos);
set(leg,'fontsize',22);
grid on;
title([cruise_title ' IR']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',...
    {'NOAA ESRL PSD'},'FontSize',16,'color','b','FitBoxToText','off','LineStyle','none');
annotation(gcf,'textbox',[0.2 0.03 0.4498 0.02462],'String',...
    {'Jan'},'FontSize',16,'color','k','fontweight','bold','FitBoxToText','off','LineStyle','none');
annotation(gcf,'textbox',[0.7 0.03 0.4498 0.02462],'String',...
    {'Feb'},'FontSize',20,'color','k','fontweight','bold','FitBoxToText','off','LineStyle','none');
ppath = [plotdir cruise_file_str '_IR' pst];
print(graphdevice,ppath);

%%%%% latent, sensible, wind
fig = figure; 
left_color = rgb('black');
right_color = rgb('darkgreen');
set(fig,'defaultAxesColorOrder',[left_color; right_color]);
yyaxis left; hold on;
set(gca,'YColor',rgb('black'));
plot(c10.t, c10.U10,'-','linewidth',2);
plot(c10.t, c10.hs,'-r');
ylabel('m s^{-1}, sensible W m^{-2}');
yyaxis right;
plot(c10.t, c10.hl,'-','color',rgb('limegreen'));
ylabel('latent W m^{-2}');
xlim(xrange); datetick('x','dd','keeplimits');
leg = legend('U_{10}','hs: sensible heat flux','hl: latent heat flux');
set(leg,'position',leg_pos+[0.3 -.05 0 0]);
set(leg,'fontsize',22);
grid on;
title([cruise_title ' turbulent heat and moisture fluxes']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',...
    {'NOAA ESRL PSD'},'FontSize',16,'color','b','FitBoxToText','off','LineStyle','none');
annotation(gcf,'textbox',[0.2 0.03 0.4498 0.02462],'String',...
    {'Jan'},'FontSize',16,'color','k','fontweight','bold','FitBoxToText','off','LineStyle','none');
annotation(gcf,'textbox',[0.7 0.03 0.4498 0.02462],'String',...
    {'Feb'},'FontSize',20,'color','k','fontweight','bold','FitBoxToText','off','LineStyle','none');
ppath = [plotdir cruise_file_str '_wind_fluxes' pst];
print(graphdevice,ppath);


%%% buoyancy flux components
figure; hold on;
% plot(c10.t, f15(-x.*c10.hs),'-','color',rgb('darkorange'));
% plot(c10.t, f15(x.*lhf_ef),'-','color',rgb('purple'));
plot(c10.t, f15(x.*c10.hs),'-','color',rgb('red'));
plot(c10.t, f15(x.*lhf_ef),'-','color',rgb('limegreen'));
plot(c10.t, f15(F),'-','color',rgb('darkgray'),'linewidth',3)
% plot(c10.t, (-x.*c10.hs) + (x.*lhf_ef),'-k') ; %%% check the sum
ylabel('m^{2} s^{-3}');
xlim(xrange); datetick('x','dd','keeplimits');
leg = legend('sensible heat flux','\Lambda latent heat flux','buoyancy flux into air');
set(leg,'position',leg_pos+[0.5 -0.05 0 0]);
set(leg,'fontsize',22);
grid on;
% yyaxis right
% plot(c10.t, c10.sst,':','color',rgb('skyblue'));
title([cruise_title ' buoyancy into atmosphere']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',...
    {'NOAA ESRL PSD'},'FontSize',16,'color','b','FitBoxToText','off','LineStyle','none');
annotation(gcf,'textbox',[0.2 0.03 0.4498 0.02462],'String',...
    {'Jan'},'FontSize',16,'color','k','fontweight','bold','FitBoxToText','off','LineStyle','none');
annotation(gcf,'textbox',[0.7 0.03 0.4498 0.02462],'String',...
    {'Feb'},'FontSize',20,'color','k','fontweight','bold','FitBoxToText','off','LineStyle','none');
ppath = [plotdir cruise_file_str '_buoyancy' pst];
print(graphdevice,ppath);


%%%% parts of buoyancy: thermo / wind
fig = figure; 
left_color = rgb('black');
right_color = rgb('purple');
set(fig,'defaultAxesColorOrder',[left_color; right_color]);
yyaxis left; hold on;
plot(c10.t, c10.dT,'-r');
plot(c10.t, c10.dq,'-','color',rgb('limegreen'));
ylabel('^{o}C , g kg^{-1}');
hold off;
yyaxis right; hold on;
plot(c10.t, c10.U10,':','color',rgb('navy'));
ylabel('m s^{-1}');
leg = legend('dT','dq','U_{10}');
set(leg,'position',leg_pos+[0.32 -0.05 0 0]);
set(leg,'fontsize',22);
xlim(xrange); datetick('x','dd','keeplimits');
grid on;
title([cruise_title ' turbulent flux components']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',...
    {'NOAA ESRL PSD'},'FontSize',16,'color','b','FitBoxToText','off','LineStyle','none');
annotation(gcf,'textbox',[0.2 0.03 0.4498 0.02462],'String',...
    {'Jan'},'FontSize',16,'color','k','fontweight','bold','FitBoxToText','off','LineStyle','none');
annotation(gcf,'textbox',[0.7 0.03 0.4498 0.02462],'String',...
    {'Feb'},'FontSize',20,'color','k','fontweight','bold','FitBoxToText','off','LineStyle','none');
ppath = [plotdir cruise_file_str '_gradients_wind' pst];
print(graphdevice,ppath);

%%%% momentum flux
fig = figure; 
left_color = rgb('slateblue');
right_color = rgb('black');
set(fig,'defaultAxesColorOrder',[left_color; right_color]);
yyaxis left; hold on;
plot(c10.t, c10.tau,'-','color',rgb('slateblue'));
ylabel('N m^{-2}');
hold off;
yyaxis right; hold on;
plot(c10.t, c10.U10,'-','color',rgb('black'));
ylabel('m s^{-1}');
leg = legend('\tau: wind stress magnitude',...
    'U_{10}: wind speed adjusted for 10-m height');
set(leg,'location','north');
set(leg,'fontsize',22);
xlim(xrange); datetick('x','dd','keeplimits');
grid on;
title([cruise_title ' air-sea momentum flux']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',...
    {'NOAA ESRL PSD'},'FontSize',16,'color','b','FitBoxToText','off','LineStyle','none');
annotation(gcf,'textbox',[0.2 0.03 0.4498 0.02462],'String',...
    {'Jan'},'FontSize',16,'color','k','fontweight','bold','FitBoxToText','off','LineStyle','none');
annotation(gcf,'textbox',[0.7 0.03 0.4498 0.02462],'String',...
    {'Feb'},'FontSize',20,'color','k','fontweight','bold','FitBoxToText','off','LineStyle','none');
ppath = [plotdir cruise_file_str '_tau_wind' pst];
print(graphdevice,ppath);

%%% sst
figure; hold on;
plot(c10.t, c10.Tskin,'o', c10.t, c10.sst);
xlim(xrange); datetick('x','dd','keeplimits');
ylabel('^o C');
leg = legend('T_{skin}','sst: T_{snake} - cool skin');
set(leg,'position',leg_pos);
set(leg,'fontsize',22);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',...
    {'NOAA ESRL PSD'},'FontSize',16,'color','b','FitBoxToText','off','LineStyle','none');
annotation(gcf,'textbox',[0.2 0.03 0.4498 0.02462],'String',...
    {'Jan'},'FontSize',16,'color','k','fontweight','bold','FitBoxToText','off','LineStyle','none');
annotation(gcf,'textbox',[0.7 0.03 0.4498 0.02462],'String',...
    {'Feb'},'FontSize',20,'color','k','fontweight','bold','FitBoxToText','off','LineStyle','none');
grid on;
title([cruise_title ' sst']);
ppath = [plotdir cruise_file_str '_sst' pst];
print(graphdevice,ppath);

hold on;
yyaxis right;
plot(c10.t, c10.sw_net);
xlim(xrange);
ylabel('W m^{-2}');
leg = legend('T_{skin}','sst: T_{snake} - cool skin','Net Solar Heat Flux');
set(leg,'position',leg_pos);
set(leg,'fontsize',22);
ppath = [plotdir cruise_file_str '_sst_Solar' pst];
print(graphdevice,ppath);

%%% rain heat flux;
figure; hold on;
plot(c10.t, c10.hl);
plot(c10.t, c10.hs);
plot(c10.t, c10.lw_net);
plot(c10.t, c10.hr,'linewidth',2);
leg = legend('latent','sensible','net IR','rain');
set(leg,'location','north');
title(leg,'fluxes heating atmosphere'); grid on;
set(leg,'fontsize',22);
ylim([-15 400]);
title([cruise_title]);
xlim(xrange); datetick('x','dd','keeplimits');
ylabel('W m^{-2}');
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',...
    {'NOAA ESRL PSD'},'FontSize',16,'color','b','FitBoxToText','off','LineStyle','none');
annotation(gcf,'textbox',[0.2 0.03 0.4498 0.02462],'String',...
    {'Jan'},'FontSize',16,'color','k','fontweight','bold','FitBoxToText','off','LineStyle','none');
annotation(gcf,'textbox',[0.7 0.03 0.4498 0.02462],'String',...
    {'Feb'},'FontSize',20,'color','k','fontweight','bold','FitBoxToText','off','LineStyle','none');
grid on;
ppath = [plotdir cruise_file_str '_sfc_heat' pst];
print(graphdevice,ppath);

%%% copy and rename the track plot from prior directory
% mapfig = '/Users/eliz/DATA/PISTON_2019/Sally/flux/Processed_Images/da_red_plots_png/026_PISTON_2019_TrackMap.png';
% system(['cp ' mapfig ' ' plotdir cruise_file_str '_TrackMap.png']);
map_all_cruise(c10.lon, c10.lat, cruise_title, c10.PosLims)
ppath = [plotdir cruise_file_str '_map' pst];
print(graphdevice,ppath);

%%%%%%%%%%%%%%%%%%%%%%

end

%% coare 3.5 algorithm experiments

coare05 = coare35vn_motcorr(c10.wspd, zu, c10.Ta, zt, c10.rh, zq, c10.slp, c10.Tsnk,...
                     c10.sw_dn, c10.lw_dn, c10.lat, 600, c10.prate, NaN,NaN, 0.5);
                 
coare1 = coare35vn_motcorr(c10.wspd, zu, c10.Ta, zt, c10.rh, zq, c10.slp, c10.Tsnk,...
                     c10.sw_dn, c10.lw_dn, c10.lat, 600, c10.prate, NaN,NaN, 1);

coare_fields = {'usr';'tau';'hsb';'hlb';'hlwebb';'tsr';'qsr';'zot';'zoq';'Cd';'Ch';...
    'Ce';'L';'zet';'dter';'dqer';'tkt';'RF';'Cdn_ref';'Chn_ref';'Cen_ref';...
    'Uref';'Evap';'Tref';'qref';'rhref'};

for i = [19:22 24:26]
    i05.(coare_fields{i}) = coare05(:,i);
    i1.(coare_fields{i}) = coare1(:,i);
end

readme = {'COARE 3.5 algorithm output at specified height in title';
          'Elizabeth J. Thompson NOAA ESRL PSD';
          'elizabeth.thompson@noaa.gov';
          'ATOMIC 2020 field experiment in tropical Atlantic Ocean';
          datetime;
          'Cdn_ref  neutral drag coefficient for stress at reference height';
          'Chn_ref  neutral heat transfer coefficient for sensible heat at reference height';
          'Cen_ref  neutral stability evaporation transfer coefficient for latent heat flux at reference height';...
          'Uref     wind speed at reference height, m/s';
          'Tref     air temp at reference height, deg C';
          'qref     air specific humidity at reference height, g/kg';
          'rhref    air relative humidity at reference height, %'};

i05.readme = readme;
i1.readme = readme;
      
plot_height_comp = 0;
if plot_height_comp == 1
figure;
plot(c10.t, c10.Ta,'-', c10.t, c10.T10,'-', c10.t, i1.Tref,'-', c10.t, i05.Tref,'--');
legend('17 m','10 m','1 m','0.5 m');
grid on;
xlim([min(c10.t) max(c10.t)]);
datetick('x','keeplimits');
ylabel('T ^oC');
title([cruise_title ' height comparisons']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',...
    {'NOAA ESRL PSD'},'FontSize',16,'color','b','FitBoxToText','off','LineStyle','none');
annotation(gcf,'textbox',[0.2 0.03 0.4498 0.02462],'String',...
    {'Jan'},'FontSize',16,'color','k','fontweight','bold','FitBoxToText','off','LineStyle','none');
annotation(gcf,'textbox',[0.7 0.03 0.4498 0.02462],'String',...
    {'Feb'},'FontSize',20,'color','k','fontweight','bold','FitBoxToText','off','LineStyle','none');
ppath = [plotdir cruise_file_str '_heights_T' pst];
print(graphdevice,ppath);

figure;
plot(c10.t, c10.wspd,'-', c10.t, c10.U10,'-', c10.t, i1.Uref,'-', c10.t, i05.Uref,'--');
legend('17 m','10 m','1 m','0.5 m');
grid on;
xlim([min(c10.t) max(c10.t)]);
datetick('x','keeplimits');
ylabel('U m s^{-1}');
title([cruise_title ' height comparisons']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',...
    {'NOAA ESRL PSD'},'FontSize',16,'color','b','FitBoxToText','off','LineStyle','none');
annotation(gcf,'textbox',[0.2 0.03 0.4498 0.02462],'String',...
    {'Jan'},'FontSize',16,'color','k','fontweight','bold','FitBoxToText','off','LineStyle','none');
annotation(gcf,'textbox',[0.7 0.03 0.4498 0.02462],'String',...
    {'Feb'},'FontSize',20,'color','k','fontweight','bold','FitBoxToText','off','LineStyle','none');
ppath = [plotdir cruise_file_str '_heights_U' pst];
print(graphdevice,ppath);

figure;
plot(c10.t, c10.rh,'-', c10.t, c10.rh10,'-', c10.t, i1.rhref,'-', c10.t, i05.rhref,'--');
legend('17 m','10 m','1 m','0.5 m');
grid on;
xlim([min(c10.t) max(c10.t)]);
datetick('x','keeplimits');
ylabel('RH %');
title([cruise_title ' height comparisons']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',...
    {'NOAA ESRL PSD'},'FontSize',16,'color','b','FitBoxToText','off','LineStyle','none');
annotation(gcf,'textbox',[0.2 0.03 0.4498 0.02462],'String',...
    {'Jan'},'FontSize',16,'color','k','fontweight','bold','FitBoxToText','off','LineStyle','none');
annotation(gcf,'textbox',[0.7 0.03 0.4498 0.02462],'String',...
    {'Feb'},'FontSize',20,'color','k','fontweight','bold','FitBoxToText','off','LineStyle','none');
ppath = [plotdir cruise_file_str '_heights_rh' pst];
print(graphdevice,ppath);

figure;
plot(c10.t, c10.qa,'-', c10.t, c10.q10,'-', c10.t, i1.qref,'-', c10.t, i05.qref,'--');
legend('17 m','10 m','1 m','0.5 m');
grid on;
xlim([min(c10.t) max(c10.t)]);
datetick('x','keeplimits');
ylabel('q g kg^{-1}');
title([cruise_title ' height comparisons']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',...
    {'NOAA ESRL PSD'},'FontSize',16,'color','b','FitBoxToText','off','LineStyle','none');
annotation(gcf,'textbox',[0.2 0.03 0.4498 0.02462],'String',...
    {'Jan'},'FontSize',16,'color','k','fontweight','bold','FitBoxToText','off','LineStyle','none');
annotation(gcf,'textbox',[0.7 0.03 0.4498 0.02462],'String',...
    {'Feb'},'FontSize',20,'color','k','fontweight','bold','FitBoxToText','off','LineStyle','none');
ppath = [plotdir cruise_file_str '_heights_q' pst];
print(graphdevice,ppath);
end

fname = [cruise_file_str '_10min_coare_met_output_at_0p5m_v1'];
dfl_mat = [fluxdir fname '.mat'];
save(dfl_mat,'i05');

fname = [cruise_file_str '_10min_coare_met_output_at_1m_v1'];
dfl_mat = [fluxdir fname '.mat'];
save(dfl_mat,'i1');

% A = [usr tau hsb hlb hlwebb tsr qsr zot zoq Cd Ch Ce L zet dter dqer tkt RF Cdn_10 Chn_10 Cen_10 U10 Evap T10 Q10 RH10];
%     1   2   3   4     5    6   7   8   9  10 11 12 13 14  15   16   17 18   19     20     21    22   23   24  25  26]
