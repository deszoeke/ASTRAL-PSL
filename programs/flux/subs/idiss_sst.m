function [usib, tsib, qsib, Lid] = idiss_sst(Cu2, Ct2, Cq2, qbar, Tbar, zu, zq, L_bulk, tsb, qsb)
% function [usib, tsib, qsib, Lid] = idiss_sst(Cu2, Ct2, Cq2, qbar, Tbar, Tskin, zu, zq, L_bulk, usb, tsb, qsb, dter)
%{
    Inertial dissipation calculations

    inputs may be single values or vectors of equal length
    inputs: Cu2, Ct2, Cq2: structure function parameters
            qbar, Tbar:    mean q and T from bulk T/RH sensors
            zu, zq:        wind and q measurement heights (m)
            L_bulk, usb, tsb, qsb: COARE model output
    note: inputs have been simplified so not all are used. can either use
    sign of tsr or sign of 

% should be the potential temp difference
% dtheta: 

    outputs: usib, tsib, qsib, Lid
%}

% qsb = qsb/1000; % convert to kg/kg units if not already there
vkon = 0.4;
% alphau = 0.52;
% c_coeff = 4*vkon/alphau^.667;
g = 9.82;
% Cp = 1004;
% Cle = 2500 - 2.274*Tbar;
Ta = 273.16+Tbar;
Tv = Ta.*(1+.61*qbar);
% rho = 1013.25/287./Tv;
zet_u = zu./L_bulk;
zet_q = zq./L_bulk;
% wtv = -usb.*(tsb+0.61.*Ta.*qsb);

% usid first pass
usib = sqrt(Cu2*zu^(2/3)./psi_fu(zet_u));
% Tstar, sonic
% tsib = -sqrt(Ct2*(zu^(2/3))./psi_ft(zet_u)).*sign(wtv);
% DT = Tsnk - dter + dT_warm_to_skin - Tbar;  % use deltaT for sign
% flux scales as dtheta, where it's surface - air, since theta is conserved
% quantity. 
% DT = Tskin - Tbar;  % use deltaT for sign
% DTheta = Theta_skin - Theta_air; % is this different or necessary?
% tsib = -sqrt(Ct2*(zu^(2/3))./psi_ft(zet_u)).*sign(DTheta);  % sonic Tstar
% tsr and dtheta have different signs, so change leading negative sign too
% DT = SST - Tbar + dter;  % ORIGINAL use deltaT for sign
% tsib = -sqrt(Ct2*(zu^(2/3))./psi_ft(zet_u)).*sign(DT);  % ORIGINAL sonic Tstar 
tsib = sqrt(Ct2*(zu^(2/3))./psi_ft(zet_u)).*sign(tsb);  % sonic Tstar 
% Correct for water vapor effect on Tsonic
tsib = tsib - 0.51*Ta.*qsb;
% qsid
qsib = sqrt(Cq2*(zq^(2/3))./psi_ft(zet_q))*1e-3.*sign(qsb); % kg/kg

% refine usib...
us0 = usib;
ts0 = tsb;
qs0 = qsb;
for iii=1:10
   zet = vkon*zu*g./Tv.*(ts0+0.61*Ta.*qs0)./(us0.*us0);
   us0 = sqrt(Cu2*(zu^(2/3))./psi_fu(zet));
   %ts0 = sign(zet)*sqrt(Ct2*(z^(2/3))/psi_ft(zet));
   %qs0 = -sqrt(Cq2*(z^(2/3))/psi_ft(zet))/1000;
   %ts0 = ts0 - 0.00051*T*qsid/rho;
end
usib = us0;
Lid = zu./zet;

end

