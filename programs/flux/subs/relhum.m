function [rh]=relhum(x)
%x=[t q p]
t = x(:,1);% air temp (Cent)
qa = x(:,2);% spec hum (g/kg)
p = x(:,3);% pressure (mb)

% sat vapor pressure, from Buck
es = 6.112.*exp(17.502.*t./(t+241.0)).*(1.0007+3.46e-6*p);
% vap pressure
e = p.*qa./(622+.378*qa);
rh = e./es*100;

end
