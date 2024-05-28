function [theta]=pot_temp(TK, P)

%%% function to calculate potential temperature [K] at different pressure levels
%%% For formula: T in deg K; P in hPa; reference P0 = 1,000 hPa = 100,000 Pa
Rd      = 287;  % J/K/kg
cp      = 1004; % J/K/kg
theta   = TK*(1000/P)^(Rd/cp);        