function plot_motcorr(ff, path_dailyPlots)
%%% function to read in 1 day of met, seawater, flux data and make plots
%%% that are normally produced by run_motcoor.m program. Function reads in
%%% the daily matlab structure ff produced by this program. 
%%% 
%%% EJT Jan 2020
%%%
%%% input: 
%%%     ff      = structure with data and metadata used for plotting

%%% Notes: 
%%%     WXT is ignored for now
%%%

% %% if you need to load a new mat file for the conversion, do it
% if strcmp(yn_loadnew, 'y') == 1
%     %%% load the .mat file from its directory
%     load([dir_name file_name '.mat']);
%     %%% make string of name of structure
%     struct_name = char(struct);
%     eval(['the_m = ' struct_name ';']);
% %%% else, the structure already exists in the program by name "structname"
% elseif strcmp(yn_loadnew, 'n') == 1
%     % do nothing
%     the_m = struct;
% end
    
% the_m



            %%% this chunk was broken out by variable for tracking individual fields
            % rhoa, coare_s(:, 1:21), coare_psl(:, 1:21), met_10min_std(:, 6), ... % 52-95 


% OLD output of array A from coare35vn_motcorr:
% %%%% this is why this program should not save COARE output without
% specifying which variables... if you change the coare function, then this
% part of DA gets screwed up. 
% coare_psl = [usr tau hsb hlb hlwebb tsr qsr zot zoq  Cd Ch Ce L zet dT_skin dq_skin dz_skin hrain Cdn_10 Chn_10 Cen_10 U10 Evap T10 Q10 RH10];
%    coare_psl:  1   2   3   4     5    6   7   8   9  10 11 12 13 14  15       16      17      18   19     20     21    22   23   24  25  26]
%   da for psl: 74  75  76  77    78   79  80  81  82  83 84 85 86 87  88       89      90      91   92     93     94  ... the rest is not saved in da]
%  da for ship: 53  54  55  56    57   58  59  60  61  62 63 64 65 66  67       68      69      70   71     72     73  ... the rest is not saved in da]

%     %%% KEY: inertial dissipation fluxes for plotting
%     da(:,52) = rhoa; % air density PSL
%     da(:,144) = tsid_a; % sensible heat flux from inertial dissipation method A
%     da(:,142) = usid_a; % stress from inertial dissipation method A
%     da(:,20) = Ts; % best surface temp
%     da(:,163) = Stsg_s; % salinity from ship
%     da(:,146) = qsid_a; % latent heat flux from inertial dissipation method A
%     
%     da(:,78) = coare_psl(:,5) = hlwebb; % webb latent flux from coare_psl
%     da(:,56) = coare_s(:,4) = hlb_s; % bulk latent flux from coare_s
%     da(:,77) = coare_psl(:,4) = hlb; % bulk latent flux from coare_psl
%     da(:,55) = coare_s(:,3) = hsb_s; % bulk sensible flux from coare_s
%     da(:,76) = coare_psl(:,3) = hsb; % bulk sensbile flux from coare_psl
%         
%     hlwebb = coare_psl(:,5);
%     hlb_s = coare_s(:,4);
%     hlb = coare_psl(:,4);
%     hsb_s = coare_s(:,3);
%     hsb = coare_psl(:,3);


%% get date, time, cruise info
the_jd = floor(ff.jd(2));
[the_yr, the_mo, the_day, the_hr, the_min, the_sec] = datevec(ff.t(2));
cruise = [cruise_str '_' sprintf('%i',the_yr)];

%% plot info
graphformat = '.png';  % select graphics format
graphdevice = '-dpng'; % select graphic device

%% Daily plots

label_st = [cruise '_' sprintf('%02i_%02i_%03i', the_mo, the_day, the_jd) graphformat];

    ppath_T = fullfile(path_dailyPlots,'Air_Sea_Temps',['Air_Sea_Temps_' label_st]);
    ppath_RH = fullfile(path_dailyPlots,'RH',['RH_q_' label_st]);
    ppath_TW = fullfile(path_dailyPlots,'True_Wind',['True_Wind_' label_st]);
    ppath_COGSOG = fullfile(path_dailyPlots,'SOG_COG',['SOG_COG_' label_st]);
    ppath_RW = fullfile(path_dailyPlots,'Rel_Wind',['Rel_Wind_' label_st]);
    ppath_R = fullfile(path_dailyPlots,'Rain',['Rain_' label_st]);
    ppath_MOT = fullfile(path_dailyPlots,'Motion_Tilt',['Motion_Tilt_' label_st]);
    ppath_RAD = fullfile(path_dailyPlots,'Radiation',['Radiation_' label_st]);
    ppath_HEAT = fullfile(path_dailyPlots,'Heat_Fluxes',['Heat_Fluxes_' label_st]);
    ppath_TAU = fullfile(path_dailyPlots,'Stress',['Stress_' label_st]);
    ppath_MAP = fullfile(path_dailyPlots,'Track_Plot',['TrackPlot_' label_st]);
    ppath_BULK = fullfile(path_dailyPlots,'Heat_Fluxes',['Bulk_Fluxes_' label_st]);

the_ppaths = {ppath_T; ppath_RH; ppath_TW; ppath_COGSOG; ppath_RW; ppath_R; ppath_MOT; ppath_RAD;...
    ppath_HEAT; ppath_TAU; ppath_MAP; ppath_BULK};

%%% if no data exist, print blank plots
if isnan(ff.slp(1)) == 1 && isnan(ff.slp(end)) == 1

    disp('no data today, so just printing blank plots');

    % print a blank plot
    figure; plot(ff.jd,nan(1,length(ff.jd))); grid on;
    title(sprintf('%s (%04i-%02i-%02i, DOY%03i).  No Data - Ship in Port',cruise_str,the_yr,the_mo,the_day,the_jd),'FontWeight','Bold','Interpreter','none')
    xlabel('Hour UTC');
    axis([the_jd the_jd+1 0 1]); 
    set(gca(gcf),'XTick',the_jd:2/24:the_jd+1); datetick('x','HH:MM','keepticks');
    xax = get(gca(gcf),'XTickLabel'); xax(end,:)='24:00'; set(gca(gcf),'XTickLabel',xax(:,1:2));
    annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA/ESRL/PSL'},'FontSize',10,'FitBoxToText','off','LineStyle','none');

    for i = 1:length(the_ppaths)
        print(graphdevice,the_ppaths{i});
    end

else


% Air and Sea Temperatures
figure;
    %%% air
subplot(2,1,1); plot(ff.jd,ff.Ta_s,'b-',ff.jd,ff.Ta,'r-');
    title(sprintf('%s (%04i-%02i-%02i, DOY%03i).  Air & Sea Temperatures',cruise_str,the_yr,the_mo,...
        the_day,the_jd),'FontWeight','Bold','Interpreter','none');
    xlabel('Hour UTC');ylabel('Air Temp, ^oC'); grid;
    set(gca(gcf),'XTick',the_jd:2/24:the_jd+1);datetick('x','HH:MM','keepticks');
    xax=get(gca(gcf),'XTickLabel');xax(end,:)='24:00';set(gca(gcf),'XTickLabel',xax(:,1:2));
    legend('ship','PSL','Location','Best');

    %%% sea
subplot(2,1,2); plot(ff.jd, ff.Ttsg2_s,'b-',ff.jd, ff.sst,'r-',ff.jd, ff.Tskin,'-g');
    xlabel('Hour UTC');ylabel('Seawater Temp, ^oC'); grid;
    legend(['ship TSG @ ' sprintf('%3.1f',ztsg2_ship') ' m'],'PSL SST: Tsnake - cool skin','ROSR SST at skin level',...
        'location','best');
    set(gca(gcf),'XTick',the_jd:2/24:the_jd+1);datetick('x','HH:MM','keepticks');
    xax=get(gca(gcf),'XTickLabel');xax(end,:)='24:00';set(gca(gcf),'XTickLabel',xax(:,1:2));
    annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',...
        {'NOAA PSL'},'FontSize',15,'FitBoxToText','off','LineStyle','none');
orient tall
    print(graphdevice,ppath_T);


% Humidity

figure;
subplot(2,1,1); hold on;
plot(ff.jd,ff.rh_s,'b-',ff.jd,ff.rh,'r-'); 
plot(ff.jd,ff.licor_rh,'ok'); 
    title(sprintf('%s (%04i-%02i-%02i, DOY%03i).  RH & Specific Humidity',cruise_str,the_yr,...
        the_mo,the_day,the_jd),'FontWeight','Bold','Interpreter','none');
    xlabel('Hour UTC');ylabel('RH, %'); grid; ylim([40,100]);
    set(gca(gcf),'XTick',the_jd:2/24:the_jd+1);datetick('x','HH:MM','keepticks');
    xax=get(gca(gcf),'XTickLabel');xax(end,:)='24:00';set(gca(gcf),'XTickLabel',xax(:,1:2));
    legend('ship','PSL','Licor','Location','south','orientation','horizontal');
subplot(2,1,2); hold on;
plot(ff.jd,ff.qa_s,'b-',ff.jd,ff.qa,'r-');
plot(ff.jd,ff.licor_qa,'ok');
    xlabel('Hour UTC');ylabel('q, g kg^{-1}'); grid; ylim([0 25]);
    set(gca(gcf),'XTick',the_jd:2/24:the_jd+1);datetick('x','HH:MM','keepticks');
    xax=get(gca(gcf),'XTickLabel');xax(end,:)='24:00';set(gca(gcf),'XTickLabel',xax(:,1:2))
    annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',...
        {'NOAA PSL'},'FontSize',15,'FitBoxToText','off','LineStyle','none');
orient tall
    print(graphdevice,ppath_RH);

% True Wspd/Wdir
figure;
subplot(2,1,1); plot(ff.jd,ff.wspd_s,'b-',ff.jd,ff.wspd,'r-');
    title(sprintf('%s (%04i-%02i-%02i, DOY%03i).  True Wind Speed',cruise_str,the_yr,the_mo,...
        the_day,the_jd),'FontWeight','Bold','Interpreter','none')
    xlabel('Hour UTC');ylabel('True Wind Speed, m s^{-1}'); grid;
    set(gca(gcf),'XTick',the_jd:2/24:the_jd+1);datetick('x','HH:MM','keepticks');
    xax=get(gca(gcf),'XTickLabel');xax(end,:)='24:00';set(gca(gcf),'XTickLabel',xax(:,1:2));
    legend('ship','PSL','Location','Best');
subplot(2,1,2); plot(ff.jd,ff.wdir_s,'bo',ff.jd,ff.wdir,'r.');
    xlabel('Hour UTC');ylabel('True Wind Dir, ^o'); grid; ylim([0 360]);
    set(gca(gcf),'XTick',the_jd:2/24:the_jd+1);datetick('x','HH:MM','keepticks');
    xax=get(gca(gcf),'XTickLabel');xax(end,:)='24:00';set(gca(gcf),'XTickLabel',xax(:,1:2))
    annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',...
        {'NOAA PSL'},'FontSize',15,'FitBoxToText','off','LineStyle','none');
orient tall
    print(graphdevice,ppath_TW);

% COG / SOG
figure;
subplot(2,1,1); plot(ff.jd,ff.sog_s,'bo',ff.jd,ff.sog,'r.');
    title(sprintf('%s (%04i-%02i-%02i, DOY%03i).  SOG COG',cruise_str,the_yr,the_mo,...
        the_day,the_jd),'FontWeight','Bold','Interpreter','none')
    xlabel('Hour UTC');ylabel('SOG, m s^{-1}'); grid;
    set(gca(gcf),'XTick',the_jd:2/24:the_jd+1);datetick('x','HH:MM','keepticks');
    xax=get(gca(gcf),'XTickLabel');xax(end,:)='24:00';set(gca(gcf),'XTickLabel',xax(:,1:2));
    legend('ship','PSL','Location','Best');
subplot(2,1,2); plot(ff.jd,ff.cog_s,'bo',ff.jd,ff.cog,'r.');
    xlabel('Hour UTC');ylabel('COG, ^o'); grid; ylim([0 360]);
    set(gca(gcf),'XTick',the_jd:2/24:the_jd+1);datetick('x','HH:MM','keepticks');
    xax=get(gca(gcf),'XTickLabel');xax(end,:)='24:00';set(gca(gcf),'XTickLabel',xax(:,1:2))
    annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',...
        {'NOAA PSL'},'FontSize',15,'FitBoxToText','off','LineStyle','none');
orient tall
    print(graphdevice,ppath_COGSOG);

% Relative Wspd/Wdir
figure;
Uplim = ones(length(ff.t),1)*60;
LoLim = ones(length(ff.t),1)*-60;
subplot(2,1,1); plot(ff.jd,ff.rspd_s,'b-',ff.jd,ff.rspd,'r-');
    title(sprintf('%s (%04i-%02i-%02i, DOY%03i).  Relative Wind',cruise_str,the_yr,...
        the_mo,the_day,the_jd),'FontWeight','Bold','Interpreter','none')
    xlabel('Hour UTC');ylabel('Relative Wind Speed, m s^{-1}'); grid;
    set(gca(gcf),'XTick',the_jd:2/24:the_jd+1);datetick('x','HH:MM','keepticks');
    xax=get(gca(gcf),'XTickLabel');xax(end,:)='24:00';set(gca(gcf),'XTickLabel',xax(:,1:2));
    legend('ship','PSL','Location','Best');
subplot(2,1,2); plot(ff.jd,ff.rdir_s,'bo',ff.jd,ff.rdir,'r.'); hold on;
    plot(ff.jd,Uplim,'k--',ff.jd,LoLim,'k--');
    xlabel('Hour UTC');ylabel('Relative Wind Dir, ^o'); grid; ylim([-180 180]);
    set(gca(gcf),'XTick',the_jd:2/24:the_jd+1);datetick('x','HH:MM','keepticks');
    xax=get(gca(gcf),'XTickLabel');xax(end,:)='24:00';set(gca(gcf),'XTickLabel',xax(:,1:2))
    annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',...
        {'NOAA PSL'},'FontSize',15,'FitBoxToText','off','LineStyle','none');
orient tall
    print(graphdevice,ppath_RW);


% Rain
figure;
subplot(2,1,1); plot(ff.jd,ff.prate,'r','LineWidth',3);  
    title(sprintf('%s (%04i-%02i-%02i, DOY%03i).  Rain',cruise_str,the_yr,the_mo,...
        the_day,the_jd),'FontWeight','Bold','Interpreter','none')
    xlabel('Hour UTC');ylabel('Rain Rate, mm hr^{-1}'); grid;
    set(gca(gcf),'XTick',the_jd:2/24:the_jd+1);datetick('x','HH:MM','keepticks');
    xax=get(gca(gcf),'XTickLabel');xax(end,:)='24:00';set(gca(gcf),'XTickLabel',xax(:,1:2));
    legend('PSL ORG','Location','Best'); 
subplot(2,1,2); plot(ff.jd,ff.paccum,'r','LineWidth',3); 
    xlabel('Hour UTC');ylabel('Accumulated Rain, mm'); grid;
    set(gca(gcf),'XTick',the_jd:2/24:the_jd+1);datetick('x','HH:MM','keepticks');
    xax=get(gca(gcf),'XTickLabel');xax(end,:)='24:00';set(gca(gcf),'XTickLabel',xax(:,1:2))
    annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',...
        {'NOAA PSL'},'FontSize',15,'FitBoxToText','off','LineStyle','none');
orient tall
    print(graphdevice,ppath_R);

% Std Dev Platform Motion & Tilt Angle
figure;
subplot(2,1,1); plot(ff.jd,ff.uplat_std,'-',ff.jd,ff.vplat_std,'-',ff.jd,ff.wplat_std,'-');
    title(sprintf('%s (%04i-%02i-%02i, DOY%03i).  Motion Std Dev & Tilt',cruise_str,the_yr,...
        the_mo,the_day,the_jd),'FontWeight','Bold','Interpreter','none');
    xlabel('Hour UTC');ylabel('Motion Std Dev, m s^{-1}'); grid;
    set(gca(gcf),'XTick',the_jd:2/24:the_jd+1);datetick('x','HH:MM','keepticks');
    legend('u','v','w','Location','Best');
    xax=get(gca(gcf),'XTickLabel');xax(end,:)='24:00';set(gca(gcf),'XTickLabel',xax(:,1:2));
subplot(2,1,2); plot(ff.jd,ff.tilt*r2d,'-');
    xlabel('Hour UTC');ylabel('Wind Tilt Angle, ^o'); grid;
    set(gca(gcf),'XTick',the_jd:2/24:the_jd+1);datetick('x','HH:MM','keepticks');
    xax=get(gca(gcf),'XTickLabel');xax(end,:)='24:00';set(gca(gcf),'XTickLabel',xax(:,1:2))
    annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',...
        {'NOAA PSL'},'FontSize',15,'FitBoxToText','off','LineStyle','none');
orient tall
    print(graphdevice,ppath_MOT);

% Radiation
figure;
subplot(2,1,1); plot(ff.jd,ff.sw_dn_s,'b-',ff.jd,ff.sw_dn,'r-');
    title(sprintf('%s (%04i-%02i-%02i, DOY%03i).  Solar & IR Radiation',cruise_str,the_yr,the_mo,the_day,the_jd),'FontWeight','Bold','Interpreter','none');
    xlabel('Hour UTC');ylabel('Solar Downwelling, W m^{-2}'); grid;
    set(gca(gcf),'XTick',the_jd:2/24:the_jd+1);datetick('x','HH:MM','keepticks');
    xax=get(gca(gcf),'XTickLabel');xax(end,:)='24:00';set(gca(gcf),'XTickLabel',xax(:,1:2));
    legend('ship','PSL','Location','Best');
subplot(2,1,2); plot(ff.jd,ff.lw_dn_s,'b-',ff.jd,ff.lw_dn,'r-');
    xlabel('Hour UTC');ylabel('IR Downwelling, W m^{-2}'); grid;
    set(gca(gcf),'XTick',the_jd:2/24:the_jd+1);datetick('x','HH:MM','keepticks');
    xax=get(gca(gcf),'XTickLabel');xax(end,:)='24:00';set(gca(gcf),'XTickLabel',xax(:,1:2))
    annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL'},'FontSize',15,'FitBoxToText','off','LineStyle','none');
orient tall
    print(graphdevice,ppath_RAD);


% Heat Fluxes
maxhl = 450; minhl = 0; maxhs = 45; minhs = -20;

figure;
subplot(2,1,1); plot(ff.jd,ff.hl_s,'b-',ff.jd,ff.hl,'r-',ff.jd,ff.hl_covW,'go',...
        ff.jd,ff.hl_covS,'k*',ff.jd,ff.hl_id,'mo');
    title(sprintf('%s (%04i-%02i-%02i, DOY%03i).  Heat Fluxes',cruise_str,the_yr,...
        the_mo,the_day,the_jd),'FontWeight','Bold','Interpreter','none')
    xlabel('Hour UTC');ylabel('Latent Heat, W m^{-2}'); grid;
    ylim([minhl, maxhl]);
    set(gca(gcf),'XTick',the_jd:2/24:the_jd+1);datetick('x','HH:MM','keepticks');
    xax=get(gca(gcf),'XTickLabel');xax(end,:)='24:00';set(gca(gcf),'XTickLabel',xax(:,1:2));
    legend('bulk ship','bulk PSL','Cov-Webb','Cov-SdS','ID-a','Location','Best');
subplot(2,1,2); plot(ff.jd,ff.hs_s,'b-',ff.jd,ff.hs,'r-',ff.jd,ff.hs_covW,'go',...
        ff.jd,ff.hs_covS,'k*',ff.jd,ff.hs_id,'mo');
    xlabel('Hour UTC');ylabel('Sensible Heat, W m^{-2}'); grid;
    ylim([minhs,maxhs]);
    set(gca(gcf),'XTick',the_jd:2/24:the_jd+1);datetick('x','HH:MM','keepticks');
    xax=get(gca(gcf),'XTickLabel');xax(end,:)='24:00';set(gca(gcf),'XTickLabel',xax(:,1:2))
    legend('bulk ship','bulk PSL','Cov-Webb','Cov-SdS','ID-a','Location','Best');
    annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',...
        {'NOAA PSL'},'FontSize',15,'FitBoxToText','off','LineStyle','none');
orient tall
    print(graphdevice,ppath_HEAT);

% Stress

figure; plot(ff.jd,ff.tau_s,'b-',ff.jd,ff.tau,'r-',ff.jd,ff.tau_cov,'ko',...
    ff.jd,ff.tau_ida,'go',ff.jd,ff.tau_idb,'mo');
title(sprintf('%s (%04i-%02i-%02i, DOY%03i).  Streamwise Stress',cruise_str,the_yr,...
    the_mo,the_day,the_jd),'FontWeight','Bold','Interpreter','none')
xlabel('Hour UTC');ylabel('Stress, N m^{-2}'); grid; ylim([-0.02 0.45]);
set(gca(gcf),'XTick',the_jd:2/24:the_jd+1);datetick('x','HH:MM','keepticks');
xax=get(gca(gcf),'XTickLabel');xax(end,:)='24:00';set(gca(gcf),'XTickLabel',xax(:,1:2));
legend('bulk ship','bulk PSL','Cov','ID-A','ID-B','Location','Best');
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',...
    {'NOAA PSL'},'FontSize',15,'FitBoxToText','off','LineStyle','none');
    print(graphdevice,ppath_TAU);

% GPS Track Plot
lon_smooth = despike2(ff.lon);
lat_smooth = despike2(ff.lat);
map_day(lon_smooth,lat_smooth,cruise_str,PosLims,ff.t(1),the_jd)
    print(graphdevice,ppath_MAP);

% Bulk fluxes
figure; hold on;
plot(ff.t, ff.hnet,'-k','linewidth',2.5);
plot(ff.t, ff.sw_net, ff.t, ff.lw_net, ff.t, ff.hl, ff.t, ff.hs, ff.t, ff.hrain);
leg = legend('net','net solar','net infrared','latent','sensible','rain','location','north');
% title(leg,'Surface Heat Fluxes')
datetick('x');
    title(sprintf('%s (%04i-%02i-%02i, DOY%03i).  Bulk Surface Fluxes',cruise_str,the_yr,...
        the_mo,the_day,the_jd),'FontWeight','Bold','Interpreter','none')
    xlabel('Hour UTC');ylabel('W m^{-2}'); grid;
    ylim([-450, 1000]);
    xax=get(gca(gcf),'XTickLabel');xax(end,:)='24:00';set(gca(gcf),'XTickLabel',xax(:,1:2));
    annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',...
        {'NOAA PSL'},'FontSize',15,'FitBoxToText','off','LineStyle','none');
text(ff.t(end)+datenum(0,0,0,0,20,0),270,'warming','fontsize',20,'fontweight','bold','horizontalalignment','left');
text(ff.t(end)+datenum(0,0,0,0,20,0),200,'surface','fontsize',20,'fontweight','bold','horizontalalignment','left');
text(ff.t(end)+datenum(0,0,0,0,20,0),-200,'cooling','fontsize',20,'fontweight','bold','horizontalalignment','left');
text(ff.t(end)+datenum(0,0,0,0,20,0),-270,'surface','fontsize',20,'fontweight','bold','horizontalalignment','left');
    print(graphdevice,ppath_BULK);
   
end

close all;

