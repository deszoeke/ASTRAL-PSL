function y=qair_p(t, rh, p)
% computes air specific humidity given input of air values of t rh p. 
% Ideally, values shoudl be measured or scaled to the same height.
% function is derived by calculating saturation vapor pressure, e, for the input values

% t =  temp, deg C
% rh = relative humidity, %
% p = pressure, mb

% in case there is a row vs. height issue:
% [nrow, ncol] = size(x);
% disp(nrow);
% disp(ncol);
% if ncol > nrow
%     t=x(:,1); % air temp
%     h=x(:,2); % rel hum (%) 
%     p=x(:,3); % pressure mb
% else
%     t=x(1,:); % air temp
%     h=x(2,:); % rel hum (%) 
%     p=x(3,:); % pressure mb
% end

e=6.112.*exp(17.67.*t./(t+243.5)).*rh/100;
y=e*622./(p-.378*e);