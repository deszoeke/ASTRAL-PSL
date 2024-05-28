function Exx = esat(T,P)
% function esat  
% Given temperature (C) and pressure (mb), returns
% saturation vapor pressure (mb).
Exx = 6.1121*exp(17.502*T./(240.97+T));
Exx = Exx.*(1.0007+P*3.46E-6);

