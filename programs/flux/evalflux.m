%{
 Process daily met files, make diagnostic plots, and save intermediate
 1-min and 10-min data files.

 Updated May 2021 EJT

 Calls:
  read_met_day:     PSL met data from loggers 1 & 2 @ 1 min     from 1 min data
  read_gps_day:     PSL gps course & speed @ 1 Hz               from 10 Hz data
  read_hed_day:     PSL gps heading & pitch @ 1 Hz              from 10 Hz data
  read_motion_day:  PSL MotionPak @ 1 Hz                        from 10 Hz data
  read_sonic_day:   PSL sonic wind @ 1 Hz                       from 10 Hz data
  read_licor_day:   PSL licor fast water vapor / co2 @ 1 Hz     from 10 Hz data
  read_ship_day:    ship data @ 1 Hz                            from 1 Hz or sometimes faster data
  read_wxt_day      PSL WXT met data @ 1 Hz                     from 1 min data
%}

%%  initialize run parameters
clear;
close('all');
fclose('all');
warning ('off','MATLAB:MKDIR:DirectoryExists');
setup_cruise;


plot_checks = 1;
have_ship_data = 1;
have_wxt_data = 0;
have_lat_data = 1;

%% set day-of-year range for this run... 
%%% 159 hr 08 (June 8) through 176 hr 05 (June 25) for PSL data
%%% 160 hr 10 through 176 hr 21 for ship data
% TSGs not good until 1530 UTC June 10th? 
% went bad again 24th 17:45 UTC

% ASTRAL 2024: jd 119 - 134 for leg 1
%              jd 139 -     for leg 2

% I don't know why this will only run one day at a time but I think it has
% to do with python.... maybe that only matters the first time... since
% gprm files only need to be created once? Another fix would be to write a
% separate program to run all the python codes outside of this code.
% YES, matlab can't pipe to [mini]conda environments, so then 
% one has to run python converters from outside matlab.
jdStart = 139; jdStop = 180;

min10 = datenum(2018,8,27,0,10,0) - datenum(2018,8,27,0,0,0);

%% set paths
plotit = true; % for doing plots.
prtit = true;  % for saving plots (plotit must also be true)
graphformat = '.png';  % select graphics format files
graphdevice = '-dpng'; % select graphic device

% system specific path defs
sysType = computer;
username=char(java.lang.System.getProperty('user.name'));
if strncmp(sysType,'MACI64',7) && strncmp(username, 'ethompson', 9)     % set Mac paths
    data_drive = '/Users/ethompson/DATA/';
    path_prog = fullfile(data_drive,cruise,ship,'Scientific_Analysis','programs');
elseif strncmp(sysType,'MACA64',7) && strncmp(username, 'deszoeks', 8)
    data_drive = '/Users/deszoeks/Data/';
    path_prog = fullfile('/Users/deszoeks/Projects/ASTRAL/PSL/programs');
elseif strncmp(sysType,'PCWIN64',7)  % set PSL DAC paths
    data_drive = 'D:\DATA\';
    path_prog = fullfile(data_drive,cruise,ship,'Scientific_Analysis','programs');
end

% matlab script path
restoredefaultpath
cd(fullfile(path_prog,'flux'));
addpath(genpath(fullfile(path_prog,'flux')));
path_python = fullfile(path_prog,'python');
rehash toolboxcache;

% paths relative to data_drive - these should be preexisting
path_readme = fullfile(data_drive,cruise,'PSL','readme');
mkdir(path_readme);
% path_raw_data = fullfile(data_drive,cruise,ship,'Raw');
path_raw_data = fullfile(data_drive,cruise,'PSL');
% ship_met_path = fullfile(data_drive,cruise,ship,'PSL','ship');%notused

% define folders for saving data and plots
% path_proc_data = fullfile(data_drive,cruise,ship,'flux','Processed');
path_proc_data = fullfile(data_drive,cruise,'PSL','flux','Processed');
mkdir(path_proc_data);
mkdir(fullfile(path_proc_data,'v0_1min'));
mkdir(fullfile(path_proc_data,'v0_10min'));

% path_raw_images = fullfile(data_drive,cruise,ship,'flux','Raw_Images');
path_raw_images = fullfile(data_drive,cruise,'flux','Raw_Images');
mkdir(path_raw_images);
mkdir(fullfile(path_raw_images,'qSpectra'));
mkdir(fullfile(path_raw_images,'Rwspd'));
mkdir(fullfile(path_raw_images,'sonicQC'));
mkdir(fullfile(path_raw_images,'tSpectra'));
mkdir(fullfile(path_raw_images,'uSpectra'));
mkdir(fullfile(path_raw_images,'wSpectra'));
mkdir(fullfile(path_raw_images,'SST'));
mkdir(fullfile(path_raw_images,'SL_pressure'));
mkdir(fullfile(path_raw_images,'Temps'));
mkdir(fullfile(path_raw_images,'RH'));
mkdir(fullfile(path_raw_images,'Wind'));
mkdir(fullfile(path_raw_images,'Rainrate'));
mkdir(fullfile(path_raw_images,'T_RH_fan'));
mkdir(fullfile(path_raw_images,'Track_plot'));
mkdir(fullfile(path_raw_images,'COG_SOG'));
mkdir(fullfile(path_raw_images,'Heading'));
mkdir(fullfile(path_raw_images,'pitch'));
mkdir(fullfile(path_raw_images,'Relative_Wind'));
mkdir(fullfile(path_raw_images,'True_Wind'));
mkdir(fullfile(path_raw_images,'Motion'));
mkdir(fullfile(path_raw_images,'Licor_agc'));
mkdir(fullfile(path_raw_images,'Heat_Fluxes'));
mkdir(fullfile(path_raw_images,'ustar'));
mkdir(fullfile(path_raw_images,'IR_flux'));
mkdir(fullfile(path_raw_images,'Solar_flux'));

%% loop through days
for ddd = jdStart:jdStop
    %% run git  scripts on gps, heading, and WXT raw files
    [m,d] = yd2md(yr, ddd);
    Vdate = [yr, m, d];
    path_working_ddd = fullfile(path_raw_data,[sprintf('%03i',ddd)]);
    % convert PSL gps and met3 files to gprm and wxt format with python script
    % python language must be installed on the computer.
    cd(path_working_ddd);
    % python_exe = '/opt/anaconda3/bin/python '
    % run python from the condor micromamba environment
    python_exe = 'micromamba run -n condor python '

    fclose('all');

    files = dir('gps*.txt');
    if ~isempty(files)
        system([python_exe,fullfile(path_python,'parseGpsFiles.py')]);
    end

    files = dir('hed0*.txt');
    if ~isempty(files)
        system([python_exe,fullfile(path_python,'parseHedFiles.py')]);
    end
    
    files = dir('met3*.txt');
    if ~isempty(files)
        system([python_exe,fullfile(path_python,'parseWXTFiles.py')]);
    end
    
    
    %%%=====================================================================
    %% read data - this takes time...
      % read PSL gps - gprm is 1Hz 86400x7 array: 1 sec
   
    gprm = read_gps_day(path_working_ddd,ddd,yr_st,PosLims);   

    if sum(isnan(gprm(:,2))) > 2000
        disp('something wrong with gps');
        stop;
    end

    % read PSL sonic - sonm is 1Hz 86400x5: 1 sec data
    sonm = read_sonic_day(path_working_ddd,ddd,yr_st,sonicmodel,...
         rotationsonic,fsonic,prtit,path_raw_images,graphformat,graphdevice); 


    if have_ship_data == 1
        % read ship (used to be called "SCS") data - from ship at 1 Hz 86400 by numvars: 1 sec
        % # fields changes each cruise depending on how much ship data is provided and what type
        ship_day = read_ship_day_ASTRAL_2024(path_working_ddd,ddd,yr,PosLims,ship_adj,zp_ship,zq_ship);
        % test with read_ship_practice or with this command:
        %  ship_day = read_ship_day('/Users/eliz/DATA/ATOMIC/Brown/flux/Raw/20010',10,'2020',[45 63 5 15],[0 0],15.6337)
    end
    

    % read PSL 1-min avg bulk met data - metm is 1440x17 array: 1 min
    metm = read_met_day(path_working_ddd,ddd,yr_st,zp);
    
    % read PSL heading-pitch - hedm is 1Hz 86400x3 array: 1 sec
    % array for MISOBOB - heading not working
    hedm = read_hed_day(path_working_ddd,ddd,yr_st);

    % read PSL motionPak - motm is 1Hz 86400x13: 1 sec
    motm = read_motion_day(path_working_ddd,ddd,yr_st);
       
    % MOTION PLOT - 1 Hz
    if plot_checks == 1
        figure;
        subplot(3,2,1);plot(motm(:,1),motm(:,2),'.','markersize',2);ylabel('accx (m.s^-^2)');
        ylim([-5 5]);set(gca(gcf),'XTick',ddd:2/24:ddd+1); datetick('x','HH:MM','keepticks');
        xax = get(gca(gcf),'XTickLabel'); xax(end,:)='24:00'; set(gca(gcf),'XTickLabel',xax(:,1:2));
        grid;
        subplot(3,2,2);plot(motm(:,1),motm(:,3),'.','markersize',2);ylabel('accy (m.s^-^2)');
        ylim([-5 5]);set(gca(gcf),'XTick',ddd:2/24:ddd+1);datetick('x','HH:MM','keepticks');
        xax = get(gca(gcf),'XTickLabel'); xax(end,:)='24:00'; set(gca(gcf),'XTickLabel',xax(:,1:2));
        grid;
        subplot(3,2,3);plot(motm(:,1),motm(:,4),'.','markersize',2);ylabel('accz (m.s^-^2)');
        ylim([5 15]);set(gca(gcf),'XTick',ddd:2/24:ddd+1);datetick('x','HH:MM','keepticks');
        xax = get(gca(gcf),'XTickLabel'); xax(end,:)='24:00'; set(gca(gcf),'XTickLabel',xax(:,1:2));
        grid;
        subplot(3,2,4);plot(motm(:,1),motm(:,5),'.','markersize',2);ylabel('ratex (rad/s)');
        ylim([-5 5]*.02);set(gca(gcf),'XTick',ddd:2/24:ddd+1);datetick('x','HH:MM','keepticks');
        xax = get(gca(gcf),'XTickLabel'); xax(end,:)='24:00'; set(gca(gcf),'XTickLabel',xax(:,1:2));
        grid;
        subplot(3,2,5);plot(motm(:,1),motm(:,6),'.','markersize',2);ylabel('ratey (rad/s)');xlabel('Hour (UTC)');
        ylim([-5 5]*.02);set(gca(gcf),'XTick',ddd:2/24:ddd+1);datetick('x','HH:MM','keepticks');
        xax = get(gca(gcf),'XTickLabel'); xax(end,:)='24:00'; set(gca(gcf),'XTickLabel',xax(:,1:2));
        grid;
        subplot(3,2,6);plot(motm(:,1),motm(:,7),'.','markersize',2);ylabel('ratez (rad/s)');xlabel('Hour (UTC)');
        ylim([-5 5]*.02);set(gca(gcf),'XTick',ddd:2/24:ddd+1);datetick('x','HH:MM','keepticks');
        xax = get(gca(gcf),'XTickLabel'); xax(end,:)='24:00'; set(gca(gcf),'XTickLabel',xax(:,1:2));
        grid;
        annotation(gcf,'textbox',[0.35 0.96 0.8 0.02462],'String',sprintf('%s (%04i-%02i-%02i, DOY%03i).  PSL motion pack',cruise_str,Vdate(1),Vdate(2),Vdate(3),ddd),'Fontsize',18,'FontWeight','Bold','FitBoxToText','off','LineStyle','none','Interpreter','none');
        annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL'},'FontSize',14,'FitBoxToText','off','LineStyle','none');
        if prtit
            ppath = fullfile(path_raw_images,'Motion',['MotionPak_',sprintf('%04i_%02i_%02i_%03i',Vdate(1),Vdate(2),Vdate(3),ddd),graphformat]);
            print(graphdevice,ppath);
        end
    end
    

    % read PSL Licor - licm is 1Hz 86400x8: 1 sec data 
    licm = read_licor_day(path_working_ddd,ddd,yr_st,...
                flicor,prtit,path_raw_images,graphformat,graphdevice);  
     
%     % read wxt data - wxtm is 1440 x 9 array: 1 min data
%     wxtm = read_wxt_day(path_working_ddd,ddd,yr_st,zwxt);

    close all
           
    %% 1-min averages for some variables
    disp('doing work on 1 min vars');
    
    %%% time
    jd_1min = metm(:,1); % ref 1-min timestamp
    delta = double(1.0/1440);
    last = ddd + 1440*delta;
    jd_1bin = (ddd:delta:last);	
    jd_1bin = jd_1bin'; % ref 1-min bin edges
    t_1min = datenum(yr,0,0,0,0,0) + jd_1min;
    
    delta_10 = double(10.0/1440);
    last_10 = ddd + 144*delta_10;
    jd_10bin = (ddd:delta_10:last_10);	
    jd_10bin = jd_10bin'; % ref 10-min bin edges 
    jd_10min = jd_10bin(1:end-1); % reference 10-min timestamp
    t_10min = datenum(yr,0,0,0,0,0) + jd_10min;
    
    %% 1-min PSL data
    
%     %%% motion data...saved for high resolution run_motcorr program later
%     motm1 = interval_avg(motm(:,1), motm(:,2:7), jd_1bin); % average everything
%     accX = motm1(:,2);
%     accY = motm1(:,3);
%     accZ = motm1(:,4);
%     rateX = motm1(:,5);
%     rateY = motm1(:,6);
%     rateZ = motm1(:,7);

    %%% PSL gps data, sog, cog
    gprm1 = interval_avg(gprm(:,1), gprm(:,2:7), jd_1bin); % average everything
    lat = gprm1(:,6); %
    lon = gprm1(:,7); %
    sogN = gprm1(:,4); % mean ship speed toward N
    sogE = gprm1(:,5); % mean ship speed toward W
    sog = sqrt(sogN.^2 + sogE.^2);  % recompute sog from speed components
    cog = atan2(sogE, sogN)*r2d; % recompute cog from speed components
    cog = mod(cog + 360, 360);
    gprm1(:,2) = cog; % replace with updated 1-min cog/sog
    gprm1(:,3) = sog;
    
    %%% PSL heading: from 1 Hz to 1 min sampling. Keep in hedm structure
    %%% since that's what is averaged to 10 min later on.
    [hedN_10Hz, hedE_10Hz] = pol2cart(hedm(:,2)*d2r,1);  % N/E heading components at 1 Hz in radians
    hedm = [hedm, hedN_10Hz, hedE_10Hz];                   % add to array of 1 Hz data
    hedm1 = interval_avg(hedm(:,1), hedm(:,2:5), jd_1bin); % average everything to 1 min
    hedN1 = hedm1(:,4);
    hedE1 = hedm1(:,5);
    hed = atan2(hedE1, hedN1)*r2d; % recompute hed from avg N/E components in radians, then convert back to degrees
    hed = mod(hed + 360, 360);
    hedm1(:,2) = hed; % replace with updated 1-min hed
    [hedN, hedE] = pol2cart(hed*d2r,1);  % recomputed N/E heading components with 1 min avgs to be consistent
    
    %%% PSL pitch from heading
    pitch = hedm1(:,3); % this is at 1 min
    ii = find(isnan(pitch)); 
    pitch(ii) = nanmean1(pitch);
    
    %%% sonic
    sonm1 = interval_avg(sonm(:,1), sonm(:,2:5), jd_1bin); % average all sonm
    tsonic = sonm1(:,5);
    
    % correct ORG offset
    orgV_bkgd = nanmedian1(despike2(metm(:,17))); % single value
    orgV_adj = 0.06484 - orgV_bkgd; % single value
    org_recalc = (metm(:,17)+orgV_adj).^1.87*25 - 0.15; % recompute rain rate after adjustment
    org_recalc(org_recalc<0.05) = 0; % set lower limit on org rain rate sensitivity
    prate = org_recalc;
    prate(isnan(org_recalc) == 1) = 0; % reset nan to zero
    orgV = metm(:,17); % voltage 
    orgV_desp = despike2(metm(:,17)); % voltage despiked
    prate_orig = metm(:,13); % orgiginal rain rate estimated from ORG
    temp = prate;
    temp(isnan(temp)) = 0;
    paccum = cumsum(temp)/60; % 60 min per hour
    
    %%% relative and true wind from sonic and PSL gps, heading, sog, cog
    % Apply flow distortion corrections for mean spd using 0.95 & 1.15 
    % coefficients. Note: these are based on global class vessels like
    % R/V Revelle, R/V Thompson, and NOAA Ship Brown. They could need to be
    % adjusted for smaller or different profile ships. Also use ship
    % heading, sog, and cog, for adjusting relative wind. We don't know 
    % whether the w component or w^2 in vector average/sum is needed 
    % to compute wspd... we assume not though because we are instead 
    % correcting for flow distortion with the coefficients. Coefficients
    % were reduced to account for increase in flow distortion on R/V ride.
    % The change was arrived at by inspecting da_red plots to come up with
    % a percentage increase/decrease ~ 15% decrease in coefficients 
    % chris had writfdsa  Eadzy that wasn't 15% c kj

    [rspd,rdir] = uv_to_sd(sonm1(:,2)/0.95,sonm1(:,3)/1.15); % 
    [rUn, rUw] = sd_to_uv(rspd, rdir);
    rdir(rdir>180) = rdir(rdir>180)-360;    % +/- 180 deg format
    [wspd,wdir,Un, Uw] = uv_rel_to_sd_true(sonm1(:,2)/0.95,sonm1(:,3)/1.15,hed,cog,sog);
%     [wspd2,wdir2,Un2, Uw2] = uv_rel_to_sd_true(rUn,rUw,hed,cog,sog);
   
    %%% plot wind speeds and directions

%     figure;
%     subplot(2,2,1);
%     plot(t_1min, wspd, ship_day.t, ship_day.wspd)
%     title('wspd');
%     datetick('x','HH')
%     subplot(2,2,2);
%     plot(t_1min, wdir, ship_day.t, ship_day.wdir)
%     title('wdir');
%     datetick('x','HH')
%     subplot(2,2,3);
%     plot(t_1min, rspd, ship_day.t, ship_day.rspd)
%     title('rspd');
%     datetick('x','HH')
%     subplot(2,2,4);
%     plot(t_1min, rdir, ship_day.t, ship_day.rdir)
%     title('rdir');
%     datetick('x','HH')
    
    %% other met data

    ta = metm(:,2);
    rh = metm(:,3);
    tsnk = metm(:,4);
    sw_dn_1 = metm(:,5); % should be positive value... 
    lw_dn_1 = metm(:,6); % should be positive value... 
    sw_dn_2 = metm(:,7); % should be positive value... 
    lw_dn_2 = metm(:,8); % should be positive value... 
    lw_case_t_1 = metm(:,9);
    lw_dome_t_1 = metm(:,10);
    lw_case_t_2 = metm(:,11);
    lw_dome_t_2 = metm(:,12);
    psealevel = metm(:,14);  % sea level press
    pa = metm(:,20);  % measured press at height zp
    pa_at_zq = psealevel - 0.125*zq;
    aspir_trh = metm(:,15);
    lw_therm_1 = metm(:,18); % measured value should be negative voltage. If not, flip sign when using this value to compute IR downwelling radiation in fix_met_sea.
    lw_therm_2 = metm(:,19); % measured value should be negative voltage. If not, flip sign when using this value to compute IR downwelling radiation in fix_met_sea.
    qa = qair_p(ta,rh,pa_at_zq);
    qsnk = qsea_p(tsnk,psealevel);
    % air density (kg/m3) and h2o number density (mmol/m3)
    rhoa = air_density(ta,pa_at_zq,rh); %%% this gets recalculated in COARE below
    h2o = qa.*rhoa/0.018016;
            
    % average licm
    licm1 =  interval_avg(licm(:,1), licm(:,2:end), jd_1bin); 
%     licor_agc = licm1(:,5);
    
    % 1-min licor h2o and co2 statistics: 6x5 array output
    % stats are for 'all' data, not screened for bad agc
    % 1 jd_ref, 2 Licor_h2o(mmol/m3), 3 Licor_t(C), 4 Licor_P(kpa), 5 agc
    lic_jd = licm1(:,1);
    
    licor_h2o = licm1(:,2); % Licor_H20, h2o density, mmol/m3 
    licor_tbox = licm1(:,3); % Licor box ta, C
    licor_pbox = licm1(:,4); % Licor box pa, kPa
    licor_agc = licm1(:,5); % Licor agc, mean diagnostic value
    licor_co2 = licm1(:,6); % Licor co2 density, mmol/m3
    
    % there are SO many bad values in tbox and pbox. They correspond to bad
    % values in co2 but not h2o, q, or rhoa... we use Ta and Pa from PSL
    % instead to compute licor met quantities below. Don't bother QC-ing
    % pbox and Tbox. 
%     licor_Tbox(licor_Tbox > 40) = nan;
%     licor_pbox(licor_pbox*10 > 1030) = nan;
    
    %%% these are redone with 10 Hz data in motcorr, so are commented out
%     licor_h2o_std = interval_std_var(licm(:,1), licm(:,2), jd_1bin); % standard deviation of Licor h2o, mmol/m3
%     licor_pbox_std = interval_std_var(licm(:,1), licm(:,4), jd_1bin); % standard deviation of Licor box pa, kPa

    licor_h2o_mr = (licor_h2o*1e-3).*Rgas_universal.*(ta+C2K)./(pa_at_zq*1e-1); % WV mr converted from mmol/m3 to mol water / mol dry air
    licor_rhoa_dry = (pa_at_zq*1e3).*(1-licor_h2o_mr*(1-epsilon))./(Rgas.*(ta+C2K)); % dry air density in licor [kg/m3]... conserved
    licor_qa_dry = (licor_h2o*1e-3).*Mw./licor_rhoa_dry; % mmol/m3 to g/kg dry air only
    licor_qa = (licor_h2o*1e-3).*Mw./rhoa; % mmol/m3 to g/kg moist air mix
    licor_co2_mr = (licor_co2).*Rgas_universal.*(ta+C2K)./(pa_at_zq*1e-1); % C02 mr converted from mmol/m3 to ppm... micromol C02 / mol dry air
    licor_rh = relhum([ta,licor_qa,pa_at_zq]);
    
    %%% quality control licor data based on agc. Good value where agc < 60
    % note: the high frequency licor data are used in computing eddy
    % covariance and inertial dissipation latent heat flux, not these
    % 10-min values that are computed and saved here. 
    wh_good_licor = find(licor_agc < 60);
    wh_bad_licor = find(licor_agc >= 60);
    licor_rhoa_dry(wh_bad_licor) = nan; % kg / m3
    licor_qa_dry(wh_bad_licor) = nan; % g / kg
    licor_qa(wh_bad_licor) = nan; % g / kg
    licor_h2o(wh_bad_licor) = nan;  % mmol/m3
    licor_h2o_mr(wh_bad_licor) = nan;  % mol/mol
    licor_tbox(wh_bad_licor) = nan; % C
    licor_pbox(wh_bad_licor) = nan; % kPa
    licor_co2_mr(wh_bad_licor) = nan; % ppm
    licor_rh(wh_bad_licor) = nan; % %
    
    %% 1-min WXT data
    if have_wxt_data == 1
        rUn_wxt = wxtm(:,8);
        rUw_wxt = wxtm(:,9);
        [rspd_wxt,rdir_wxt] = uv_to_sd(rUn_wxt,rUw_wxt); % recompute wspd/wdir with cog, sog, hed (which WXT doesn't do in its reader, since it doesn't measure it)
        rr = rdir_wxt>180; 
        rdir_wxt(rr) = rdir_wxt(rr)-360;
        [wspd_wxt,wdir_wxt,Un_wxt,Uw_wxt] = uv_rel_to_sd_true(wxtm(:,8),wxtm(:,9),hed,cog,sog);
        ta_wxt = wxtm(:,4);
        rh_wxt = wxtm(:,5);
        pa_wxt = wxtm(:,6);
        qa_wxt = qair_p(ta_wxt, rh_wxt, pa_wxt); % spec humidity
        % air density (kg/m3) and h2o number density (mmol/m3)
        rhoa_wxt = air_density(ta_wxt,pa_wxt,rh_wxt);
        h2o_wxt = qa_wxt.*rhoa_wxt/0.018016;
        psealevel_wxt = wxtm(:,6)+0.125*zwxt;
        prate_wxt = wxtm(:,7);  % mm/hr
        prate_wxt(isnan(prate_wxt) == 1) = 0; % reset nan to zero
        temp = prate_wxt;
        temp(isnan(temp)) = 0;
        paccum_wxt = cumsum(temp)/60; % 60 X 1 min segments per hour
    end
    
    %% make plots of met data to check
    plot_psl_vars = 0;
    if plot_psl_vars == 1
    f_psl = {'lat';'lon';'ta';'tsonic';'tsnk';'rh';'qa';...
        'psealevel';'pa';'h2o';'prate';'paccum';...
        'prate_orig';'orgV';'orgV_desp';...
        'sw_dn_1';'sw_dn_2';'lw_dn_1';'lw_dn_2';...
        'lw_dome_t_1';'lw_case_t_1';'lw_dome_t_2';'lw_case_t_2';...
        'lw_therm_1';'lw_therm_2';'wspd';'wdir';'rspd';'rdir';...
        'sog';'cog';'sogE';'sogN';'hed';'hedE';'hedN';...
        'aspir_trh';'pitch';...
        'licor_agc';'licor_rhoa_dry';'licor_qa';'licor_qa_dry';'licor_h2o';'licor_h2o_mr';...
        'licor_tbox';'licor_pbox';'licor_co2';'licor_co2_mr';'licor_rh'};
    pathplot = '/Users/ethompson/DATA/ASTRAL_2024/Revelle/flux/Raw_Images/check/';
    figure;
    counter = 1;
    nc = length(f_psl);
    for i = 1:4:nc
        clf;
        for j = 1:4
           if (i+j-1) <= nc
               subplot(2,2,j); hold on;
               eval(['thevar = ' f_psl{i+j-1} ';']);
               plot(t_1min, thevar,'o');
               grid on;
               var_name = {strrep(f_psl{i+j-1},'_',' ')};
               title([sprintf('%i',ddd) ' ' var_name]);
               xlim([min(t_1min) max(t_1min)]);
               datetick('x','keeplimits');
               grid on;
           end
        end
       print(graphdevice,[pathplot 'PSL_ASTRAL_2023_' sprintf('%i',ddd) '_' sprintf('%i',counter) graphformat]);
       counter = counter + 1;
    end  % for all vars
    end % if plotting    
        
    %% 1-min ship data 
    if have_ship_data == 1
    %     The reader checks to make sure sog is in m/s. This could also be done
    %     here instead or later in fixit.m
    
        %%% for PISTON only, change units of T from K to C, eliminate noisy
        %%% (negative) values of lw_dn. NOTE: do most of the other fixes later
        %%% in fixit.m afterwards. 
%         ship_day.lw_case_t = ship_day.lw_case_t-273.15;
%         ship_day.lw_dome_t = ship_day.lw_dome_t-273.15;
        ship_day.lw_dn(ship_day.lw_dn < 0 | ship_day.lw_dn > 500) = nan;        
    
        %%% ship heading, cog, sog, wind: from 1 Hz to 1 min sampling, into ship_avg structure.
        % recomputed N/E heading components from 1 min avg magnitude and direction
        ship_day.hed = ship_day.hed; 
        [ship_day.hedN, ship_day.hedE] = pol2cart(ship_day.hed*d2r,1);  
        [ship_day.Un, ship_day.Uw] = sd_to_uv(ship_day.wspd, ship_day.wdir);
        [ship_day.rUn, ship_day.rUw] = sd_to_uv(ship_day.rspd, ship_day.rdir);
        [ship_day.Un2, ship_day.Uw2] = sd_to_uv(ship_day.wspd2, ship_day.wdir2);
        [ship_day.rUn2, ship_day.rUw2] = sd_to_uv(ship_day.rspd2, ship_day.rdir2);
        [ship_day.Un3, ship_day.Uw3] = sd_to_uv(ship_day.wspd3, ship_day.wdir3);
        [ship_day.rUn3, ship_day.rUw3] = sd_to_uv(ship_day.rspd3, ship_day.rdir3);
        


         % PISTON: speed log. Should be in m/s to match sog. It was originally in kt.
%         ship_day.spdlog_u = ship_day.spdlog_u./1.944;
%         ship_day.spdlog_v = ship_day.spdlog_v./1.944;
    
        %%% add remaining ship vars not in there already
%         ship_day.prate = cum2rate(ship_day.paccum', t_1min')';
%         ship_day.prate(isnan(ship_day.prate) == 1) = 0; % reset nan to zero
%         ship_day.spdlog = sqrt(ship_day.spdlog_u.^2 + ship_day.spdlog_v.^2);
        
        plot_ship_vars = 0;
        if plot_ship_vars == 1
        figure;
        counter = 1;
        thefields = fields(orderfields(ship_day));
        nc = length(thefields);
        for i = 1:4:nc
            clf;
            for j = 1:4
               if (i+j-1) <= nc
                   subplot(2,2,j); hold on;
                   eval(['thevar = ship_day.' thefields{i+j-1} ';']);
                   plot(ship_day.t, thevar,'o');
                   grid on;
                   var_name = {strrep(thefields{i+j-1},'_',' ')};
                   title([sprintf('%i',ddd) ' ' var_name]);
                   xlim([min(ship_day.t) max(ship_day.t)]);
                   datetick('x','keeplimits');
                   grid on;
               end
            end
           print(graphdevice,[pathplot 'ship_ASTRAL_2023_' sprintf('%i',ddd) '_' sprintf('%i',counter) graphformat]);
           counter = counter + 1;
        end  % for all vars
        end % if plotting
    
        
        % do 1-min averages of all ship data
        clear ship_avg;
        mfields = fields(ship_day);
        for j = 1:length(mfields) 
            x = ship_day.(mfields{j});
            ship_avg.(mfields{j}) = interval_avg_var(ship_day.jd, x, jd_1bin);
        end
    
        lat_s = ship_avg.lat;
        lon_s = ship_avg.lon;
        sog_s = sqrt(ship_avg.sogN.^2 + ship_avg.sogE.^2);  % recompute sog from speed components
        cog_s = atan2(ship_avg.sogE, ship_avg.sogN)*r2d;  % recompute cog from speed components
        cog_s = mod(cog_s + 360, 360);
        ship_avg.cog = cog_s; % replace with updated 1-min cog/sog
        ship_avg.sog = sog_s;
        hed_s = atan2(ship_avg.hedE, ship_avg.hedN)*r2d; % recompute avg hed from avg N/E components
        hed_s = mod(hed_s + 360, 360);
        ship_avg.hed = hed_s; % replace with updated 1-min hed
    

%     [rspd,rdir] = uv_to_sd(sonm1(:,2)/0.95,sonm1(:,3)/1.15); % 
%     [rUn, rUw] = sd_to_uv(rspd, rdir);
%     rdir(rdir>180) = rdir(rdir>180)-360;    % +/- 180 deg format
%     [wspd,wdir,Un, Uw] = uv_rel_to_sd_true(sonm1(:,2)/0.95,sonm1(:,3)/1.15,hed,cog,sog);
%     [wspd2,wdir2,Un2, Uw2] = uv_rel_to_sd_true(rUn,rUw,hed,cog,sog);

        [rspd_s,rdir_s] = uv_to_sd(ship_avg.rUn, ship_avg.rUw); 
        rdir_s(rdir_s>180) = rdir_s(rdir_s>180)-360;    % +/- 180 deg format
        %%% use same rUn and rUw components, and the recently recalculated 10-min avgs of hed, sog, cog, to do 10-min true wind
        [wspd_s,wdir_s,Un_s,Uw_s] = uv_rel_to_sd_true(ship_avg.rUn,ship_avg.rUw,ship_avg.hed,ship_avg.cog,ship_avg.sog);
%         ship_avg.wspd = wspd_s;
        ship_avg.rspd = rspd_s;
%         ship_avg.wdir = wdir_s;
        ship_avg.rdir = rdir_s;
%         ship_avg.Un = Un_s;
%         ship_avg.Uw = Uw_s;  
% it's unclear why this component approach with cog, sog, hed from
% rspd/rdir isn't working, but the only way I could get the ship_avg =
% ship_day was to calculate ship_avg wdir and wspd from its averaged Un and
% Uw components. I don't know why, and this hasn't been necessary for prior
% cruises. 
        [ship_avg.wspd,ship_avg.wdir] = uv_to_sd(ship_avg.Un, ship_avg.Uw); 

        figure;
        subplot(2,2,1);plot(ship_day.t, ship_day.rUn, ship_avg.t, ship_avg.rUn); title('rUn');
        subplot(2,2,2);plot(ship_day.t, ship_day.rUw, ship_avg.t, ship_avg.rUw); title('rUw');
        subplot(2,2,3);plot(ship_day.t, ship_day.Un, ship_avg.t, ship_avg.Un); title('Un');
        subplot(2,2,4);plot(ship_day.t, ship_day.Uw, ship_avg.t, ship_avg.Uw); title('Uw');    

        [rspd2_s,rdir2_s] = uv_to_sd(ship_avg.rUn2, ship_avg.rUw2); 
        rdir2_s(rdir2_s>180) = rdir2_s(rdir2_s>180)-360;    % +/- 180 deg format
        %%% use same rUn and rUw components, and the recently recalculated 10-min avgs of hed, sog, cog, to do 10-min true wind
%         [wspd2_s,wdir2_s,Un2_s,Uw2_s] = uv_rel_to_sd_true(ship_avg.rUn2,ship_avg.rUw2,ship_avg.hed,ship_avg.cog,ship_avg.sog);
        ship_avg.rspd2 = rspd2_s;
        ship_avg.rdir2 = rdir2_s;
        [ship_avg.wspd2,ship_avg.wdir2] = uv_to_sd(ship_avg.Un2, ship_avg.Uw2); 


        [rspd3_s,rdir3_s] = uv_to_sd(ship_avg.rUn3, ship_avg.rUw3); 
        rdir3_s(rdir3_s>180) = rdir3_s(rdir3_s>180)-360;    % +/- 180 deg format
        %%% use same rUn and rUw components, and the recently recalculated 10-min avgs of hed, sog, cog, to do 10-min true wind
%         [wspd3_s,wdir3_s,Un3_s,Uw3_s] = uv_rel_to_sd_true(ship_avg.rUn3,ship_avg.rUw3,ship_avg.hed,ship_avg.cog,ship_avg.sog);
        ship_avg.rspd3 = rspd3_s;
        ship_avg.rdir3 = rdir3_s;
        [ship_avg.wspd3,ship_avg.wdir3] = uv_to_sd(ship_avg.Un3, ship_avg.Uw3); 


%     figure;
%     subplot(2,2,1);
%     plot(t_1min, wspd, ship_day.t, ship_day.wspd, ship_avg.t, ship_avg.wspd)
%     title('wspd');
%     datetick('x','HH')
%     subplot(2,2,2);
%     plot(t_1min, wdir, ship_day.t, ship_day.wdir, ship_avg.t, ship_avg.wdir)
%     title('wdir');
%     datetick('x','HH')
%     subplot(2,2,3);
%     plot(t_1min, rspd, ship_day.t, ship_day.rspd, ship_avg.t, ship_avg.rspd)
%     title('rspd');
%     datetick('x','HH')
%     subplot(2,2,4);
%     plot(t_1min, rdir, ship_day.t, ship_day.rdir, ship_avg.t, ship_avg.rdir)
%     title('rdir');
%     datetick('x','HH')

        %% 10-min ship data
        %%% all the MET variables we want to save ... redo some of the 10-min
        %%% vars for averaging / time / component reasons
    
        clear ship_avg_10;
        mfields = fields(ship_day);
        for j = 1:length(mfields) 
            x = ship_day.(mfields{j});
            ship_avg_10.(mfields{j}) = interval_avg_var(ship_day.jd, x, jd_10bin);
        end
            
    
%         ship_avg_10.prate = cum2rate(ship_avg_10.paccum', t_10min')';
%         ship_avg_10.prate(isnan(ship_avg_10.prate) == 1) = 0; % reset nan to zero
%         ship_avg_10.spdlog = sqrt(ship_avg_10.spdlog_u.^2 + ship_avg_10.spdlog_v.^2);
            
        ship_avg_10.sog_std = interval_std_var(ship_day.jd, ship_day.sog, jd_10bin);    % sog std dev in ship speed
        ship_avg_10.hed_std = interval_std_var(ship_day.jd, unwrap(ship_day.hed*d2r), jd_10bin)*r2d;    % sog std dev in ship speed
        ship_avg_10.cog_std = interval_std_var(ship_day.jd, unwrap(ship_day.cog*d2r), jd_10bin)*r2d;    % sog std dev in ship speed
        ship_avg_10.ched_std = interval_std_var(ship_day.jd, sin(ship_day.hed*d2r), jd_10bin);    % sin of sog std dev in ship speed, in radians
        ship_avg_10.shed_std = interval_std_var(ship_day.jd, cos(ship_day.hed*d2r), jd_10bin);    % cos of sog std dev in ship speed, in radians
%         ship_avg_10.spdlog_std = interval_std_var(ship_day.jd, ship_day.spdlog_s, jd_10bin);    
        
        ship_avg_10.sog_min = interval_min_var(ship_day.jd, ship_day.sog, jd_10bin);    % sog min dev in ship speed
        ship_avg_10.hed_min = interval_min_var(ship_day.jd, unwrap(ship_day.hed*d2r), jd_10bin)*r2d;    % sog min dev in ship speed
        ship_avg_10.cog_min = interval_min_var(ship_day.jd, unwrap(ship_day.cog*d2r), jd_10bin)*r2d;    % sog min dev in ship speed
        
        ship_avg_10.sog_max = interval_max_var(ship_day.jd, ship_day.sog, jd_10bin);    % sog max dev in ship speed
        ship_avg_10.hed_max = interval_max_var(ship_day.jd, unwrap(ship_day.hed*d2r), jd_10bin)*r2d;    % sog max dev in ship speed
        ship_avg_10.cog_max = interval_max_var(ship_day.jd, unwrap(ship_day.cog*d2r), jd_10bin)*r2d;    % sog max dev in ship speed
        
        ship_avg_10.wspd_max = interval_max_var(ship_day.jd, ship_day.wspd, jd_10bin);
        ship_avg_10.wspd_min = interval_min_var(ship_day.jd, ship_day.wspd, jd_10bin);
        ship_avg_10.wspd_std = interval_std_var(ship_day.jd, ship_day.wspd, jd_10bin);
        ship_avg_10.wdir_max = interval_max_var(ship_day.jd, ship_day.wdir, jd_10bin);
        ship_avg_10.wdir_min = interval_min_var(ship_day.jd, ship_day.wdir, jd_10bin);
        ship_avg_10.wdir_std = interval_std_var(ship_day.jd, ship_day.wdir, jd_10bin);
    
        ship_avg_10.rdir_std = interval_std_var(ship_day.jd, unwrap(ship_day.rdir*d2r), jd_10bin)*r2d;
        ship_avg_10.rspd_std = interval_std_var(ship_day.jd, ship_day.rspd, jd_10bin);
        
        %%% Do 1-min stats too... shouldn't these be done with high-res data?
        %%% Does it matter? 
        
        ship_avg.sog_std = interval_std_var(ship_day.jd, ship_day.sog, jd_1bin);    
        ship_avg.hed_std = interval_std_var(ship_day.jd, unwrap(ship_day.hed*d2r), jd_1bin)*r2d;   
        ship_avg.cog_std = interval_std_var(ship_day.jd, unwrap(ship_day.cog*d2r), jd_1bin)*r2d;   
        ship_avg.ched_std = interval_std_var(ship_day.jd, sin(ship_day.hed*d2r), jd_1bin);    % cosine of heading, in radians
        ship_avg.shed_std = interval_std_var(ship_day.jd, cos(ship_day.hed*d2r), jd_1bin);    % sine of heading, in radians
    
        ship_avg.sog_min = interval_min_var(ship_day.jd, ship_day.sog, jd_1bin);    
        ship_avg.hed_min = interval_min_var(ship_day.jd, unwrap(ship_day.hed*d2r), jd_1bin)*r2d;    
        ship_avg.cog_min = interval_min_var(ship_day.jd, unwrap(ship_day.cog*d2r), jd_1bin)*r2d;   
        
        ship_avg.sog_max = interval_max_var(ship_day.jd, ship_day.sog, jd_1bin);   
        ship_avg.hed_max = interval_max_var(ship_day.jd, unwrap(ship_day.hed*d2r), jd_1bin)*r2d;   
        ship_avg.cog_max = interval_max_var(ship_day.jd, unwrap(ship_day.cog*d2r), jd_1bin)*r2d;   
        
        ship_avg.wspd_max = interval_max_var(ship_day.jd, ship_day.wspd, jd_1bin);
        ship_avg.wspd_min = interval_min_var(ship_day.jd, ship_day.wspd, jd_1bin);
        ship_avg.wspd_std = interval_std_var(ship_day.jd, ship_day.wspd, jd_1bin);
        ship_avg.wdir_max = interval_max_var(ship_day.jd, ship_day.wdir, jd_1bin);
        ship_avg.wdir_min = interval_min_var(ship_day.jd, ship_day.wdir, jd_1bin);
        ship_avg.wdir_std = interval_std_var(ship_day.jd, ship_day.wdir, jd_1bin);   
        
        ship_avg.rdir_std = interval_std_var(ship_day.jd, unwrap(ship_day.rdir*d2r), jd_1bin)*r2d;
        ship_avg.rspd_std = interval_std_var(ship_day.jd, ship_day.rspd, jd_1bin);
       
        % rest of ship met and nav data
        lat_s_10 = ship_avg_10.lat;
        lon_s_10 = ship_avg_10.lon;
        sog_s_10 = sqrt(ship_avg_10.sogN.^2 + ship_avg_10.sogE.^2);  % recompute sog from speed components
        cog_s_10 = atan2(ship_avg_10.sogE, ship_avg_10.sogN)*r2d;  % recompute cog from speed components
        cog_s_10 = mod(cog_s_10 + 360, 360);
        ship_avg_10.cog = cog_s_10; % replace with updated 1-min cog/sog
        ship_avg_10.sog = sog_s_10;
        hedE_s_10 = ship_avg_10.hedE;
        hedN_s_10 = ship_avg_10.hedN;
        hed_s_10 = atan2(hedE_s_10, hedN_s_10)*r2d; % recompute avg hed from avg N/E components
        hed_s_10 = mod(hed_s_10 + 360, 360);
        ship_avg_10.hed = hed_s_10; % replace with updated 1-min hed
        
        rh_s_10 = ship_avg_10.rh; % rh
        ta_s_10 = ship_avg_10.ta; % air t
        psealevel_s_10 = ship_avg_10.psealevel; % psealevel
        pa_at_zq_s_10 = psealevel_s_10 - (0.125*zq_ship); % 
        ship_avg_10.pa = psealevel_s_10 - (0.125*zp_ship); % p measured
        sw_dn_s_10 = ship_avg_10.sw_dn; % solar radiation
        lw_dn_s_10 = ship_avg_10.lw_dn; % ir radiation
        qa_s_10 = qair_p(ta_s_10, rh_s_10, pa_at_zq_s_10); % spec humidity
        ship_avg_10.qa = qa_s_10;
        
        % air density (kg/m3) and h2o number density (mmol/m3)
        rhoa_s_10 = air_density(ta_s_10,pa_at_zq_s_10,rh_s_10);
        h2o_s_10 = qa_s_10.*rhoa_s_10/0.018016;
        ship_avg_10.rhoa = rhoa_s_10;
        ship_avg_10.h2o = h2o_s_10;
        
        [rspd_s_10,rdir_s_10] = uv_to_sd(ship_avg_10.rUn, ship_avg_10.rUw); 
        rdir_s_10(rdir_s_10>180) = rdir_s_10(rdir_s_10>180)-360;    % +/- 180 deg format
        %%% use same rUn and rUw components, and the recently recalculated 10-min avgs of hed, sog, cog, to do 10-min true wind
%         [wspd_s_10,wdir_s_10,Un_s_10,Uw_s_10] = uv_rel_to_sd_true(ship_avg_10.rUn,ship_avg_10.rUw,ship_avg_10.hed,ship_avg_10.cog,ship_avg_10.sog);
%         ship_avg_10.wspd = wspd_s_10;
        ship_avg_10.rspd = rspd_s_10;
%         ship_avg_10.wdir = wdir_s_10;
        ship_avg_10.rdir = rdir_s_10;
%         ship_avg_10.Un = Un_s_10;
%         ship_avg_10.Uw = Uw_s_10;
        [ship_avg_10.wspd,ship_avg_10.wdir] = uv_to_sd(ship_avg_10.Un, ship_avg_10.Uw); 


        [rspd2_s_10,rdir2_s_10] = uv_to_sd(ship_avg_10.rUn2, ship_avg_10.rUw2); 
        rdir2_s_10(rdir2_s_10>180) = rdir2_s_10(rdir2_s_10>180)-360;    % +/- 180 deg format
        %%% use same rUn and rUw components, and the recently recalculated 10-min avgs of hed, sog, cog, to do 10-min true wind
%         [wspd2_s_10,wdir2_s_10,Un2_s_10,Uw2_s_10] = uv_rel_to_sd_true(ship_avg_10.rUn2,ship_avg_10.rUw2,ship_avg_10.hed,ship_avg_10.cog,ship_avg_10.sog);
%         ship_avg_10.wspd2 = wspd2_s_10;
        ship_avg_10.rspd2 = rspd2_s_10;
%         ship_avg_10.wdir2 = wdir2_s_10;
        ship_avg_10.rdir2 = rdir2_s_10;
%         ship_avg_10.Un2 = Un2_s_10;
%         ship_avg_10.Uw2 = Uw2_s_10;   
        [ship_avg_10.wspd2,ship_avg_10.wdir2] = uv_to_sd(ship_avg_10.Un2, ship_avg_10.Uw2); 

        [rspd3_s_10,rdir3_s_10] = uv_to_sd(ship_avg_10.rUn3, ship_avg_10.rUw3); 
        rdir3_s_10(rdir3_s_10>180) = rdir3_s_10(rdir3_s_10>180)-360;    % +/- 180 deg format
        %%% use same rUn and rUw components, and the recently recalculated 10-min avgs of hed, sog, cog, to do 10-min true wind
%         [wspd3_s_10,wdir3_s_10,Un3_s_10,Uw3_s_10] = uv_rel_to_sd_true(ship_avg_10.rUn3,ship_avg_10.rUw3,ship_avg_10.hed,ship_avg_10.cog,ship_avg_10.sog);
%         ship_avg_10.wspd3 = wspd3_s_10;
        ship_avg_10.rspd3 = rspd3_s_10;
%         ship_avg_10.wdir3 = wdir3_s_10;
        ship_avg_10.rdir3 = rdir3_s_10;
%         ship_avg_10.Un3 = Un3_s_10;
%         ship_avg_10.Uw3 = Uw3_s_10;   
        [ship_avg_10.wspd3,ship_avg_10.wdir3] = uv_to_sd(ship_avg_10.Un3, ship_avg_10.Uw3); 


        end
    
    %% 10 min PSL data 
    % 10-min PSL gps, sog, cog from 1-Hz data
    gprm10 = interval_avg(gprm(:,1), gprm(:,2:7), jd_10bin); % average everything
    sogN_10 = gprm10(:,4); % ship speed toward N
    sogE_10 = gprm10(:,5); % ship speed toward W
    lat_10 = gprm10(:,6);
    lon_10 = gprm10(:,7);
    sog_10 = sqrt(sogN_10.^2 + sogE_10.^2);  % sog from speed components from GPS
    cog_10 = atan2(sogE_10, sogN_10)*r2d; % cog from speed components from GPS
    cog_10 = mod(cog_10 + 360, 360); % cog fom GPS
      
    %%% these are redone with 10 Hz data in motcorr, so are commented out
%     cog_std_10 = interval_std_var(gprm(:,1),unwrap(gprm(:,2)*d2r),jd_10bin)*r2d;
%     sog_std_10 = interval_std_var(gprm(:,1),gprm(:,3),jd_10bin);
%     cog_std = interval_std_var(gprm(:,1),unwrap(gprm(:,2)*d2r),jd_1bin)*r2d;
%     sog_std = interval_std_var(gprm(:,1),gprm(:,3),jd_1bin);
    
    % 10-min PSL heading from 1Hz raw data
    hedm10 = interval_avg(hedm(:,1), hedm(:,2:5), jd_10bin); % average everything
    hedN_10 = hedm10(:,4);
    hedE_10 = hedm10(:,5);
    hed_10 = atan2(hedE_10, hedN_10)*r2d; % recompute hed from avg N/E components
    hed_10 = mod(hed_10 + 360, 360);
    hedm10(:,2) = hed_10; % replace with updated 10-min hed
    
    %%% these are redone with 10 Hz data in motcorr, so are commented out
%     hed_std_10 = interval_std_var(hedm(:,1), unwrap(hedm(:,2)*d2r), jd_10bin)*r2d;   
%     hed_std = interval_std_var(hedm(:,1), unwrap(hedm(:,2)*d2r), jd_1bin)*r2d;   
    
    pitch_10 = hedm10(:,3); % this is at 1 min
    ii_10 = find(isnan(pitch_10)); 
    pitch_10(ii_10) = nanmean1(pitch_10);

%     % Another way to do the 10-min heading from 1 Hz components, used in motcorr
%     heading_interp = replace_NaN_nearest_neighbor(hed(:,2)*d2r);  % to radians
%     heading = heading_interp;
%     shed = sin(heading);    
%     ched = cos(heading);
%     ched = interval_avg(hed(:,1), ched, jd_10bin);
%     shed_avg = interval_avg(hed(:,1), shed, jd_10bin);
%     [hed_avg,~] = cart2pol(ched(:,2), shed_avg(:,2));
%     hed_avg = hed_avg*r2d;
%     hed_avg = mod(hed_avg+360, 360);
 
    % 10-min PSL met data from 1 Hz data
    metm10 = interval_avg(metm(:,1), metm(:,2:end), jd_10bin);
    ta_10 = metm10(:,2);
    rh_10 = metm10(:,3);
    tsnk_10 = metm10(:,4); 
    sw_dn_1_10 = metm10(:,5); % should be positive. 
    lw_dn_1_10 = metm10(:,6); % should be positive.
    sw_dn_2_10 = metm10(:,7); % should be positive. 
    lw_dn_2_10 = metm10(:,8); % should be positive.
    lw_case_t_1_10 = metm10(:,9);
    lw_dome_t_1_10 = metm10(:,10);
    lw_case_t_2_10 = metm10(:,11);
    lw_dome_t_2_10 = metm10(:,12);
    org_10 = metm10(:,13);
    psealevel_10 = metm10(:,14);  % sea level press
    pa_at_zq_10 = psealevel_10-(0.125*zq);
    pa_10 = psealevel_10-(0.125*zp);  % measured press
    aspir_trh_10 = metm10(:,15);
    lw_therm_1_10 = metm10(:,18); % should be measured as negative value. If not, flip sign.
    lw_therm_2_10 = metm10(:,19); % should be measured as negative value. If not, flip sign.
    qa_10 = qair_p(ta_10,rh_10,pa_at_zq_10);
    qsnk_10 = qsea_p(tsnk_10,psealevel_10);
    % air density (kg/m3) and h2o number density (mmol/m3)
    rhoa_10 = air_density(ta_10,pa_at_zq_10,rh_10); 
    h2o_10 = qa_10.*rhoa_10/0.018016;

    % recalculate ORG 10 min from 1 min org data QC'd above
    if all(isnan(org_10)); org_10 = 0; end
    org_10_recalc = interval_avg_var(metm(:,1), org_recalc, jd_10bin);
    org_10_recalc(org_10_recalc<0.05) = 0;  % set lower limit on org rain rate sensitivity
    prate_10 = org_10_recalc;
    prate_10(isnan(org_10_recalc) == 1) = 0; % reset nan to 0
    temp = prate_10;
    temp(isnan(temp)) = 0;
    paccum_10 = cumsum(temp)/6; % 6 X 10 min segments per hour

    orgV_bkgd_10    = nanmedian1(despike2(interval_avg_var(metm(:,1), metm(:,17), jd_10bin))); % single value
    orgV_adj_10     = 0.06484 - orgV_bkgd_10; % single value
    orgV_10         = interval_avg_var(metm(:,1), metm(:,17), jd_10bin); 
    orgV_desp_10    = despike2(interval_avg_var(metm(:,1), metm(:,17), jd_10bin));
    prate_orig_10   = interval_avg_var(metm(:,1), metm(:,13), jd_10bin);

    % compute 10-min PSL winds from sonic 10Hz
    sonm10 = interval_avg(sonm(:,1), sonm(:,2:end), jd_10bin); % average everything
    tsonic_10 = sonm10(:,5);
    
    % Apply flow distortion corrections for mean spd, using ship heading for corrections
    % increases wind speed for bow-on winds and decreases wind speed for
    % cross-ship winds. Agrees with results we have and from other ships. 
    [rspd_10,rdir_10] = uv_to_sd(sonm10(:,2)/0.95,sonm10(:,3)/1.15);
    rdir_10(rdir_10>180) = rdir_10(rdir_10>180)-360; % +/- 180 deg format
    [wspd_10,wdir_10,Un_10,Uw_10] = uv_rel_to_sd_true(sonm10(:,2)/0.95,sonm10(:,3)/1.15,hed_10,cog_10,sog_10);

    %% other met data at 10-min

    % 10-min PSL licor
    licm10 = interval_avg(licm(:,1), licm(:,2:end), jd_10bin);

    % 10-min wxt met 
    if have_wxt_data == 1
        wxt10 = interval_avg(wxtm(:,1), wxtm(:,2:9), jd_10bin);      % average everything
        rUn_wxt_10 = wxt10(:,8);
        rUw_wxt_10 = wxt10(:,9);
        [rspd_wxt_10,rdir_wxt_10] = uv_to_sd(rUn_wxt_10,rUw_wxt_10); % recompute wspd/wdir with cog, sog, hed (which WXT doesn't do in its reader, since it doesn't measure it)
        rr = rdir_wxt_10>180; 
        rdir_wxt_10(rr) = rdir_wxt_10(rr)-360; % +/- 180 deg format
        [wspd_wxt_10,wdir_wxt_10,Un_wxt_10,Uw_wxt_10] = uv_rel_to_sd_true(wxt10(:,8),wxt10(:,9),hed_10,cog_10,sog_10);
        ta_wxt_10 = wxt10(:,4);
        rh_wxt_10 = wxt10(:,5);
        pa_wxt_10 = wxt10(:,6);
        qa_wxt_10 = qair_p(ta_wxt_10, rh_wxt_10, pa_wxt_10); % spec humidity
        % air density (kg/m3) and h2o number density (mmol/m3)
        rhoa_wxt_10 = air_density(ta_wxt_10,pa_wxt_10,rh_wxt_10);
        h2o_wxt_10 = qa_wxt_10.*rhoa_wxt_10/0.018016;
        psealevel_wxt_10 = pa_wxt_10+0.125*zwxt;
        prate_wxt_10 = wxt10(:,7);  % mm/hr
        prate_wxt_10(isnan(prate_wxt_10) == 1) = 0; % reset nan to 0
        temp = prate_wxt_10;
        temp(isnan(temp)) = 0;
        paccum_wxt_10 = cumsum(temp)/6; % 6 X 10 min segments per hour
    end
    %% 10-min licor h2o and co2 statistics: 6x5 array output
    % stats are for 'all' data, not screened for bad agc
    % 1 jd_ref, 2 Licor_h2o(mmol/m3), 3 Licor_T(C), 4 Licor_P(kpa), 5 agc
    lic_10_jd = licm10(:,1);

    licor_h2o_10 = licm10(:,2); % Licor_H20, WV density, mmol/m3 
    licor_tbox_10 = licm10(:,3); % Licor box T, C
    licor_pbox_10 = licm10(:,4); % Licor box pa, kPa
    licor_agc_10 = licm10(:,5); % Licor agc, mean diagnostic value
    licor_co2_10 = licm10(:,6); % Licor co2, density, mmol/m3

    % there are SO many bad values in Tbox and pbox. They correspond to bad
    % values in co2 but not h2o, q, or rhoa...
%     licor_Tbox_10(licor_Tbox_10 > 40) = nan;
%     licor_pbox_10(licor_pbox_10*10 > 1030) = nan; 
    
    %%% these are redone with 10 Hz data in motcorr, so are commented out
%     licor_h2o_std_10 = interval_std_var(licm(:,1), licm(:,2), jd_10bin); % standard deviation of Licor h2o, mmol/m3
%     licor_pbox_std_10 = interval_std_var(licm(:,1), licm(:,4), jd_10bin); % standard deviation of Licor box pa, kPa

    licor_h2o_mr_10 = (licor_h2o_10*1e-3).*Rgas_universal.*(ta_10+C2K)./(pa_at_zq_10*1e3); % WV mr converted from mmol/m3 to mol water / mol dry air
    licor_rhoa_dry_10 = (pa_at_zq_10*1e3).*(1-licor_h2o_mr_10*(1-epsilon))./(Rgas.*(ta_10+C2K)); % dry air density in licor [kg/m3]... conserved
    licor_qa_dry_10 = (licor_h2o_10*1e-3).*Mw./licor_rhoa_dry_10; % mmol/m3 to g/kg dry air only
    licor_qa_10 = (licor_h2o_10*1e-3).*Mw./rhoa_10; % mmol/m3 to g/kg moist air mix
    licor_co2_mr_10 = (licor_co2_10*1e3).*Rgas_universal.*(ta_10+C2K)./(pa_at_zq_10*1e3); % C02 mr converted from mmol/m3 to ppm... micromol C02 / mol dry air
    licor_rh_10 = relhum([ta_10,licor_qa_10,pa_at_zq_10]);

    %%% quality control licor data based on agc. Good value where agc < 60
    % note: the high frequency licor data are used in computing eddy
    % covariance and inertial dissipation latent heat flux in motcorr
    % program. These means are not used later. They are just here for
    % reference.
    wh_good_licor_10 = find(licor_agc_10 < 60);
    wh_bad_licor_10 = find(licor_agc_10 >= 60);
    licor_rhoa_dry_10(wh_bad_licor_10) = nan; % kg / m3
    licor_qa_dry_10(wh_bad_licor_10) = nan; % g / kg
    licor_qa_10(wh_bad_licor_10) = nan; % g / kg
    licor_h2o_10(wh_bad_licor_10) = nan;  % mmol/m3
    licor_h2o_mr_10(wh_bad_licor_10) = nan;  % mol/mol
    licor_co2_10(wh_bad_licor_10) = nan;  % mmol/m3
    licor_co2_mr_10(wh_bad_licor_10) = nan;  % micromol/m3 or ppm
    licor_tbox_10(wh_bad_licor_10) = nan; % C
    licor_pbox_10(wh_bad_licor_10) = nan; % kPa
    

    %% Bulk met data and surface fluxes for now

    if have_ship_data == 1
    %%% for PISTON, choose TSG2 for now
        tsea_10 = ship_avg_10.tsea;
        ssea_10 = ship_avg_10.ssea;
    else
        tsea_10 = tsnk_10*nan;
        ssea_10 = tsnk_10*nan;    
    end
        
    % tentatively choose the 1st PIR and PSP for first round of fluxes
    lw_dn_10 = lw_dn_1_10;
    sw_dn_10 = sw_dn_1_10;
    lw_dn = lw_dn_1;
    sw_dn = sw_dn_1;
    
    lw_dn_std_10 = interval_std_var(jd_1min, lw_dn, jd_10bin);
    sw_dn_std_10 = interval_std_var(jd_1min, sw_dn, jd_10bin);
    %%% lw and sw are not really offered at time intervals fast enough to
    %%% produce an accurate standard deviation. So, just interpolate the
    %%% 10-min down to 1-min. This has to be redone anyway later when the
    %%% corrections to the radiometers are completed in fixit.m
    lw_dn_std = interp1(jd_10min, lw_dn_std_10, jd_1min);
    sw_dn_std = interp1(jd_10min, sw_dn_std_10, jd_1min);

    
    %%% coare


    coare_psl = coare36vnWarm_et(jd_10min, wspd_10,zu,ta_10,zt,rh_10,zq,psealevel_10,tsnk_10,...
                     sw_dn_10,lw_dn_10,lat_10,lon_10, 600,prate_10,zsnk,...
                     ssea_10, nan, nan, 2, 2, 2);
                 

                 
cfields = {'usr';'tau';'hs';'hl';'hb';'hb_son';'hlwebb';'tsr';'qsr';'zo';'zot';'zoq';...
    'cd';'ch';'ce';'l';'zeta';'dt_skin';'dq_skin';'dz_skin';'u2';'ta2';'qa2';...
    'rh2';'u2n';'ta2n';'qa2n';'lw_net';'sw_net';'le';'rhoa';'un';'u10';'u10n';'cdn10';'chn10';'cen10';...
    'hrain';'qs';'erate';'ta10';'ta10n';'qa10';'qa10n';'rh10';'pa10';'rhoa10';'gust';'wc_frac';'edis';...
    'dt_warm';'dz_warm';'dt_warm_to_skin';'du_warm'};


    for i = 1:length(cfields)
        eval([cfields{i} '_10 = coare_psl(:,i);']);
        eval([cfields{i} ' = interp1(jd_10min,' cfields{i} '_10, jd_1min);' ]);
    end

    
    
    if have_ship_data == 1
        wspd_s_10 = ship_avg_10.wspd;
        coare_s = coare36vnWarm_et(jd_10min, wspd_s_10,zu_ship,ta_s_10,zt,rh_s_10,zq_ship,psealevel_s_10,tsea_10,...
                         sw_dn_s_10,lw_dn_s_10,lat_s_10,lon_s_10,600,prate_10,zsea_ship,...
                         ssea_10, nan, nan, 2, 2, 2);
              
        cfields_s = strcat(cfields,'_s');
        
        
        for i = 1:length(cfields)
            eval([cfields{i} '_s_10 = coare_s(:,i);']);
            eval([cfields{i} '_s = interp1(jd_10min,' cfields{i} '_s_10, jd_1min);' ]);
        end
    end
    
    %%% in case you want signs to be + heating ocean now, vs later... the code
    %%% right now doesn't flip the signs until save_nc.m
    %%% The bulk sensible, latent, and rain heat fluxes are defined + warming 
    %%% the atmosphere instead by COARE. 
    % flips = {'hs';'hl';'hrain'};
    % for k = 1:length(flips)
    %     eval([flips{k} ' = - ' flips{k} ';']);
    %     eval([flips{k} '_s = - ' flips{k} '_s;']);
    %     eval([flips{k} '_s_10 = - ' flips{k} '_s_10;']);
    %     eval([flips{k} '_10 = - ' flips{k} '_10;']);
    % end

    %% recalculate some fields using COARE output

    % interface
    tskin = tsnk + dt_warm_to_skin - dt_skin;
    tskin_10 = tsnk_10 + dt_warm_to_skin_10 - dt_skin_10;

    % this is redone in fixit.m once TSGs are checked
    % tskin_s = tsea + dt_warm_to_skin_s - dt_skin_s;
    % tskin_s_10 = tsea_10 + dt_warm_to_skin_s_10 - dt_skin_s_10;

    % recalculate upwelling radiative fluxes
    lw_up       = lw_net - lw_dn;
    lw_up_10    = lw_net_10 - lw_dn_10;
    sw_up       = sw_net - sw_dn;
    sw_up_10    = sw_net_10 - sw_dn_10;

    % net heat flux now that signs are all consistent: heating into the ocean
    hnet        = sw_net + lw_net - hs - hl - hrain;
    hnet_10     = sw_net_10 + lw_net_10 - hs_10 - hl_10 - hrain_10;
    
    grav = grv(lat);
    lapse=grav/cpa;
    dtheta = tskin - (ta + lapse*zt);
    
    grav_10 = grv(lat_10);
    lapse_10=grav_10/cpa;
    dtheta_10 = tskin_10 - (ta_10 + lapse_10*zt);
    
%     % potential temperature test of prior approximation in ta
%     p_tq = psealevel - 0.125*zt;
%     p_tq_10 = psealevel_10 - 0.125*zt;
%     theta0   = (tskin+C2K).*(1000./psealevel).^(Rgas/cpa);  
%     theta10  = (ta+C2K).*(1000./p_tq).^(Rgas/cpa);  
%     dtheta   = theta0 - theta10;
%     theta10_10 = (ta_10+C2K).*(1000./p_tq_10).^(Rgas/cpa);  
%     theta0_10  = (tskin_10+C2K).*(1000./psealevel_10).^(Rgas/cpa);  
%     dtheta_10  = theta0_10 - theta10_10;

    % tstar from sonic without humidity correction... the bulk value corrects 
    % for it automatically so we have to add it back in (tstr < 0 for SST > ta)
    tsr_son = tsr + 0.51*(ta+C2K).*qsr*1e-3;
    tsr_son_10 = tsr_10 + 0.51*(ta_10+C2K).*qsr_10*1e-3;

    %% BULK FRICTION VELOCITY
    if plot_checks == 1
        figure; plot(jd_10min, usr_10,'b','linewidth',1); xlabel('Hour (UTC)'); ylabel('u_*(m/s)'); xlim([ddd ddd+1]);
        title(sprintf('%s (%04i-%02i-%02i, DOY%03i).  PSL Friction Velocity from COARE algorithm',cruise_str,Vdate(1),Vdate(2),Vdate(3),ddd),'FontWeight','Bold','Interpreter','none');
        set(gca(gcf),'XTick',ddd:2/24:ddd+1);datetick('x','HH:MM','keepticks'); grid;
        xax = get(gca(gcf),'XTickLabel'); xax(end,:)='24:00'; set(gca(gcf),'XTickLabel',xax(:,1:2));
        annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL'},'FontSize',14,'FitBoxToText','off','LineStyle','none');
        if prtit
            ppath = fullfile(path_raw_images,'ustar',['Friction_Velocity_',sprintf('%04i_%02i_%02i_%03i',Vdate(1),Vdate(2),Vdate(3),ddd),graphformat]);
            print(graphdevice,ppath);
        end

        close all;
    end
    
    %% radiation models @ 1 and 10 min resolution
        
    if have_lat_data == 0
       lat = 12.25; lat_10 = 12.25;
       lon = 64.33; lon_10 = 64.33;
    end

        % Downward IR 10 min
        lw_dn_clr_10 = (0.52+0.13/60*abs(lat_10)+(0.082-0.03/60.*abs(lat_10)).*sqrt(qa_10)).*(5.67e-8*(ta_10+273.15).^4);
    
        % Downward IR 1 min
        lw_dn_clr = (0.52+0.13/60*abs(lat)+(0.082-0.03/60.*abs(lat)).*sqrt(qa)).*(5.67e-8*(ta+273.15).^4);
    
        % Solar model 10 min
        sw_dn_clr_10 = rs_clear(jd_10min,nanmean1(psealevel_10),qa_10,lat_10,lon_10,k1,k2,oz);
    
        % Solar model 1 min
        sw_dn_clr = rs_clear(jd_1min,nanmean1(psealevel),qa,lat,lon,k1,k2,oz);


    disp(['FINISHED evalflux.m ',cruise,' yearday ',sprintf('%03i',ddd),'.']);

    %% save daily 1- and 10-min data to matalb structures f and g

    %%% Do 1-min averages of 1-sec data, then put into daily structure. 
    %%% Do this for fields 3-end, so ignore t and jd since they'll be
    %%% handled separately here in this loop.
    clear a1 a10 
   
    % add these directly. The interval_avg times are centered on 30 sec marks.
    a1.jd    = jd_1min;
    a1.t     = t_1min;
    a10.jd   = jd_10min;
    a10.t    = t_10min;
         
    %%% if there is an issue with t, check rounding.
%     [yyyy, mmm, dd, HH, MM, SS] = datevec(to);
%     t = datenum(yyyy, mmm, dd, HH, roundn(MM,1), 0);

    if have_ship_data == 1
        % ship_vars are same for 1-min and 10-min averages (ship_avg and ship_avg_10)
        ship_avg_no_wind_cmps = rmfield(ship_avg,{'rUn';'rUw';'rUn2';'rUw2';'rUn3';'rUw3';'Un';'Uw';'jd';'t'});
        ship_vars = fields(ship_avg_no_wind_cmps);

        ship_vars_s = strcat(ship_vars,'_s');
        % save 1- and 10-min averages of ship data
        for i = 1:length(ship_vars_s)
            eval([ship_vars_s{i} ' = ship_avg.' ship_vars{i} ';']); 
            eval([ship_vars_s{i} '_10 = ship_avg_10.' ship_vars{i} ';']); 
        end
    end
    
    if have_wxt_data == 1
        wxt_vars = {'wspd_wxt';'wdir_wxt';'rspd_wxt';'rdir_wxt';...
                'ta_wxt';'qa_wxt';'rh_wxt';'rhoa_wxt';'h2o_wxt';...
                'prate_wxt';'paccum_wxt';'psealevel_wxt';'pa_wxt';...
                'rUn_wxt';'rUw_wxt'};
                % 'Un_wxt';'Uw_wxt';
    end
    
    % 1-min vars to save from PSL
    f_psl = {'lat';'lon';'ta';'tsonic';'tsnk';'tskin';'rh';'qa';'qsnk';...
            'psealevel';'pa';'rhoa';'h2o';'prate';'paccum';...
            'prate_orig';'orgV';'orgV_desp';...
            'sw_dn_1';'sw_dn_2';'lw_dn_1';'lw_dn_2';'sw_dn_clr';'lw_dn_clr';...
            'sw_dn_std';'lw_dn_std';...
            'lw_dome_t_1';'lw_case_t_1';'lw_dome_t_2';'lw_case_t_2';...
            'lw_dn';'lw_up';'sw_dn';'sw_up';...
            'lw_therm_1';'lw_therm_2';'wspd';'wdir';'rspd';'rdir';...
%             'wspd_raw';'wdir_raw';'rspd_raw';'rdir_raw';
            'sog';'cog';'sogE';'sogN';'hed';'hedE';'hedN';...
            'tskin';'aspir_trh';'pitch';...
            'licor_agc';'licor_rhoa_dry';'licor_qa';'licor_qa_dry';'licor_h2o';'licor_h2o_mr';...
            'licor_tbox';'licor_pbox';'licor_co2';'licor_co2_mr';'licor_rh';...
            'hnet';'lw_net';'sw_net';'dtheta';'tsr_son'};
%              'rUn';'rUw';'Un';'Uw';'rUn_raw';'rUw_raw';'Un_raw';'Uw_raw';...

                
    % add MET, ship, and coare fields (osl + ship) 
    if have_ship_data == 1 && have_wxt_data == 0
        f_fields = vertcat(f_psl, ship_vars_s, cfields, cfields_s);
    elseif have_ship_data == 0 && have_wxt_data == 1
        f_fields = vertcat(f_psl, cfields, wxt_vars);
    elseif have_ship_data == 0 && have_wxt_data == 0
        f_fields = vertcat(f_psl, cfields);
    end
    
    % save in structure
    for j = 1:length(f_fields)
        eval(['a1.(f_fields{j}) = ' f_fields{j} ';']);
        thisvar = a1.(f_fields{j});
        if length(thisvar) > 50
            eval(['a10.(f_fields{j}) = ' f_fields{j} '_10;']);
        else
           eval(['a10.(f_fields{j}) = ' f_fields{j} ';']);
        end
    end

    % organize structures for saving
    % put all variable names in alphabetical order;
    a1 = orderfields(a1);
    a10 = orderfields(a10);
    
    [a10.year, a10.month, a10.day, a10.hour, a10.minute] = datevec(a10.t);
    [a1.year, a1.month, a1.day, a1.hour, a1.minute] = datevec(a1.t);

    %% 1 min and 10 min File I/O  
    % base file name
    a1_name = [cruise '_1min_' sprintf('%02i%02i_jd%03i',Vdate(2),Vdate(3),ddd)];
    a10_name = [cruise '_10min_' sprintf('%02i%02i_jd%03i',Vdate(2),Vdate(3),ddd)];
    a1_mat = [path_proc_data '/v0_1min/' a1_name '.mat'];
    a10_mat = [path_proc_data '/v0_10min/' a10_name '.mat'];
    save(a1_mat,'a1');    
    save(a10_mat,'a10'); 
    fields_1 = fields(a1);
    fields_10 = fields(a10);
    n1 = length(fields_1);
    n10 = length(fields_10);
        
    % print to screen
    disp('');
    disp(['num vars in  1 min mat file: ' sprintf('%i',n1)]);
    disp(['num vars in 10 min mat file: ' sprintf('%i',n10)]);
    %%% save that in a text file manually and call it the header. 
    
    %% make plots of 1 and 10 min data

%     plot_eval_noship(a1, a10, path_prog, path_raw_images);
    plot_eval(a1, a10, path_prog, path_raw_images);
    
% %     if testing outside of program:
%     load('/Users/eliz/DATA/ASTRAL_2023/Revelle/flux/Processed/v0_1min/ASTRAL_2023_1min_0609_jd160.mat');
%     load('/Users/eliz/DATA/ASTRAL_2023/Revelle/flux/Processed/v0_10min/ASTRAL_2023_10min_0609_jd160.mat');
%     path_prog = '/Users/eliz/DATA/ASTRAL_2023/Revelle/Scientific_Analysis/programs';
%     path_raw_images = '/Users/eliz/DATA/ASTRAL_2023/Revelle/flux/Raw_Images';
%     plot_eval(a1, a10, path_prog, path_raw_images);

%     plot_eval_noship(a1, a10, path_prog, path_raw_images);

end %%% daily for loop

