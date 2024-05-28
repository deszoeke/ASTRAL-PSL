function [uvw,Ts,uvwplat,xyzplat,euler,lagPnts] = motcorr(son,mot,heading,sens_disp,fsam,decorr)
%{
motcorr.m - computes motion-corrected wind from raw sonic and motionPak
data files.  Edson-98 method.

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

if decorr
    % Decorrelate wind-motion  and Tsonic-motion. Sequentially remove correlation
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

    % decorrelate Ts w/respect to vertical wind
    Cta = cov(detrend(Ts),detrend(plat_acc(3,:)));
    muta = Cta(1,2)/Cta(2,2);
    Ts = Ts - muta*detrend(plat_acc(3,:));
    Ctv = cov(detrend(Ts),detrend(uvwplat(3,:)));
    mutv = Ctv(1,2)/Ctv(2,2);
    Ts = Ts - mutv*detrend(uvwplat(3,:));
end;

