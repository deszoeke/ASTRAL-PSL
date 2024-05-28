function [jdav,y,yvar]=tmave_2(jd,dta,x)

% disp('time_ave');
[nx mx]=size(x);%assumes nx is the time dimension  x(t,1:mx)
nt=24*60/dta;%number of values in a day
tx=0:nt;
tx=tx/24;
ds=jd(1);
N=length(jd);
de=jd(N);
jdint=floor(jd);
count=1;
ijd=floor(ds);
j=0;
while count<N+1;
   ii=find(jdint==ijd);
   for i=1:nt
      jj=find((jd(ii)-ijd)>tx(i) & (jd(ii)-ijd)<tx(i+1));
      j=j+1;
      jda(j)=ijd+tx(i);
      if isempty(jj)
         xave(j,1:mx)=NaN;
         xvar(j,1:mx)=NaN;
      else
         xave(j,1:mx)=mean(x(ii(jj),1:mx));
         xvar(j,1:mx)=var(x(ii(jj),1:mx));
      end;
   end;
   ijd=ijd+1;
   if ~isempty(ii)
      count=count+length(ii);
   end;
end;
jdav=jda';
y=xave;
yvar=xvar;

