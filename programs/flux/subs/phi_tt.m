function phix=phiq(zet)
%modified 3/19/98 to allow vector input/output by Peter Guest 

%stable cases
x = 1+4.7*zet;
phix = x*3.5;
	

%unstable cases
        uns=find(zet<0);    % &zet>-.2
        if ~isempty(uns);
            y=1./(1-25.*zet(uns)).^.333;
            phix(uns)=y*3.5;
           
        end; 
     
