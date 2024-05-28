clear all;
close all;

thedir = '/Users/eliz/DATA/PISTON_2019/Sally/ship/adcp/';
ncname = 'piston-WH300_RV-Sally-Ride_20190904_R0.nc';
matname = 'piston-WH300_RV-Sally-Ride_20190904_R0.mat';

%   amp             14483x50            5793200  double              
%   depth           14483x50            5793200  double              
%   heading         14483x1              115864  double              
%   lat             14483x1              115864  double              
%   lon             14483x1              115864  double              
%   num_pings       14483x1              115864  double              
%   pflag           14483x50            5793200  double              
%   pg              14483x50            5793200  double              
%   time            14483x1              115864  double              
%   tr_temp         14483x1              115864  double              
%   trajectory          1x1                   8  double              
%   u               14483x50            5793200  double              
%   uship           14483x1              115864  double    speed of ship m/s          
%   v               14483x50            5793200  double              
%   vship           14483x1              115864  double    speed of ship m/s

ncload2([thedir ncname]);
finfo = ncinfo([thedir ncname]);
% disp(vinfo);
f_names = {finfo.Variables.Name};
nf = length(f_names);
for i = 1:nf
    eval(['f.' f_names{i} ' = ' f_names{i} ';']);
%     eval(['f_' f.names{i} ' = ' f.names{i} ';']);
    eval(['clear ' f_names{i} ';']);
end
a = f;
a.t = a.time+datenum(2019, 1, 1, 0, 0, 0);

a.badu = find(a.u > 2);
a.badv = find(a.v > 2);

a.uC = a.u;
a.uC(a.badu) = nan;

a.vC = a.v;
a.vC(a.badv) = nan;

a.usfc = a.t*nan;
a.vsfc = a.t*nan;

for i = 1:length(a.t)
    a.usfc(i) = nanmean(a.uC(i,1:3));
    a.vsfc(i) = nanmean(a.vC(i,1:3));
end

a.usfc_fill = fillmissing(a.usfc,'linear');
a.vsfc_fill = fillmissing(a.vsfc,'linear');

save([thedir matname], 'a');