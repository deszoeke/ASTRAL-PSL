function [yday] = md2yd_vn(year, month, day)
% calculates the Julian day given year, month and day
% vectorized version, 06-2015 BWB

day_tab = double([31,28,31,30,31,30,31,31,30,31,30,31; 31,29,31,30,31,30,31,31,30,31,30,31]);
% leap = 1 for non-leap year, 2 for leap year.
leap = or(and(mod(year,4)==0, mod(year,100)~=0), mod(year,400) == 0) + 1;
yday = day;
for ii = 1:length(month)
    for jj = 1:month(ii)-1
        yday(ii) = yday(ii) + day_tab(leap(ii),jj);
    end
end
