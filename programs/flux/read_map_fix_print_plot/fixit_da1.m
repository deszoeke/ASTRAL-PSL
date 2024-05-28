% Comparison plots and adjustments to variables for the final bulk flux run

% Edit this script to make adjustments and corrections to the met data

% Adjustments to variables used for COARE input will be used in the model run
% but mean met values in the 10-min and 1-hr flux files will be the unadjusted
% original unless the adjustments are also copied back into the da array.

% You don't need to run this script directly.  It is called from da_red1.m
% but, you can edit the lines below to make adjustments to the data or select
% specific variables to be used in the final COARE model run.

disp('fixit_da1')


%% fixes
% sea snake


% PIR

% TSG S and T
load('/Users/eliz/DATA/PISTON_2019/Sally/flux/Field_Processed/met_sea_1min_v0/PISTON_2019_1min_met_sea_data_v0.mat');


%%



% % remove bad periods of ship data
% ii = jdy<150.2;
% dir_ship(ii) = NaN; rwdir_ship(ii) = NaN;
% U_ship(ii) = NaN; rwspd_ship(ii) = NaN;
% rwspd_ship_std(ii) = NaN; rwdir_ship_std(ii) = NaN;
% rs_ship(ii) = NaN; rl_ship(ii) = NaN;
% sog_ship(ii) = NaN; cog_ship(ii) = NaN;
% sog_ship(sog_ship>10) = NaN; cog_ship(sog_ship>10) = NaN;
% 
% ii = (jdy>158.124 & jdy<158.166) | (jdy>159.583 & jdy<159.6) |...
%     (jdy>159.833 & jdy<159.841) | (jdy>160.2 & jdy<160.326) |...
%     (jdy>160.541 & jdy<160.549) | (jdy>161.916 & jdy<161.923) |...
%     (jdy>166.624 & jdy<166.744)  | (jdy>167.541 & jdy<167.577) |...
%     (jdy>=171 & jdy<173);
% ta_ship(ii) = NaN; rh_ship(ii) = NaN;
% 
% % bad PSD data
% sog(sog>10) = NaN; cog(sog>10) = NaN;
% ii = (jdy>190.333 & jdy<192.333) | (jdy>198.333 & jdy<199.5); rl(ii) = NaN;
% ii = (jdy>=186 & jdy<=187.5); rh(ii) = NaN; ta(ii) = NaN;

%% wind speed
% remove bad ship wind data
% ii = jdy<150.2;
% U_ship(ii) = NaN;

figure('position',[1,1,800,475]);
plot(jdy,U,'r.',jdy,U_ship,'b.'); grid; xlim([stdt endt]);
legend('NOAA','ship','location','eastoutside');
ylabel('True Wspd m/s'); xlabel('DOY');
title([ptitle,' True Wind Speed (m/s)']);
if savefigs
    ppath = fullfile(png_path,['001_',cruise,'_True_Wind_Spd.png']);
    print('-dpng',ppath);
%     saveas(gcf,fullfile(fig_path,['001_',cruise,'_True_Wind_Spd.fig']));
end

[xbins, ybins1, ~, SD1, ~] = binave2(U,U_ship,2,0,18);
figure; plot([0,20],[0,20],'k-'); hold on;
p1 = errorbar(xbins,ybins1,SD1,'rd-'); grid;
xlim([0 20]); ylim([0 20]);
ylabel('Wspd, SDS m/s'); xlabel('Wspd, NOAA sonic, m/s');
title([ptitle,' True Wind Speed Comparison']);
if savefigs
    ppath = fullfile(png_path,['002_',cruise,'_True_Wind_Spd_Comparison.png']);
    print('-dpng',ppath);
%     saveas(gcf,fullfile(fig_path,['002_',cruise,'_True_Wind_Spd_Comparison.fig']));
end

figure('position',[1,1,800,475]);
subplot(2,1,1);
    plot(jdy,missing,'bd','markersize',2); grid; xlim([stdt endt]);
    ylabel('missing pnts'); xlabel('DOY');
    title([ptitle,' Missing Sonic Data Points per 10min @ 10 Hz']);
subplot(2,1,2);
    plot(jdy,badSon,'rd','markersize',2); grid; xlim([stdt endt]);
    ylabel('bad pnts'); xlabel('DOY');
    title([ptitle,' Bad Sonic Data Points per 10min @ 10 Hz']);
if savefigs
    ppath = fullfile(png_path,['003_',cruise,'_Sonic_QA.png']);
    print('-dpng',ppath);
%     saveas(gcf,fullfile(fig_path,['003_',cruise,'_Sonic_QA.fig']));
end

%% wind direction

figure('position',[1,1,800,475]);
plot(jdy,dir,'r.',jdy,dir_ship,'b.'); grid; xlim([stdt endt]);
ylim([0,360]); yticks([0,90,180,270,360]);
ylabel('True Wdir, deg'); xlabel('DOY');
legend('NOAA','ship','location','eastoutside');
title([ptitle,' True Wind Direction (relative to earth)']);
if savefigs
    ppath = fullfile(png_path,['004_',cruise,'_True_Wind_Dir.png']);
    print('-dpng',ppath);
%     saveas(gcf,fullfile(fig_path,['004_',cruise,'_True_Wind_Dir.fig']));
end

figure; histogram(dir,0:20:360); grid;
xlim([0,360]); xticks(0:60:360); xlabel('True Wind Direction');
ylabel('Frequency Histogram, 10-min averages');
title([ptitle,' Wind Direction Frequency Historgam, NOAA sonic']);
if savefigs
    ppath = fullfile(png_path,['005_',cruise,'_True_Wind_Dir_Dist.png']);
    print('-dpng',ppath);
%     saveas(gcf,fullfile(fig_path,['005_',cruise,'_True_Wind_Dir_Dist.fig']));
end

%% relative wind direction

figure('position',[1,1,800,475]);
plot([stdt,endt],[90,90],'k--',[stdt,endt],[-90,-90],'k--'); hold on;
plot([stdt,endt],[60,60],'g--',[stdt,endt],[-60,-60],'g--');
p1 = plot(jdy,reldir,'r.',jdy,rwdir_ship,'b.'); grid; xlim([stdt endt]);
ylim([-180,180]); yticks([-180,-90,0,90,180]);
ylabel('Rel Wdir, deg'); xlabel('DOY');
legend(p1,{'NOAA','ship'},'location','eastoutside');
title([ptitle,' Relative Wind Direction']);
if savefigs
    ppath = fullfile(png_path,['006_',cruise,'_Rel_Wind_Dir.png']);
    print('-dpng',ppath);
%     saveas(gcf,fullfile(fig_path,['006_',cruise,'_Rel_Wind_Dir.fig']));
end

figure; histogram(reldir,-180:20:180); grid;
xlim([-180,180]); xticks(-180:45:180); xlabel('Relative Wind Direction');
ylabel('Frequency Histogram, 10-min averages');
title([ptitle,' Relative Wind Direction Frequency Historgam, NOAA sonic']);
if savefigs
    ppath = fullfile(png_path,['007_',cruise,'_Rel_Wind_Dir_Dist.png']);
    print('-dpng',ppath);
%     saveas(gcf,fullfile(fig_path,['007_',cruise,'_Rel_Wind_Dir_Dist.fig']));
end

%% sea level pressure

P_ship(P_ship<1000) = NaN;
figure('position',[1,1,800,475]);
plot(jdy,press,'r.',jdy,P_ship,'b.',jdy,Pmb_wxt,'g.'); xlim([stdt endt]); grid;
ylabel('Sea Level pressure, mb'); xlabel('DOY');
legend('NOAA','ship','WXT','location','eastoutside');
title([ptitle,' Sea Level Pressure']);
if savefigs
    ppath = fullfile(png_path,['008_',cruise,'_Pressure.png']);
    print('-dpng',ppath);
%     saveas(gcf,fullfile(fig_path,['008_',cruise,'_Pressure.fig']));
end

[bpbinNOAA, bpbinSCS, ~, SDbpSCS, ~] = binave2(press,P_ship,2,1000,1014);
[~, bpbinWXT, ~, SDbpWXT, ~] = binave2(press,Pmb_wxt,2,1000,1014);
figure; plot([1000,1014],[1000,1014],'k-'); hold on;
p1 = errorbar(bpbinNOAA,bpbinSCS,SDbpSCS,'rd-');
p2 = errorbar(bpbinNOAA,bpbinWXT,SDbpWXT,'gd-'); grid;
% xlim([1000 1022]); ylim([1006 1022]);
legend([p1 p2],'ship','WXT','location','best');
ylabel('Sea Level BP, ship, mb'); xlabel('Sea Level BP, NOAA, mb');
title([ptitle,' Pressure Comparison']);
if savefigs
    ppath = fullfile(png_path,['009_',cruise,'_Pressure_Comparison.png']);
    print('-dpng',ppath);
%     saveas(gcf,fullfile(fig_path,['009_',cruise,'_Pressure_Comparison.fig']));
end

disp(['Mean Diff BP, NOAA-Ship = ',sprintf('%6.2f',nanmean1(press-P_ship))]);

%% tilt angle - flow distortion angle derived from the motion correction script
% this is tilt angle prior to ship speed correction

figure('position',[1,1,800,475]);
plot(reldir,tiltx,'r.',[-90 -90],[-5 25],'k--',[90 90],[-5 25],'k--');
axis([-180 180 -5 25]); grid;
ylabel('Streamline Tilt Angle, deg'); xlabel('Relative Wind Direction');
title([ptitle,' Streamline Tilt Angle, NOAA sonic']);
if savefigs
    ppath = fullfile(png_path,['010_',cruise,'_Tilt.png']);
    print('-dpng',ppath);
%     saveas(gcf,fullfile(fig_path,['010_',cruise,'_Tilt.fig']));
end

[xbins, ybins, ~, SD, ~] = binave2(reldir,tiltx,20,-180,180);
figure('position',[1,1,800,475]);
plot([-90 -90],[-5 25],'k--',[90 90],[-5 25],'k--'); hold on; grid;
errorbar(xbins,ybins,SD,'rd-');  axis([-180 180 -5 25]);
ylabel('Streamline Tilt Angle, deg'); xlabel('Relative Wind Direction');
title([ptitle,' Binned Tilt Angle']);
if savefigs
    ppath = fullfile(png_path,['011_',cruise,'_Tilt_Binned.png']);
    print('-dpng',ppath);
%     saveas(gcf,fullfile(fig_path,['011_',cruise,'_Tilt_Binned.fig']));
end

[xbins, ybins, ~, ~, ~] = binave2(reldir,wwj,20,-180,180);
figure('position',[1,1,800,475]);
plot([-90 -90],[-5 25],'k--',[90 90],[-5 25],'k--'); hold on; grid;
plot(xbins,sqrt(ybins),'rd-'); axis([-180,180,0,1.0]);
ylabel('Std Dev Vertical Wind Vel, m/s'); xlabel('Relative Wind Direction');
title([ptitle,' Sigma W vs Rel Wind Direction']);
if savefigs
    ppath = fullfile(png_path,['012_',cruise,'_SigW_Binned.png']);
    print('-dpng',ppath);
%     saveas(gcf,fullfile(fig_path,['012_',cruise,'_SigW_Binned.fig']));
end

%% sea surface temperature
% MISOBOB: tsnk and tsg are identical 'best' composite SST from several sources.

maxx = max(tsnk)+0.5; minx = min(tsnk)-0.5;
figure('position',[1,1,800,475]);
plot(jdy,tsnk,'r',jdy,ts_ship,'b'); 
legend('Sea Snake','ship','location','eastoutside');
% plot(jdy,tsnk,'r',jdy,ts_ship,'b',jdy,skinT,'g'); 
% legend('Sea Snake','ship','ROSR skin T','location','eastoutside');
grid;
xlim([stdt,endt]); ylim([minx,maxx]);
ylabel('SST, C'); xlabel('DOY');
title([ptitle,' Sea Surface Temperature']);
if savefigs
    ppath = fullfile(png_path,['013_',cruise,'_Tsea.png']);
    print('-dpng',ppath);
%     saveas(gcf,fullfile(fig_path,['013_',cruise,'_Tsea.fig']));
end

hDay = mod(jdy,1)*24; % hour of day
ii = isfinite(tsnk) & isfinite(ts_ship);
[xbins0, ybins0, ~, SD0, ~] = binave2(hDay(ii),tsnk(ii),2,0,24);
[xbins1, ybins1, ~, SD1, ~] = binave2(hDay(ii),ts_ship(ii),2,0,24);
figure('position',[1,1,800,475]); p2 = errorbar(xbins1,ybins1,SD1,'bo-'); hold on;
p1 = errorbar(xbins0,ybins0,SD0,'rd-');
xlim([0,24]); xticks(0:2:24); xlabel('Hour of Day, UTC'); grid;
legend([p1 p2],{'Sea Snake','ship'},'location','eastoutside');
ylabel('SST, C'); title([ptitle,' SST Diel Cycle']);
if savefigs
    ppath = fullfile(png_path,['014_',cruise,'_Tsea_Diel.png']);
    print('-dpng',ppath);
%     saveas(gcf,fullfile(fig_path,['014_',cruise,'_Tsea_Diel.fig']));
end

%% relative humidity

figure('position',[1,1,800,475]);
plot(jdy,rh,'r.',jdy,rh_ship,'b.',jdy,RH_wxt,'g.');
ylabel('RH, %'); xlabel('DOY'); grid; xlim([stdt endt]);
legend('PSD','ship','WXT','location','eastoutside');
title([ptitle,'  Relative Humidity']);
if savefigs
    ppath = fullfile(png_path,['015_',cruise,'_RH.png']);
    print('-dpng',ppath);
%     saveas(gcf,fullfile(fig_path,['015_',cruise,'_RH.fig']));
end

%% air temperature

figure('position',[1,1,800,475]);
plot(jdy,ta,'r.',jdy,ta_ship,'b.',jdy,Tair_wxt,'g.');
ylabel('T air, C'); xlabel('DOY'); grid; xlim([stdt endt]);
legend('PSD','ship','WXT','location','eastoutside');
title([ptitle,'  Air temperature']);
if savefigs
    ppath = fullfile(png_path,['016_',cruise,'_Tair.png']);
    print('-dpng',ppath);
%     saveas(gcf,fullfile(fig_path,['016_',cruise,'_Tair.fig']));
end

%% specific humidity

qa = qair_p(ta,rh,press);  % recompute q in case T/RH has changed
qa_ship = qair_p(ta_ship,rh_ship,P_ship);
qa_wxt    = qair_p(Tair_wxt,RH_wxt,Pmb_wxt);
figure('position',[1,1,800,475]);
plot(jdy,qa,'r.',jdy,qa_ship,'b.',jdy,qa_wxt,'g.'); grid; xlim([stdt endt]);
ylabel('Q air, g/kg'); xlabel('DOY');
legend('PSD','ship','WXT','location','eastoutside');
title([ptitle,' Air specific humidity']);
if savefigs
    ppath = fullfile(png_path,['017_',cruise,'_Qa.png']);
    print('-dpng',ppath);
%     saveas(gcf,fullfile(fig_path,['017_',cruise,'_Qa.fig']));
end

%% surface saturation specific humidity

qse = qsea_p(tsnk,press);
figure('position',[1,1,800,475]);
plot(jdy,qse,jdy,qs_tsg); grid; xlim([stdt endt]);
ylabel('Qsea, g/kg'); xlabel('DOY');
legend('Sea Snake','ship','location','eastoutside');
title([ptitle,' Specific humidity at ocean surface (g/kg)']);
if savefigs
    ppath = fullfile(png_path,['018_',cruise,'_Qsea.png']);
    print('-dpng',ppath);
%     saveas(gcf,fullfile(fig_path,['018_',cruise,'_Qsea.fig']));
end

%% solar radiative flux

figure('position',[1,1,800,475]);
plot(jdy,rs,'r.',jdy,rs_ship,'b.'); grid; xlim([stdt endt]);
ylabel('Solar Flux, W/m^2'); xlabel('DOY');
legend('PSD','ship','location','eastoutside');
title([ptitle,' Downwelling Solar Radiation']);
if savefigs
    ppath = fullfile(png_path,['019_',cruise,'_SolarRad.png']);
    print('-dpng',ppath);
%     saveas(gcf,fullfile(fig_path,['019_',cruise,'_SolarRad.fig']));
end

%% longwave radiative flux

figure('position',[1,1,800,475]);
plot(jdy,rl,'r.',jdy,rl_ship,'b.'); grid; xlim([stdt endt]);
ylabel('IR Flux, W/m^2'); xlabel('DOY');
legend('PSD PIR1','ship','location','eastoutside');
title([ptitle,' Downwelling IR Radiation']);
if savefigs
    ppath = fullfile(png_path,['020_',cruise,'_IR_Rad.png']);
    print('-dpng',ppath);
%     saveas(gcf,fullfile(fig_path,['020_',cruise,'_IR_Rad.fig']));
end

%% rain rate

figure('position',[1,1,800,475]);
plot(jdy,rain,'r',jdy,rain_wxt,'b',jdy,pr_ship,'g'); grid; xlim([stdt endt]);
ylabel('Rain, mm/hr'); xlabel('DOY');
legend('ORG','WXT','ship','location','eastoutside');
title([ptitle,' Rainrate']);
if savefigs
    ppath = fullfile(png_path,['021_',cruise,'_Rain.png']);
    print('-dpng',ppath);
%     saveas(gcf,fullfile(fig_path,['021_',cruise,'_Rain.fig']));
end

%% SOG/COG/Heading/Map plots

figure('position',[1,1,800,475]);
plot(jdy,sog,'r.',jdy,sog_ship,'b.'); grid; xlim([stdt endt]);
ylabel('SOG, m/s'); xlabel('DOY');
legend('NOAA','ship','location','eastoutside');
title([ptitle,' Ship Speed Over Ground']);
if savefigs
    ppath = fullfile(png_path,['022_',cruise,'_SOG.png']);
    print('-dpng',ppath);
%     saveas(gcf,fullfile(fig_path,['022_',cruise,'_SOG.fig']));
end

figure('position',[1,1,800,475]);
plot(jdy,cog,'r.',jdy,cog_ship,'b.'); grid; axis([stdt,endt,0,360]);
yticks([0,90,180,270,360]); ylabel('COG, deg'); xlabel('DOY');
legend('NOAA','ship','location','eastoutside');
title([ptitle,' Ship Course Over Ground']);
if savefigs
    ppath = fullfile(png_path,['023_',cruise,'_COG.png']);
    print('-dpng',ppath);
%     saveas(gcf,fullfile(fig_path,['023_',cruise,'_COG.fig']));
end

figure('position',[1,1,800,475]);
plot(jdy,head); grid; axis([stdt,endt,0,360]);
ylabel('Heading'); xlabel('DOY');
title([ptitle,' Heading']);
if savefigs
    ppath = fullfile(png_path,['024_',cruise,'_Heading.png']);
    print('-dpng',ppath);
%     saveas(gcf,fullfile(fig_path,['024_',cruise,'_Heading.fig']));
end

figure('position',[1,1,800,475]);
plot(jdy,sig_h); grid; xlim([stdt,endt]);
ylabel('Std Dev Heading'); xlabel('DOY');
title([ptitle,' Standard Deviation Heading']);
if savefigs
    ppath = fullfile(png_path,['025_',cruise,'_StdDev_Heading.png']);
    print('-dpng',ppath);
%     saveas(gcf,fullfile(fig_path,['025_',cruise,'_StdDev_Heading.fig']));
end

%%% for ATOMIC, it's -50 or 50 W, so subtract 360 deg from Lon to make plot
map_all_cruise(Lon,Lat,ptitle,LatLonLim)
if savefigs
    ppath = fullfile(png_path,['026_',cruise,'_TrackMap.png']);
    print('-dpng',ppath);
%     saveas(gcf,fullfile(fig_path,['026_',cruise,'_TrackMap.fig']));
end

%% Licor fast humidity
% lots of clean up required here...

AGC = cr(:,17);
h2o_mr = (cr(:,2)/1000).*Rgas_universal.*(ta+273.15)./(press*100);
rhoa_lic = (press*100).*(1-h2o_mr*(1-epsilon))./(Rgas.*(ta+273.15));
sgq_lic = (cr(:,12)*1e-3).*Mw./rhoa_lic;
q_lic = (cr(:,2)*1e-3).*Mw./rhoa_lic;

% kill all data where AGC is bad
ii = AGC>AGC_lim;
cr(ii,2:5) = NaN;
cr(ii,8:15) = NaN;
cql(ii) = NaN; da(ii,140:141) = NaN;

% kill all where q is out of reasonable range
ii = q_lic<q_lic_LoLim | q_lic>q_lic_HiLim;
q_lic(ii) = NaN;
cr(ii,2:5) = NaN;
cr(ii,8:15) = NaN;
cql(ii) = NaN; da(ii,140:141) = NaN;

% kill all when sigma q is out of range
ii = sgq_lic>sigq_HiLim | sgq_lic<sigq_LoLim;
sgq_lic(ii) = NaN;
q_lic(ii) = NaN;
cr(ii,2:5) = NaN;
cr(ii,8:15) = NaN;
cql(ii) = NaN; da(ii,140:141) = NaN;

% remove remaining outlier wq covariances
wq_lic = cr(:,8)*1.045; % wq Licor with correction for sensor sep: 1.045
ii = wq_lic<wq_LoLim | wq_lic>wq_HiLim;
wq_lic(ii) = NaN;
cr(ii,8) = NaN;

% recompute licor moisture, air density, q from filtered data
h2o_mr = (cr(:,2)/1000).*Rgas_universal.*(ta+tdk)./(press*100);
rhoa_lic = (press*100).*(1-h2o_mr*(1-epsilon))./(Rgas.*(ta+tdk));
q_lic = (cr(:,2)*1e-3).*Mw./rhoa_lic;

% apply same filtering to wq_sds
ii = isnan(wq_lic); wq_sds(ii) = NaN;

 % q licor plot
figure('position',[1,1,800,475]);
subplot(2,1,1); % q licor plot
plot(jdy,qa,jdy,q_lic); grid; xlim([stdt endt]);
ylabel('Qair, g/kg');
title([ptitle,' Licor Specific Humidity and AGC (red dashed = limit)']);
legend('T/RH','Licor','location','eastoutside');
subplot(2,1,2); % Licor AGC
plot(jdy,AGC,[stdt,endt],[AGC_lim,AGC_lim],'r--',[stdt,endt],[50,50],'k-');
grid; ylabel('AGC (arbitrary units)'); xlabel('DOY,2018');
ylim([48,100]); xlim([stdt endt]);
legend('AGC','Limit','location','eastoutside');
if savefigs
    ppath = fullfile(png_path,['027_',cruise,'_Licor_Qa_AGC.png']);
    print('-dpng',ppath);
%     saveas(gcf,fullfile(fig_path,['027_',cruise,'_Licor_Qa_AGC.fig']));
end

close all

%% filter other covariances and ID variables for outlier values

% first, remove all instances with bad wind direction or excessive missing data
kk = (reldir>rdir_hi & reldir<rdir_lo) | badSon>badSon_lim | missing>missing_lim | jdy<150.2;
wuj(kk) = NaN; wvj(kk) = NaN; wt_son(kk) = NaN; wq_lic(kk) = NaN;
wq_sds(kk) = NaN; wt_sds(kk) = NaN; uuj(kk) = NaN; vvj(kk) = NaN;
wwj(kk) = NaN; tt(kk) = NaN; usi(kk) = NaN; tsi(kk) = NaN; qsi(kk) = NaN;
cu(kk) = NaN; cw(kk)=NaN; ct(kk)=NaN; cql(kk)=NaN;
da(kk,117:121) = NaN; da(kk,125:128) = NaN; da(kk,134:147) = NaN;
cr(kk,2:5) = NaN; cr(kk,8:15) = NaN;

% general covariance limits
ii = wuj<wu_LoLim | wuj>wu_HiLim;        wuj(ii) = NaN;
ii = wvj<wv_LoLim | wvj>wv_HiLim;        wvj(ii) = NaN;
ii = wt_son<wT_LoLim | wt_son>wT_HiLim;  wt_son(ii) = NaN;
ii = wt_sds<wT_LoLim | wt_sds>wT_HiLim;  wt_sds(ii) = NaN;

% cu2,cw2,ct2 and cql2 limits
ii = find(cu<cu_LoLim |cu >cu_HiLim);
cu(ii) = NaN; da(ii,134:135) = NaN; % NaN both cu idiss methods in da array
kk = find(cw<cw_LoLim |cw >cw_HiLim);
cw(kk) = NaN; da(ii,136:137) = NaN;
ii = find(ct<ct_LoLim | ct>ct_HiLim);
ct(ii) = NaN; da(ii,138:139) = NaN;
ii = find(cql<cql_LoLim | cql_HiLim>2);
cql(ii) = NaN; da(ii,140:141) = NaN;

% filter for Ts noise limit and variance
ii = (Ts_noise > Tnoise_lim) | (tt>Tson_var_lim);
ct(ii) = NaN; wt_son(ii) = NaN; wt_sds(ii) = NaN;
da(ii,138:139) = NaN;

% average cu and cw for smoother structure function
cs = (cu+.75*cw)/2;
ii = find(isnan(cu));
cs(ii) = .75*cw(ii);
ii = find(isnan(cw));
cs(ii) = cu(ii);

%% save cleaned-up bulk variables back to da array for later averaging
da(:,2) = U_ship;
da(:,3) = ta_ship;
da(:,4) = rh_ship;
da(:,5) = P_ship;
da(:,6) = ts_ship;
% da(:,176) = skinT;
da(:,7) = rs_ship;
da(:,8) = rl_ship;
da(:,16) = U;
da(:,17) = ta;
da(:,18) = rh;
da(:,19) = press;
da(:,20) = tsnk;
da(:,21) = rs;
da(:,22) = rl;
da(:,24) = rain;
da(:,41) = dir;
da(:,34) = dir_ship;
da(:,44) = tiltx;
da(:,49) = qa;
da(:,50) = qa_ship;
da(:,51) = qse;
da(:,117) = wuj;
da(:,119) = wvj;
da(:,121) = wt_son;
da(:,181) = wt_sds;
da(:,182) = wq_sds;
cr(:,8) = wq_lic;
