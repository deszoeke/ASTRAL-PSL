function output = relwind_wrap(input)

output = input;
wh_more = input > 180;
output(wh_more) = input(wh_more)-360;
