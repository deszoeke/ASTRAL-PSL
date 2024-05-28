function scsm = read_scs_day_old(path_working_ddd,ddd,yyyy,PosLims,SCS_adj,zpim)
%{
Reads hourly scs files for one day and returns array with the
following columns:

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
    20   impir raw PIR thermopile, W/m2
    21   imtc PIR case temp, C
    22   imtd PIR dome temp, C
    23   imrwspd relative wind speed, m/s
    24   imrwdir relative wind dir, +/- 180 deg from bow
    25   Ngps, m/s
    26   Egps, m/s
    27   imrl2, recomputed imrl, W/m2

input parameters: path_working_ddd = path to daily data folder
                  ddd = julian date
                  yyyy = year string
                  PosLims = lat/lon limits for filtering position data
%}

fclose all;

scsm = NaN(86400,27);
delta = double(1.0/86400);
last = ddd + 86399*delta;
jd_ref = ddd:delta:last;	% ref 1 Hz timestamp
scsm(:,1) = jd_ref(1:end)';
jd = sprintf('%03i',ddd);

for hhh = 0:23              % cycle thru 24 hourly files
    hr = sprintf('%02i',hhh);
    dfl = fullfile(path_working_ddd,['scs0' yyyy(3:4),jd,hr,'_raw.txt']);
    if exist(dfl,'file')==2
        scs = read_scs(dfl,ddd,hhh,PosLims,SCS_adj,zpim);
    else
        continue % no data this hour
    end
    jd_scs = scs(:,1);
    
    % match jd_scs to closest jd_ref and copy data over
    % this preserves gaps in data as NaNs in scsm
    for ii=1:length(scs)
        [~,zz] = min(abs(jd_scs(ii) - jd_ref));
        scsm(zz,2:27) = scs(ii,2:27);
    end

end

end
