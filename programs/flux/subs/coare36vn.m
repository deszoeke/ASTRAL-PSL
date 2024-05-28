function A=coare36vn(u,zu,t,zt,rh,zq,P,ts,sw_dn,lw_dn,lat,zi,rain,Ss,cp,sigH,zrf_u,zrf_t,zrf_q)
%
% Vectorized version of COARE 3.6 code (Fairall et al, 2003) with 
% modification based on the CLIMODE, MBL and CBLAST experiments 
% (Edson et al., JPO, 43, 2013). The cool skin option is retained but warm layer 
% and surface wave options removed. 
%
% ************************************************************************
% *************** IMPORTANT NOTICE ***************************************
% ************************************************************************
% The current version of the code includes the wind-speed, wave-age and
% sea-state dependent parameterizations of the Charnock variabile as
% described in Edson et al. (2013).  The parameterization is chosen by the 
% inputed values of
%    cp = phase speed of dominant waves (m/s)  
%  sigH = significant wave height (m)
%
% Specifically, if the user inputs:
%
% A=coare36vn(u,zu,t,zt,rh,zq,P,ts,sw_dn,lw_dn,lat,zi,rain,Ss,NaN,NaN,zrf_u,zrf_t,zrf_q);
%   the wind-speed dependent formulation is used
% A=coare36vn(u,zu,t,zt,rh,zq,P,ts,sw_dn,lw_dn,lat,zi,rain,Ss,cp,NaN,zrf_u,zrf_t,zrf_q);
%   the wave-age dependent formulation is used
% A=coare36vn(u,zu,t,zt,rh,zq,P,ts,sw_dn,lw_dn,lat,zi,rain,Ss,cp,sigH,zrf_u,zrf_t,zrf_q);
%   the sea-state dependent formulation is used
%
% The sea-state dependent formulation requires both cp and sigH. 
%
% The parameterizations are based on fits to the Banner-Norison wave model 
% and the Fairall-Edson flux database.  
%
%********************************************************************
% An important component of this code is whether the inputed ts 
% represents the skin temperature of a near surface temperature.  
% How this variable is treated is determined by the jcool parameter:
% set jcool=1 if Ts is bulk ocean temperature (default),
%     jcool=0 if Ts is true ocean skin temperature. 
%********************************************************************

jcoolx=1;%set to 1.0 if you want the cool skin correction  computed for ocean surface temperature

% The code assumes u,t,rh,ts,P,sw_dn,lw_dn,rain,Ss,cp,sigH are vectors; 
% sensor heights (zu,zt,zl) latitude lat, and PBL height zi may be constants;
% air pressure P and radiation sw_dn, lw_dn may be vectors or 
% constants. Input NaNs as vectors or single values to indicate no data. 
%
% The code allows salinity as a input.  
% Open ocean Ss=35; Great Lakes Ss=0;  The salinity defaults to 35 is NaN
% is input.
%
% This version also allows input of reference heights, which are used to 
% compute values of wind velocity, temperature and specific humidity at
% those heights. These heights default to 10m if NaN is input
%
% Inputs:  
%
%     u = water-relative mean wind speed magnitude (m/s) at height zu (m)
%         If not available, use true wind speed to compute fluxes in 
%         earth-coordinates only which will be ignoring the stress 
%         contribution by ocean current, which affects all other fluxes too.
%     t = air temperature (degC) at height zt (m)
%    rh = relative humidity (%) at height zq (m)
%     P = surface sea level air pressure (mb) (typical value = 1013)
%    ts = seawater temperature (degC) see jcool below
% sw_dn = downward (positive) shortwave radiation (W/m^2) (typical value = 150) 
% lw_dn = downward (positive) longwave radiation (W/m^2) (typical value = 370)
%   lat = latitude
%    zi = PBL height (m) (default or typical value = 600m)
%  rain = rain rate (mm/hr)
%    Ss = sea surface salinity (PSU)
%    cp = phase speed of dominant waves (m/s)  
%  sigH = significant wave height (m)
%  zu, zt, zq heights of the observations (m)
%  zrf_u, zrf_t, zrf_q  reference height for profile.  Use this to compare observations 
%  at different heights  
%
% The user controls the output at the end of the code.
%
% A fields
% Radiation signs: positive warms the ocean
% Flux signs: sensible, rain, and latent flux signs: positive cools the ocean
% NOTE: signs change throughout the program for ease of calculations. The
% units noted here are for the final outputs.
%
%    usr = friction velocity that includes gustiness (m/s)
%    tau = wind stress that includes gustiness (N/m^2)
%    hsb = sensible heat flux (W/m^2) ... positive for Tair < Tskin
%    hlb = latent heat flux (W/m^2) ... positive for qair < qs
%    hbb = atmospheric buoyany flux (W/m^2)... positive when hlb and hsb heat the atmosphere
%   hsbb = atmospheric buoyancy flux from sonic ... as above, computed with sonic anemometer T
% hlwebb = webb factor to be added to hl covariance and ID latent heat fluxes
%    tsr = temperature scaling parameter (K)
%    qsr = specific humidity scaling parameter (g/kg)
%     zo = momentum roughness length (m) 
%    zot = thermal roughness length (m) 
%    zoq = moisture roughness length (m)
%     Cd = wind stress transfer (drag) coefficient at height zu   
%     Ch = sensible heat transfer coefficient (Stanton number) at height zu   
%     Ce = latent heat transfer coefficient (Dalton number) at height zu
%      L = Monin-Obukhov length scale (m) 
%    zet = Monin-Obukhov stability parameter zu/L (dimensionless)
%dT_skin = cool-skin temperature depression (degC), pos value means skin is cooler than subskin
%dq_skin = cool-skin humidity depression (g/kg)
%dz_skin = cool-skin thickness (m)
%    Urf = wind speed at reference height (user can select height at input)
%    Trf = air temperature at reference height
%    Qrf = air specific humidity at reference height
%   RHrf = air relative humidity at reference height
%   UrfN = neutral value of wind speed at reference height
% lw_net = Net IR radiation computed by COARE (W/m2)... positive heating ocean
% sw_net = Net solar radiation computed by COARE (W/m2)... positive heating ocean
%     Le = latent heat of vaporization (J/K)
%   rhoa = density of air at input parameter height zt, typically same as zq (kg/m3)
%     UN = neutral value of wind speed at zu (m/s)
%    U10 = wind speed adjusted to 10 m (m/s)
%   UN10 = neutral value of wind speed at 10m (m/s)
% Cdn_10 = neutral value of drag coefficient at 10m (unitless)
% Chn_10 = neutral value of Stanton number at 10m (unitless)
% Cen_10 = neutral value of Dalton number at 10m (unitless)
%  hrain = rain heat flux (W/m^2)... positive cooling ocean
%     Qs = sea surface specific humidity, i.e. assuming saturation (g/kg)
%   Evap = evaporation rate (mm/h)
%    T10 = air temperature at 10m (deg C)
%    Q10 = air specific humidity at 10m (g/kg)
%   RH10 = air relative humidity at 10m (%)
%    P10 = air pressure at 10m (mb)
% rhoa10 = air density at 10m (kg/m3)
%   gust = gustiness velocity (m/s)
%wc_frac = whitecap fraction (ratio)
%   Edis = energy dissipated by wave breaking (W/m^2)

% Notes: 1) u is the surface-relative wind speed, i.e., the magnitude of the
%           difference between the wind (at zu) and ocean surface current 
%           vectors.
%        2) Set jcool=0 in code if ts is true surface skin temperature,
%           otherwise ts is assumed the bulk temperature and jcool=1.
%        3) Assign a default value to P, lw_dn, sw_dn, lat, zi if unknown. Single
%           value is okay.
%        4) Code updates the cool-skin temperature depression dT_skin and thickness
%           dz_skin during iteration loop for consistency.
%        5) Number of iterations set to nits = 6.

% Reference:
%
%  Fairall, C.W., E.F. Bradley, J.E. Hare, A.A. Grachev, and J.B. Edson (2003),
%  Bulk parameterization of air sea fluxes: updates and verification for the 
%  COARE algorithm, J. Climate, 16, 571-590.
%
%  Edson, J.B., J. V. S. Raju, R.A. Weller, S. Bigorre, A. Plueddemann, C.W. Fairall, 
%  S. Miller, L. Mahrt, Dean Vickers, and Hans Hersbach, 2013: On the Exchange of momentum
%  over the open ocean. J. Phys. Oceanogr., 43, 1589–1610. doi: http://dx.doi.org/10.1175/JPO-D-12-0173.1 

% Code history:
% 
% 1. 12/14/05 - created based on scalar version coare26sn.m with input
%    on vectorization from C. Moffat.  
% 2. 12/21/05 - sign error in psiu_26 corrected, and code added to use variable
%    values from the first pass through the iteration loop for the stable case
%    with very thin M-O length relative to zu (zetu>50) (as is done in the 
%    scalar coare26sn and COARE3 codes).
% 3. 7/26/11 - S = dT was corrected to read S = ut.
% 4. 7/28/11 - modification to roughness length parameterizations based 
%    on the CLIMODE, MBL, Gasex and CBLAST experiments are incorporated
% 5. New wave parameterization added 9/20/2017  based on fits to wave model
% 5. tested and updated in 9/2020 to give consistent readme info and units,
%    and so that no external functions are required. They are all included at
%    end of this program now. Changed names for a few things... including skin
%    dter -> dT_skin; dt -> dT; dqer -> dq_skin; tkt -> dz_skin
%    and others to avoid ambiguity:
%    Rnl -> lw_net; Rns -> sw_net; Rl -> lw_dn; Rs -> sw_dn;
%    SST -> Tskin
%-----------------------------------------------------------------------

% convert input to column vectors
u=u(:);t=t(:);rh=rh(:);P=P(:);ts=ts(:);
sw_dn=sw_dn(:);lw_dn=lw_dn(:);lat=lat(:);zi=zi(:);
zu=zu(:);zt=zt(:);zq=zq(:);
zrf_u=zrf_u(:);zrf_t=zrf_t(:);zrf_q=zrf_q(:);
rain=rain(:);  
Ss=Ss(:);cp=cp(:);sigH=sigH(:);
N=length(u);
jcool=jcoolx*ones(N,1);jcool=jcool(:);

% Option to set local variables to default values if input is NaN... can do
% single value or fill each individual. Warning... this will fill arrays
% with the dummy values

ii=find(isnan(zrf_u)); zrf_u(ii)=10;    % reference height for u
ii=find(isnan(zrf_t)); zrf_t(ii)=10;    % reference height for t
ii=find(isnan(zrf_q)); zrf_q(ii)=10;    % reference height for q
ii=find(isnan(P)); P(ii)=1013;          % pressure
ii=find(isnan(zi)); zi(ii)=600;         % PBL height
ii=find(isnan(Ss)); Ss(ii)=35;          % Salinity
ii=find(isnan(sw_dn)); sw_dn(ii)=200;   % incident shortwave radiation
ii=find(isnan(lat)); lat(ii)=45;        % latitude
ii=find(isnan(lw_dn)); 
lw_dn(ii)=400; %-1.6*abs(lat(ii));         % incident longwave radiation

% set local variables to default values if input is NaN
% if isnan(P); P=1013*ones(N,1); end;      % pressure
% if isnan(Rs); Rs=150*ones(N,1); end;     % incident shortwave radiation
% if isnan(Rl); Rl=370*ones(N,1); end;     % incident longwave radiation
% if isnan(lat); lat=45; end;              % latitude
% if isnan(zi); zi=600; end;               % PBL height
% 
% iip=find(isnan(P)); 
% iirs=find(isnan(sw_dn)); 
% iilat=find(isnan(lat)); 
% iirl=find(isnan(lw_dn)); 
% iizi=find(isnan(zi)); 
% iiSs=find(isnan(Ss)); 

% input variable u is assumed to be wind speed corrected for surface current
% (magnitude of difference between wind and surface current vectors). to 
% follow orginal Fairall code, set surface current speed us=0. if us data 
% are available, construct u prior to using this code.
us = 0*u;

% convert rh to specific humidity after accounting for salt effect on freezing
% point of water
% JBE - I am not too sure about the pressure adjustment done here.

Tf=-0.0575*Ss+1.71052E-3*Ss.^1.5-2.154996E-4*Ss.*Ss; %freezing point of seawater
Qs = qsat26sea(ts,P,Ss,Tf)./1000;                    % surface water specific humidity (g/kg)
P_tq = P - (0.125*zt);                               % P at tq measurement height
[Q,Pv]  = qsat26air(t,P_tq,rh);                      % specific humidity of air (g/kg).  

% Assumes rh relative to ice T<0
% Pv is the partial pressure due to water vapor in mb
Q=Q./1000;  % change back to g/g

ice=zeros(size(u));
iice=find(ts<Tf);ice(iice)=1;jcool(iice)=0;
zos=5E-4;

%***********  set constants **********************************************
zref=10;
Beta = 1.2;
von  = 0.4;
fdg  = 1.00; % Turbulent Prandtl number
T2K  = 273.16;
grav = grv(lat);

%***********  air constants **********************************************
Rgas = 287.1;
Le   = (2.501-.00237*ts)*1e6;
cpa  = 1004.67;
cpv  = cpa*(1+0.84*Q);
rhoa = P_tq*100./(Rgas*(t+T2K).*(1+0.61*Q));
% Pv is the partial pressure due to wate vapor in mb
rhodry = (P_tq-Pv)*100./(Rgas*(t+T2K)); % dry air density. 
visa = 1.326e-5*(1+6.542e-3.*t+8.301e-6*t.^2-4.84e-9*t.^3);
%**************************************************************************
% Cool skin constants  
% Includes salinity dependent thermal expansion coeff for water
%**************************************************************************

tsw=ts;ii=find(ts<Tf);tsw(ii)=Tf(ii);
Al35   = 2.1e-5*(tsw+3.2).^0.79;
Al0   =(2.2*real((tsw-1).^0.82)-5)*1e-5;
Al=Al0+(Al35-Al0).*Ss/35;
bets=7.5e-4;    % salintity expansion coeff; assumes beta independent of temperature

%**************************************************************************
%   be is beta*Salinity
%   see "Computing the seater expansion coefficients directly from the
%   1980 equation of state".  J. Lillibridge, J.Atmos.Oceanic.Tech, 1980.
%**************************************************************************
be   = bets*Ss; 
cpw  = 4000;
rhow = 1022;
visw = 1e-6;
tcw  = 0.6;
bigc = 16*grav*cpw*(rhow*visw)^3./(tcw.^2*rhoa.^2);
wetc = 0.622*Le.*Qs./(Rgas*(ts+T2K).^2);

%***********  net solar and IR radiation fluxes ***************************
% net solar aka sw aka shortwave
sw_net = 0.945.*sw_dn; % albedo correction, positive heating ocean

% lw_up = eps*sigma*Tskin^4 + (1-eps)*lw_dn
% lw_net = lw_up + lw_dn
% lw_net = eps(sigma*Tskin^4 - lw-dn)  
%     as below for lw_dn>0 heating ocean and lw_net>0 cooling ocean
%     Tskin is in Kelvin: ts-0.3*jcool+T2K... approximates a cool-skin of
%     amount 0.3 K as initial guess. This gets updated as this code progresses.

% net longwave aka IR aka infrared
% initial value here is positive for cooling ocean in the calculations
% below. However it is returned at end of program as -lw_net in final output
% so that it is positive heating ocean like the other input radiation values.
lw_net = 0.97*(5.67e-8*(ts-0.3*jcool+T2K).^4-lw_dn); 

%************  begin bulk loop ********************************************
%************  first guess ************************************************
lapse=grav/cpa;
du = u-us;          %Differences
theta=t+lapse*zt;
dT = ts-theta;
dq = Qs-Q;
ta = t+T2K;         %Compute in K
theta=theta+T2K;
tv = ta.*(1+0.61*Q);
thetav=theta.*(1+0.61*Q);

gust = 0.5;
dT_skin  = 0.3;
ut    = sqrt(du.^2+gust.^2);
u10   = ut.*log(10/1e-4)./log(zu/1e-4);
usr   = 0.035*u10;
zo10  = 0.011*usr.^2./grav + 0.11*visa./usr;
Cd10  = (von./log(10./zo10)).^2;
Ch10  = 0.00115;
Ct10  = Ch10./sqrt(Cd10);
zot10 = 10./exp(von./Ct10);
Cd    = (von./log(zu./zo10)).^2;
Ct    = von./log(zt./zot10);
CC    = von*Ct./Cd;
Ribcu = -zu./zi./.004/Beta^3;
Ribu  = -grav.*zu./ta.*((dT-dT_skin.*jcool)+.61*ta.*dq)./ut.^2;
zetu = CC.*Ribu.*(1+27/9*Ribu./CC);
k50=find(zetu>50); % stable with very thin M-O length relative to zu
k=find(Ribu<0); 
if length(Ribcu)==1
    zetu(k)=CC(k).*Ribu(k)./(1+Ribu(k)./Ribcu); clear k;
else
    zetu(k)=CC(k).*Ribu(k)./(1+Ribu(k)./Ribcu(k)); clear k;
end
stab_old=0;   %Use earlier stability functions
L10 = zu./zetu;
gf=ut./du;
if stab_old
    usr = ut.*von./(log(zu./zo10)-psiu_26(zu./L10));
    tsr = -(dT-dT_skin.*jcool).*von*fdg./(log(zt./zot10)-psit_26(zt./L10));
    qsr = -(dq-wetc.*dT_skin.*jcool)*von*fdg./(log(zq./zot10)-psit_26(zq./L10));
else
    usr = ut.*von./(log(zu./zo10)-psiu_36(zu./L10));
    tsr = -(dT-dT_skin.*jcool).*von*fdg./(log(zt./zot10)-psit_36(zt./L10));
    qsr = -(dq-wetc.*dT_skin.*jcool)*von*fdg./(log(zq./zot10)-psit_36(zq./L10));
end
tvsr=tsr.*(1+0.61.*Q) + 0.61*theta.*qsr;

dz_skin = 0.001*ones(N,1);

%**********************************************************
%  The following gives the new formulation for the
%  Charnock variable
%**********************************************************
%           COARE 3.5 wind speed dependent charnock
%**********************************************************
charnC = 0.011*ones(N,1);
umax=19;
a1=0.0017;
a2=-0.0050;
charnC=a1*u10+a2;
k=find(u10>umax);
charnC(k)=a1*umax+a2;

%**********************************************************
%  If wave age is given but not wave height, use parameterized
%  wave height
%**********************************************************
hsig=(0.02*(cp./u10).^1.1-0.0025).*u10.^2;
hsig=max(hsig,.25);
ii=find(~isnan(cp) & isnan(sigH));
sigH(ii)=hsig(ii);
    
%**********************************************************
%  Wave slope approach
%
%  Edson et al. (2013) used:
%  Ad=0.091;  %Sea-state/wave-age dependent coefficients
%  Bd=2.0;
%  zoS=sigH.*Ad.*(usr./cp).^Bd;
%  charnS=zoS.*grav./usr./usr;
%  
%  COARE 3.6 uses a wave-state/wave-age dependent coefficients 
%  from wave model
%**********************************************************
Ad=0.2;  
Bd=2.2;
zoS=sigH.*Ad.*(usr./cp).^Bd;
charnS=zoS.*grav./usr./usr;

nits=10; % number of iterations
charn=charnC;
ii=find(~isnan(cp));charn(ii)=charnS(ii);
%**************  bulk loop **************************************************

for i=1:nits
    zet=von.*grav.*zu./thetav.*tvsr./(usr.^2);
    L=zu./zet;
    zo=charn.*usr.^2./grav+0.11*visa./usr; % surface roughness
    zo(iice)=zos;
    rr=zo.*usr./visa;
    %***************************************************************************
    % This thermal roughness length Stanton number is close to COARE 3.0 value
    % Expect changes in COARE 4.0
    %***************************************************************************
    zoq=min(1.6e-4,5.8e-5./rr.^.72);       % These thermal roughness lengths give Stanton and
    zot=zoq;                               % Dalton numbers that closely approximate COARE 3.0
     
    %***************************************************************************
    %    Andreas 1987 for snow/ice
    %***************************************************************************
    ik=find(rr(iice)<=.135);
   		rt(iice(ik))=rr(iice(ik))*exp(1.250);
     	rq(iice(ik))=rr(iice(ik))*exp(1.610);
     ik=find(rr(iice)>.135 & rr(iice)<=2.5);
        rt(iice(ik))=rr(iice(ik)).*exp(0.149-.55*log(rr(iice(ik))));
     	rq(iice(ik))=rr(iice(ik)).*exp(0.351-0.628*log(rr(iice(ik))));
     ik=find(rr(iice)>2.5 & rr(iice)<=1000);
     	rt(iice(ik))=rr(iice(ik)).*exp(0.317-0.565*log(rr(iice(ik)))-0.183*log(rr(iice(ik))).*log(rr(iice(ik))));
      	rq(iice(ik))=rr(iice(ik)).*exp(0.396-0.512*log(rr(iice(ik)))-0.180*log(rr(iice(ik))).*log(rr(iice(ik))));
    
    %***************************************************************************
    %    MOS Magic
    %***************************************************************************
    if stab_old
        cdhf=von./(log(zu./zo)-psiu_26(zu./L));
        cqhf=von.*fdg./(log(zq./zoq)-psit_26(zq./L));
        cthf=von.*fdg./(log(zt./zot)-psit_26(zt./L));
    else
        cdhf=von./(log(zu./zo)-psiu_36(zu./L));
        cqhf=von.*fdg./(log(zq./zoq)-psit_36(zq./L));
        cthf=von.*fdg./(log(zt./zot)-psit_36(zt./L));
    end
    usr=ut.*cdhf;
    qsr=-(dq-wetc.*dT_skin.*jcool).*cqhf;
    tsr=-(dT-dT_skin.*jcool).*cthf;

    % Buoyancy flux from Stull (1988) page 146
    tvsr=tsr.*(1+0.61.*Q) + 0.61*theta.*qsr;
    tssr=tsr.*(1+0.51.*Q) + 0.51*theta.*qsr;
    
    Bf=-grav./thetav.*usr.*tvsr;
    gust=0.2*ones(N,1);
    k=find(Bf>0); 
%     if length(zi)==1
%         gust(k)=Beta*(Bf(k).*zi).^.333; clear k;
%     else
%         gust(k)=Beta*(Bf(k).*zi(k)).^.333; clear k;
%     end
    if length(zi)==1;
        gust(k)=max(0.2,Beta*(Bf(k).*zi).^.333); clear k;
    else
        gust(k)=max(0.2,Beta*(Bf(k).*zi(k)).^.333); clear k;
    end
    
    ut=sqrt(du.^2+gust.^2);
    gf=ut./du;
    hsb=-rhoa*cpa.*usr.*tsr;
    hlb=-rhoa.*Le.*usr.*qsr;
    qout=lw_net+hsb+hlb; %% why isn't rain heat flux included?
    
    % The absorption function below is from a Soloviev paper, appears as 
    % Eq 17 Fairall et al. 1996 and updated/tested by Wick et al. 2005. The
    % coefficient was changed from 1.37 to 0.065 ~ about halved.
    % Most of the time this adjustment makes no difference. But then there
    % are times when the wind is weak, insolation is high, and it matters a
    % lot. Using the original 1.37 coefficient resulted in many unwarranted
    % warm-skins that didn't seem realistic. See Wick et al. 2005 for details.
    % That's the last time the cool-skin routine was updated. The
    % absorption is not from Paulson & Simpson because that was derived in a lab.
    % It absorbed too much and produced too many warm layers. It likely had 
    % too much near-IR (longerwavelength solar) absorption in ocean
    % which probably doesn't make it to the ocean, was probably absorbed
    % somewhere in the atmosphere first. The below expression could 
    % likely use 2 exponentials if you had a shallow mixed layer... 
    % but we find better results with 3 exponentials. That's the best so 
    % far we've found that covers the possible depths. 
    
    dels=sw_net.*(0.065+11*dz_skin-6.6e-5./dz_skin.*(1-exp(-dz_skin/8.0e-4)));  
    qcol=qout-dels;
    alq=Al.*qcol+be.*hlb.*cpw./Le;
    xlamx=6.0*ones(N,1);
    dz_skin=min(0.01, xlamx.*visw./(sqrt(rhoa./rhow).*usr));
    k=find(alq>0);
    xlamx(k)=6./(1+(bigc(k).*alq(k)./usr(k).^4).^0.75).^0.333;
    dz_skin(k)=xlamx(k).*visw./(sqrt(rhoa(k)./rhow).*usr(k)); clear k;
    dT_skin=qcol.*dz_skin./tcw;
    dq_skin=wetc.*dT_skin;
    lw_net=0.97*(5.67e-8*(ts-dT_skin.*jcool+T2K).^4-lw_dn); % used to update dT_skin
    if i==1 % save first iteration solution for case of zetu>50;
        usr50=usr(k50);tsr50=tsr(k50);qsr50=qsr(k50);L50=L(k50);
        zet50=zet(k50);dT_skin50=dT_skin(k50);dq_skin50=dq_skin(k50);tkt50=dz_skin(k50);
    end
    
    u10N = usr./von./gf.*log(10./zo);
    charnC=a1*u10N+a2;
    k=find(u10N>umax);
    charnC(k)=a1*umax+a2;
    charn=charnC;
    
    zoS=sigH.*Ad.*(usr./cp).^Bd;%-0.11*visa./usr;
    charnS=zoS.*grav./usr./usr;
    
    %zoS=sigH.*Ad.*(usr./cp).^Bd-0.11*visa./usr;
    %charnS=zoS.*grav./usr./usr;
    
    ii=find(~isnan(cp));charn(ii)=charnS(ii);
end

% insert first iteration solution for case with zetu>50
usr(k50)=usr50;tsr(k50)=tsr50;qsr(k50)=qsr50;L(k50)=L50;
zet(k50)=zet50;dT_skin(k50)=dT_skin50;dq_skin(k50)=dq_skin50;dz_skin(k50)=tkt50;

%****************  compute fluxes  ********************************************
tau=rhoa.*usr.*usr./gf;         % wind stress
hsb=-rhoa.*cpa.*usr.*tsr;       % sensible heat flux
hlb=-rhoa.*Le.*usr.*qsr;        % latent heat flux
hbb=-rhoa.*cpa.*usr.*tvsr;      % atmospheric buoyancy flux
hsbb=-rhoa.*cpa.*usr.*tssr;     % atmospheric buoyancy flux from sonic
wbar=1.61*hlb./Le./(1+1.61*Q)./rhoa+hsb./rhoa./cpa./ta;  % mean w
hlwebb=rhoa.*wbar.*Q.*Le;       % webb correction to add to covariance hl
Evap=1000*hlb./Le./1000*3600;   % evap rate mm/hour

%*****  compute transfer coeffs relative to ut @ meas. ht  ********************
Cd= tau./rhoa./ut./max(.1,du);
Ch=-usr.*tsr./ut./(dT-dT_skin.*jcool);
Ce=-usr.*qsr./(dq-dq_skin.*jcool)./ut;

%***  compute 10-m neutral coeff relative to ut ************
Cdn_10=1000*von.^2./log(10./zo).^2;
Chn_10=1000*von.^2.*fdg./log(10./zo)./log(10./zot);
Cen_10=1000*von.^2.*fdg./log(10./zo)./log(10./zoq);

%***  compute 10-m neutral coeff relative to ut ************
%  Find the stability functions
%*********************************   User defined reference heights and 10 m
if stab_old
    psi=psiu_26(zu./L);
    psi10=psiu_26(10./L);
    psirf=psiu_26(zrf_u./L);
    psiT=psit_26(zt./L);
    psi10T=psit_26(10./L);
    psirfT=psit_26(zrf_t./L);
    psirfQ=psit_26(zrf_q./L);
else
    psi=psiu_36(zu./L);
    psi10=psiu_36(10./L);
    psirf=psiu_36(zrf_u./L);
    psiT=psit_36(zt./L);
    psi10T=psit_36(10./L);
    psirfT=psit_36(zrf_t./L);
    psirfQ=psit_36(zrf_q./L);
end
gf=ut./du;

%*********************************************************
%  Determine the wind speeds relative to ocean surface at different heights
%  Note that usr is the friction velocity that includes 
%  gustiness usr = sqrt(Cd) S, which is equation (18) in
%  Fairall et al. (1996)
%*********************************************************
S = ut;
U = du;
S10 = S + usr./von.*(log(10./zu)-psi10+psi);
U10 = S10./gf;
% or U10 = U + usr./von./gf.*(log(10/zu)-psi10+psi);
Urf = U + usr./von./gf.*(log(zrf_u./zu)-psirf+psi);
UN = U + psi.*usr/von./gf;
U10N = U10 + psi10.*usr/von./gf;
UrfN = Urf + psirf.*usr/von./gf;

UN2 = usr/von./gf.*log(zu./zo);
U10N2 = usr./von./gf.*log(10./zo);
UrfN2  = usr./von./gf.*log(zrf_u./zo);

%******** rain heat flux *****************************
dwat=2.11e-5*((t+T2K)./T2K).^1.94; % water vapour diffusivity
dtmp=(1. + 3.309e-3*t - 1.44e-6.*t.*t).*0.02411./(rhoa.*cpa); % heat diffusivity
dqs_dt=Q.*Le./(Rgas.*(t+T2K).^2); % Clausius-Clapeyron
alfac= 1./(1+0.622*(dqs_dt.*Le.*dwat)./(cpa.*dtmp)); % wet bulb factor
hrain= rain.*alfac.*cpw.*((ts-t-dT_skin.*jcool)+(Qs-Q-dq_skin.*jcool).*Le./cpa)./3600;

lapse=grav/cpa;
Tskin=ts-dT_skin.*jcool;

% P is sea level pressure, so use subtraction through hydrostatic equation to get P10
P10 = P - (rhoa.*grav/100*10);
Prf = P - (rhoa.*grav/100*zref);

T = t;
T10 = T + tsr./von.*(log(10./zt)-psi10T+psiT) + lapse.*(zt-10);
Trf = T + tsr./von.*(log(zrf_t./zt)-psirfT+psiT) + lapse.*(zt-zrf_t);
TN = T + psiT.*tsr/von;
T10N = T10 + psi10T.*tsr/von;
TrfN = Trf + psirfT.*tsr/von;

TN2 = Tskin + tsr/von.*log(zt./zot)-lapse.*zt;
T10N2 = Tskin + tsr/von.*log(10./zot)-lapse.*10;
TrfN2 = Tskin + tsr/von.*log(zrf_t./zot)-lapse.*zrf_t;

dq_skin=wetc.*dT_skin.*jcool;  %(kg/kg)
Qs=Qs-dq_skin;                 %(kg/kg)
%***********************************************************
% Report specific humidity variables in (g/kg)
%***********************************************************
dq_skin = dq_skin*1000;        %(g/kg)  
Qs=Qs*1000;                    %(g/kg)
Q=Q*1000;                      %(g/kg)
qsr=qsr*1000;                  %(g/kg)
Q10 = Q + qsr./von.*(log(10./zq)-psi10T+psiT);
Qrf = Q + qsr./von.*(log(zrf_q./zq)-psirfQ+psiT);
QN = Q + psiT.*qsr/von./sqrt(gf);
Q10N = Q10 + psi10T.*qsr/von;
QrfN = Qrf + psirfQ.*qsr/von;

QN2 = Qs + qsr/von.*log(zq./zoq);
Q10N2 = Qs + qsr/von.*log(10./zoq);
QrfN2 = Qs + qsr/von.*log(zrf_q./zoq);
RHrf=RHcalc(Trf,Prf,Qrf/1000,Tf);
RH10=RHcalc(T10,P10,Q10/1000,Tf);


% recompute rhoa10 with 10-m values of everything else.
rhoa10 = P10*100./(Rgas*(T10+T2K).*(1+0.61*(Q10/1000)));

%%%%%%%%%%%%  Other wave breaking statistics from Banner-Morison wave model
wc_frac=7.3E-4*(U10N-2).^1.43;      % wind only
wc_frac(U10<2.1)=1e-5;

kk = find(isfinite(cp) == 1);   % wind and waves if wave info is available
wc_frac(kk)=1.6e-3*U10N(kk).^1.1./sqrt(cp(kk)./U10N(kk));  

Edis=0.095*rhoa.*U10N.*usr.^2;  %  energy dissipation rate from breaking waves W/m^2
wc_frac(iice)=0;Edis(iice)=0;

%****************  output  ****************************************************
% only return values if jcool = 1; if cool skin model was intended to be run
dT_skinx=dT_skin.*jcool;
dq_skinx=dq_skin.*jcool;

% get rid of filled values where nans are present in input data
bad_input = find(isnan(u) ==1);
gust(bad_input) = nan;
dz_skin(bad_input) = nan;
zot(bad_input) = nan;
zoq(bad_input) = nan;

% flip lw_net sign for standard radiation sign convention: positive heating ocean
lw_net = -lw_net; 
% sign flip means lw_net net long wave flux is equivalent to:
% lw_net = 0.97*(lw_dn_best - 5.67e-8*(Tskin+C2K).^4);

% adjust A output as desired
A=[usr tau hsb hlb hbb hsbb hlwebb tsr qsr zo  zot zoq Cd Ch Ce  L  zet dT_skinx dq_skinx dz_skin Urf Trf Qrf RHrf UrfN lw_net sw_net Le rhoa UN U10 U10N Cdn_10 Chn_10 Cen_10 hrain Qs Evap T10 Q10 RH10 P10 rhoa10 gust wc_frac Edis];
%   1   2   3   4   5   6    7      8   9  10  11  12  13 14 15  16  17  18       19        20     21  22  23   24   25    26    27   28  29  30  31  32     33   34     35     36   37  38   39  40  41  42     43   44   45      46

end
%------------------------------------------------------------------------------
function psi=psit_26(zet)
% computes temperature structure function
dzet=min(50,0.35*zet); % stable
psi=-((1+0.6667*zet).^1.5+0.6667*(zet-14.28).*exp(-dzet)+8.525);
k=find(zet<0); % unstable
x=(1-16*zet(k)).^0.5;
psik=2*log((1+x)./2);
x=(1-34.15*zet(k)).^0.3333;
psic=1.5*log((1+x+x.^2)./3)-sqrt(3)*atan((1+2*x)./sqrt(3))+4*atan(1)./sqrt(3);
f=zet(k).^2./(1+zet(k).^2);
psi(k)=(1-f).*psik+f.*psic;
end
%------------------------------------------------------------------------------
function psi=psiu_26(zet)
% computes velocity structure function
dzet=min(50,0.35*zet); % stable
a=0.7;
b=3/4;
c=5;
d=0.35;
psi=-(a*zet+b*(zet-c/d).*exp(-dzet)+b*c/d);
k=find(zet<0); % unstable
x=(1-16*zet(k)).^0.25;
psik=2*log((1+x)/2)+log((1+x.*x)/2)-2*atan(x)+2*atan(1);
x=(1-10.15*zet(k)).^0.3333;
psic=1.5*log((1+x+x.^2)/3)-sqrt(3)*atan((1+2*x)./sqrt(3))+4*atan(1)./sqrt(3);
f=zet(k).^2./(1+zet(k).^2);
psi(k)=(1-f).*psik+f.*psic;
end
%------------------------------------------------------------------------------
function psi = psiu_36(zet)
% computes momentum flux profile function
% for unstable case, zet<0:
psi=ones(size(zet));

k=find(zet<=0);
if ~isempty(k)
    zL=zet(k);
    x = (1-16*zL).^0.25;
    psik = 2*log((1+x)/2) + log((1+x.^2)/2) - 2*atan(x) + 2*atan(1);
    x = (1-10.15*zL).^(1/3);
    psic = 1.5*log((1+x+x.^2)/3) - sqrt(3)*atan((1+2*x)/sqrt(3)) + 4*atan(1)/sqrt(3);
    f = zL.*zL./(1+zL.^2);
    psi(k) = (1-f).*psik + f.*psic;
end

% for stable case, z>0, Grachev 2007, Eq. 12:
clear k
k = find(zet>0);
if ~isempty(k)
    zL=zet(k);
    am = 5;
    bm = am/6.5;
    Bm = ((1-bm)/bm)^(1/3);
    x = (1+zL).^(1/3);
    psi(k) = -(3*am/bm)*(x-1) + ((am*Bm)/(2*bm))*(2*log((Bm+x)/(Bm+1)) - ...
        log((Bm^2-Bm*x+x.^2)/(Bm^2-Bm+1)) + 2*sqrt(3)*atan((2*x-Bm)/(Bm*sqrt(3))) - ...
        2*sqrt(3)*atan((2-Bm)/(Bm*sqrt(3))));
end
end
%------------------------------------------------------------------------------
function psi = psit_36(zet)
% computes scalar flux profile function
% for unstable case, zet<0:
psi=ones(size(zet));
k=find(zet<=0);
if ~isempty(k)
    zL=zet(k);
    x = (1-16*zL).^0.5;
    psik = 2*log((1+x)/2);
    x = (1-34.15*zL).^0.3333;
    psic = 1.5*log((1+x+x.*x)/3) - sqrt(3)*atan((1+2*x)/sqrt(3)) + 4*atan(1)/sqrt(3);
    f = zL.*zL./(1+zL.*zL);
    psi(k) = (1-f).*psik + f.*psic;
end
% for stable case, z>0, Grachev 2007, Eq. 13:
clear k;
k = find(zet>0);
if ~isempty(k)
    zL=zet(k);
    a = 5;
    b = 5;
    c = 3;
    B = sqrt(c^2 - 4);
    psi(k) = -(b/2)*log(1+c*zL+zL.^2) + ...
        (((b*c)/(2*B))-(a/B))*(log((2*zL+c-B)./(2*zL+c+B))-log((c-B)/(c+B)));
end
end
%------------------------------------------------------------------------------
function psi=psiu_40(zet)
% computes velocity structure function
dzet=min(50,0.35*zet); % stable
a=1;
b=3/4;
c=5;
d=0.35;
psi=-(a*zet+b*(zet-c/d).*exp(-dzet)+b*c/d);
k=find(zet<0); % unstable
x=(1-18*zet(k)).^0.25;
psik=2*log((1+x)/2)+log((1+x.*x)/2)-2*atan(x)+2*atan(1);
x=(1-10*zet(k)).^0.3333;
psic=1.5*log((1+x+x.^2)/3)-sqrt(3)*atan((1+2*x)./sqrt(3))+4*atan(1)./sqrt(3);
f=zet(k).^2./(1+zet(k).^2);
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
function qs=qsat26sea(T,P,Ss,Tf)
% computes surface saturation specific humidity [g/kg]
% given T [degC] and P [mb]
ex=bucksat(T,P,Tf);
fs=1-0.02*Ss/35;% reduction sea surface vapor pressure by salinity
es=fs.*ex; 
qs=622*es./(P-0.378*es);
end
%------------------------------------------------------------------------------
function [q,em]=qsat26air(T,P,rh)
% computes saturation specific humidity [g/kg]
% given T [degC] and P [mb]
Tf=0;%assumes relative humidity for pure water
es=bucksat(T,P,Tf);
em=0.01*rh.*es; % in mb, partial pressure of water vapor
q=622*em./(P-0.378*em);
end
%------------------------------------------------------------------------------
function g=grv(lat)
% computes g [m/sec^2] given lat in deg
gamma=9.7803267715;
c1=0.0052790414;
c2=0.0000232718;
c3=0.0000001262;
c4=0.0000000007;
phi=lat*pi/180;
x=sin(phi);
g=gamma*(1+c1*x.^2+c2*x.^4+c3*x.^6+c4*x.^8);
end
%------------------------------------------------------------------------------
function RHrf=RHcalc(T,P,Q,Tf)
% computes relative humidity given T,P, & Q
es=6.1121.*exp(17.502.*T./(T+240.97)).*(1.0007+3.46e-6.*P);
ii=find(T<Tf);%ice case
es(ii)=6.1115.*exp(22.452.*T(ii)./(T(ii)+272.55)).*(1.0003+4.18e-6*P(ii));
em=Q.*P./(0.378.*Q+0.622);
RHrf=100*em./es;
end