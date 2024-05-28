function [usib, tsib, qsib, Lid] = idiss(Cu2, Ct2, Cq2, qbar, Tbar, zu, zq, L_bulk, usb, tsb, qsb)
%{
    Inertial dissipation calculations

    inputs may be single values or vectors of equal length
    inputs: Cu2, Ct2, Cq2: structure function parameters
            qbar, Tbar:    mean q and T from bulk T/RH sensors
            zu, zq:        wind and q measurement heights (m)
            L_bulk, usb, tsb, qsb: COARE model output

    outputs: usib, tsib, qsib, Lid
%}

qsb = qsb/1000; % kg/kg units
vkon = 0.4;
alphau = 0.52;
c_coeff = 4*vkon/alphau^.667;
g = 9.82;
Cp = 1004;
Cle = 2500 - 2.274*Tbar;
T = 273.16+Tbar;
Tv = T.*(1+.61*qbar);
rho = 1013.25/287./Tv;
zet_u = zu./L_bulk;
zet_q = zq./L_bulk;
wtv = -usb.*(tsb+0.61.*T.*qsb);

% usid first pass
usib = sqrt(Cu2*zu^(2/3)./psi_fu(zet_u));
% Tstar, sonic
tsib = -sqrt(Ct2*(zu^(2/3))./psi_ft(zet_u)).*sign(wtv);
% Correct for water vapor effect on Tsonic
tsib = tsib - 0.51*T.*qsb;
% qsid
qsib = sqrt(Cq2*(zq^(2/3))./psi_ft(zet_q))*1e-3.*sign(qsb); % kg/kg

% refine usib...
us0 = usib;
ts0 = tsb;
qs0 = qsb;
for iii=1:10,
   zet = vkon*zu*g./Tv.*(ts0+0.61*T.*qs0)./(us0.*us0);
   us0 = sqrt(Cu2*(zu^(2/3))./psi_fu(zet));
   %ts0 = sign(zet)*sqrt(Ct2*(z^(2/3))/psi_ft(zet));
   %qs0 = -sqrt(Cq2*(z^(2/3))/psi_ft(zet))/1000;
   %ts0 = ts0 - 0.00051*T*qsid/rho;
end;
usib = us0;
Lid = zu./zet;

