function [scs] = read_scs(dfl,ddd,hhh,PosLims,SCS_adj,zpim)
%{
reads scs file specified by dfl and returns array with the
following columns:

test with: scs = read_scs(dfl,ddd,hhh,PosLims,SCS_adj,zpim)
% path_working_ddd = '/Users/eliz/DATA/ATOMIC/Brown/flux/Raw/20008';
% dfl = '/Users/eliz/DATA/ATOMIC/Brown/flux/Raw/20008/scs02000802_raw.txt';
% ddd = 8;  % yearday
% hhh = 2;  % hour
% PosLims = [45    63     5    15];   % limits for map
% SCS_adj = [0 0];
% zpim = 15.6337;

% testing of:
    %%% input parameters: dfl = string path to scs file
                  ddd = julian date
                  hhh = hour
                  PosLims = lat/lon limits for filtering position data

    %%% output: currently 38 parameters but could change each cruise.

    %%% input/output data 
%     t             (calculated here) matlab date/time
%     jd            (calculated here) julian date, need to print out past 5th decimal place to see the precision to 1 sec    
%     lat           Lat DDDMM.MM, primary gps
%     lon           Lon DDDMM.MM, primary gps
%     cog           COG deg, primary gps
%     sog           SOG kts, primary gps * 0.514 for m/s
%     Ttsg          T SBE38, C
%     Stsg          S SBE45, psu
%     rh            RH, %
%     Ta            air T, C
%     rs            solar, W/m2
%     rl            IR, W/m2
%     hed           heading POSMV, deg
%     wspd_f        true wind speed, kt, foremast rotating propellor
%     wdir_f        true wind dir, deg, foremast rotating propellor
%     slp_reported  pressured corrected for MSL by ship, mb
%     
%     pitch         pitch POSMV, deg
%     roll          roll POSMV, deg
%     heave         heave POSMV, m
%     rspd_f        relative wind speed, kt, foremast rotating propellor
%     rdir_f        relative wind direction, deg, foremast rotating propellor
%     
%     wspd_s        true wind speed, kt, starboard 2D sonic
%     wdir_s        true wind dir, deg, starboard 2D sonic
%     rspd_s        rel wind speed, kt, starboard 2D sonic
%     rdir_s        rel wind dir, deg, starboard 2D sonic
%             
%     wspd_p        true wind speed, kt, port 2D sonic
%     wdir_p        true wind dir, deg, port 2D sonic
%     rspd_p        rel wind speed, kt, port 2D sonic
%     rdir_p        rel wind dir, deg, port 2D sonic
%     Td            dew point T, C
%     Fl            fluorometer dry value micrograms/L
%     Ctsg          C SBE45 (S/m)
%     Ttsg_int      T of internal sensor SBE45 (C)
%     press         measured barometric pressure, mb

    %%% calculated here:
%     slp           pressure corrected to MSPL by NOAA equations, mb
%     qa            specific humidity of air, g/kg
%     sogE          eastward sog, kt (aka Egps)
%     sogN          northward sog, kt (aka Ngps)


original output file... kind of antiquated because doesn't carry everything
we need or take into account different ship sensors. 
    1    Decimal DOY
    2    Lat
    3    Lon
    4    COG
    5    SOG, m/s
    6    tsgm  TSG temperature
    7    tssm  TSG salinity
    8    imrh RH, @ 15.5 m
    9    imta air temp, C, @ 15.5 m
    10   imrs downwelling solar radiation, W/m2
    11   orgm rain rate (no data)
    12   lrg heading, deg
    13   imum true wind speed, m/s
    14   imdm true wind direction
    15   imrl downwelling IR, W/m2
    16   imPress sealevel pressure, mb
    17   imqa specific humidity, g/kg
    18   imts SST at intake, C
    19   imrosr radiometric SST, C
    20   impir raw PIR thermopile, mV
    21   imtc PIR case temp, C
    22   imtd PIR dome temp, C
    23   rspd_f relative wind speed, m/s
    24   rdir_f relative wind dir, +/- 180 deg from bow
    25   sogN, N ship speed component, m/s
    26   sogE, E ship speed component, m/s
    27   imrl2 recomputed longwave radiation, W/m2


%}

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
t_s = datenum(2020, the_mo, the_day, hhh, min_array, sec_array);
% t_disp_s = datetime(t_s);


%%% data fields:

    %%% first set of SCS files had these fields
    fields_1 = {'cog';'sog'; 'Ttsg';'Stsg';'rh';'Ta';'sw';'lw';'hed';...
        'wspd_f';'wdir_f';'slp_reported';'pitch';'roll';'heave';'rspd_f';'rdir_f';...
        'wspd_s';'wdir_s';'rspd_s';'rdir_s'; ...
        'wspd_p';'wdir_p';'rspd_p';'rdir_p'};
    fs_1 = length(fields_1);

    %%% these fields were included in files at second date
    more_fields ={'Td';'Fl';'Ctsg';'Ttsg_int';'press'};  
    fields_2 = vertcat(fields_1,more_fields);
    fs_2 = length(fields_2);
    
    %%% then these fields were added too
    more_more_fields = {'lw_T_case';'lw_T_dome'};
    
    fields_all = vertcat(fields_1,more_fields, more_more_fields);
    fs_all = length(fields_all);
    
    %%% these fields were calculated
    full_fields = vertcat({'lat';'lon'},fields_all,{'qa';'press';'slp';'sogN';'sogE'});

    

%% read data if file exists, if not return NaNs
% dfl = '/Users/eliz/DATA/ATOMIC/Brown/flux/Raw/20008/scs02000802_raw.txt';
if exist(dfl,'file')==2
    
    disp(['Reading scs file for hour ',int2str(hhh)]);
    fileID = fopen(dfl,'r');      
    if min(t_s) < datenum(2020,1,9,22,0,0)
        format_str = ['%2f%2f%3f%1s%10s %f %2f%7.4f%s %3f%7.4f%s ',repmat('%f ',1,25) ,' %*[^\n]'];
    elseif min(t_s) >= datenum(2020,1,9,22,0,0) && min(t_s) < datenum(2020,1,12,19,0,0)
        format_str = ['%2f%2f%3f%1s%10s %f %2f%7.4f%s %3f%7.4f%s ',repmat('%f ',1,30) ,' %*[^\n]'];
    else
        format_str = ['%2f%2f%3f%1s%10s %f %2f%7.4f%s %3f%7.4f%s ',repmat('%f ',1,32) ,' %*[^\n]'];
    end
    b = textscan(fileID,format_str,'delimiter',',','headerlines',1);
    [nrows, nreturns] = size(b{1});

    %%% Notes about this read format:
    % - output cell array b can be used with b{1} for 1 instance or b(1)
    % for all instances of that array. Cannot do cell2mat unless all the
    % same "type of data"
    % - ignores 1 header line
    % - handles strings, slashes, and spaces... but only actually parses at ','
    % - the ' %*[^\n]' means "ignore everything else on this line and go to next
    % for some reason, there are more digits saved for lon than lat... and
    %     this in decimal minutes. And there is a N and W, and there are multiple
    %     delimiters that we have to deal with... hmmm. But I'm smart enough to
    %     figure this out.

    %%% testing examples of read statements for textscan:
    %%% PISTON            
    %     0003231 300519,050003,LA: 7.6628 LO:87.3950 CR:285.74            

    %%% ATOMIC 
    %     01/08/2020 13:00 Ronald H Brown SCS Data (SN: RHB)   % header line 1
    % 0000152 01/08/2020,125958.500,1336.9254N,05627.5370W,334.6.... % 1st data line



    %% figure out time
    ihr = ones(nrows, 1)*hhh;
    % calculate day fraction:
    imin = cell2mat(b(1)); %= minutes PSD
    isec = cell2mat(b(2)); %= seconds PSD
        % b{3} %= nothing... extra meaningless digits
        % b{4} %= nothing from space
    date_strings = cell2mat(b{5});
%     [iyr, imo, iday] = datevec(date_strings,'MM/DD/YYYY');
    imo = extractBefore(date_strings(1,:),'/');
    imos = ones(nrows,1)*imo;
    iday = str2double(extractBetween(date_strings(1,:),'/','/'));
    idays = ones(nrows,1)*iday;
    iyrs = ones(nrows,1)*the_year;

    % Ex: days(duration(5,3,10)) gives fraction of a day for 5 hours, 3 minutes,
        % 10 seconds... > 4 digits of precision output are needed to see difference
    dayfraction = days(duration(ihr, imin, isec));
        % dayfraction_2 = (ihr + (imin + (isec./60))./60)./24;  %% equivalent
        % sprintf('%10.5f',dayfraction(2))
    % calculate true julian date
    jd = ddd+dayfraction;
    % calcualte matlab date and time
    t = datenum(iyrs, imos, idays, ihr, imin, isec);
    %%% time_reported be used later for locating much missing data
    time_reported = round(jd.*86400);
    
    %% location
    % b{6} = ship posmv time
    deg_lat = cell2mat(b(7));% = degrees lat
    dmin_lat = cell2mat(b(8));% = decimal minutes lat
    lat = deg_lat + dmin_lat./60;
    % b{9} = 'N'
    %%% use negative signs instead of N/S convention
    if strcmp(b{9},'S') == 1
        lat = -1*(lat);
    end
    
    deg_lon = cell2mat(b(10));% = degrees lon
    dmin_lon = cell2mat(b(11));% = decimal minutes lon
    lon = deg_lon + dmin_lon./60;
    % b{12} = 'W'
    %%% use negative signs instead of E/W convention
    if strcmp(b{12},'W') == 1
        lon = -1*(lon);
    end
        
    %%% assign the remaining dataarrays to field names
    % choose the field name list, 1 or 2
    if min(t_s) < datenum(2020,1,9,22,0,0)
        ftype = 1;
    elseif min(t_s) >= datenum(2020,1,9,22,0,0) && min(t_s) < datenum(2020,1,12,19,0,0)
        ftype = 2;
    else
        ftype = 3;
    end
    

    if ftype == 1
        fields = fields_1;
        for i = 13:37
        %     data = cell2mat(b(i));
            eval([fields{i-12} ' = cell2mat(b(i));'])
        end
        %%% fill in missing datastreams
        Td = nan(nrows,1);
        Fl = nan(nrows,1);
        Ctsg = nan(nrows,1);
        Ttsg_int = nan(nrows,1);
        press = slp_reported-2;
        lw_T_case = nan(nrows,1);
        lw_T_dome = nan(nrows,1);
        

    elseif ftype ==2
        fields = fields_2;
        for i = 13:42
            eval([fields{i-12} ' = cell2mat(b(i));'])
        end
        lw_T_case = nan(nrows,1);
        lw_T_dome = nan(nrows,1);
        
    elseif ftype ==3
        fields = fields_all;
        for i = 13:44
            eval([fields{i-12} ' = cell2mat(b(i));'])
        end
    end

    %% close file
    fclose(fileID);

    %% derived data... cruise dependent
    %%% units issue prior to 01/09/2020,21:03:33... true wsdp was in m/s
    %%% instead of kt (rest of them are in kt).
    
    % convert portion of 21st hour on 1/9/20 from m/s to kt
    if min(t_s) < datenum(2020,1,9,22,0,0)
        ccc = find(t <= datenum(2020,1,9,21,3,33));
        rspd_f(ccc) = rspd_f(ccc).*1.944;
    %%% convert all time less than 1/9/20 21:00 from m/s to kt
    elseif min(t_s) < datenum(2020,1,9,21,0,0)
        rspd_f = rspd_f.*1.944;
    end
        

%     if ddd < 10
%         tbefore = find(t < datenum(2020,1,9,21,0,0));
%         if ~isempty(tbefore)
%             wspd_f(tbefore) = wspd_f(tbefore).*1.944;
%         end
%     end

    % convert from kt to m/s
    sog     = sog./1.944;
    wspd_f  = wspd_f./1.944;
    rspd_f  = rspd_f./1.944;
    wspd_p  = wspd_p./1.944;
    rspd_p  = rspd_p./1.944;
    wspd_s  = wspd_s./1.944;
    rspd_s  = rspd_s./1.944;

    %%% how barometric pressure corrections are handled by scs
    % zpim is elevation of sensor in m
    pcorrection_scs     = 2;   %%% RHB just uses slope of 1 and adds 2 for their mslp correction
    pcorrection_noaa    = 0.125*zpim;  %%% noaa version of correction for mslp = 1.9542 for RHB
    slp = press + pcorrection_noaa;
   
    % compute specific humidity
    qa = qair_p(Ta, rh, press); 
    
    %% clean up lat/lon if necessary
    lon(lon<PosLims(1)) = NaN;
    lon(lon>PosLims(2)) = NaN;
    lat(lat<PosLims(3)) = NaN;
    lat(lat>PosLims(4)) = NaN;
    lat = despike2(lat); % despike & replace NaNs
    lon = despike2(lon);

    %% check for unreasonable values
%     imrs(imrs>2500) = NaN;
%     imrs(imrs<-20) = NaN;
%     imrl(imrl>1500) = NaN;
%     imrl(imrl<-20) = NaN;
%     ipcum(ipcum < 0) = NaN;    
    Stsg(Stsg>40) = NaN;
    Stsg(Stsg<25) = NaN;
    Ttsg(Ttsg>50) = NaN;
    Ttsg(Ttsg<-2) = NaN;
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
    qa(qa>25) = NaN;
    qa(qa<0.5) = NaN;
    rh(rh>100) = 100;
    rh(rh<0) = NaN;

    %% despike and replace NaNs with nearest neighbor
    cog = unwrap(cog*pi/180); % unwrap and convert to radians
    [cog,~] = despike2(cog);

    hed = unwrap(hed*pi/180); % unwrap and convert to radians
    [hed,~] = despike2(hed);
    
    %%% propellor vane
    [wspd_f,~] = despike2(wspd_f);
    [rspd_f,~] = despike2(rspd_f);
    wdir_f = unwrap(wdir_f*pi/180); % unwrap and convert to radians
    [wdir_f,~] = despike2(wdir_f);
    rdir_f = unwrap(rdir_f*pi/180); % unwrap and convert to radians
    [rdir_f,~] = despike2(rdir_f);
    
    %%% starboard ultrasonic
    [wspd_p,~] = despike2(wspd_p);
    [rspd_p,~] = despike2(rspd_p);
    wdir_p = unwrap(wdir_p*pi/180); % unwrap and convert to radians
    [wdir_p,~] = despike2(wdir_p);
    rdir_p = unwrap(rdir_p*pi/180); % unwrap and convert to radians
    [rdir_p,~] = despike2(rdir_p);
    
    %%% port ultrasonic
    [wspd_s,~] = despike2(wspd_s);
    [rspd_s,~] = despike2(rspd_s);
    wdir_s = unwrap(wdir_s*pi/180); % unwrap and convert to radians
    [wdir_s,~] = despike2(wdir_s);
    rdir_s = unwrap(rdir_s*pi/180); % unwrap and convert to radians
    [rdir_s,~] = despike2(rdir_s);
    
    
%     %%% just despike the rest... why do this on some of the vars and not
%     %%% others?
%     [slp,~] = despike2(slp);
%     [qa,~] = despike2(qa);
    
    
    %%% ship speed components
    sogN = sog.*cos(cog);
    sogE = sog.*sin(cog);
    
    %%% convert heading, cog, and all wind directions back to degrees
    %%% option 'y' for unwrapping or 'n' for not. 
    hed         = rad2deg_wind(hed);
    cog         = rad2deg_wind(cog);
    
    rdir_f      = rad2deg_wind(rdir_f);
    rdir_p      = rad2deg_wind(rdir_p);
    rdir_s      = rad2deg_wind(rdir_s);
    wdir_f      = rad2deg_wind(wdir_f);
    wdir_p      = rad2deg_wind(wdir_p);
    wdir_s      = rad2deg_wind(wdir_s);
    
    rdir_f = relwind_wrap(rdir_f);
    rdir_p = relwind_wrap(rdir_p);
    rdir_s = relwind_wrap(rdir_s);
    
    %% format output structure called scs with all reported data, derived data, and matlab & jd time fields
  
    %%% some time entries are repeated. Make sure they don't count.
    
    
    [time_unique, ID_unique] = unique(time_reported);
   
    %%% fill missing values for full 3600 seconds in the hour
    not_reported = find(ismember(time_ref, time_reported) == 0);
    reported = find(ismember(time_ref, time_reported) == 1);

    %%% dropping _s suffix for time varibales in final structure
    scs.jd = jd_s;
    scs.t = t_s;
        
%     disp(['reported: ' sprintf('%i',size(reported)) ' ... ID_unique: ' sprintf('%i',size(ID_unique))]);

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

end  %%% end of function

