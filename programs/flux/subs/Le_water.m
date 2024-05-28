function [Le_w, Le_sw] = Le_water(ts, sal)
%{
    computes latent heat of vaporization for pure water and seawater
    reference:  M. H. Sharqawy, J. H. Lienhard V, and S. M. Zubair, Desalination
                and Water Treatment, 16, 354-380, 2010. (http://web.mit.edu/seawater/)
    validity: 0 < t < 200 C;   0 <sal <240 g/kg

    inputs: T in deg C
            sal in ppt or psu

    output: Le_w, Le_sw in J/g (J/kg) ~ should be about 2.4 x 10^6
    
    Edited by EJT in May 2021 to output J/kg per convention/norm
%}

% polynomial constants
a = [2.5008991412E+06, -2.3691806479E+03, 2.6776439436E-01, ...
    -8.1027544602E-03, -2.0799346624E-05];

Le_w = (a(1) + a(2)*ts + a(3)*ts.^2 + a(4)*ts.^3 + a(5)*ts.^4); %J/kg
Le_sw = (Le_w .* (1 - 0.001*sal)); %J/kg
Le_w = Le_w; %J/kg

