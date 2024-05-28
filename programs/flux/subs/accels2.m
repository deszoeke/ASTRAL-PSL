function [uvwplat,xyzplat,accplat]=accels2(~,~,sf,accm,euler)
%
% Revised: June 10, 1997 - high pass filter with higher cutoff 
%			   frequency than previous version
% Revised: May, 2018: outputs rotated accelerations
% 
% Integrate linear accelerations to get platform velocity
% and displacement. After each integration, signals are 
% high pass filtered to remove low frequency effects.
%
% INPUT
%
%    bhigh,ahigh - high pass filter coefficients
%    sf 	 - sampling frequency
%    accm 	 - calibrated linear accelerations (output from recal.m)
%    euler	 - (3xN) Euler angles phi,theta,psi 
%
% OUTPUT:
%
%    acc     - (3XN) linear accelerations in FLIP/Earth reference 
%    uvwplat - (3XN) linear velocities at the point of motion measurement
%    xyzplat - (3XN) platform displacements from mean position

% DEFINE ARRAY SIZES UP FRONT

  uvwplat=zeros(size(accm));
  xyzplat=zeros(size(accm));
  
% DEFINE A HIGH PASS FILTER WHICH RETAINS REAL ACCELERATION BUT REMOVES DRIFT
% 
wp=1/25/(sf/2);
% wp=1/250/(sf/2);
ws=0.8*wp;
% [n,wn]=buttord(wp,ws,10,25);
[n,wn]=buttord(wp,ws,3,7);
[b,a]=butter(n,wn,'high');


% wp=1/240/(sf/2);
% ws=1/120/(sf/2);
% [n,wn]=buttord(wp,ws,1,14);
% % [n,wn]=buttord(wp,ws,9,30);
% [b,a]=butter(n,wn,'high');

% wp=1/120/(sf/2);
% ws=.8*wp;
% [n,wn]=buttord(wp,ws,3,5);

% % % % %disp([num2str(ws),'  ',num2str(wn),'  ',num2str(wp)])
% [b,a]=butter(n,wn,'high');

  
  gravxyz = mean(accm');
  gravity = sqrt( sum(gravxyz.^2) );

   accplat      = neaqs_trans(accm,euler,0);    % first rotate  
   accplat(3,:) = accplat(3,:) - gravity;      % remove gravity

   accplat(1,:) = filtfilt(b,a,accplat(1,:));
   accplat(2,:) = filtfilt(b,a,accplat(2,:));
   accplat(3,:) = filtfilt(b,a,accplat(3,:));   
   
   
% INTEGRATE ACCELERATIONS TO GET PLATFORM VELOCITIES

   uvwplat(1,:) = (cumsum(accplat(1,:)) -.5*accplat(1,:) - .5*accplat(1,1) )/sf;
   uvwplat(2,:) = (cumsum(accplat(2,:)) -.5*accplat(2,:) - .5*accplat(2,1) )/sf;
   uvwplat(3,:) = (cumsum(accplat(3,:)) -.5*accplat(3,:) - .5*accplat(3,1) )/sf;

% FILTER 

   uvwplat(1,:) = filtfilt(b,a,uvwplat(1,:));
   uvwplat(2,:) = filtfilt(b,a,uvwplat(2,:));
   uvwplat(3,:) = filtfilt(b,a,uvwplat(3,:));

% INTEGRATE AGAIN TO GET DISPLACEMENTS

   xyzplat(1,:) = (cumsum(uvwplat(1,:)) -.5*uvwplat(1,:) - .5*uvwplat(1,1) )/sf;
   xyzplat(2,:) = (cumsum(uvwplat(2,:)) -.5*uvwplat(2,:) - .5*uvwplat(2,1) )/sf;
   xyzplat(3,:) = (cumsum(uvwplat(3,:)) -.5*uvwplat(3,:) - .5*uvwplat(3,1) )/sf;

   xyzplat(1,:) = filtfilt(b,a,xyzplat(1,:));
   xyzplat(2,:) = filtfilt(b,a,xyzplat(2,:));
   xyzplat(3,:) = filtfilt(b,a,xyzplat(3,:));
