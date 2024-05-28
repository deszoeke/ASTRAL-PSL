%%% defines values specific to this cruise
%%%    PISTON 2019 on R/V Sally Ride
%%%    ejt April 2020

%%%    this info used to be the PAR file of Chris's workflow
% We are in port at the end of Leg 1. I'll try uploading day 119-134 in one compressed file to the share drive (Astral Ekamsat 2024/TGT transit 1 day data sample) It's ~750mb but I think the ship network can handle that. As discussed with Ludovic, I'll adjust the reigel while we are in port to get a better return on it, and check that all boxes and instruments are secure for Leg 2 while I'm up there.

% Sea snake got pulled at 0230utc jd135. It'll get back in ~jd138 as we exit EEZ for Leg2

% No issues with any other instruments as far as installation or connection to DAS

% The Thompson restechs are more stringent about EEZ so the SCS feed from the ship will be out for a few hours at the start and finish of the 119-134 batch.

% ROSR 002 and seasnake sst readings were reasonably close for Leg 1

% I missed a Licor rinse on 133

% PSP/PIR were cleaned on the way in to dock on 5-14, I'll give them another cleaning on 6-01 unless needed.


% Sensor
% Atmospheric pressure
% PSP/PIR fast pressure mast - low
% fast pressure mast - high
% Licor
% IT/RH ORG motion pack
% sonic
% Riegl
% Height from WL (m)
% 10.1
% 11.4
% 11.3
% 15.5
% 15.7
% 15.2
% 15.5
% 15.7
% 16.5
% 14.5

%% titles
cruise = 'ASTRAL_2024';  % string for file names: acronym_year
ptitle = 'ASTRAL 2024';  % string for plots
cruise_str = 'ASTRAL';  % cruise acronym
ship = 'Thompson';  % research vessel
yr = str2double(cruise(end-3:end)); % numeric year
yr_st = cruise(end-3:end); % year string

graphdevice = '-dpng'; % select graphic device
graphformat = '.png';  % select graphics format


%% licor options... used only in manualfluxeval
flicor = 10; 

%% Sonic configuration
% valid models: 'WindMasterPro', 'R3', 'R3A', 'R2', 'R2A'
sonicmodel = 'R3A';
fsonic = 10;            % frequency (Hz) for all fast data
rotationsonic = false;  % true = rotate 30 deg for some Gill sonics
outputsonic = 1;    % defines T_sonic output: 0 = speed of sound, 1 = degC
Npts = fsonic*600;  % data points in 10 min window @ frequency fsonic

% sonic-MotionPak displacement vector [Rx Ry Rz]
% the sonic bolts onto the motion pack so this doesn't change cruise to cruise
sens_disp = [0,0,0.7]; % sonic is 0.7 m above MotionPak 

%% Instrument names, locations, heights, depths (in meters)

% to-do: add calibration info

ins_rain = 'Optical Scientific Inc Optical Rain Gauge ORG-815-DA, SN# 8060281';	
loc_rain = 'bow mast';
zrain = 15.5;

ins_sw1 = 'Eppley Precision Spectral Pyranometer PSP, SN# 30593F3';
ins_sw2 = 'Eppley Precision Spectral Pyranometer PSP, SN# 30434F3';
ins_lw1 = 'Eppley Precision Infrared Radiometer PIR, SN# 30433F3';	
ins_lw2 = 'Eppley Precision Infrared Radiometer PIR, SN# 30432F3'; 
loc_rad = 'starboard forward O2 deck rail';
zrad = 11.4;

ins_t = 'Vaisala-HMT337 tempearture humidity sensor, SN# E1350206'; 	
loc_t = 'bow mast';
zt = 15.2;

ins_q = 'Vaisala-HMT337 tempearture humidity sensor, SN# E1350206'; 	
loc_q = 'bow mast';
zq = 15.2; 

% 43', 9" is o2 level... and it's angled up... so I bet sensor is right there
ins_p = 'Vaisala-PTB220 shielded pressure sensor, SN# A2710002'; 
loc_p = 'starboard forward O2 deck rail';
zp = 10.1;

ins_u = 'Gill Instruments R3 3-axis sonic anemometer, SN# 111001';
loc_u = 'bow mast';
zu = 16.5;

ins_snk = 'NOAA PSL Sea Snake ocean temperature, made in house';
loc_snk = 'port forward focsle deck rail';
zsnk = 0.05;

ins_lic = 'Licor-7500 open-path H2O CO2 gas analyzer, LI7500 SN# 1749'; 
loc_lic = 'bow mast';
zlic = 15.7; % by design of setup supposed to be 1 m below sonic

ins_wxt = '--'; 
loc_wxt = '--';
zwxt = nan;

% ins_wxt = 'RM Young WXT520 weather station, SN# --'; 
% loc_wxt = 'starboard forward O2 deck rail';
% zwxt = 11.31;

ins_rosr = ['--']; 
loc_rosr = '--';
zrosr = NaN;

% ins_rosr = ['Remote Measurements & Research Co. Remote Ocean Surface '...
%     'Radiometer (RMR Co. ROSR), SN# 3']; 
% loc_rosr = 'port forward O2 deck rail';
% zrosr = 11.3;

ins_motion = 'Systron and Donner MP-1 6-axis motion sensor, SN# 681'; 
loc_motion = 'bow mast';
zmotion = 15.7; % by design of setup

ins_gps = 'Hemisphere GPS VS-1000 system. Hemisphere MDA30 and MDA10 antenna, SN# 0824-7443-0010, '; 
loc_gps = 'starboard forward O2 deck rail';
zgps = 11.4;

ins_wave = 'WaMoS system using Revelle science-dedicated Furuno X-band radar'; 
loc_wave = 'main mast';
zwave = 14.5; 
 
% ins_wave = 'Riegl LD90-3100VHS-FLP distance meter, SN# 2220524_0'; 
% loc_wave = 'bow mast';
% zwave = 12; 

ins = {ins_rain; loc_rain; zrain; ...
ins_sw1; ins_sw2; ins_lw1; ins_lw2; loc_rad; zrad; ...
ins_t; loc_t; zt; ...
ins_q; loc_q; zq; ...
ins_p; loc_p; zp; ...
ins_u; loc_u; zu; ...
ins_lic; loc_lic; zlic; ...
ins_snk; loc_snk; zsnk; ...
ins_wxt; loc_wxt; zwxt; ...
ins_rosr; loc_rosr; zrosr; ...
ins_motion; loc_motion; zmotion; ... 
ins_gps; loc_gps; zgps; ...
ins_wave; loc_wave; zwave};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% sensor heights above sea level on ship in meters. If not provided or
% known by ship, can look in SAMOS metadata


ins_rain_ship = 'N/A';
loc_rain_ship = 'N/A';
zrain_ship = NaN;

ins_sw_ship = 'Eppley Precision Spectral Pyranometer PSP';
ins_lw_ship = 'Eppley Precision Infrared Radiometer PIR';
loc_rad_ship = 'bow mast';
zrad_ship = 15;

ins_t_ship = 'RM Young aspirated air temperature sensor 41342VC';
loc_t_ship = 'bow mast';
zt_ship = zmotion;

ins_q_ship = 'E+E Elektronic humidity sensor EE08';
loc_q_ship = 'bow mast';
zq_ship = zmotion;

ins_p_ship = 'RM Young barometer 61302V';
loc_p_ship = 'bow mast';
zp_ship = zmotion;

ins_u_ship = 'RM Young 2D ultrasonic wind anemometer 86106';
loc_u_ship = 'bow mast';
zu_ship = 22;

ins_u2_ship = 'RM Young 2D ultrasonic wind anemometer 86106';
loc_u2_ship = 'bridge port';
zu2_ship = 18.9;

ins_u3_ship = 'RM Young 2D ultrasonic wind anemometer 86106';
loc_u3_ship = 'bridge star';
zu3_ship = 18.9;


ins_sea_ship = ['Sea-Bird Electronics, Inc SBE-45 MicroTSG '...
    'Thermosalinograph, SN# --']; 
loc_sea_ship = 'bow';
zsea_ship = 4;   % depth of bow TSG
 
ins_spdlog_ship = 'speed log and GPS';
loc_spdlog_ship = 'bridge';
zspdlog_ship = 18;

ins_ship = {ins_rain_ship; loc_rain_ship; zrain_ship; ...
ins_sw_ship; ins_lw_ship; loc_rad_ship; zrad_ship; ...
ins_t_ship; loc_t_ship; zt_ship; ...
ins_q_ship; loc_q_ship; zq_ship; ...
ins_p_ship; loc_p_ship; zp_ship; ...
ins_u_ship; loc_u_ship; zu_ship; ...
ins_u2_ship; loc_u2_ship; zu2_ship; ...
ins_u3_ship; loc_u3_ship; zu3_ship; ...
ins_sea_ship; loc_sea_ship; zsea_ship; ...
ins_spdlog_ship; loc_spdlog_ship; zspdlog_ship};


%% domain
Lonmin = 75; Lonmax = 108; Latmin = 0; Latmax = 24;
PosLims = [Lonmin, Lonmax, Latmin, Latmax];

%% clear sky model configuration
% this might need tuning to account for local conditions. Look for max or
% min value of solar or IR, respectively, to match the clear sky values
% when clouds are not present (check ceilometer or Wband if needed) and
% when it is obvious that aerosol loading is not changing.
k1 = 0.1;     % aerosol optical depth, band 1
k2 = 0.1;     % aerosol optical depth, band 2
oz = 0.2;     % column ozone
iv = 3.5;     % column water vapor (cm), if not calculated from obs.

%% constants
C2K = 273.15;               % T conversion constant
d2r = pi/180;               % angle conversion constants
r2d = 180/pi;               % angle conversion constants
Rgas = 287.1;               % Pa m-3 K-1 kg-1 for dry air
Rgas_universal = 8.314472;	% Pa m3 K-1 mol-1
Mw = 18.01528;              % molar mass of H20 g/mol
Md = 28.964;                % molar mass dry air
epsilon = Mw/Md;            % mass of water to mass of dry air = 0.622,
                            %    epsilon = 0.9715; % mean emissivity of the ocean
cpa  = 1004.67;             % heat capacity air, J kg-1 K-1 for dry air and constant P
sigma = 5.67E-8;            % stephan boltzmann constant W m-2 K-4
      
%% adjustments for met/sea ... not used currently. 
% to-do: remove from all programs.
% Even if used, it only gets called in evalflux.
% Now the corrections get done instead in fix_met_sea, not here.
% but potentially, this could be used if you knew ahead of time what the
% corrections should be. We usually don't, and have to do tests to figure it
% out afterwards. So we assume here that no corrections are needed initially.

td1_adj = 0;        % PIR dome 1
tc1_adj = 0;        % PIR case 1
td2_adj = 0;        % PIR dome 2
tc2_adj = 0;        % PIR case 2
td_ship_adj = 0;    % PIR dome ship
tc_ship_adj = 0;    % PIR case ship
tsea_adj = 0;       % sea snake  ~+0.55 too warm, but not adjusting here
ta_adj = 0;         % air temp

adj = [tsea_adj,ta_adj,td1_adj,tc1_adj,td2_adj,tc2_adj];
ship_adj = [td_ship_adj,tc_ship_adj];
