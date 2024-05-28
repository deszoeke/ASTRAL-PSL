%%% program to save the final netcdf file for ASTRAL 2023

% Run these first:
% fixit.m ... which runs coare a final time on 1 and 10 min data to be used
% in... 
% da_red_et.m ... which forms the final .mat files at 1, 10, 60 min.

% check the output of this file, prior files, and that for 2019 as well in
% PISTON_check_nc.m ... which is in Documents/MATLAB/

% this program calls assign_nc_info.m which is very minimally modified from
% experiment to experiment, ideally. The only things that are still hard
% coded are the corrections applied to seawater data. The rest of the
% instrument, height, cruise info are automatically loaded where needed in
% setup_cruise.m

% Oct 2023 EJT


%% Initialize run parameters
close all;
fclose all;
clear all;
warning ('off','MATLAB:MKDIR:DirectoryExists');
setup_cruise;

% system specific path defs
sysType = computer;
username=char(java.lang.System.getProperty('user.name'));
if strncmp(sysType,'MACI64',7)     % set Mac paths
    data_drive = '/Users/ethompson/DATA/';
    path_prog = fullfile(data_drive,cruise,ship,'Scientific_analysis','programs');
elseif strncmp(sysType,'PCWIN64',7)  % set PSL DAC paths
    data_drive = 'D:\DATA\';
    path_prog = fullfile(data_drive,cruise,ship,'Scientific_analysis','programs');
end

% matlab script path
restoredefaultpath
cd(fullfile(path_prog,'flux'));
addpath(genpath(fullfile(path_prog,'flux')));
rehash toolboxcache;

path_plot = fullfile(data_drive,cruise,ship,'flux','Processed_Images','nccheck');
mkdir(path_plot);

% where both input and output data live
indir = [fullfile(data_drive,cruise,ship,'flux','Processed','v2') '/'];
thedir = [fullfile(data_drive,cruise,ship,'flux','Processed','final') '/'];
mkdir(thedir);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 1 min, 10 min, hourly input mat files:
vin = 'v2'; 
f1  = [cruise  '_1min_nav_met_sea_flux_' vin '.mat'];
f10 = [cruise '_10min_nav_met_sea_flux_' vin '.mat'];
% f60 = [cruise '_60min_' vin '.mat'];

load([indir f1]);  
load([indir f10]);

% load([thedir f1]);  
% load([thedir f10]);
% load([thedir f60]);

% output files we are making here:
vnum = 'R1'; % R1 for Fall 2022 release, R2 for Jan 2023 release
product_version_nc = '1'; % used to fill in global attributes automatically

day1_str = datestr(b10.t(1),'yyyymmdd');  % it's e1 and e10 if it's after da_red
dayn_str = datestr(b10.t(end),'yyyymmdd');

ncname1=[cruise_str '-nav-met-sea-1min_RV-' ship '_' day1_str '_' vnum '_thru_' dayn_str '.nc'];
ncname10=[cruise_str '-nav-met-sea-flux-10min_RV-' ship '_' day1_str '_' vnum '_thru_' dayn_str '.nc'];
% ncname60=[cruise_str '-nav-met-sea-flux-60min_RV-' ship '_' day1_str '_' vnum '_thru_' dayn_str '.nc'];

fillval = -9999;

%%% if you want to read in a table to get nc info
% R = readtable([thedir cruise '_data_info.csv']);
% % = [fieldss, unitss, standard_namess, longnamess, commentss, typess] = 
% thefields1      = R(:,1);
% unitss          = R(:,2);
% standard_namess = R(:,3);
% longnamess      = R(:,4);
% commentss       = R(:,5);
% typess          = R(:,6);


% % If you want to convert 0-360 to +/- 180
% rdir0 = e10.rdir;
% rdir0(rdir0<0)=rdir0(rdir0<0)+360;

%% variables

for k = 1:2
    clear a b c;
    if k == 1
        a = b1; % e1 for after da_red    
        ncname = ncname1;
        tres = '1 minute';
    elseif k == 2
        a = b10; % e10 for after da_red
        ncname = ncname10;
        tres = '10 minutes';
    elseif k == 3
        a = e60;
        ncname = ncname60;
        tres = '60 minutes, 1 hour';
    end
    
nt = length(a.t);
display(['time:' datestr(min(a.t),0) ' thru ' datestr(max(a.t),0)]);

more_fluxes = 0;
if more_fluxes == 1
% ship manuevering and sampling the ship plume. 1 = bad; 0 = good;
jship = ones(nt, 1); % assume all are bad (1)
jship(a.jmanuv < 0.5 | a.jplume < 0.5) = 0; % data are good (0) where jmanuv < 0.5 (3 is max) and jplume = 0
b.flag_bad_ship = jship;
end

% wind from aft.  1 = bad; 0 = good;
jbulk = ones(nt,1); % assume all are bad (1)
jbulk(abs(a.rdir) < 140) = 0; % data with rdir within +/- 140 deg are good (0)
b.flag_bad_bulk = jbulk;

% if k > 1
% % wind not head on.  1 = bad; 0 = good;
% jdirect = zeros(nt,1); % assume all good
% jdirect(abs(a.rdir) > 90 | e10.good_motion == 0) = 1; set bad data to 1
% e10.flag_bad_direct = jdirect;
% end

% add human readable time arrays for IDL, python, NCL etc. users
[b.year, b.month, b.day, b.hour, b.minute, ~] = datevec(a.t);

% time elapsed in seconds since Jan 1 of that year
% note... don't add this to a structure. just call it time. used below in a
% special netcdf way. 

time = (a.t - datenum(yr,1,1,0,0,0))*24*3600;
ndays = a.jd(end) - a.jd(1);

% Decide whether to choose NOAA or ship cog, sog, heading. They appear the same
% except NOAA datastream of these variables has 80 less NaN points than
% the ship. The goal is to have continuous nav time series without gaps where we
% can manage. We do not like to interpolate our measurements. 
b.lat = a.lat;
b.lon = a.lon;
b.cog = a.cog;
b.sog = a.sog;
b.heading = a.hed;

b.rhair = a.rh;
b.rhair_2 = a.rh2;
b.rhair_10 = a.rh10;
% b.rhship = a.rh_s;
b.rhoair = a.rhoa;
b.rhoair_10 = a.rhoa10;
% b.rhoship = a.rhoa_s;
b.qair = a.qa;
b.qair_2 = a.qa2;
b.qair_2n = a.qa2n;
b.qair_10 = a.qa10;
b.qair_10n = a.qa10n;
b.pair_10 = a.pa10;
% b.qair_ship = a.qa_s;
% b.psealevel_ship = a.psealevel_s;
b.tair = a.ta;
b.tair_2 = a.ta2;
b.tair_2n = a.ta2n;
b.tair_10 = a.ta10;
b.tair_10n = a.ta10n;
% b.tair_ship = a.Ta_s;
b.wspd_2 = a.u2;
b.wspd_2n = a.u2n;
b.wspd_10 = a.u10;
b.wspd_10n = a.u10n;
% b.wspd_ship = a.wspd_s;
% b.wdir_ship = a.wdir_s;
b.qskin = a.qs;
b.tskin = a.tskin;
b.tsea = a.tsnk;
b.qsea = a.qsnk;
b.tsea_ship = a.tsea_s;
b.tsea_in_ship = a.tsea_in_s;
b.ssea_ship = a.ssea_s;
% b.qsea_ship = a.qs_s;
% b.dt_skin = a.dT_skin;
% b.dt_warm_to_skin = a.dT_warm_to_skin;
% b.dt_warm = a.dT_warm;
% b.wave_height = nan(length(a.t),1);
% b.wave_cp = nan(length(a.t),1);
b.wave_edis = a.edis;
b.wave_whitecap_frac = a.wc_frac;
b.sw_down = a.sw_dn;
b.sw_down_ship = a.sw_dn_s;
b.sw_down_clear = a.sw_dn_clr;
b.sw_up_ship = a.sw_up_s;
b.lw_down = a.lw_dn;
b.lw_down_ship = a.lw_dn_s;
b.lw_down_clear = a.lw_dn_clr;
b.lw_up_ship = a.lw_up_s;

if k > 1
    
b.hl_bulk = -a.hl;
b.hs_bulk = -a.hs;
b.hrain = -a.hrain;
b.hb_bulk = a.hb;

if more_fluxes == 1
    b.hs_cov = -a.hs_cov;
    b.hs_id = -a.hs_id;
    b.hl_cov = -a.hl_cov;
    b.hl_id = -a.hl_id;
end

b.hl_webb = -a.hlwebb;
b.mo_length = a.l;
b.ustar = a.usr;
b.qstar = a.qsr;
b.tstar = a.tsr;
% b.cd = a.Cd;
% b.ce = a.Ce;
% b.ch = a.Ch;
% b.cd10N = a.CdN10;
% b.ce10N = a.CeN10;
% b.ch10N = a.ChN10;
b.rough_u = a.zo;
b.rough_t = a.zot;
b.rough_q = a.zoq;
b.tau_bulk = a.tau;


end

% meteorological convention wind components positive to E (u) and positive to N (v): v = spd .* cos((dir+180)*pi/180); u = spd .* sin((dir+180)*pi/180)'

% [b.u_sfc, b.v_sfc] = sd_to_uv_met(a.wspd_sfc, a.wdir_sfc);
[b.u, b.v] = sd_to_uv_met(a.wspd, a.wdir);
[b.u_10n, b.v_10n] = sd_to_uv_met(a.u10n, a.wdir_sfc);

if k > 1
[b.tau_bulk_u, b.tau_bulk_v] = sd_to_uv_met(a.tau, a.wdir_sfc);
end

%%% question: if u and v components are computed explicity, I have to
%%% include multiple versions based on whether it's relative to water or
%%% ocean, and the need for that would vary by application or group. I
%%% think it's better to provide the simple formula for people to calculate
%%% it themselves. 


%%% time, navigation
vars1 = {'lat';'lon';...
'cog';'sog';'heading';...
'flag_bad_bulk';...
'year';'month';'day';'hour';'minute';};

if more_fluxes == 1
vars1 = {'lat';'lon';...
'cog';'sog';'heading';...
'flag_bad_ship';'flag_bad_bulk';...
'year';'month';'day';'hour';'minute';};
end

% excluded for this particular cruies:
%    wave_height, wave_cp, 
%   allll the wxt variables, if they are even useful to save?
%    wspd_wxt';'wdir_wxt';'rspd_wxt';'rdir_wxt';...
%        'Ta_wxt';'qa_wxt';'rh_wxt';'rhoa_wxt';'H2O_wxt';...
%        'prate_wxt';'paccum_wxt';'psealevel_wxt
%   ship variables... which confuse people
%       'tair_ship'; ;'psealevel_ship' 'wspd_ship' 'wdir_ship';
%       'sw_up_ship'; 'lw_up_ship' 'sw_down_ship'; 'lw_down_ship'
%   ship variables... which were actually bad on this cruise
%       rhair_ship, prate_ship,

%%% met and seawater, including warm layer and cool skin
vars2 = {'tair';'tair_2';'tair_10';'tair_10n';...
'rhair';'rhair_2';'rhair_10';...
'qair';'qair_2';'qair_10';'qair_10n';...
'rhoair';'rhoair_10';...
'prate';'paccum';'psealevel';'pair_10';...
'rdir';'rspd';'wdir';...
'wspd';'wspd_2';'wspd_2n';'wspd_10';'wspd_10n';...
'u';'v';'u_10n';'v_10n';...
'tskin';'qskin';'tsea';'qsea';'tsea_in_ship';'tsea_ship';'ssea_ship';...
'dt_skin';'dz_skin';'dt_warm';'dz_warm';'dt_warm_to_skin';...
'wave_edis';'wave_whitecap_frac';...
'sw_down';'sw_down_clear';'sw_up';...
'lw_down';'lw_down_clear';'lw_up';};

% took out wspd_sfc and wdir_sfc 'u_sfc';'v_sfc' for now

% 'cspd';'cdir';'wave_sigheight';'wave_phasespd';'wave_period';'wave_edis';'wave_whitecap_frac';...


%%% fluxes
if more_fluxes == 1
    vars3 = {'hnet';'hs_bulk';...
    'hs_cov';'hs_id';
    'hl_bulk';'hl_webb';
    'hl_cov';'hl_id';
    'hrain';'hb_bulk';...
    'tau_cov';'tau_cov_cross';'tau_id';...
    'tau_bulk';'tau_bulk_u';'tau_bulk_v';'tilt';'mo_length';...
    'ustar';'tstar';'qstar';'cd';'ce';'ch';'cdn10';'cen10';'chn10';...
    'erate';'rough_u';'rough_t';'rough_q';'gust'};
else
    vars3 = {'hnet';'hs_bulk';...
    'hl_bulk';'hl_webb';
    'hrain';'hb_bulk';...
    'tau_bulk';'tau_bulk_u';'tau_bulk_v';'mo_length';...
    'ustar';'tstar';'qstar';'cd';'ce';'ch';'cdn10';'cen10';'chn10';...
    'erate';'rough_u';'rough_t';'rough_q';'gust'};
end

if k > 1
    vars = vertcat(vars1, vars2, vars3);
else
    vars = vertcat(vars1, vars2);
end

% make new array c for the variables we want to save from a (input) and b (new)
disp(['var = time ...  n(NaN) = ' sprintf('%i',length(find(isnan(time) == 1)) )]);

for i = 1:length(vars)
    % if field is not already defined above with a special name or special
    % sign convention above, then grab the field with the same name from
    % the input structure a (e1, e10, e60);
    if isfield(b,vars{i}) ~= 1
        eval(['c.' vars{i} ' = a.' vars{i} ';']);
    % or grab the new b field
    else
        eval(['c.' vars{i} ' = b.' vars{i} ';']);
    end
    %%% reset nans to fill value
    clear bad_data thisvar;

    eval(['thisvar = c.' vars{i} ';']);
    bad_data = find(isnan(thisvar)==1);
    disp(['var = ' vars{i} ' ... n(NaN) = ' sprintf('%i',length(bad_data)) ]);
    if strcmp(vars{i},'t') == 0 && strcmp(vars{i},'jd') == 0 && ...
        strcmp(vars{i},'lat') == 0 && strcmp(vars{i},'lon') == 0 && ...
        contains(vars{i},'flag') == 0
%         strcmp(vars{i},'year') == 0 && strcmp(vars{i},'month') == 0 && ...
%         strcmp(vars{i},'day') == 0 && strcmp(vars{i},'hour') == 0 && ...
%         strcmp(vars{i},'minute') == 0 
            thisvar(bad_data) = fillval;
            eval(['c.' vars{i} ' = thisvar;']);
    end

end

thefields = fields(c);
nf = length(thefields);

%% assign netcdf variable attributes
[units, standard_names, long_names, comments, types, heights,...
    instruments, locations, methods] = ...
    assign_nc_info(thefields, nf, ins, ins_ship);
for j = 1:nf
    if isempty(units{j}) == 1
        disp(['missing unit for field ' sprintf('%i',j) ' = ' string(thefields(j))]);
    end
    if isempty(standard_names{j}) == 1
        disp(['missing standard name for field ' sprintf('%i',j) ' = ' string(thefields(j))]);
    end
    if isempty(long_names{j}) == 1
        disp(['missing longname for field ' sprintf('%i',j) ' = ' string(thefields(j))]);
    end    
    if isempty(types{j}) == 1
        disp(['missing type for field ' sprintf('%i',j) ' = ' string(thefields(j))]);
    end    
end

%%% write a table when 10-min file is being produced since that's when
%%% fluxes will be computed and listed 
if k == 2
    T = table(thefields, units, standard_names, long_names, comments, types, heights, instruments, locations, methods);
    writetable(T, [thedir cruise '_data_info.csv'],'Delimiter',',','QuoteStrings',true); 
end

%% readmes
make_readme = 0;
if make_readme == 1

readme_data_f10     = [pathreadme '_fields_' cruise '_' version_num '.txt'];
header_data_f10     = [pathreadme '_header_' cruise '_' version_num '.txt'];
fileID_d_f10 = fopen(readme_data_f10,'w');
fileID_h_f10 = fopen(header_data_f10,'w');

for j = 1:nfa
    formatSpec = 'i(%i) = %15s %-60s\n';
    fprintf(fileID_d_f10, formatSpec, j, string(thefields(j)), string(lf(j)) );
    fprintf(fileID_h_f10,'%20s',string(thefields(j)) );
end
fclose(fileID_d_f10);
fclose(fileID_h_f10);

end % if making readme


%% netcdf file construction
thedata = c;
vartypes = cell(nf,1);
dr = nan(nf,1);
dc = nan(nf,1);
% note: varname is an internal netcdf library reserved special name. do not use.
for i = 1:nf
    eval(['thisvar = thedata.' thefields{i} ';']);
    thevar = char(thefields(i));
    vartype = class(thisvar);
    vartypes(i) = {vartype};
    [dr(i), dc(i)] = size(thisvar);
%     disp([' saving ' thevar ' = ' vartype]);
end

dt = find(dr == length(time) & dc == 1);   % discretized in time
dn = find(dr > 2 & dr < 100 & dc == 1);          % some other short array or short readme
d1 = find(dr == 1 & dc == 1);                     % 1D fields
nd1 = length(d1);
ndn = length(dn);
ndt = length(dt);
% nd =  ndt;
disp([' out of ' sprintf('%i',nf) ' total vars, ' sprintf('%i',ndt) ' are accounted for and time discretized']);

% initialize file:
thenc = netcdf.create([thedir ncname], 'NETCDF4');

% define the dimensions

%%% for multiple trajectories
% [obs_dimlen,c]=size(jdy);
% trajectory_dimlen=1;  %number of cruise legs
% obs_dimID = netcdf.defDim(ncid,'obs',obs_dimlen); %simply length of data set
% traj_dimID= netcdf.defDim(ncid,'trajectory',trajectory_dimlen); %for single trajectory this dimension could be omitted but keep it for easiness and consistency for cruises with multiple legs
% dimIDs = [traj_dimID, obs_dimID];%used to pass the dimids of the dimensions of the NETCDF variables. All the NETCDF variables we are creating share the same dimensions.

ntime=length(time);

% create ID for (define) the dimensions
timedimID=netcdf.defDim(thenc,'time',ntime);

% time vars must be in seconds since first day of year. Must be double or float.
timeID=netcdf.defVar(thenc,'time','double',timedimID);
netcdf.putAtt(thenc,timeID,'units',['seconds since ' sprintf('%i',yr) '-01-01 00:00 UTC']);
netcdf.putAtt(thenc,timeID,'standard_name','time');
netcdf.putAtt(thenc,timeID,'long_name','time');
netcdf.putAtt(thenc,timeID,'comment','');
netcdf.putAtt(thenc,timeID,'method',...
   ['this time marks the beginning of the averaging interval, i.e. this time ' ...
    'is the leading bin edge for each bin average. values provided are averages '...
    'of all samples from this time step to the next time step. Only 1 good data '...
    'point was required for a valid average to be computed and reported. Data '...
    'were originally collected at intervals of 5 min (skin ocean temp ROSR), ' ...
    '1 min (radiation, temp, humidity, pressure, rain, sea water, extra met sensor), ' ...
    '10 Hz (wind, fast humidity, GPS, heading, pitch/roll, motion)']);
netcdf.putAtt(thenc, timeID,'coverage_content_type', 'coordinate');
netcdf.defVarFill(thenc,timeID,false,fillval);
netcdf.putAtt(thenc,timeID, 'axis', 'time'); % define that these are time (T) axis variables
netcdf.putVar(thenc,timeID,time); % actually put the variable in

theID = nan(ndt,1);
clear j;

%% create ID (define) for the rest of the time-based variables
for i = 1:ndt
    j = dt(i);
    theID(j) = netcdf.defVar(thenc,char(thefields(j)),char(vartypes(j)),timedimID);
end

% define the variable attributes
for i = 1:ndt

    netcdf.putAtt(thenc,theID(i),'units',               char(units{i}));

    if isempty(standard_names{i}) == 0  
        netcdf.putAtt(thenc,theID(i),'standard_name',   char(standard_names{i}));
    end
    
    netcdf.putAtt(thenc,theID(i),'long_name',           char(long_names{i}));
    
    if isempty(methods{i}) == 0 
        netcdf.putAtt(thenc,theID(i),'method',          char(methods{i}));
    end
    if isempty(comments{i}) == 0 
        netcdf.putAtt(thenc,theID(i),'comment',         char(comments{i}));
    end
    if isempty(heights{i}) == 0 
        netcdf.putAtt(thenc,theID(i),'height',          heights{i});
    end
    
    netcdf.putAtt(thenc,theID(i),'cdm_data_type',       char(types{i}));
    
    if isempty(instruments{i}) == 0 
        netcdf.putAtt(thenc,theID(i),'instrument',      char(instruments{i}));
    end
    if isempty(locations{i}) == 0 
        netcdf.putAtt(thenc,theID(i),'location',        char(locations{i}));
    end
    
    netcdf.defVarFill(thenc,theID(i),false,fillval);
    netcdf.putAtt(thenc,theID(i), 'axis', 'time'); % define that these are time (T) axis variables

    %%% other things that we could define for each variable but won't for now
    %     valid_range %%% ugh
    %     actual_range %%% ugh     
    %     platform %%% leaving out because it's the same for all variables in file... ? 
    %     statistic  %%% leave out because they are all means? 
    %     grid_mapping %%% only seems necessary if the dimensions are not lat/lon
    %     coordinates %%% only seems necessary if the dimensions are not lat/lon

end

%% define global attributes: Part 1
gvarid = netcdf.getConstant('GLOBAL');

acknowledgement_nc = 'Office of Naval Research Physical Oceanography program (for UND), and also in part by NOAA Global Ocean Monitoring and Observations program (for NOAA PSL)';
cdm_data_type_nc = 'Trajectory';
comment_nc = 'Corrections and Data Quality Notes not contained in global or variable attributes: Unavailable data, bad data, and data within restricted Exclusive Economic Zones were assigned _FillValue = -9999. Please use the variables named flag_bad_ship and flag_bad_bulk to further mask out questionable or non-ideal data points depending on the application for state variables and bulk fluxes respectively.';
% contributor_name_nc = 'Jay Orson Hyde and Joe (Hadrina) Fernando, Notre Dame University';
% contributor_role_nc = 'installation, maintenance, demobilization, and shipping of instruments';
conventions_nc = 'CF-1.6 ACCD-1.3';
coverage_content_type_nc = 'physicalMeasurement, qualityInformation, modelResult, coordinate';
creator_email_nc = 'elizabeth.thompson@noaa.gov';
creator_institution_nc = 'NOAA Physical Sciences Lab (PSL)';
creator_name_nc = 'Elizabeth J. Thompson, Ludovic Bariteau, Byron Blomquist, Chris Fairall, Sergio Pezoa';
creator_type_nc = 'group';
creator_url_nc = 'https://psl.noaa.gov/boundary-layer/';
contributor_name_nc = 'Joe (Harindra) Fernando, Jay Orson Hyde, Griffin Modjeski, Simon de Szoeke';
contributor_type_nc = 'group';
contributor_institution_nc = 'University of Notre Dame, Oregon State University';
contributor_url_nc = 'https://efmlab.nd.edu/people/efm-laboratory/harindra-j-fernando/';
geospatial_lat_units_nc = 'degrees_north';
geospatial_lon_units_nc = 'degrees_east';
geospatial_vertical_units_nc = 'meters';
% geospatial_vertical_positive = 'up'; % we don?t use this really because both depth and height are defined positive
history_nc = 'v1: first release, v2: reformatted second release if needed';
id_nc = 'doi = not yet assigned';
institution_nc = creator_institution_nc;
% instrument_nc = 'i';
instrument_vocabulary_nc = 'GCMD Version 12.3';
keywords_library_nc = 'GCMD Version 12.3';
licence_nc = 'Please acknowledge data and EKAMSAT / ASTRAL 2023-2024 project according to global attribute info: acknowledgement, creator info, contributor info. These data may be redistributed and used without restriction.';
% metadata_link_nc = 'xxx';
naming_authority_nc = 'gov.noaa.ncei';
platform_nc = 'R/V Thomas G. Thompson';
platform_vocabulary_nc = 'GCMD Version 12.3';
processing_level_nc = 'processed and quality controlled';
% product version is defined in program based on another field
program_nc = 'Funding provided by: ONR Physical Oceanography (UND participation) and NOAA Global Ocean Monitoring and Observations (NOAA PSL participation)';
project_nc = 'EKAMSAT / ASTRAL';
% publisher_email_nc = 'elizabeth.thompson@noaa.gov';
% publisher_institution_nc = 'NOAA Physical Sciences Laboratory';
% publisher_name_nc = 'Elizabeth J. Thompson';
% publisher_type_nc = 'person';
% publisher_url_nc = 'https://psl.noaa.gov/boundary-layer/';
references_nc = ['Fairall et al. 1996a JGR https://doi.org/10.1029/95JC03190 ...'  ...
'Fairall et al. 1996b JGR https://doi.org/10.1029/95JC03205 .... ' ...
'Fairall et al. 2003 JClim https://doi.org/10.1175/1520-0442(2003)016%3C0571:BPOASF%3E2.0.CO;2 ... ' ....
'Edson et al. 2013 JPO with corrigendum: the value should be m = 0.0017, and not m = 0.017 as originally appeared https://doi.org/10.1175/JPO-D-12-0173.1'];
source_nc = 'observations from NOAA PSL sensors, derivations from those observations using eddy covariance and inertial dissipation methods of estimating fluxes, model results from COARE 3.6 bulk air-sea flux algorithm.';
standard_name_vocabulary_nc = 'CF Standard Name Table, Version 77, 19 January 2021, https://cfconventions.org/Data/cf-standard-names/77/build/cf-standard-name-table.html';
summary_nc = 'Data collected from this cruise is critical for supporting the study of physical oceanography, air-sea interaction, tropical meteorology, as well as global weather and climate variability and predictability. This includes improvement to our fundamental understanding of these processes in the far western Pacific Ocean and their influence around the globe including the Continental United States. The data will also support improvement and validation of prediction models including parameterizations.';
title_nc = 'Ship-based data of navigation, meteorology, seawater, and air-sea fluxes from R/V Revelle in the Arabian sea in the EKAMSAT / ASTRAL 2023 experiment.';
sea_name_nc = 'Bay of Bengal';
ncei_template_version_nc = 'netCDF_single_trajectory_v2.0 ';


keywords_nc = [...
'EARTH SCIENCE > ATMOSPHERE > ATMOSPHERIC PRESSURE > AIR MASS/DENSITY; ' ...
'EARTH SCIENCE > ATMOSPHERE > ATMOSPHERIC PRESSURE > ATMOSPHERIC PRESSURE MEASUREMENTS; ' ...
'EARTH SCIENCE > ATMOSPHERE > ATMOSPHERIC PRESSURE > SEA LEVEL PRESSURE; ' ...
'EARTH SCIENCE > ATMOSPHERE > ATMOSPHERIC PRESSURE > SURFACE PRESSURE; ' ...
'EARTH SCIENCE > ATMOSPHERE > ATMOSPHERIC RADIATION > HEAT FLUX; ' ...
'EARTH SCIENCE > ATMOSPHERE > ATMOSPHERIC RADIATION > INCOMING SOLAR RADIATION; ' ...
'EARTH SCIENCE > ATMOSPHERE > ATMOSPHERIC RADIATION > LONGWAVE RADIATION > DOWNWELLING LONGWAVE RADIATION; ' ...
'EARTH SCIENCE > ATMOSPHERE > ATMOSPHERIC RADIATION > LONGWAVE RADIATION > UPWELLING LONGWAVE RADIATION; ' ...
'EARTH SCIENCE > ATMOSPHERE > ATMOSPHERIC RADIATION > LONGWAVE RADIATION; ' ...
'EARTH SCIENCE > ATMOSPHERE > ATMOSPHERIC RADIATION > NET RADIATION; ' ...
'EARTH SCIENCE > ATMOSPHERE > ATMOSPHERIC RADIATION > OUTGOING LONGWAVE RADIATION; ' ...
'EARTH SCIENCE > ATMOSPHERE > ATMOSPHERIC RADIATION > RADIATIVE FLUX; ' ...
'EARTH SCIENCE > ATMOSPHERE > ATMOSPHERIC RADIATION > SHORTWAVE RADIATION > DOWNWELLING SHORTWAVE RADIATION; ' ...
'EARTH SCIENCE > ATMOSPHERE > ATMOSPHERIC RADIATION > SHORTWAVE RADIATION; ' ...
'EARTH SCIENCE > ATMOSPHERE > ATMOSPHERIC RADIATION > SOLAR RADIATION; ' ...
'EARTH SCIENCE > ATMOSPHERE > ATMOSPHERIC TEMPERATURE > SURFACE TEMPERATURE > AIR TEMPERATURE; ' ...
'EARTH SCIENCE > ATMOSPHERE > ATMOSPHERIC TEMPERATURE > SURFACE TEMPERATURE > DEW POINT TEMPERATURE; ' ...
'EARTH SCIENCE > ATMOSPHERE > ATMOSPHERIC TEMPERATURE > SURFACE TEMPERATURE > POTENTIAL TEMPERATURE; ' ...
'EARTH SCIENCE > ATMOSPHERE > ATMOSPHERIC TEMPERATURE > SURFACE TEMPERATURE > SKIN TEMPERATURE; ' ...
'EARTH SCIENCE > ATMOSPHERE > ATMOSPHERIC TEMPERATURE > SURFACE TEMPERATURE > VIRTUAL TEMPERATURE; ' ...
'EARTH SCIENCE > ATMOSPHERE > ATMOSPHERIC WATER VAPOR > WATER VAPOR INDICATORS > HUMIDITY > RELATIVE HUMIDITY; ' ...
'EARTH SCIENCE > ATMOSPHERE > ATMOSPHERIC WATER VAPOR > WATER VAPOR INDICATORS > HUMIDITY > SATURATION SPECIFIC HUMIDITY; ' ...
'EARTH SCIENCE > ATMOSPHERE > ATMOSPHERIC WATER VAPOR > WATER VAPOR INDICATORS > HUMIDITY > SPECIFIC HUMIDITY; ' ...
'EARTH SCIENCE > ATMOSPHERE > ATMOSPHERIC WATER VAPOR > WATER VAPOR INDICATORS > HUMIDITY; ' ...
'EARTH SCIENCE > ATMOSPHERE > ATMOSPHERIC WATER VAPOR > WATER VAPOR INDICATORS > WATER VAPOR; ' ...
'EARTH SCIENCE > ATMOSPHERE > ATMOSPHERIC WATER VAPOR > WATER VAPOR PROCESSES > EVAPORATION; ' ...
'EARTH SCIENCE > ATMOSPHERE > ATMOSPHERIC WINDS > SURFACE WINDS > U/V WIND COMPONENTS; ' ...
'EARTH SCIENCE > ATMOSPHERE > ATMOSPHERIC WINDS > SURFACE WINDS > WIND DIRECTION; ' ...
'EARTH SCIENCE > ATMOSPHERE > ATMOSPHERIC WINDS > SURFACE WINDS > WIND SPEED; ' ...
'EARTH SCIENCE > ATMOSPHERE > ATMOSPHERIC WINDS > SURFACE WINDS; ' ...
'EARTH SCIENCE > ATMOSPHERE > CLOUDS > CLOUD RADIATIVE TRANSFER > CLOUD RADIATIVE FORCING; ' ...
'EARTH SCIENCE > ATMOSPHERE > PRECIPITATION > LIQUID PRECIPITATION > LIQUID SURFACE PRECIPITATION RATE; ' ...
'EARTH SCIENCE > ATMOSPHERE > PRECIPITATION > LIQUID PRECIPITATION > RAIN; ' ...
'EARTH SCIENCE > ATMOSPHERE > PRECIPITATION > LIQUID PRECIPITATION; ' ...
'EARTH SCIENCE > ATMOSPHERE > PRECIPITATION > PRECIPITATION AMOUNT; ' ...
'EARTH SCIENCE > ATMOSPHERE > PRECIPITATION > PRECIPITATION RATE; ' ...
'EARTH SCIENCE > OCEANS > OCEAN CIRCULATION > OCEAN CURRENTS > SUBSURFACE CURRENTS; ' ...
'EARTH SCIENCE > OCEANS > OCEAN CIRCULATION > OCEAN CURRENTS > SURFACE CURRENTS; ' ...
'EARTH SCIENCE > OCEANS > OCEAN CIRCULATION > OCEAN CURRENTS > SURFACE SPEED; ' ...
'EARTH SCIENCE > OCEANS > OCEAN CIRCULATION > OCEAN CURRENTS; ' ...
'EARTH SCIENCE > OCEANS > OCEAN HEAT BUDGET > HEAT FLUX > LATENT HEAT FLUX; ' ...
'EARTH SCIENCE > OCEANS > OCEAN HEAT BUDGET > HEAT FLUX > SENSIBLE HEAT FLUX; ' ...
'EARTH SCIENCE > OCEANS > OCEAN HEAT BUDGET > HEAT FLUX > TURBULENT HEAT FLUX; ' ...
'EARTH SCIENCE > OCEANS > OCEAN HEAT BUDGET > HEAT FLUX; ' ...
'EARTH SCIENCE > OCEANS > OCEAN HEAT BUDGET > HEATING RATE; ' ...
'EARTH SCIENCE > OCEANS > OCEAN HEAT BUDGET > LONGWAVE RADIATION; ' ...
'EARTH SCIENCE > OCEANS > OCEAN HEAT BUDGET > REFLECTANCE; ' ...
'EARTH SCIENCE > OCEANS > OCEAN HEAT BUDGET > SHORTWAVE RADIATION; ' ...
'EARTH SCIENCE > OCEANS > OCEAN HEAT BUDGET; ' ...
'EARTH SCIENCE > OCEANS > OCEAN PRESSURE > SEA LEVEL PRESSURE; ' ...
'EARTH SCIENCE > OCEANS > OCEAN TEMPERATURE > SEA SURFACE TEMPERATURE > SEA SURFACE  SUBSKIN TEMPERATURE; ' ...
'EARTH SCIENCE > OCEANS > OCEAN TEMPERATURE > SEA SURFACE TEMPERATURE > SEA SURFACE FOUNDATION TEMPERATURE; ' ...
'EARTH SCIENCE > OCEANS > OCEAN TEMPERATURE > SEA SURFACE TEMPERATURE > SEA SURFACE SKIN TEMPERATURE; ' ...
'EARTH SCIENCE > OCEANS > OCEAN TEMPERATURE > SEA SURFACE TEMPERATURE; ' ...
'EARTH SCIENCE > OCEANS > OCEAN TEMPERATURE > WATER TEMPERATURE; ' ...
'EARTH SCIENCE > OCEANS > OCEAN TEMPERATURE; ' ...
'EARTH SCIENCE > OCEANS > OCEAN WINDS > SURFACE WINDS > WIND DIRECTION; ' ...
'EARTH SCIENCE > OCEANS > OCEAN WINDS > SURFACE WINDS > WIND SPEED; ' ...
'EARTH SCIENCE > OCEANS > OCEAN WINDS > SURFACE WINDS; ' ...
'EARTH SCIENCE > OCEANS > OCEAN WINDS; ' ...
'EARTH SCIENCE > OCEANS > OCEAN WAVES > SIGNIFICANT WAVE HEIGHT; ' ... 
'EARTH SCIENCE > OCEANS > OCEAN WAVES > WAVE PERIOD; ' ... 
'EARTH SCIENCE > OCEANS > SALINITY/DENSITY > CONDUCTIVITY > SURFACE CONDUCTIVITY; ' ...
'EARTH SCIENCE > OCEANS > SALINITY/DENSITY > CONDUCTIVITY; ' ...
'EARTH SCIENCE > OCEANS > SALINITY/DENSITY > DENSITY; ' ...
'EARTH SCIENCE > OCEANS > SALINITY/DENSITY > OCEAN SALINITY > OCEAN SURFACE SALINITY; ' ...
'EARTH SCIENCE > OCEANS > SALINITY/DENSITY > OCEAN SALINITY > PRACTICAL SALINITY; ' ...
'EARTH SCIENCE > OCEANS > SALINITY/DENSITY > OCEAN SALINITY; ' ...
'EARTH SCIENCE > OCEANS > SALINITY/DENSITY > SALINITY; ' ...
'EARTH SCIENCE > OCEANS > SALINITY/DENSITY ' ...
];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

atts_traj = {...
'acknowledgement';'cdm_data_type';'comment';
'conventions';'coverage_content_type';'creator_email';'creator_institution';...
'creator_name';'creator_type';'creator_url';...
'contributor_name';'contributor_type';'contributor_institution';'contributor_url';...
'geospatial_lon_units';'geospatial_lat_units';...
'geospatial_vertical_units';'history';...
'id';'institution';'instrument_vocabulary';'keywords';'keywords_library';...
'licence';'naming_authority';'platform';'platform_vocabulary';...
'processing_level';'product_version';'program';'project';
'references';'source';'standard_name_vocabulary';'summary';
'title';'sea_name';'ncei_template_version'};

atts = atts_traj;

for h = 1:length(atts)
    eval(['netcdf.putAtt(thenc,gvarid, "' atts{h} '", ' atts{h} '_nc);']);
end

%% define global attributes: Part 1... these are easier to do with commands

netcdf.putAtt(thenc,gvarid,'date_created',datestr(now));
netcdf.putAtt(thenc,gvarid,'date_issued',datestr(now));
netcdf.putAtt(thenc,gvarid,'date_metadata_modified',datestr(now));
netcdf.putAtt(thenc,gvarid,'date_modified',datestr(now));
netcdf.putAtt(thenc,gvarid,'product_version',product_version_nc);

geospatial_lat_min_nc = sprintf('%8.3f', min(a.lat));
geospatial_lat_max_nc = sprintf('%8.3f', max(a.lat));
geospatial_lon_min_nc = sprintf('%8.3f', min(a.lon));
geospatial_lon_max_nc = sprintf('%8.3f', max(a.lon));
geospatial_bounds_nc = ['POLYGON [' geospatial_lon_min_nc ', ' geospatial_lon_max_nc ', ' geospatial_lat_min_nc ', ' geospatial_lat_max_nc ']'];
netcdf.putAtt(thenc,gvarid,'geospatial_lat_min',geospatial_lat_min_nc);
netcdf.putAtt(thenc,gvarid,'geospatial_lat_max',geospatial_lat_max_nc);
netcdf.putAtt(thenc,gvarid,'geospatial_lon_min',geospatial_lon_min_nc);
netcdf.putAtt(thenc,gvarid,'geospatial_lon_max',geospatial_lon_max_nc);
netcdf.putAtt(thenc,gvarid,'geospatial_lat_bounds',geospatial_bounds_nc);
netcdf.putAtt(thenc,gvarid,'geospatial_vertical_min',sprintf('%5.2f',-1*zsea_ship));
netcdf.putAtt(thenc,gvarid,'geospatial_vertical_max',sprintf('%5.2f',zu));

netcdf.putAtt(thenc,gvarid,'time_coverage_start', [datestr(min(a.t), 0) ' UTC']);
netcdf.putAtt(thenc,gvarid,'time_coverage_end',   [datestr(max(a.t), 0) ' UTC']);
netcdf.putAtt(thenc,gvarid,'time_coverage_duration', [sprintf('%6.3f',ndays) ' days']);

% % tell the netcdf file that you are done defining how it will work
netcdf.endDef(thenc);

%% write the data to the variables you just prepared.

for i = 1:ndt
   eval(['data = thedata.' thefields{i} ';']);
   netcdf.putVar(thenc,theID(i),data);
end


%% end process. IT IS VERY IMPORTANT TO CLOSE THE FILE!
netcdf.close(thenc)

disp(['saved netcdf file: ' ncname]);


%% check files;

disp(['---------------------------------- ncdisp for k = ' sprintf('%i',k) ';' ]);

% ncdisp([thedir ncname]);

end % for k = 1, 2, 3 for 1-min, 10-min, 60-min files
