function [wT, wq] = wpl_schotanus(meanT, meanq, meanrho, wTson_cov, wH2O_cov)
%{
  [wT, wq] = wpl_schotanus(meanT,meanq,meanrho, wTs,wrhov)
  Computes wT and wq covariances from sonic temperature and water vapor
  density covariances wTson, wrhov; combining Webb et al. 1980 and Schotanus
  1983. Requires mean temperature meanT, mean specific humidity meanq, and
  mean air density meanrhov. See de Szoeke et al. 2017 appendix.

  % it doesn't look like there is a velocity cross talk correction here

  [wT_cov_sds, wq_cov_sds] = wpl_schotanus(x.Ta+C2K,x.qa/1000,x.rhoa,wTson_cov,wH2O_cov);

  meanT in deg C
  meanq in kg/kg
  meanrhoa in kg/m3
  wH2O_cov in mmol/m3 (as reported by Licor 7500)
  wTson_cov in K 

  Simon de Szoeke 2018, PISTON
  
%}

Md = 28.97;  % kg/kmol
Mv = 18.016; % kg/kmol
epsilon = Mv/Md;
mu = Md/Mv;
delta = (1/epsilon)-1; % virtual temperature coefficient
gamma = 0.51; % sonic temperature qv coefficient, Ts = T(1+ gamma*qv)
%alpha = gamma.*meanq.*(1+ (mu-2)*meanq + (1-mu)*meanq)./(1-meanq);
alpha = gamma.*meanq; % (1+ (mu-2)*meanq + (1-mu)*meanq)./(1-meanq) === 1

sigma = meanq./(1-meanq); % mixing ratio of the mean
rhov = meanq.*meanrho;
rhovoT = rhov./meanT; %  <rhov>/<T>

% calculates evaporation (kinematic)
% using Tsonic Schotanus (1983) and Webb et al. (1980) formulae from NCAR web page
factr = 1+mu*sigma;
eterm1 = factr.*rhovoT.*wTson_cov; % dry crosstalk term
eterm2 = factr.*(((1-alpha)./(1+alpha)).*(Mv*1.0e-6).*wH2O_cov); % wet term
wq = eterm1 + eterm2;
% (Mv*1.0e-6).*wcov.(tag).h2o --> kg/m^3

% calculates sensible heat flux, uses Schotanus (1983) sonic T correction
sterm1 =  wTson_cov./(1+alpha) ; % dry term
sterm2 = -meanT.*alpha.*(Mv*1.0e-6).*wH2O_cov./(rhov.*(1+alpha)); % wet crosstalk term
wT = sterm1 + sterm2;
end
