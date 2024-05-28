function [jdav,v1,thet1]=tmave_vec1(jd,dta,v,thet)
%does vector average of magnitude (v) and angle (thet, in degrees)
%disp('time_ave');
clear jdav v1 thet1 nn
nt=24*60/dta;%number of values in a day
rats=pi/180;%degr to radian conversion factor
tx=0:nt;
tx=tx/nt;
ds=jd(1);
N=length(jd);
de=jd(N);
jdint=floor(jd);
count=1;
ijd=floor(ds);
j=0;
c1=v.*cos(thet*rats);
c2=v.*sin(thet*rats);

while count<N+1;
   ii=find(jdint==ijd);
   for i=1:nt
      kk=find((jd(ii)-ijd)>=tx(i) & (jd(ii)-ijd)<tx(i+1));
      j=j+1;
      jda(j)=ijd+tx(i);
      if isempty(kk)
         c1ave(j)=NaN;
         c2ave(j)=NaN;
         nn(j)=0;
      else
         nn(j)=length(kk); 
         if nn(j)==1
            c1ave(j)=c1(ii(kk),:);
            c2ave(j)=c2(ii(kk),:);
         else
            c1ave(j)=nanmean1(c1(ii(kk),:));
            c2ave(j)=nanmean1(c2(ii(kk),:));
         end;
         
		end;
   end;
   ijd=ijd+1;
   if ~isempty(ii)
      count=count+length(ii);
   end;
end;
jdav=jda';
v1=sqrt(c1ave.*c1ave+c2ave.*c2ave);
thet1=atan2(c2ave,c1ave)/rats;

