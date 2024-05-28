function [Press,Tseak,Tairk,Qsatsea,Qsatms,Qms,Rhoair,Rhodry]=scalarv_et(P0,Tsea,Tair,RH,zt);

% Compute the require scalar variables for the bulk code
% Vectorized when needed
% Inputs:
% P0    Air pressure (mb)
% Tsea  SST (C)
% Tair  Air temperature (C)
% RH    Relative humidity (%)

Press=P0*100;                   %ATMOSPHERIC SEA LEVEL PRESSURE (Pa)
P_tq = 100*(P0 - (0.125*zt));   % P at tq measurement height (Pa)
Tseak=Tsea+273.15;              %SEA SURFACE TEMPERATURE (K)
Tairk=Tair+273.15;              %AIR TEMPERATURE (K)

if length(Tsea)>1
    %**********************COMPUTES QSEA***************************
    Exx=6.1121*exp(17.502*Tsea./(240.97+Tsea));
    Exx=Exx.*(1.0007+P0*3.46E-6);
    Esatsea=Exx*0.98;
    Qsatsea=.622*Esatsea./(P0-.378*Esatsea)*1000;  %SPEC HUM SEA (g/kg)
    
    %**********************COMPUTES QAIR***************************
    Exx=6.1121*exp(17.502*Tair./(240.97+Tair));
    Exx=Exx.*(1.0007+P_tq*3.46E-6);
    Qsatms=.622*Exx./(P_tq-.378*Exx)*1000;
    Ems=Exx.*RH/100;
    Qms=.622*Ems./(P_tq-.378*Ems)*1000;   %SPEC HUM AIR (g/kg)
    E=Ems*100;
    %******************COMPUTES AIR DENSITY*******************
    Rhoair=P_tq./(Tairk.*(1+.61*Qms/1000)*287.05);
    Rhodry=(P_tq-E)./(Tairk*287.05);
else
    %**********************COMPUTES QSEA***************************
    Ex=ComputeEsat(Tsea,P0);                         %SATURATION VALUE
    Esatsea=Ex*.98;
    Qsatsea=.622*Esatsea/(P0-.378*Esatsea)*1000;  %SPEC HUM SEA (g/kg)
    
    %**********************COMPUTES QAIR***************************
    Esatms=ComputeEsat(Tair,P_tq);          %SATURATION VALUE
    Qsatms=.622*Esatms/(P_tq-.378*Esatms)*1000;
    Ems=Esatms*RH/100;
    Qms=.622*Ems/(P_tq-.378*Ems)*1000;   %SPEC HUM AIR (g/kg)
    E=Ems*100;
    
    %******************COMPUTES AIR DENSITY*******************
    Rhoair=P_tq/(Tairk*(1+.61*Qms/1000)*287.05);
    Rhodry=(P_tq-E)/(Tairk*287.05);
end
end

function Exx=ComputeEsat(T,P)
%         Given temperature (C) and pressure (mb), returns
%         saturation vapor pressure (mb).
Exx=6.1121*exp(17.502*T./(240.97+T));
Exx=Exx.*(1.0007+P*3.46E-6);
end
