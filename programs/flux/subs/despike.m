function [uu,N]=despike(uz)

% returns despiked vector uu, detects spikes over 4 sigma
% edit criterion below if desired
% modified to return the number of spikes removed, 10/2014  BWB

N = 0;  % initial value for number of spikes

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

% create sorted data matrix, low to high
% and compute median (mu)
uu2=sortrows(uz,1);
uu=uu2(1:np,1);
mp=floor(np/2);
mu=uu(mp);

% compute sigma u
sp=floor(.84*np);
sm=floor(.16*np);
sig=(uu(sp)-uu(sm))/2;

% set despike criterion
dsig=max(4*sig,.5);

% number of neg spikes
im=1;
while abs(mu-uu(im))>dsig;
   im=im+1;
end;

% number of pos spikes
ip=np;
while abs(uu(ip)-mu)>dsig;
   ip=ip-1;
end;

% percent bad data
pct=(im+np-ip)/np*100;
N = (im+np-ip);         % number of bad points
%disp(['total spikes= ' num2str(pct) ' %    median=  ' num2str(mu) '  sigma= ' num2str(sig)] );

% NaN bad points and resort to original order
uu2(1:im,1)=NaN;
uu2(ip:np,1)=NaN;
uy=sortrows(uu2,2);

% find NaNs and substitute a nearest neighbor
ii=find(isnan(uy)); ab=length(ii);
if ~isempty(ii)
    uy(ii(2:ab))=uy(ii(2:ab)-1);
    if ii(1)>1
        uy(ii(1))=uy(ii(1)-1);
    else
        uy(ii(1))=uy(ii(1)+1);
    end;
end;

% do it again to eliminate double spikes
ii=find(isnan(uy)); ab=length(ii);
if ~isempty(ii)
    uy(ii(2:ab))=uy(ii(2:ab)-1);
    if ii(1)>1
        uy(ii(1))=uy(ii(1)-1);
    else
        uy(ii(1))=uy(ii(1)+1);
    end;
end;

% do it again to eliminate triple spikes
ii=find(isnan(uy)); ab=length(ii);
if ~isempty(ii)
    uy(ii(2:ab))=uy(ii(2:ab)-1);
    if ii(1)>1
        uy(ii(1))=uy(ii(1)-1);
    else
        uy(ii(1))=uy(ii(1)+1);
    end;
end;

% return result
if a==1
    uu=uy(1:np,1);
else
    uu=uy(1:a,1)';
end


