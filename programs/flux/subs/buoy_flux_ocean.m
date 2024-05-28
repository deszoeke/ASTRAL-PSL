function [B, B_Q, B_R, ...
    B_Train, B_Salt, B_Q_evap_salt, B_Q_evap_cool] = ...
    buoy_flux_ocean(SSS, SST, R, lhf, Qnet, Tw)

%==========================================================================
% Function to calculate the buoyancy flux, B, into the ocean surface, as
% well as the expected stable layer depth, hS_hat, and the wind limit for a set
% stable layer depth, US_hat. We abbreviate in this code by omiting "_hat"
% from variables.

% author:
%       Elizabeth J. Thompson
%       NOAAA ESRL PSD
%       elizabeth.thompson@noaa.gov
%       Oct 2018

% citation:
%       Thompson E. J., J. N. Moum, C. W. Fairall, S. A. Rutledge, accepted: 
%             Wind limits on rain layers and diurnal warm layers
%                     J. Geophys. Res. Oceans., accepted.

%  outputs:
%       B       bouyancy flux into ocean surface [m^2 s^-3]
%       hS      estimated stable layer depth [m]
%       US      estimated wind (U10) limit of stratification for B and hS_hat [m s-1]

%  inputs: 
%       SST     sea surface temperature
%       SSS     sea surface salinity
%       R       rain rate in mm/h
%       E       evap rate in mm/h
%       Qnet    net heat flux w/o rhf = net solar + net IR + lhf + shf
%       Tw      wet bult temp, function of Tair and RH
%       tau     wind stress, N m^-2
%       U10     wind speed adjusted to 10 m for neutral stability
%       rho_a   density of air at 10 m
% k           = 0.41;             % von Karmon constant
%mean_rho_a  = nanmean(rho_a);   % density of air at 10 m(?) [kg m-3]


%==========================================================================
% preparation
%=================
g           = 9.81;             % gravity [m s^-2]
rho_pw      = 1000;             % density of pure water [kg m-3]
rho_w       = sw_dens(SSS, SST, 0.0); % density of sea water [kg m-3]
mean_rho_w  = nanmean(rho_w);         % mean density of sea water [kg m-3]
cp_sw       = sw_cp(SSS,SST,0.0); % specific heat of seawater [J/kg/degK]... c=4187 for pure water
%cd          = tau ./ (mean_rhoA*(U10.^2)); % drag coefficient [unitless]
%mean_cd     = nanmean(cd); % mean drag coefficient [unitless]
alpha       = sw_alphap(SSS,SST,0.0); % thermal expansion coeffient [per deg C]
beta        = sw_betap(SSS,SST,0.0); % salt contractino coefficient [per PSU]
deltaT      = Tw-SST; % change of temp between rain drops and SST
Rmass       = rho_pw.* (1/(3600*1000)) .* R; % rain mass flux [kg/m2/s]
Emass       = lhf ./ (lat_heat_vap(SST)); % evaporation mass flux [kg/m2/s]
            %%% Emass = rho_pw. * (1 / 3600*1000)) .* Erate;
%==========================================================================
% buoyancy fluxes
%=================


% Calculate buoyancy mass fluxes [kg m-2 s-1]
Rmass(isnan(Rmass) == 1) = 0.0;
salt = Rmass-Emass;

M_Salt      = SSS.*beta.*(salt);
M_Train     = alpha.*deltaT.*(Rmass);
M_Qnet      = -1.*(alpha./cp_sw).*Qnet;
M           = M_Train + M_Salt + M_Qnet;

% Calculate buoyancy fluxes [m^2 s^-3]
B_Salt  = g.*M_Salt    .* (1/mean_rho_w);
B_Train = g.*M_Train   .* (1/mean_rho_w);
B_Qnet  = g.*M_Qnet    .* (1/mean_rho_w);
B       = g.*M         .* (1/mean_rho_w);


B_pos = B;
B_pos(B < 0) = 0;

B_R     = g.* (1/mean_rho_w) .* Rmass .* (SSS.*beta + alpha.*deltaT);
B_Q     = (-1 * g * alpha )./(mean_rho_w .* cp_sw) .* ( ((cp_sw./alpha).*SSS.*beta.*Emass) + Qnet);

B_Q_evap_salt = (-9.81 * alpha )./(mean_rho_w .* cp_sw) .* ( (cp_sw./alpha).*SSS.*beta.*Emass);
B_Q_evap_cool = (-9.81 * alpha )./(mean_rho_w .* cp_sw) .* (lhf);

B(isfinite(B) ~= 1)         = nan; 
B_Q(isfinite(B_Q) ~= 1)     = nan;
B_R(isfinite(B_R) ~= 1)     = nan;

B_Q_pos = B_Q;
B_Q_pos(B_Q < 0) = nan;
