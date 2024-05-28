function y=qsea_p(sst, slp)
% function to compute sea surface specific humidity in g/kg, often written
% as q_s or SSQ.

% function is derived by calculating saturation vapor pressure, es, at sea surface given SST, SLP
% accounts for the salt effect (factor of 0.98, and the rest of the odd numbers)

% sst =  sea surface temp, deg C
% slp = sea level pressure, mb

es=6.112.*exp(17.502.*sst./(sst+241.0))*.98.*(1.0007+3.46e-6.*slp);
y=es*622./(slp-.378*es);