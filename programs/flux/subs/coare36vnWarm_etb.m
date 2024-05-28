function B=coare36vnWarm_etb(jd,wspd,zu,tair,zt,rhair,zq,psealevel,tsea,sw_down,lw_down,lat,lon,zi,prate,ztsea,ssea,wave_cp,wave_height,zref_u,zref_t,zref_q)

disp('WarmCoolLayer')

%***********   input data **************

%        jd = day-of-year or julian day
%	      wspd = wind speed magnitude (m/s) corrected for currents at height zu
%                i.e. wind speed relative to water, i.e. current-relative wind
%	     zu = height (m) of wind measurement
%	   tair = air temp (degC) at height zt
%	     zt = height (m) of air temperature measurement
%	     rhair = relative humidity (%) at height zq
%   	 zq = height (m) of air humidity measurement
% psealevel = air pressure at sea level (mb) 
%      tsea = near-surface sea temp (degC) at depth ztsea
%	sw_down = downward solar flux (w/m^2) defined positive down
%	lw_down = downward IR flux (w/m^2) defined positive down
%	    lat = latitude (deg N=+)
%	    lon = longitude (deg E=+) % If using other version, see
%               usage of lon in albedo_vector function and adjust 'E' or 
%               'W' string input
%       zi = inversion height (m)
%    prate = rain rate (mm/hr)
%    ztsea = depth (m) of water temperature measurement, positive below surface
%     ssea = near-surface salinity (PSU)
%  wave_cp = phase speed of dominant waves (m/s)  
% wave_height = significant wave height (m)
% zu, zt, zq = heights of the observations above sea level (m)
% zref_u, zref_t, zref_q = reference height for profile, used to compare 
%             or estimate observations at different heights  
%
%  
%********** output data  ***************
% Outputs
% Adds onto output from coare36vn_zrf_et
% .... see that function for updated output. It can change. This function adds 4 variables onto it:
% previously named dt_wrm, tk_pwp, dsea, du_wrm... renamed to the following
% for clarity:
%         dt_warm = temperature difference from base of warm layer to skin, i.e. warming across entire warm layer depth (deg C) 
%         dz_warm = warm layer thickness (m)
% dt_warm_to_skin = temperature difference from measurement depth to skin due to warm layer, 
%                       such that Tskin = tsea + dt_warm_to_skin - dT_skin
%         du_warm = total current accumulation in warm layer (m/s ?...  unsure of units but likely m/s)

%********** history ********************
% updated 09/2020 for consistency with units, readme info, and coare 3.6 main function
%    Changed names for a few things... 
%    dt_wrm -> dt_warm; tk_pwp -> dz_warm; dsea -> dt_warm_to_skin;
%    skin: dter -> dT_skin
%    and fluxes to avoid ambiguity: RF -> hrain
%    Rnl -> lw_net; Rns -> sw_net; Rl -> lw_down; Rs -> sw_down;

%********** Set cool skin options ******************
jcool=1;  % 0=no cool skin calc; 1=do cool skin calc
icount=1;

%********** Set wave ******************
%%% ... not sure if this is necessary ... 
% if no wave info is provided, fill array with nan. 
% if length(wave_cp) == 1 && isnan(wave_cp) == 1
%     wave_cp = jd*nan;
% end
% if length(wave_height) == 1 && isnan(wave_height) == 1
%     wave_height = jd*nan;
% end

%*********************  housekeep variables  ********
% Call coare35vn to get initial flux values
Bx=coare36vn_zrf_etb(wspd(1),zu(1),tair(1),zt(1),rhair(1),zq(1),psealevel(1),tsea(1),sw_down(1),lw_down(1),lat(1),lon(1),jd(1),zi(1),prate(1),ssea(1),wave_cp(1),wave_height(1),zref_u(1),zref_t(1),zref_q(1));

tau_old=Bx.tau;           % stress
hs_old=Bx.hs;             % sensible heat flux
hl_old=Bx.hl;             % latent heat flux
dT_skin_old=Bx.dT_skin;   % cool skin
hrain_old=Bx.hrain;       % rain heat flux

qcol_ac=0;      % accumulates heat from integral, J/s
tau_ac=0;       % accumulates stress from integral, N/m2
dt_warm_i=0;      % total warming (amplitude deg C) in warm layer
du_warm_i=0;      % total current (amplitude m/s?) in warm layer, m/s most likely
max_dz_warm=19;     % maximum depth of warm layer (adjustable)
dz_warm=max_dz_warm;% initial depth set to max value
dt_warm_to_skin_i=0; % dT from measurement input depth to skin, initially set to 0
q_warm=0;        % total heat absorped in warm layer... note: this is reset below so doesn't need to be specified here?
fxp=.5;         % initial value of solar flux absorption

rich=.65;       %critical Richardson number tuned for COARE

jtime=0;
jamset=0;
jump=1;

%*******************  set constants  ****************
T2K=273.16;   % Converts to Kelvin
Rgas=287.1;   % Universal gas constant
cpa=1004.67;  % Specific heat of air at constant pressure
cpw=4000;     % Specific heat of water
rhow=1022;    % Density of water
visw=1e-6;    % Viscosity of water

be=0.026;
tcw=0.6;

%**********************************************************
%******************  setup read data loop  ****************
[Press,TseaK,TairK,Qsatsea,Qsat,qair,Rhoair,Rhodry]=scalarv(psealevel,tsea,tair,rhair,zt);

% %%% could this be used instead if only qair is needed from scalarv? 
% [qair,pv]  = qsat26air(tair,pair_tq,rhair); % specific humidity of air (g/kg).  
%     % Assumes rhair relative to ice T<0
%     % pv is the partial pressure due to wate vapor in mb
% qair=qair./1000;  % change qair to g/g

nx=length(jd);        % # of lines of data

% this is an empty array for saving warm layer code output values. Will be
% added to coare output at the end.

% warm_output = nan(nx,4);

dt_warm = nan(nx,1);
dz_warm = nan(nx,1);
dt_warm_to_skin = nan(nx,1);
du_warm = nan(nx,1);

for i = 1:nx 			% major read loop discritized by time
    jd_i=jd(i);       % yearday where 1 is Jan 1
    psealevel_i=psealevel(i);           % air pressure at sea level
    wspd_i=wspd(i);           % wind speed corrected for surface currents... i.e. wind speed adjused or relative to moving water surface
    tsea_i=tsea(i);     % subsurface sea temp
    tair_i=tair(i);        % air temp
    ssea_i=ssea(i);         % salinity at or near the surface
%     qskin1=Qsatsea(i);    % sea surface humidity ... not used
    qair_i=qair(i);        % air specific humidity 
    rhair_i=rhair(i);         % air relative humidity
    sw_down_i=sw_down(i);      % downward solar flux (positive down)
    lw_down_i=lw_down(i);         % doward IR flux (positive down)
    prate_i=prate(i); % rain rate
    grav_i=grv(lat(i)); % gravity
    lat_i=lat(i);      % latitude
    lon_i=lon(i);      % longitude
%     rhoair_i=Rhoair(i);   % air density ... not used
    
    %*****  variables for warm layer  ***
    
    %%% for constant albedo
    % sw_net=.945*sw_down_i;     % Net Solar: positive warming ocean, constant albedo

    %%% for albedo that is time-varying, i.e. zenith angle varying
    % insert 'E' for input to albedo function if longitude is defined positive
    % to E, so that lon can be flipped. The function ideally works with
    % longitude positive to the west. Check: albedo should peak at sunrise not
    % sunset.
    [alb,~,~,~] = albedo_vector(sw_down_i,jd_i,lon_i,lat_i,'E');
    sw_net = (1-alb).*sw_down_i; % constant albedo correction, positive heating ocean

    lw_net=.97*(5.67e-8*(tsea_i-dT_skin_old*jcool+T2K)^4-lw_down_i); % Net IR: positive cooling ocean
    cpv=cpa*(1+0.84*qair_i/1000);
    visa=1.326e-5*(1+6.542e-3*tair_i+8.301e-6*tair_i*tair_i-4.84e-9*tair_i*tair_i*tair_i);
    Al=2.1e-5*(tsea_i+3.2)^0.79;
    ctd1=sqrt(2*rich*cpw/(Al*grav_i*rhow));       % mess-o-constants 1
    ctd2=sqrt(2*Al*grav_i/(rich*rhow))/(cpw^1.5); % mess-o-constants 2
    
    %********************************************************
    %****  Compute apply warm layer  correction *************
    %********************************************************
    
    intime=jd_i-fix(jd_i);
    loc=(lon_i+7.5)/15;
    chktime=loc+intime*24;
    if chktime>24
        chktime=chktime-24;
    end
    newtime=(chktime-24*fix(chktime/24))*3600;
    if icount>1  % not first time thru
        if newtime<=21600 || jump==0
            jump=0;
            if newtime < jtime	% re-zero at midnight
                jamset=0;
                fxp=.5;
                dz_warm_i=max_dz_warm;
                tau_ac=0;
                qcol_ac=0;
                dt_warm_i=0;
                du_warm_i=0;
            else
                %************************************
                %****   set warm layer constants  ***
                %************************************
                dtime=newtime-jtime;                % delta time for integrals
                qr_out=lw_net+hs_old+hl_old+hrain_old; % total cooling at surface
                q_warm=fxp*sw_net-qr_out;               % total heat absorbed in warm layer
%                   qqrx(i)=hs_old; %%% ...not used
                if q_warm>=50 || jamset==1           % check for threshold
                    jamset=1;                       % indicates threshold crossed
                    tau_ac=tau_ac+max(.002,tau_old)*dtime;	% momentum integral
                    if qcol_ac+q_warm*dtime>0	            % check threshold for warm layer existence
                        %******************************************
                        % Compute the absorption profile
                        %******************************************
                        for i=1:5                           %loop 5 times for fxp

                            %%%% The original version since Fairall et al. 1996:
                            fxp=1-(0.28*0.014*(1-exp(-dt_warm_i/0.014))+0.27*0.357*(1-exp(-dt_warm_i/0.357))+0.45*12.82*(1-exp(-dt_warm_i/12.82)))/dt_warm_i;
                            % the above integrated flux formulation is wrong for the warm layer,
                            % but it has been used in this scheme since 1996 without
                            % making bad predictions.
                            % Simon recognized that fxp should be the
                            % fraction absorbed in the layer of the form
                            % 1-sum(ai*exp(-tk_pwp/gammai)) with sum(ai)=1
                            % One can choose different exponential
                            % absorption parameters, but it has to be of the right form.
                            % Simon idealized coefficients from profiles of
                            % absorption in DYNAMO by C. Ohlmann.
                            % see /Users/sdeszoek/Data/cruises/DYNAMO_2011/solar_absorption/test_absorption_fcns.m
                            % 
                            % Correct form of Soloviev 3-band absorption:
                            % --using original F96 absorption bands:
                            %  fxp=1-(0.32*exp(-tk_pwp/22.0) + 0.34*exp(-tk_pwp/1.2) + 0.34*exp(-tk_pwp/0.014)); % NOT TESTED!!
                            % --using DYNAMO absorption bands (F, invgamma defined above):

                            %%%% NOT TESTED!! Correction of fxp from Simon ***
%                            fxp=1-sum(F.*(exp(-tk_pwp*invgamma)),2);   
                            
                            qjoule=(fxp*sw_net-qr_out)*dtime;
                            if qcol_ac+qjoule>0             % Compute warm-layer depth
                                dt_warm_i=min(max_dz_warm,ctd1*tau_ac/sqrt(qcol_ac+qjoule));
                            end
                        end
                    else   % warm layer wiped out
                        fxp=0.75;
                        dz_warm_i=max_dz_warm; % check?
                        qjoule=(fxp*sw_net-qr_out)*dtime;
                    end
                    qcol_ac=qcol_ac+qjoule; % heat integral
                    %*******  compute dt_warm  ******
                    if qcol_ac>0
                        dt_warm_i=ctd2*(qcol_ac)^1.5/tau_ac;
                        du_warm_i=2*tau_ac/(dt_warm_i*rhow); % check units... should be m/s?
                    else
                        dt_warm_i=0;
                        du_warm_i=0;
                    end
                end%                    end threshold check
            end%                        end midnight reset
            % Compute warm layer dT between input measurement and skin layer
            if dt_warm_i<ztsea          
                dt_warm_to_skin_i=dt_warm_i;
            else
                dt_warm_to_skin_i=dt_warm_i*ztsea/dt_warm_i; % assumes a linear profile of T throughout warm layer
            end
            
        end%                            end 6am start first time thru
    end%                                end first time thru check
    jtime=newtime;
    %************* output from routine  *****************************

% Adjust tsea_i for warm layer above measurement. Even if tsea_i is at 5 cm for the sea snake,
% there could be warming present between the interface and the subsurface
% temperature. dt_warm_to_skin estimates that warming between the levels.
    tskin=tsea_i+dt_warm_to_skin_i;
    
% Rerun COARE with the warm-layer corrected tsea_i temperature. COARE will
% apply a cool skin to this, completing all calculations needed for tskin and fluxes. 
% Using COARE ouput from this function, tskin = tsea - dt_skin + dt_warm_to_skin
% note: in prior COARE lingo/code: dt_warm_to_skin used to be dsea and dt_skin used to be dter
    Bx=coare36vn_zrf_etb(wspd_i,zu,tair_i,zt,rhair_i,zq,psealevel_i,tskin,sw_down_i,lw_down_i,lat_i,lon_i,jd_i,zi,prate_i,ssea_i,wave_cp,wave_height,zrf_u,zrf_t,zrf_q);

% save values from this time step to be used in next time step, this is how
% the integral is computed
    tau_old=Bx.tau;           % stress
    hs_old=Bx.hs;             % sensible heat flux
    hl_old=Bx.hl;             % latent heat flux
    dT_skin_old=Bx.dT_skin;   % cool skin
    hrain_old=Bx.hrain;       % rain heat flux
    
%     warm_output(i,1) = dt_warm_i;         % dT between base of warm layer and skin, across entire layer, deg C
%     warm_output(i,2) = dt_warm_i;         % warm layer thickness, m
%     warm_output(i,3) = dt_warm_to_skin_i; % dT between measurement and skin level due to warm layer, degC
%     warm_output(i,4) = du_warm_i;         % some measure of current or momentum across entire layer, units ?
   
    dt_warm(i) = dt_warm_i; % temperature difference between base of warm layer and skin, across entire layer, deg C
    dz_warm(i) = dz_warm_i; % warm layer thickness, m
    dt_warm_to_skin(i) = dt_warm_to_skin_i; % temperature difference between measurement and skin level due to warm layer, degC
    du_warm(i) = du_warm_i; % some measure of current or momentum across entire layer, units ?
    
    icount=icount+1;
    
end %  data line loop

% get rid of filled values where nans are present in input data
bad_input = find(isnan(sw_down) == 1);
% disp(['bad solar values = ' sprintf('%i',length(bad_input))]);
warm_output(bad_input,:) = nan;

%**************************************************************************
% Recompute entire time series of fluxes with seawater temperature adjusted
% for warming between sensor and skin layer. COARE_zrf will then apply a
% cool skin on top of that.
%**************************************************************************
clear Bx
tsea=tsea+warm_output(:,3);

Bx=coare36vn_zrf_etb(wspd,zu,tair,zt,rhair,zq,psealevel,tsea,sw_down,lw_down,lat,lon,jd,zi,prate,ssea,wave_cp,wave_height,zrf_u,zrf_t,zrf_q);

% B=[Bx warm_output];    %Add all warm layer variables to the end

Bx.dt_warm = dt_warm;
Bx.dz_warm = dz_warm;
Bx.dt_warm_to_skin = dt_warm_to_skin;
Bx.du_warm = du_warm;

%************* output from routine  *****************************
%%% adds to coarevn_zrf output the following 4 vars:
% B = [ <<< outputs from main coare function >>> .... dt_warm  dz_warm  dt_warm_to_skin  du_warm ]
end

%% functions... note that different variable names are used here to keep
% them working at all times and not confuse the code
%------------------------------------------------------------------------------
function g=grv(LAT)
% computes g [m/sec^2] given lat in deg
gamma=9.7803267715;
c1=0.0052790414;
c2=0.0000232718;
c3=0.0000001262;
c4=0.0000000007;
phi=LAT*pi/180;
x=sin(phi);
g=gamma*(1+c1*x.^2+c2*x.^4+c3*x.^6+c4*x.^8);
end

%------------------------------------------------------------------------------
function [Press,TseaK,TairK,Qsatsea,Qsatms,Qms,Rhoair,Rhodry]=scalarv(P,Tsea,Tair,RH,zt)

% Compute the required scalar variables for the bulk code.
% Vectorized when needed.
% Inputs:
% P    Air pressure (mb)
% Tsea  sea temp (C)
% Tair  Air temperature (C)
% RH    Relative humidity (%)

Press=P*100;                    % ATMOSPHERIC SEA LEVEL PRESSURE (Pa)
P_tq=100*(P - (0.125*zt));      % AIR TEMPERATURE at tq measurement height (Pa)
TseaK=Tsea+273.15;              % NEAR-SURFACE SEA TEMPERATURE (K)
TairK=Tair+273.15;              % AIR TEMPERATURE (K)

if length(Tsea)>1
    %********************** COMPUTES QSEA ***************************
    Exx=6.1121*exp(17.502*Tsea./(240.97+Tsea));
    Exx=Exx.*(1.0007+P*3.46E-6);
    Esatsea=Exx*0.98;
    Qsatsea=.622*Esatsea./(P-.378*Esatsea)*1000;  % SPEC HUM SEA (g/kg)
    
    %********************** COMPUTES QAIR ***************************
    Exx=6.1121*exp(17.502*Tair./(240.97+Tair));
    Exx=Exx.*(1.0007+P_tq*3.46E-6);
    Qsatms=.622*Exx./(P_tq-.378*Exx)*1000;
    Ems=Exx.*RH/100;
    Qms=.622*Ems./(P_tq-.378*Ems)*1000;   % SPEC HUM AIR (g/kg)
    E=Ems*100;
    %****************** COMPUTES AIR DENSITY *******************
    Rhoair=P_tq./(TairK.*(1+.61*Qms/1000)*287.05);
    Rhodry=(P_tq-E)./(TairK*287.05);
else
    %********************** COMPUTES QSEA ***************************
    Ex=ComputeEsat(Tsea,P);                         % SATURATION VALUE
    Esatsea=Ex*.98;
    Qsatsea=.622*Esatsea/(P-.378*Esatsea)*1000;  % SPEC HUM SEA (g/kg)
    
    %********************** COMPUTES QAIR ***************************
    Esatms=ComputeEsat(Tair,P_tq);          % SATURATION VALUE
    Qsatms=.622*Esatms/(P_tq-.378*Esatms)*1000;
    Ems=Esatms*RH/100;
    Qms=.622*Ems/(P_tq-.378*Ems)*1000;   % SPEC HUM AIR (g/kg)
    E=Ems*100;
    
    %****************** COMPUTES AIR DENSITY *******************
    Rhoair=P_tq/(TairK*(1+.61*Qms/1000)*287.05);
    Rhodry=(P_tq-E)/(TairK*287.05);
end
end

%------------------------------------------------------------------------------

function Exx=ComputeEsat(T,P)
%         Given temperature (C) and pressure (mb), returns
%         saturation vapor pressure (mb).
Exx=6.1121*exp(17.502*T./(240.97+T));
Exx=Exx.*(1.0007+P*3.46E-6);
end

%------------------------------------------------------------------------------
function [ALB,T,solarmax,psi] = albedo_vector(SW_DN,JD,LON,LAT,EorW)

%  Computes transmission and albedo from downwelling solar using
%  LAT   : latitude in degrees (positive to the north)
%  LON   : longitude in degrees (positive to the west)
%  JD    : yearday
%  SW_DN : downwelling solar radiation measured at surface
%  EorW  : 'E' if longitude is positive to the east, or 'W' if otherwise

% updates:
%   20-10-2021: ET vectorized function

if strcmp(EorW,'E') == 1
%     disp('LON is positive to east so negate for albedo calculation');
    LON = -LON;
elseif strcmp(EorW,'W') == 1
%     disp('LON is already positive to west so go ahead with albedo calculation');
else
    disp('please provide sign information on whether LON is deg E or deg W');
end

ALB = nan(length(SW_DN),1); % allocate array of albedo values as vector
LAT=LAT*pi/180;       %Convert to radians
LON=LON*pi/180;       %Convert to radians
SC=1380;              %Solar constant W/m^2
utc=(JD-fix(JD))*24;  %UTC time (decimal hours)
h=pi*utc/12-LON;
declination=23.45*cos(2*pi*(JD-173)/365.25);       % Solar declination angle
solarzenithnoon=(LAT*180/pi-declination);          % Zenith angle at noon
solaraltitudenoon=90-solarzenithnoon;              % Altitude at noon
sd=declination*pi/180;                             % Convert to radians
gamma=1;                                           % ratio of actual to mean earth-sun separation (set to 1 for now)
gamma2=gamma*gamma;
%
sinpsi = sin(LAT).*sin(sd)-cos(LAT).*cos(sd).*cos(h);  % Local elevation angle
psi = asin(sinpsi).*180/pi;
solarmax=SC.*sinpsi/gamma2;                            % No atmosphere
%solarmax=1380*sinpsi*(0.61+0.20*sinpsi);

T = min(2,SW_DN./solarmax);

Ts = 0:0.05:1;
As = 0:2:90;

%%% for vectorized function
for k = 1:length(sinpsi)
 Tchk = abs(Ts-T(k));
 wh_Tchk = find(Tchk == min(Tchk));

%%% for single value function
% Tchk = abs(Ts-T);
% i=find(Tchk==min(Tchk));


%  Look up table from Payne (1972)  Only adjustment is to T=0.95 Alt=10 value
%
%       0     2     4     6     8     10    12    14    16    18    20   22     24    26    28    30    32    34    36    38    40    42    44    46    48    50    52    54    56    58    60    62    64    66    68    70    72    74    76    78    80    82    84    86    88    90

a = [ 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061; ...
      0.062 0.062 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061; ...
      0.072 0.070 0.068 0.065 0.065 0.063 0.062 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.061 0.060 0.061 0.060 0.060 0.060 0.060 0.060 0.060 0.060 0.060 0.060 0.060 0.060 0.060 0.060 0.060 0.060 0.060 0.060 0.060 0.060 0.060 0.060 0.060 0.060 0.060 0.060 0.060 0.060 0.060; ...
      0.087 0.083 0.079 0.073 0.070 0.068 0.066 0.065 0.064 0.063 0.062 0.061 0.061 0.060 0.060 0.060 0.060 0.060 0.060 0.060 0.060 0.060 0.060 0.060 0.060 0.060 0.060 0.060 0.060 0.060 0.060 0.060 0.060 0.060 0.060 0.060 0.060 0.060 0.060 0.060 0.060 0.060 0.060 0.060 0.060 0.060; ...
      0.115 0.108 0.098 0.086 0.082 0.077 0.072 0.071 0.067 0.067 0.065 0.063 0.062 0.061 0.061 0.060 0.060 0.060 0.060 0.061 0.061 0.061 0.061 0.060 0.059 0.060 0.060 0.060 0.060 0.060 0.060 0.060 0.060 0.060 0.060 0.060 0.060 0.060 0.060 0.060 0.060 0.060 0.060 0.059 0.059 0.059; ...
      0.163 0.145 0.130 0.110 0.101 0.092 0.084 0.079 0.072 0.072 0.068 0.067 0.064 0.063 0.062 0.061 0.061 0.061 0.060 0.060 0.060 0.060 0.060 0.059 0.059 0.059 0.059 0.059 0.059 0.059 0.059 0.059 0.059 0.059 0.059 0.059 0.059 0.059 0.059 0.059 0.059 0.059 0.059 0.059 0.059 0.058; ...
      0.235 0.198 0.174 0.150 0.131 0.114 0.103 0.094 0.083 0.080 0.074 0.074 0.070 0.067 0.065 0.064 0.063 0.062 0.061 0.060 0.060 0.060 0.059 0.059 0.059 0.059 0.059 0.059 0.059 0.059 0.059 0.059 0.059 0.059 0.059 0.059 0.059 0.059 0.059 0.059 0.059 0.059 0.059 0.058 0.058 0.058; ...
      0.318 0.263 0.228 0.192 0.168 0.143 0.127 0.113 0.099 0.092 0.084 0.082 0.076 0.072 0.070 0.067 0.065 0.064 0.062 0.062 0.060 0.060 0.060 0.059 0.059 0.059 0.059 0.059 0.059 0.059 0.058 0.058 0.058 0.058 0.058 0.058 0.058 0.058 0.057 0.058 0.058 0.058 0.058 0.057 0.057 0.057; ...
      0.395 0.336 0.290 0.248 0.208 0.176 0.151 0.134 0.117 0.107 0.097 0.091 0.085 0.079 0.075 0.071 0.068 0.067 0.065 0.063 0.062 0.061 0.060 0.060 0.060 0.059 0.059 0.058 0.058 0.058 0.057 0.057 0.057 0.057 0.057 0.057 0.057 0.056 0.056 0.056 0.056 0.056 0.056 0.056 0.056 0.055; ...
      0.472 0.415 0.357 0.306 0.252 0.210 0.176 0.154 0.135 0.125 0.111 0.102 0.094 0.086 0.081 0.076 0.072 0.071 0.068 0.066 0.065 0.063 0.062 0.061 0.060 0.059 0.058 0.057 0.057 0.057 0.056 0.055 0.055 0.055 0.055 0.055 0.055 0.054 0.053 0.054 0.053 0.053 0.054 0.054 0.053 0.053; ...
      0.542 0.487 0.424 0.360 0.295 0.242 0.198 0.173 0.150 0.136 0.121 0.110 0.101 0.093 0.086 0.081 0.076 0.073 0.069 0.067 0.065 0.064 0.062 0.060 0.059 0.058 0.057 0.056 0.055 0.055 0.054 0.053 0.053 0.052 0.052 0.052 0.051 0.051 0.050 0.050 0.050 0.050 0.051 0.050 0.050 0.050; ...
      0.604 0.547 0.498 0.407 0.331 0.272 0.219 0.185 0.160 0.141 0.127 0.116 0.105 0.097 0.089 0.083 0.077 0.074 0.069 0.066 0.063 0.061 0.059 0.057 0.056 0.055 0.054 0.053 0.053 0.052 0.051 0.050 0.050 0.049 0.049 0.049 0.048 0.047 0.047 0.047 0.046 0.046 0.047 0.047 0.046 0.046; ...
      0.655 0.595 0.556 0.444 0.358 0.288 0.236 0.190 0.164 0.145 0.130 0.119 0.107 0.098 0.090 0.084 0.076 0.073 0.068 0.064 0.060 0.058 0.056 0.054 0.053 0.051 0.050 0.049 0.048 0.048 0.047 0.046 0.046 0.045 0.045 0.045 0.044 0.043 0.043 0.043 0.042 0.042 0.043 0.042 0.042 0.042; ... 
      0.693 0.631 0.588 0.469 0.375 0.296 0.245 0.193 0.165 0.145 0.131 0.118 0.106 0.097 0.088 0.081 0.074 0.069 0.065 0.061 0.057 0.055 0.052 0.050 0.049 0.047 0.046 0.046 0.044 0.044 0.043 0.042 0.042 0.041 0.041 0.040 0.040 0.039 0.039 0.039 0.038 0.038 0.038 0.038 0.038 0.038; ... 
      0.719 0.656 0.603 0.480 0.385 0.300 0.250 0.193 0.164 0.145 0.131 0.116 0.103 0.092 0.084 0.076 0.071 0.065 0.061 0.057 0.054 0.051 0.049 0.047 0.045 0.043 0.043 0.042 0.041 0.040 0.039 0.039 0.038 0.038 0.037 0.036 0.036 0.035 0.035 0.034 0.034 0.034 0.034 0.034 0.034 0.034; ... 
      0.732 0.670 0.592 0.474 0.377 0.291 0.246 0.190 0.162 0.144 0.130 0.114 0.100 0.088 0.080 0.072 0.067 0.062 0.058 0.054 0.050 0.047 0.045 0.043 0.041 0.039 0.039 0.038 0.037 0.036 0.036 0.035 0.035 0.034 0.033 0.032 0.032 0.032 0.031 0.031 0.031 0.030 0.030 0.030 0.030 0.030; ... 
      0.730 0.652 0.556 0.444 0.356 0.273 0.235 0.188 0.160 0.143 0.129 0.113 0.097 0.086 0.077 0.069 0.064 0.060 0.055 0.051 0.047 0.044 0.042 0.039 0.037 0.035 0.035 0.035 0.034 0.033 0.033 0.032 0.032 0.032 0.029 0.029 0.029 0.029 0.028 0.028 0.028 0.028 0.027 0.027 0.028 0.028; ... 
      0.681 0.602 0.488 0.386 0.320 0.252 0.222 0.185 0.159 0.142 0.127 0.111 0.096 0.084 0.075 0.067 0.062 0.058 0.054 0.050 0.046 0.042 0.040 0.036 0.035 0.033 0.032 0.032 0.031 0.030 0.030 0.030 0.030 0.029 0.027 0.027 0.027 0.027 0.026 0.026 0.026 0.026 0.026 0.026 0.026 0.026; ... 
      0.581 0.494 0.393 0.333 0.288 0.237 0.211 0.182 0.158 0.141 0.126 0.110 0.095 0.083 0.074 0.066 0.061 0.057 0.053 0.049 0.045 0.041 0.039 0.034 0.033 0.032 0.031 0.030 0.029 0.028 0.028 0.028 0.028 0.027 0.026 0.026 0.026 0.025 0.025 0.025 0.025 0.025 0.025 0.025 0.025 0.025; ... 
      0.453 0.398 0.342 0.301 0.266 0.226 0.205 0.180 0.157 0.140 0.125 0.109 0.095 0.083 0.074 0.065 0.061 0.057 0.052 0.048 0.044 0.040 0.038 0.033 0.032 0.031 0.030 0.029 0.028 0.027 0.027 0.026 0.026 0.026 0.025 0.025 0.025 0.025 0.025 0.025 0.025 0.025 0.025 0.025 0.025 0.025; ... 
      0.425 0.370 0.325 0.290 0.255 0.220 0.200 0.178 0.157 0.140 0.122 0.108 0.095 0.083 0.074 0.065 0.061 0.056 0.052 0.048 0.044 0.040 0.038 0.033 0.032 0.031 0.030 0.029 0.028 0.027 0.026 0.026 0.026 0.026 0.025 0.025 0.025 0.025 0.025 0.025 0.025 0.025 0.025 0.025 0.025 0.025]; 

  
%   whos psi
if psi(k)<0 
   ALB(k)=0;
   solarmax(k)=0;
   T(k)=0;
   j=0;
   psi(k)=0;
else
   Achk = abs(As-psi(k));
   j=find(Achk==min(Achk));
   szj = size(j);
   if szj(2) > 0
       ALB(k)=a(wh_Tchk,j);
   else
%       disp('no j found, not assigning ALB to anything');
   end
end

end % end for k list of albedo_vector array
%disp([num2str(JD_i) '  ' num2str(SW_DN) '  ' num2str(ALB) '  ' num2str(T) '  ' num2str(i) '  ' num2str(j)])
end