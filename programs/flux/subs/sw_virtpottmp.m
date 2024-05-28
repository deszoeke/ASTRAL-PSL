function [thetav] = sw_virtpottmp(airtmp,press,relhum)
%C
%C  This function calculates the virtual potential temperature as function of air
%C  temperature, pressure and humidity. Based on A. Gill's book
%C  Atmosphere-Ocean Dynamics pp 39-41 and these websites:

%C  http://glossary.ametsoc.org/wiki/Virtual_potential_temperature

%C  http://www.azimuthproject.org/azimuth/show/Virtual+potential+temperature

%C  modified by Elizabeth Thompson Dec 2017
%C
%C  thetav ------------ Virtual potential temperature (K)
%C  AIRTMP ------------ Air temperature (C)
%C  PRESS ------------- Barometric pressure (mb or hPa)
%C  RELHUM ------------ Relative humidity defined as W/Ws*100, where W is
%C                      the mixing ratio and Ws the saturation mixing ratio
%C  SPCHUM ------------ Specific humidity

Rd      = 287;      % dry gas constant
cpd     = 1004;     % specific heat capacity of dry air
p0      = 1000;     % reference pressure = 1000 mb or hPa

q       = sw_spchum(airtmp,press,relhum);
kappa   = Rd*(1-(0.23*q))/cpd;
thetav  = (1+(0.61.*q)).*(airtmp+273.15).*((p0./press).^kappa);
