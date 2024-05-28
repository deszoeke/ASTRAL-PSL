function [uu,N]=despike2(uz)

% returns despiked vector uu, detects spikes over 4 sigma or greater
% than alt from the median value
% modified to return the number of spikes removed, 10/2014  BWB

%% initialize
N = 0;  % initial value for number of spikes

if all(isnan(uz))
    uu = uz;
    N = length(uz);
    return
end;

%% create 2-col matrix with data in c1 and index in c2
[np,a]=size(uz);
if a==1;
    ux=1:np;
    uz=[uz ux'];
else
    np=a;
    ux=1:a;
    uz=[uz' ux'];
end;

%% create sorted data matrix, low to high
% and compute median (mu)
uu2=sortrows(uz,1);
uu=uu2(1:np,1);
mp=floor(np/2);
mu=uu(mp);

%% compute sigma u
sp=floor(.84*np);
sm=floor(.16*np);
sig=(uu(sp)-uu(sm))/2;

% set despike criterion
dsig=4*sig;

% number of neg spikes
im=1;
while abs(mu-uu(im))>dsig;
   im=im+1;
end;

% number of pos spikes
ip=np;
while abs(uu(ip)-mu)>dsig || isnan(uu(ip));
   ip=ip-1;
end;

% percent bad data
pct=(im+np-ip)/np*100;
N = (im+np-ip);         % number of bad points
%disp(['total spikes= ' num2str(pct) ' %    median=  ' num2str(mu) '  sigma= ' num2str(sig)] );

%% NaN bad points and resort to original order
uu2(1:im,1)=NaN;
uu2(ip:np,1)=NaN;
uy=sortrows(uu2,2);

uyy = replace_NaN_nearest_neighbor(uy(:,1));

% return result
if a==1
    uu=uyy(1:np);
else
    uu=uyy(1:a)';
end


