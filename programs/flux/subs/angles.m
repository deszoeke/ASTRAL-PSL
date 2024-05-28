 function [euler,dr]=angles(ahi,bhi,sf,accm,ratem,gyro)
%
% May 16 1997 - modified to remove the first estimate of the euler
%     angles in the nonlinear euler angle update matrix, F^-1 matrix
%     is approximated by the identity matrix. still uses trapezoidal
%     intetgration
%
% INPUT
%
%    ahi,bhi - filter coefficients
%    sf    - sampling frequency
%    accm  - (3xN) array of recalibrated linear accelerations,accx,accy,accz
%    ratem - (3XN) array of recalibrated angular rates, ratex, ratey, ratez
%    gyro  - (1XN) array of gyro signal
%
% OUTPUT
%
%    euler    - (3XN) array of the euler angles (phi, theta, psi) in radians.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% THE ANGLES ARE  ESTIMATED FROM
%
% angle = slow_angle (from accelerometers) + fast_angle (integrated rate sensors)
%
% CALCULATE GRAVITY from ACCM

  gravxyz = mean(accm');
  gravity = sqrt( sum(gravxyz.^2) );
%  disp(['Gravity = ',num2str(gravity),' m/s/s']);

% Unwrap compass
  gyro = unwrap(gyro);
%   gyro=detrend(gyro);

% REMOVE MEAN FROM RATE SENSORS

  ratem = detrend(ratem',0)';

% LOW FREQUENCY ANGLES FROM ACCELEROMETERS AND GYRO
%
% ROLL

% SLOW ROLL FROM GRAVITY EFFECTS ON HORIZONTAL ACCELERATIONS. LOW PASS
% FILTER SINCE HIGH FREQUENCY HORIZONTAL ACCELERATIONS MAY BE 'REAL'

%%% this will fail if given nans. accm = [3,36000]
  phislow = atan2(accm(2,:),gravity) - filtfilt(bhi,ahi,atan2(accm(2,:),gravity));

% PITCH

% fs=10;         %Sonic are output at 20 Hz
% fc=1/40;       %Cutoff frequency for angle calculation
% nfreq = fs/2.0;                   %Nyquist frequency
% wpt = fc/nfreq;
% wst = .6*wpt;
% [nt,wnt] = buttord(wpt,wst,10,25);        %Filter coefficients
% [bhit,ahit] = butter(nt,wnt,'high');  %High order Butterworth filter

  thetaslow = atan2(-accm(1,:),gravity) - filtfilt(bhi,ahi,atan2(-accm(1,:),gravity));

% YAW

% HERE, WE ESTIMATE THE SLOW HEADING. THE 'FAST HEADING' IS NOT NEEDED
% FOR THE EULER ANGLE UPDATE MATRIX. THE NEGATIVE SIGN PUTS THE GYRO
% SIGNAL INTO A RIGHT HANDED SYSTEM.

% fs=10;         %Sonic are output at 20 Hz
% fc=1/120;       %Cutoff frequency for angle calculation
% nfreq = fs/2.0;                   %Nyquist frequency
% wpp = fc/nfreq;
% wsp = .6*wpp;
% [np,wnp] = buttord(wpp,wsp,10,25);        %Filter coefficients
% [bhip,ahip] = butter(np,wnp,'high');  %High order Butterworth filter
%
% psislow = (-gyro - filtfilt(bhip,ahip,-gyro));
psislow = (-gyro - filtfilt(bhi,ahi,-gyro));

% INTEGRATE AND FILTER ANGLE RATES, AND ADD TO SLOW ANGLES

   phi   = phislow   + filtfilt(bhi,ahi,((cumsum(ratem(1,:)) -.5*ratem(1,:) - .5*ratem(1,1))/sf));
   theta = thetaslow + filtfilt(bhi,ahi,((cumsum(ratem(2,:)) -.5*ratem(2,:) - .5*ratem(2,1))/sf));

psi   = psislow   + filtfilt(bhi,ahi,((cumsum(ratem(3,:)) -.5*ratem(3,:) - .5*ratem(3,1))/sf));

   euler  = [phi; theta; psi];
   dr = ratem;
