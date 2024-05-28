ddd = 248;  % yearday
hhh = 00;  % hour

path_working_ddd = ['/Users/eliz/DATA/PISTON_2019/Sally/flux/Raw/19' sprintf('%03i',ddd)];
dfl = ['/Users/eliz/DATA/PISTON_2019/Sally/flux/Raw/19' sprintf('%03i',ddd) '/scs019' sprintf('%03i',ddd) sprintf('%02i',hhh) '_raw.txt'];
PosLims = [45    63     5    15];   % limits for map
SCS_adj = [0 0];
zpim = 15.6337;

% path_working_ddd = '/Users/eliz/DATA/PISTON_2019/Sally/flux/Raw/19248';
% dfl = '/Users/eliz/DATA/PISTON_2019/Sally/flux/Raw/19248/scs01924804_raw.txt';
% ddd = 9;  % yearday
% hhh = 5;  % hour
% PosLims = [119 139 4 27];   % limits for map
% SCS_adj = [0 0];
% zpim = 157;

%% see original file for more details of readme

%% apply constants and offsets
% K_pir = 3.01e-6;     % SCS RMR 37751 PIR cal coef, V/W/m2
% G_pir = 858.21;      % SCS RMR PIR amplifier gain
% voff = -2.6;         % SCS RMR PIR amplifier offset, mV
% sig_sb = 5.67e-8;    % Stefan Boltzmann constant
% C2K = 273.15;        % temp conversion constant
Td_adj = SCS_adj(1);
Tc_adj = SCS_adj(2);

%% reference timestamp for this hour of data at 1-sec interval
start = (ddd+hhh/24);
delta = double(1.0/86400);
last = start + 3599*delta;
% reference time stamp in julian date
jd_s = (start:delta:last)';

[FILEPATH,NAME,EXT] = fileparts(dfl);
yr_part = str2double(NAME(5:6));
if yr_part < 75
    the_year = 2000 +yr_part;
elseif yr_part > 75
    the_year = 1900+ yr_part;
end

% make a new number not susceptible to rounding, to check later for
% missing data with time_reported
time_ref = round(jd_s.*86400);

% make a matlab version of the full time array with 3600 sec in the hour
[the_mo, the_day] = yd2md(the_year, ddd);

% fill miniute array min_array = nan(3600,1);
for i = 1:60
    if i == 1
        min_array = repmat(i-1, 60, 1);
    else
        min_array = [min_array; repmat(i-1, 60, 1)];
    end
end
% fill seconds array
sec_array = repmat((0:59)',60,1);

% full matlab date and time array. 3600 members of 1-sec interval for 1 hr
t_s = datenum(the_year, the_mo, the_day, hhh, min_array, sec_array);
% t_disp_s = datetime(t_s);

%%% data fields from input file:
%     lat =       scs_raw(4,:);     % LA decimal lat
%     lon =       scs_raw(5,:);     % LO decimal lon
%     cogm =      scs_raw(6,:);     % CR ship course over ground, cog
%     sogm =      scs_raw(7,:);     % SP ship speed over ground, kt
%     lrg =       scs_raw(8,:);     % GY ship heading from gyrocompass, deg
%     imta =      scs_raw(9,:);     % AT air temp, deg C
%     imrh =      scs_raw(10,:);    % RH relative humidity, %
%     imdm =      scs_raw(11,:);    % TI true wind direction, deg, direction wind came from
%     imum =      scs_raw(12,:);    % TW true wind speed, m/s
%     imrwdir =   scs_raw(13,:);    % WD relative wind direction, deg, direction wind came from
%     imrwspd =   scs_raw(14,:);    % WS relative wind speed, m/s
%     tsgm =      scs_raw(15,:);                   % TT TSG temp deg C (bow water from TSG in bow thruster room)
%     tssm =      scs_raw(16,:);                   % SA TSG salinity PSU (bow water from TSG in bow thruster room)
%     imPress =   scs_raw(17,:) + pcorrection_scs; % BP barometric pressure, mb (not corrected for sea level), then we do that
%     imrs =      scs_raw(18,:);                   % SW short wave radiation from pyranometer, W/m2
%     imrl =      scs_raw(19,:);                   % LW long wave radiation from pyrgeometer, W/m2
%     imtc =      despike2(scs_raw(20,:))-273.15;  % LW long wave radiation body temp, deg K
%     imtd =      despike2(scs_raw(21,:))-273.15;  % LW long wave radiation dome temp, deg K
%     ipcum =     scs_raw(22,:);                   % PR cumulative precipitation, mm 


    %% fields in files
    
    % after date/time in first 3 fields, the SCS files had these fields
    the_fields = {'lat';'lon'; 'cog';'sog';'hed';'Ta';'rh';'wdir';'wspd';...
        'rdir';'rspd';'Ttsg1';'Stsg1';'press';'sw_dn';'lw_dn';'lw_T_case';'lw_T_dome';'paccum'};
    fs = length(the_fields);
    
    % these fields were then calculated
    full_fields = vertcat(the_fields,{'qa';'slp';'slp_reported';'sogN';'sogE'});

%% read data if file exists, if not return NaNs
% dfl = '/Users/eliz/DATA/ATOMIC/Brown/flux/Raw/20008/scs02000802_raw.txt';
if exist(dfl,'file')==2
    
    disp(['Reading scs file for hour ',int2str(hhh)]);
    flist = fopen(dfl,'r');      

    N=22; % columns of data in raw file
    temp = []; scs_raw = [];
    while ~feof(flist)
        try
            temp = textscan(flist,['%2f%2f%3f %*6f %*6f ',repmat('%*3c%f ',1,19),' %*[^\n]'],'delimiter',', ','headerlines',1,'emptyvalue',NaN,'MultipleDelimsAsOne',1);
            scs_raw = [scs_raw cell2mat(temp)'];
        catch
            [lnr2,~] = size(temp{1,N});
                if lnr2<=1
                    temp = [];
                else
                for ll=1:N
                    if length(temp{1,ll})~=lnr2
                        temp{1,ll}(lnr2+1)=[];
                    end
                end
                if ~isempty(temp{1,1})
                    scs_raw = [scs_raw cell2mat(temp)'];
                end
                end
        end
    end
    scs_raw = scs_raw';
    
%     [~,cols] =  size(scs_raw);
    jd_scs =    ddd + (hhh + (scs_raw(:,1)+(scs_raw(:,2)+scs_raw(:,3)/1000)/60)/60)/24;
    imin = scs_raw(:,1);
%     disp(imin(1));
    isec = scs_raw(:,2);
%     disp(isec(1));
    imsec = scs_raw(:,3);
%     disp(imsec(1));
    the_sec = round(isec + imsec/1000);

    % make a matlab version of the full time array with 3600 sec in the hour
    [the_mo, the_day] = yd2md(the_year, ddd);
    t = datenum(the_year, the_mo, the_day, hhh, imin, the_sec);
    %%% time_reported be used later for locating much missing data
    time_reported = round(jd_scs.*86400);
    
    for i = 4:22
       eval([the_fields{i-3} ' = scs_raw(:,i);'])
    end

    %% close file
    fclose(flist);


    %% derived data... cruise dependent

    % convert from kt to m/s
    sog     = sog./1.944;
%     wspd_f  = wspd./1.944;
%     rspd_f  = rspd./1.944;

    %%% how barometric pressure corrections are handled by scs
    % zpim is elevation of sensor in m

    %%% how barometric pressure corrections are handled by scs
    % zpim is elevation of sensor in m
    pcorrection_ship     = 1013.25 *( 1 - ( 1 - zpim/44307.69231 ) ^5.253283 );
    pcorrection_noaa    = 0.125*zpim;
    % difference is 0.0743;
    slp = press + pcorrection_noaa;
    slp_reported = press + pcorrection_ship;
   
    % compute specific humidity
    qa = qair_p(Ta, rh, press); 
    
    %% clean up lat/lon if necessary
%     lon(lon<PosLims(1)) = NaN;
%     lon(lon>PosLims(2)) = NaN;
%     lat(lat<PosLims(3)) = NaN;
%     lat(lat>PosLims(4)) = NaN;
    lat = despike2(lat); % despike & replace NaNs
    lon = despike2(lon);

    %% check for unreasonable values
%     imrs(imrs>2500) = NaN;
%     imrs(imrs<-20) = NaN;
%     imrl(imrl>1500) = NaN;
%     imrl(imrl<-20) = NaN;
%     paccum(paccum < 0) = NaN;    
    Stsg1(Stsg1>40) = NaN;
    Stsg1(Stsg1<25) = NaN;
    Ttsg1(Ttsg1>50) = NaN;
    Ttsg1(Ttsg1<-2) = NaN;
%     Stsg2(Stsg2>40) = NaN;
%     Stsg2(Stsg2<25) = NaN;
%     Ttsg2(Ttsg2>50) = NaN;
%     Ttsg2(Ttsg2<-2) = NaN;
%     imts(imts>50) = NaN;
%     imts(imts<-2) = NaN;
    cog(cog>360) = NaN;
    cog(cog<0) = NaN;
%     wdir_f(wdir_f>360) = NaN;
%     wdir_f(wdir_f<0) = NaN;
%     wspd_f(wspd_f<0) = NaN;
%     wspd_f(wspd_f>50) = NaN;
    sog(sog>20) = NaN;
    Ta(Ta>50) = NaN;
%     prcum(prcum>100) = NaN;
%     qa(qa>25) = NaN;
    qa(qa<0.5) = NaN;
    rh(rh>100) = 100;
    rh(rh<0) = NaN;

    %% despike and replace NaNs with nearest neighbor
    cog = unwrap(cog*pi/180); % unwrap and convert to radians
    [cog,~] = despike2(cog);

    hed = unwrap(hed*pi/180); % unwrap and convert to radians
    [hed,~] = despike2(hed);
    
    %%% 2D sonic on mast
    [wspd,~] = despike2(wspd);
    [rspd,~] = despike2(rspd);
    wdir = unwrap(wdir*pi/180); % unwrap and convert to radians
    [wdir,~] = despike2(wdir);
    rdir = unwrap(rdir*pi/180); % unwrap and convert to radians
    [rdir,~] = despike2(rdir);

%     %%% just despike the rest... why do this on some of the vars and not
%     %%% others?
%     [slp,~] = despike2(slp);
%     [qa,~] = despike2(qa);
    
    
    %%% ship speed components
    sogN = sog.*cos(cog);
    sogE = sog.*sin(cog);
    
    %%% convert heading, cog, and all wind directions back to degrees
    %%% option 'y' for unwrapping or 'n' for not. 
    hed     = rad2deg_wind(hed);
    cog     = rad2deg_wind(cog);
    
    rdir    = rad2deg_wind(rdir);
    wdir    = rad2deg_wind(wdir);
    
    rdir    = relwind_wrap(rdir);
    
    %% format output structure called scs with all reported data, derived data, and matlab & jd time fields
  
    %%% some time entries are repeated. Make sure they don't count.
    [time_unique_0, ID_unique_0] = unique(time_reported);
    
    %%% throw out data that exceeds or comes before t_s; 
    %%% sometimes this happens because the time stamp / logger slips forward
    overtime = find(time_unique_0 > time_ref(end));
    undertime = find(time_unique_0 < time_ref(1));
    badtimes = [undertime overtime];
    time_unique = time_unique_0;
    ID_unique = ID_unique_0;
    if ~isempty(badtimes)
        time_unique(badtimes) = [];
        ID_unique(badtimes) = [];
    end

    %%% fill missing values for full 3600 seconds in the hour
    not_reported = find(ismember(time_ref, time_reported) == 0);
    reported = find(ismember(time_ref, time_reported) == 1);
    
    clear scs;
    %%% dropping _s suffix for time varibales in final structure
    scs.jd = jd_s;
    scs.t = t_s;
        
    if length(reported) ~= length(ID_unique)
     disp(['*** n(reported)= ' sprintf('%i',length(reported)) ' ... but n(ID_unique)= ' sprintf('%i',length(ID_unique))]);
    end
    % this is for everything but t and jd... since the vars with those
    % prefixes already exist in this program and have been added without
    % the prefixes to the structure already.
    for i = 1:length(full_fields)
        eval([full_fields{i} '_s = nan(3600,1);']);
        eval([full_fields{i} '_s(reported) = ' full_fields{i} '(ID_unique);']);
        eval(['scs.' full_fields{i} ' = ' full_fields{i} '_s;']);
    end
    
%     disp('size of ship dataset: time x fields');
%     disp(size(scs));
else
    
    %%% create empty structure for this hour
    disp('file does not exist');
        
    clear scs;
    scs.jd = jd_s;
    scs.t = t_s;
        
    for i = 1:length(full_fields)
        eval(['scs.' full_fields{i} ' = nan(3600,1);']);
    end
    
    
end %%% end of file i/o check and read loop
