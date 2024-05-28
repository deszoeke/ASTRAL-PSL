function yy = filt_lowpass(xx,fs,pb)
%{
    apply low pass filter to noisy data, 0.04 Hz passband.
    pb is passband (e.g. 0.04 Hz), fs is data frequency in Hz.
%}

[yy,~] = despike2(xx); % replace 4sig spikes with nearest neighbor

wp = pb/(fs/2);
ws = 0.8*wp;
[n,wn] = buttord(wp,ws,3,7);
[blo,alo] = butter(n,wn,'low');
yy = filtfilt(blo,alo,yy);
end