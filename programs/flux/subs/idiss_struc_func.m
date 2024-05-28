function Cx2 = idiss_struc_func(Px, Fx, fmin, fmax, rwspd, meanTrue)
%{
    Compute inertial dissipation structure function parameter as mean
     or median over frequency range fmin to fmax.

    inputs: Px: variance spectrum, smoothed / bin averaged or raw
                spectrum may be 1-D vector or 2-D with one spectrum per row
            Fx: frequency axis for spectrum, 1-D same length as Pxx
            fmin: index for start frequency
            fmax: index for end frequency
            rwspd: mean relative wind speed, vector with single value for each
                spectrum in Pxx, length = #rows in Pxx
            meanTrue: boolean input, computes mean if true, median if false

    output: Cx2: structure function parameter array, length = #rows in Pxx
%}

cS = 4;
N = length(rwspd);
if N>1
    Cx2 = zeros(1,N)*NaN;
    for ii = 1:N
        if meanTrue
            Cx2(ii) = mean(cS*((2*pi/rwspd(ii))^(2/3))*Px(ii,fmin:fmax).*Fx(fmin:fmax).^(5/3));
        else
            Cx2(ii) = median(cS*((2*pi/rwspd(ii))^(2/3))*Px(ii,fmin:fmax).*Fx(fmin:fmax).^(5/3));
        end
    end
else
    if meanTrue
        Cx2 = mean(cS*((2*pi/rwspd)^(2/3))*Px(fmin:fmax).*Fx(fmin:fmax).^(5/3));
    else
        Cx2 = median(cS*((2*pi/rwspd)^(2/3))*Px(fmin:fmax).*Fx(fmin:fmax).^(5/3));
    end
end
Cx2 = Cx2';
