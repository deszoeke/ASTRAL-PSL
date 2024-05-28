disp('prt_flux_10');
fclose all;
clear f;

fname = [cruise '_flux_10min'];

%%% change to 1 to save direct flux output
save_direct_flux = 0;

% nnn = 72; % number of columns of output
% f = NaN(nnn,npz);

% save in +/-180 or 0-360
reldir2 = rwdir_best;
reldir2(reldir2<0) = reldir2(reldir2<0)+360;

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% cstart = datenum(2019,9,5,0,0,0);  %%% when snake went in and we were out of EEZ 
% %%% snake went in 6th at 5 z, but we started soundings at 00 z on 5th. 
% % cend = datenum(2019,9,25,0,0,0);  %%% when snake came out and we were in EEZ
% bad_times   = find(t < cstart);  % | t > cend);
% good_times  = find(t >= cstart); % & t <= cend);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ff.t            = t;                             % matlab time of 10 min
ff.yday         = t - datenum(2019,0,0,0,0,0);   % julian decimal date, recalculated
ff.Lat          = Lat;                           % lat
ff.Lon          = Lon;                           % lon

ff.sog          = sog_best;                      % no odec, use sog... is this from ship or psd or both?
ff.cog          = cog_best;                      % cog ship
ff.head         = head;                          % ship heading... what is diff between cog and head?

% wind
ff.wspd_15m     = u_best;                % u true at 15 m
ff.wdir_15m     = dir;                   % true dir at 15 m
ff.wspdrel_15m  = urel;                  % u rel to ship at 15 m
ff.wdirrel_15m  = reldir2;               % rel dir to ship- save in 0-360 deg format at 15 m
ff.U10N         = U10N;                  % 10m neutral windspeed, COARE 3.5

% sea level
ff.Psl          = P_best;               % sea level atmospheric pressure (mbar)
% ff.skinT        = skinT;                % skin T from ROSR
ff.SST          = SST;                  % sea snake - cool skin
ff.qs           = qs_sst;               % qs from SST
ff.Tsnake       = tsnk;                 % from sea snake at 0.05 m
ff.dT           = SST - T10N;           % sea - air temp difference
ff.dq           = qs_sst - Q10N;        % sea - air humidity difference

% adjusted to 10 m
%%% coare output
ff.T10N         = T10N;                 % 10m neutral temperature, COARE 3.5
ff.q10N         = Q10N;                 % 10m neutral specific humidity, COARE 3.5
ff.RH10N        = RH10; 
ff.rhoa         = rhoair;                 % output from coare

% % psd met... what level are these at??
% f(9,:) = ta_best;               % T air
% f(11,:) = qa_best;              % qa

% sea surface
ff.skin_dT      = dter;                  % cool skin T amount
ff.skin_dz      = tkt;                   % thickness of cool skin

% %%% ocean warm layer calculated when coare is set up to do so
% dtw     =    c35(:,43);      % warm layer T diff
% zw      =    c35(:,44);      % warm layer thickness

% buoyancy flux into atm
% ff.hb       = hbb;        % w / m2

% sensible heat flux
ff.hs       = -1* hsb;                  % hs bulk

% latent heat flux
ff.hl       = -1* hlb;                  % hl bulk
ff.E     = Evap; % evap rate in mm/hr

% momentum flux
ff.ustar            = usr ;  % ustar in air
ff.tau              = tau;                  % stress bulk
% ff.tau_streamwise   = -(rhoair.*wuj);       % stress streamwise covariance
% ff.tau_crossstream  = -(rhoair.*wvj);       %   "     xstream

% IRup_rosr = epsilon *sigma * ((Trosr+273.15).^4) + (1-epsilon)*IRdn;
IRup_SST           = -1*( epsilon *sigma * ((SST+273.15).^4) + (1-epsilon)*rl_best);
Solarnet           = 0.955.*rs_best; ... or 0.945?
    
% radiative fluxes... net are positive heating the ocean, negative cooling the ocean
ff.IRdn             = rl_best;               % IR flux (downwelling... positive into ocean)
ff.IRup             = IRup_SST;              % from COARE
ff.IRnet            = rl_best + IRup_SST;    % net longwave
ff.Solardn          = rs_best;               % solar flux (downwelling)
ff.Solarup          = Solarnet-rs_best;
ff.Solarnet         = Solarnet;

ff.IRdn_clear       = rlclr;                % Longwave downwelling clear sky model (W/m2)
ff.Solardn_clear    = rsclr;                % Shortwave solar radiance clear sky model (W/m2)

% rain 
ff.P                = rain_best;            % rain rate
ff.hr               = -1*RF;                   % Rain heat flux

% net heat flux
ff.hnet             = hnet;         % = 0.955*rs_best - rnl - hsb - hlb - RF;                 % net heat from coare

% % ???
% f(25,:) = jplume;               % ship plume contam index
% f(26,:) = tiltx;                % tilt angle
% f(27,:) = jmanuv;               % maneuver index
% f(28,:) = ct;                   % ct
% f(29,:) = cql;                  % cq from Licor
% f(30,:) = cu;                   % cu
% f(31,:) = cw;                   % cw

% heights of instruments? 
% f(36,:) = zu*ones(1,npz);        % zu
% f(37,:) = zWXT*ones(1,npz);      % zt
% f(38,:) = zWXT*ones(1,npz);      % zq

% %%% ship met
% f(39,:) = U_scs;                % true wind speed ship
% f(49,:) = dir_scs;              % true wind dir ship
% % f(41,:) = sog_best;             % sog ship .  % why provide 2? are
% % they different?
% f(44,:) = ta_im;                % Ta ship
% f(46,:) = qa_im;                % qa ship
% f(62,:) = rh_im;                % RH, ship
% f(63,:) = P_im;                 % Pmb (sea level), ship
% f(47,:) = rs_im;                % solar flux downwelling ship
% f(48,:) = rl_im;                % IR flux downwelling ship
% f() = pr_scs;

% %%% ship seawater
% ff.Ttsg = Ttsg_best;                % Ts ship from seachest ship
% ff.Stsg = Stsg_best;                % S ship from seachest ship
% ff.Ftsg = Ftsg_best;                % F ship from seachest... not reporting?
% ff.Ctsg = Ctsg_best;                % C ship from seachest ship
% ff.Sigtsg = sigtsg_best;            % sigmaT ship from seachest ship
% ff.ID_Ftsg = ID_Ftsg_best;            % ID for good or bad TSG data;
% 
% ff.IDtsg = tsg_ID;               % 1 = use bow, 2 = use sea chest ship, 0 = don't use
% ff.switch_tsg_1 = tsgswitchtime1;  % time we turned off bow tsg pump
% ff.switch_tsg_2 = tsgswitchtime2;  % time we turned on seachest tsg pump

%==========================================================================
%%% direct flux stuff
if save_direct_flux == 1

    %%% atm boundary layer
    ff.Cd       = Cd      ;      % drag @ zu
    ff.Ch       = Ch      ;      % Stanton
    ff.Ce       = Ce      ;      % Dalton
    ff.Cdn_10   = Cdn_10  ;      % neutral drag @ 10m [includes gustiness]
    ff.Chn_10   = Chn_10  ;      % ''
    ff.Cen_10   = Cen_10  ;      % ''

    ff.zet      = zet     ;      % z/L
    ff.zo       = zo      ;      % vel roughness length
    ff.zot      = zot     ;      % temp "
    ff.zo1      = zoq     ;      % hum  "
    ff.L        = L       ;      % Obukhov Length, m

    ff.skin_dq      = dqer;                  % cool skin q amount

    
        % define good ID data flags
    filt_u = isfinite(usib);        % sonic (?) wind
    filt_q = isfinite(qsib_lic);    % Licor
    filt_t = isfinite(tsib);        % sonic T

    ff.tau_ID = (rhoair.*usib.^2);    % stress ID

    ff.hsc = hsc;                  % hs covariance
    ff.hsib = hsib;                 % hs ID
    ff.hlc_lic = hlc_lic;              % hl covariance from licor
    ff.hlib.lic = hlib_lic;             % hl ID

    % data flags for sonic and licor
    ff.filt_u = filt_u;               % usib good data flag (sonic wind)
    ff.filt_q = filt_q;               % qsib_lic good data flag (licor humidity)
    ff.filt_t = filt_t;               % tsib good data flag (sonic T)

    %%% licor stuff
    ff.q_lic = q_lic;                % Specific Humidity from Licor (g/kg)
    ff.sgq_lic = sgq_lic;              % Stv of Specific Humidity from Licor (g/kg)
    ff.hl_webb = hl_webb;              % Hl webb flux

    ff.hnet_c = hnet_c; % = 0.955*rs_best- rnl- hsc- hlc_lic - hl_webb - RF;    % net heat using cov fluxes hsc & hlc
    ff.hnet_id = hnet_id; % = 0.955*rs_best- rnl- hsib- hlib_lic- hl_webb- RF;   % net heat using id fluxes hsib & hlib_lic
end
% f(49,:) = jdy'*NaN;              % <w'c'> Licor - NOT MEASURED
% f(52,:) = jdy'*NaN;              % CO2 concentration from Licor (umol/mol) - NOT MEASURED
% f(53,:) = jdy'*NaN;              % Stv of CO2 concentration from Licor (umol/mol) - NOT MEASURED

%%% WXT data... why provide them if we don't trust them?
% f(64,:) = RH_wxt;               % PSD WXT RH, %


% ?? These are simons... unsupported? supported? make sure I understand
% them before I provide them. 
% f(70,:) = hsc_sds;              % hsc, Simon's version
% f(71,:) = hlc_sds;              % hlc, Simon's version
% f(72,:) = rosr;                 % ROSR radiometric SST, C

% vectorized print, 72 columns
% prepare format string for numeric data
% fmtStr = '';
% fmtStr = strcat('\r\n', fmtStr);
% for i = 1:nnn
%     fmtStr = strcat('%20.10e ', fmtStr);
% end
% fprintf(flist,fmtStr,f);
% fclose('all');
% disp(['File written as ' f]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% trim off bad data at beginning of cruise before EEZ. Use this also to
%%% do the same at end of cruise.
fs = fields(ff);
%%% load all variables
for j = 1:length(fs)
%     if j < length(fs)
    %%% grab portion of data within the good time range
%         f.(fs{j}) = ff.(fs{j})(good_times);
    %%% grab all data
        f.(fs{j}) = ff.(fs{j});
%     else
%         f.(fs{j}) = ff.(fs{j});
%     end
end

% save copy in .mat format
dfl = fullfile(da_path,[fname,'.mat']);
save(dfl, 'f');

% save copy in .txt format
k = mat2txt(fname, 'n', [da_path '/' ], f);

