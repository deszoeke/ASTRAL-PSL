function Ra = air_density(T,P,RH)
% computes density of moist air in kg/m3 given T, P and RH
% T in C
% P in mb or hPa

Md = 0.028964;  % MW dry air in kg/mol
Mv = 0.018016;  % MW water in kg/mol
Tk = T+273.15;  % T in deg K
Pa = P*100;     % P in Pa
R = 8.314;      % gas const in m3 Pa/mol K

Pv = (RH/100).*esat(T,P)*100; % H2O vapor pressure in Pa
Pd = Pa - Pv;   % pressure dry air
Ra = (Pd*Md + Pv*Mv)./(R*Tk);
end
