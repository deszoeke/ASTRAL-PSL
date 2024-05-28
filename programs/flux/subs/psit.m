
function psi=psit(zet)
if zet<0
	x=(1-15*zet)^.5;
	psik=2*log((1+x)/2);
	x=(1-30*zet)^.3333;
	psic=1.5*log((1+x+x*x)/3)-sqrt(3)*atan((1+2*x)/sqrt(3))+4*atan(1)/sqrt(3);
	f=zet*zet/(1+zet*zet);
	psi=(1-f)*psik+f*psic;                                               
else
	%psi=-4.7*zet;
	c=min(50,.35*zet);
   psi=-((1+2/3*zet)^1.5+.6667*(zet-14.28)/exp(c)+8.525);

end;