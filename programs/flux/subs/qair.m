function y=qair(x)
% computes q matrix y given input x = [t rh]
t=x(:,1); % air temp
h=x(:,2); % rel hum (%) 
e=6.112.*exp(17.67.*t./(t+243.5)).*h/100;
y=e*622./(1010.0-.378*e);