function [uvw,Ts,accplat,uvwplat,xyzplat,euler,plat_rate,lagPnts,mu,uvw_raw,uvw_motcorr,f1,f2] = ...
    motcorr3(son,mot,heading,sens_disp,fsam,decorr)
%{
motcorr2.m - computes motion-corrected wind from raw sonic and motionPak
data files.  Edson-98 method.

motcorr3.m - decorrelation uses multiple regression approach over 10-min segments

Required inputs are arrays son (36000x5), mot(36000x7), heading (36000x1) and
sens_disp (1x3).  Additional input is sampling rate, typically 10Hz
and decorr (boolean).

Outputs are 36000x3 arrays uvw (winds), accplat (platform accelerations),
uvwplat(platform velocities), xyzplat (platform displacements), lagPnts
and mu, a 6x33 array of before/after corr coefs from the decorrelation.

Requires functions angles.m, accels.m Filtcoef.m interval_decorr.m and neaqs_trans.m
    
EJT 01/2020 - modifications made to make program flexible for bad/dropped
heading data. When hed...raw data file has missing data, this program will
now still run (failling at filtfilt.m) and then adjust the lengths of all
arrays accordingly to pass successfully back to run_motcorr.m
%}

% define 10 Hz variables - transpose to row vectors to match legacy code
son_vel = son(:,2:4)';    % sonic wind velocities
plat_acc = mot(:,2:4)';   % platform accelerations, m/s
plat_rate = mot(:,5:7)';  % platform rotational rates, rad/s
Ts = son(:,5)';

% unwrapped slow rotation about z axis
heading = unwrap(heading)';

% filter coefficients
[bhi,ahi,~,~,~,~] = Filtcoef(fsam,1/30);

% euler angles
%%% plat_acc and plat_rate = [3, 36000]... heading = [1, 36000]
wh_heading_valid = find(isfinite(heading) == 1);
[euler_valid,~] = angles(ahi,bhi,fsam,plat_acc(:,wh_heading_valid),plat_rate(:,wh_heading_valid),heading(wh_heading_valid));
euler = nan(3,36000);
euler(:,wh_heading_valid) = euler_valid(:,:);

% platform velocities, displacements and accelerations
[uvwplat_valid,xyzplat_valid,accplat_valid] = accels2(bhi,ahi,fsam,plat_acc(:,wh_heading_valid),euler_valid);
uvwplat = nan(3,36000);
xyzplat = nan(3,36000);
accplat = nan(3,36000);
uvwplat(:,wh_heading_valid) = accplat_valid;
xyzplat(:,wh_heading_valid) = accplat_valid;
accplat(:,wh_heading_valid) = accplat_valid;

% rotate uvw into earth frame
R = [sens_disp(1); sens_disp(2); sens_disp(3)] * ones(1,lengt(son_vel));
R_valid = R(:,wh_heading_valid);
uvw_valid = neaqs_trans(son_vel(:,wh_heading_valid)+cross(plat_rate(:,wh_heading_valid),R_valid),euler_valid,0);
uvw = nan(3,36000);
uvw(:,wh_heading_valid) = uvw_valid;
%%% save this version of uvw as uvw_raw, since uvw gets worked on later and
%%% saved as different versions: uvw_motcorr
uvw_raw = uvw;

% compute lag between W and platform vertical velocity
% shift uvw accordingly and sum with uvwplat to correct winds
% uvw are then in earth coordinates, corrected for platform pitch/roll/yaw
lagPnts = lagcorrection(uvw(3,:),uvwplat(3,:),16);
if lagPnts > 0
    uvw(1,1:length(uvw(3,:))-lagPnts) = uvw(1,1:length(uvw(3,:))-lagPnts) + uvwplat(1,lagPnts+1:length(uvw(3,:)));
    uvw(2,1:length(uvw(3,:))-lagPnts) = uvw(2,1:length(uvw(3,:))-lagPnts) + uvwplat(2,lagPnts+1:length(uvw(3,:)));
    uvw(3,1:length(uvw(3,:))-lagPnts) = uvw(3,1:length(uvw(3,:))-lagPnts) + uvwplat(3,lagPnts+1:length(uvw(3,:)));
else
    uvw(1,-lagPnts+1:length(uvw(3,:))) = uvw(1,-lagPnts +1:length(uvw(3,:))) + uvwplat(1,1:length(uvw(3,:))+lagPnts);
    uvw(2,-lagPnts+1:length(uvw(3,:))) = uvw(2,-lagPnts +1:length(uvw(3,:))) + uvwplat(2,1:length(uvw(3,:))+lagPnts);
    uvw(3,-lagPnts+1:length(uvw(3,:))) = uvw(3,-lagPnts +1:length(uvw(3,:))) + uvwplat(3,1:length(uvw(3,:))+lagPnts);
end
uvw_motcorr = uvw;

jd_bins = son(1,1):10/1440:son(1,1)+60/1440; jd_bins = jd_bins';
if decorr
    % Decorrelate wind-motion and Ts-motion.  Decorrelate in 10-min
    % segments with multiple regression
    X = [ones(length(uvw),1),accplat(3,:)',uvwplat(3,:)'];   % W
    [w_decorr,mu_w] = interval_decorr(son(:,1),uvw(3,:)',jd_bins,X);
    X = [ones(length(Ts),1),accplat',uvwplat'];              % Tsonic
    [Ts_decorr,mu_Ts] = interval_decorr(son(:,1),Ts',jd_bins,X);
    uvw = [uvw(1:2,:);w_decorr'];
    Ts = Ts_decorr';
    mu = [jd_bins(1:end-1),mu_w,mu_Ts]; % concat all mu coefs
else
    mu = [jd_bins(1:end-1),NaN(6,17)];
end

N = floor(length(son)/2);
dd = sprintf('%02i',floor(son(1,1)));
hh = sprintf('%02i',round((son(1,1)-floor(son(1,1)))*24));

f1 = figure('position',[200,400,600,1000]);
subplot(3,1,1); plot(son(N-150:N+150,1),uvwplat(1,N-150:N+150),'r',son(N-150:N+150,1),uvw_raw(1,N-150:N+150),'b');
hold on; plot(son(N-150:N+150,1),uvw_motcorr(1,N-150:N+150),'g',son(N-150:N+150,1),uvw(1,N-150:N+150),'k'); grid;
ylabel('U velocity'); title([dd,' ',hh,' Winds (Earth Frame): Raw, Motcorr, Decorr']);
xlim([son(N-150,1),son(N+150,1)]);
legend('platform','raw','motcorr','decorr','location','northwest');

subplot(3,1,2); plot(son(N-150:N+150,1),uvwplat(2,N-150:N+150),'r',son(N-150:N+150,1),uvw_raw(2,N-150:N+150),'b');
hold on; plot(son(N-150:N+150,1),uvw_motcorr(2,N-150:N+150),'g',son(N-150:N+150,1),uvw(2,N-150:N+150),'k'); grid;
ylabel('V velocity'); xlim([son(N-150,1),son(N+150,1)]);

subplot(3,1,3); plot(son(N-150:N+150,1),uvwplat(3,N-150:N+150),'r',son(N-150:N+150,1),uvw_raw(3,N-150:N+150),'b');
hold on; plot(son(N-150:N+150,1),uvw_motcorr(3,N-150:N+150),'g',son(N-150:N+150,1),uvw(3,N-150:N+150),'k');
plot([son(N-150,1),son(N+150,1)],[0,0],'k'); grid;
xlabel('Decimal DOY'); ylabel('W velocity'); xlim([son(N-150,1),son(N+150,1)]);


f2 = figure('position',[200,400,600,1000]);
subplot(3,1,1); plot(son(:,1),uvw_raw(1,:),'b',son(:,1),uvw(1,:),'r'); grid;
ylabel('U velocity'); title([dd,' ',hh,' Winds (Earth Frame): Raw, Motcorr, Decorr']);
xlim([son(1,1),son(1,1)+1/24]); legend('raw','decorr','location','northwest');

subplot(3,1,2); plot(son(:,1),uvw_raw(2,:),'b',son(:,1),uvw(2,:),'r'); grid;
ylabel('V velocity'); xlim([son(1,1),son(1,1)+1/24]);

subplot(3,1,3); plot(son(:,1),uvw_raw(3,:),'b',son(:,1),uvw(3,:),'r'); hold on;
plot([son(1,1),son(36000,1)],[0,0],'k'); grid;
xlabel('Decimal DOY'); ylabel('W velocity'); xlim([son(1,1),son(1,1)+1/24]);

end



