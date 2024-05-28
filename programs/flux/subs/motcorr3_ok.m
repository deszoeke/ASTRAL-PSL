function [uvw,Ts,accplat,uvwplat,xyzplat,euler,plat_rate,lagPnts,mu,uvw_raw,uvw_motcorr,f1,f2] = ...
    motcorr3_ok(son,mot,heading,sens_disp,fsam,decorr)
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
[euler,~] = angles(ahi,bhi,fsam,plat_acc,plat_rate,heading);

% platform velocities, displacements and accelerations
[uvwplat,xyzplat,accplat] = accels2(bhi,ahi,fsam,plat_acc,euler);

% rotate uvw into earth frame
R = [sens_disp(1); sens_disp(2); sens_disp(3)] * ones(1,length(son_vel));
uvw = neaqs_trans(son_vel+cross(plat_rate,R),euler,0);
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
    X = [ones(length(uvw),1),accplat(1,:)',uvwplat(1,:)'];   % U
%         X = [ones(length(Ts),1),accplat(1:2,:)',uvwplat(1:2,:)'];             
    [u_decorr,mu_u] = interval_decorr(son(:,1),uvw(1,:)',jd_bins,X);
    X = [ones(length(uvw),1),accplat(2,:)',uvwplat(2,:)'];   % V
%         X = [ones(length(Ts),1),accplat(1:2,:)',uvwplat(1:2,:)'];             
    [v_decorr,mu_v] = interval_decorr(son(:,1),uvw(2,:)',jd_bins,X);
    X = [ones(length(uvw),1),accplat(3,:)',uvwplat(3,:)'];   % W
%         X = [ones(length(Ts),1),accplat',uvwplat'];             
    [w_decorr,mu_w] = interval_decorr(son(:,1),uvw(3,:)',jd_bins,X);
    
    X = [ones(length(Ts),1),accplat',uvwplat'];              % Tsonic
    [Ts_decorr,mu_Ts] = interval_decorr(son(:,1),Ts',jd_bins,X);
%     uvw = [uvw(1:2,:);w_decorr'];
%     uvw = [uvw(1,:);v_decorr';w_decorr'];
    uvw = [u_decorr';v_decorr';w_decorr'];
%    uvw = [u_decorr';uvw(2,:);w_decorr'];

    Ts = Ts_decorr';
    mu = [jd_bins(1:end-1),mu_w,mu_Ts]; % concat all mu coefs
else
    mu = [jd_bins(1:end-1),NaN(6,17)];
end

N = floor(length(son)/2);
dd = sprintf('%02i',floor(son(1,1)));
hh = sprintf('%02i',round((son(1,1)-floor(son(1,1)))*24));

f1 = figure('position',[200,400,600,1000]);
subplot(3,1,1); hold on;
plot(son(N-150:N+150,1),uvwplat(1,N-150:N+150),'r',son(N-150:N+150,1),uvw_raw(1,N-150:N+150),'b');
plot(son(N-150:N+150,1),uvw_motcorr(1,N-150:N+150),'g','linewidth',3); 
plot(son(N-150:N+150,1),uvw(1,N-150:N+150),'k'); grid;
ylabel('U velocity'); title([dd,' ',hh,' Winds (Earth Frame): Raw, Motcorr, Decorr']);
xlim([son(N-150,1),son(N+150,1)]);
legend('platform','raw','motcorr','decorr','location','best','orientation','horizontal');

subplot(3,1,2); hold on;
plot(son(N-150:N+150,1),uvwplat(2,N-150:N+150),'r',son(N-150:N+150,1),uvw_raw(2,N-150:N+150),'b');
plot(son(N-150:N+150,1),uvw_motcorr(2,N-150:N+150),'g','linewidth',3); 
plot(son(N-150:N+150,1),uvw(2,N-150:N+150),'k'); grid;
ylabel('V velocity'); xlim([son(N-150,1),son(N+150,1)]);

subplot(3,1,3); hold on;
plot(son(N-150:N+150,1),uvwplat(3,N-150:N+150),'r',son(N-150:N+150,1),uvw_raw(3,N-150:N+150),'b');
plot(son(N-150:N+150,1),uvw_motcorr(3,N-150:N+150),'g','linewidth',3); 
plot(son(N-150:N+150,1),uvw(3,N-150:N+150),'k');
plot([son(N-150,1),son(N+150,1)],[0,0],'k'); grid;
xlabel('Decimal DOY'); ylabel('W velocity'); xlim([son(N-150,1),son(N+150,1)]);


f2 = figure('position',[200,400,600,1000]);
subplot(3,1,1); plot(son(:,1),uvw_raw(1,:),'bo',son(:,1),uvw(1,:),'r.'); grid;
ylabel('U velocity'); title([dd,' ',hh,' Winds (Earth Frame): Raw, Motcorr, Decorr']);
xlim([son(1,1),son(1,1)+1/24]); legend('raw','decorr','location','northwest');

subplot(3,1,2); plot(son(:,1),uvw_raw(2,:),'bo',son(:,1),uvw(2,:),'r.'); grid;
ylabel('V velocity'); xlim([son(1,1),son(1,1)+1/24]);

subplot(3,1,3); plot(son(:,1),uvw_raw(3,:),'bo',son(:,1),uvw(3,:),'r.'); hold on;
plot([son(1,1),son(36000,1)],[0,0],'k'); grid;
xlabel('Decimal DOY'); ylabel('W velocity'); xlim([son(1,1),son(1,1)+1/24]);

end



