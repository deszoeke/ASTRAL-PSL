function [rh] = sw_relhum(Tc, Tdc)

rh = nan(1,length(Tc));
Es = nan(1,length(Tc));
E = nan(1,length(Tc));

Es=6.11*10.0.^(7.5*Tc./(237.7+Tc));
E=6.11*10.0.^(7.5*Tdc./(237.7+Tdc));

% relative humidity in percent
rh =(E./Es)*100;