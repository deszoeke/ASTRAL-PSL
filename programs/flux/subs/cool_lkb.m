function y=cool_lkb(x)
%x=[6.3 0 28.7 26 24.2 18.5 141 419 0 600 1010 15 15 15];
u=x(1);
us=x(2);
ts=x(3);
t=x(4);
Qs=x(5)/1000;
Q=x(6)/1000;
Rs=x(7);
Rl=x(8);
rain=x(9);
zi=x(10);
P=x(11);
zu=x(12);
zt=x(13);
zq=x(14);

     %***********   set constants *************
     Beta=1.25;
     von=0.4;
     fdg=1.00;
     tdk=273.16;
     grav=9.72;
     %*************  air constants ************
     Rgas=287.1;
     Le=(2.501-.00237*ts)*1e6;
     cpa=1004.67;
     cpv=cpa*(1+0.84*Q);
     rhoa=P*100/(Rgas*(t+tdk)*(1+0.61*Q));
     visa=1.325e-5*(1+6.542e-3*t+8.301e-6*t*t-4.8e-9*t*t*t);
     %************  cool skin constants  *******
     Al=2.1e-5*(ts+3.2)^0.79;
     be=0.026;
     cpw=4000;
     rhow=1022;
     visw=1e-6;
     tcw=0.6;
     bigc=16*grav*cpw*(rhow*visw)^3/(tcw*tcw*rhoa*rhoa);
     wetc=0.622*Le*Qs/(Rgas*(ts+tdk)^2);
     
     %**************  compute aux stuff *******
     Rns=Rs*.945;
     Rnl=0.97*(5.56e-8*(ts+tdk)^4-Rl);
     
     %***************   Begin bulk loop *******
     
     %***************  first guess ************
     du=u-us;
     dt=ts-t-.0098*zt;
     dq=Qs-Q;
     ta=t+tdk;
     ug=.5;
     ut=sqrt(du*du+ug*ug);
     usr=.035*ut;
     tsr=-.035*dt;
     qsr=-.035*dq;
     dter=0;
     tkt=.001;
     Rib=-grav*zu/ta*(dt+.61*ta*dq)/ut^2;
     
     %disp(usr)
     
     %***************  bulk loop ************
     for i=1:20
     
     zet=von*grav*zu/ta*(tsr+.61*ta*qsr)/(usr*usr);
      %disp(usr)
      %disp(zet)
     zo=0.011*usr*usr/grav+0.11*visa/usr;
     rr=zo*usr/visa;
     if rr<=.11,
     rt=.177;
     rq=.292;
     elseif rr<=.8,
     rt=1.376*rr^.929;
     rq=1.808*rr^.826;
     elseif rr<=3.0,
     rt=1.026*rr^(-.599);
     rq=1.393*rr^(-.528);
     elseif rr<=10.0,
     rt=1.625*rr^(-1.018);
     rq=1.956*rr^(-.870);
     elseif rr<=30.0,
     rt=4.661*rr^(-1.475);
     rq=4.994*rr^(-1.297);
     elseif rr<=100.0,
     rt=34.904*rr^(-2.067);
     rq=30.709*rr^(-1.845);
     elseif rr<=300.0,
     rt=1667.19*rr^(-2.907);
     rq=1448.68*rr^(-2.682);
     elseif rr<=1000.0,
     rt=5.88e5*rr^(-3.935);
     rq=2.98e5*rr^(-3.616);
     elseif rr>1000.0,
     rt=5.88e5*1000^(-3.935);
     rq=2.98e5*1000^(-3.616);
     end;
     
     L=zu/zet;
     zot=rt*visa/usr;
     zoq=rq*visa/usr;
     usr=ut*von/(log(zu/zo)-psiu(zu/L));
     tsr=-(dt-dter)*von*fdg/(log(zt/zot)-psit(zt/L));
     qsr=-(dq-wetc*dter)*von*fdg/(log(zq/zoq)-psit(zq/L));
     Bf=-grav/ta*usr*(tsr+.61*ta*qsr);
     if Bf>0
     ug=Beta*(Bf*zi)^.333;
     else
     ug=.2;
     end;
     ut=sqrt(du*du+ug*ug);
     hsb=-rhoa*cpa*usr*tsr;
     hlb=-rhoa*Le*usr*qsr;
     qout=Rnl+hsb+hlb;
     dels=Rns*(.137+11*tkt-6.6e-5/tkt*(1-exp(-tkt/8.0e-4))); 	% Eq.16 Shortwave
     qcol=qout-dels;
     if qcol>0;
     alq=Al*qcol+be*hlb*cpw/Le;					% Eq. 7 Buoy flux water
     xlamx=6/(1+(bigc*alq/usr^4)^.75)^.333;			% Eq 13 Saunders
     tkt=xlamx*visw/(sqrt(rhoa/rhow)*usr);			%Eq.11 Sub. thk
     dter=qcol*tkt/tcw;%  Eq.12 Cool skin
             else
     dter=0;
         end;
     dqer=wetc*dter;
     
     end;%bulk iter loop
     tau=rhoa*usr*usr*du/ut;                %stress
     
     %****************   rain heat flux ********
     
      dwat=2.11e-5*((t+tdk)/tdk)^1.94;%! water vapour diffusivity
      dtmp=(1.+3.309e-3*t-1.44e-6*t*t)*0.02411/(rhoa*cpa); 	%!heat diffusivity
      dqs_dt=Q*Le/(Rgas*(t+tdk)^2);                        	%!Clausius-Clapeyron
      alfac= 1/(1+0.622*(dqs_dt*Le*dwat)/(cpa*dtmp));      	%! wet bulb factor
      RF= rain*alfac*cpw*((ts-t-dter)+(Qs-Q-dqer)*Le/cpa)/3600;
     %****************   Webb et al. correection  ************
     wbar=1.61*hlb/rhoa/Le+(1+1.61*Q)*hsb/rhoa/cpa/ta;
     hl_webb=wbar*Q*Le;
     %**************   compute transfer coeffs relative to du @meas. ht **********
     Cd=tau/rhoa/du^2;
     Ch=-usr*tsr/du/(dt-dter);
     Ce=-usr*qsr/(dq-dqer)/du;
     %************  10-m neutral coeff realtive to ut ********
     Cdn_10=von*von/log(10/zo)/log(10/zo);
     Chn_10=von*von*fdg/log(10/zo)/log(10/zot);
     Cen_10=von*von*fdg/log(10/zo)/log(10/zoq);
     
     y=[hsb hlb tau zo zot zoq L usr tsr qsr dter dqer tkt RF hl_webb Cd Ch Ce Cdn_10 Chn_10 Cen_10];