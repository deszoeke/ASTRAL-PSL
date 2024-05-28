function [wspd, wdir] = sw_wind(u, v)

ni = length(u);

% make a nan array of wdir in whatever the oriention is of inputs
wdir = u*nan;
alpha = u*nan;
    
% quadrant 1
wh_q1 = find(u > 0 & v > 0);
alpha(wh_q1) = atand(v(wh_q1)./u(wh_q1));
alpha(wh_q1) = (90-alpha(wh_q1));

% quadrant 2
wh_q2 = find(u > 0 & v <= 0);
alpha(wh_q2) = atand(u(wh_q2)./v(wh_q2));
alpha(wh_q2) = (180+alpha(wh_q2));

% quadrant 3
wh_q3 = find(u <= 0 & v <= 0);
alpha(wh_q3) = atand(v(wh_q3)./u(wh_q3));
alpha(wh_q3) = (270-alpha(wh_q3));

% quadrant 4
wh_q4 = find(u <= 0 & v > 0);
alpha(wh_q4) = atand(u(wh_q4)./v(wh_q4));
alpha(wh_q4) = (360+alpha(wh_q4));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

wdir = alpha+180;
find_pos = find(wdir >= 360);
wdir(find_pos) = wdir(find_pos) - 360;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

wh_fnorth   = find(u == 0 & v < 0);
wh_fsouth   = find(u == 0 & v > 0);
wh_feast    = find(u < 0 & v == 0);
wh_fwest    = find(u > 0 & v == 0);
wh_fnowhere = find(u == 0 & v == 0);

wdir(wh_fnorth) = 0;
wdir(wh_fsouth) = 180;
wdir(wh_fwest) = 270;
wdir(wh_feast) = 90;
wdir(wh_fnowhere) = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

wspd = sqrt(u.^2 + v.^2);

% for i = 1:length(u)
%     wspd(i) = sqrt(u(i)^2 + v(i)^2);
% end