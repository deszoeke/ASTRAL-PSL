% Comparison plots and adjustments to variables for the final bulk flux run

% Edit this script to make adjustments and corrections to the met data

% Adjustments to variables used for COARE input will be used in the model run
% but mean met values in the 10-min and 1-hr flux files will be the unadjusted
% original unless the adjustments are also copied back into the da array.

% You don't need to run this script directly.  It is called from da_red1.m
% but, you can edit the lines below to make adjustments to the data or select
% specific variables to be used in the final COARE model run.

disp('PLOTS: prior to fixes in da')


%% EXAMPLE: remove bad periods of ship data
% ii = (jdy>158.124 & jdy<158.166) | (jdy>159.583 & jdy<159.6) |...
%     (jdy>159.833 & jdy<159.841) | (jdy>160.2 & jdy<160.326) |...
%     (jdy>160.541 & jdy<160.549) | (jdy>161.916 & jdy<161.923) |...
%     (jdy>166.624 & jdy<166.744)  | (jdy>167.541 & jdy<167.577) |...
%     (jdy>=171 & jdy<173);
% ta_ship(ii) = NaN; rh_ship(ii) = NaN;


%% wind speed: PSL vs. ship
figure;
plot(jdy,U,'r.',jdy,U_ship,'b.'); grid; xlim([stdt endt]);
legend('NOAA','ship','location','eastoutside');
ylabel('m/s'); xlabel('DOY');
title([ptitle,' true wind speed']);
if savefigs
    ppath = fullfile(png_path,['001_',cruise,'_True_Wind_Spd.png']);
    print('-dpng',ppath);
%     saveas(gcf,fullfile(fig_path,['001_',cruise,'_True_Wind_Spd.fig']));
end

%% wind speed: bin averaged PSL vs. ship
[xbins, ybins1, ~, SD1, ~] = binave2(U,U_ship,2,0,18);
figure; plot([0,20],[0,20],'k-'); hold on;
p1 = errorbar(xbins,ybins1,SD1,'rd-'); grid;
xlim([0 20]); ylim([0 20]);
ylabel('ship, m s^{-1}'); xlabel('NOAA sonic, m s^{-1}');
title([ptitle,' true wind speed']);
if savefigs
    ppath = fullfile(png_path,['002_',cruise,'_True_Wind_Spd_Comparison.png']);
    print('-dpng',ppath);
end

%% bad sonic data
figure;
subplot(2,1,1);
    plot(jdy,missing,'bd','markersize',2); grid; xlim([stdt endt]);
    ylabel('missing pnts'); xlabel('DOY');
    title([ptitle,' ,issing sonic data points per 10min @ 10 Hz']);
subplot(2,1,2);
    plot(jdy,badSon,'rd','markersize',2); grid; xlim([stdt endt]);
    ylabel('bad pnts'); xlabel('DOY');
    title([ptitle,' bad sonic data points per 10min @ 10 Hz']);
if savefigs
    ppath = fullfile(png_path,['003_',cruise,'_Sonic_QA.png']);
    print('-dpng',ppath);
end

%% true wind direction: PSL vs. ship
figure;
plot(jdy,dir,'r.',jdy,dir_ship,'b.'); grid; xlim([stdt endt]);
ylim([0,360]); yticks([0,90,180,270,360]);
ylabel('^{o}'); xlabel('DOY');
legend('NOAA','ship','location','eastoutside');
title([ptitle,' true wind direction, earth coordinates']);
if savefigs
    ppath = fullfile(png_path,['004_',cruise,'_True_Wind_Dir.png']);
    print('-dpng',ppath);
end

%% true wind direction: histogram
figure; histogram(dir,0:20:360); grid;
xlim([0,360]); xticks(0:60:360); xlabel('true wind direction, ^{o}');
ylabel('count, 10-min averages');
title([ptitle,' wind direction historgam, NOAA sonic']);
if savefigs
    ppath = fullfile(png_path,['005_',cruise,'_True_Wind_Dir_Dist.png']);
    print('-dpng',ppath);
end

%% relative wind direction
figure;
plot([stdt,endt],[90,90],'k--',[stdt,endt],[-90,-90],'k--'); hold on;
plot([stdt,endt],[60,60],'g--',[stdt,endt],[-60,-60],'g--');
p1 = plot(jdy,reldir,'r.',jdy,rwdir_ship,'b.'); grid; xlim([stdt endt]);
ylim([-180,180]); yticks([-180,-90,0,90,180]);
ylabel('^{o}'); xlabel('DOY');
legend(p1,{'NOAA','ship'},'location','eastoutside');
title([ptitle,' relative wind direction']);
if savefigs
    ppath = fullfile(png_path,['006_',cruise,'_Rel_Wind_Dir.png']);
    print('-dpng',ppath);
end

%% relative wind direction histogram
figure; histogram(reldir,-180:20:180); grid;
xlim([-180,180]); xticks(-180:45:180); xlabel('relative wind direction, ^{o}');
ylabel('histogram, 10-min averages');
title([ptitle,' relative wind direction historgam, NOAA sonic']);
if savefigs
    ppath = fullfile(png_path,['007_',cruise,'_Rel_Wind_Dir_Dist.png']);
    print('-dpng',ppath);
end

%% sea level pressure
figure;
plot(jdy,press,'r.',jdy,P_ship,'b.'); xlim([stdt endt]); grid;
ylabel('mb'); xlabel('DOY');
legend('NOAA','ship','location','eastoutside');
title([ptitle,' sea level pressure']);
if savefigs
    ppath = fullfile(png_path,['008_',cruise,'_SLP.png']);
    print('-dpng',ppath);
end

%% sea level pressure binned
[bpbinNOAA, bpbinship, ~, SDbpship, ~] = binave2(press,P_ship,2,1000,1014);
% [~, bpbinWXT, ~, SDbpWXT, ~] = binave2(press,Pmb_wxt,2,1000,1014);
figure; plot([1000,1014],[1000,1014],'k-'); hold on;
p1 = errorbar(bpbinNOAA,bpbinship,SDbpship,'rd-');
% p2 = errorbar(bpbinNOAA,bpbinWXT,SDbpWXT,'gd-'); grid;
% xlim([1000 1022]); ylim([1006 1022]);
% legend([p1 p2],'ship','location','best');
ylabel('ship SLP, mb'); xlabel('NOAA SLP, mb');
title([ptitle,' SLP Comparison']);
if savefigs
    ppath = fullfile(png_path,['009_',cruise,'_SLP_Comparison.png']);
    print('-dpng',ppath);
end

disp(['Mean difference in SLP, NOAA - ship = ',sprintf('%6.2f',nanmean1(press-P_ship))]);

%% tilt angle - flow distortion angle derived from the motion correction script
% this is tilt angle prior to ship speed correction
figure;
plot(reldir,tiltx,'r.',[-90 -90],[-5 25],'k--',[90 90],[-5 25],'k--');
axis([-180 180 -5 25]); grid;
ylabel('streamline tilt Angle, ^{o}'); xlabel('felative wind direction, ^{o}');
title([ptitle,' streamline tilt angle before motion correction, NOAA sonic']);
if savefigs
    ppath = fullfile(png_path,['010_',cruise,'_Tilt.png']);
    print('-dpng',ppath);
end

%% tilt angled binned
[xbins, ybins, ~, SD, ~] = binave2(reldir,tiltx,20,-180,180);
figure;
plot([-90 -90],[-5 25],'k--',[90 90],[-5 25],'k--'); hold on; grid;
errorbar(xbins,ybins,SD,'rd-');  axis([-180 180 -5 25]);
ylabel('streamline tilt angle, ^{o}'); xlabel('felative wind direction, ^{o}');
title([ptitle,' streamline tilt angle before motion correction, NOAA sonic']);
if savefigs
    ppath = fullfile(png_path,['011_',cruise,'_Tilt_Binned.png']);
    print('-dpng',ppath);
end

%% std dev vertical velocoty
[xbins, ybins, ~, ~, ~] = binave2(reldir,wwj,20,-180,180);
figure;
plot([-90 -90],[-5 25],'k--',[90 90],[-5 25],'k--'); hold on; grid;
plot(xbins,sqrt(ybins),'rd-'); axis([-180,180,0,1.0]);
ylabel('\sigma w, m s^{-1}'); xlabel('relative wind direction, ^o');
title([ptitle,' \sigma w vs rel. wind direction']);
if savefigs
    ppath = fullfile(png_path,['012_',cruise,'_SigW_Binned.png']);
    print('-dpng',ppath);
end

%% water temperature
maxx = max(tsnk)+0.5; minx = min(tsnk)-0.5;
figure;
plot(jdy,tsnk,'r',jdy,ts_ship,'b'); 
legend('sea snake','ship','location','eastoutside');
% plot(jdy,tsnk,'r',jdy,ts_ship,'b',jdy,skinT,'g'); 
% legend('sea snake','ship','ROSR skin T','location','eastoutside');
grid;
xlim([stdt,endt]); ylim([minx,maxx]);
ylabel('water T, ^oC'); xlabel('DOY');
title([ptitle,' Water Temperature']);
if savefigs
    ppath = fullfile(png_path,['013_',cruise,'_Tsea.png']);
    print('-dpng',ppath);
end

%% diurnal cycle SST
hDay = mod(jdy,1)*24; % hour of day
ii = isfinite(tsnk) & isfinite(ts_ship);
[xbins0, ybins0, ~, SD0, ~] = binave2(hDay(ii),tsnk(ii),2,0,24);
[xbins1, ybins1, ~, SD1, ~] = binave2(hDay(ii),ts_ship(ii),2,0,24);
figure; p2 = errorbar(xbins1,ybins1,SD1,'bo-'); hold on;
p1 = errorbar(xbins0,ybins0,SD0,'rd-');
xlim([0,24]); xticks(0:2:24); xlabel('Hour of Day, UTC'); grid;
legend([p1 p2],{'sea snake','ship'},'location','eastoutside');
ylabel('Water T, ^oC'); title([ptitle,' Water T Diurnal Cycle']);
if savefigs
    ppath = fullfile(png_path,['014_',cruise,'_Tsea_Dirurnal.png']);
    print('-dpng',ppath);
end

%% relative humidity
figure;
plot(jdy,rh,'r.',jdy,rh_ship,'b.');
ylabel('rh, %'); xlabel('DOY'); grid; xlim([stdt endt]);
legend('NOAA','ship','location','eastoutside');
title([ptitle,'  relative humidity']);
if savefigs
    ppath = fullfile(png_path,['015_',cruise,'_RH.png']);
    print('-dpng',ppath);
end

%% air temperature
figure;
plot(jdy,ta,'r.',jdy,ta_ship,'b.');
ylabel('T air, ^oC'); xlabel('DOY'); grid; xlim([stdt endt]);
legend('NOAA','ship','location','eastoutside');
title([ptitle,'  air temperature']);
if savefigs
    ppath = fullfile(png_path,['016_',cruise,'_Tair.png']);
    print('-dpng',ppath);
end

%% specific humidity
qa = qair_p(ta,rh,press);  % recompute q in case T/RH has changed
qa_ship = qair_p(ta_ship,rh_ship,P_ship);
figure;
plot(jdy,qa,'r.',jdy,qa_ship,'b.'); grid; xlim([stdt endt]);
ylabel('q air, g kg^{-1}'); xlabel('DOY');
legend('NOAA','ship','location','eastoutside');
title([ptitle,' air specific humidity']);
if savefigs
    ppath = fullfile(png_path,['017_',cruise,'_Qa.png']);
    print('-dpng',ppath);
end

%% surface saturation specific humidity
figure;
plot(jdy,qs,jdy,qs_tsg); grid; xlim([stdt endt]);
ylabel('q_s, g kg^{-1}'); xlabel('DOY');
legend('sea snake','ship TSG','location','eastoutside');
title([ptitle,' surface specific humidity']);
if savefigs
    ppath = fullfile(png_path,['018_',cruise,'_Qsea.png']);
    print('-dpng',ppath);
end

%% solar radiation
figure;
plot(jdy,rs,'r.',jdy,rs_ship,'b.'); grid; xlim([stdt endt]);
ylabel('W m^{-2}'); xlabel('DOY');
legend('NOAA','ship','location','eastoutside');
title([ptitle,' downwelling solar radiation']);
if savefigs
    ppath = fullfile(png_path,['019_',cruise,'_SolarRad.png']);
    print('-dpng',ppath);
end

%% longwave radiation
figure;
plot(jdy,rl,'r.',jdy,rl_ship,'b.'); grid; xlim([stdt endt]);
ylabel('W m^{-2}'); xlabel('DOY');
legend('NOAA','ship','location','eastoutside');
title([ptitle,' downwelling IR radiation']);
if savefigs
    ppath = fullfile(png_path,['020_',cruise,'_IR_Rad.png']);
    print('-dpng',ppath);
end

%% rain rate
figure;
plot(jdy,rain,'r',jdy,pr_ship,'b'); grid; xlim([stdt endt]);
ylabel('mm/hr'); xlabel('DOY');
legend('NOAA','ship','location','eastoutside');
title([ptitle,' rain rate']);
if savefigs
    ppath = fullfile(png_path,['021_',cruise,'_Rain.png']);
    print('-dpng',ppath);
end

%% SOG
figure;
plot(jdy,sog,'r.',jdy,sog_ship,'b.'); grid; xlim([stdt endt]);
ylabel('m s^{-1}'); xlabel('DOY');
legend('NOAA','ship','location','eastoutside');
title([ptitle,' speed over ground']);
if savefigs
    ppath = fullfile(png_path,['022_',cruise,'_SOG.png']);
    print('-dpng',ppath);
end

%% COG
figure;
plot(jdy,cog,'r.',jdy,cog_ship,'b.'); grid; axis([stdt,endt,0,360]);
yticks([0,90,180,270,360]); ylabel('^o'); xlabel('DOY');
legend('NOAA','ship','location','eastoutside');
title([ptitle,' ship course over ground']);
if savefigs
    ppath = fullfile(png_path,['023_',cruise,'_COG.png']);
    print('-dpng',ppath);
end

%% heading
figure;
plot(jdy,head, 'or', jdy, head_ship,'xb'); grid; axis([stdt,endt,0,360]);
ylabel('^o'); xlabel('DOY');
legend('NOAA','ship','location','eastoutside');
title([ptitle,' ship heading']);
if savefigs
    ppath = fullfile(png_path,['024_',cruise,'_Heading.png']);
    print('-dpng',ppath);
end

%% std dev heading
figure;
plot(jdy,sig_h, 'r'); grid; xlim([stdt,endt]);
ylabel('^o'); xlabel('DOY');
legend('NOAA','location','best');
title([ptitle,' standard deviation heading']);
if savefigs
    ppath = fullfile(png_path,['025_',cruise,'_StdDev_Heading.png']);
    print('-dpng',ppath);
end

%% map
map_all_cruise(Lon,Lat,ptitle,LatLonLim)
if savefigs
    ppath = fullfile(png_path,['026_',cruise,'_TrackMap.png']);
    print('-dpng',ppath);
end


%% q licor plot
figure;
subplot(2,1,1); 
    plot(jdy,qa,jdy,q_lic); grid; xlim([stdt endt]);
    ylabel('q, g/kg');
    title([ptitle,' specific humidity']);
    legend('Vaisala','Licor','location','eastoutside');
subplot(2,1,2);
    plot(jdy,AGC,[stdt,endt],[AGC_lim,AGC_lim],'r--',[stdt,endt],[50,50],'k-');
    grid; ylabel('AGC'); xlabel('DOY');
    ylim([48,100]); xlim([stdt endt]);
    legend('AGC','Limit','location','eastoutside');
if savefigs
    ppath = fullfile(png_path,['027_',cruise,'_Licor_Qa_AGC.png']);
    print('-dpng',ppath);
end

%% finished!
close all


