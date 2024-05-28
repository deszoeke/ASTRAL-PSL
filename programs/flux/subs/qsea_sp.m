function qs=qsea_sp(T,P,Ss)

% convert rh to specific humidity after accounting for salt effect on freezing
% point of water
Tf=-0.0575*Ss+1.71052E-3*Ss.^1.5-2.154996E-4*Ss.*Ss; %freezing point of seawater

% From ex=bucksat(T,P,Tf)... using exx = bucksat(T,P, Tf) function
% computes saturation vapor pressure [mb]
% given T [degC] and P [mb] and Tf [degC] freezing pt 
% computes surface saturation specific humidity [g/kg]
exx=6.1121.*exp(17.502.*T./(T+240.97)).*(1.0007+3.46e-6.*P);
ii=find(T<Tf);
exx(ii)=(1.0003+4.18e-6*P(ii)).*6.1115.*exp(22.452.*T(ii)./(T(ii)+272.55));%vapor pressure ice

fs=1-0.02*Ss/35;% reduction sea surface vapor pressure by salinity
es=fs.*exx; 
qs=622*es./(P-0.378*es);
end