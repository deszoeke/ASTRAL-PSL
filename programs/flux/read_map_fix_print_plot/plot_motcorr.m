function plot_motcorr(c10, b10, path_dailyPlots, cruise, cruise_str)
%%% function to read in 1 day of run_motcorr data and make plots
%%% 
%%% EJT Jan 2020
%%%
%%% input: 
%%%     b10      = all-cruise means
%%%     c10      = one day of run_motcorr output

%%% Notes: 
%%%     WXT is ignored for now

%% get date, time, cruise info
the_jd = floor(c10.jd(2));
[the_yr, the_mo, the_day, the_hr, the_min, the_sec] = datevec(c10.t(2));

%% plot info
graphformat = '.png';  % select graphics format
graphdevice = '-dpng'; % select graphic device

%% Daily plots

label_st = [cruise '_' sprintf('%02i_%02i_%03i', the_mo, the_day, the_jd) graphformat];
    ppath_TW = fullfile(path_dailyPlots,'True_Wind',['True_Wind_' label_st]);
    ppath_RW = fullfile(path_dailyPlots,'Rel_Wind',['Rel_Wind_' label_st]);
    ppath_MOT = fullfile(path_dailyPlots,'Motion_Tilt',['Motion_Tilt_' label_st]);
    ppath_HEAT = fullfile(path_dailyPlots,'Heat_Fluxes',['Heat_Fluxes_' label_st]);
    ppath_TAU = fullfile(path_dailyPlots,'Stress',['Stress_' label_st]);
    ppath_STAR = fullfile(path_dailyPlots,'Stars',['Stars_' label_st]);
    ppath_VAR = fullfile(path_dailyPlots,'Vars',['Vars_' label_st]);
the_ppaths = {ppath_TW; ppath_RW; ppath_MOT; ppath_HEAT; ppath_TAU; ppath_STAR; ppath_VAR};


    %%% load this day's segment of mean corrected 10-min data. call it
    %%% "b" so that things don't get overwritten or confused yet
    these = find(b10.t >= c10.t(1) & b10.t <= c10.t(end));
    fields_f10 = fields(b10);
    nf = length(fields_f10);
    for k = 1:nf
       this = b10.(fields_f10{k});
       eval(['b.' fields_f10{k} ' = this(these);']); 
    end

%%% if no data exist, print blank plots
if isnan(b.wspd(1)) == 1 && isnan(b.wspd(52)) == 1 && isnan(b.wspd(end)) == 1

    disp('no data today, so just printing blank plots');

    % print a blank plot
    figure; plot(b.jd,nan(1,length(b.jd))); grid on;
    title(sprintf('%s (%04i-%02i-%02i, DOY%03i).  No Data - Ship in Port',...
        cruise_str,the_yr,the_mo,the_day,the_jd),'FontWeight','Bold','Interpreter','none');
    xlabel('Hour UTC');
    axis([the_jd the_jd+1 0 1]); 
    set(gca(gcf),'XTick',the_jd:2/24:the_jd+1); datetick('x','HH:MM','keepticks');
    xax = get(gca(gcf),'XTickLabel'); xax(end,:)='24:00'; set(gca(gcf),'XTickLabel',xax(:,1:2));
    annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA/ESRL/PSL'},'FontSize',10,'FitBoxToText','off','LineStyle','none');

    for i = 1:length(the_ppaths)
        print(graphdevice,the_ppaths{i});
    end

else


% True Wspd/Wdir
figure;
subplot(2,1,1); plot(b.jd,b.wspd_s,'b-',b.jd,b.wspd,'r-',c10.jd,c10.wspd_new,'k-');
    title(sprintf('%s (%04i-%02i-%02i, DOY%03i).  True Wind Speed',cruise_str,the_yr,the_mo,...
        the_day,the_jd),'FontWeight','Bold','Interpreter','none');
    xlabel('Hour UTC');ylabel('True Wind Speed, m s^{-1}'); grid;
    set(gca(gcf),'XTick',the_jd:2/24:the_jd+1);datetick('x','HH:MM','keepticks');
    xax=get(gca(gcf),'XTickLabel');xax(end,:)='24:00';set(gca(gcf),'XTickLabel',xax(:,1:2));
    legend('ship','PSL','PSL new','Location','Best');
subplot(2,1,2); plot(b.jd,b.wdir_s,'bo',b.jd,b.wdir,'r.',c10.jd,c10.wdir_new,'kx');
    xlabel('Hour UTC');ylabel('True Wind Dir, ^o'); grid; ylim([0 360]);
    set(gca(gcf),'XTick',the_jd:2/24:the_jd+1);datetick('x','HH:MM','keepticks');
    xax=get(gca(gcf),'XTickLabel');xax(end,:)='24:00';set(gca(gcf),'XTickLabel',xax(:,1:2))
    annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',...
        {'NOAA PSL'},'FontSize',15,'FitBoxToText','off','LineStyle','none');
orient tall
    print(graphdevice,ppath_TW);

% Relative Wspd/Wdir
figure;
Uplim = ones(length(c10.t),1)*60;
LoLim = ones(length(c10.t),1)*-60;
subplot(2,1,1); plot(b.jd,b.rspd_s,'b-',b.jd,b.rspd,'r-',c10.jd,c10.rspd_new,'k-',c10.jd,c10.rspd_new2,'g-');
    title(sprintf('%s (%04i-%02i-%02i, DOY%03i).  Relative Wind',cruise_str,the_yr,...
        the_mo,the_day,the_jd),'FontWeight','Bold','Interpreter','none');
    xlabel('Hour UTC');ylabel('Relative Wind Speed, m s^{-1}'); grid;
    set(gca(gcf),'XTick',the_jd:2/24:the_jd+1);datetick('x','HH:MM','keepticks');
    xax=get(gca(gcf),'XTickLabel');xax(end,:)='24:00';set(gca(gcf),'XTickLabel',xax(:,1:2));
    legend('ship','PSL','PSL new','PSL new2','Location','Best');
subplot(2,1,2); plot(b.jd,b.rdir_s,'bo',b.jd,b.rdir,'r.',c10.jd,c10.rdir_new,'kx'); hold on;
    plot(c10.jd,Uplim,'k--',c10.jd,LoLim,'k--');
    xlabel('Hour UTC');ylabel('Relative Wind Dir, ^o'); grid; ylim([-180 180]);
    set(gca(gcf),'XTick',the_jd:2/24:the_jd+1);datetick('x','HH:MM','keepticks');
    xax=get(gca(gcf),'XTickLabel');xax(end,:)='24:00';set(gca(gcf),'XTickLabel',xax(:,1:2))
    annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',...
        {'NOAA PSL'},'FontSize',15,'FitBoxToText','off','LineStyle','none');
orient tall
    print(graphdevice,ppath_RW);

% variances
figure;
subplot(3,2,1); plot(c10.jd,c10.tvar,'r-');
    title(sprintf('%s (%04i-%02i-%02i, DOY%03i).  tvar',cruise_str,the_yr,...
        the_mo,the_day,the_jd),'FontWeight','Bold','Interpreter','none');
    xlabel('Hour UTC');ylabel('K'); grid;
    set(gca(gcf),'XTick',the_jd:2/24:the_jd+1);datetick('x','HH:MM','keepticks');
    xax=get(gca(gcf),'XTickLabel');xax(end,:)='24:00';set(gca(gcf),'XTickLabel',xax(:,1:2));
subplot(3,2,2); plot(c10.jd,c10.qvar,'r-');
    title(sprintf('%s (%04i-%02i-%02i, DOY%03i).  qvar',cruise_str,the_yr,...
        the_mo,the_day,the_jd),'FontWeight','Bold','Interpreter','none');
    xlabel('Hour UTC');ylabel('g g^{-1}'); grid;
    set(gca(gcf),'XTick',the_jd:2/24:the_jd+1);datetick('x','HH:MM','keepticks');
    xax=get(gca(gcf),'XTickLabel');xax(end,:)='24:00';set(gca(gcf),'XTickLabel',xax(:,1:2));
subplot(3,2,3); plot(c10.jd,c10.uvar,'r-');
    title(sprintf('%s (%04i-%02i-%02i, DOY%03i).  uvar',cruise_str,the_yr,...
        the_mo,the_day,the_jd),'FontWeight','Bold','Interpreter','none');
    xlabel('Hour UTC');ylabel('m s^{-1}'); grid;
    set(gca(gcf),'XTick',the_jd:2/24:the_jd+1);datetick('x','HH:MM','keepticks');
    xax=get(gca(gcf),'XTickLabel');xax(end,:)='24:00';set(gca(gcf),'XTickLabel',xax(:,1:2));
subplot(3,2,4); plot(c10.jd,c10.vvar,'r-');
    title(sprintf('%s (%04i-%02i-%02i, DOY%03i).  vvar',cruise_str,the_yr,...
        the_mo,the_day,the_jd),'FontWeight','Bold','Interpreter','none');
    xlabel('Hour UTC');ylabel('m s^{-1}'); grid;
    set(gca(gcf),'XTick',the_jd:2/24:the_jd+1);datetick('x','HH:MM','keepticks');
    xax=get(gca(gcf),'XTickLabel');xax(end,:)='24:00';set(gca(gcf),'XTickLabel',xax(:,1:2));
subplot(3,2,5); plot(c10.jd,c10.wvar,'r-');
    title(sprintf('%s (%04i-%02i-%02i, DOY%03i).  wvar',cruise_str,the_yr,...
        the_mo,the_day,the_jd),'FontWeight','Bold','Interpreter','none');
    xlabel('Hour UTC');ylabel('m s^{-1}'); grid;
    set(gca(gcf),'XTick',the_jd:2/24:the_jd+1);datetick('x','HH:MM','keepticks');
    xax=get(gca(gcf),'XTickLabel');xax(end,:)='24:00';set(gca(gcf),'XTickLabel',xax(:,1:2));
        
    
    annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',...
        {'NOAA PSL'},'FontSize',15,'FitBoxToText','off','LineStyle','none');
    print(graphdevice,ppath_VAR);

% stars / scaling parameters
figure;
subplot(3,1,1); plot(b.jd,b.tsr,'r-',c10.jd,c10.tsr_ida,'om',c10.jd,c10.tsr_idb,'oc');
    title(sprintf('%s (%04i-%02i-%02i, DOY%03i).  t*',cruise_str,the_yr,...
        the_mo,the_day,the_jd),'FontWeight','Bold','Interpreter','none');
    xlabel('Hour UTC');ylabel('K'); grid;
    set(gca(gcf),'XTick',the_jd:2/24:the_jd+1);datetick('x','HH:MM','keepticks');
    xax=get(gca(gcf),'XTickLabel');xax(end,:)='24:00';set(gca(gcf),'XTickLabel',xax(:,1:2));
    legend('bulk','ID a','ID b','Location','eastoutside');
subplot(3,1,2); plot(b.jd,b.qsr,'r-',c10.jd,c10.qsr_ida,'om',c10.jd,c10.qsr_idb,'oc');
    title(sprintf('%s (%04i-%02i-%02i, DOY%03i).  q*',cruise_str,the_yr,...
        the_mo,the_day,the_jd),'FontWeight','Bold','Interpreter','none');
    xlabel('Hour UTC');ylabel('g g^{-1}'); grid;
    set(gca(gcf),'XTick',the_jd:2/24:the_jd+1);datetick('x','HH:MM','keepticks');
    xax=get(gca(gcf),'XTickLabel');xax(end,:)='24:00';set(gca(gcf),'XTickLabel',xax(:,1:2));
    legend('bulk','ID a','ID b','Location','eastoutside');
subplot(3,1,3); plot(b.jd,b.usr,'r-',c10.jd,c10.usr_ida,'om',c10.jd,c10.usr_idb,'oc');
    title(sprintf('%s (%04i-%02i-%02i, DOY%03i).  u*',cruise_str,the_yr,...
        the_mo,the_day,the_jd),'FontWeight','Bold','Interpreter','none');
    xlabel('Hour UTC');ylabel('m s^{-1}'); grid;
    set(gca(gcf),'XTick',the_jd:2/24:the_jd+1);datetick('x','HH:MM','keepticks');
    xax=get(gca(gcf),'XTickLabel');xax(end,:)='24:00';set(gca(gcf),'XTickLabel',xax(:,1:2));
    legend('bulk','ID a','ID b','Location','eastoutside');    
    annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',...
        {'NOAA PSL'},'FontSize',15,'FitBoxToText','off','LineStyle','none');
    print(graphdevice,ppath_STAR);
    
% Std Dev Platform Motion & Tilt Angle
figure;
subplot(2,1,1); plot(c10.jd,c10.uplat_std,'-',c10.jd,c10.vplat_std,'-',c10.jd,c10.wplat_std,'-');
    title(sprintf('%s (%04i-%02i-%02i, DOY%03i).  Motion Std Dev & Tilt',cruise_str,the_yr,...
        the_mo,the_day,the_jd),'FontWeight','Bold','Interpreter','none');
    xlabel('Hour UTC');ylabel('Motion Std Dev, m s^{-1}'); 
    ylim([0 2]); grid;
    set(gca(gcf),'XTick',the_jd:2/24:the_jd+1);datetick('x','HH:MM','keepticks');
    legend('u','v','w','Location','Best');
    xax=get(gca(gcf),'XTickLabel');xax(end,:)='24:00';set(gca(gcf),'XTickLabel',xax(:,1:2));
subplot(2,1,2); plot(c10.jd,c10.tilt,'-k');
    xlabel('Hour UTC');ylabel('Wind Tilt Angle, ^o'); 
    ylim([-10 35]);grid;
    set(gca(gcf),'XTick',the_jd:2/24:the_jd+1);datetick('x','HH:MM','keepticks');
    xax=get(gca(gcf),'XTickLabel');xax(end,:)='24:00';set(gca(gcf),'XTickLabel',xax(:,1:2))
    annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',...
        {'NOAA PSL'},'FontSize',15,'FitBoxToText','off','LineStyle','none');
orient tall
    print(graphdevice,ppath_MOT);

% Heat Fluxes
maxhl = 450; minhl = 0; maxhs = 70; minhs = -20;
wh_cov = find(c10.good_motion == 1);
wh_covl = find(c10.good_motion_licor == 1);
wh_id = find(c10.good_motion_id == 1);
wh_idl = find(c10.good_motion_id_licor == 1);


figure;
subplot(2,1,1); plot(b.jd,b.hl_s,'b-',b.jd,b.hl,'r-',...
        c10.jd(wh_idl),c10.hl_ida(wh_idl),'mo',c10.jd(wh_idl),c10.hl_idb(wh_idl),'co',...
        c10.jd(wh_covl),c10.hl_cov_sds(wh_covl),'go',c10.jd(wh_covl),c10.hl_cov(wh_covl),'k*');
    title(sprintf('%s (%04i-%02i-%02i, DOY%03i).  Heat Fluxes',cruise_str,the_yr,...
        the_mo,the_day,the_jd),'FontWeight','Bold','Interpreter','none');
    xlabel('Hour UTC');ylabel('Latent Heat, W m^{-2}'); grid;
    ylim([minhl, maxhl]);
    set(gca(gcf),'XTick',the_jd:2/24:the_jd+1);datetick('x','HH:MM','keepticks');
    xax=get(gca(gcf),'XTickLabel');xax(end,:)='24:00';set(gca(gcf),'XTickLabel',xax(:,1:2));
    legend('bulk ship','bulk PSL','ID a','ID b','cov SdS','cov','Location','eastoutside');
subplot(2,1,2); plot(b.jd,b.hs_s,'b-',b.jd,b.hs,'r-',...
        c10.jd(wh_id),c10.hs_ida(wh_id),'mo',c10.jd(wh_id),c10.hs_idb(wh_id),'co',...
        c10.jd(wh_cov),c10.hs_cov_sds(wh_cov),'go',c10.jd(wh_cov),c10.hs_cov(wh_cov),'k*');
    xlabel('Hour UTC');ylabel('Sensible Heat, W m^{-2}'); grid;
    ylim([minhs,maxhs]);
    set(gca(gcf),'XTick',the_jd:2/24:the_jd+1);datetick('x','HH:MM','keepticks');
    xax=get(gca(gcf),'XTickLabel');xax(end,:)='24:00';set(gca(gcf),'XTickLabel',xax(:,1:2))
    legend('bulk ship','bulk PSL','ID a','ID b','cov SdS','cov','Location','eastoutside');
    annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',...
        {'NOAA PSL'},'FontSize',15,'FitBoxToText','off','LineStyle','none');
    print(graphdevice,ppath_HEAT);

% Stress
figure; plot(b.jd,b.tau_s,'b-',b.jd,b.tau,'r-',...
    c10.jd(wh_cov),c10.tau_cov(wh_cov),'k*',...
    c10.jd(wh_id),c10.tau_ida(wh_id),'mo',c10.jd(wh_id),c10.tau_idb(wh_id),'co');
title(sprintf('%s (%04i-%02i-%02i, DOY%03i).  Streamwise Stress',cruise_str,the_yr,...
    the_mo,the_day,the_jd),'FontWeight','Bold','Interpreter','none');
xlabel('Hour UTC');ylabel('Stress, N m^{-2}'); grid; ylim([-0.02 0.45]);
set(gca(gcf),'XTick',the_jd:2/24:the_jd+1);datetick('x','HH:MM','keepticks');
xax=get(gca(gcf),'XTickLabel');xax(end,:)='24:00';set(gca(gcf),'XTickLabel',xax(:,1:2));
legend('bulk ship','bulk PSL','cov','ID a','ID b','Location','eastoutside');
annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',...
    {'NOAA PSL'},'FontSize',15,'FitBoxToText','off','LineStyle','none');
    print(graphdevice,ppath_TAU);

   
end

% close all;

