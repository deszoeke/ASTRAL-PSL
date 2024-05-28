function [uvw,Ts,uvwplat,xyzplat,euler,son_rot,lagPnts] = motcorr_test(son,mot,heading,sens_disp,fsam,decorr)
%{
motcorr_test.m - computes motion-corrected wind from raw sonic and motionPak

test version - Nov 2015

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
son_rot = neaqs_trans(son_vel+cross(plat_rate,R),euler,0);

% compute lag between W and platform vertical velocity
% shift uvw accordingly and sum with uvwplat to correct winds
% uvw are then in earth coordinates, corrected for platform pitch/roll/yaw
uvw = son_rot;
% check lag of W and wplat - positive lagPnts means motion is lagged w/respect to wind
lagPnts = lagcorrection(uvw(3,:),uvwplat(3,:),16);
% shift platform vel accordingly
if lagPnts > 0,
    uvwplat(:,1:end-lagPnts) = uvwplat(:,lagPnts+1:end);
else
    uvwplat(:,abs(lagPnts)+1:end) = uvwplat(:,1:end-abs(lagPnts));
end;
uvw = uvw + uvwplat;

if decorr
    uvw1 = uvw;
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

% jd10 = son(:,1');
% figure;plot(jd10,son_rot(1,:),'r',jd10,uvwplat(1,:),'b',jd10,uvw1(1,:),'g',jd10,uvw(1,:),'k');grid;xlim([15.3550,15.3555]);
% figure;plot(jd10,son_rot(2,:),'r',jd10,uvwplat(2,:),'b',jd10,uvw1(2,:),'g',jd10,uvw(2,:),'k');grid;xlim([15.3550,15.3555]);
% figure;plot(jd10,son_rot(3,:),'r',jd10,uvwplat(3,:),'b',jd10,uvw1(3,:),'g',jd10,uvw(3,:),'k');grid;xlim([15.3550,15.3555]);
