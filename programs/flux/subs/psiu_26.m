function psi=psiu_26(zet)
% computes velocity structure function
dzet=min(50,0.35*zet); % stable
a=0.7;
b=3/4;
c=5;
d=0.35;
psi=-(a*zet+b*(zet-c/d).*exp(-dzet)+b*c/d);
k=find(zet<0); % unstable
x=(1-15*zet(k)).^0.25;
psik=2*log((1+x)/2)+log((1+x.*x)/2)-2*atan(x)+2*atan(1);
x=(1-10.15*zet(k)).^0.3333;
psic=1.5*log((1+x+x.^2)/3)-sqrt(3)*atan((1+2*x)./sqrt(3))+4*atan(1)./sqrt(3);
f=zet(k).^2./(1+zet(k).^2);
psi(k)=(1-f).*psik+f.*psic;
end
