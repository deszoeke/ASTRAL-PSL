%{
run_motcorr.m

Includes hl / hs computed with Simon's method (wpl_schotanus.m).

Driver script for the flux calculations

Fluxes are processed in 10-min segments.

This file and the associated read data functions generally require
project-specific editing and alterations.

The additional flux utility functions usually don't require
project-specific modifications.

Set run parameters in the first block below as desired.

V2: May 2015 with updated and vectorized code, BRB.
- Motion corrections are Edson98 only - Hare code removed. Integrate
angular rates and accelerations... it's complimentary filtering. It's
described in the paper. Laplace transforms. Time constant is clearly
defined. 
- co2 flux FROM LI 7500 is not computed.

V4 : TSONIC & Q_licor DECORRELATED W/ RESPECT TO 3-AXIS MOTION.

V5: ET cleaned things up and restructured order of operations for all
processing.

There used to be lags in data... lags are no longer used. The velocities were
coming out in live feed, and the corrections to measured velocities (from
sonic) raw velocity from sonic, are transformed to earth coords east,
north, vertical, and computed motions are subtracted off, and what shuold
be left if turbulence without any motion. in real time, I was watching uvw
plat be subtracted from uvw... so no more ship motions in velocity. What we
observed was.... sonic velocities with orbital motions from ship, and then
corrections, sum should be flat... but they weren't.... there was a day
with no wind but lots of swell... leaving monterey, lots of oscillations...
so knew corrections were not right, and the thing Chris noticed was that
they shuldb be going opposite sinusoids, but really they were just offset.
If you go through mat, you can show that if you add 2 sine waves offset in
phase, you'll get a harmonic, the first will be big, and it's just time
mismatched... latency in instrument input to output, then there is a
handshake between instrument and computer. And then by the time you get
through all that, there is no guarantee that latencies in uvw are same as
that in processing. Or there could be lags in processing due to filtering.
For whatever reason, it was eye-ball worthy to get better time worthy for
that cruise and that set of equipment by sliding time series of corrections
and actual met data relative to each other, maybe just 2-3 time
intervals... maybe 0.2 of a second or 0.02 second. But it made a big
difference because of ship motions and becaues signal was weak. So,
identifyed this issue taht we needed to match the time series... he was
just matching the corrections of t, q, and u vecotry from sonic. Initially
it was just uvw and motion correction. Once we identified that as a
problem, we started wondering in general what shuold we do. Jeff wrote
softwware to find the delays taht gave the max correlation. It was just
iterative. Then we went to a better way. There are a lot of problems to do
it this way.... need peak and signal for the correlation to even make
sense. We might have a different lag every hour. but that's probably
unnecssary because. We went through a period with RF modems instead of long
cables for every intsturment, and an entire bundle of them into ship, we
eliminated that by using RF modems, and we'd have to have 6 more on ship.
It turned out not to be a good solution, but it added another double
latency problem, and then latencies before and after... it was hard to make
those modems not lose data.  The first thing that happened is that you get
less data... drop outs... Then right when we got a bit better, they came
out with better ehternet servers. We couldn't find ones that could ensure
that no data was lost though. Then all the sudden they were available. Now
we can run 1-2 ethernet lines and boxes are ethernet servers. The latencies
are a lot lower. There are still latencies in instruments, but they are
better now, they used to have weird things. Data goes into buffer
somewhere, and instead of being pulled out syncronously it will fill up
buffer and pull over 10 values. Look at time stamp of when we aqcuire
values, they aren't necessarily all from that time. You assume that the
isntrument is outputing data uniformly but it's a buffer overload instead.
Then we look at time stamps, You run through this problem.. if you are
missing 100 points, is it because sonic is running slower than 10 Hz, then
it should be evenly spaced, or is it hung up on the modem/server, lost data
transmission for 5 tenths of a second. And you need to know that Dan Geotes
set up RF modems and also ran data with cables, at platteville, and worked
on data aqcuisiiont... and he's updated the data acquisition software about
5 times, tryign tot get it to latch data as fast as possible and time stamp
it so that ther eis no latency. Now it is very robust. If we lost data in
atomic, or if the data are irregular, 10 values short, instead of 360000,
would assume it was because instrument was runnign slow, not cables. You
can plot time series and see if there are gaps. Times also used to slip
backwards, and that was a time sync... like SPURS-2. We used to collect all
data on same computer, so time syncing wasn't an issue. but once you sync
times from several instruemnts. PC computer times used to slip a minute a
day, terrible, then you could sync your computer to gps computer, and there
was a way to sync to network. But the network may be unbenownst to you sync
every 5 min, so the clock sync was running fast and would set it. When you
start cross correlating things, every thing that you are cross correlating
has to be time matched. We tried to solve problems and created more, then
we got it all figured out. We probably sync once a day. We don't aquire
data while we are doing the clock sync. We used to not sync the flux
computer to the ship. One was ship's network and one was not. They were on
their own local networks. so they could transfer data between them by
writing discs. The DA computer sat there and ran, but did no processing,
that way you could do matlab on it withuot bogging it down. And never lost
data in archiving. so the way it worked is the non DAQ computer woudl pull
data over on other computer, and then... So in the recent years, we haven't
been doing processing on that computer, we sit in lab with laptops, we use
sneakernet or flash drives. We had reliability issues so that's why we had
2 computers. All the DAQ programs and data... would have motherboard, we
still do lag calculations for chemistry... we have to know the lag to cross
correlate with the chemistry.. ther's a tube on mast, we insert a test gas
and measure the lag directly. Byron was doing that on mosaic. Same if you
are doign it with water samples. BUt to do DMS flux... you ahve to cross
correlate the spectrum of velocity and DMS, you have to slide time series.
You have strong signals you can use xcorr and find the peak. but in
chemistry, you don't see peaks, so looking for peak is not possible. Need
to measure lag directly in that case. 
memory failures, the serial interface would fail, the ethernet would fai 

beware matlab xcorr just splices out NaNs, if you have them. Not good for
finding lags.
%}

%% Initialize run parameters
close all;
fclose all;
clear;
warning ('off','MATLAB:MKDIR:DirectoryExists');
setup_cruise;

% Dates: ASTRAL 2024
% stjd = 119; endjd = 134; % leg 1
% stjd = 139; endjd = 161; % leg 2
stjd = 160; endjd = 160;

[data_drive, path_prog, ship] = setpaths(); % system specific paths

% matlab script path
restoredefaultpath
cd(fullfile(path_prog,'flux'));
addpath(genpath(fullfile(path_prog,'flux')));
rehash toolboxcache;

%% types of processing: motion corrected or not, using WXT or not
use_wxt = 0;
sens_sep_factor = 1.0; % this was 1.045 in a prior set up... not sure what is best here. 
decorr = true;      % set true decorrelate winds & motion...
if decorr
    dcname = 'decorr';
else
    dcname = 'std';
end

% decide to make plots of motion correction
plotit = 1;

%% build paths relative to data_drive
% these and subsequent path constructs are OS-independent due to use of fullfile()
% these first 3 paths should be preexisting
path_raw_data_flux = fullfile(data_drive,cruise,ship,'flux','Raw');
path_proc_data_flux = fullfile(data_drive,cruise,ship,'flux','Processed','legacy','decorr');
path_proc_images_flux = fullfile(data_drive,cruise,ship,'flux','Processed_Images');

path_output = fullfile(data_drive,cruise,ship,'flux','Processed','motcorr');
mkdir(path_output);

% subdirectory for saving daily met/flux plots
path_dailyPlots = fullfile(path_proc_images_flux,['Daily_',dcname]);
mkdir(path_dailyPlots);
mkdir(fullfile(path_dailyPlots,'Motion_Tilt'));
mkdir(fullfile(path_dailyPlots,'Rel_Wind'));
mkdir(fullfile(path_dailyPlots,'Heat_Fluxes'));
mkdir(fullfile(path_dailyPlots,'Stress'));
mkdir(fullfile(path_dailyPlots,'True_Wind'));
mkdir(fullfile(path_dailyPlots,'Stars'));
mkdir(fullfile(path_dailyPlots,'Vars'));
% subdirectory for saving corrected wind timeseries plots
path_windPlots = fullfile(path_proc_images_flux,['WindPlots_',dcname]);
mkdir(path_windPlots);
mkdir(fullfile(path_windPlots,'motcorr_segment'));
mkdir(fullfile(path_windPlots,'uvw'));
% subdirectory for saving corrected wind spectra plots
path_spectraPlots = fullfile(path_proc_images_flux,['SpectraPlots_',dcname]);
mkdir(path_spectraPlots);
mkdir(fullfile(path_spectraPlots,'q_spectrum'));
mkdir(fullfile(path_spectraPlots,'t_spectrum'));
mkdir(fullfile(path_spectraPlots,'uv_spectrum'));
mkdir(fullfile(path_spectraPlots,'w_spectrum'));
mkdir(fullfile(path_spectraPlots,'wq_cospectrum'));
mkdir(fullfile(path_spectraPlots,'wt_cospectrum'));
mkdir(fullfile(path_spectraPlots,'wu_cospectrum'));
% subdirectory for saving corrected wind data
path_uvwStreamData = fullfile(path_proc_data_flux,['uvwStream_',dcname]);
mkdir(path_uvwStreamData);
% subdirectory for saving motion data
path_motionData = fullfile(path_proc_data_flux,['motion_',dcname]);
mkdir(path_motionData);
% subdirectory for saving hourly da files
path_da = fullfile(path_proc_data_flux,['da_',dcname]);
mkdir(path_da);
% subdirectory for saving hourly sp files
path_sp = fullfile(path_proc_data_flux,['sp_',dcname]);
mkdir(path_sp);
% subdirectory for saving hourly cr files
path_cr = fullfile(path_proc_data_flux,['cr_',dcname]);
mkdir(path_cr);
% subdirectory for saving hourly lag times
path_lag = fullfile(path_proc_data_flux,['lag_',dcname]);
mkdir(path_lag);
% subdirectory for saving hourly decorr coefs
path_mu = fullfile(path_proc_data_flux,['mu_',dcname]);
mkdir(path_mu);
mkdir(fullfile(path_mu,'w_Ts'));
mkdir(fullfile(path_mu,'q'));
% initialize plot format
graphformat = '.png';  % select graphics format
graphdevice = '-dpng'; % select graphic device


%% other ship data
% load corrected 10-min data from manualflux_eval, cat_mats, fix_met_sea
in_version = 'v2'; % v2 for Jan 2022 tests

% v1 corrected met sea flux nav data
indir = [data_drive cruise '/' ship '/flux/Processed/' in_version '/'];
infile_10 = [indir cruise '_10min_nav_met_sea_flux_' in_version '.mat'];
load(infile_10);
infile_1 = [indir cruise '_1min_nav_met_sea_flux_' in_version '.mat'];
load(infile_1);

parens = @(x,i) x(i)

%% ----------Main loop----------
for ddd=stjd:endjd  % iterate over days
    [m,d] = yd2md(yr, ddd);
    Vdate = [yr m d];
    jd_str = sprintf('%03i',ddd);

    % empty output arrays for daily results: rows 144 = 24 x 6 per hr
    % except for sp, file formats compatible with older flux code
    % no Hare correction spectra in this version.
    num_vars = 186;
%     da = NaN(144,num_vars); % legacy. Now in da_red.m program so that it saves the entire cruise
%     sp = NaN(144,481); % legacy. Noa in da_red.m program so that it saves the entire cruise
%     cr = NaN(144,17); % legacy. Now in da_red.m program so that it saves the entire cruise
    lag = NaN(24,2); lag(:,1) = ddd:1/24:ddd+1-1/24;
    mu_decorr = NaN(144,17); mu_decorr(:,1) = ddd:10/1440:ddd+1-10/1440;
    mu_q_decorr = NaN(144,13); mu_q_decorr(:,1) = ddd:10/1440:ddd+1-10/1440;
    
    hr_start = 0;
    hr_end = 23;

    for hhh = hr_start : hr_end   % iterate over hours
        %% read raw data files...
        label_st = [cruise '_' sprintf('%02i%02i_', m, d) jd_str graphformat];
        d_str = sprintf('%02i%02i', m, d);
        
        hr_str = sprintf('%02i',hhh);
            
        % read motion file
        dfl = fullfile(path_raw_data_flux,[yr_st(3:4),jd_str],['mot0' yr_st(3:4),jd_str,hr_str,'_raw.txt']);
        mot = read_motion_real(dfl,ddd,hhh);

        % read sonic file
        % % missing data are negative when more data are recovered in that
        % hour than expected
        dfl = fullfile(path_raw_data_flux,[yr_st(3:4),jd_str],['son0',yr_st(3:4),jd_str,hr_str,'_raw.txt']);
        [son,badSon,missingSon] = read_sonic(dfl,ddd,hhh,sonicmodel,rotationsonic);
        badSon = badSon(:); % # NaNs in raw file (water or ice on transducers, etc.)
        missingSon = missingSon(:); % # missingSon data points in raw file - timestamp gaps... can be negative if more data points are recovered than expected
        xxx = missingSon>100 | badSon>100;  % find bad sonic data... it'll either be a pretty small number (3-10) or a huge number (way over 100)
        
        % read gprm file - PYTHON processed output from raw Hemosphere gps file
        dfl = fullfile(path_raw_data_flux,[yr_st(3:4),jd_str],['gprm',yr_st(3:4),jd_str,hr_str,'_raw.txt']);
        gps = read_gprm(dfl,ddd,hhh,PosLims);

        % read Hemisphere heading and roll angle
        dfl = fullfile(path_raw_data_flux,[yr_st(3:4),jd_str],['hed0',yr_st(3:4),jd_str,hr_str,'_raw.txt']);
        hedf = read_hed_pitch(dfl,ddd,hhh);

        % read licor
        dfl = fullfile(path_raw_data_flux,[yr_st(3:4),jd_str],['lic0',yr_st(3:4),jd_str,hr_str,'_raw.txt']);
        lic = read_licor(dfl,ddd,hhh);

        %% copy out selected variables
        jd_10Hz = son(:,1);     % ref 10 Hz timestamp... could use for licor too.. same
        
        %% compute 10 Hz heading
        heading_interp_r = replace_NaN_nearest_neighbor(hedf(:,2)*d2r);  % to radians
        hed_10Hz_r = heading_interp_r;
        shed_10Hz = sin(hed_10Hz_r); 
        ched_10Hz = cos(hed_10Hz_r);
        
        % if for whatever reason our heading fails... fill with nans from
        % ship heading interpolated to 10 Hz. 
        hed_10Hz_b = interp1(b10.jd, b10.hed_s, jd_10Hz)*d2r;
        
        if ddd == 159 && hhh >=6 || hhh == 13 % ASTRAL
            bad_hed = find(isnan(hed_10Hz_r));
            if ~isempty(bad_hed)
                disp(['replacing nan in heading on day ' ddd ' hr ' hhh ' with ship heading interpolated to 10 Hz'])
                hed_10Hz_r(bad_hed) = hed_10Hz_b(bad_hed);
            end
        end
        
        %% E98  rfs corrections, with decorr if desired
        % NOTE: why we don't apply the wind speed-dependent or not flow
        % distortion corrections here too-- because only the fluctuations
        % matter... relative to each other... or because it's in ship reference frame
        % motcorr3 can handle missing heading because there is a check in it
        % before it runs angles.m, which adjusts the length of all the
        % arrays to still run properly.
        % use motcorr3, decorr in 10 min segments

        try
            % motcorr3_ok can't handle missings
            [uvw,tson_10Hz,accplat,uvwplat,xyzplat,euler,plat_rate,lagPnts,mu,uvw_raw,uvw_motcorr,f1,ff2] = ...
                motcorr3_ok(son,mot,hed_10Hz_r,sens_disp,fsonic,decorr);
        catch
            % doesn't crash for missing data

            [uvw,tson_10Hz,accplat,uvwplat,xyzplat,euler,plat_rate,lagPnts,mu,uvw_raw,uvw_motcorr,f1,ff2] = ...
                motcorr3(son,mot,hed_10Hz_r,sens_disp,fsonic,decorr);
        end
            % tson_10Hz isn't corrected for humidity cross talk because the
            % correction is more accurate at 10-min and with bulk values.
            % The correction is done later
            
        if ~all(isnan(uvw(:,1))) && plotit && (hhh==0 || hhh==6 || hhh==12 || hhh==18)
            ppath = fullfile(path_windPlots,'motcorr_segment',['uvw_motcorr','_',jd_str,'_',d_str,'_',hr_str,'_',dcname,graphformat]);
            print(f1,graphdevice,ppath);
            ppath = fullfile(path_windPlots,'uvw',['uvw_',jd_str,'_',d_str,'_',hr_str,'_',dcname,graphformat]);
            print(ff2,graphdevice,ppath);
            close all;
        else
            close all;
        end

        uvw = uvw';                    % uvw - Edson motcorr and decorr
        tson_10Hz = tson_10Hz';        % this is sonic temperature
        accplat = accplat';            % platform acc,vel and disp in earth frame
        uvwplat = uvwplat';
        xyzplat = xyzplat';
        euler = euler';
        plat_rate = plat_rate';
        uvw_raw = uvw_raw';            % sonic uvw rotated to earth frame
        uvw_motcorr = uvw_motcorr';    % uvw with Edson correction only
        lagmat = [son(1,1), lagPnts];  % saves high frequency time step of first segment and lagPnts, ...
                                       % how much the uvw was shifted. W and platform vertical
                                       % velocity shift uvw accordingly and sum with uvwplat
                                       % to correct winds

        %% correct uv for ship velocity
        uvw_str = uvw.*0;   % preallocate output arrays
        uvw_rot = uvw.*0;
        tilt = zeros(1,6);	% for saving tilt and azm this hr
        azm = zeros(1,6);

        % use filtered psl gps velocity @ 10 Hz for speed correction
        cog_10Hz = gps(:,2);
        sog_10Hz = gps(:,3);
        sogN_10Hz = gps(:,4);
        sogE_10Hz = gps(:,5);
        
        % first remove tilt
        % double rotation into streamlines over 10-min segs of 10Hz data
        ii=1;
        for jj=1:6
            [uvw_str(ii:ii+Npts-1,:),azm(jj),tilt(jj)] = dbl_rot(uvw(ii:ii+Npts-1,:));
            ii = ii + Npts;
        end
        % single-rotate azimuth ccw, back to earth coordinates
        ii = 1;
        for jj=1:6
            uvw_rot(ii:ii+Npts-1,:) = azm_rot(uvw_str(ii:ii+Npts-1,:),azm(jj),1);
            ii = ii + Npts;
        end

        % then sum with N/E ship speed components to remove platform velocity
        uvw_rot(:,1) = uvw_rot(:,1) + sogN_10Hz;
        uvw_rot(:,2) = uvw_rot(:,2) - sogE_10Hz;

        % finally compute new azimuth and rotate uv clockwise into streamlines
        % mean v & w should now be zero
        ii = 1;
        for jj=1:6
            azm2 = atan2(mean(uvw_rot(ii:ii+Npts-1,2)), mean(uvw_rot(ii:ii+Npts-1,1)));
            uvw_str(ii:ii+Npts-1,:) = azm_rot(uvw_rot(ii:ii+Npts-1,:),azm2,0);
            ii = ii + Npts;
        end
        disp(['mean W = ',num2str(mean(uvw_str(:,3)),'%3.2f'),'  mean V = ',num2str(mean(uvw_str(:,2)),'%3.2f')]);

        % add timestamp and sonicT to uvw_str array
        uvw_str = [jd_10Hz, uvw_str, tson_10Hz];
        clear uvw_rot

        %% compute and use 10-min statistics

        % Set up to process data in 10-min blocks
        jd_start = floor(son(1,1)*24)/24;   % start of hour
        jd_end = jd_start + 60/1440;        % start of next hour
        % 10-min bin edges
        jd_10bin = (jd_start:10.0/1440:jd_end)';
        jd_10min = jd_10bin(1:end-1);
        t_10min = datenum(yr,0,0,0,0,0) + jd_10min;
        % 1-min bin edges
        jd_1bin = (jd_start:1.0/1440:jd_end)';
        jd_1min = jd_1bin(1:end-1);
        t_1min = datenum(yr,0,0,0,0,0) + jd_1min;
  
        %%% load this 1-hour segment of mean corrected 10-min data. call it
        %%% "x" so that things don't get overwritten or confused yet. There
        %%% are a lot of variables already ending in a and b for different
        %%% flux methods, so stay away from a. and b. here
        these = find((b10.t >= t_10min(1)) & (b10.t <= t_10min(end)));
        these1 = find(b1.t >= t_1min(1) & b1.t <= t_1min(end));
        fields_f10 = fields(b10);
        nf = length(fields_f10);
        for k = 1:nf
           this = b10.(fields_f10{k});
           this1 = b1.(fields_f10{k});
           eval(['x.' fields_f10{k} ' = this(these);']); 
           eval(['x1.' fields_f10{k} ' = this1(these1);']); 
        end
        
        % 10-min heading
        ched = interval_avg_var(hedf(:,1), ched_10Hz, jd_10bin); % ched in radians
        shed = interval_avg_var(hedf(:,1), shed_10Hz, jd_10bin); % shed in radians
        ched_std = interval_std_var(hedf(:,1), ched_10Hz, jd_10bin); % ched in radians
        shed_std = interval_std_var(hedf(:,1), shed_10Hz, jd_10bin); % shed in radians
        
        [hed,~] = cart2pol(ched, shed);
        hed = hed*r2d;
        hed = mod(hed+360, 360);
        
        % 1-min heading
        ched_1 = interval_avg_var(hedf(:,1), ched_10Hz, jd_1bin); % ched in radians
        shed_1 = interval_avg_var(hedf(:,1), shed_10Hz, jd_1bin); % shed in radians
        ched_std_1 = interval_std_var(hedf(:,1), ched_10Hz, jd_1bin); % ched in radians
        shed_std_1 = interval_std_var(hedf(:,1), shed_10Hz, jd_1bin); % shed in radians
        
        [hed_1,~] = cart2pol(ched_1, shed_1);
        hed_1 = hed_1*r2d;
        hed_1 = mod(hed_1+360, 360);

        %% 10-min motion-corrected wind statistics: 6x5 array as follows:
        % 1:jd, 2:ustr, 3:vstr, 4:wstr, 5:tson
        uvwt_10min_avg = interval_avg(uvw_str(:,1), uvw_str(:,2:end),jd_10bin);
        uvwt_10min_std = interval_std(uvw_str(:,1), uvw_str(:,2:end),jd_10bin);
        uvwt_10min_avg(xxx,2:5) = NaN;
        uvwt_10min_std(xxx,2:5) = NaN;
        % define ubar, the streamwise true windspeed from Edson correction.
        % vbar and wbar should both be zero after rotation. Should be
        % equivalent to rspd... actual speed experienced at ship, that's
        % moving air by the anemometer and that's what creates the spectra
        ubar = uvwt_10min_avg(:,2);
        vbar = uvwt_10min_avg(:,3);
        wbar = uvwt_10min_avg(:,4);
        Tbar = uvwt_10min_avg(:,5);
        
        % 1-min std for computing 1-min variances
        uvwt_1min_std = interval_std(uvw_str(:,1), uvw_str(:,2:end),jd_1bin);
        
        % 10-min unrotated raw sonic wind averages: 6x5 array as follows:
        % 1:jd, 2:u, 3:v, 4:w, 5:tson
        son_10min_avg = interval_avg(jd_10Hz, son(:,2:end),jd_10bin);
        son_10min_avg(xxx,2:5) = NaN;
        uson_avg = son_10min_avg(:,2); % factor of 0.95 is applied when computing mean wind later
        vson_avg = son_10min_avg(:,3); % factor of 1.15 is applied when computing mean wind later
        wson_avg = son_10min_avg(:,4);
        tson_avg = son_10min_avg(:,5);

        %%% if 1 min computation was necessary... it's not
%         son_1min_avg = interval_avg(jd_10Hz, son(:,2:end),jd_1bin);
%         son_1min_avg(xxx,2:5) = NaN;
%         uson_avg_1 = son_1min_avg(:,2); % factor of 0.95 is applied when computing mean wind later
%         vson_avg_1 = son_1min_avg(:,3); % factor of 1.15 is applied when computing mean wind later
%         wson_avg_1 = son_1min_avg(:,4);
%         tson_avg_1 = son_1min_avg(:,5);
        
        % 10-min platform velocity std deviations: 6x4 array as follows:
        % 1:jd, 2:uplat, 3:vplat, 4:wplat
        plat_10min_std = interval_std(mot(:,1), uvwplat(:,:),jd_10bin);
        uplat_std = plat_10min_std(:,2);
        vplat_std = plat_10min_std(:,3);
        wplat_std = plat_10min_std(:,4);
        
        plat_1min_std = interval_std(mot(:,1), uvwplat(:,:),jd_1bin);
        uplat_std_1 = plat_1min_std(:,2);
        vplat_std_1 = plat_1min_std(:,3);
        wplat_std_1 = plat_1min_std(:,4);

        %% can this be skipped, because we do it in manual flux The only thing new is Un and Ue with 10-Hz heading info instead of 1-Hz avg.
        
        % compute psl true wind spd & dir from N/E sonic components
        % first, apply flow distortion correction to the raw wind speeds
        % but ignoring ship motion (no motcorr input).
        U = son(:,2)/0.86;  % +5% for head-on wind  
        V = son(:,3)/1.12;  % -15% for side-on wind  
        W = son(:,4);  % -15% for side-on wind  
        Un = zeros(6,1)*NaN; % empty arrays
        Ue = zeros(6,1)*NaN;
        W_10avg = zeros(6,1)*NaN;
        ii = 1;
        for jj=1:6
            % compute 10 min average vector wind speed, should be
            % equivalent to ubar.
            % puts data into earth coordinates N/S, E/W in average sense
            % pitch, roll, and heave area not accounted for. just ship
            % speed, heading, and cog
            % NOTE: Un and Ue are only used to recalculate wind, but this 
            % isn't the best way to do that either. We can just compute
            % them from wspd and wdir. e and n are earth frame. This might
            % have been used before but isn't the way we save it... it's
            % more jumpy because of the order of operations of averaging
            % and corrections... the way it's done in evalflux is better.
            % The main point of reading in the sonic data again is to get
            % std of rspd and rdir from 10 Hz, it seems
            Un(jj) = (nanmean1(U(ii:ii+Npts-1).*cos(hed_10Hz_r(ii:ii+Npts-1)) + ...
                    V(ii:ii+Npts-1).*shed_10Hz(ii:ii+Npts-1) + sogN_10Hz(jj)));
            Ue(jj) = (nanmean1(U(ii:ii+Npts-1).*sin(hed_10Hz_r(ii:ii+Npts-1)) - ...
                    V(ii:ii+Npts-1).*ched_10Hz(ii:ii+Npts-1) + sogE_10Hz(jj)));
            W_10avg(jj) = nanmean1(W(jj));
            wdir_new = atan2(-Ue, -Un)*r2d;
            wdir_new(wdir_new<0) = wdir_new(wdir_new<0)+360;
            wspd_new = sqrt(Un.^2 + Ue.^2); % don't need a w component here
            ii = ii + Npts;
        end

        % 10-min relative wind statistics
        % compute unwrapped rdir in radians
        rdir_10Hz = unwrap(atan2(son(:,3),-son(:,2))); 
        
        % average and convert to +/- 180 deg format
        rdir_new = interval_avg_var(jd_10Hz,rdir_10Hz,jd_10bin)*r2d;
        rdir_new = mod(rdir_new + 360, 360);
        rdir_new(rdir_new>180) = rdir_new(rdir_new>180) - 360;
        rdir_std = interval_std_var(jd_10Hz,rdir_10Hz,jd_10bin)*r2d;
        rdir_std_1 = interval_std_var(jd_10Hz,rdir_10Hz,jd_1bin)*r2d;
        
        % why isn't this bad sonic filtering used on winds in the evalflux
        % eval or fix_met_sea? Because it's assumed that 10-min averages
        % take care of it? But rain and bad data can last longer, and will
        % still affect the 1-min average too.
%         rdir_new(xxx) = NaN;  % 
%         rdir_std(xxx) = NaN;  % 
        
        % note: this is essentially the 10 min streamwise wind speed UNCORRECTED for ship velocity
        % wind speed should just be horizontal. If flow distortion is
        % converting vertical component into horizontal, then it might be
        % added. 
        rspd_raw = sqrt((uson_avg).^2 + (vson_avg).^2 + (wson_avg).^2); 
        rspd_new = sqrt((uson_avg/0.86).^2 + (vson_avg/1.12).^2 + wson_avg.^2); 
        rspd_new2 = sqrt((uson_avg/0.86).^2 + (vson_avg/1.12).^2); 

        % compute fast q from licor mmol/m3, using 10-min moist air
        % density. This is better than using 1-min rhoair perhaps because 
        % we are looking at 10-min covariance anyway. Using 1-min rhoair
        % could introduce more spectral artifacts than 10-min. They both
        % could do introduce artifacts though. We could test it in the future. 
        qa_10Hz_raw = NaN(Npts*6,1);
        ii=1;
        for jj=1:6
            % this is the correct q formula, using rhoa or dry+moist air. 
            % q is in units of kg/kg. 
            qa_10Hz_raw(ii:ii+Npts-1) = lic(ii:ii+Npts-1,2)*Mw/1000/x.rhoa(jj);
            ii = ii + Npts;
        end

        % apply mean correction from fixit? Does it matter? 
        qa_10Hz_raw = qa_10Hz_raw - 0.600969; % NOT ALREADY DONE??
        
        % decorrelate licor water vapor vars w/respect to 3-axis motion
        if decorr
            % old way that doesn't account for lags or mu_q
            % qa_10Hz = decorr_q(qa_10Hz_raw,uvwplat,mot(:,2:4)); 
            jd_bins = lic(1,1):10/1440:son(1,1)+60/1440; jd_bins = jd_bins';
            X = [ones(length(qa_10Hz_raw),1),accplat,uvwplat];
            [qa_10Hz,mu_q] = interval_decorr(lic(:,1),qa_10Hz_raw,jd_bins,X);
            [h2o_10Hz,~] = interval_decorr(lic(:,1),lic(:,2),jd_bins,X);
%             [co2_10Hz,~] = interval_decorr(lic(:,1),lic(:,6),jd_bins,X); % don't bother
            mu_q = [jd_bins(1:end-1),mu_q]; % re orient dimensions for later use
        else
            qa_10Hz = qa_10Hz_raw;
            h2o_10Hz = lic(:,2);
        end

        %% finally, compute 10-min wu, wv, wt and wq covariances
        wu_cov_10min = interval_cov(uvw_str(:,1),uvw_str(:,4),uvw_str(:,2),jd_10bin);
        wv_cov_10min = interval_cov(uvw_str(:,1),uvw_str(:,4),uvw_str(:,3),jd_10bin);
        % This is for sonic T, uncorrected for humidity
        wtson_cov_10min = interval_cov(uvw_str(:,1),uvw_str(:,4),tson_10Hz,jd_10bin); 
        wh2o_cov_10min = interval_cov(uvw_str(:,1),uvw_str(:,4),h2o_10Hz,jd_10bin);
        wq_cov_10min = interval_cov(uvw_str(:,1),uvw_str(:,4),qa_10Hz,jd_10bin);
%         wco2_cov_10min = interval_cov(uvw_str(:,1),uvw_str(:,4),co2_10Hz,jd_10bin); % don't bother

        wu_cov_10min(xxx,2) = NaN;
        wv_cov_10min(xxx,2) = NaN;
        wtson_cov_10min(xxx,2) = NaN;
        wh2o_cov_10min(xxx,2) = NaN;
        wq_cov_10min(xxx,2) = NaN;
%         wco2_cov_10min(xxx,2) = NaN; % don't bother

        wu_cov = wu_cov_10min(:,2);
        wv_cov = wv_cov_10min(:,2);
        wtson_cov = wtson_cov_10min(:,2);
        wh2o_cov = wh2o_cov_10min(:,2)*sens_sep_factor; 
        wq_cov = wq_cov_10min(:,2)*sens_sep_factor;
%         wco2_cov = wh2o_cov_10min(:,2)*sens_sep_factor; % don't bother
        wco2_cov = nan(6,1);

        % Simon's alternate computation of wt and wq, Webb corrected and
        % corrected for humidity effect on sonic. Requires licor, in this
        % case. Or could get h2o from bulk algorithm if licor isn't great
        [wt_cov_sds, wq_cov_sds] = wpl_schotanus(x.ta+C2K,x.qa/1000,x.rhoa,wtson_cov,wh2o_cov);
        % convert from kg/kg -> g/kg. The correction for sensor sep was already applied to wH20_cov
        wq_cov_sds = wq_cov_sds*1000; 

        %% compute covariance heat fluxes
        % licor measures wv density. there's a cross talk through density
        % called the dilution effect. Density fluctuatinos appear as wv flux
        % even if wv concentration is zero.
        % correct sonic wt for humidity -  use C35 for <wq>=-usb*qsb
        % effect of the speed of sound since the sonic measurse T from speed of sound
        % it measures an acoustic temperature... affected by both temp and humidity. It'd be density
        % except there is a cp and cv potential difference. Webb effect is
        % dilution. the acoustic effect is that a portion of the speed of
        % sound isn't affected by humidity enuogh as we'd like it to be if
        % perfect measurement. 
        % Simon's wt_cov_sds doesn't need to be corrected further because it
        % already is, and then converted to correct units by the function
        % above.
        % <wt> = <wtson> - 0.51*T*<wq>  where w'q' = -ustar qstar, so signs
        % add up correctly. tsonic = T(1+0.51q) Could also be corrected at instrument level at
        % 10 Hz, but here the bulk fluxes offer a more reliable correction
        % factor... if bulk model run is good. The flux is -ustarqstar... 
        % old version: wt_cov = wtson_cov + 0.51*(x.ta+C2K).*x.usr.*x.qsr;
        % more correct version is below, where the sign is taken care of
        % because the ideal equation is as follows (commented), but then we
        % use the bulk qsr and usr instead (uncommented)
        % wt_cov = ( wtson_cov - 0.51*(x.ta+C2K).*wq_cov ) ./ (1 + 0.51*x.qa*1E-3)
        wt_cov = ( wtson_cov + 0.51*(x.ta+C2K).*x.usr.*x.qsr) ./ (1 + 0.51*x.qa*1E-3);
        
        % then convert to heat flux units
        % hs = w't' * rhoair * Cp_air = K m/s * kg/m3 * J/(kg K) = W/m2
        % Cp_air = 1004.67 J/kg K
        hs_cov = wt_cov.* x.rhoa * cpa;
        hs_cov_sds = wt_cov_sds.* x.rhoa * cpa; % Simon's method is already humidity + tsonic corrected
        
        % hl = w'q' * 1e-3 * rhoair * Le_w = g/kg m/s * [1 kg / 1000 g] * kg/m3 * J/kg = W/m2
        % latent heat vap [J/kg] for water and seawater from ship SST and ship salinity
        [Le_w, Le_sw] = Le_water(x.tskin, x.ssea_s);
        hl_cov = (wq_cov .* 1e-3 .* x.rhoa .* Le_w) + x.hlwebb; % using coare webb correction
        hl_cov_sds = wq_cov_sds .* 1e-3 .* x.rhoa .* Le_w; % Simon's method is already webb corrected, le in J/kg
        
        %% --------------------COMPUTE SPECTRA AND COSPECTRA--------------------
        % initialize arrays for hourly spectral data
        Fx = NaN(1,48);      % empty arrays for 6x48-bin smoothed spectra
        Pu = NaN(6,48);
        Pv = Pu; Pw = Pu; Pt = Pu; Pt2 = Pu; Pq = Pu;
        Cuw = Pu; Cvw = Pu; Ctw = Pu; Cqw = Pu;
        Ctw_raw = Pu; Cqw_raw = Pu;

        Fxx = NaN(1,1+Npts/2);  % empty arrays for raw spectra
        Puu = NaN(6,1+Npts/2);  % used for idiss calculations...
        Pvv = Puu; Pww = Puu; Ptt = Puu; Ptt2 = Puu; Pqq = Puu;
        tson_noise = NaN(6,1);

        % compute variance spectra and cospectra in 10-min windows
        % but only for periods when sonic data is good
        segs = 1:6;
        for jj = segs(~xxx)  % just good 10-min intervals
            ii = 1 + Npts*(jj-1);
            [Puu(jj,:),Fxx(1,:)] = psd2(detrend(uvw_str(ii:ii+Npts-1,2)),Npts,fsonic,hamming(Npts));
            Puu = real(Puu);
            [Pu(jj,:),Fx(1,:)] = specsmoo(Puu(jj,:),fsonic);
            [Pvv(jj,:),~] = psd2(detrend(uvw_str(ii:ii+Npts-1,3))',Npts,fsonic,hamming(Npts));
            Pvv = real(Pvv);
            [Pv(jj,:),~] = specsmoo(Pvv(jj,:),fsonic);
            [Pww(jj,:),~] = psd2(detrend(uvw_str(ii:ii+Npts-1,4))',Npts,fsonic,hamming(Npts));
            Pww = real(Pww);
            [Pw(jj,:),~] = specsmoo(Pww(jj,:),fsonic);
            [Ptt(jj,:),~] = psd2(detrend(tson_10Hz(ii:ii+Npts-1))',Npts,fsonic,hamming(Npts));
            Ptt = real(Ptt);
            [Pt(jj,:),~] = specsmoo(Ptt(jj,:),fsonic); % This is tson...
            [Pqq(jj,:),~] = psd2(detrend(qa_10Hz(ii:ii+Npts-1))',Npts,fsonic,hamming(Npts));
            Pqq = real(Pqq);
            [Pq(jj,:),~] = specsmoo(Pqq(jj,:),fsonic);

            % subtract noise from tson spectra (for idiss)
            % assumes sonic spectrum at ~5 Hz is noise (from last 3 points in smoothed spectrum)
            tson_noise(jj) = median(Pt(jj,end-2:end));
            Ptt2(jj,:) = Ptt(jj,:) - tson_noise(jj); % noise corrected power spectrum
            [Pt2(jj,:),~] = specsmoo(Ptt2(jj,:),fsonic); % smoothed noise corrected power spectrum
            zz = find(Pt2(jj,:)<0); Pt2(jj,zz) = 0; % be sure there are no negative variances

            % integrate or sum Ptt2.*df (raw) or Pt2.*df (smoothed), then
            % take square root. That should be adjusted sigma T. The raw
            % might be better. 
            
            [temp,~] = csd2(detrend(uvw_str(ii:ii+Npts-1,4)),detrend(uvw_str(ii:ii+Npts-1,2)),Npts,fsonic,hamming(Npts));
            [Cuw(jj,:),~] = specsmoo(real(temp),fsonic);
            [temp,~] = csd2(detrend(uvw_str(ii:ii+Npts-1,4)),detrend(uvw_str(ii:ii+Npts-1,3)),Npts,fsonic,hamming(Npts));
            [Cvw(jj,:),~] = specsmoo(real(temp),fsonic);
            [temp,~] = csd2(detrend(uvw_str(ii:ii+Npts-1,4)),detrend(tson_10Hz(ii:ii+Npts-1)),Npts,fsonic,hamming(Npts));
            [Ctw(jj,:),~] = specsmoo(real(temp),fsonic);
            [temp,~] = csd2(detrend(uvw_str(ii:ii+Npts-1,4)),detrend(son(ii:ii+Npts-1,5)),Npts,fsonic,hamming(Npts));
            [Ctw_raw(jj,:),~] = specsmoo(real(temp),fsonic);
            [temp,~] = csd2(detrend(uvw_str(ii:ii+Npts-1,4)),detrend(qa_10Hz(ii:ii+Npts-1)),Npts,fsonic,hamming(Npts));
            [Cqw(jj,:),~] = specsmoo(real(temp),fsonic);
            [temp,~] = csd2(detrend(uvw_str(ii:ii+Npts-1,4)),detrend(qa_10Hz_raw(ii:ii+Npts-1)),Npts,fsonic,hamming(Npts));
            [Cqw_raw(jj,:),~] = specsmoo(real(temp),fsonic);
            clear temp
            ii = ii + Npts;
        end

        %% inertial dissipation calculations
        % METHOD A: compute Cx2 from median over inertial subrange in
        % smoothed spectra
        % Cu2 / Cw2: array length same as rspd
        fminU = find(Fx>0.8,1,'first');
        fminU = fminU - 2;
        if fminU < 1
            fminU = 1;
        end
        fmaxU = fminU + 2;
        if fmaxU > length(Fx)
            fmaxU = length(Fx);
        end
        
        % rspd is averaged over several wave periods, so has effectively
        % accounted for (been averaged over) ship roll, pitch, roll. 
        % might try lookign at peaks of spectra... might get moved if
        % eddies are beign squished. you don't see peaks in u, v, you see
        % it in w... peaks tend to be gentle though and spectrum is noisy.
        % Enters the ID as 2/3 power, but bulk as square... want to remove 
        % spikes of bad data before this is run. A
        Cua = idiss_struc_func(Pu, Fx, fminU, fmaxU, rspd_raw, 0);
        Cwa = idiss_struc_func(Pw, Fx, fminU, fmaxU, rspd_raw, 0);

         %%% alternate way to do Cua: compute as median from raw spectra
%         fminU = find(Fxx>0.7,1,'first');
%         fmaxU = find(Fxx<1.0,1,'last');
%         Cua = idiss_struc_func(Puu, Fxx, fminU, fmaxU, rspd_raw, 0);
%         Cwa = idiss_struc_func(Pww, Fxx, fminU, fmaxU, rspd_raw, 0);

        % Ct2 - this is tson...
        fminT = find(Fx>0.35,1,'first');
        fminT = fminT - 2;
        if fminT < 1
            fminT = 1;
        end
        fmaxT = fminT + 2;
        if fmaxU > length(Fx)
            fmaxT = length(Fx);
        end
        Cta = idiss_struc_func(Pt2, Fx, fminT, fmaxT, rspd_raw, 0);

        %%% alternate way to do Cta: compute as median from raw spectra
%         fminT = find(Fxx>0.28,1,'first');
%         fmaxT = find(Fxx<0.4,1,'last');
%         Cta = idiss_struc_func(Ptt2, Fxx, fminT, fmaxT, rspd_raw, 0);

        % Cq2 - q licor
        fminq = find(Fx>0.7,1,'first');
        fminq = fminq - 2;
        if fminq < 1
            fminq = 1;
        end
        fmaxq = fminq + 2;
        if fmaxq > length(Fx)
            fmaxq = length(Fx);
        end
        Cqa = idiss_struc_func(Pq, Fx, fminq, fmaxq, rspd_raw, 0);
        
        %%% alternate way to do Cqa: compute as median from raw spectra
%         fminq = find(Fxx>0.6,1,'first');
%         fmaxq = find(Fxx<0.8,1,'last');
%         Cqa = idiss_struc_func(Pqq, Fxx, fminq, fmaxq, rspd_raw, 0);


        % apply Wyngaard (Fritsch ... spell check) & Clifford correction for
        % taylor's hypothesis... spectra gets distorted by mean wind speed
        % variability. ustream2 is the squared streamwise wind (rspd)
        % wavenumber is 2pif /u... convert spectrum ffrom frequency to wave
        % number.There is doppler shifting effect of small scale
        % frequencies because they are carried by large scale turbulence. 
        % f1, f2, f3 are same length as uvar, etc. The paper describes the
        % contamination and the variances. Those equations are repeated
        % here. corrections are applied to the structure functions. For the
        % ocean, the corrections are small since the wind are strong
        % compared to turb (roughness is low, ocean is relatively flat).
        % corrections are less than a percent. 
        
        qa_1min_std = interval_std_var(uvw_str(:,1),  qa_10Hz, jd_1bin);
        qa_10min_std = interval_std_var(uvw_str(:,1), qa_10Hz, jd_10bin);

        
        ustream2 = x.rspd.^2;  
        uvar = uvwt_10min_std(:,2).^2;
        vvar = uvwt_10min_std(:,3).^2;
        wvar = uvwt_10min_std(:,4).^2;
        tvar = uvwt_10min_std(:,5).^2;
        qvar = qa_10min_std.^2;
       
        
        tson_std = uvwt_10min_std(:,5);
        % should also do the adjusted. See how much of a difference the
        % noise subtraction makes
        
        uvar_1 = uvwt_1min_std(:,2).^2;
        vvar_1 = uvwt_1min_std(:,3).^2;
        wvar_1 = uvwt_1min_std(:,4).^2;
        tvar_1 = uvwt_1min_std(:,5).^2;
        qvar_1 = qa_1min_std.^2;

                
        f1 = 1 - (uvar/9.0 - 2*vvar/3.0 - 2*wvar/3.0)./ustream2;
        ff2 = 1 - (uvar/9.0 - vvar/12.0 - wvar/3.0)./ustream2;
        f3 = 1 - (uvar/9.0 - vvar/3.0 - wvar/3.0)./ustream2;

        Cua = Cua ./ f1;
        Cwa = Cwa ./ ff2;
        Cta = Cta ./ f3;
        Cqa = Cqa ./ f3;
       

        % compute usid, tsid, qsid, Lid
        % qsid output is kg/kg
        % qsid and tsid are negative for flux from water-to-air
        % calls psi_fu and psi_ft functions
        % Cta is not corrected for humidity effect on sonic. tsr is bulk
        % value so nor corrections are needed. Cqa is not corrected for
        % Webb effect either, that happens later in hl directly, not to
        % qs_id
        [usr_ida,tsr_ida,qsr_ida,l_ida] = idiss_sst(Cua, Cta, Cqa, x.qa, x.ta,...
            zu, zq, x.l, x.tsr, x.qsr);
        % tstar from ID method is particularly poor because of the noisy 
        % sonic. This method can be better if fed the bulk l, tstar, qstar 

        %% inertial dissipation calculations
        % METHOD B: compute Cx2 from spectral fit over inertial subrange in
        % smoothed spectra
        % Cu2 / Cw2
        fminU = find(Fx>0.6*fsonic/20,1,'first');
        if fminU<1
            fminU = 1;
        end
        fmaxU = find(Fx<3.5*fsonic/20,1,'last');
        if fmaxU>length(Fx)
            fmaxU = length(Fx);
        end
        Cub = idiss_spec_fit(Pu, Fx, fminU, fmaxU, rspd_raw);
        Cwb = idiss_spec_fit(Pw, Fx, fminU, fmaxU, rspd_raw);

        % Ct2
        fminT = find(Fx>0.35*fsonic/20,1,'first');
        if fminT<1
            fminT = 1;
        end
        fmaxT = find(Fx<3*fsonic/20,1,'last');
        if fmaxT>length(Fx)
            fmaxT = length(Fx);
        end
        Ctb = idiss_spec_fit(Pt2, Fx, fminT, fmaxT, rspd_raw);

        % Cq2
        fminq = find(Fx>0.7*fsonic/20,1,'first');
        if fminq<1
            fminq = 1;
        end
        fmaxq = find(Fx<3.6*fsonic/20,1,'last');
        if fmaxq>length(Fx)
            fmaxq = length(Fx);
        end
        Cqb = idiss_spec_fit(Pq, Fx, fminq, fmaxq, rspd_raw);

        % apply Wyngaard & Clifford correction
        Cub = Cub ./ f1;
        Cwb = Cwb ./ ff2;
        Ctb = Ctb ./ f3;
        Cqb = Cqb ./ f3;

        % compute usid, tsid, qsid, Lid
        % qsid output is kg/kg
        % see comments above from version a for more details on signs and
        % corrections that are applied or not at this stage.
        [usr_idb,tsr_idb,qsr_idb,l_idb] = idiss_sst(Cub, Ctb, Cqb, x.qa, x.ta,...
            zu, zq, x.l, x.tsr, x.qsr);
        % tstar from ID method is particularly poor because of the noisy 
        % sonic. This method can be better if fed the bulk l, tstar, qstar 
                
        %% save 10_Hz wind and motion data
        % wrap rdir_10Hz back to original format
        rdir_10Hz_wrap = mod(rdir_10Hz*r2d + 360, 360); 
        rdir_10Hz_wrap(rdir_10Hz>180) = rdir_10Hz_wrap(rdir_10Hz>180) - 360;
        uvwmat = [uvw_str,rdir_10Hz_wrap,qa_10Hz]; %full = [jd_10Hz,u,v,w,T,rdir,qa_10Hz]
        fpath = fullfile(path_uvwStreamData,['UVWstream_',jd_str,'_',d_str,'_',hr_str,'_',dcname,'.txt']);
        save (fpath,'uvwmat','-ascii');
        
        motmatall=[jd_10Hz,uvwplat,xyzplat,euler];
        fpath = fullfile(path_motionData,['motion_',jd_str,'_',d_str,'_',hr_str,'_',dcname,'.txt']);
        save (fpath,'motmatall','-ascii','-double');

        %% selected wind correction and spectra plots
        if plotit
            if hhh==0 || hhh==6 || hhh==12 || hhh==18

                % cospectra plots
                wu = nanmean1(Cuw,1);
                figure(4); clf; semilogx(Fx,Fx.*wu,'b-',[1e-3 10 ],[0 0],'-y');
                title([jd_str,' ',hr_str,' wu Cospectrum']); grid;
                legend('decorr','location','northwest');
                ylabel('C_{uw}(f) x f'); xlabel('f (Hz)');
                ppath = fullfile(path_spectraPlots,'wu_cospectrum',['wuCospec_',jd_str,'_',d_str,'_',hr_str,'_',dcname,graphformat]);
                print(graphdevice,ppath);

                wq = nanmean1(Cqw,1); wq_raw = nanmean1(Cqw_raw,1);
                figure(5); clf; semilogx(Fx,Fx.*wq,'b-',Fx,Fx.*wq_raw,'b--',[1e-3 10 ],[0 0],'-y');
                title([jd_str,' ',hr_str,' wq Cospectrum']); grid;
                legend('decorr','raw','location','northwest');
                ylabel('C_{wq}(f) x f'); xlabel('f (Hz)');
                ppath = fullfile(path_spectraPlots,'wq_cospectrum',['wqCospec_',jd_str,'_',d_str,'_',hr_str,'_',dcname,graphformat]);
                print(graphdevice,ppath);

                wt = nanmean1(Ctw,1); wt_raw = nanmean1(Ctw_raw,1);
                figure(6); clf; semilogx(Fx,Fx.*wt,'b-',Fx,Fx.*wt_raw,'b--',[1e-3 10 ],[0 0],'-y');
                title([jd_str,' ',hr_str,' wt Cospectrum']); grid;
                legend('decorr','raw','location','northwest');
                ylabel('C_{wt}(f) x f'); xlabel('f (Hz)');
                ppath = fullfile(path_spectraPlots,'wt_cospectrum',['wtCospec_',jd_str,'_',d_str,'_',hr_str,'_',dcname,graphformat]);
                print(graphdevice,ppath);

                % spectra plots
                Sw = nanmean1(Pw,1);
                [Sw_raw,~] = psd2(detrend(son(:,4)),Npts*6,10,hamming(Npts*6));
                [Sw_raw,Fraw] = specsmoo(Sw_raw,10);
                figure(7);clf;loglog(Fx,Fx.*Sw,'b-',Fraw,Fraw.*Sw_raw,'b--');
                hold on; loglog(Fx(17:48),((Fx(17:48)).^(-2/3))./(Fx(35).^(-2/3)).*Sw(35).*Fx(35),'r');
                ylabel('S_{ww} x f'); xlabel('f (Hz)'); 
                legend('decorr','raw','-2/3','location','northwest');
                title([jd_str,' ',hr_str,' Spectrum of vertical wind velocity, W']); grid;
                ppath = fullfile(path_spectraPlots,'w_spectrum',['wSpectrum_',jd_str,'_',d_str,'_',hr_str,'_',dcname,graphformat]);
                print(graphdevice,ppath);

                St = nanmean1(Pt,1); St2 = nanmean1(Pt2,1);
                WN = zeros(size(St)) + nanmean1(tson_noise); WN(1:24) = NaN;
                figure(8);clf;loglog(Fx(1:end-5),Fx(1:end-5).*St2(1:end-5),'b-',Fx,Fx.*St,'b--');
                hold on; loglog(Fx(17:48),((Fx(17:48)).^(-2/3))./(Fx(35).^(-2/3)).*St(35).*Fx(35),'r-', Fx,Fx.*WN,'k--');
                ylabel('S_{tt} x f'); xlabel('f (Hz)'); title([jd_str,' ',hr_str,' Spectrum of sonic temperature']); grid;
                legend('minus noise','raw','-2/3','white noise','location','northwest');
                ppath = fullfile(path_spectraPlots,'t_spectrum',['tSpectrum_',jd_str,'_',d_str,'_',hr_str,'_',dcname,graphformat]);
                print(graphdevice,ppath);

                Sq = nanmean1(Pq,1);
                figure(9);clf;loglog(Fx,Fx.*Sq,'b-',Fx(17:48),((Fx(17:48)).^(-2/3))./(Fx(35).^(-2/3)).*Sq(35).*Fx(35),'r');
                ylabel('S_{qq} x f'); xlabel('f (Hz)');
                legend('data','-2/3','location','northwest');
                title([jd_str,' ',hr_str,' Spectrum of specific humidity, q']); grid;
                ppath = fullfile(path_spectraPlots,'q_spectrum',['qSpectrum_',jd_str,'_',d_str,'_',hr_str,'_',dcname,graphformat]);
                print(graphdevice,ppath);

                Su = nanmean1(Pu,1);
                Sv = nanmean1(Pv,1);
                [Su_raw,~] = psd2(detrend(son(:,2)),Npts*6,10,hamming(Npts*6));
                [Su_raw,~] = specsmoo(real(Su_raw),10);
                [Sv_raw,~] = psd2(detrend(son(:,3)),Npts*6,10,hamming(Npts*6));
                [Sv_raw,~] = specsmoo(real(Sv_raw),10);
                figure(10);clf;loglog(Fx,Fx.*Su,'b-',Fraw,Fraw.*Su_raw,'b--',Fx,Fx.*Sv,'g-',Fraw,Fraw.*Sv_raw,'g--');
                hold on; loglog(Fx(17:48),((Fx(17:48)).^(-2/3))./(Fx(35).^(-2/3)).*Su(35).*Fx(35),'r');
                ylabel('S_{uu} x f'); xlabel('f (Hz)');
                legend('U','U raw','V','V raw','-2/3','location','northeast');
                title([jd_str,' ',hr_str,' U V Wind Spectra']); grid;
                ppath = fullfile(path_spectraPlots,'uv_spectrum',['uvSpectrum_',jd_str,'_',d_str,'_',hr_str,'_',dcname,graphformat]);
                print(graphdevice,ppath);

                close all;
            end
        end
        
        %% redo standard deviations with the 10-Hz data
    
        licor_h2o_std  = interval_std_var(lic(:,1), lic(:,2), jd_10bin); % standard deviation of Licor h2o, mmol/m3
        licor_pbox_std = interval_std_var(lic(:,1), lic(:,4), jd_10bin); % standard deviation of Licor box P, kPa
        licor_co2_std = interval_std_var(lic(:,1), lic(:,6), jd_10bin); % standard deviation of Licor co2, mmol/m3
        licor_qa_std = (licor_h2o_std*1e-3).*Mw./x.rhoa; % standard deviation of q

        cog_std = interval_std_var(gps(:,1),unwrap(cog_10Hz*d2r),jd_10bin)*r2d;
        hed_std = interval_std_var(hedf(:,1),unwrap(hed_10Hz_r),jd_10bin)*r2d;
        sog_std = interval_std_var(gps(:,1),sog_10Hz,jd_10bin);

        cog_max = interval_max_var(gps(:,1),unwrap(cog_10Hz*d2r),jd_10bin)*r2d;
        hed_max = interval_max_var(hedf(:,1),unwrap(hed_10Hz_r),jd_10bin)*r2d;
        sog_max = interval_max_var(gps(:,1),sog_10Hz,jd_10bin);

        cog_min = interval_min_var(gps(:,1),unwrap(cog_10Hz*d2r),jd_10bin)*r2d;
        hed_min = interval_min_var(hedf(:,1),unwrap(hed_10Hz_r),jd_10bin)*r2d;
        sog_min = interval_min_var(gps(:,1),sog_10Hz,jd_10bin);

        licor_h2o_std_1 = interval_std_var(lic(:,1), lic(:,2), jd_1bin); % standard deviation of Licor h2o, mmol/m3
        licor_pbox_std_1 = interval_std_var(lic(:,1), lic(:,4), jd_1bin); % standard deviation of Licor box P, kPa
        licor_co2_std_1 = interval_std_var(lic(:,1), lic(:,6), jd_1bin); % standard deviation of Licor co2, mmol/m3
        licor_qa_std_1 = (licor_h2o_std_1*1e-3).*Mw./x1.rhoa; % standard deviation of q
        
        cog_std_1 = interval_std_var(gps(:,1),unwrap(cog_10Hz*d2r),jd_1bin)*r2d;
        hed_std_1 = interval_std_var(hedf(:,1),unwrap(hed_10Hz_r),jd_1bin)*r2d;
        sog_std_1 = interval_std_var(gps(:,1),sog_10Hz,jd_1bin);
       
        cog_max_1 = interval_max_var(gps(:,1),unwrap(cog_10Hz*d2r),jd_1bin)*r2d;
        hed_max_1 = interval_max_var(hedf(:,1),unwrap(hed_10Hz_r),jd_1bin)*r2d;
        sog_max_1 = interval_max_var(gps(:,1),sog_10Hz,jd_1bin);

        cog_min_1 = interval_min_var(gps(:,1),unwrap(cog_10Hz*d2r),jd_1bin)*r2d;
        hed_min_1 = interval_min_var(hedf(:,1),unwrap(hed_10Hz_r),jd_1bin)*r2d;
        sog_min_1 = interval_min_var(gps(:,1),sog_10Hz,jd_1bin);
 
        %% some filtering varaibles

        % w'tv' sonic buoyancy flux ... w't' is technically -ustar x tstar
        wtv = -x.usr.*(x.tsr+0.61.*(x.ta+273.16).*x.qsr); 
        
        % convective velocity order 0.8 m/s... where 600 is estimated BL
        % depth. convective generated turbulence... as opposed to shear
        % driven turb described by ustar. 
        ws = (9.83./(x.ta+273.16).*abs(wtv)*600).^(1/3); 
 
        %%% these are gustiness parameters to descibe how much turbulence we expect
        %%% to see from convection and shear driven velocity variances.
        %%% This is also done in coare, but different weights are used
        %%% here.
        ug = sqrt(x.usr.^2+ws.^2); % ... gustiness velocity... calculated differently than COARE
        ugw = sqrt(1.5*x.usr.^2+ws.^2); % ... weighted gustiness velocity
        ugu = sqrt(8*x.usr.^2+1.*ws.^2); % ... heavily weighted gustiness velocity describes velocity variances
%         what are the velocity variances, what shouold the be in terms of the bulk data or based on the bulk data
%         if the actual variances are larger, then that tells you something went on with the ship plume. 
%         the ratio of measured to expected is supposed to be less than some number, but is allowed to get bigger 
%         when the wind speed increases. the different thresholds were
%         developed based on trying to identify and get rid of outliers. 
        
        %%% these parameters and their use in kk,hh,jj,ii are not sacred...
        %%% developed by plotting data as a function of variables to find
        %%% way to eliminate outliers in covariance and inertial
        %%% dissipation based on some rational criteria. sigma w and sigma
        %%% v are the sqrt of variances. normalized by velocity variance
        %%% scales. sigma w / ustar in neutral is about 1.25
        %%% additional filter option: kk & isfinite(usid) & (abs(-wu-usid)^2<.02+.006*U)

        kk = find((x.rdir < 90 & x.rdir > -90) & hed_std < 5 &...
                   sog_std < 0.6 & vplat_std < 0.8 &...
                   (sqrt(wvar)./ugw < .7+.0015*x.wspd.^2) &...
                   (sqrt(wvar)./ugu < 1.4) & missingSon < 100 & ...
                   badSon < 100); % x.prate < 5); For ASTRAL_2023 leaving out prate 
               
               % might think about relaxing or removing prate threshold.
               % could mess up T spectrum first. 

%                the variables may not meet our standards for accuracy of 10% for the net heat flux
%                10 W / m2. We cannot guarantee the accuracy 1997, Fairall and Bradley. We
%                also have specific accuracy claims for each state variable, which map out to accuracy 
%                for each flux and then the net flux. The stated accurcy applies to the wind speed 
%                limits we found +/- 140... he could actually estimate what 

% in hourly data, could tell you how many good data values you had, then you'd have a good idea of how good
% that hourly data was. If there were only 2 x 10 min periods of good data, you might want to track and exclude that thoough
% the uncertainty or representativeness. 1 / square root of hte number. if you have 6 10 min samples, so the uncertainty of that avg is the uncertainty of the individual ones divided by square root of 5 (good  samples) or divided by ssquare root of 1 (worse). 
% check whether the

        hh = intersect(kk, find(x.licor_agc < 60));

        jj = intersect(kk, find(isfinite(usr_ida) == 1));

        mm = intersect(hh,jj);
       
        good_motion = t_10min*0;
        good_motion(kk) = 1;

        good_motion_licor =t_10min*0;
        good_motion_licor(hh) = 1;

        good_motion_id =t_10min*0;
        good_motion_id(jj) = 1;

        good_motion_id_licor =t_10min*0;
        good_motion_id_licor(mm) = 1;
   
        %% calculate inertial dissipation (id) and eddy covariance (cov) fluxes for saving and plotting
        
        % idiss method a for sensible and latent heat fluxes
        % originally the ID fluxes were defined positive flux out of ocean 
        % for tstar < 0 and qstar < 0, i.e. warmer and moister ocean than
        % air. This is typical for tropics.
        % hlwebb is positive so should be added to positive hl_ida. 
        % however, the bulk fluxes are now defined that negative cools
        % ocean and positive heats ocean.
        hs_ida = -x.rhoa .*cpa .*tsr_ida .*usr_ida; 
        hl_ida = -x.rhoa .*Le_w .*qsr_ida .* usr_ida + x.hlwebb; % Webb corrected, qsr in kg/kg

        % Unit check for hl_ID = rhoa * Le_w * qstr * 1000 * ustar + hl_webb = 
        %     kg/m3 * J/kg % kg/kg * m/s = W/m2
        %     J = Watt sec = kg m2 s-2 

        % Unit check for hs_ID = rhoa * cpa * tstr * ustar = 
        %     kg/m3 * J/(K kg) % K * m/s = W/m2
        %     J = Watt sec = kg m2 s-2  = = kg m s^-2 m 
        %     W = kg m2 s?3
        
        % idiss method b for sensible and latent heat fluxes
        hs_idb = -x.rhoa .*cpa .*tsr_idb .*usr_idb;
        hl_idb = -x.rhoa .*Le_w .*qsr_idb .*usr_idb + x.hlwebb; % Webb corrected, qsr in kg/kg
        
        % id a and b methods for stress
        tau_ida = x.rhoa .*usr_ida .^2;
        tau_idb = x.rhoa .*usr_idb .^2;

        % eddy covariance method for stress 
        tau_cov = -x.rhoa .* wu_cov;               %  stream wise stress
        tau_cov_cross = -x.rhoa .* wv_cov;         %  cross stream stress

        %% save data
        % address sign or orientation issues with these arrays for saving
        tilt = tilt'*r2d;
        azm = azm';
        
        % concatenate lag times and 10-min decorr coefficients
        lag(hhh+1,:) = lagmat;
            
        %%% new vars calculated in this program at 1 and 10 min
        new_vars_both = {'uplat_std';'vplat_std';'wplat_std';...
        'sog_min';'hed_min';'cog_min';'sog_max';'hed_max';'cog_max';...
        'sog_std';'hed_std';'cog_std';'shed_std';'ched_std';...
        'rdir_std';'uvar';'vvar';'wvar';'tvar';'qvar'};
                    
        %%% new vars calculated only at 10-min, which we can interpolate to
        %%% 1-min in next program
        new_vars_10 = {'tilt';'azm';...
        'wu_cov';'wv_cov';'wq_cov';'wt_cov';'wtson_cov';'wq_cov_sds';'wt_cov_sds';'wh2o_cov';'wco2_cov';...
        'missingSon';'badSon';'tson_noise';'tson_std';...
        'usr_ida';'usr_idb';'tsr_ida';'tsr_idb';'qsr_ida';'qsr_idb';'l_ida';'l_idb';...
        'hs_cov';'hs_cov_sds';'hl_cov';'hl_cov_sds';...
        'Cua';'Cub';'Cwa';'Cwb';'Cta';'Ctb';'Cqa';'Cqb';...
        'Fx';'Pu';'Pv';'Pw';'Pt';'Pq';'Cuw';'Cvw';'Ctw';'Cqw';'mu';'mu_q';'lag';...
        'Un';'Ue';'rspd_raw';'rspd_new';'rspd_new2';'rdir_new';...
        'wspd_new';'wdir_new';'ubar';'vbar';'wbar';'Tbar';...
        'tau_cov';'tau_cov_cross';'tau_ida';'tau_idb';...
        'hs_ida';'hs_idb';'hl_ida';'hl_idb';...
        'good_motion';'good_motion_licor';'good_motion_id';'good_motion_id_licor';...
        'wtv';'ws';'ug';'ugw';'ugu';'Le_w';'Le_sw';...
        'licor_h2o_std';'licor_pbox_std';'licor_co2_std';'licor_qa_std';...
        };
             
        %%% save new vars in structure
        
        if hhh == hr_start %%% start structure if hh = hr_start
            clear c10;
            clear c1
            
            c10.jd = jd_10min;
            c1.jd = jd_1min;
            c10.t = datenum(yr,0,0,0,0,0) + jd_10min;
            c1.t = datenum(yr,0,0,0,0,0) + jd_1min;

            for i = 1:length(new_vars_both)
                eval(['c10.' new_vars_both{i}   ' = ' new_vars_both{i} ';']);
                eval(['c1.' new_vars_both{i}    ' = ' new_vars_both{i} '_1;']);
            end

            for i = 1:length(new_vars_10)
                eval(['c10.' new_vars_10{i}     ' = ' new_vars_10{i} ';']);
            end
        
        else %%% add to the structure if hh > hr_start
            c10.jd = [c10.jd; jd_10min];
            c10.t = [c10.t; datenum(yr,0,0,0,0,0) + jd_10min];
            c1.jd = [c1.jd; jd_1min];
            c1.t = [c1.t; datenum(yr,0,0,0,0,0) + jd_1min];
                        
            for i = 1:length(new_vars_both)
                eval(['c10.' new_vars_both{i}   ' = [c10.' new_vars_both{i}  '; ' new_vars_both{i} '];']);
                eval(['c1.' new_vars_both{i}    ' = [c1.' new_vars_both{i} '; ' new_vars_both{i} '_1];']);
            end
            for i = 1:length(new_vars_10)
                eval(['c10.' new_vars_10{i}     ' = [c10.' new_vars_10{i}    '; ' new_vars_10{i} '];']);
            end

        end %%% end hour loop for making structure
        
    end % end of 24 hour loop

%% OLD B/C already taken care of with fixit
%%% EEZ: remove the data while in EEZ... same as fix_met_sea.m
%    and add nans at end of last day since we only loaded half day here
% EEZ_10 = find(c10.t < datenum(2019,9,6,5,0,0) | c10.t > datenum(2019,9,25,12,0,0));
% EEZ_1 = find(c1.t < datenum(2019,9,6,5,0,0) | c1.t > datenum(2019,9,25,12,0,0));
% fmet_10 = fields(c10);
% fmet_1 = fields(c1);

%%% changing EEZ to nan
% % 10-min data
% for j = 1:length(fmet)
%     m10 = c10.(fmet{j});
%         if strcmp(fmet(j),'t') ~= 1 && strcmp(fmet(j),'jd') ~= 1 ...
%                 && strcmp(fmet(j),'lag') ~= 1
% %             disp(['applying EEZ for ' fmet{j}]);
%             m10(EEZ_10,:) = nan;
%             c10.(fmet{j}) = m10;
%         end
% 
% end   
% 
% % 1-min data
% for j = 1:length(fmet1)
%     m1 = c1.(fmet1{j});
%         if strcmp(fmet1(j),'t') ~= 1 && strcmp(fmet1(j),'jd') ~= 1
% %             disp(['applying EEZ for ' fmet1{j}]);
%             m1(EEZ_1,:) = nan;
%             c1.(fmet1{j}) = m1;
%         end
% 
% end 

% %%% removing EEZ
% for j = 1:length(fmet_1)
%     x1 = c1.(fmet_1{j});
%     x1(EEZ_1) = [];
%     c1.(fmet_1{j}) = x1;
% endx
% 
% for j = 1:length(fmet_10)
%     x10 = c10.(fmet_10{j});
%     x10(EEZ_10) = [];
%     c10.(fmet_10{j}) = x10;
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    plot_check_flags = 0;
    if plot_check_flags == 1
        figure;
        subplot(2,2,1); hold on;
        plot(c10.t, c10.wspd_new);
        plot(c10.t(kk_1), c10.wspd_new(kk_1),'x');
        plot(c10.t(c10.good_motion == 1), c10.wspd_new(c10.good_motion == 1),'o');
        title('good motion kk');
        grid on;
        datetick('x','mm/dd');
        axis tight;
        subplot(2,2,2); hold on;
        plot(c10.t, c10.wspd_new);
        plot(c10.t(hh_1), c10.wspd_new(hh_1),'x');
        plot(c10.t(c10.good_motion_licor == 1), c10.wspd_new(c10.good_motion_licor == 1),'o');
        title('good motion licor hh');
        grid on;
        datetick('x','mm/dd');
        axis tight;
        subplot(2,2,3); hold on;
        plot(c10.t, c10.wspd_new);
        plot(c10.t(jj_1), c10.wspd_new(jj_1),'x');
        plot(c10.t(c10.good_motion_id == 1), c10.wspd_new(c10.good_motion_id == 1),'o');
        title('good ID jj');
        grid on;
        datetick('x','mm/dd');
        axis tight;
        subplot(2,2,4); hold on;
        plot(c10.t, c10.wspd_new);
        plot(c10.t(mm_1), c10.wspd_new(mm_1),'x');
        plot(c10.t(c10.good_motion_id_licor == 1), c10.wspd_new(c10.good_motion_id_licor == 1),'o');
        title('good ID licor mm');
        grid on;
        datetick('x','mm/dd');
        axis tight;
        legend('wspd','old','new');    
    end
    
    disp(['FINISHED motcorr ',cruise,' yearday ',sprintf('%03i',ddd),'.']);

            
    %% DAILY flux file prep to save = all hours
    
    % put all variable names in alphabetical order;
    c10 = orderfields(c10);   % 10-min time series
    c1 = orderfields(c1);     %  1-min time series

    name_10     = [cruise '_10min_motcorr_' sprintf('%02i_%02i_jd%03i',Vdate(2),Vdate(3),ddd)];
    name_1      = [cruise  '_1min_motcorr_' sprintf('%02i_%02i_jd%03i',Vdate(2),Vdate(3),ddd)];
    mat_10      = [path_output '/'  name_10 '.mat'];
    mat_1       = [path_output '/'  name_1 '.mat'];
    save(mat_10,'c10');    
    save(mat_1,'c1');    

    %% Daily plots 
    plot_motcorr(c10, b10, path_dailyPlots, cruise, cruise_str);
    
    %%% if testing outside program:
    

end % end daily loop

disp('END OF motcorr PROCESSING')