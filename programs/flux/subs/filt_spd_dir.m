function [fspd,fdir,fNspd,fEspd] = filt_spd_dir(spd,dir,fs)
%{
    apply filter to noisy speed/direction data, 0.04 Hz lowpass.
    dir is degrees, 0-360; spd output has same units as input.
    fs is data frequency in Hz.
%}

Nspd = spd .* cos(dir*pi/180); % compute N/E component vectors
Espd = spd .* sin(dir*pi/180);

% [Nspd,~] = despike2(Nspd); % replace 4sig spikes with nearest neighbor
% [Espd,~] = despike2(Espd);

wp = 1/25/(fs/2);
ws = 0.8*wp;
[n,wn] = buttord(wp,ws,3,7);
[blo,alo] = butter(n,wn,'low');
fNspd = filtfilt(blo,alo,Nspd); % filtered N component vector
fEspd = filtfilt(blo,alo,Espd); % filtered E component vector
fspd = sqrt(fNspd.^2 + fEspd.^2);
fdir = mod(atan2(fEspd,fNspd)+2*pi, 2*pi)*180/pi;
end