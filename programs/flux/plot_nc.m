%% Initialize run parameters
close all;
fclose all;
clear all;
warning ('off','MATLAB:MKDIR:DirectoryExists');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


theyr = 2019;

graphformat = '.png';  % select graphics format
graphdevice = '-dpng'; % select graphic device

Lonmin = 119; Lonmax = 139; Latmin = 4; Latmax = 23;
PosLims = [Lonmin, Lonmax, Latmin, Latmax];

if theyr == 2019
    cruise = 'PISTON_2019';  
    ptitle = 'PISTON 2019';
    ncdir = '/Users/eliz/DATA/PISTON_2019/Sally_Ride/flux/Processed/final/';
    ncname1 = 'PISTON-nav-met-sea-1min_RV-Sally-Ride_20190906_R1_thru_20190925.nc';
    ncname10 = 'PISTON-nav-met-sea-flux-10min_RV-Sally-Ride_20190906_R1_thru_20190925.nc';
    ncname60 = 'PISTON-nav-met-sea-flux-60min_RV-Sally-Ride_20190906_R1_thru_20190925.nc';
    plotdir = '/Users/eliz/DATA/PISTON_2019/Sally_Ride/flux/Processed_Images/nccheck/';
elseif theyr == 2018
    cruise = 'PISTON_2018';   
    ptitle = 'PISTON 2018';
    ncdir = '/Users/eliz/DATA/PISTON_2018/TGT/flux/final/';
    ncname1 = 'PISTON-nav-met-sea-1min_RV-Thompson_20180819_R1_thru_20181012.nc';
    ncname10 = 'PISTON-nav-met-sea-flux-10min_RV-Thompson_20180819_R1_thru_20181012.nc';
    ncname60 = 'PISTON-nav-met-sea-flux-60min_RV-Thompson_20180819_R1_thru_20181012.nc';
    plotdir = '/Users/eliz/DATA/PISTON_2018/TGT/flux/Processed_Images/nccheck/';
end

% assign all variables to matlab structures
clear f1 f10 f60;
for k = 1:3
    if k == 1
        thestr = 'f1';
        ncname = ncname1;
    elseif k == 2
        thestr = 'f10';
        ncname = ncname10;
    elseif k == 3
        thestr = 'f60';
        ncname = ncname60;
    end
    
    ncload2([ncdir '/' ncname]);
    finfo = ncinfo([ncdir '/' ncname]);
    % % disp(finfo);
    f_names = {finfo.Variables.Name};
    nf = length(f_names);
    for i = 1:nf
        eval([ thestr '.' f_names{i} ' = ' f_names{i} ';']); % saves variables in structure $thestr.$var
        eval(['clear ' f_names{i} ';']); % clears all the variables loaded automatically by ncload2
    end
    
    eval([ thestr '.t = datenum(theyr,1,1,0,0,' thestr '.time);']); % matlab datetime
end


%% use 10 min file as basis for making plots and populating plot fields
thef = fields(f10);
nf = length(thef);

vartypes = cell(nf,1);
var_names = thef;
drow = nan(nf,1);
dcol = nan(nf,1);
for i = 1:nf
    eval(['thisvar = f10.' thef{i} ';']);
    vartype = class(thisvar);
    vartypes(i) = {vartype};
    [drow(i), dcol(i)] = size(thisvar);
    if contains(string(thef(i)), '_') == 1
        var_names(i) = {strrep(string(thef(i)),'_',' ')};
    end
end


%% check the files with plots
plot_map = 1;
if plot_map == 1
    map_all_cruise(f10.lon,f10.lat,ptitle,PosLims)
    annotation(gcf,'textbox',[0.007154 0.01077 0.4498 0.02462],'String',{'NOAA PSL'},'FontSize',10,'FitBoxToText','off','LineStyle','none');
    print(graphdevice,[plotdir cruise '_TrackMap'  graphformat]);
end

plot_all = 0;
if plot_all == 1
   
clear i j;
    
figure('position',[100 100 1200 600]);

%%% 1-D time fields
counter = 1;
for i = 1:4:nf
    clf;
    for j = 1:4
       if (i+j-1) <= nf
%            disp(['i = ' sprintf('%i',i) '; j= ' sprintf('%i',j) '; var = ' var_names{i+j-1}]);
           subplot(2,2,j); hold on;
           if isfield(f1,thef{i+j-1}) == 1
                plot(f1.t, f1.(thef{i+j-1}),'x');
           end
           plot(f10.t, f10.(thef{i+j-1}),'o');
           plot(f60.t, f60.(thef{i+j-1}),'.');
           title([ptitle ' ' char(var_names{i+j-1})]);
           xlim([min(f10.t) max(f10.t)]);
           datetick('x','mm/dd','keeplimits');
           grid on;
           
           if j == 1
               
               if isfield(f1,thef{i+j-1}) == 1
                   legend('1-min','10-min','60-min','location',[0.465,0.48, 0.05, 0.05],'box','on');
               else
                   legend('10-min','60-min','location',[0.465,0.48, 0.05, 0.05],'box','on');
               end
           
           end
           
       end
   end
   print(graphdevice,[plotdir 'check_' sprintf('%i',counter) '_' cruise graphformat]);
   counter = counter + 1;
end    

end
    