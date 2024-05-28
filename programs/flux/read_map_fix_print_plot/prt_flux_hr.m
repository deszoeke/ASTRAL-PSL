% saves txt and mat versions of hourly flux, met, sea, nav data

disp('prt_flux_hr');
fclose('all');
clear flux1hr;

fname = [cruise '_flux_hr'];
ffile = fullfile(path_proc_data,[fname,'.txt']);
fmfile = fullfile(path_proc_data,[fname,'.mat']);
flist = fopen(ffile,'w');

npz = length(jda);
nnn = 71; % number of columns of output
flux1hr = NaN(nnn,npz);

% changes rdir back to 0-360... not my preference
% yrwdir2 = yrwdir;
% yrwdir2(yrwdir2<0) = yrwdir2(yrwdir2<0)+360;

npz = length(jda);
flux1hr(1,1:npz) = jda';            % date
flux1hr(2,1:npz) = yspd_log;        % odec / ship speed log
flux1hr(3,1:npz) = ywspd;           % true wind spd
flux1hr(4,1:npz) = ywdir;           % true wind dir
flux1hr(5,1:npz) = NaN(size(jda')); % u rel
flux1hr(6,1:npz) = yrdir;           % rel dir - save in 0-360 deg format
flux1hr(7,1:npz) = yhed;            % ship heading
flux1hr(8,1:npz) = y1(:,20)';       % SST seasnake (Tskin or Tsnk?)
flux1hr(9,1:npz) = y4(:,5)';        % Ta best
flux1hr(10,1:npz) = y4(:,4)';       % qs best
flux1hr(11,1:npz) = y4(:,7)';       % qa best
flux1hr(12,1:npz) = yhs_cov;        % hs covariance
flux1hr(13,1:npz) = yhs_id;         % hs ID
flux1hr(14,1:npz) = yhs_b;          % hs bulk
flux1hr(15,1:npz) = yhl_cov;        % hl blend of cov results
flux1hr(16,1:npz) = yhl_id;         % hl ID
flux1hr(17,1:npz) = yhl_b;          % hl bulk
flux1hr(18,1:npz) = ytau_cov;       % stress stream-wise covariance
flux1hr(19,1:npz) = ytau_cov_cross; % stress cross-stream covariance %% used to say ytaucx but that was a type
flux1hr(20,1:npz) = ytau_id;        % stress ID
flux1hr(21,1:npz) = ytau_b;         % stress bulk
flux1hr(22,1:npz) = y4(:,8)';       % rs best
flux1hr(23,1:npz) = y4(:,9)';       % rl best
flux1hr(24,1:npz) = y4(:,11)';      % ORG rain rate
flux1hr(25,1:npz) = yj;             % ship plume contam index
flux1hr(26,1:npz) = y1(:,44)';      % tilt of good data
flux1hr(27,1:npz) = yjm;            % ship maneuver index

switch IDflag
    case 'a'
        flux1hr(28,1:npz) = y1(:,138)';    % ct
        flux1hr(29,1:npz) = y1(:,140)';    % cq
        flux1hr(30,1:npz) = y1(:,134)';    % cu
        flux1hr(31,1:npz) = y1(:,136)';    % cw
    case 'b'
        flux1hr(28,1:npz) = y1(:,139)';    % ct
        flux1hr(29,1:npz) = y1(:,141)';    % cq
        flux1hr(30,1:npz) = y1(:,135)';    % cu
        flux1hr(31,1:npz) = y1(:,137)';    % cw
    case 'ab' % mean of a and b
        flux1hr(28,1:npz) = nanmean1(y1(:,138:139),2)';    % ct
        flux1hr(29,1:npz) = nanmean1(y1(:,140:141),2)';    % cq
        flux1hr(30,1:npz) = nanmean1(y1(:,134:135),2)';    % cu
        flux1hr(31,1:npz) = nanmean1(y1(:,136:137),2)';    % cw
    otherwise % method a by default
        flux1hr(28,1:npz) = y1(:,138)';    % ct
        flux1hr(29,1:npz) = y1(:,140)';    % cq
        flux1hr(30,1:npz) = y1(:,134)';    % cu
        flux1hr(31,1:npz) = y1(:,136)';    % cw
end

flux1hr(32,1:npz) = yhrain;         % Rain heat flux
flux1hr(33,1:npz) = yhlwebb';       % Hl webb flux
flux1hr(34,1:npz) = y1(:,151)';     % lat
flux1hr(35,1:npz) = y1(:,150)';     % lon
flux1hr(36,1:npz) = y1(:,27)';      % zu
flux1hr(37,1:npz) = y1(:,28)';      % zt
flux1hr(38,1:npz) = y1(:,29)';      % zq
flux1hr(39,1:npz) = ysog;           % sog ship
flux1hr(40,1:npz) = ywspd_s;        % wind true spd ship
flux1hr(41,1:npz) = ywdir_s;        % wind true dir ship
flux1hr(42,1:npz) = ycog;           % ship course ship
flux1hr(43,1:npz) = y1(:,6)';       % Ts ship, raw ship measurement (?)
flux1hr(44,1:npz) = y1(:,3)';       % T ship (?)
flux1hr(45,1:npz) = y4(:,4)';       % qs ship
flux1hr(46,1:npz) = y4(:,7)';       % qa ship
flux1hr(47,1:npz) = y1(:,7)';       % rs ship
flux1hr(48,1:npz) = y1(:,8)';       % rl ship
flux1hr(49,1:npz) = jda'*NaN;       % w'c' licor - NOT COMPUTED
flux1hr(50,1:npz) = y3(:,2)';       % Specific Humidity from Licor (g/kg)
flux1hr(51,1:npz) = y3(:,12)';      % std of Specific Humidity from Licor (g/kg)
flux1hr(52,1:npz) = jda'*NaN;       % CO2 concentration from Licor (umol/mol)
flux1hr(53,1:npz) = jda'*NaN;       % std of CO2 concentration from Licor (umol/mol)
flux1hr(54,1:npz) = y4(:,10)';      % atmospheric pressure best (mbar), sea level
flux1hr(55,1:npz) = NaN(size(jda'));% Wind speed (m/s) relative to earth - NOT COMPUTED (?)
flux1hr(56,1:npz) = NaN(size(jda'));% Wind direction (deg) from relative to earth - NOT COMPUTED (?)
flux1hr(57,1:npz) = yrnl';          % net longwave heat flux
flux1hr(58,1:npz) = yhnet';         % net heat flux, bulk, W/m2 hourly
flux1hr(59,1:npz) = yhnet_cov';     % net heat flux, turb, W/m2 hourly
flux1hr(60,1:npz) = y1(:,4)';       % ship RH
flux1hr(61,1:npz) = y1(:,5)';       % ship Pmb, sea level
flux1hr(62,1:npz) = ywspd_wxt';     % wspd WXT
flux1hr(63,1:npz) = ywdir_wxt';     % wdir WXT
flux1hr(64:67,1:npz) = y1(:,168:171)'; % Ta, RH, Pmb, rain, WXT
flux1hr(68,1:npz) = ywt_sds';       % Simon's w't' cov
flux1hr(69,1:npz) = ywq_sds';       % Simon's w'q' cov
flux1hr(70,1:npz) = yhs_cov_sds';   % Simon's sensible heat flux cov
flux1hr(71,1:npz) = yhl_cov_sds';   % Simon's latent heat flux cov

% vectorized print, 67 columns
% prepare format string for numeric data
fmtStr = '';
fmtStr = strcat('\r\n', fmtStr);
for i = 1:nnn
    fmtStr = strcat('%12.6f ', fmtStr);
end
fprintf(flist,fmtStr,flux1hr);
fclose('all');
disp(['File written as ' ffile]);

% save copy in .mat format
flux1hr = flux1hr';
save(fmfile,'flux1hr');

