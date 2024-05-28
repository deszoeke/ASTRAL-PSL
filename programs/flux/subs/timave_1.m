function [jdav,y,yvar,nn] = timave_1(jd,dta,yx)

% disp('time_ave');
clear jdav y xave xvar nn
[nx mx] = size(yx); % assumes nx is the time dimension  yx(t,1:mx)
nt = 24*60/dta; % number of values in a day
tx = 0:nt;
tx = tx/nt;
ds = jd(1);
N = length(jd);
de = jd(N);
jdint = floor(jd);
count = 1;
ijd = floor(ds);
j = 0;
while count<N+1;
   ii = find(jdint==ijd);
   for i=1:nt
      kk = find(((jd(ii)-ijd)>=tx(i)) & ((jd(ii)-ijd)<tx(i+1)));
      j = j+1;%increment ave time step
      jda(j) = ijd+tx(i);
      if isempty(kk)
         xave(j,1:mx) = NaN;
         xvar(j,1:mx) = NaN;
         nn(j) = 0;
      else
         nn(j)=length(kk); 
         if nn(j)==1
            xave(j,1:mx) = yx(ii(kk),1:mx);
            xvar(j,1:mx) = 0;
         else
            xave(j,1:mx) = nanmean1(yx(ii(kk),1:mx));
            xvar(j,1:mx) = nanvar1(yx(ii(kk),1:mx));
         end;
      end;
   end;
   ijd = ijd+1;%increment julian day
   if ~isempty(ii)
      count = count+length(ii);
   end;
end;
jdav = jda';
y = xave;
yvar = xvar;

