% plot_da_red
%%% 
%%% EJT Jan 2020, March 2021
%%%

%%% Notes: 
%%%     WXT is ignored for now


%% start
disp('PLOTS: da')
hourly = 1;
    
t0 = min(b10.t);
tN = max(b10.t);

%% wind speed: PSL vs. ship
figure;
plot(b10.t,b10.wspd,'r.',b10.t,b10.wspd_s,'b.'); grid; xlim([t0 tN]);
legend('NOAA','ship','location','eastoutside');
ylabel('m/s'); datetick('x','mm/dd','keeplimits');
title([ptitle,' true wind speed']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 1'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['001_',cruise,'_True_Wind_Spd.png']);
print('-dpng',ppath);


%% wind speed: bin averaged PSL vs. ship
[xbins, ybins1, ~, SD1, ~] = binave2(b10.wspd,b10.wspd_s,2,0,18);
figure('position',[200,200,600,600]);
plot([0,20],[0,20],'k-'); hold on; grid; axis square;
p1 = errorbar(xbins,ybins1,SD1,'md-','linewidth',2);
xlim([0 20]); ylim([0 20]);
ylabel('ship, m s^{-1}'); xlabel('NOAA sonic, m s^{-1}');
title([ptitle,' true wind speed']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 2'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['002_',cruise,'_True_Wind_Spd_Comparison.png']);
print('-dpng',ppath);

%% bad sonic data
% missing data are negative when more data are recovered in that hour than
% expected
figure;
subplot(2,1,1);
    plot(b10.t,d10.missingSon,'rd','markersize',2); grid; xlim([t0 tN]);
    ylabel('missing points'); datetick('x','mm/dd','keeplimits');
    title([ptitle,' missing sonic data points per 10min @ 10 Hz']);
subplot(2,1,2);
    plot(b10.t,d10.badSon,'rd','markersize',2); grid; xlim([t0 tN]);
    ylabel('bad points'); datetick('x','mm/dd','keeplimits');
    title([ptitle,' bad sonic data points per 10min @ 10 Hz']);
    annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 3'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['003_',cruise,'_Sonic_QA.png']);
print('-dpng',ppath);

%% true wind direction: PSL vs. ship
figure;
plot(b10.t,b10.wdir,'r.',b10.t,b10.wdir_s,'b.'); grid; xlim([t0 tN]);
ylim([0,360]); yticks([0,90,180,270,360]);
ylabel('^{o}'); datetick('x','mm/dd','keeplimits');
legend('NOAA','ship','location','eastoutside');
title([ptitle ' true wind direction']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 4'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['004_',cruise,'_True_Wind_Dir.png']);
print('-dpng',ppath);

%% true wind direction: histogram
figure; histogram(b10.wdir,0:20:360); grid;
xlim([0,360]); xticks(0:60:360); xlabel('^{o}');
ylabel('count, 10-min averages');
title([ptitle ' true wind direction']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 5'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['005_',cruise,'_True_Wind_Dir_Dist.png']);
print('-dpng',ppath);

%% relative wind direction
figure;
plot([t0,tN],[90,90],'k--',[t0,tN],[-90,-90],'k--'); hold on;
plot([t0,tN],[60,60],'g--',[t0,tN],[-60,-60],'g--');
p1 = plot(b10.t,b10.rdir,'r.',b10.t,b10.rdir_s,'b.'); grid; xlim([t0 tN]);
ylim([-180,180]); yticks([-180,-90,0,90,180]);
ylabel('^{o}'); datetick('x','mm/dd','keeplimits');
legend(p1,{'NOAA','ship'},'location','eastoutside');
title([ptitle ' relative wind direction']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 6'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['006_',cruise,'_Rel_Wind_Dir.png']);
print('-dpng',ppath);

%% relative wind direction histogram
figure; histogram(b10.rdir,-180:20:180); grid on;
xlim([-180,180]); xticks(-180:45:180); xlabel('relative wind direction, ^{o}');
ylabel('count, 10-min averages');
title([ptitle ' relative wind direction']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 7'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['007_',cruise,'_Rel_Wind_Dir_Dist.png']);
print('-dpng',ppath);

%% sea level pressure
figure;
plot(b10.t,b10.psealevel,'r.',b10.t,b10.psealevel_s,'b.');  grid on; xlim([t0 tN]);
ylabel('SLP mb'); datetick('x','mm/dd','keeplimits');
legend('NOAA','ship','location','eastoutside');
title([ptitle ' sea level pressure']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 8'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['008_',cruise,'_SLP.png']);
print('-dpng',ppath);

%% sea level pressure binned
[bpbinNOAA, bpbinship, ~, SDbpship, ~] = binave2(b10.psealevel,b10.psealevel_s,2,1000,1014);
% [~, bpbinWXT, ~, SDbpWXT, ~] = binave2(press,Pmb_wxt,2,1000,1014);
figure('position',[200,200,600,600]);
plot([1000,1014],[1000,1014],'k-'); hold on; grid on; axis square;
p1 = errorbar(bpbinNOAA,bpbinship,SDbpship,'md-','linewidth',2);
% p2 = errorbar(bpbinNOAA,bpbinWXT,SDbpWXT,'gd-'); grid;
% xlim([1000 1022]); ylim([1006 1022]);
% legend([p1 p2],'ship','location','best');
ylabel('ship SLP, mb'); xlabel('NOAA SLP, mb');
title([ptitle ' sea level pressure']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 9'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['009_',cruise,'_SLP_Comparison.png']);
print('-dpng',ppath);

disp(['Mean difference in SLP, NOAA - ship = ',sprintf('%6.2f',nanmean1(b10.psealevel-b10.psealevel_s))]);

%% tilt angle - flow distortion angle derived from the motion correction script
% this is tilt angle prior to ship speed correction
figure;
plot(b10.rdir,d10.tilt,'r.',[-90 -90],[-5 25],'k--',[90 90],[-5 25],'k--');
axis([-180 180 -5 25]); grid;
ylabel('streamline tilt angle, ^{o}'); xlabel('relative wind direction, ^{o}');
title(ptitle);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 10'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['010_',cruise,'_Tilt.png']);
print('-dpng',ppath);

%% tilt angled binned
[xbins, ybins, ~, SD, ~] = binave2(b10.rdir,d10.tilt,20,-180,180);
figure;
plot([-90 -90],[-5 25],'k--',[90 90],[-5 25],'k--'); hold on; grid on;
errorbar(xbins,ybins,SD,'rd-','linewidth',2);  axis([-180 180 -5 25]);
ylabel('streamline tilt angle, ^{o}'); xlabel('relative wind direction, ^{o}');
title(ptitle);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 11'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['011_',cruise,'_Tilt_Binned.png']);
print('-dpng',ppath);

%% std dev vertical velocoty
[xbins, ybins, ~, ~, ~] = binave2(b10.rdir,d10.wvar,20,-180,180);
figure;
plot([-90 -90],[-5 25],'k--',[90 90],[-5 25],'k--'); hold on; grid; axis square;
plot(xbins,sqrt(ybins),'rd-'); axis([-180,180,0,1.0]);
ylabel('\sigma w, m s^{-1}'); xlabel('relative wind direction, ^o');
title(ptitle);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 12'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['012_',cruise,'_SigW_Binned.png']);
print('-dpng',ppath);

%% water temperature
maxx = max(b10.tsnk)+0.5; minx = min(b10.tsnk)-0.5;
figure;
plot(b10.t,b10.tsnk,'or',b10.t,b10.tsea_s,'.b');  xlim([t0 tN]);
legend('sea snake','ship','location','eastoutside');
% plot(b10.t,b10.tsnk,'r',b10.t,b10.tsea_s,'b',b10.t,skinT,'g'); 
% legend('sea snake','ship','ROSR skin T','location','eastoutside');
grid;
xlim([t0,tN]); ylim([minx,maxx]);
ylabel('^oC'); datetick('x','mm/dd','keeplimits');
title([ptitle ' seawater T']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 13'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['013_',cruise,'_tsea.png']);
print('-dpng',ppath);

%% diurnal cycle SST
hDay = mod(b10.t,1)*24; % hour of day
clear ii; ii = isfinite(b10.tsnk) & isfinite(b10.tsea_s);
[xbins0, ybins0, ~, SD0, ~] = binave2(hDay(ii),b10.tsnk(ii),2,0,24);
[xbins1, ybins1, ~, SD1, ~] = binave2(hDay(ii),b10.tsea_s(ii),2,0,24);
figure; p2 = errorbar(xbins1,ybins1,SD1,'bo-','linewidth',2); hold on; axis square;
p1 = errorbar(xbins0,ybins0,SD0,'rd-','linewidth',2);
xlim([0,24]); xticks(0:2:24); xlabel('Hour of Day, uTC'); grid;
legend([p1 p2],{'sea snake','ship'},'location','eastoutside');
ylabel('water T, ^oC'); 
title([ptitle,' water T Diurnal Cycle']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 14'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['014_',cruise,'_tsea_Dirurnal.png']);
print('-dpng',ppath);

%% relative humidity
figure;
plot(b10.t,b10.rh,'r.',b10.t,b10.rh_s,'b.'); xlim([t0 tN]);
ylabel('%'); datetick('x','mm/dd','keeplimits'); grid; 
legend('NOAA','ship','location','eastoutside');
title([ptitle ' relative humidity']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 15'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['015_',cruise,'_RH.png']);
print('-dpng',ppath);

%% air temperature
figure;
plot(b10.t,b10.ta,'r.',b10.t,b10.ta_s,'b.'); xlim([t0 tN]);
ylabel('T air, ^oC'); datetick('x','mm/dd','keeplimits'); grid; 
legend('NOAA','ship','location','eastoutside');
title([ptitle ' air temperature']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 16'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['016_',cruise,'_tair.png']);
print('-dpng',ppath);

%% specific humidity
figure;
plot(b10.t,b10.qa,'r.',b10.t,b10.qa_s,'b.'); grid; xlim([t0 tN]);
ylabel('q air, g kg^{-1}'); datetick('x','mm/dd','keeplimits');
legend('NOAA','ship','location','eastoutside');
title([ptitle,' air specific humidity']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 17'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['017_',cruise,'_Qa.png']);
print('-dpng',ppath);

%% surface saturation specific humidity
figure;
plot(b10.t,b10.qs,'.r',b10.t,b10.qs_s,'.b'); grid; xlim([t0 tN]);
ylabel('q_s, g kg^{-1}'); datetick('x','mm/dd','keeplimits');
legend('sea snake','ship TSG','location','eastoutside');
title([ptitle,' sea surface specific humidity']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 18'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['018_',cruise,'_Qsea.png']);
print('-dpng',ppath);

%% solar radiation
figure;
plot(b10.t,b10.sw_dn,'r.',b10.t,b10.sw_dn_s,'b.'); grid; xlim([t0 tN]);
ylabel('W m^{-2}'); datetick('x','mm/dd','keeplimits');
legend('NOAA','ship','location','eastoutside');
title([ptitle,' downwelling solar radiation']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 19'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['019_',cruise,'_SolarRad.png']);
print('-dpng',ppath);

%% longwave radiation
figure;
plot(b10.t,b10.lw_dn,'r.',b10.t,b10.lw_dn_s,'b.'); grid; xlim([t0 tN]);
ylabel('W m^{-2}'); datetick('x','mm/dd','keeplimits');
legend('NOAA','ship','location','eastoutside');
title([ptitle,' downwelling IR radiation']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 20'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['020_',cruise,'_IR_Rad.png']);
print('-dpng',ppath);


%% rain rate - no ship rain on TGT in ASTRAL 2024
% figure;
% plot(b10.t,b10.prate,'r',b10.t,b10.prate_s,'b'); grid; xlim([t0 tN]);
% ylabel('mm/hr'); datetick('x','mm/dd','keeplimits');
% legend('NOAA','ship','location','eastoutside');
% title([ptitle,' rain rate']);
% annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 21'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
% ppath = fullfile(png_path,['021_',cruise,'_Rain.png']);
% print('-dpng',ppath);

%% SOG
figure;
plot(b10.t,b10.sog,'or',b10.t,b10.sog_s,'xb'); grid; xlim([t0 tN]);
ylabel('m s^{-1}'); datetick('x','mm/dd','keeplimits');
legend('NOAA','ship','location','eastoutside');
title([ptitle,' speed over ground']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 22'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['022_',cruise,'_SOG.png']);
print('-dpng',ppath);

%% COG
figure;
plot(b10.t,b10.cog,'or',b10.t,b10.cog_s,'xb'); grid; axis([t0,tN,0,360]);
yticks([0,90,180,270,360]); ylabel('^o'); datetick('x','mm/dd','keeplimits');
legend('NOAA','ship','location','eastoutside');
title([ptitle,' course over ground']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 23'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['023_',cruise,'_COG.png']);
print('-dpng',ppath);

%% heading
figure;
plot(b10.t,b10.hed, 'or', b10.t, b10.hed_s,'xb'); grid; axis([t0,tN,0,360]);
ylabel('^o'); datetick('x','mm/dd','keeplimits');
legend('NOAA','ship','location','eastoutside');
title([ptitle,' heading']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 24'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['024_',cruise,'_Heading.png']);
print('-dpng',ppath);

%% std dev heading
figure;
plot(b10.t,d10.hed_std, 'r'); grid; xlim([t0,tN]);
ylabel('^o'); datetick('x','mm/dd','keeplimits');
legend('NOAA','location','best');
title([ptitle,' standard deviation of heading']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 25'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['025_',cruise,'_StdDev_Heading.png']);
print('-dpng',ppath);

%% map
map_all_cruise(b10.lon,b10.lat,ptitle,PosLims)
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 26'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['026_',cruise,'_TrackMap.png']);
print('-dpng',ppath);

%% q licor plot

figure;
subplot(2,1,1); 
    plot(b10.t,b10.qa,'or',b10.t,b10.licor_qa,'xk'); grid; xlim([t0 tN]);
    ylabel('q, g kg^{-1}'); datetick('x','dd','keeplimits');
    title([ptitle,' specific humidity']);
    legend('Vaisala','Licor','location','best');
subplot(2,1,2);
    plot(b10.t,b10.licor_agc,'.r',[t0,tN],[agc_lim,agc_lim],'g--',[t0,tN],[50,50],'g-');
    grid; ylabel('agc'); datetick('x','dd','keeplimits');
    ylim([48,100]); xlim([t0 tN]);
    if strcmp(cruise,'PISTON_2019') == 1
       hold on;
       plot([bad_licor_day bad_licor_day], ylim,'--k');
       text(bad_licor_day-0.25, agc_lim, 'bad after this point',...
           'rotation',90,'fontweight','bold','fontsize',16);
    end
    legend('Licor agc','agc Limit','agc = 50','location','northoutside','orientation','horizontal');
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 27'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['027_',cruise,'_Licor_Qa_agc.png']);
print('-dpng',ppath);


%% stars / scaling parameters
    
figure('position',[1,1,1450,800]);
subplot(3,1,1);
    plot(b10.t, b10.tsr,'r-', d10.t, d10.tsr_ida,'om', d10.t, d10.tsr_idb, 'oc',...
        d10.t, d10.tsr_id,'*b', d10.t, d10.tsr_cov_sds,'og', d10.t, d10.tsr_cov,'*k');
    grid; xlim([t0 tN]);
    datetick('x','mm/dd','keeplimits'); ylabel('K');
    legend('bulk','ID a','ID b','ID combo','cov SdS','cov','location','eastoutside');
    title([ptitle ' t_*']);
subplot(3,1,2);
    plot(b10.t, b10.qsr,'r-', d10.t, d10.qsr_ida,'om', d10.t, d10.qsr_idb, 'oc',...
        d10.t, d10.qsr_id,'*b', d10.t, d10.qsr_cov_sds,'og', d10.t, d10.qsr_cov,'*k');
    grid; xlim([t0 tN]);
    datetick('x','mm/dd','keeplimits'); ylabel('g g{-1}');
    legend('bulk','ID a','ID b','ID combo','cov SdS','cov','location','eastoutside');
    title([ptitle ' q_*']);
subplot(3,1,3);
    plot(b10.t, b10.usr,'r-', d10.t, d10.usr_ida,'om', d10.t, d10.usr_idb, 'oc',...
        d10.t, d10.usr_id,'*b', d10.t, d10.usr_cov,'*k');
    grid; xlim([t0 tN]);
    datetick('x','mm/dd','keeplimits'); ylabel('m s^{-1}');
    legend('bulk','ID a','ID b','ID combo','cov','location','eastoutside');
    title([ptitle ' u_*']);
    annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 28'},'FontSize',10,'FitBoxToText','off','LineStyle','none');

    
ppath = fullfile(png_path,['028_',ptitle,'_Stars.png']);
print('-dpng',ppath);

figure('position',[1,1,1450,800]);
subplot(3,1,1);
    plot(b10.t, b10.hs,'r-', d10.t, d10.hs_ida,'om', d10.t, d10.hs_idb, 'oc',...
        d10.t, d10.hs_id,'*b', d10.t, -d10.hs_cov_sds,'og', d10.t, -d10.hs_cov,'*k');
    grid; xlim([t0 tN]);
    datetick('x','mm/dd','keeplimits'); ylabel('W m{-2}');
    legend('bulk','ID a','ID b','ID combo','cov SdS','cov','location','eastoutside');
    title([ptitle ' hs']);
subplot(3,1,2);
    plot(b10.t, b10.hl,'r-', d10.t, d10.hl_ida,'om', d10.t, d10.hl_idb, 'oc',...
        d10.t, d10.hl_id,'*b', d10.t, d10.hl_cov_sds,'og', d10.t, d10.hl_cov,'*k');
    grid; xlim([t0 tN]);
    datetick('x','mm/dd','keeplimits'); ylabel('W m{-2}');
    legend('bulk','ID a','ID b','ID combo','cov SdS','cov','location','eastoutside');
    title([ptitle ' hl']);
subplot(3,1,3);
    plot(b10.t, b10.tau,'r-', d10.t, d10.tau_ida,'om', d10.t, d10.tau_idb, 'oc',...
        d10.t, d10.tau_id,'*b', d10.t, d10.tau_cov,'*k');
    grid; xlim([t0 tN]);
    datetick('x','mm/dd','keeplimits'); ylabel('N m{-2}');
    legend('bulk','ID a','ID b','ID combo','cov','location','eastoutside');
    title([ptitle ' tau']);
    annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 28'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
 
ppath = fullfile(png_path,['028_',ptitle,'_Fluxes.png']);
print('-dpng',ppath);


%% solar flux
figure('position',[1,1,800,475]);
plot(b10.t,b10.sw_dn_clr,'k--',b10.t,b10.sw_dn,'r-'); grid; xlim([t0 tN]);
datetick('x','mm/dd','keeplimits'); ylabel('Solar Flux, W m^{-2}');
legend('clear sky','measured','location','eastoutside');
title([ptitle ' downwelling solar flux']);
    annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 29'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['029_',ptitle,'_Solar_Best_Clearsky.png']);
print('-dpng',ppath);

%% IR flux
figure('position',[1,1,800,475]);
plot(b10.t,b10.lw_dn_clr,'k--',b10.t,b10.lw_dn,'r-'); grid; xlim([t0 tN]);
datetick('x','mm/dd','keeplimits'); ylabel('IR Flux, W m^{-2}');
legend('clear sky','measured','location','eastoutside');
title([ptitle ' downwelling IR flux']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 30'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['030_',ptitle,'_IR_Best_Clearsky.png']);
print('-dpng',ppath);

%% transfer coefficients w'T'
% plot of w't'/u10n vs delta theta from surface - air should be linear, slope is ~ch10n, and
% x-intercept is measure of bias in deltaT measurement
wT_u = d10.wt_cov./b10.u10n;
wT_sds_u = d10.wt_cov_sds./b10.u10n;
% dts = b10.tskin-theta10;  % Delta T, use potential temp at 10m... and theta 0 (this was wrong before)
% wT plot criteria
clear idt;
idt = (isfinite(wT_u) & isfinite(b10.dtheta) & isfinite(d10.wt_cov_sds) &...
    b10.dtheta<3 & b10.dtheta>-2 & wT_u>-0.01 & wT_u<0.01);
minx = min(b10.dtheta(idt))-0.1; 
maxx = max(b10.dtheta(idt));
coef_T = polyfit(b10.dtheta(idt),wT_u(idt),1);
coef_Tsds = polyfit(b10.dtheta(idt),wT_sds_u(idt),1);
liney_T = coef_T(1)*[minx,maxx] + coef_T(2); 
xIntcpt_T = coef_T(2)/-coef_T(1);
liney_Tsds = coef_Tsds(1)*[minx,maxx] + coef_Tsds(2); 
xIntcpt_Tsds = coef_Tsds(2)/-coef_Tsds(1);

figure('position',[1,1,800,475]);
plot(b10.dtheta(idt),wT_u(idt),'r.',b10.dtheta(idt),wT_sds_u(idt),'b.'); hold on;
plot(xlim,liney_T,'r--',xlim,liney_Tsds,'b--','linewidth',2);
plot([0,0],[-0.01,0.01],'k',xlim,[0,0],'k'); grid;
ylim([-0.006,0.006]); xlim(xlim); legend({'PSL','SdS'},'fontsize',14,'location','northwest');
ylabel('w`T`/u_{10n}'); xlabel('\theta_{skin} - \theta_{10n}');
title([ptitle ' w`T` transfer coefficient']);
annotation(gcf,'textbox',[0.25 0.8 0.4498 0.02462],'String',...
    {['ch10n x 1000 = ',num2str(coef_T(1)*1000,'%6.5f'),' / ',num2str(coef_Tsds(1)*1000,'%6.5f'),...
    '  y-Intcpt = ',num2str(coef_T(2),'%6.5f'),' / ',num2str(coef_Tsds(2),'%6.5f'),...
    '  x-Intcpt = ',num2str(xIntcpt_T,'%6.5f'),' / ',num2str(xIntcpt_Tsds,'%6.5f')]},...
    'FontSize',10,'FitBoxToText','off','LineStyle','none');
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 31'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['031_',ptitle,'_wt_u_vs_dtheta.png']);
print('-dpng',ppath);

%% transfer coefficients w'q'
wq_u = (d10.wq_cov-(d10.wbar.*(b10.qa/1000)))./b10.u10n; % (wq - wbar*qbar) = Webb corrected 
wq_sds_u = d10.wq_cov_sds./b10.u10n; % already webb corrected
dqs = b10.qs-b10.qa10n;

clear idq;
idq = (isfinite(wq_u) & isfinite(wq_sds_u) & isfinite(dqs));
minx = min(dqs(idq))-2; 
maxx = max(dqs(idq))+2;
coef_q = polyfit(dqs(idq),wq_u(idq),1);
coef_qsds = polyfit(dqs(idq),wq_sds_u(idq),1);
liney_q = coef_q(1)*[0,maxx] + coef_q(2); 
xIntcpt_q = coef_q(2)/-coef_q(1);
liney_qsds = coef_qsds(1)*[0,maxx] + coef_qsds(2); 
xIntcpt_qsds = coef_qsds(2)/-coef_qsds(1);

figure('position',[1,1,800,475]);
plot(dqs(idq),wq_u(idq),'r.',dqs(idq),wq_sds_u(idq),'b.'); hold on;
plot([0,maxx],liney_q,'r--',[0,maxx],liney_qsds,'b--','linewidth',2);
plot([0,0],[-0.02,0.02],'k',[0,maxx],[0,0],'k'); grid;
xlim([0,maxx]); ylim([-0.005,0.02]); legend({'PSL','SdS'},'fontsize',14,'location','northwest');
ylabel('w`q`/u_{10n}'); xlabel('q_{skin} - q_{10n}');
title([ptitle ' w`q` transfer coefficient']);
annotation(gcf,'textbox',[0.25 0.8 0.4498 0.02462],'String',...
    {['ce10n x 1000 = ',num2str(coef_q(1)*1000,'%6.5f'),' / ',num2str(coef_qsds(1)*1000,'%6.5f'),...
    '  y-Intcpt = ',num2str(coef_q(2),'%6.5f'),' / ',num2str(coef_qsds(2),'%6.5f'),...
    '  x-Intcpt = ',num2str(xIntcpt_q,'%6.5f'),' / ',num2str(xIntcpt_qsds,'%6.5f')]},...
    'FontSize',10,'FitBoxToText','off','LineStyle','none');
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 32'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['032_',ptitle,'_wq_u_vs_dqs.png']);
print('-dpng',ppath);

%% stability function for velocity structure function
figure('position',[1,1,800,475]); 
semilogy(zeta_fake,cuxx,'k-'); hold on;
semilogy(zeta_log_bin,cs_plot,'rO'); grid; axis([-15 1 1 100]);
xlabel('z/L'); ylabel('psi-fu(z/L)');
legend('psi-fu(z/L)','(Cs/u*)^2 * zu^{2/3}','location','eastoutside');
title([ptitle,' dimensionless stability function for u structure function']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 33'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['033_',ptitle,'_Psi_fu.png']);
print('-dpng',ppath);

%% ratio: stability function for velocity structure function
figure('position',[1,1,800,475]);
plot(zeta_fake,ones(length(zeta_fake),1),'k-'); hold on;
plot(zeta_log_bin,cs_plot./psi_fu(zeta_log_bin),'rd'); grid;
xlim([min(zeta_log_bin)-5,max(zeta_log_bin)+5]); 
xlabel('z/L'); ylabel('Ratio');
legend('1','(Cs/u*)^2 * zu^{2/3} / psi-fu(z/L)');
title([ptitle,' ratio: dimensionless stability function for u structure function']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 34'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['034_',ptitle,'_Csm_Psi_fu_ratio.png']);
print('-dpng',ppath);

%% ID estimate for 10-min cd10n vs u
% jjj = wh_good_id 
figure('position',[1,1,800,475]);
plot(b10.u10n(jjj),b10.cdn10(jjj),'k.',...
    b10.u10n(jjj),(d10.usr_id(jjj)./b10.u10n(jjj)).^2,'r.'); grid;
axis([0 14 0 2e-3]); 
xlabel('u_{10n} m/s'); ylabel('cd_{10n}');
legend({'bulk','ID: (u_{*ID}/u_{10n})^2'},'location','eastoutside');
title([ptitle,' cd_{10n}']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 35'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['035_',ptitle,'_ID_cd10n_v_u.png']);
print('-dpng',ppath);

%% wind-binned cd10n vs u
% jjj = wh_good_id
figure('position',[1,1,800,475]);
p0 = plot(b10.u10n(jjj),b10.cdn10(jjj),'k.'); hold on;
clear ii; ii = cd_id_bin_nn>0;
p1 = errorbar(u10n_bin(ii),cd_id_bin_mean(ii),cd_id_bin_std(ii)./sqrt(cd_id_bin_nn(ii)),'rd-','linewidth',2);
grid;
axis([0 14 0 2e-3]); xlabel('u_{10n} m/s'); ylabel('cd_{10n}');
legend([p0,p1],{'bulk','ID: (u_{*ID}/u_{10n})^2'},'location','eastoutside');
title([ptitle,' cd_{10n}, median +/- std error of mean']); 
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 36'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['036_',ptitle,'_bin_ID_cd10n_v_u.png']);
print('-dpng',ppath);


%% ID sensible heat fluxes
% jjj = wh_good_id 
minx = max(min(b10.hs(jjj)),-40)-10; 
maxx = max(b10.hs(jjj))+10;
figure('position',[1,1,800,475]); plot([minx maxx],[minx maxx],'k--'); hold on;
plot([0 0],[minx maxx],'k-',[minx maxx],[0 0],'k-',[minx maxx],[minx maxx],'k--');
plot(b10.hs(jjj),hs_id(jjj),'r.'); grid;
axis([minx maxx minx maxx]); xlabel('hs bulk, W m^{-2}');
ylabel('hs ID, W m^{-2}'); 
title([ptitle,' sensible heat flux']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 37'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['037_',ptitle,'_ID_Hs_v_bulk.png']);
print('-dpng',ppath);

%% binned ID hs
minx = min(hs_bulk_bin)-10; 
maxx = max(hs_bulk_bin)+10;
figure('position',[1,1,800,475]);
p0 = plot([minx maxx],[minx maxx],'k--'); hold on;
p1 = plot([0 0],[minx maxx],'k-',[minx maxx],[0 0],'k-',[minx maxx],[minx maxx],'k--');
p2 = errorbar(hs_bulk_bin,hs_id_bin_mean,hs_id_std,'rd-','linewidth',2); grid;
axis([minx maxx minx maxx]); xlabel('hs bulk, W m^{-2}');
ylabel(' hs ID, W m^{-2}'); 
title([ptitle,' sensible heat flux, mean +/- \sigma']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 38'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['038_',ptitle,'_bin_ID_Hs_v_bulk.png']);
print('-dpng',ppath);

%% compare hs_id and hs_cov
% jjj = wh_good_id
minx = max(min(b10.hs(jjj)),-20)-10; 
maxx = max(b10.hs(jjj))+10;
figure('position',[1,1,800,475]); 
p1 = plot([minx maxx],[minx maxx],'k--'); hold on;
p2 = plot([0 0],[minx maxx],'k-',[minx maxx],[0 0],'k-',[minx maxx],[minx maxx],'k--');
p3 = plot(b10.hs(jjj),hs_id(jjj),'b.',b10.hs(jjj),-d10.hs_cov(jjj),'r.');
axis([minx maxx minx maxx]); grid; xlabel('hs bulk, W m^{-2}');
ylabel('W m^{-2}'); 
legend(p3,{'hs ID','hs covariance'},'location','eastoutside');
title([ptitle,' sensible heat flux']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 39'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['039_',ptitle,'_hsib_hsc_v_bulk.png']);
print('-dpng',ppath);

%% ID latent heat flux vs bulk
% jjj = wh_good_id
figure('position',[1,1,800,475]);
plot([0 300], [0 300],'k--'); hold on;
plot(b10.hl(jjj),hl_id(jjj),'r.'); axis([0 300 0 300]);  grid;
xlabel('hl bulk, W m^{-2}'); ylabel('hl ID, W m^{-2}');
title([ptitle,' latent heat flux']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 40'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['040_',ptitle,'_ID_Hl.png']);
print('-dpng',ppath);

%% covariance latent heat vs bulk
figure('position',[1,1,800,475]);
plot([0 300], [0 300],'k--'); hold on;
plot(b10.hl,d10.hl_cov,'r.'); axis([0 300 0 300]);  grid;
xlabel('hl bulk, W m^{-2}'); ylabel('hl covariance, W m^{-2}');
title([ptitle,' latent heat flux']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 41'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['041_',ptitle,'_Cov_Hl.png']);
print('-dpng',ppath);

%% inertial dissipation latent heat flux vs wind speed
miny = nanmin1(hl_id_u)-30; 
maxy = nanmax1(hl_id_u)+30;
figure('position',[1,1,800,475]);
clear yy; yy = find(ynn_u > 2);
plot(u_bin(yy)+0.5,hl_u(yy),'--k',u_bin(yy)+0.5,hl_id_u(yy),'-or'); 
title([ptitle,' wind-binned latent heat flux']);
xlabel('u_{10n}, m s^{-1}');
ylabel('hl, W m^{-2}'); grid;
if isfinite(miny) == 1 && isfinite(maxy) == 1
    ylim([miny maxy]);
end
legend('hl bulk median','hl ID median','location','northwest');
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 42'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['042_',ptitle,'_Hlm_WindBin.png']);
print('-dpng',ppath);

%% ID vs bulk latent flux
figure('position',[1,1,800,475]); hold on;
plot(hl_u,hl_id_u,'or',[0 maxy],[0 maxy],'--k'); 
xlabel('hl bulk, W m^{-2}');
ylabel('hl ID, W m^{-2}'); 
grid; 
if isfinite(miny) == 1 && isfinite(maxy) == 1
    ylim([0 maxy]); xlim([0 maxy]);
end
title([ptitle,' wind-binned latent heat flux']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 43'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['043_',ptitle,'_Hlm_Bin_v_bulk.png']);
print('-dpng',ppath);

%% -w'u' vs usr_id squared with filtering: ppp... doesn't make sense anymore
figure('position',[1,1,800,475]);
p1 = plot([t0 tN],[0 0],'--k'); hold on;
p2 = plot(b10.t,-d10.wu_cov,'r.',b10.t,d10.usr_id.^2,'b.');
xlim([t0 tN]);
grid; datetick('x','mm/dd','keeplimits'); ylabel('m^2 s^{-2}');
legend(p2,{'-w`u`','u_{*ID}^2'},'location','northwest');
title([ptitle,' ID and covariance']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 44'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['044_',ptitle,'_Wu_StdFiltered.png']);
print('-dpng',ppath);

%% -w'u' vs usr_id squared, but with more filtering: ppp(kk) doesn't make sense anymore
figure('position',[1,1,800,475]);
p1 = plot([t0 tN],[0 0],'--k'); hold on;
p2 = plot(b10.t,-d10.wu_cov,'r.',b10.t,d10.usr_id.^2,'b.');
xlim([t0 tN]); 
grid; datetick('x','mm/dd','keeplimits'); ylabel('m^2 s^{-2}');
legend(p2,{'-w`u`','u_{*ID}^2'},'location','northwest');
title([ptitle,' ID and covariance']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 45'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['045_',ptitle,'_Wu_AddFiltered.png']);
print('-dpng',ppath);

%% zu over L vs humidity structure function with filtering: ppp... doesn't make sense anymore
figure('position',[1,1,800,475]);
semilogy(b10.zeta,d10.Cqab./(b10.qsr*1000).^2.*zu^.67,'.r',...
    b10.zeta,psi_ft(b10.zeta),'.k')
axis([-10 2 0.01 5e2]);
xlabel('z/L'); ylabel('Cq^2/q_{*bulk}^2 z^{2/3}'); grid;
legend('obs','Psi-ft(z/L)','location','eastoutside');
title([ptitle,'  Cq^2 and Psi-ft(z/L)']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 46'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['046_',ptitle,'_cq2.png']);
print('-dpng',ppath);

%% zu over L vs. temp structure function with filtering: ppp... doesn't make sense anymore
figure('position',[1,1,800,475]);
semilogy(b10.zeta,d10.Ctab./(b10.tsr).^2.*zu^.67,'.r',...
    b10.zeta,psi_ft(b10.zeta),'.k'); grid;
axis([-10,2,0.01,5e2]); xlabel('z/L'); ylabel('Ct^2/t_{*bulk}^2 z^{2/3}');
legend('obs','Psi-ft(z/L)','location','eastoutside');
title([ptitle,' Ct^2 and Psi-ft(z/L)']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 47'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['047_',ptitle,'_ct2.png']);
print('-dpng',ppath);

%% zu over L vs. humidity stdev with filtering: ppp... doesn't make sense anymore
figure('position',[1,1,800,475]);
semilogy(b10.zeta,d10.licor_qa_std./abs(b10.qsr*1000),'.r',...
    b10.zeta,phi_tt(b10.zeta),'.k'); grid;
axis([-10,2,0.1,5e1]); xlabel('z/L'); ylabel('Dimensionless \sigma q');
legend('obs','Phi-tt(z/L)','location','eastoutside');
title([ptitle,' dimensionless \sigma q (normalized by q_{*bulk}) and Psi-tt(z/L)']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 48'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['048_',ptitle,'_sigmaQ.png']);
print('-dpng',ppath);

%% zu over L vs sonic temp stdev
% normalization is accomplished by standard deviation of Tsonic over Tstar from Tsonic
%       Ts_std / tstar_sonic
% NOTE: Tsonic std is square root of Tsonic variance. Must also use Tstar
% from sonic directly, not the humidity corrected true Tstar.
figure('position',[1,1,800,475]);
% semilogy(b10.zeta(ppp),phi_tt(b10.zeta(ppp)),'.',...
% b10.zeta(ppp),sqrt(d10.Tvar(ppp))./abs(b10.tsr_son(ppp)),'.');
semilogy(b10.zeta,sqrt(d10.Tvar)./abs(b10.tsr_son),'.r',...
    b10.zeta,phi_tt(b10.zeta),'.k'); 
% axis([-10,2,0.1,5e1]); xlabel('z/L'); ylabel('Dimensionless \sigma Tsonic'); grid; ??
axis([-10,2,0.1,5e1]); xlabel('z/L'); ylabel('Dimensionless T variance'); grid;
legend('obs','Phi-tt(z/L)','location','eastoutside');
title([ptitle,' dimensionless \sigmaT (normalized by t_{*bulk}) and Psi-tt(z/L)']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 49'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['049_',ptitle,'_sigmaTs.png']);
print('-dpng',ppath);

% normalized by t' or tsr? said sigma Ts before, but it was really variance
% plotted. 

%% zu over L vs. sigma q / sigma Tsonic with filtering: ppp... doesn't make sense anymore
figure('position',[1,1,800,475]);
semilogy(b10.zeta,(d10.licor_qa_std./abs(b10.qsr*1000))./...
(sqrt(d10.Tvar)./abs(b10.tsr_son)),'.r', [-10 2],[.85 .85],'-k'); grid;
axis([-10 2 0.1 1e1]); xlabel('z/L'); ylabel('Dimensionless \sigma q / \sigma T');
title([ptitle,' \sigma q / \sigma T']);
legend('obs','0.85','location','eastoutside');
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 50'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['050_',ptitle,'_sigmaQ_sigmaTs_Ratio.png']);
print('-dpng',ppath);

%% cov v. bulk ustar
% jjjj = good_id and good usr_id
figure('position',[1,1,800,475]);
plot([-1,5],[-1,5],'k-',b10.usr(jjjj),d10.usr_cov(jjjj),'r.'); grid; axis([0,0.75,0,0.75]);
xlabel('u_* bulk, m/s'); ylabel('u_* covariance, m/s');
title([ptitle,' u_* bulk vs. covariance']);
ppath = fullfile(png_path,['051_',ptitle,'_ustar_cov_v_bulk.png']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 51'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
print('-dpng',ppath);

%% binned cov ustar
figure('position',[1,1,800,475]);
plot([-1,5],[-1,5],'k-'); hold on;
errorbar(usr_bulk_bin,usr_cov_bin_mean,usr_cov_bin_std,'rd-','linewidth',2);
axis([0,0.75,0,0.75]); grid; xlabel('u_* bulk, m s^{-1}');
ylabel(' u_* covariance, m s^{-1}'); 
title([ptitle,' u_* bulk vs. covariance, mean +/- \sigma']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 52'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['052_',ptitle,'_bin_ustar_cov_v_bulk.png']);
print('-dpng',ppath);

%% ID ustar
% jjjj = good_motion_id and finite(usr_id)
figure('position',[1,1,800,475]);
plot([-1,5],[-1,5],'k-',b10.usr(jjjj),d10.usr_id(jjjj),'r.'); 
grid; axis([0,0.75,0,0.75]);
xlabel('u_* bulk, m/s'); ylabel('u_* ID, m/s');
title([ptitle,'  u_* bulk vs. ID']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 53'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['053_',ptitle,'_ustar_ID_v_bulk.png']);
print('-dpng',ppath);

%% binned ID ustar
figure('position',[1,1,800,475]);
plot([-1,5],[-1,5],'k-'); hold on;
errorbar(usr_bulk_bin,usr_id_bin_mean,usr_id_bin_std,'rd-','linewidth',2);
axis([0,0.75,0,0.75]); grid; xlabel('u_* bulk, m s^{-1}');
ylabel('u_* ID m s^{-1}'); 
title([ptitle,' u_* bulk vs. ID, mean +/- \sigma']);

annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 54'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['054_',ptitle,'_bin_ustar_ID_v_bulk.png']);
print('-dpng',ppath);

%% cov tstar
% jjjj = good_motion_id and finite(usr_id)
figure('position',[1,1,800,475]);
plot([-1,1],[0,0],'k-',[0,0],[-1,1],'k-'); hold on;
h1 = plot(b10.tsr(jjjj),d10.tsr_cov(jjjj),'.r',b10.tsr(jjjj),d10.tsr_cov_sds(jjjj),'.b'); 
plot([-1,1],[-1,1],'k--');
grid; axis([-0.3,0.3,-0.3,0.3]);
xlabel('t_* bulk, ^oC'); ylabel('t_* covariance, ^oC'); legend(h1,'PSL','SdS','location','northwest');
title([ptitle,'  t_* bulk vs. covariance']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 55'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['055_',ptitle,'_tstar_cov_v_bulk.png']);
print('-dpng',ppath);

%% binned cov tstar
figure('position',[1,1,800,475]);
plot([-1,1],[0,0],'k-',[0,0],[-1,1],'k-'); hold on;
h1 = errorbar(tsr_bulk_bin,tsr_cov_bin_mean,tsr_cov_std,'rd-','linewidth',2); 
h2 = errorbar(tsr_bulk_bin,tsr_cov_sds_bin_mean,tsr_cov_sds_std,'bd-','linewidth',2);
plot([-1,1],[-1,1],'k--');
axis([-0.3,0.3,-0.3,0.3]); grid; xlabel('t_* bulk, ^oC');
legend([h1,h2],'PSL','SdS','location','northwest');
ylabel('t_* covariance, ^oC'); 
title([ptitle,' t_* bulk vs. covariance, mean +/- \sigma']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 56'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['056_',ptitle,'_bin_tstar_cov_v_bulk.png']);
print('-dpng',ppath);


%% ID tstar
% jjjj = good_motion_id and finite(usr_id)
figure('position',[1,1,800,475]);
plot([-1,1],[0,0],'k-',[0,0],[-1,1],'k-'); hold on;
plot(b10.tsr(jjjj),d10.tsr_id(jjjj),'.r'); grid; axis([-0.3,0.3,-0.3,0.3]);
plot([-1,1],[-1,1],'k--');
xlabel('t_* bulk, ^oC'); ylabel('t_* ID, ^oC');
title([ptitle,'  t_* bulk vs. ID']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 57'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['057_',ptitle,'_tstar_ID_v_bulk.png']);
print('-dpng',ppath);


%% binned ID tstar
% ID flux binned by bulk flux
figure('position',[1,1,800,475]);
plot([-1,1],[0,0],'k-',[0,0],[-1,1],'k-'); hold on;
errorbar(tsr_bulk_bin,tsr_id_bin_mean,tsr_id_bin_std,'rd-','linewidth',2);
plot([-1,1],[-1,1],'k--');
axis([-0.3,0.3,-0.3,0.3]); grid; xlabel('t_* bulk, ^oC');
ylabel('t_* ID, ^oC'); 
title([ptitle,' t_* bulk vs. ID, mean +/- \sigma']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 58'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['058_',ptitle,'_bin_tstar_ID_v_bulk.png']);
print('-dpng',ppath);

%% qstar cov vs bulk
% jjjj = good_motion_id and finite(usr_id)
figure('position',[1,1,800,475]);
plot([-1,1],[0,0],'k-',[0,0],[-1,1],'k-'); hold on;
plot(b10.qsr(jjjj),d10.qsr_cov(jjjj),'r.'); axis([-0.4e-3,0.05e-3,-0.4e-3,0.05e-3]);
plot([-1,5],[-1,5],'k--');
grid; xlabel('q_* bulk, g kg^{-1}'); ylabel('q_* covariance, kg kg^{-1}');
title([ptitle,'  q_* bulk vs. covariance']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 59'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['059_',ptitle,'_qstar_cov_v_bulk.png']);
print('-dpng',ppath);

%% qstar id vs bulk
% jjjj = good_motion_id and finite(usr_id)
figure('position',[1,1,800,475]);
plot([-1,1],[0,0],'k-',[0,0],[-1,1],'k-'); hold on;
plot(b10.qsr(jjjj),d10.qsr_id(jjjj),'r.'); axis([-0.4e-3,0.05e-3,-0.4e-3,0.05e-3]);
plot([-1,5],[-1,5],'k--');
grid; xlabel('q_* bulk, g kg^{-1}'); ylabel('q_* ID, kg kg^{-1}');
title([ptitle,'  q_* bulk vs. ID']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 60'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['060_',ptitle,'_qstar_ID_v_bulk.png']);
print('-dpng',ppath);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% daily averages
%% daily clear sky transmission
figure('position',[1,1,800,475]);
plot(day.lat,day.sw_dn./day.sw_dn_clr,'-o'); grid;
axis([Latmin,Latmax,0,1.1]);
xlabel('latitude, ^o'); ylabel('cloud trans. coef.');
title([ptitle,' daily cloud transmission coef: solar down measured/clear-sky']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 61'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['061_',ptitle,'_cloud_trans_coef_v_lat.png']);
print('-dpng',ppath);

%% daily clear sky vs cloudy radiative fluxes
jj = find(day.lat>Latmin);
% jj = good latitudes
figure('position',[1,1,800,475]);
plot(1-day.sw_dn(jj)./day.sw_dn_clr(jj),day.lw_dn(jj)-day.lw_dn_clr(jj),'o'); grid;
axis([0,1,0,100]); 
xlabel('1 - tran. coeff. (solar downwelling measured/clear-sky)'); ylabel('IR downwelling measured - clear sky, W m^{-2}');
title([ptitle,' daily cloud forcing']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 62'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['062_',ptitle,'_cloud_IR_v_lat.png']);
print('-dpng',ppath);

%% daily solar and IR fluxes
% jj = good latitudes
figure('position',[1,1,800,475]);
plot([0 200],[0 80],'k--',day.sw_dn_clr(jj)-day.sw_dn(jj),day.lw_dn(jj)-day.lw_dn_clr(jj),'o'); grid;
axis([0 200 0 100]); 
xlabel('solar, W m^{-2}'); ylabel('IR, W m^{-2}');
title([ptitle,' daily radiative cloud forcing (downwelling measured - clear sky)']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 63'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['063_',ptitle,'_IR_v_solar_flux.png']);
print('-dpng',ppath);

%% daily cloud forcing vs latitude
figure('position',[1,1,800,475]);
plot(day.lat,day.sw_dn-day.sw_dn_clr,'-o',day.lat,day.lw_dn-day.lw_dn_clr,'-x',[Latmin Latmax],[0 0 ],'--k');
xlim([Latmin Latmax]); grid;
xlabel('latitude, ^o'); ylabel('cloud forcing (down measured - clear sky), W m^{-2}');
legend('solar', 'IR','location','best');
title([ptitle,' daily downwelling radiative cloud forcing vs latitude']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 64'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['064_',ptitle,'_cloud_forcing_v_lat.png']);
print('-dpng',ppath);

%% daily cloud forcing
figure('position',[1,1,800,475]);
plot(day.t+0.5,day.sw_dn-day.sw_dn_clr,'-o',day.t+0.5,day.lw_dn-day.lw_dn_clr,'-x',...
    [t0 tN],[0 0 ],'k--');
xlim([t0 tN]); grid;
datetick('x','mm/dd','keeplimits'); ylabel('cloud forcing (down measured - clear sky), W m^{-2}');
legend('solar', 'IR','location','best');
title([ptitle,' daily downwelling radiative cloud forcing']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 65'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['065_',ptitle,'_cloud_forcing.png']);
print('-dpng',ppath);

%% daily net heat flux
figure('position',[1,1,800,475]);
plot(day.t+0.5, day.hnet,'ro-',[t0 tN],[0,0],'k--'); grid;
xlim([t0 tN]);
datetick('x','mm/dd','keeplimits'); ylabel('h_{net}, W m^{-2}');
title([ptitle,' daily mean net heat flux']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 66'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['066_',ptitle,'_daily_net_heat.png']);
print('-dpng',ppath);

close all;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% hourly heat flux and stress plots
if hourly == 1
    
    
%% timeseries for various verisons of hourly hl
maxy = max(hr.hl_cov)+50;
figure('position',[1,1,800,475]);
% yhlc is hr ave heat flux computed from hourly filtered 10-min wq_lic
subplot(3,1,1); plot(hr.t,hr.hl_cov,'r',hr.t,hr.hl_cov_sds,'b'); 
grid; axis([t0 tN 0 maxy]);
ylabel('W m^{-2}'); datetick('x','mm/dd','keeplimits'); legend('NOAA','SdS');
title([ptitle ' hl cov: recomputed']);legend('NOAA','sds');
% yhlib_lic is hr ave heat flux from filtered hourly cq2
subplot(3,1,2); plot(hr.t,hr.hl_id,'r'); 
grid; axis([t0 tN 0 maxy]); legend('NOAA');
ylabel('W m^{-2}'); datetick('x','mm/dd','keeplimits'); legend('mean(mean)','recomputed');
title([ptitle ' hl id: recomputed']);
% hlc_licbar is hr ave of filtered 10-min hl from original run
subplot(3,1,3); plot(hr.t,hr.hl_cov,'r', hr.t, hr.hl_cov_sds,'b'); 
grid; axis([t0 tN 0 maxy]); legend('NOAA','sds');
ylabel('W m^{-2}'); datetick('x','mm/dd','keeplimits');
title([ptitle ' hl cov: hourly mean of original 10-min hlc']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 67'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['067_',ptitle,'_Hl_timeseries.png']);
print('-dpng',ppath);

%% hl cov vs bulk hourly
minx = -10; maxx = 300;
figure('position',[1,1,800,475]);
plot(hr.hl,hr.hl_cov,'or',hr.hl,hr.hl_cov_sds,'xb',[minx maxx],[minx maxx],'--k');
grid; axis([minx maxx minx maxx]); 
legend('NOAA cov','SdS cov','location','northwest');
xlabel('bulk hl, W m^{-2}'); ylabel('cov hl, W m^{-2}');
title([ptitle,' Hourly Latent Heat Flux']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 68'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['068_',ptitle,'_Hl_cov_v_bulk.png']);
print('-dpng',ppath);

%% hl ID vs bulk hourly
minx = -10; 
maxx = 300;
figure('position',[1,1,800,475]);
plot([minx maxx],[minx maxx],'--k',hr.hl,hr.hl_id,'ro');
grid; axis([minx maxx minx maxx]);
xlabel('bulk hl, W m^{-2}'); ylabel('ID hl, W m^{-2}');
title([ptitle,' Hourly Latent Heat Flux']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 69'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['069_',ptitle,'_Hl_ID_v_bulk.png']);
print('-dpng',ppath);

%% timeseries of hs cov hourly
minx = min(hr.hs_cov)-20; 
maxx = max(hr.hs_cov)+20;
figure('position',[1,1,800,475]);
plot(hr.t,-hr.hs_cov,'ro',hr.t,hr.hs_cov_sds,'bd',hr.t,hr.hs,'k-',...
    [t0 tN],[0 0],'k--'); 
grid; axis([t0 tN minx maxx]);
datetick('x','mm/dd','keeplimits'); ylabel('W m^{-2}');
legend('NOAA cov','SdS cov','bulk','location','eastoutside');
title([ptitle,' Hourly Sensible Heat Flux']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 70'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['070_',ptitle,'_Hs_cov_timeseries.png']);
print('-dpng',ppath);

%% timeseries of hs ID hourly
minx = -20; 
maxx = 75;
figure('position',[1,1,800,475]);
plot(hr.t,hr.hs_id,'ro',hr.t,hr.hs,'k-',[t0 tN],[0 0],'k--'); 
grid; axis([t0 tN minx maxx]);
datetick('x','mm/dd','keeplimits'); ylabel('W m^{-2}');
legend('ID','bulk','location','eastoutside');
title([ptitle,' Hourly Sensible Heat Flux']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 71'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['071_',ptitle,'_Hs_ID_timeseries.png']);
print('-dpng',ppath);

%% hs cov vs bulk hourly
minx = min(hr.hs_cov)-20; 
maxx = max(hr.hs_cov)+20;
figure('position',[1,1,800,475]);
plot(hr.hs,-hr.hs_cov,'ro',hr.hs,hr.hs_cov_sds,'bd'); hold on;
plot([0 0],[minx maxx],'k-',[minx maxx],[0 0],'k-',[minx maxx],[minx maxx],'k--'); grid;
axis([minx maxx minx maxx]); legend('NOAA cov','SdS cov','location','northwest');
xlabel('bulk hs, W m^{-2}'); ylabel('cov hs, W m^{-2}');
title([ptitle,' Hourly Sensible Heat Flux']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 72'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['072_',ptitle,'_Hs_cov_v_bulk.png']);
print('-dpng',ppath);

%% hs ID vs bulk hourly
minx = -20; 
maxx = 75;
figure('position',[1,1,800,475]);
plot([0 0],[minx maxx],'k-',[minx maxx],[0 0],'k-'); hold on;
plot(hr.hs,hr.hs_id,'ro'); grid; axis([minx maxx minx maxx]);
plot([minx maxx],[minx maxx],'k--');
xlabel('bulk hs, W m^{-2}'); ylabel('ID hs, W m^{-2}');
title([ptitle,' Hourly Sensible Heat Flux']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 73'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['073_',ptitle,'_Hs_ID_v_bulk.png']);
print('-dpng',ppath);

%% Stress timeseries, cov hourly
minx = -0.05; 
maxx = 0.35;
figure('position',[1,1,800,475]);
plot(hr.t,hr.tau_cov,'ro',hr.t,hr.tau,'k-',[t0 tN],[0 0],'--k');
axis([t0 tN minx maxx]); datetick('x','mm/dd','keeplimits');ylabel('N m^{-2}');
legend('cov','bulk','location','eastoutside'); grid;
title([ptitle ' Hourly Stress']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 74'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['074_',ptitle,'_tau_cov_timeseries.png']);
print('-dpng',ppath);

%% Stress timeseries, ID hourly
minx = -0.05; 
maxx = 0.35;
figure('position',[1,1,800,475]);
plot(hr.t,hr.tau_id,'ro',hr.t,hr.tau,'k-',[t0 tN],[0 0],'--k');
axis([t0 tN minx maxx]); datetick('x','mm/dd','keeplimits');ylabel('N m^{-2}');
legend('ID','bulk','location','eastoutside'); grid;
title([ptitle ' Hourly Stress']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 75'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['075_',ptitle,'_tau_ID_timeseries.png']);
print('-dpng',ppath);

%% Stress, cov vs bulk hourly
minx = -0.05; 
maxx = 0.35;
figure('position',[1,1,800,475]);
plot([0 0],[minx maxx],'k-',[minx maxx],[0 0],'k-'); hold on;
plot(hr.tau,hr.tau_cov,'ro'); grid; axis([minx maxx minx maxx]);
plot([minx maxx],[minx maxx],'k--');
xlabel('bulk, N m^{-2}'); ylabel('cov, N m^{-2}');
title([ptitle,' Hourly Stress']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 76'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['076_',ptitle,'_tau_cov_v_bulk.png']);
print('-dpng',ppath);


%% Stress, ID vs bulk hourly
minx = -0.05; 
maxx = 0.35;
figure('position',[1,1,800,475]);
plot([0 0],[minx maxx],'k-',[minx maxx],[0 0],'k-'); hold on;
plot(hr.tau,hr.tau_id,'ro'); grid; axis([minx maxx minx maxx]);
plot([minx maxx],[minx maxx],'k--');
xlabel('bulk, N m^{-2}'); ylabel('ID, N m^{-2}');
title([ptitle,' Hourly Stress']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 77'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['077_',ptitle,'_tau_ID_v_bulk.png']);
print('-dpng',ppath);

%%  hourly
figure('position',[1,1,1000,600]);
subplot(1,2,1);
clear ii; ii = hr_nh_u>2; % ii = where more than 2 points make up sample size
plot(hr_u_bin(ii),hr_hl_med_u(ii),'-k',...
    hr_u_bin(ii),hr_hl_mean_u(ii),'--k',...
    hr_u_bin(ii),hr_hl_cov_med_u(ii),'-',...
    hr_u_bin(ii),hr_hl_cov_mean_u(ii),'-',...
    hr_u_bin(ii),hr_hl_id_med_u(ii),'-',...
    hr_u_bin(ii),hr_hl_id_mean_u(ii),'-');
xlim([0 12]);
grid; xlabel('u, m s^{-1}');ylabel('hl, W m^{-2}');
legend('bulk median','bulk mean','cov median','cov mean','ID median','ID mean','location','northwest')
title([ptitle,' Hourly Wind-bin hl']);

subplot(1,2,2);
clear ii; ii = hr_ns_u>2; % ii = where more than 2 points make up sample size
plot(hr_u_bin(ii),hr_hs_med_u(ii),'-k',...
    hr_u_bin(ii),hr_hs_mean_u(ii),'--k',...
    hr_u_bin(ii),hr_hs_cov_med_u(ii),'-',...
    hr_u_bin(ii),hr_hs_cov_mean_u(ii),'-',...
    hr_u_bin(ii),hr_hs_id_med_u(ii),'-',...
    hr_u_bin(ii),hr_hs_id_mean_u(ii),'-');
xlim([0 12]);
grid; xlabel('u, m s^{-1}');ylabel('hs, W m^{-2}');
legend('bulk median','bulk mean','cov median','cov mean','ID median','ID mean','location','northeast')
title([ptitle,' Hourly Wind-bin hs']);

annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 78'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['078_',ptitle,'_med_Hl_Hs_v_u.png']);
print('-dpng',ppath);

%% hourly
figure('position',[1,1,1000,600]);
subplot(1,2,1)
plot(hr_hl_med_u,hr_hl_cov_med_u,'-',...
    hr_hl_mean_u,hr_hl_cov_mean_u,'-',...
    hr_hl_med_u,hr_hl_id_med_u,'-',...
    hr_hl_mean_u,hr_hl_id_mean_u,'-',...
    [0 250],[0 250],'--k'); grid;
xlabel('med & mean bulk hl, W m^{-2}'); ylabel('hl, W m^{-2}');
legend('cov median','cov mean','ID median','ID mean','location','northwest')
title([ptitle,' Hourly wind-binned hl turb/bulk']);

subplot(1,2,2)
plot(hr_hs_med_u,hr_hs_cov_med_u,'-',...
    hr_hs_mean_u,hr_hs_cov_mean_u,'-',...
    hr_hs_med_u,hr_hs_id_med_u,'-',...
    hr_hs_mean_u,hr_hs_id_mean_u,'-',...
    [-15 30],[-15 30],'--k'); grid;
xlabel('med & mean bulk hs, W m^{-2}'); ylabel('hs, W m^{-2}');
legend('cov median','cov mean','ID median','ID mean','location','northeast')
title([ptitle,' Hourly wind-binned hs turb/bulk']);

annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 79'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['079_',ptitle,'_med_Hl_Hs_v_bulk.png']);
print('-dpng',ppath);

%% hourly
clear ii; ii = hr_nt_u>2; % ii = where more than 2 points make up sample size
figure('position',[1,1,800,475]);
plot(hr_u_bin(ii),hr_tau_med_u(ii),'k-',hr_u_bin(ii),hr_tau_mean_u(ii),'k--',...
    hr_u_bin(ii),hr_tau_cov_med_u(ii),hr_u_bin(ii),hr_tau_cov_mean_u(ii),...
    hr_u_bin(ii),hr_tau_id_med_u(ii), hr_u_bin(ii), hr_tau_id_mean_u(ii)); 
grid; xlabel('u, m s^{-1}'); ylabel('N m^{-2}');
% maxx = max(xlim);
% maxy = max(ylim);
xlim([0 12]);
legend('bulk median','bulk mean','cov median','cov mean','ID median','ID mean','location','northwest')
title([ptitle,' Wind-Binned Stress']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 80'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['080_',ptitle,'_med_tau_v_u.png']);
print('-dpng',ppath);

%% hourly
 % ii = where more than 2 points make up sample size
figure('position',[1,1,800,475]);
plot(hr_u_bin(ii),-0.004-hr_tau_id_med_u(ii)/10,'k--',hr_u_bin(ii),hr_tau_cov_cross_mean_u(ii),...
    hr_u_bin(ii),hr_tau_cov_cross_med_u(ii)); grid; 
% maxy = max(ylim);
xlim([0 12]);
xlabel('u, m s^{-1}'); ylabel('N m^{-2}');
legend('-0.004 - tau id med/10','taux mean','taux median','location','northwest')
title([ptitle,' Wind-Binned Cross-Stream Stress']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 81'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['081_',ptitle,'_med_taux_v_u.png']);
print('-dpng',ppath);

%% hourly
 % ii = where more than 2 points make up sample size
figure('position',[1,1,800,475]);
plot(hr_u_bin(ii),-hr_wu_med_u(ii),'-kd',hr_u_bin(ii),-hr_wv_med_u(ii),'-rd'); grid;
xlabel('u, m s^{-1}'); ylabel('m^2s^{-2}'); 
xlim([0 12]); 
legend('-<Wu> median','-<WV> median','location','northwest')
title([ptitle,' Hourly Stress Components']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 82'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['082_',ptitle,'_wu_wv_v_u.png']);
print('-dpng',ppath);

%% net heat timeseries hourly
figure('position',[1,1,800,475]);
plot(hr.t,hr.sw_net,'r-',hr.t,hr.lw_net,'m-',hr.t,-hr.hs,'b-',hr.t,-hr.hl,'g-',...
    hr.t, -hr.hrain, 'c-', hr.t,hr.hnet,'k-'); grid;
xlim([t0 tN]); datetick('x','mm/dd','keeplimits'); ylabel('W m^{-2}');
title([ptitle,' hourly heat budget (+ into ocean)']);
legend('net solar','net IR','-hs','-hl','-hr','net','location','eastoutside');
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 83'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['083_',ptitle,'_heat_budget.png']);
print('-dpng',ppath);

%% hourly
% hr_bb = where convective; hr_aa = where stable
figure('position',[1,1,800,800]);
subplot(2,1,1)
loglog(hr.zeta(hr_bb),hr_phi_w_cov(hr_bb),'rd'); hold on;
loglog(hr_zeta_b,hr_phi_w_bf,'k--','linewidth',2); grid;
ylim([5e-1,50]);
ylabel('\Phi_w = \sigma_w / sqrt(-w`u`)'); xlabel('z/L');
title([ptitle,' convective (b) hourly non-dimensional \sigma_w']);
subplot(2,1,2)
loglog(hr.zeta(hr_aa),hr_phi_w_cov(hr_aa),'rd'); hold on;
loglog(hr_zeta_a,hr_phi_w_af,'k--','linewidth',2); grid;
ylim([5e-1,50]);
ylabel('\Phi_w = \sigma_w / sqrt(-w`u`)'); xlabel('z/L');
title([ptitle,' stable (a) hourly non-dimensional \sigma_w']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 84'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['084_',ptitle,'_nondim_sigma_W_v_zeta.png']);
print('-dpng',ppath);

%% hourly
% hr_bb = where convective; hr_aa = where stable
figure('position',[1,1,800,800]);
subplot(2,1,1)
loglog(hr.zeta(hr_bb),hr_phi_w_b(hr_bb),'rd'); 
hold on;
loglog(hr_zeta_b,hr_phi_w_bf,'k--','linewidth',2); grid;
ylim([5e-1,50]);
ylabel('\Phi_w = \sigma_w / u_* bulk'); xlabel('z/L');
title([ptitle,' convective (b) hourly non-dimensional \sigma_w']);
subplot(2,1,2)
loglog(hr.zeta(hr_aa),hr_phi_w_b(hr_aa),'rd'); hold on;
loglog(hr_zeta_a,hr_phi_w_af,'k--','linewidth',2); grid;
ylim([5e-1,50]);
ylabel('\Phi_w = \sigma_w / u_* bulk'); xlabel('z/L');
title([ptitle,' stable (a) hourly non-dimensional \sigma_w']);
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 85'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['085_',ptitle,'_nondim_sigma_Wb_v_zeta.png']);
print('-dpng',ppath);

%% hourly
% [xbins, ybins, ~, SD, ~] = binave2(hr.dt_skin,hr.tsnk-hr.tskin_ir,0.05,0,0.5);
% figure; plot(b10.dt_skin,b10.tsnk-b10.tskin_ir,'r.'); hold on; grid on;
% errorbar(xbins,ybins,SD,'bd-','linewidth',2); 
% plot([-0.1,0.5],[-0.1,0.5],'k--',[0,0],[-0.1,0.5],'k-',[-0.1,0.5],[0,0],'k-');
% axis([-0.1,0.5,-0.1,0.5]); 
% legend('10-min','hourly bin avg');
% xlabel('bulk dt skin, ^oC'); ylabel('T_{snake} - T_{skin} IR, ^oC');
% title([ptitle ' hourly dt skin']);
% annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 86'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
% ppath = fullfile(png_path,['086_',ptitle,'_cool_skin_delta_T.png']);
% print('-dpng',ppath);

%% hourly
figure('position',[1,1,1200,475]);
plot(hr.t,zeros(size(hr.t)),'k--'); hold on;
pl=plot(hr.t,hr.hnet,'k-',day.t+0.5,day.hnet,'ro'); grid;
yticks(-400:100:900); xticks(day.t(1):1:day.t(end)+1);
xlim([t0 tN]); datetick('x','mm/dd','keeplimits'); ylabel('h_{net}, W m^{-2}');
title([ptitle,' Daily Net Heat Flux']);
legend(pl,'hourly','daily','location','eastoutside');
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL plot 87'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
ppath = fullfile(png_path,['087_',ptitle,'_net_heat.png']);
print('-dpng',ppath);

close all;

end % end making hourly plots