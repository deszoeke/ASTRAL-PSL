function Lv = lat_heat_vap(SST)
%%% latent heat of vaporization in J per kg

Lv = (2.501-.00237*SST)*1e6;
