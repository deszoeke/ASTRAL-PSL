function A=coare36vn_zrf_etb(wspd,zu,tair,zt,rhair,zq,psealevel,tsea,sw_down,lw_down,lat,lon,jd,zi,prate,ssea,wave_cp,wave_height,zref_u,zref_t,zref_q)
%

%**************************************************************************
% VERSION INFO:

% Vectorized version of COARE 3.6 code (Fairall et al, 2003) with 
% modification based on the CLIMODE, MBL and CBLAST experiments 
% (Edson et al., 2012). The cool skin and surface wave options are included.
% A separate warm layer function can be used to call this function.
%
% This 3.6 version include parameterizations using wave height and wave
% slope using wave_cp and wave_height.  If these are set to NaN, then the wind
% speed dependent formulation is used.  The parameterizations are based
% on fits to the Banner-Norison wave model and the Fairall-Edson flux
% database.  This version also allows salinity as a input.  
% Open ocean example ssea=35; Great Lakes ssea=0;
 
%**************************************************************************
% COOL SKIN:
%
% An important component of this code is whether the inputed tsea 
% represents the ocean skin temperature or a subsurface temperature.  
% How this variable is treated is determined by the jcool parameter:
%   set jcool=1 if tsea is subsurface or bulk ocean temperature (default);
%   set jcool=0 if tsea is skin temperature or to not run cool skin model.
% The code updates the cool-skin temperature depression dt_skin and 
% thickness dz_skin during iteration loop for consistency. The number of 
% iterations set to nits = 6.

    jcoolx=1;
    
%**************************************************************************
%%% INPUTS:  

% Notes on input default values, missing values, vectors vs. single values:
%   - the code assumes wspd,tair,rhair,tsea,psealevel,sw_down,lw_down,prate,ssea,wave_cp,wave_height are vectors; 
%   - sensor heights (zu,zt,zl) latitude lat, longitude lon, julian date jd, 
%       and PBL height zi may be constants;
%   - air pressure psealevel and radiation sw_down, lw_down may be vectors or constants. 
%   - input NaNs as vectors or single values to indicate no data. 
%   - assign a default value to psealevel, lw_down, sw_down, lat, zi if unknown, single
%       values of these inputs are okay.
% Notes about signs and units: 
%   - radiation signs: positive warms the ocean
%   - signs and units change throughout the program for ease of calculations.
%   - the signs and units noted here are for the inputs.

%
%     wspd = water-relative wind speed magnitude (m/s) at height zu (m)
%             i.e. mean wind speed accounting for the ocean current vector. 
%             i.e. the magnitude of the difference between the wind vector
%                       ... and the ocean current vector.
%             i.e. current-relative wind speed.
%             If not available, use true wind speed to compute fluxes in 
%             earth-coordinates, which will be ignoring the stress 
%             contribution from the ocean current to all fluxes
%     tair = air temperature (degC) at height zt (m)
%    rhair = relative humidity (%) at height zq (m)
%     psealevel = sea level air pressure (mb) 
%    tsea = seawater temperature (degC), see jcool below for cool skin 
%             calculation info, and separate warm layer code for specifying 
%             sensor depth and whether warm layer is computed
% sw_down = downward (positive) shortwave radiation (W/m^2)
% lw_down = downward (positive) longwave radiation (W/m^2) 
%   lat = latitude defined positive to north
%   lon = longitude defined positive to east, if using other version,
%             adjust the eorw string input to albedo_vector function
%    jd = year day or julian day, where day Jan 1 00:00 UTC = 0
%    zi = PBL height (m) (default or typical value = 600m)
%  prate = rain rate (mm/hr)
%    ssea = sea surface salinity (PSU)
%    wave_cp = phase speed of dominant waves (m/s) computed from peak period 
%  wave_height = significant wave height (m)
%  zu, zt, zq heights of the observations (m)
%  zref_u, zref_t, zref_q  reference height for profile.  Use this to compare observations at different heights  

%**************************************************************************
%%%% OUTPUTS: the user controls the output array A at the end of the code.

% Note about signs and units: 
%   - radiation signs: positive warms the ocean
%   - sensible, rain, and latent flux signs: positive cools the ocean
%   - signs and units change throughout the program for ease of calculations.
%   - the signs and units noted here are for the final outputs.

%   ustar = friction velocity that includes gustiness (m/s), u*
%     tau = wind stress that includes gustiness (N/m^2)
%      hs = sensible heat flux (W/m^2) ... positive for tairir < tskin
%      hl = latent heat flux (W/m^2) ... positive for qair < qs
%      hb = atmospheric buoyany flux (W/m^2)... positive when hl and hs heat the atmosphere
%     hbs = atmospheric buoyancy flux from sonic anemometer ... as above, computed with sonic anemometer T
% hl_webb = webb factor to be added to hl covariance and ID latent heat fluxes
%   tstar = temperature scaling parameter (K), t*
%   qstar = specific humidity scaling parameter (kg/kg), q*
%      zo = momentum roughness length (m) 
%     zot = thermal roughness length (m) 
%     zoq = moisture roughness length (m)
%      cd = wind stress transfer (drag) coefficient at height zu (unitless)
%      ch = sensible heat transfer coefficient (Stanton number) at height zu (unitless)
%      ce = latent heat transfer coefficient (Dalton number) at height zu (unitless)
%       L = Monin-Obukhov length scale (m)
%    zeta = Monin-Obukhov stability parameter zu/L (dimensionless)
% dt_skin = cool-skin temperature depression (degC), pos value means skin is cooler than subskin
% dq_skin = cool-skin humidity depression (g/kg)
% dz_skin = cool-skin thickness (m)
%    wspd_ref = wind speed at reference height (user can select height at input)
%    tair_ref = air temperature at reference height
%    qair_ref = air specific humidity at reference height
%   rhair_ref = air relative humidity at reference height
%    pair_ref = air pressure at reference height
%   wspd_refN = neutral value of wind speed at reference height
%   tair_refN = neutral value of air temp at reference height
%   qair_refN = neutral value of air specific humidity at reference height
%  lw_net = Net IR radiation computed by COARE (W/m2)... positive heating ocean
%  sw_net = Net solar radiation computed by COARE (W/m2)... positive heating ocean
%      Le = latent heat of vaporization (J/K)
%    rhoair = density of air at input parameter height zt, typically same as zq (kg/m3)
%      wspd_N = neutral value of wind speed at zu (m/s)
%     wspd_10 = wind speed adjusted to 10 m (m/s)
%    wspd_10N = neutral value of wind speed at 10m (m/s)
%   cd10N = neutral value of drag coefficient at 10m (unitless)
%   ch10N = neutral value of Stanton number at 10m (unitless)
%   ce10N = neutral value of Dalton number at 10m (unitless)
%   hrain = rain heat flux (W/m^2)... positive cooling ocean
%   qskin = sea surface specific humidity, i.e. assuming saturation (g/kg)
%   erate = evaporation rate (mm/h)
%     tair_10 = air temperature at 10m (deg C)
%     qair_10 = air specific humidity at 10m (g/kg)
%    rhair_10 = air relative humidity at 10m (%)
%     P10 = air pressure at 10m (mb)
%  rhoair_10 = air density at 10m (kg/m3)
%    gust = gustiness velocity (m/s)
% wave_wc_frac = whitecap fraction (ratio)
%    wave_edis = energy dissipated by wave breaking (W/m^2)

%**************************************************************************
%%%% ADDITONAL CALCULATIONS: 

%   using COARE output, one can easily calculate the following using the
%   sign conventions and names herein:

%     %%% Skin sea surface temperature or interface temperature; neglect
%     %%% dT_warm_to_skin if warm layer code is not used as the driver
%     %%%% program for this program
%           tskin = tsea + dT_warm_to_skin - dt_skin;
%     
%     %%% Upwelling radiative fluxes: positive heating the ocean
%           lw_up = lw_net - lw_down;
%           sw_up = sw_net - sw_down;
%  
%     %%% Net heat flux: positive heating ocean
%     %%% note that hs, hl, hrain are defined when positive cooling
%     %%% ocean by COARE, so their signs are flipped here: 
%           hnet = sw_net + lw_net - hs - hl - hrain;

%**************************************************************************
%%%% REFERENCES:
%
%  Fairall, C. W., E. F. Bradley, J. S. Godfrey, G. A. Wick, J. B. Edson, 
%  and G. S. Young, 1996a: Cool-skin and warm-layer effects on sea surface 
%  temperature. J. Geophys. Res., 101, 1295?1308.
%
%  Fairall, C. W., E. F. Bradley, D. psealevel. Rogers, J. B. Edson, and G. S. Young,
%  1996b: Bulk parameterization of air-sea fluxes for Tropical Ocean- Global
%  Atmosphere Coupled- Ocean Atmosphere Response Experiment. J. Geophys. Res.,
%  101, 3747?3764.
%
%  Fairall, C. W., A. B. White, J. B. Edson, and J. E. Hare, 1997: Integrated
%  shipboard measurements of the marine boundary layer. Journal of Atmospheric
%  and Oceanic Technology, 14, 338?359
%
%  Fairall, C.W., E.F. Bradley, J.E. Hare, A.A. Grachev, and J.B. Edson (2003),
%  Bulk parameterization of air sea fluxes: updates and verification for the 
%  COARE algorithm, J. Climate, 16, 571-590.
%
%  Edson, J.B., J. V. S. Raju, R.A. Weller, S. Bigorre, A. Plueddemann, C.W.
%  Fairall, S. Miller, L. Mahrt, Dean Vickers, and Hans Hersbach, 2013: On 
%  the Exchange of momentum over the open ocean. J. Phys. Oceanogr., 43, 
%  1589–1610. doi: http://dx.doi.org/10.1175/JPO-D-12-0173.1 

%**************************************************************************
% CODE HISTORY:
% 
% 1. 12/14/05 - created based on scalar version coare26sn.m with input
%    on vectorization from C. Moffat.  
% 2. 12/21/05 - sign error in psiu_26 corrected, and code added to use variable
%    values from the first pass through the iteration loop for the stable case
%    with very thin M-O length relative to zu (zetau>50) (as is done in the 
%    scalar coare26sn and COARE3 codes).
% 3. 7/26/11 - S = dt was corrected to read S = ut.
% 4. 7/28/11 - modification to roughness length parameterizations based 
%    on the CLIMODE, MBL, Gasex and CBLAST experiments are incorporated
% 5. 9/20/2017 - New wave parameterization added based on fits to wave model
% 6. 9/2020 - tested and updated to give consistent readme info and units,
%    and so that no external functions are required. They are all included at
%    end of this program now. Changed names for a few things... including skin
%    dter -> dt_skin; dt -> dt; dqer -> dq_skin; tkt -> dz_skin
%    and others to avoid ambiguity:
%    Rnl -> lw_net; Rns -> sw_net; Rl -> lw_down; Rs -> sw_down;
%    SST -> tskin; Also corrected heights at which qair and psealevel are
%    computed to be more accurate, changed units of qstar to kg/kg, removed
%    extra 1000 on neutral 10 m transfer coefficients;
% 7. 10/2021 - implemented zenith angle dependent sw_up and sw_net;
%    changed buoyancy flux calculation to follow Stull 
%    textbook version of tv* and tv_sonic*; reformatted preamble of program for
%    consistent formatting and to reduce redundancy; resolved issues of
%    nomenclature around T adjusted to heights vs theta potential
%    temperature when computing dt for the purpose of sensible heat flux.
%-----------------------------------------------------------------------

%***********  prep input data *********************************************

% convert input to column vectors
wspd=wspd(:); tair=tair(:); rhair=rhair(:); psealevel=psealevel(:); tsea=tsea(:);
sw_down=sw_down(:); lw_down=lw_down(:); lat=lat(:); zi=zi(:);
zu=zu(:); zt=zt(:); zq=zq(:);
zref_u=zref_u(:); zref_t=zref_t(:); zref_q=zref_q(:);
prate=prate(:); ssea=ssea(:); wave_cp=wave_cp(:); wave_height=wave_height(:);
N=length(wspd);
jcool=jcoolx*ones(N,1);jcool=jcool(:);

% Option to set local variables to default values if input is NaN... can do
% single value or fill each individual. Warning... this will fill arrays
% with the dummy values and produce results where no input data are valid
% so real/fake output might not be distinguishable after the fact
% ii=find(isnan(psealevel)); psealevel(ii)=1013;    % sea level pressure
% ii=find(isnan(sw_down)); sw_down(ii)=200;   % downwelling shortwave radiation
% ii=find(isnan(lat)); lat(ii)=45;  % latitude
% ii=find(isnan(lw_down)); lw_down(ii)=400-1.6*abs(lat(ii)); % downwelling longwave radiation
% ii=find(isnan(zi)); zi(ii)=600;   % PBL height
% ii=find(isnan(ssea)); ssea(ii)=35;    % salinity

% find missing input data
iip=find(isnan(psealevel)); 
iirs=find(isnan(sw_down)); 
iilat=find(isnan(lat)); 
iirl=find(isnan(lw_down)); 
iizi=find(isnan(zi)); 
iiSs=find(isnan(ssea)); 

% Input variable wspd is assumed to be wind speed corrected for surface current
% (magnitude of difference between wind and surface current vectors). To 
% follow orginal Fairall code, set surface current speed us=0. If us surface
% current data are available, construct wspd prior to using this code and
% input us = 0*wspd here;

is_current_rel_wind = 1;

%%% note... don't these result in the same thing??? is this redundant or
%%% needed at all? or should us = something other than 0? unclear. if it
%%% were nonzero, wouldn't it be an input to the algorithm?
% if current-relative wind is provided as input to algorithm
if is_current_rel_wind == 1
      us = 0*wspd;
% if true wind is provided as input to algorithm
elseif is_current_rel_wind == 0
      us = 0;
end

% convert rhair to specific humidity after accounting for salt effect on freezing
% point of water
tfreeze=-0.0575*ssea+1.71052E-3*ssea.^1.5-2.154996E-4*ssea.*ssea; %freezing point of seawater
qskin = qsat26sea(tsea,psealevel,ssea,tfreeze)./1000; % surface water specific humidity (g/kg)
pair_tq = psealevel - (0.125*zt); % pair at tq measurement height (mb)... usually zt and zq are the same, modify if otherwise
[qair,pv]  = qsat26air(tair,pair_tq,rhair); % specific humidity of air (g/kg).  
    % Assumes rhair relative to ice T<0
    % pv is the partial pressure due to wate vapor in mb
qair=qair./1000;  % change qair to g/g

ice=zeros(size(wspd));
iice=find(tsea<tfreeze); ice(iice)=1; jcool(iice)=0;
zos=5E-4;

%***********  set constants ***********************************************
zref=10;
Beta = 1.2;
von  = 0.4;
fdg  = 1.00; % Turbulent Prandtl number
T2K  = 273.16;
grav = grv(lat);

%***********  air constants ***********************************************
Rgas = 287.1;
Le   = (2.501-.00237*tsea)*1e6;
cpa  = 1004.67;
cpv  = cpa*(1+0.84*qair);
rhoair = pair_tq*100./(Rgas*(tair+T2K).*(1+0.61*qair));
% pv is the partial pressure due to wate vapor in mb
rhodry = (pair_tq-pv)*100./(Rgas*(tair+T2K)); % dry air density. 
visa = 1.326e-5*(1+6.542e-3.*tair+8.301e-6*tair.^2-4.84e-9*tair.^3);
lapse=grav/cpa; % dry adiabatic lapse rate, K/km

%***********  cool skin constants  ***************************************
%%% includes salinity dependent thermal expansion coeff for water
tsw=tsea;ii=find(tsea<tfreeze);tsw(ii)=tfreeze(ii);
Al35   = 2.1e-5*(tsw+3.2).^0.79;
Al0   =(2.2*real((tsw-1).^0.82)-5)*1e-5;
Al=Al0+(Al35-Al0).*ssea/35;
%%%%%%%%%%%%%%%%%%%
bets = 7.5e-4; % salintity expansion coeff; assumes beta is independent of T
be   = bets*ssea; % be is beta*salinity
%%%%  see "Computing the seater expansion coefficients directly from the
%%%%  1980 equation of state".  J. Lillibridge, J.Atmos.Oceanic.Tech, 1980.
cpw  = 4000;
rhow = 1022;
visw = 1e-6;
tcw  = 0.6;
bigc = 16*grav*cpw*(rhow*visw)^3./(tcw.^2*rhoair.^2);
wetc = 0.622*Le.*qskin./(Rgas*(tsea+T2K).^2);

%***********  net solar and IR radiation fluxes ***************************
%%% net solar flux, aka sw, aka shortwave

% *** for time-varying, i.e. zenith angle varying albedo using Payne 1972:
% insert 'E' for input to albedo function if longitude is defined positive
% to E (normal), in this case lon sign will be flipped for the calculation.
% Otherwise specify 'W' and the sign will not be changed in the function. 
% Check: albedo should usually peak at sunrise not at sunset, though it may
% vary based on sw_down.
[alb,~,~,~] = albedo_vector(sw_down,jd,lon,lat,'E');
sw_net = (1-alb).*sw_down; % varying albedo correction, positive heating ocean

% *** for constant albedo:
% sw_net = 0.945.*sw_down; % constant albedo correction, positive heating ocean

%%% net longwave aka IR aka infrared
% initial value here is positive for cooling ocean in the calculations
% below. However it is returned at end of program as -lw_net in final output so 
% that it is positive heating ocean like the other input radiation values.
% the one redone at the end of the program also uses the real tskin
lw_net = 0.97*(5.67e-8*(tsea-0.3*jcool+T2K).^4-lw_down); 

%***********  begin bulk loop *********************************************

%***********  first guess *************************************************

% wind speed minus current speed... note us = 0 if wspd input is already
% computed as the current-relative wind speed. 
du = wspd-us;
% air sea temperature difference for the purpose of sensible heat flux
dt = tsea-tair-lapse.*zt;

% air-sea T diff must account for lapse rate between surface and instrument height
% tair is air temperature in C, tsea is surface water temperature in C. dt is
% an approximation that is equivalent to  dtheta where theta is the
% potential temperature, and the pressure at sea level and instrument level
% are used. They are equivalent (max difference = 0.0022 K). This way 
% elimniates the need to involve the pressures at different heights. 
% Using or assuming dry adiabatic lapse rate between the two heights
% doesn't matter because if real pressures are used the result is the 
% unchanged. The dt need not include conversion to K either. Here's an example: 
% grav = grv(lat);
% lapse=grav/cpa;
% P_at_tq_height=(psealevel - (0.125*zt)); % pair at tq measurement height (mb)
% note psealevel is adjusted using same expression from pa height
% tair is originally in C and C2K = 273.15 to convert from C to K
% theta = (b10.tair+C2K).*(1000./pair_tq).^(Rgas/cpa); 
% tairdjK = (b10.tair+C2K) + lapse*zt;
% tadj = b10.tair + lapse*zt;
% theta_sfc = (b10.tskin+C2K).*(1000./b10.psealevel).^(Rgas/cpa); 
% tadjK_sfc = b10.tskin+C2K;
% tadj_sfc = b10.tskin;
% 
%%% the adj versions are only 0.0022 K smaller than theta versions)
% dtheta = theta_sfc - theta;
% dtadjK = tadjK_sfc - tadjK;
% dtadj = tadj_sfc - tadj; % so dt = tskin - (tair + lapse*zt) = tskin - tair - lapse*zt


% put things into different units and expressions for more calculations,
% including first guesses that get redone later
dq = qskin-qair;
tair = tair+T2K;
tv = tair.*(1+0.61*qair); % note, not used anymore
gust = 0.5;
dt_skin  = 0.3;
ut    = sqrt(du.^2+gust.^2);
u10   = ut.*log(10/1e-4)./log(zu/1e-4);
ustar   = 0.035*u10;
zo10  = 0.011*ustar.^2./grav + 0.11*visa./ustar;
cd10  = (von./log(10./zo10)).^2;
ch10  = 0.00115;
ct10  = ch10./sqrt(cd10);
zot10 = 10./exp(von./ct10);
cd    = (von./log(zu./zo10)).^2;
ct    = von./log(zt./zot10);
cc    = von*ct./cd;
Ribcu = -zu./zi./.004/Beta^3;
Ribu  = -grav.*zu./tair.*((dt-dt_skin.*jcool)+.61*tair.*dq)./ut.^2;
zetau = cc.*Ribu.*(1+27/9*Ribu./cc);
k50=find(zetau>50); % stable with very thin M-O length relative to zu
k=find(Ribu<0); 
if length(Ribcu)==1
    zetau(k)=cc(k).*Ribu(k)./(1+Ribu(k)./Ribcu); clear k;
else
    zetau(k)=cc(k).*Ribu(k)./(1+Ribu(k)./Ribcu(k)); clear k;
end
L10 = zu./zetau;
gf=ut./du;
ustar = ut.*von./(log(zu./zo10)-psiu_40(zu./L10));
tstar = -(dt-dt_skin.*jcool).*von*fdg./(log(zt./zot10)-psit_26(zt./L10));
qstar = -(dq-wetc.*dt_skin.*jcool)*von*fdg./(log(zq./zot10)-psit_26(zq./L10));
dz_skin = 0.001*ones(N,1);

%**********************************************************
%  The following gives the new formulation for the
%  Charnock variable
%**********************************************************
%%%%%%%%%%%%%   COARE 3.5 wind speed dependent charnock
charnC = 0.011*ones(N,1);
umax=19;
a1=0.0017;
a2=-0.0050;
charnC=a1*u10+a2;
k=find(u10>umax);
charnC(k)=a1*umax+a2;


%%%%%%%%%   if wave age is given but not wave height, use parameterized
%%%%%%%%%   wave height based on wind speed
    hsig=(0.02*(wave_cp./u10).^1.1-0.0025).*u10.^2;
    hsig=max(hsig,.25);
    ii=find(~isnan(wave_cp) & isnan(wave_height));
    wave_height(ii)=hsig(ii);
    
Ad=0.2;  %Sea-state/wave-age dependent coefficients from wave model
%Ad=0.73./sqrt(u10);
Bd=2.2;
zoS=wave_height.*Ad.*(ustar./wave_cp).^Bd;
charnS=zoS.*grav./ustar./ustar;

nits=10; % number of iterations
charn=charnC;
ii=find(~isnan(wave_cp));charn(ii)=charnS(ii);
%**************  bulk loop ************************************************

for i=1:nits
    zeta=von.*grav.*zu./tair.*(tstar +.61*tair.*qstar)./(ustar.^2);
    L=zu./zeta;
    zo=charn.*ustar.^2./grav+0.11*visa./ustar; % surface roughness
    zo(iice)=zos;
    rr=zo.*ustar./visa;
    
    % This thermal roughness length Stanton number is close to COARE 3.0 value
    zoq=min(1.6e-4,5.8e-5./rr.^.72);  
     
    % Andreas 1987 for snow/ice
    ik=find(rr(iice)<=.135);
   		rt(iice(ik))=rr(iice(ik))*exp(1.250);
     	rq(iice(ik))=rr(iice(ik))*exp(1.610);
     ik=find(rr(iice)>.135 & rr(iice)<=2.5);
        rt(iice(ik))=rr(iice(ik)).*exp(0.149-.55*log(rr(iice(ik))));
     	rq(iice(ik))=rr(iice(ik)).*exp(0.351-0.628*log(rr(iice(ik))));
     ik=find(rr(iice)>2.5 & rr(iice)<=1000);
     	rt(iice(ik))=rr(iice(ik)).*exp(0.317-0.565*log(rr(iice(ik)))-0.183*log(rr(iice(ik))).*log(rr(iice(ik))));
      	rq(iice(ik))=rr(iice(ik)).*exp(0.396-0.512*log(rr(iice(ik)))-0.180*log(rr(iice(ik))).*log(rr(iice(ik))));
 
    % Dalton number is close to COARE 3.0 value
    zot=zoq;                               
    cdhf=von./(log(zu./zo)-psiu_26(zu./L));
    cqhf=von.*fdg./(log(zq./zoq)-psit_26(zq./L));
    cthf=von.*fdg./(log(zt./zot)-psit_26(zt./L));
    ustar=ut.*cdhf;
    qstar=-(dq-wetc.*dt_skin.*jcool).*cqhf;
    tstar=-(dt-dt_skin.*jcool).*cthf;
    
    % original COARE version buoyancy flux
    tvstar_old=tstar+0.61*tair.*qstar;
    tvsstar_old=tstar+0.51*tair.*qstar;
    
    % new COARE version buoyancy flux from Stull (1988) page 146
    % tstar here uses dt with the lapse rate adjustment (see code above). The
    % qair and tair values should be at measurement height, not adjusted heights
    tvstar=tstar.*(1+0.61.*qair) + 0.61*tair.*qstar;
    tvsstar=tstar.*(1+0.51.*qair) + 0.51*tair.*qstar;
    
    Bf=-grav./tair.*ustar.*tvstar;
    gust=nan*ones(N,1); % default value used to be 0.2... but it wasn't getting redone
    if length(find(Bf < 0))> 1
%         disp('Bf < 0');
    end
    k=find(Bf>0); 

    %%% gustiness in this way is from the original code. Notes: 
    % we measured the actual gustiness by measuring the variance of the
    % wind speed and empirically derived the the scaling. It's empirical
    % but it seems appropriate... the longer the time average then the larger
    % the gustiness factor should be, to account for the gustiness averaged
    % or smoothed out by the averaging. wstar is the convective velocity.
    % gustiness is beta times wstar. gustiness is different between mean of
    % velocity and square of the mean of the velocity vector components.
    % The actual wind (mean + fluctuations) is still the most relavent 
    % for the flux. The models do u v w, and then compute vector avg to get
    % speed, so we've done the same thing. coare alg input is the magnitude
    % of the mean vector wind relative to water. 

    if length(zi)==1
        gust(k)=Beta*(Bf(k).*zi).^.333; clear k;
    else
        gust(k)=Beta*(Bf(k).*zi(k)).^.333; clear k;
    end
    ut=sqrt(du.^2+gust.^2);
    gf=ut./du;
    hs=-rhoair*cpa.*ustar.*tstar;
    hl=-rhoair.*Le.*ustar.*qstar;
    qout=lw_net+hs+hl; 
    %%% rain heat flux is not included in qout because we don't fully
    % understand the evolution or gradient of the cool skin layer in the
    % presence of rain, and the sea snake subsurface measurement input
    % value will capture some of the rain-cooled water already. TBD.
    
    %%% solar absorption: 
    % The absorption function below is from a Soloviev paper, appears as 
    % Eq 17 Fairall et al. 1996 and updated/tested by Wick et al. 2005. The
    % coefficient was changed from 1.37 to 0.065 ~ about halved.
    % Most of the time this adjustment makes no difference. But then there
    % are times when the wind is weak, insolation is high, and it matters a
    % lot. Using the original 1.37 coefficient resulted in many unwarranted
    % warm-skins that didn't seem realistic. See Wick et al. 2005 for details.
    % That's the last time the cool-skin routine was updated. The
    % absorption is not from Paulson & Simpson because that was derived in a lab.
    % It absorbed too much and produced too many warm layers. It likely  
    % approximated too much near-IR (longerwavelength solar) absorption
    % which probably doesn't make it to the ocean since it was probably absorbed
    % somewhere in the atmosphere first. The below expression could 
    % likely use 2 exponentials if you had a shallow mixed layer... 
    % but we find better results with 3 exponentials. That's the best so 
    % far we've found that covers the possible depths. 
    dels=sw_net.*(0.065+11*dz_skin-6.6e-5./dz_skin.*(1-exp(-dz_skin/8.0e-4)));  
    qcol=qout-dels;
    % only needs stress, water temp, sum of sensible, latent, ir, solar,
    % and latent individually. 
    alq=Al.*qcol+be.*hl.*cpw./Le; % buoyancy flux... to make it sink. Positive buoyancy fluxes generate tke. cooling at the interface creates turb in the ocean through the buoyancy term. and destroys it on the air side. 
    xlamx=6.0*ones(N,1); % contains buoyancy effect. There are two sources.Net cooling of interface by latent, sensible, ir, 
%     the other is the salinity part caused by latent heat flux (evap) leaving behind salt. 
    dz_skin=min(0.01, xlamx.*visw./(sqrt(rhoair./rhow).*ustar));
    k=find(alq>0);
    xlamx(k)=6./(1+(bigc(k).*alq(k)./ustar(k).^4).^0.75).^0.333;
    dz_skin(k)=xlamx(k).*visw./(sqrt(rhoair(k)./rhow).*ustar(k)); clear k;
    dt_skin=qcol.*dz_skin./tcw;
    dq_skin=wetc.*dt_skin;
    lw_net=0.97*(5.67e-8*(tsea-dt_skin.*jcool+T2K).^4-lw_down); % used to update dt_skin
    if i==1 % save first iteration solution for case of zetau>50;
        ustar50=ustar(k50);tstar50=tstar(k50);qstar50=qstar(k50);L50=L(k50);
        zeta50=zeta(k50);dT_skin50=dt_skin(k50);dq_skin50=dq_skin(k50);dz_skin50=dz_skin(k50);
    end
    u10N = ustar./von./gf.*log(10./zo);
    charnC=a1*u10N+a2;
    k=u10N>umax;
    charnC(k)=a1*umax+a2;
    charn=charnC;
    zoS=wave_height.*Ad.*(ustar./wave_cp).^Bd;%-0.11*visa./ustar;
    charnS=zoS.*grav./ustar./ustar;
    ii=find(~isnan(wave_cp));charn(ii)=charnS(ii);
end

% insert first iteration solution for case with zetau>50
ustar(k50)=ustar50;tstar(k50)=tstar50;qstar(k50)=qstar50;L(k50)=L50;
zeta(k50)=zeta50;dt_skin(k50)=dT_skin50;dq_skin(k50)=dq_skin50;dz_skin(k50)=dz_skin50;

%****************  compute fluxes  ****************************************
tau=rhoair.*ustar.*ustar./gf;         % wind stress
hs=-rhoair.*cpa.*ustar.*tstar;       % sensible heat flux
hl=-rhoair.*Le.*ustar.*qstar;        % latent heat flux
hb=-rhoair.*cpa.*ustar.*tvstar;      % atmospheric buoyancy flux new from Jim Edson
hb_old=-rhoair.*cpa.*ustar.*tvstar_old;    % atmospheric buoyancy flux original
hbs=-rhoair.*cpa.*ustar.*tvsstar;     % atmospheric buoyancy flux sonic new from Jim Edson
hbs_old=-rhoair.*cpa.*ustar.*tvsstar_old;   % atmospheric buoyancy flux sonic original

wbar=1.61*hl./Le./(1+1.61*qair)./rhoair+hs./rhoair./cpa./tair;  % mean w
hl_webb=rhoair.*wbar.*qair.*Le;       % webb correction to add to covariance hl
erate=1000*hl./Le./1000*3600;   % evap rate mm/hour

%*****  compute transfer coeffs relative to ut @ meas. ht  ****************
cd= tau./rhoair./ut./max(.1,du);
ch=-ustar.*tstar./ut./(dt-dt_skin.*jcool);
ce=-ustar.*qstar./(dq-dq_skin.*jcool)./ut;

%***%%  compute 10-m neutral coeff relative to ut *************************
cd10N=von.^2./log(10./zo).^2;
ch10N=von.^2.*fdg./log(10./zo)./log(10./zot);
ce10N=von.^2.*fdg./log(10./zo)./log(10./zoq);

%***%%  compute 10-m neutral coeff relative to ut *************************

% Find the stability functions for computing values at user defined 
% reference heights and 10 m
psi=psiu_26(zu./L);
psi10=psiu_26(10./L);
psiref=psiu_26(zref_u./L);
psiT=psit_26(zt./L);
psi10T=psit_26(10./L);
psirefT=psit_26(zref_t./L);
psirefQ=psit_26(zref_q./L);
gf=ut./du;

%*********************************************************
%  Determine the wind speeds relative to ocean surface at different heights
%  Note that ustar is the friction velocity that includes 
%  gustiness ustar = sqrt(cd) S, which is equation (18) in
%  Fairall et al. (1996)
%*********************************************************
S = ut;
U = du;
S10 = S + ustar./von.*(log(10./zu)-psi10+psi);
wspd_10 = S10./gf;
% or wspd_10 = U + ustar./von./gf.*(log(10/zu)-psi10+psi);
wspd_ref = U + ustar./von./gf.*(log(zref_u./zu)-psiref+psi);
wspd_N = U + psi.*ustar/von./gf;
wspd_10N = wspd_10 + psi10.*ustar/von./gf; % technically this removes gustiness because the average wind is the wspd_10
wspd_refN = wspd_ref + psiref.*ustar/von./gf;

% unused... these are here to make sure you gets the same answer whether 
% you used the thermal calculated roughness lengths or the values at the 
% measurement height. So at this point they are just illustrative and can
% be removed or ignored if you want.
wspd_N_old = ustar/von./gf.*log(zu./zo);
wspd_10N_old = ustar./von./gf.*log(10./zo);
wspd_refN_old  = ustar./von./gf.*log(zref_u./zo);

%******** rain heat flux *****************************
dwat=2.11e-5*((tair+T2K)./T2K).^1.94; % water vapor diffusivity
dtmp=(1. + 3.309e-3*tair - 1.44e-6.*tair.*tair).*0.02411./(rhoair.*cpa); % heat diffusivity
dqs_dt=qair.*Le./(Rgas.*(tair+T2K).^2); % Clausius-Clapeyron
alfac= 1./(1+0.622*(dqs_dt.*Le.*dwat)./(cpa.*dtmp)); % wet bulb factor
hrain= prate.*alfac.*cpw.*((tsea-tair-dt_skin.*jcool)+(qskin-qair-dq_skin.*jcool).*Le./cpa)./3600; % rain heat flux

% ocean skin surface temperature, or interface temperature, C
% note that dt_skin will be zero if jcool = 0, i.e. if the cool skin model
% is not meant to be used to estimate the fluxes or tskin
tskin=tsea-(dt_skin.*jcool); 

% psealevel is sea level pressure, so use subtraction through hydrostatic equation 
% to get P10 and pair at reference height
pair_10 = psealevel - (0.125*10);
pair_ref = psealevel - (0.125*zref);

tair_10 = tair + tstar./von.*(log(10./zt)-psi10T+psiT) + lapse.*(zt-10);
tair_ref = tair + tstar./von.*(log(zref_t./zt)-psirefT+psiT) + lapse.*(zt-zref_t);
tair_N = tair + psiT.*tstar/von;
tair_10N = tair_10 + psi10T.*tstar/von;
tair_refN = tair_ref + psirefT.*tstar/von;

% unused... these are here to make sure you gets the same answer whether 
% you used the thermal calculated roughness lengths or the values at the 
% measurement height. So at this point they are just illustrative and can
% be removed or ignored if you want.
tair_N_old = tskin + tstar/von.*log(zt./zot)-lapse.*zt;
tair_10N_old = tskin + tstar/von.*log(10./zot)-lapse.*10;
tair_refN_old = tskin + tstar/von.*log(zref_t./zot)-lapse.*zref_t;

dq_skin=wetc.*dt_skin.*jcool;
qskin=qskin-dq_skin;
dq_skin = dq_skin*1000;
qskin=qskin*1000;
qair=qair*1000;
qair_10 = qair + 1E3.*qstar./von.*(log(10./zq)-psi10T+psiT);
qair_ref = qair + 1E3.*qstar./von.*(log(zref_q./zq)-psirefQ+psiT);
qair_N = qair + psiT.*1E3.*qstar/von./sqrt(gf);
qair_10N = qair_10 + psi10T.*1E3.*qstar/von;
qair_refN = qair_ref + psirefQ.*1E3.*qstar/von;

% unused... these are here to make sure you gets the same answer whether 
% you used the thermal calculated roughness lengths or the values at the 
% measurement height. So at this point they are just illustrative and can
% be removed or ignored if you want.
qair_N_old = qskin + 1E3.*qstar/von.*log(zq./zoq);
qair_10N_old = qskin + 1E3.*qstar/von.*log(10./zoq);
qair_refN_old = qskin + 1E3.*qstar/von.*log(zref_q./zoq);

rhair_ref=RHcalc(tair_ref,pair_ref,qair_ref/1000,tfreeze);
rhair_10=RHcalc(tair_10,pair_10,qair_10/1000,tfreeze);

% recompute rhoair_10 with 10-m values of everything else.
rhoair_10 = pair_10*100./(Rgas*(tair_10+T2K).*(1+0.61*(qair_10/1000)));

% recompute rhoair_ref with reference height values of everything else
rhoair_ref = pair_ref*100./(Rgas*(tair_ref+T2K).*(1+0.61*qair_ref));


%%%%%%%%%%%%  Other wave breaking statistics from Banner-Morison wave model
wave_wc_frac=7.3E-4*(wspd_10N-2).^1.43;      % wind only
wave_wc_frac(wspd_10<2.1)=1e-5;

kk = find(isfinite(wave_cp) == 1);   % wind and waves if wave info is available
wave_wc_frac(kk)=1.6e-3*wspd_10N(kk).^1.1./sqrt(wave_cp(kk)./wspd_10N(kk));  

wave_edis=0.095*rhoair.*wspd_10N.*ustar.^2;  %  energy dissipation rate from breaking waves W/m^2
wave_wc_frac(iice)=0;wave_edis(iice)=0;

% only return values if jcool = 1; if cool skin model was intended to be run
% returns 0 if jcool = 0, if not intending to apply the cool skin to tskin
% after using this program
dt_skin=dt_skin.*jcool;
dq_skin=dq_skin.*jcool;

% get rid of filled values where nans are present in input data
bad_input = find(isnan(wspd) ==1);
gust(bad_input) = nan;
dz_skin(bad_input) = nan;
zot(bad_input) = nan;
zoq(bad_input) = nan;

% alert users if other NaN data in inputs, other than wind, might be throwing off output!
% wspd,zu,tair,zt,rh,zq,psealevel,tsea,sw_down,lw_down,lat,lon,jd,zi,prate,ssea,wave_cp,wave_height,zref_u,zref_t,zref_q)

disp(['var = wspd, current-relative wind speed ...  n(NaN) = ' sprintf('%i',length(find(isnan(u) == 1)) )]);
disp(['var = tair, air temp ...  n(NaN) = ' sprintf('%i',length(find(isnan(tair) == 1)) )]);
disp(['var = psealevel, air pressure ...  n(NaN) = ' sprintf('%i',length(find(isnan(tair) == 1)) )]);
disp(['var = tsea, near-surface sea temp ...  n(NaN) = ' sprintf('%i',length(find(isnan(tair) == 1)) )]);
disp(['var = sw_down, downwelling shortwave ...  n(NaN) = ' sprintf('%i',length(find(isnan(tair) == 1)) )]);
disp(['var = lw_down, downwelling longwave ...  n(NaN) = ' sprintf('%i',length(find(isnan(tair) == 1)) )]);
disp(['var = lat, latitude ...  n(NaN) = ' sprintf('%i',length(find(isnan(tair) == 1)) )]);
disp(['var = lon, longitude ...  n(NaN) = ' sprintf('%i',length(find(isnan(tair) == 1)) )]);
disp(['var = jd, year/julian day ...  n(NaN) = ' sprintf('%i',length(find(isnan(tair) == 1)) )]);
disp(['var = prate, rain rate ...  n(NaN) = ' sprintf('%i',length(find(isnan(tair) == 1)) )]);
disp(['var = ssea, near-surface salinity ...  n(NaN) = ' sprintf('%i',length(find(isnan(tair) == 1)) )]);
disp(['var = wave_period, wave period ...  n(NaN) = ' sprintf('%i',length(find(isnan(tair) == 1)) )]);
disp(['var = wave_height, significant wave height ...  n(NaN) = ' sprintf('%i',length(find(isnan(tair) == 1)) )]);


% flip lw_net sign for standard radiation sign convention: positive heating ocean
lw_net = -lw_net; 
% this sign flip means lw_net, net long wave flux, is equivalent to:
% lw_net = 0.97*(lw_dn_best - 5.67e-8*(tskin+C2K).^4);

%%% I'm not sure what's best, but if this isn't here, then the program
%%% thinks that the variables don't get used. Because we end up adding them
%%% in a more efficient way below with eval function. If vars_to_save gets
%%% changed below, remember to change A_array
A_array = [tau hs hl hb hbs hl_webb hrain erate
    tstar qstar ustar ...
    zo zot zoq L zeta cd ch ce cd10N ch10N ce10N ...
    dt_skin dq_skin dz_skin ...
    wspd_ref tair_ref qair_ref rhair_ref pair_ref rhoair_ref ...
    wspd_refN tair_refN qair_refN ...
    lw_net sw_net Le rhoair qskin gust wave_wc_frac wave_edis ...
    wspd_N wspd_10 wspd_10N tair_10 tair_10N qair_10 qair_10N rhair_10 pair_10 rhoair_10];


%%% save the vars in A_array to a matlab structure A
vars_to_save = {'tau';'hs';'hl';'hb';'hbs';'hl_webb';'hrain';'erate';...
    'tstar';'qstar';'ustar'...
    'zo';'zot';'zoq';'L';'zeta';'cd';'ch';'ce';'cd10N';'ch10N';'ce10N';...
    'dt_skin';'dq_skin';'dz_skin';...
    'wspd_ref';'tair_ref';'qair_ref';'rhair_ref';'pair_ref';'rhoair_ref';...
    'wspd_refN';'tair_refN';'qair_refN';...
    'lw_net';'sw_net';'Le';'rhoair';'qskin';'gust';'wave_wc_frac';'wave_edis';...
    'wspd_N';'wspd_10';'wspd_10N';'tair_10';'tair_10N';'qair_10';'qair_10N';'rhair_10';'pair_10';'rhoair_10'};

for i = 1:length(vars_to_save)
    eval(['A.' vars_to_save{i} '  = ' vars_to_save{i}  ]);
    eval(['clear ' lvars{i} ';']);
end

end


%% functions... note that different variable names are used here to keep
% them working at all times and not confuse the code
%------------------------------------------------------------------------------
function psi=psit_26(Zeta)
% computes temperature structure function
dZETA=min(50,0.35*Zeta); % stable
psi=-((1+0.6667*Zeta).^1.5+0.6667*(Zeta-14.28).*exp(-dZETA)+8.525);
k=find(Zeta<0); % unstable
x=(1-15*Zeta(k)).^0.5;
psik=2*log((1+x)./2);
x=(1-34.15*Zeta(k)).^0.3333;
psic=1.5*log((1+x+x.^2)./3)-sqrt(3)*atan((1+2*x)./sqrt(3))+4*atan(1)./sqrt(3);
f=Zeta(k).^2./(1+Zeta(k).^2);
psi(k)=(1-f).*psik+f.*psic;
end
%------------------------------------------------------------------------------
function psi=psiwspd_26(Zeta)
% computes velocity structure function
dZETA=min(50,0.35*Zeta); % stable
a=0.7;
b=3/4;
c=5;
d=0.35;
psi=-(a*Zeta+b*(Zeta-c/d).*exp(-dZETA)+b*c/d);
k=find(Zeta<0); % unstable
x=(1-15*Zeta(k)).^0.25;
psik=2*log((1+x)/2)+log((1+x.*x)/2)-2*atan(x)+2*atan(1);
x=(1-10.15*Zeta(k)).^0.3333;
psic=1.5*log((1+x+x.^2)/3)-sqrt(3)*atan((1+2*x)./sqrt(3))+4*atan(1)./sqrt(3);
f=Zeta(k).^2./(1+Zeta(k).^2);
psi(k)=(1-f).*psik+f.*psic;
end
%------------------------------------------------------------------------------
function psi=psiu_40(Zeta)
% computes velocity structure function
dZETA=min(50,0.35*Zeta); % stable
a=1;
b=3/4;
c=5;
d=0.35;
psi=-(a*Zeta+b*(Zeta-c/d).*exp(-dZETA)+b*c/d);
k=find(Zeta<0); % unstable
x=(1-18*Zeta(k)).^0.25;
psik=2*log((1+x)/2)+log((1+x.*x)/2)-2*atan(x)+2*atan(1);
x=(1-10*Zeta(k)).^0.3333;
psic=1.5*log((1+x+x.^2)/3)-sqrt(3)*atan((1+2*x)./sqrt(3))+4*atan(1)./sqrt(3);
f=Zeta(k).^2./(1+Zeta(k).^2);
psi(k)=(1-f).*psik+f.*psic;
end
%------------------------------------------------------------------------------
function exx=bucksat(T,P,Tf)
% computes saturation vapor pressure [mb]
% given T [degC] and P [mb] Tf is freezing pt 
exx=6.1121.*exp(17.502.*T./(T+240.97)).*(1.0007+3.46e-6.*P);
ii=find(T<Tf);
exx(ii)=(1.0003+4.18e-6*P(ii)).*6.1115.*exp(22.452.*T(ii)./(T(ii)+272.55));%vapor pressure ice
end
%------------------------------------------------------------------------------
function qs=qsat26sea(T,P,S,Tf)
% computes surface saturation specific humidity [g/kg]
% given T [degC], S [psu], P [mb]
ex=bucksat(T,P,Tf);
fs=1-0.02*S/35;% reduction sea surface vapor pressure by salinity
es=fs.*ex; 
qs=622*es./(P-0.378*es);
end
%------------------------------------------------------------------------------
function [Q,em]=qsat26air(T,P,RH)
% computes saturation specific humidity [g/kg]
% given T [degC] and P [mb]
Tf=0;%assumes relative humidity for pure water
es=bucksat(T,P,Tf);
em=0.01*RH.*es; % in mb, partial pressure of water vapor
Q=622*em./(P-0.378*em);
end
%------------------------------------------------------------------------------
function g=grv(LAT)
% computes g [m/sec^2] given LAT in deg
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
function RHref=RHcalc(T,P,Q,Tf)
% computes relative humidity given T,P, & Q
es=6.1121.*exp(17.502.*T./(T+240.97)).*(1.0007+3.46e-6.*P);
ii=find(T<Tf);%ice case
es(ii)=6.1115.*exp(22.452.*T(ii)./(T(ii)+272.55)).*(1.0003+4.18e-6*P(ii));
em=Q.*P./(0.378.*Q+0.622);
RHref=100*em./es;
end
%------------------------------------------------------------------------------
function [ALB,T,solarmax,psi] = albedo_vector(SW_DN,JD,LON,LAT,EorW)

%  Computes transmission and albedo from downwelling SW_DN using
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
%disp([num2str(JD) '  ' num2str(SW_DN) '  ' num2str(ALB) '  ' num2str(T) '  ' num2str(i) '  ' num2str(j)])
end