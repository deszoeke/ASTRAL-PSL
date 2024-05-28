disp('prt_flux_10');
fclose all;
clear flux10;

disp('prt_flux_hr');
fclose('all');
clear flux1hr;

fname = [cruise '_flux_10'];
ffile = fullfile(path_proc_data,[fname,'.txt']);
fmfile = fullfile(path_proc_data,[fname,'.mat']);
flist = fopen(ffile,'w');

npz = length(jdy);
nnn = 72; % number of columns of output
flux10 = NaN(nnn,npz);

reldir2 = rwdir_best;
reldir2(reldir2<0) = reldir2(reldir2<0)+360;

% define good ID data flags
filt_u = isfinite(usr_id);        % ustar sonic
filt_q = isfinite(qsr_id);    % qstar Licor
filt_t = isfinite(tsr_id);        % Tsonic star, from sonic T

flux10(1,:) = b10.jd';                   % date
flux10(2,:) = b10.sog';              % no odec, use sog
flux10(3,:) = b10.wspd';                % u true
flux10(4,:) = b10.wdir';                   % true dir
flux10(5,:) = b10.rspd';                  % u rel
flux10(6,:) = b10.rdir';               % rel dir - save in 0-360 deg format
flux10(7,:) = b10.hed';                  % ship heading
flux10(8,:) = b10.Tsnk';                  % Ts seasnake
flux10(9,:) = b10.Ta';               % T
flux10(10,:) = b10.qs';              % qs
flux10(11,:) = b10.qa';              % qa
flux10(12,:) = d10.hs_cov';                  % hs covariance
flux10(13,:) = d10.hs_id';                 % hs ID
flux10(14,:) = b10.hs';                  % hs bulk
flux10(15,:) = d10.hl_cov';              % hl covariance from licor
flux10(16,:) = d10.hl_id';             % hl ID
flux10(17,:) = b10.hl';                  % hl bulk
flux10(18,:) = -(rhoair.*wuj)';       % stress streamwise covariance
flux10(19,:) = -(rhoair.*wvj)';       %   "     xstream
flux10(20,:) = (rhoair.*usib.^2)';    % stress ID
flux10(21,:) = tau';                  % stress bulk
flux10(22,:) = rs_best';              % solar flux
flux10(23,:) = rl_best';              % IR flux
flux10(24,:) = rain_best';            % rain rate
flux10(25,:) = jplume';               % ship plume contam index
flux10(26,:) = tiltx';                % tilt angle
flux10(27,:) = jmanuv';               % maneuver index
flux10(28,:) = ct';                   % ct
flux10(29,:) = cql';                  % cq from Licor
flux10(30,:) = cu';                   % cu
flux10(31,:) = cw';                   % cw
flux10(32,:) = RF';                   % Rain heat flux
flux10(33,:) = hl_webb';              % Hl webb flux
flux10(34,:) = Lat';                  % lat
flux10(35,:) = Lon';                  % lon
flux10(36,:) = zu*ones(1,npz);        % zu
flux10(37,:) = zWXT*ones(1,npz);      % zt
flux10(38,:) = zWXT*ones(1,npz);      % zq
flux10(39,:) = sog_best';             % sog scs
flux10(40,:) = U_scs';                % u true scs
flux10(41,:) = dir_scs';              % true dir scs
flux10(42,:) = cog_best';             % cog scs
flux10(43,:) = tsg';                  % Ts scs
flux10(44,:) = ta_im';                % T scs
flux10(45,:) = qs_tsg';               % qs scs
flux10(46,:) = qa_im';                % qa scs
flux10(47,:) = rs_im';                % solar flux  IMET
flux10(48,:) = rl_im';                % IR flux IMET
flux10(49,:) = jdy'*NaN ;             % <w'c'> Licor - NOT COMPUTED
flux10(50,:) = q_lic';                % Specific Humidity from Licor (g/kg)
flux10(51,:) = sgq_lic';              % Stv of Specific Humidity from Licor (g/kg)
flux10(52,:) = co2_lic';              % CO2 concentration from Licor (umol/mol)
flux10(53,:) = sgco2_lic;             % Stv of CO2 concentration from Licor (umol/mol)
flux10(54,:) = P_best';               % sea level atmospheric pressure (mbar)
flux10(55,:) = u_best';               % Wind speed (m/s) relative to earth
flux10(56,:) = dir';                  % Wind direction (deg) from relative to earth
flux10(57,:) = rlclr';                % Longwave downwelling clear sky model (W/m2)
flux10(58,:) = rsclr';                % Shortwave solar radiance clear sky model (W/m2)
flux10(59,:) = U10N';                 % 10m neutral windspeed, COARE 3.5
flux10(60,:) = T10N';                 % 10m neutral temperature, COARE 3.5
flux10(61,:) = Q10N';                 % 10m neutral specific humidity, COARE 3.5
flux10(62,:) = rh_im';                % scs RH
flux10(63,:) = P_im';                 % scs Pmb (sea level)
flux10(64,:) = RH_wxt';               % PSD WXT RH, %
flux10(65,:) = filt_u';               % usib good data flag
flux10(66,:) = filt_q';               % qsib_lic good data flag
flux10(67,:) = filt_t';               % tsib good data flag
flux10(68,:) = NaN(size(jdy'));       % wspd w/respect to earth
flux10(69,:) = NaN(size(jdy'));       % wdir w/respect to earth
flux10(70,:) = hsc_sds';              % hsc, Simon's version
flux10(71,:) = hlc_sds';              % hlc, Simon's version
flux10(72,:) = rosr';                 % ROSR radiometric SST, C

% vectorized print, 72 columns
% prepare format string for numeric data
fmtStr = '';
fmtStr = strcat('\r\n', fmtStr);
for i = 1:nnn
    fmtStr = strcat('%20.10e ', fmtStr);
end
fprintf(flist,fmtStr,flux10);
fclose('all');
disp(['File written as ' f]);

% save copy in .mat format
flux1hr = flux1hr';
save(fmfile,'flux10');
