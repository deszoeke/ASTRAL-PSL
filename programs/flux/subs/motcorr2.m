function [uvw,Ts,uvwplat,xyzplat,euler,lagPnts] = motcorr2(son,mot,heading,sens_disp,fsam,decorr)
%{
motcorr2.m - computes motion-corrected wind from raw sonic and motionPak
data files.  Edson-98 method.

% THIS VERSION IMPLEMENTS TSONIC DECORRELATION WITH ALL 3 MOTION AXES

Required inputs are arrays son (Nx4), mot(Nx7), heading (Nx1) and
sens_disp (3x1).  Additional input is sampling rate, typically 10Hz
and decorr (boolean).

Outputs are Nx3 arrays uvw (winds), uvwplat(platform velocities) and
xyzplat (platform displacements) and lagPnts.

Requires functions angles.m, accels.m Filtcoef.m and neaqs_trans.m
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

% platform velocities
[uvwplat,xyzplat] = accels(bhi,ahi,fsam,plat_acc,euler);

% rotate uvw into earth frame
R = [sens_disp(1); sens_disp(2); sens_disp(3)] * ones(1,length(son_vel));
uvw = neaqs_trans(son_vel+cross(plat_rate,R),euler,0);
w_raw = uvw(3,:);

% compute lag between W and platform vertical velocity
% shift uvw accordingly and sum with uvwplat to correct winds
% uvw are then in earth coordinates, corrected for platform pitch/roll/yaw
lagPnts = lagcorrection(uvw(3,:),uvwplat(3,:),16);
if lagPnts > 0,
    uvw(1,1:length(uvw(3,:))-lagPnts) = uvw(1,1:length(uvw(3,:))-lagPnts) + uvwplat(1,lagPnts+1:length(uvw(3,:)));
    uvw(2,1:length(uvw(3,:))-lagPnts) = uvw(2,1:length(uvw(3,:))-lagPnts) + uvwplat(2,lagPnts+1:length(uvw(3,:)));
    uvw(3,1:length(uvw(3,:))-lagPnts) = uvw(3,1:length(uvw(3,:))-lagPnts) + uvwplat(3,lagPnts+1:length(uvw(3,:)));
else
    uvw(1,-lagPnts+1:length(uvw(3,:))) = uvw(1,-lagPnts +1:length(uvw(3,:))) + uvwplat(1,1:length(uvw(3,:))+lagPnts);
    uvw(2,-lagPnts+1:length(uvw(3,:))) = uvw(2,-lagPnts +1:length(uvw(3,:))) + uvwplat(2,1:length(uvw(3,:))+lagPnts);
    uvw(3,-lagPnts+1:length(uvw(3,:))) = uvw(3,-lagPnts +1:length(uvw(3,:))) + uvwplat(3,1:length(uvw(3,:))+lagPnts);
end;
w_motcorr = uvw(3,:);

if decorr
    % Decorrelate wind-motion.  Sequentially remove correlation
    % between wind and platform acceleration/velocity for each axis.
    Cua = cov(detrend(uvw(1,:)),detrend(plat_acc(1,:)));
    muua = Cua(1,2)/Cua(2,2);
    uvw(1,:) = uvw(1,:) - muua*detrend(plat_acc(1,:));
    Cuv = cov(detrend(uvw(1,:)),detrend(uvwplat(1,:)));
    muuv = Cuv(1,2)/Cuv(2,2);
    uvw(1,:) = uvw(1,:) - muuv*detrend(uvwplat(1,:));

    Cva = cov(detrend(uvw(2,:)),detrend(plat_acc(2,:)));
    muva = Cva(1,2)/Cva(2,2);
    uvw(2,:) = uvw(2,:) - muva*detrend(plat_acc(2,:));
    Cvv = cov(detrend(uvw(2,:)),detrend(uvwplat(2,:)));
    muvv = Cvv(1,2)/Cvv(2,2);
    uvw(2,:) = uvw(2,:) - muvv*detrend(uvwplat(2,:));

    Cwa = cov(detrend(uvw(3,:)),detrend(plat_acc(3,:)));
    muwa = Cwa(1,2)/Cwa(2,2);
    uvw(3,:) = uvw(3,:) - muwa*detrend(plat_acc(3,:));
    Cwv = cov(detrend(uvw(3,:)),detrend(uvwplat(3,:)));
    muwv = Cwv(1,2)/Cwv(2,2);
    uvw(3,:) = uvw(3,:) - muwv*detrend(uvwplat(3,:));

    % decorrelate Ts w/respect to motion on all 3 axes
    Ctwa = cov(detrend(Ts),detrend(plat_acc(3,:)));
    mutwa = Ctwa(1,2)/Ctwa(2,2);
    Ts = Ts - mutwa*detrend(plat_acc(3,:));
    Ctwv = cov(detrend(Ts),detrend(uvwplat(3,:)));
    mutwv = Ctwv(1,2)/Ctwv(2,2);
    Ts = Ts - mutwv*detrend(uvwplat(3,:));

    Ctva = cov(detrend(Ts),detrend(plat_acc(2,:)));
    mutva = Ctva(1,2)/Ctva(2,2);
    Ts = Ts - mutva*detrend(plat_acc(2,:));
    Ctvv = cov(detrend(Ts),detrend(uvwplat(2,:)));
    mutvv = Ctvv(1,2)/Ctvv(2,2);
    Ts = Ts - mutvv*detrend(uvwplat(2,:));

    Ctua = cov(detrend(Ts),detrend(plat_acc(1,:)));
    mutua = Ctua(1,2)/Ctua(2,2);
    Ts = Ts - mutua*detrend(plat_acc(1,:));
    Ctuv = cov(detrend(Ts),detrend(uvwplat(1,:)));
    mutuv = Ctuv(1,2)/Ctuv(2,2);
    Ts = Ts - mutuv*detrend(uvwplat(1,:));
end;

N = floor(length(son)/2);
dd = sprintf('%02i',floor(son(1,1)));
hh = sprintf('%02i',round((son(1,1)-floor(son(1,1)))*24));
figure; plot(son(N-150:N+150,1),uvwplat(3,N-150:N+150),'r',son(N-150:N+150,1),w_raw(N-150:N+150),'b');
hold on; plot(son(N-150:N+150,1),w_motcorr(N-150:N+150),'g',son(N-150:N+150,1),uvw(3,N-150:N+150),'k');
plot([son(N-150,1),son(N+150,1)],[0,0],'k');
xlabel('Time'); ylabel('Velocity m/s'); grid; title([dd,' ',hh,' Rotated raw W (b), wplat(r), Corrected W(g), Decorr W (k)']);




