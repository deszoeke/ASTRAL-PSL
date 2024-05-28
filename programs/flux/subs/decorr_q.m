function q_out = decorr_q(q_in,uvwplat,plat_acc)

%{
    decorrelates q_in w/respect to velocity and acceleration on 3 axes
    decorrelation applied sequentially: v axis acc, v axis vel, u axis acc,
        u axis vel, w axis acc, w axis vel.

    inputs: q_in    - Nx1 vector of fast specific humidity (or other variable)
            uvwplat - Nx3 array of platform velocities on u,v,w axes
            plat_acc- Nx3 array of platform accelerations on u,v,w axes
%}

q_out = q_in;

Cqva = cov(detrend(q_out),detrend(plat_acc(:,2)));
muqva = Cqva(1,2)/Cqva(2,2);
q_out = q_out - muqva*detrend(plat_acc(:,2));
Cqvv = cov(detrend(q_out),detrend(uvwplat(:,2)));
muqvv = Cqvv(1,2)/Cqvv(2,2);
q_out = q_out - muqvv*detrend(uvwplat(:,2));

Cqua = cov(detrend(q_out),detrend(plat_acc(:,1)));
muqua = Cqua(1,2)/Cqua(2,2);
q_out = q_out - muqua*detrend(plat_acc(:,1));
Cquv = cov(detrend(q_out),detrend(uvwplat(:,1)));
muquv = Cquv(1,2)/Cquv(2,2);
q_out = q_out - muquv*detrend(uvwplat(:,1));

Cqwa = cov(detrend(q_out),detrend(plat_acc(:,3)));
muqwa = Cqwa(1,2)/Cqwa(2,2);
q_out = q_out - muqwa*detrend(plat_acc(:,3));
Cqwv = cov(detrend(q_out),detrend(uvwplat(:,3)));
muqwv = Cqwv(1,2)/Cqwv(2,2);
q_out = q_out - muqwv*detrend(uvwplat(:,3));

