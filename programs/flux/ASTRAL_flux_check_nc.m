%%% Program to check netcdf file contents for PISTON 2018-2019 by making plots 
%%% there was uncertainty in coare 36 _et and b versions... which should be
%%% the same. So, tests are done with COARE at the end. 

%%% Aug 2022

clear all;
close all

cruise = 'ASTRAL_2024';
project = 'ASTRAL';
% ship = 'Thompson';
ship = 'PSL'
theyear = 2024;
yrstr = '2024';

% thedir = ['/Users/ethompson/DATA/' cruise '/' ship '/flux/Processed/final'];
% ncname1= '/Users/ethompson/DATA/ASTRAL_2024/Thompson/flux/Processed/final/ASTRAL-nav-met-sea-1min_RV-Thompson_20240428_R1_thru_20240513.nc';
% ncname10= '/Users/ethompson/DATA/ASTRAL_2024/Thompson/flux/Processed/final/ASTRAL-nav-met-sea-flux-10min_RV-Thompson_20240428_R1_thru_20240513.nc';
% ncname60= '/Users/ethompson/DATA/ASTRAL_2024/Thompson/flux/Processed/final/ASTRAL-nav-met-sea-60min_RV-Thompson_20240428_R1_thru_20240513.nc';

thedir = fullfile('/Users/deszoeks/Data/ASTRAL_2024/PSL/flux/Processed/final/');
ncname1 =  fullfile(thedir, 'ASTRAL-nav-met-sea-1min_RV-PSL_20240428_R1_thru_20240609.nc');
ncname10 = fullfile(thedir, 'ASTRAL-nav-met-sea-flux-10min_RV-PSL_20240428_R1_thru_20240609.nc');

plotdir = fullfile('/Users/deszoeks/Data/', cruise, ship, '/flux/Processed_Images/nccheck/');
mkdir(plotdir);

restoredefaultpath
cd(fullfile(     '/Users/deszoeks/Projects',project, ship, '/programs/flux/'));
addpath(fullfile('/Users/deszoeks/Projects',project, ship, '/programs/flux/subs/'));
rehash toolboxcache;


graphformat = '.png';  % select graphics format
graphdevice = '-dpng'; % select graphic device
% matlab script path

% cd(fullfile(path_prog,'flux'));


%% read in all the files and save as structures
for j = 1:2
    
    clear f;
    if j == 1
        ffile = ncname1;
    elseif j == 2
        ffile = ncname10;
    elseif j == 3
        ffile = ncname60;
    end
    ncload2(ffile);
    % ncdisp(ffile);
    finfo = ncinfo(ffile);
    fnames = {finfo.Variables.Name};
    % other options in finfo: Attributes, Dimensions, Variables, Format, Filename

    % ncload2 loads all variables in a netcdf file by variable name.
    % Since multiple files have similar variables like time...
    % Load all the variables from the flux file into a structure f, i.e.  
    % f.$variable_name, and then clear the variable name from the workspace
    nf = length(fnames);
    for i = 1:nf
        eval(['f.' fnames{i} ' = ' fnames{i} ';']);
        eval(['clear ' fnames{i} ';']);
    end
    f = orderfields(f);
    f.t = datenum(theyear,1,1,0,0,f.time);
    display(['time:' datestr(min(f.t),0) ' thru ' datestr(max(f.t),0)]);
    
    if j == 1
        f1 = f;
    elseif j == 2
        f10 = f;
    elseif j == 3
        f60 = f;
    end
    clear f;
end

% %%% weird diurnal warm layer disagreement... 60-min dwl is EXTRA
% xW =[datenum(2019,9,6,0,0,0), datenum(2019,9,13,0,0,0)];

%% Make plots of all the data: 1, 10, 60, min

check_dwl = 0;

plot_check_all_times = 1;
if plot_check_all_times == 1
    figure;
    counter = 1;
    thefields = fields(f10);
    nc = length(thefields);
    for i = 1:4:nc
        clf;
        for j = 1:4
           if (i+j-1) <= nc
               subplot(2,2,j); hold on;
%                plot(f60.t, f60.(thefields{i+j-1}),'o','markersize',9);
               plot(f10.t, f10.(thefields{i+j-1}),'x');
               if isfield(f1,thefields{i+j-1}) == 1 
                    plot(f1.t, f1.(thefields{i+j-1}),'.k','markersize',3);
               end
               grid on;
               var_name = {strrep(thefields{i+j-1},'_',' ')};
               title(var_name);
               if check_dwl == 1
                   xlim(xW);
                   dwl_str = 'dwl_';
               else
                   xlim([min(f10.t) max(f10.t)]);
                   dwl_str = '';
               end
               datetick('x','mm/dd','keeplimits');
               grid on;
           end
        end
       legend('10','1','position',[0.5,0.5,0.001,0.001],'box','off');
       print(graphdevice,[plotdir cruise '_check_' dwl_str sprintf('%i',counter)  graphformat]);
       counter = counter + 1;
    end  % for all vars
end %%% if making plots


%% check coare before/now... 


plot_check_coare = 0;
if plot_check_coare == 1
    
    clear g10;

    zu = 18;
    ztq = 15.34;
    zsnk = 0.05;

    f10.jd = f10.t - datenum(2018,0,0,0,0,0);

    B = coare36bvnWarm(f10.jd, f10.wspd_sfc, zu, f10.tair, ztq, f10.rhair, ztq,...
                 f10.psealevel, f10.tsea, f10.sw_down, f10.lw_down, f10.lat, f10.lon, 100,...
                 f10.prate, zsnk, f10.ssea_ship, nan, nan, 2, 2, 2);

    cfields = {'ustar';'tau_bulk';'hs_bulk';'hl_bulk';'hb_bulk';'hb_son';'hl_webb';'tstar';'qstar';...
        'rough_u';'rough_t';'rough_q';...
        'cd';'ch';'ce';'mo_length';'zeta';'dt_skin';'dq_skin';'dz_skin';'wspd_2';'tair_2';'qair_2';...
        'rhair_2';'wspd_2N';'tair_2N';'qair_2N';'lw_net';'sw_net';'Le';'rhoair';...
        'wspd_N';'wspd_10';'wspd_10N';'cd10N';'ch10N';'ce10N';...
        'hrain';'qskin';'erate';'tair_10';'tair_10N';'qair_10';'qair_10N';'rhair_10';'pair_10';...
        'rhoair_10';'gust';'wave_whitecap_frac';'wave_edis';...
        'dt_warm';'dz_warm';'dt_warm_to_skin';'du_warm'};

    for i = 1:length(cfields)
        eval(['g10.' cfields{i} '   = B(:,i);']);
    end


    % interface
    g10.tskin       = f10.tsea + g10.dt_warm_to_skin - g10.dt_skin;

    % recalculate upwelling radiative fluxes
    g10.lw_up       = g10.lw_net - f10.lw_down;
    g10.sw_up       = g10.sw_net - f10.sw_down;

    % net heat flux: heating into the ocean (use minus sign if fluxes haven't
    % been flipped yet!)
    g10.hnet        = g10.sw_net + g10.lw_net - g10.hs_bulk - g10.hl_bulk - g10.hrain;

    %%% option: sign changes of COARE fields... the bulk sensible, latent, and rain
    %%% fluxes are defined positive by COARE, but we don't provide them to others that way
    flips = {'hs_bulk';'hl_bulk';'hrain'};
    for k = 1:length(flips)
        eval(['g10.' flips{k} ' = - g10.' flips{k} ';']);
    end

    figure;
    subplot(3,1,1);
    plot(f10.t, f10.cd10N,'o', f10.t, g10.cd10N,'.');
    datetick('x','mm/dd','keeplimits');
    grid on;
    legend('et','b','location','best');
    title([yrstr ' cd10N']);

    subplot(3,1,2);
    plot(f10.t, f10.ce10N,'o', f10.t, g10.ce10N,'.');
    xlim([min(f10.t), max(f10.t)]);
    datetick('x','mm/dd','keeplimits');
    grid on;
    title([yrstr ' ce10N']);

    subplot(3,1,3);
    plot(f10.t, f10.ch10N,'o', f10.t, g10.ch10N,'.');
    datetick('x','mm/dd','keeplimits');
    grid on;
    title([yrstr ' ch10N']);

    print(graphdevice,[plotdir cruise '_check_n10coeff' graphformat]);

    %%%

    figure;
    subplot(1,3,1);
    plot(f10.cd10N, g10.cd10N,'o');
    axis square; grid on;
    hold on; 
    plot(xlim, xlim, '--y');
    xlabel('et');
    ylabel('b');
    title([yrstr ' cd10N']);

    subplot(1,3,2);
    plot(f10.ce10N, g10.ce10N,'o');
    axis square; grid on;
    hold on; 
    plot(xlim, xlim, '--y');
    xlabel('et');
    ylabel('b');
    title([yrstr ' ce10N']);

    subplot(1,3,3);
    plot(f10.ch10N, g10.ch10N,'o');
    axis square; grid on;
    hold on; 
    plot(xlim, xlim, '--y');
    xlabel('et');
    ylabel('b');
    title([yrstr ' ch10N']);

    print(graphdevice,[plotdir cruise '_check_n10coeff_scatter' graphformat]);
    
end