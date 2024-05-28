% calculates the month and day given year and Julian day
function [month,day] = yd2md(  year,  yearday)
day_tab=[31,28,31,30,31,30,31,31,30,31,30,31; 31,29,31,30,31,30,31,31,30,31,30,31];

leap = (mod(year,4) == 0 && mod(year,100) ~= 0 || mod(year,400) == 0) + 1;
i = 1;
while yearday > day_tab(leap,i)
    yearday = yearday - day_tab(leap,i);
    i = i + 1;
end
month = i;
day = yearday;

end
