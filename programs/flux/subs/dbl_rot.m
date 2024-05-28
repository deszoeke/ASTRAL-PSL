function [uvw_str,azm,tilt]=dbl_rot(uvw)
% double angle rotation to achieve mean V = 0 and mean W = 0
% rotates the components of flow into streamline of flow experienced by
% sonic - ustream, vstream, wstream in the stream-wise coord system. In
% that coord system, mean v = 0 and mean w = 0. mean u = ~ Sb. 
% This is the old way of doing this. 

u = uvw(:,1);
v = uvw(:,2);
w = uvw(:,3);
Ub = mean(u);
Vb = mean(v);
Wb = mean(w);
Sb = sqrt(Ub^2+Vb^2);
%disp(['Relative 1-hr U = ',num2str(Sb),'  [m/s]'])
%disp(['TRUE Wind From North = ',num2str(-Un),' [m/s]    From West = ',num2str(Ue),' [m/s]     Dir = ',num2str(Twindir)]),
tilt = atan2(Wb,Sb);
azm = atan2(Vb,Ub);
%disp(['Tilt = ',num2str(telt*180/pi),' deg   Azmiuth = ',num2str(azm*180/pi),' deg'])
Ustream=+u*cos(azm)*cos(tilt)+v*sin(azm)*cos(tilt)+w*sin(tilt);
Vstream=-u*sin(azm)+v*cos(azm);
Wstream=-u*cos(azm)*sin(tilt)-v*sin(azm)*sin(tilt)+w*cos(tilt);
uvw_str = [Ustream Vstream Wstream];
