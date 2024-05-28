function plot_1min_10min(f, g, path_raw_images)
%%% function to read in 1 day of met, seawater, flux data and make plots
%%% that are normally produced by run_motcoor.m program. Function reads in
%%% the daily matlab structure ff produced by this program. 
%%% 
%%% EJT Jan 2020
%%%
%%% input: 
%%%     ff      = structure with data and metadata used for plotting

%%% Notes: 
%%%     WXT is ignored for now
%%%

%% plot info
%% get date, time, cruise info
the_jd = floor(f.jd(1));
[the_yr, the_mo, the_day, the_hr, the_min, the_sec] = datevec(f.t(1));
cruise = [f.cruise_str '_' sprintf('%i',the_yr)];

graphformat = '.png';  % select graphics format
graphdevice = '-dpng'; % select graphic device
date_st = sprintf('%04i_%02i_%02i_%03i',the_yr,the_mo,the_day,the_jd);
ppath = fullfile(path_raw_images,'check',['check_' date_st ]);

%% make plots to check file

fq = fields(f);
nf = length(fq);
ntime = length(f.t);

vartypes = cell(nf,1);
var_names = fq;
drow = nan(nf,1);
dcol = nan(nf,1);
for i = 1:nf
    eval(['thisvar = f.' fq{i} ';']);
    vartype = class(thisvar);
    vartypes(i) = {vartype};
    [drow(i), dcol(i)] = size(thisvar);
    if contains(string(fq(i)), '_') == 1
        var_names(i) = {strrep(string(fq(i)),'_',' ')};
    end
end

dt = find(dcol == 1 & drow == ntime);
nd = length(dt);
disp([' out of ' sprintf('%i',nf) ' total vars, ' sprintf('%i',nd) ' are counted in time']);


figure;
%%% 1-D time fields
counter = 1;
for i = 1:4:length(dt)
    clf;
    for j = 1:4
       if (i+j-1) <= length(dt)
           subplot(2,2,j); hold on;
           plot(f.t, f.(fq{dt(i+j-1)}),'o');
           plot(g.t, g.(fq{dt(i+j-1)}),'x');
           title(var_names(dt(i+j-1)));
           datetick('x','mm/yyyy','keeplimits');
           grid on;
       end
    end
   print(graphdevice,[ppath sprintf('_%i',counter) graphformat]);
   counter = counter + 1;
end

