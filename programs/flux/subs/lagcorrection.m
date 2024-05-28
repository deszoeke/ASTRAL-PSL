function Xlagflag = lagcorrection(X,Y,maxlags)

Xlagflag=0;  %defines default lag time

% calculate y/x correlation over lag range of +/- maxlags points
% positive xlags means Y is lagged w/ respect to X
% negative xlags => X is lagged w/ respect to Y
[XYcorr,xlags] = xcov(Y,X,maxlags,'coeff');
% stem(xlags,XYcorr); grid;

% find index for minimum in correlation
[minXYcorr, minXLagIndex] = min(XYcorr);
[maxXYcorr, maxXLagIndex] = max(XYcorr);

if abs(maxXYcorr)>abs(minXYcorr)
    Xlagflag = maxXLagIndex-maxlags-1;
elseif abs(maxXYcorr)<abs(minXYcorr)
    Xlagflag = minXLagIndex-maxlags-1;
end

