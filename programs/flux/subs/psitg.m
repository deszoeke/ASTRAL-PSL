function psi=psitg(zet)
%Modified 3/19/98 to allow vector input/output by Peter Guest

%stable case
	%psi=-4.7.*zet;
	c=min(50,.35.*zet);
	psi=-((1+.6667*zet).^1.5+.6667.*(zet-14.28)./exp(c)+8.525);

%unstable case
        uns=find(zet<0);
        if ~isempty(uns);
          x=(1-15.*zet(uns)).^.5;
	  psik=2*log((1+x)/2);
	  x=(1-30*zet(uns)).^.3333;
	  psic=1.5*log((1+x+x.*x)./3)-sqrt(3)*atan((1+2.*x)/sqrt(3))+4*atan(1)/sqrt(3);
	  f=zet(uns).*zet(uns)./(1+zet(uns).*zet(uns));
	  psi(uns)=(1-f).*psik+f.*psic;                                               
        end;
    
   
