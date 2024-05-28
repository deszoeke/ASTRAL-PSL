function Cx2 = idiss_spec_fit(Px, Fx, fmin, fmax, rwspd)
%{
Compute the intertial dissipation structure function parameter from a
    spectrum fit over fmin to fmax.

inputs: Px:    Variance spectrum, smoothed or bin-averaged
               spectrum may be single vector or 2-D with one spectrum per row
        Fx:    1-D frequency axis for spectrum, same length as Px
        fmin:  start frequency for fit
        fmax:  end frequency for fit
        rwspd: relative wind speed, 1-D with one value for each spectrum in Pxx

output: Cx2:   structure function parameter(s)
%}

cS = 4;           
if fmin>fmax
    fmin = fmax-4;
end;

[nr,~] = size(Px);
logP = NaN(nr,fmax-fmin+1);
Zpoly = NaN(nr,5);
Cx2 = NaN(nr,1);
Zslope = NaN(nr,1);

logF = log(Fx(fmin:fmax));

for ii = 1:nr
	logP(ii,:) = log(cS*((2*pi./rwspd(ii)).^(2/3)).*Px(ii,fmin:fmax).*...
                (Fx(fmin:fmax).^(5/3)));
    Zpoly(ii,:) = polyfit(logF,logP(ii,:),4);
end;

% logPfit = logP;
% for ii = 1:nr
% 	logPfit(ii,:) = Zpoly(ii,1)*logF(ii,:).^4 + Zpoly(ii,2)*logF(ii,:).^3 +...
%             Zpoly(ii,3)*logF(ii,:).^2 +Zpoly(ii,4)*logF(ii,:) + Zpoly(ii,5);
% end;
% figure; plot(logF',logP','bo-',logF',logPfit','r-');

% select fits with ~zero slope & compute Cx2
for ii = 1:nr
    Zslope(ii) = Zpoly(ii,4);
    if Zslope(ii)<0.25,
       Cx2(ii) = exp(Zpoly(ii,5));
    else
       inc = 1;
       while 1
          zold = Zslope(ii);
          Zslope(ii) = 4*Zpoly(ii,1)*logF(inc)^3 + 3*Zpoly(ii,2)*logF(inc)^2 + 2*Zpoly(ii,3)*logF(inc) + Zpoly(ii,4);
          inc = inc + 1;
          if fmin+inc>fmax
             break;
          end;
          if Zslope(ii)>zold || abs(Zslope(ii))<0.2
             break;
          end;
       end;
       Cx2(ii)=exp(Zpoly(ii,1)*logF(inc)^4 +Zpoly(ii,2)*logF(inc)^3 + Zpoly(ii,3)*logF(inc)^2  +Zpoly(ii,4)*logF(inc) + Zpoly(ii,5));
    end; 
end;

