function B = coare35vnWarm_et(yday,U,zu,Tair,zt,RH,zq,P,Tsea,Solar,IR,Lat,Lon,zi,Rainrate,ts_depth,zref)

disp('WarmCoolLayer')

%***********   input data **************
%***********   input data **************
%     yday = day-of-year
%	     U = wind speed magnitude (m/s) corrected for currents, i.e. relative to water at height zu
%	    zu = height (m) of wind measurement
%	  Tair = air temp (degC) at height zt
%	    zt = height (m) of air temperature measurement
%	    RH = relative humidity (%) at height zq
%	    zq = height (m) of air humidity measurement
%	     P = air pressure at sea level (mb) 
%     Tsea = surface sea temp (degC) at ts_depth
%	 Solar = downward solar flux (w/m^2) defined positive down
%	    IR = downward IR flux (w/m^2) defined positive down
%	   Lat = latitude (deg N=+)
%	   Lon = longitude (deg E=+)
%       zi = inversion height (m)
% Rainrate = rain rate (mm/hr)
% ts_depth = depth (m) of water temperature measurement
%       Ss = sea surface salinity (PSU)
%       cp = phase speed of dominant waves (m/s)  
%     sigH = significant wave height (m)
% zu, zt, zq = heights of the observations (m)
% zref = reference height for profile.
%

%********** output data  ***************
%Outputs
% From coare36vn_zrf_et
% .... see that function for updated output. It can change. This function adds 3 variables onto it:
%From WarmLayer
% dt_wrm -> dT_warm = warming across entire warm layer (degC)
% tk_pwp -> dz_warm = warm layer thickness (m)
% dsea   -> dT_warm_at_Tsea_input = dT (degC) due to warming at depth of Tsea such that Tsea_true = Tsea + dsea

%********** history ********************
% updated 09/2020 for consistency with units, readme info, and coare 3.6 main function

%********** Set cool skin options ******************
jcool = 1;  % 0=no cool skin calc, 1=do cool skin calc
icount = 1;
%*********************  housekeep variables  ********
% Call coare35vn to get initial flux values
% Bx = coare35vn(U(1),zu,Tair(1),zt,RH(1),zq,Pair(1),Tsea(1),Solar(1),IR(1),Lat(1),zi,Rainrate(1),NaN,NaN,zref);
Bx = coare35vn_et(U(1),zu,Tair(1),zt,RH(1),zq,P(1),Tsea(1),Solar(1),IR(1),Lat(1),zi,Rainrate(1),NaN,NaN,zref);
% A=[usr tau hsb hlb hbb hsbb hlwebb tsr qsr zo  zot zoq Cd Ch Ce  L zet dter dqer tkt Urf Trf Qrf RHrf UrfN Rnl Rns Le rhoa UN U10 U10N Cdn_10 Chn_10 Cen_10 RF SSQ Evap T10 Q10 RH10 P10 rhoa10 ug];
% %   1   2   3   4   5   6    7      8   9  10  11  12  13 14 15  16 17  18   19   20  21  22  23   24   25 26  27  28  29  30  31   32     33   34    35    36 37  38   39  40  41  42     43  44


%%% note if you change coare function then you must also change these indices
tau_old = Bx(2);  % stress
hs_old = Bx(3);   % sensible heat flux
hl_old = Bx(4);   % latent heat flux - Webb corrected (no???)
dter = Bx(18);    % cool skin
RF_old = Bx(36);  % rain heat flux

% check coare code!
% A=[usr tau hsb hlb hbb hsbb hlwebb tsr qsr zo  zot zoq Cd Ch Ce  L   zet dter dqer tkt Urf Trf Qrf RHrf UrfN Rnl Rns Le rhoa UN U10 U10N Cdn_10 Chn_10 Cen_10 RF SSQ Evap T10 Q10 RH10 P10 rhoa10 ug];
% %   1   2   3   4   5   6    7      8   9  10  11  12  13 14 15  16  17   18   19   20  21  22  23   24   25 26  27  28  29  30  31   32     33   34    35    36  37  38   39  40  41  42     43  44

qcol_ac = 0;      % accumulates heat from integral
tau_ac = 0;       % accumulates stress from integral
dt_wrm = 0;       % total warming (amplitude) in warm layer
max_pwp = 19;     % maximum depth of warm layer (adjustable)
tk_pwp = max_pwp; % initial depth set to max value
dsea = 0;         % dT initially set to 0
q_pwp = 0;        % total heat absorped in warm layer
fxp = .5;         % initial value of solar flux absorption

rich = .65;       % critical Richardson number

jtime = 0;
jamset = 0;
jump = 1;

%*******************  set constants  ****************
tdk = 273.16;   % Converts to Kelvin
Rgas = 287.1;   % Universal gas constant
cpa = 1004.67;  % Specific heat of air at constant pressure
cpw = 4000;     % Specific heat of water
rhow = 1022;    % Density of water
visw = 1e-6;    % Viscosity of water

be = 0.026;
tcw = 0.6;

%**********************************************************
%******************  setup read data loop  ****************
P_tq = P - (0.125*zt); % P at tq measurement height
[Press,Tseak,Tairk,Qsatsea,Qsat,Qair,Rhoair,Rhodry] = scalarv(P,Tsea,Tair,RH,zt);

nx = length(yday);        %# of lines of data

% this is an empty array for saving warm layer code output values. Will be
% added to coare output at the end.
warm_output = nan(nx,3);

for ibg = 1:nx            % major read loop
    yd = yday(ibg);       % yearday
    p = P(ibg);           % air sea level pressure
    u = U(ibg);           % wind speed
    tsea = Tsea(ibg);     % bulk sea surface temp
    t = Tair(ibg);        % air temp
    qs = Qsatsea(ibg);    % bulk sea surface humidity
    q = Qair(ibg);        % specific humidity
    rh = RH(ibg);         % relative humidity
    Rs = Solar(ibg);      % downward solar flux (positive down)
    Rl = IR(ibg);         % doward IR flux (positive down)
    rain = Rainrate(ibg); % rain rate
    grav = grv(Lat(ibg)); % gravity
    latx = Lat(ibg);      % latitude
    lonx = Lon(ibg);      % longitude, +/- 180 deg
    rhoa = Rhoair(ibg);   % air density

    %*****  variables for warm layer  ***
    Rnl = .97*(5.67e-8*(tsea-dter*jcool+tdk)^4-Rl); %Net IR
    Rns = .945*Rs;                                  %Net Solar
    cpv = cpa*(1+0.84*q/1000);
    visa = 1.326e-5*(1+6.542e-3*t+8.301e-6*t*t-4.84e-9*t*t*t);
    Al = 2.1e-5*(tsea+3.2)^0.79;
    ctd1 = sqrt(2*rich*cpw/(Al*grav*rhow));       %mess-o-constants 1
    ctd2 = sqrt(2*Al*grav/(rich*rhow))/(cpw^1.5); %mess-o-constants 2

    %********************************************************
    %****  Compute apply warm layer  correction *************
    %********************************************************

    intime = yd-fix(yd);                         % fraction of day
    loc = (lonx+7.5)/15;                         % time diff in hours from utc
    chktime = loc+intime*24;                     % local time in decimal hours
    newtime = (chktime-24*fix(chktime/24))*3600; % local time of day in seconds
    if icount>1                                  % not first time thru
        if newtime<=21600 || jump==0
            jump=0;
            if newtime < jtime        % re-zero at midnight
                jamset = 0;
                fxp = .5;
                tk_pwp = max_pwp;
                tau_ac = 0;
                qcol_ac = 0;
                dt_wrm = 0;
            else
                %************************************
                %****   set warm layer constants  ***
                %************************************
                dtime = newtime-jtime;             % delta time for integrals
                qr_out = Rnl+hs_old+hl_old+RF_old; % total cooling at surface
                q_pwp = fxp*Rns-qr_out;            % tot heat abs in warm layer
                  qqrx(ibg) = hs_old;
                if q_pwp>=50 || jamset==1           % Check for threshold
%                     disp('starting warm layer loop');
                    jamset = 1;                    % indicates threshold crossed
                    tau_ac = tau_ac+max(.002,tau_old)*dtime;   % momentum integral
                    if qcol_ac+q_pwp*dtime>0                   % check threshold for warm layer existence
                        %******************************************
                        % Compute the absorption profile
                        %******************************************
                        for i=1:5                   % loop 5 times for fxp
                            fxp = 1-(0.28*0.014*(1-exp(-tk_pwp/0.014))+0.27*0.357*(1-exp(-tk_pwp/0.357))+0.45*12.82*(1-exp(-tk_pwp/12.82)))/tk_pwp;
                            qjoule = (fxp*Rns-qr_out)*dtime;
                            if qcol_ac+qjoule>0     % Compute warm-layer depth
                                tk_pwp = min(max_pwp,ctd1*tau_ac/sqrt(qcol_ac+qjoule));
                            end
                        end
                    else             % warm layer wiped out
                        fxp = 0.75;
                        tk_pwp = max_pwp;
                        qjoule = (fxp*Rns-qr_out)*dtime;
                    end
                    qcol_ac = qcol_ac+qjoule; % heat integral
                    %*******  compute dt_warm  ******
                    if qcol_ac>0
                        dt_wrm = ctd2*(qcol_ac)^1.5/tau_ac;
                    else
                        dt_wrm = 0;
                    end
                end                     % end threshold check
            end                         % end midnight reset
            if tk_pwp<ts_depth           % Compute warm layer correction
                dsea = dt_wrm;
            else
                dsea = dt_wrm*ts_depth/tk_pwp;
            end
        end                            % end 6am start first time thru
    end                                % end first time thru check
    jtime = newtime;
    %************* output from routine  *****************************
    % Bx = [usr tau hsb hlb hbb hsbb hlwebb tsr qsr zo zot zoq Cd Ch Ce  L zet dter dqer tkt Urf Trf Qrf RHrf UrfN Rnl Le rhoa UN U10 U10N Cdn_10/1000 Chn_10/1000 Cen_10/1000 RF Qs Evap T10N Q10N RH10 ug wbar];
    %        1   2   3   4   5   6    7      8   9  10 11  12  13 14 15  16 17  18   19  20  21  22  23   24   25  26  27  28  29  30  31       32          33          34     35 36  37   38   39  40   41  42
    ts = tsea+dsea;
%     Bx = coare35vn(u,zu,t,zt,rh,zq,P,ts,Rs,Rl,latx,zi,rain,NaN,NaN,zref);
    Bx = coare35vn_et(u,zu,t,zt,rh,zq,p,ts,Rs,Rl,latx,zi,rain,NaN,NaN,zref);
    tau_old = Bx(2);            %hold stress
    hs_old = Bx(3);             %hold shf
    hl_old = Bx(4);             %hold lhf - use Webb corrected value
    dter = Bx(18);
    RF_old = Bx(36);            %hold rain flux
    
%     disp(['dT_warm = ' sprintf('%f',dt_wrm)]);
    
    warm_output(ibg,1) = dt_wrm;   % warming across entire warm layer deg.C
    warm_output(ibg,2) = tk_pwp;   % warm layer thickness m
    warm_output(ibg,3) = dsea;     % heating at selected depth

    icount = icount+1;

end %  data line loop

% get rid of filled values where nans are present in input data
bad_input = find(isnan(Solar) == 1);
% disp(['bad solar values = ' sprintf('%i',length(bad_input))]);
warm_output(bad_input,:) = nan;

%**************************************************
% Recompute fluxes with warm layer
%**************************************************
clear Bx
Tsea = Tsea+warm_output(:,3);
Bx = coare35vn_et(U,zu,Tair,zt,RH,zq,P,Tsea,Solar,IR,Lat,zi,Rainrate,NaN,NaN,zref);

B = [Bx warm_output];    %Add the warm layer variables

end
