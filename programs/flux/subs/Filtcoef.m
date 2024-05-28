function [bhigh,ahigh,bf,af,tau,spinup] = Filtcoef(fs,fc)

%%  This m-file calculates the filter coefficients
%%  from the sampling (fs) and cutoff (fc) frequencies.

% First order Butterworth filter used in the complementary filtering
% algorithm.
    
nfreq = fs/2.0;
bc = fc/nfreq;
[bf,af] = butter(1,bc);  
dt = 1./fs;                      % Time step
tau = 1./fc/2/pi;                % Filter time constant
spinup = fs/fc;                  % Spinup time
omega_c = tan(dt/2/tau);         % Pre-warped frequency
tau = dt/2/omega_c;              % Time constant used in 
                                 % integrating filter.

% DEFINE A HIGH PASS FILTER WITH A LOWER CUTOFF FREQUENCY THAN BEFORE
% THESE FILT COEFFS ARE USED IN THE UCI ANGLES M-FILE                               
% wp = 1/120/(fs/2);
% ws = 1/60/(fs/2);   
% wp = 1/40/(fs/2);
% ws = 1/20/(fs/2);   
% [n,wn] = buttord(wp,ws,1,20);
% 
% [bhigh,ahigh] = butter(n,wn,'high');

% DEFINE A HIGH PASS FILTER WHICH RETAINS REAL ACCELERATION BUT REMOVES DRIFT
% 3/2/98 - MODIFIED FILTER DESIGN.  THE OLD FILTER WAS %
%   wp=1/40/(sf/2);ws=1/20/(sf/2);
%   [n,wn]=buttord(wp,ws,1,14);
% THE NEW FILTER WAS CHOSEN SO THAT THE SPECTRA OF THE DOUBLY INTEGRATED ACCELERATION
% MATCHED THE FREQUENCY DOMAIN INTEGRATED POWER SPECTRUM IN THE PASS BAND. THE
% COMPARISON WAS MOST SENSITIVE TO THE TRANSITION WIDTH
% wp=1/25/(sf/2);
% ws=.7*wp;
% [n,wn]=buttord(wp,ws,10,25);
% [n,wn]=buttord(wp,ws,10,15);
% % %disp([num2str(ws),'  ',num2str(wn),'  ',num2str(wp)])
% [bhigh,ahigh]=butter(n,wn,'high');
% wp=1/25/(sf/2);
% ws=.8*wp;
% [n,wn]=buttord(wp,ws,3,5);
wp = 1/25/(fs/2);
% wp=1/250/(sf/2);
ws = 0.8*wp;
[n,wn] = buttord(wp,ws,3,7);
% % %disp([num2str(ws),'  ',num2str(wn),'  ',num2str(wp)])
[bhigh,ahigh] = butter(n,wn,'high');
% %freqz(bhigh,ahigh,72000,20)
% wp=1/40/(sf/2);
% ws=.6*wp;
% [n,wn]=buttord(wp,ws,10,25);
% %disp([num2str(ws),'  ',num2str(wn),'  ',num2str(wp)])
% [bhigh,ahigh]=butter(n,wn,'high');
%freqz(bhigh,ahigh,72000,20);
% wp=1/240/(sf/2);	% passband cutoff @ 1/240 (4.16e-3) Hz
% ws=1/120/(sf/2);	% stopband cutoff @ 1/120 (8.33e-3) Hz
% [n,wn]=buttord(wp,ws,1,14);  % 1 dB ripple in passband, 14 dB attn in stopband
% [bhigh,ahigh]=butter(n,wn,'high');