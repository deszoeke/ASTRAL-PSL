function [F, lhf_ef, coeff_lhf] = buoy_flux_atm(SST,T_rate,lhf,shf,rhoa, thetav)

%==========================================================================
% Function to calculate the buoyancy flux, F, into the atmosphere

% author:
%       Elizabeth J. Thompson
%       NOAAA ESRL PSD
%       elizabeth.thompson@noaa.gov
%       Oct 2018

% citation:
%       Thompson E. J., J. N. Moum, C. W. Fairall, S. A. Rutledge, accepted: 
%             Wind limits on rain layers and diurnal warm layers
%                     J. Geophys. Res. Oceans., accepted.

%  outputs: [F, lhf_ef, coeff_lhf]
%       F           bouyancy flux into atm [m^2 s^-3]
%       lhf_ef      effective latent heat flux contribution to F, weighted by
%                       coefficients, [m^2 s^-3]
%       coeff_lhf   coefficients that weight lhf's contribution to F

%  inputs: [SST,T_rate,lhf,shf,rhoa, thetav]
%       SST         skin sea surface temperature, C
%       T_rate      number of samples in one hour, #
%       lhf         latent heat flux, W/m2
%       shf         latent heat flux, W/m2
%       rhoa        density of air at 10 m
%       thetav      virtual potential temp at 10 m, C

% k           = 0.41;             % von Karmon constant
% mean_rho_a  = nanmean(rho_a);   % density of air at 10 m(?) [kg m-3]


%%% hourly average SST
mean_SST_K = movmean(SST,T_rate)+273.15;

%%% latent heat of fusion
Le = lat_heat_vap(SST);

x = (9.81 ./ thetav) .* (1./(1004*rhoa));

F               = x.*(shf + (0.61*1004*mean_SST_K.*(1./Le).*lhf));  %%% buoyancy flux
lhf_ef          = 0.61*1004*(mean_SST_K./Le).*lhf;          %%% effective lhf in F
coeff_lhf       = 0.61*1004*mean_SST_K./Le;                 %%% coefficient on lhf in F
