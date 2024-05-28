% da_red.m - process manual flux and motcorr output data.
% Save filtered output in 10 min and hourly flux files.
% Create analysis and diagnostic plots in separate program: plot_da_red.m
% joke: "da" means "don't ask" ;) and we don't know what red means. It
% might have used to mean read. 


% RUN THIS SCRIPT AFTER RUNNING run_motcorr.m

%% initialize & set matlab script path for your system
close all;
clear all;
warning ('off','MATLAB:MKDIR:DirectoryExists');
setup_cruise;

%% set system specific paths
% edit these as necessary for your system
% data drive is the root directory for cruise data
% path prog is the directory of matlab scripts for this project
% system specific path defs
sysType = computer;
username=char(java.lang.System.getProperty('user.name'));
if strncmp(sysType,'MACI64',7)     % set Mac paths
    data_drive = '/Users/ethompson/DATA/';
    path_prog = fullfile(data_drive,cruise,ship,'Scientific_Analysis','programs');
elseif strncmp(sysType,'PCWIN64',7)  % set PSD DAC paths
    data_drive = 'D:\DATA\';
    path_prog = fullfile(data_drive,cruise,ship,'Scientific_Analysis','programs');
end

% define path to 'Processed' folder with da files
path_proc_data = fullfile(data_drive,cruise,ship,'flux','Processed','final');
mkdir(path_proc_data); % create if it doesn't exist

% define paths to folders for saving da plots for this cruise leg
png_path = fullfile(data_drive,cruise,ship,'flux','Processed_Images','da_red');
mkdir(png_path); % create if it doesn't exist

% set matlab script path
restoredefaultpath
cd(fullfile(path_prog,'flux'));
addpath(genpath(fullfile(path_prog,'flux')));
rehash toolboxcache;

%% COARE options
jcool = 1;  % set to 1 to compute cool skin
jwarm = 0;  % set to 1 for warm layer estimate if using ship 5m TSG data
zref = 10;  % user defined reference height

%% data options
have_adcp_data = 0;
have_wxt_data = 0;

%% load 10-min data from prior processing
% load corrected 10-min data from manualflux_eval and fix_met_sea
file_b_in_version = 'v2';  
file_d_in_version = 'v1'; 
file_out_version = 'v2'; 

% 10-min corrected manfluxeval data and motcorr data
b_indir = [data_drive cruise '/' ship '/flux/Processed/' file_b_in_version '/'];
d_indir = [data_drive cruise '/' ship '/flux/Processed/motcorr/'];
e_outdir = [data_drive cruise '/' ship '/flux/Processed/final/'];

b10_infile  = [b_indir cruise '_10min_nav_met_sea_flux_' file_b_in_version '.mat'];  
b1_infile   = [b_indir cruise  '_1min_nav_met_sea_flux_' file_b_in_version '.mat'];  
d10_infile  = [d_indir cruise '_10min_motcorr_' file_d_in_version '.mat'];  
d1_infile   = [d_indir cruise  '_1min_motcorr_' file_d_in_version '.mat'];  

d10_outfile  = [d_indir cruise '_10min_motcorr_' file_d_in_version '_da.mat'];  
d1_outfile   = [d_indir cruise '_1min_motcorr_' file_d_in_version '_da.mat'];  


load(b10_infile);  % structure b10
load(b1_infile);   % structure b1
load(d10_infile);  % strcuture d10
load(d1_infile);   % strcuture d1

% output 10-min and 60-min (hourly) legacy text files
legacy_dir = [data_drive cruise '/' ship '/flux/Processed/legacy/decorr/'];
sname_10 = [cruise '_legacy_10min_' file_out_version];
sname_60 = [cruise '_legacy_60min_' file_out_version];

nt = length(b10.jd);

%% fixes

% % 1/27/2022 fixed for leaving out 1E-3 for qa unit conversion. Fixed in motcorr. Just need to rerun. 
% d10.wT_cov = ( d10.wTson_cov + 0.51*(b10.ta+C2K).*b10.usr.*b10.qsr) ./ (1 + 0.51*b10.qa*1E-3);
% d10.hs_cov = d10.wT_cov.* b10.rhoa * cpa;

%%

disp(['length of b1: ' sprintf('%i',length(b1.t))  ' starting with ' datestr(min(b1.t),0)]);
disp(['length of d1: ' sprintf('%i',length(d1.t))  ' starting with ' datestr(min(d1.t),0)]);
disp(['length of b10: ' sprintf('%i',length(b10.t))  ' starting with ' datestr(min(b10.t),0)]);
disp(['length of d10: ' sprintf('%i',length(d10.t))  ' starting with ' datestr(min(d10.t),0)]);

dtime1 = length(b1.t) - length(d1.t);
dtime10 = length(b10.t) - length(d10.t);
if dtime1 > 0

    disp(['missing points in d1 = ' sprintf('%i',dtime1)  ' = ' sprintf('%4.2f',dtime1/60) ' hours']);
    disp(['missing points in d10 = ' sprintf('%i',dtime10) ' = ' sprintf('%4.2f',dtime10/6) ' hours']);

    % pad d10 with half day of nan at end to match length of b10, if needed
    fmet = fields(d10);
    if strcmp(cruise,'ASTRAL_2023') == 1 
       disp('padding d10 with extra nans at beginning');
       for j = 1:length(fmet)
           if strcmp(fmet{j}, 'lag') ~= 1 && strcmp(fmet{j}, 'Fx') ~= 1 ...
                   && strcmp(fmet{j}, 't') ~= 1 && strcmp(fmet{j}, 'jd') ~= 1
                clear dim that this;
                this = d10.(fmet{j});
%                 disp(length(this));
                [l, dim] = size(this);
    %           disp(dim);
                for i = 1:dim
                    that = [nan(dtime10, 1); this(:,i)];
                end
                d10.(fmet{j}) = that;
%                 disp(length(that));
           end
        end
    end

    % pad d1 with half day of nan at end to match length of b1
    fmet = fields(d1);
    if strcmp(cruise,'ASTRAL_2023') == 1 
       disp('padding d1 with extra nans at beginning');
       for j = 1:length(fmet)
            if strcmp(fmet{j}, 't') ~= 1 && strcmp(fmet{j}, 'jd') ~= 1
                clear dim that this;
                this = d1.(fmet{j});
%                 disp(length(this));
                [l, dim] = size(this);
        %           disp(dim);
                for i = 1:dim
                    that = [nan(dtime1, 1); this(:,i)];
                end
                d1.(fmet{j}) = that;
%                 disp(length(that));
            end
       end
    end

    d1.t = [b1.t(1:dtime1); d1.t];
    d10.t = [b10.t(1:dtime10); d10.t];

    d1.jd = [b1.jd(1:dtime1); d1.jd];
    d10.jd = [b10.jd(1:dtime10); d10.jd];


    disp(['length of b1: ' sprintf('%i',length(b1.t))  ' starting with ' datestr(min(b1.t),0)]);
    disp(['length of d1: ' sprintf('%i',length(d1.t))  ' starting with ' datestr(min(d1.t),0)]);
    disp(['length of b10: ' sprintf('%i',length(b10.t))  ' starting with ' datestr(min(b10.t),0)]);
    disp(['length of d10: ' sprintf('%i',length(d10.t))  ' starting with ' datestr(min(d10.t),0)]);


end
%% fixes before next run of run_motcorr.m, if needed
% if isfield(d10,'Tbar') ~= 1
%     d10.Tbar = d10.wbar;
%     d10.vbar = d10.wbar;
%     d10.Fx = zeros(nt,48);
%     d10.licor_qa_std = d10.licor_q_std;
%     d10 = rmfield(d10, 'licor_q_std');
% end 

%%% ASTRAL 2023... for some reason the covariance fluxes are negative? See
%%% if a sign needs flipping... but I can't imagine why it would? 
%%% note.... change T to t in next iteration if run_motcorr is run again.
d10.wT_cov = -d10.wT_cov;
d10.wT_cov_sds = -d10.wT_cov_sds;
d10.hs_cov = -d10.hs_cov;
d10.hs_cov_sds = -d10.hs_cov_sds;

%% choose inertial dissipation, ID, method: 'a', 'b', or 'ab'
% a: compute Cx2 from median over inertial subrange in smoothed spectra
% b: compute Cx2 from polynomial fit over inertial subrange in smoothed spectra
% ab: average of a and b methods
IDflag = 'ab'; % we don't really know whether the ab way is the way to go 

% average of a and b methods for ID fluxes
d10.Cuab = (d10.Cua+d10.Cub)/2;
d10.Cwab = (d10.Cwa+d10.Cwb)/2;
d10.Ctab = (d10.Cta+d10.Ctb)/2;
d10.Cqab = (d10.Cqa+d10.Cqb)/2;

%% set limits for various filtering criteria... more extreme than in run_motcorr.m
rdir_lo     = -60;  % rel wind direction limits, deg from bow
rdir_hi     = 60;
rain_lim    = 5;    % max rain rate, mm/hr
sp2_lim     = 0.8;  % max vplat std dev  m/s
sigu_lim    = 1.5;  % max ship speed std dev  m/s
sigh_lim    = 5;    % max ship heading std dev, deg
badSon_lim  = 50;   % max bad sonic points per 10min interval
missingSon_lim = 50;% max missingSon sonic points per 10min interval
ushp_lim    = 3.5;  % max ship speed, m/s
tilt_lim    = 10;   % max flow tilt angle, degrees
sig_rwd_lim = 15;   % max std dev rdir
agc_lim     = 60;   % max licor agc
co2_LoLim   = 350;  % min co2 ppm
co2_HiLim   = 450;  % max co2 ppm
sigco2_lim  = 20;   % max sigma co2
q_lic_LoLim = 0.1;  % min q licor
q_lic_HiLim = 26;   % max q licor
q_std_LoLim  = 0;    % min sigma q licor
q_std_HiLim  = 3;    % max sigma q licor
wq_LoLim    = -0.02;% min wq licor
wq_HiLim    = 0.1;  % max wq licor
wu_LoLim    = -5;   % min wu
wu_HiLim    = 0.05; % max wu
wv_LoLim    = -1;   % min wv
wv_HiLim    = 1;    % max wv
wT_LoLim    = -0.1; % min wT
wT_HiLim    = 0.25; % max wT % should this be lowered to 0.6? 
Tnoise_lim  = 2e-3; % max Ts noise - having issues with Tsonic
Tson_var_lim = 0.1; % max variance in Tsonic
cu_LoLim    = 0;    % min cu2
cu_HiLim    = 1.3;  % max cu2
cw_LoLim    = 0;    % min cw2
cw_HiLim    = 1;    % max cw2
ct_LoLim    = 1e-6; % min ct2
ct_HiLim    = 0.6;  % max ct2
cq_LoLim   = 1e-4;  % min cq2
cq_HiLim   = 2;     % max cq2
qvar_LoLim = 0;     % min qvar
qvar_HiLim = 0.2e4;   % max qvar


%% make adjustments, filter outliers, etc.
% Apply fixes to data following run_motcorr and for filtering
% bulk flux calculations.  Edit fixit.m to make corrections to means.

% kill all flux components where agc is bad, licor q is out of range, when std(q) is
% out of range. agc limit was already been applied to means, but not fluxes. 

bad_licor_day = datenum(2023,6,15,7,30,0);

clear ii; 
ii = find(b10.licor_agc>agc_lim | ...
    b10.licor_qa<q_lic_LoLim | b10.licor_qa>q_lic_HiLim | ...
    d10.licor_qa_std>q_std_HiLim | d10.licor_qa_std<q_std_LoLim);
if strcmp(cruise,'ASTRAL_2023') == 1
   iii = find(b10.t < bad_licor_day);
   ii = unique([ii; iii]);
end

d10.wq_cov(ii) = nan;
d10.wq_cov_sds(ii) = nan;
d10.wh2o_cov(ii) = nan;
d10.wco2_cov(ii) = nan;
d10.hl_cov(ii) = nan;
d10.hl_cov_sds(ii) = nan;
d10.Cqa(ii) = nan;
d10.Cqb(ii) = nan;
d10.Cqab(ii) = nan;
d10.qsr_cov(ii) = nan;
d10.qsr_cov_sds(ii) = nan;
d10.qsr_ida(ii) = nan;
d10.qsr_idb(ii) = nan;

d10.licor_H2O_std(iii)  = nan; 
d10.licor_Pbox_std(iii) = nan; 
d10.licor_CO2_std(iii) = nan; 
d10.licor_qa_std(iii) = nan; 


%%% something is wrong with qvar and simon's covariance heat and moisture
% fluxes
bad_qvar = find(d10.qvar > qvar_HiLim | d10.qvar < qvar_LoLim);

%%% test with a plot
% hs_cov_sds = d10.hs_cov_sds;
% hs_cov_sds(bad_qvar) = nan;
% figure
% plot(d10.t, d10.hs_cov_sds,'o');
% hold on;
% plot(d10.t, hs_cov_sds,'x');
% % plot(d10.t, d10.hs_cov,'.')
% legend('og hs cov sds','new hs cov sds','hs cov');
% grid on;

d10.hs_cov_sds(bad_qvar) = nan;
d10.tsr_cov_sds(bad_qvar) = nan;
d10.qsr_cov_sds(bad_qvar) = nan;
d10.wq_cov_sds(bad_qvar) = nan;
d10.wT_cov_sds(bad_qvar) = nan;

%% filter other covariances and ID variables for outlier values
%%% redid good motion because it was empty before... probably because prate
kk = find((b10.rdir < 90 & b10.rdir > -90) & d10.hed_std < 5 &...
                   d10.sog_std < 0.6 & d10.vplat_std < 0.8 &...
                   (sqrt(d10.wvar)./d10.ugw < .7+.0015*b10.wspd.^2) &...
                   (sqrt(d10.wvar)./d10.ugu < 1.4) & d10.missingSon < 100 & ...
                   d10.badSon < 100);  % leaving out x.prate < 5 because prate is zero or bad

hh = intersect(kk, find(b10.licor_agc < 60));
jj = intersect(kk, find(isfinite(d10.usr_ida) == 1));
mm = intersect(hh,jj);

d10.good_motion = d10.t*0;
d10.good_motion(kk) = 1;

d10.good_motion_licor =d10.t*0;
d10.good_motion_licor(hh) = 1;

d10.good_motion_id =d10.t*0;
d10.good_motion_id(jj) = 1;

d10.good_motion_id_licor =d10.t*0;
d10.good_motion_id_licor(mm) = 1;
 
% now filter out BAD data
clear kk; kk = find(d10.good_motion == 0 | ...
    b10.rdir>rdir_hi | b10.rdir<rdir_lo | ...
    d10.badSon>badSon_lim | d10.missingSon>missingSon_lim);
% these are different from motcorr... it changes cruise to cruise.
% kk in run_motcorr used more variables to perform filtering. Here we use
% fewer variables to choose from, but stricter missingSon (was 100) and
% rdri (was +/-90) rules

d10.wTson_cov(kk) = nan;
d10.wT_cov(kk) = nan; 
d10.wq_cov(kk) = nan;
d10.wq_cov_sds(kk) = nan; 
d10.wh2o_cov(kk) = nan;
d10.wco2_cov(kk) = nan;
d10.wT_cov_sds(kk) = nan; 
d10.wu_cov(kk) = nan;
d10.wv_cov(kk) = nan;
d10.hl_cov(kk) = nan;
d10.hl_cov_sds(kk) = nan;
d10.hs_cov(kk) = nan;
d10.hs_cov_sds(kk) = nan;
d10.tau_cov(kk) = nan;
d10.tau_cov_cross(kk) = nan;

d10.uvar(kk) = nan; 
d10.vvar(kk) = nan;
d10.wvar(kk) = nan; 
d10.Tvar(kk) = nan; 

d10.usr_ida(kk) = nan; 
d10.usr_idb(kk) = nan; 
d10.tsr_id_son(kk) = nan;
d10.tsr_ida(kk) = nan; 
d10.tsr_idb(kk) = nan; 
d10.qsr_ida(kk) = nan;
d10.qsr_idb(kk) = nan;

d10.hs_ida(kk) = nan;
d10.hs_idb(kk) = nan;
d10.hl_ida(kk) = nan;
d10.hl_idb(kk) = nan;
d10.tau_ida(kk) = nan;
d10.tau_idb(kk) = nan;

d10.Cua(kk) = nan; 
d10.Cub(kk) = nan; 
d10.Cwa(kk) = nan; 
d10.Cwb(kk) = nan; 
d10.Cta(kk) = nan; 
d10.Ctb(kk) = nan; 
d10.Cqa(kk) = nan; 
d10.Cqb(kk) = nan; 

%%% NOTE why would we do this? licor does not depend on sonic
% licor_qa(kk) = Nan; 
% licor_h2o(kk) = nan;
% hl_cov(kk) = nan;

%% general covariance limits
d10.wu_cov(d10.wu_cov<wu_LoLim | d10.wu_cov>wu_HiLim) = nan;
d10.tau_cov(d10.wu_cov<wu_LoLim | d10.wu_cov>wu_HiLim) = nan;

d10.wv_cov(d10.wv_cov<wv_LoLim | d10.wv_cov>wv_HiLim) = nan;

d10.wTson_cov(d10.wTson_cov<wT_LoLim | d10.wTson_cov>wT_HiLim) = nan;
d10.wT_cov(d10.wT_cov<wT_LoLim | d10.wT_cov>wT_HiLim) = nan;
d10.hs_cov(d10.wT_cov<wT_LoLim | d10.wT_cov>wT_HiLim) = nan;

d10.wT_cov_sds(d10.wT_cov_sds<wT_LoLim | d10.wT_cov_sds>wT_HiLim) = nan;
d10.hs_cov_sds(d10.wT_cov_sds<wT_LoLim | d10.wT_cov_sds>wT_HiLim) = nan;

d10.wq_cov(d10.wq_cov<wq_LoLim | d10.wq_cov>wq_HiLim) = nan;
d10.hl_cov(d10.wq_cov<wq_LoLim | d10.wq_cov>wq_HiLim) = nan;

d10.wq_cov_sds(d10.wq_cov_sds<wq_LoLim | d10.wq_cov_sds>wq_HiLim) = nan;
d10.hl_cov_sds(d10.wq_cov_sds<wq_LoLim | d10.wq_cov_sds>wq_HiLim) = nan;

d10.wh2o_cov(d10.wq_cov<wq_LoLim | d10.wq_cov>wq_HiLim) = nan;
d10.wco2_cov(d10.wq_cov<wq_LoLim | d10.wq_cov>wq_HiLim) = nan;

% cu2,cw2,ct2 and cq2 limits
bad_cua = find(d10.Cua<cu_LoLim | d10.Cua >cu_HiLim);
bad_cwa = find(d10.Cwa<cw_LoLim | d10.Cwa >cw_HiLim);
bad_cta = find(d10.Cta<ct_LoLim | d10.Cta>ct_HiLim);
bad_cqa = find(d10.Cqa<cq_LoLim | d10.Cqa>cq_HiLim);

bad_cub = find(d10.Cub<cu_LoLim | d10.Cub >cu_HiLim);
bad_cwb = find(d10.Cwb<cw_LoLim | d10.Cwb >cw_HiLim);
bad_ctb = find(d10.Ctb<ct_LoLim | d10.Ctb>ct_HiLim);
bad_cqb = find(d10.Cqb<cq_LoLim | d10.Cqb>cq_HiLim);

bad_cuab = find(d10.Cuab<cu_LoLim | d10.Cuab >cu_HiLim);
bad_cwab = find(d10.Cwab<cw_LoLim | d10.Cwab >cw_HiLim);
bad_ctab = find(d10.Ctab<ct_LoLim | d10.Ctab>ct_HiLim);
bad_cqab = find(d10.Cqab<cq_LoLim | d10.Cqab>cq_HiLim);

d10.Cua(bad_cua) = nan;
d10.Cub(bad_cub) = nan;
d10.Cuab(bad_cuab) = nan;

d10.Cwa(bad_cwa) = nan;
d10.Cwb(bad_cwb) = nan;
d10.Cwab(bad_cwab) = nan;

d10.Cta(bad_cta) = nan;
d10.Ctb(bad_ctb) = nan;
d10.Ctab(bad_ctab) = nan;

d10.Cqa(bad_cqa) = nan;
d10.Cqb(bad_cqb) = nan;
d10.Cqab(bad_cqab) = nan;

% filter for Ts noise limit and variance
noisy_ct = (d10.Tson_noise > Tnoise_lim | d10.Tvar>Tson_var_lim);
d10.Cta(noisy_ct) = nan;
d10.Ctb(noisy_ct) = nan;
d10.Ctab(noisy_ct) = nan;
d10.hs_cov(noisy_ct) = nan;
d10.hs_cov_sds(noisy_ct) = nan;
d10.wTson_cov(noisy_ct) = nan;
d10.wT_cov(noisy_ct) = nan; 
d10.wT_cov_sds(noisy_ct) = nan; 

% Cs is the weighted average of cu and cw for smoother structure function
% cs = (cu+.75*cw)/2;
d10.Csa = (d10.Cua+.75*d10.Cwa)/2;
d10.Csb = (d10.Cub+.75*d10.Cwb)/2;
d10.Csab = (d10.Cuab+.75*d10.Cwab)/2;

d10.Csa(isnan(d10.Cua)) = .75*d10.Cwa(isnan(d10.Cua));
d10.Csa(isnan(d10.Cwa)) = d10.Cua(isnan(d10.Cwa));
d10.Csb(isnan(d10.Cub)) = .75*d10.Cwb(isnan(d10.Cub));
d10.Csb(isnan(d10.Cwb)) = d10.Cub(isnan(d10.Cwb));
d10.Csab(isnan(d10.Cuab)) = .75*d10.Cwab(isnan(d10.Cuab));
d10.Csab(isnan(d10.Cwab)) = d10.Cuab(isnan(d10.Cwab));


% ship plume contam index based on wind variances, 0 = good, 1 = bad
jplume = ones(nt,1);
clear ii; 
ii = (sqrt(d10.wvar)./d10.ugw < 2+0.0015*b10.wspd.^2) & (sqrt(d10.vvar)./d10.ugu < 2);
jplume(ii) = 0;
jplume(isnan(jplume)) = 1;
wh_bad_plume = find(jplume == 1);

%%% NOTE - IS IT OKAY IF I CHANGED THIS? DEALING WITH DECIMAL PLACE FLAGS
%%% IS NOT A GOOD IDEA. IT WAS TOO HARD TO INTERPOLATE FROM TIME BASE TO
%%% TIME BASE
% ship maneuver index, 0 = good, 1 = bad
jmanuv = ones(nt,1);
clean_sog_std = ones(nt,1);
clear ii; 
ii = (d10.hed_std<sigh_lim) & (d10.sog_std<sigu_lim) & (d10.vplat_std<sp2_lim);
clean_sog_std(ii) = d10.sog_std(ii);

jmanuv(clean_sog_std>0.8) = 1;
jmanuv(clean_sog_std<0.8) = 0;
jmanuv(isnan(clean_sog_std)) = 1;
wh_bad_manuv = find(jmanuv == 1);

d10.jmanuv = jmanuv;
d10.jplume = jplume;

% interpolate to 1-min

% assume bad values to start
d1.jmanuv = ones(length(d1.jd),1);
d1.plume = ones(length(d1.jd),1);

% can't do interp for nan jd values... 
jd_good1 = find(isfinite(d1.jd) == 1);
jd_good10 = find(isfinite(d10.jd) == 1);

d1.jmanuv = interp1(d10.jd(jd_good10), d10.jmanuv(jd_good10), d1.jd);
d1.jplume = interp1(d10.jd(jd_good10), d10.jplume(jd_good10), d1.jd);

d1.jmanuv = round(d1.jmanuv);
d1.jplume = round(d1.jplume);

% recompute ID fluxes... with new smoothed and/or filtered cs, ct, cq structures
% choosing method ab for now... but will test a, b, ab methods later
% zu / l is b10.zeta and is output by COARE
% air-sea temp difference: DT = tskin - b10.ta; 
% was used prior for sign of tsr... technically it should be dtheta
% DT was this before: Tsbest + dt_skin - ta... 
% which would have been a positive number added to tsnk... not the skin temp
usr_id_ab   = sqrt(d10.Csab     .*zu^0.667./psi_fu(b10.zeta)); 
usr_id_a    = sqrt(d10.Csa      .*zu^0.667./psi_fu(b10.zeta)); 
usr_id_b    = sqrt(d10.Csb      .*zu^0.667./psi_fu(b10.zeta)); 

usr_id_ab = real(usr_id_ab);
usr_id_a = real(usr_id_a);
usr_id_b = real(usr_id_b);

usr_id = usr_id_ab;


sign_tsr = sign(b10.tsr);
sign_dtheta = sign(b10.dtheta); % looks worse and opposite sign compared to bulk, ppposite to tsr_bulk
sign_dt = sign(b10.tskin - b10.ta); % looks worse and opposite sign compared to bulk, ppposite to tsr_bulk
sign_dt_OG = sign(b10.tsnk - b10.ta + b10.dt_skin);  % doesn't make sense because tskin = Ts_best - dt_skin;
sign_wtv = -sign(d10.wtv); % 

the_sign = sign_wtv;

% should this be sign of tsr_son? or tsr? or dt skin - air? or dtheta?
tsr_id_son_ab    = sqrt(d10.Ctab     .*zu^0.667./psi_ft(b10.zeta)).*the_sign; 
tsr_id_son_a     = sqrt(d10.Cta      .*zu^0.667./psi_ft(b10.zeta)).*the_sign; 
tsr_id_son_b      = sqrt(d10.Ctb      .*zu^0.667./psi_ft(b10.zeta)).*the_sign; 

tsr_id_son_ab    = real(tsr_id_son_ab);
tsr_id_son_a     = real(tsr_id_son_a);
tsr_id_son_b      = real(tsr_id_son_b);

tsr_id_ab       = tsr_id_son_ab  -0.51*(b10.ta+C2K).*b10.qsr; % moisture corrrected tsr_id
tsr_id_a        = tsr_id_son_a   -0.51*(b10.ta+C2K).*b10.qsr; % moisture corrrected tsr_id
tsr_id_b        = tsr_id_son_b    -0.51*(b10.ta+C2K).*b10.qsr; % moisture corrrected tsr_id

tsr_id_son = tsr_id_son_ab;
tsr_id = tsr_id_ab;

% figure; plot(b10.t, b10.tsr, b10.t(wh_good_id), tsr_id_ab(wh_good_id), 'o', ...
%     b10.t(wh_good_id), tsr_id_a(wh_good_id), 'x',...
%     b10.t(wh_good_id), tsr_id_b(wh_good_id),'s'); 
% grid on; legend('bulk','id ab','id a','id b');

zet_q = zq./b10.l;
qsr_id_ab       = sqrt(d10.Cqab     .*zq^0.667./psi_ft(zet_q))*1e-3.*sign(b10.qsr); % qsr in kg/kg
qsr_id_a        = sqrt(d10.Cqa      .*zq^0.667./psi_ft(zet_q))*1e-3.*sign(b10.qsr); % qsr in kg/kg
qsr_id_b        = sqrt(d10.Cqb      .*zq^0.667./psi_ft(zet_q))*1e-3.*sign(b10.qsr); % qsr in kg/kg
qsr_id_ab       = real(qsr_id_ab);
qsr_id_a        = real(qsr_id_a);
qsr_id_b        = real(qsr_id_b);

qsr_id = qsr_id_ab;

hs_id_ab    = -b10.rhoa*cpa.*tsr_id_ab  .*usr_id_ab;
hs_id_a     = -b10.rhoa*cpa.*tsr_id_a   .*usr_id_a;
hs_id_b     = -b10.rhoa*cpa.*tsr_id_b   .*usr_id_b;

hs_id = hs_id_ab;

hl_id_ab        = -b10.rhoa.*d10.Le_w.*qsr_id_ab  .*usr_id_ab +b10.hlwebb; % Webb corrected, g/kg
hl_id_a         = -b10.rhoa.*d10.Le_w.*qsr_id_a   .*usr_id_a  +b10.hlwebb; % Webb corrected, g/kg
hl_id_b         = -b10.rhoa.*d10.Le_w.*qsr_id_b   .*usr_id_b  +b10.hlwebb; % Webb corrected, g/kg

hl_id = hl_id_ab;

tau_id_ab = b10.rhoa .*usr_id_ab .^2;
tau_id_a = b10.rhoa .*usr_id_a .^2;
tau_id_b = b10.rhoa .*usr_id_b .^2;

tau_id = tau_id_ab;

d10.usr_id = usr_id;
d10.usr_ida = usr_id_a;
d10.usr_idb = usr_id_b;
d10.tsr_id = tsr_id;
d10.tsr_ida = tsr_id_a;
d10.tsr_idb = tsr_id_b;
d10.tsr_id_son = tsr_id_son;
d10.tsr_id_sona = tsr_id_son_a;
d10.tsr_id_sonb = tsr_id_son_b;
d10.qsr_id = qsr_id;
d10.qsr_ida = qsr_id_a;
d10.qsr_idb = qsr_id_b;
d10.hs_id = hs_id;
d10.hs_ida = hs_id_a;
d10.hs_idb = hs_id_b;
d10.hl_id = hl_id;
d10.hl_ida = hl_id_a;
d10.hl_idb = hl_id_b;
d10.tau_id = tau_id;
d10.tau_ida = tau_id_a;
d10.tau_idb = tau_id_b;

wh_good_id = find((b10.rdir<rdir_hi & b10.rdir>rdir_lo) & d10.hed_std<sigh_lim & ...
       d10.sog_std<sigu_lim & d10.vplat_std<sp2_lim &  ...
       (sqrt(d10.wvar)./d10.ugw < 2+0.0015*b10.wspd.^2) & d10.badSon<badSon_lim & ...
       d10.missingSon<missingSon_lim & (sqrt(d10.vvar)./d10.ugu < 2));
%    b10.prate<rain_lim &
good_id = zeros(nt, 1);
good_id(wh_good_id) = 1;
bad_id = ones(nt,1);
bad_id(wh_good_id) = 0;
wh_bad_id = find(bad_id == 1);

wh_good_usr_id = find(good_id == 1 & isfinite(usr_id) == 1);
wh_good_qsr_id = find(good_id == 1 & isfinite(qsr_id) == 1);
wh_good_tsr_id = find(good_id == 1 & isfinite(tsr_id) == 1);
d10.good_usr_id = zeros(nt, 1);
d10.good_tsr_id = zeros(nt, 1);
d10.good_qsr_id = zeros(nt, 1);
d10.good_usr_id(wh_good_usr_id) = 1;
d10.good_tsr_id(wh_good_tsr_id) = 1;
d10.good_qsr_id(wh_good_qsr_id) = 1;

% use the thresholds

d10.usr_id(wh_bad_id) = nan;
d10.usr_ida(wh_bad_id) = nan;
d10.usr_idb(wh_bad_id) = nan;
d10.tsr_id(wh_bad_id) = nan;
d10.tsr_ida(wh_bad_id) = nan;
d10.tsr_idb(wh_bad_id) = nan;
d10.tsr_id_son(wh_bad_id) = nan;
d10.tsr_id_sona(wh_bad_id) = nan;
d10.tsr_id_sonb(wh_bad_id) = nan;
d10.qsr_id(wh_bad_id) = nan;
d10.qsr_ida(wh_bad_id) = nan;
d10.qsr_idb(wh_bad_id) = nan;
d10.hs_id(wh_bad_id) = nan;
d10.hs_ida(wh_bad_id) = nan;
d10.hs_idb(wh_bad_id) = nan;
d10.hl_id(wh_bad_id) = nan;
d10.hl_ida(wh_bad_id) = nan;
d10.hl_idb(wh_bad_id) = nan;
d10.tau_id(wh_bad_id) = nan;
d10.tau_ida(wh_bad_id) = nan;
d10.tau_idb(wh_bad_id) = nan;

% note: everywhere that manuv is bad, plume is usually also bad. So this is 
% a bit redundant usually but good to check just in case.
wh_bad_ship = unique([wh_bad_plume; wh_bad_manuv]);

d10.usr_id(wh_bad_ship) = nan;
d10.usr_ida(wh_bad_ship) = nan;
d10.usr_idb(wh_bad_ship) = nan;
d10.tsr_id(wh_bad_ship) = nan;
d10.tsr_ida(wh_bad_ship) = nan;
d10.tsr_idb(wh_bad_ship) = nan;
d10.tsr_id_son(wh_bad_ship) = nan;
d10.tsr_id_sona(wh_bad_ship) = nan;
d10.tsr_id_sonb(wh_bad_ship) = nan;
d10.qsr_id(wh_bad_ship) = nan;
d10.qsr_ida(wh_bad_ship) = nan;
d10.qsr_idb(wh_bad_ship) = nan;
d10.hs_id(wh_bad_ship) = nan;
d10.hs_ida(wh_bad_ship) = nan;
d10.hs_idb(wh_bad_ship) = nan;
d10.hl_id(wh_bad_ship) = nan;
d10.hl_ida(wh_bad_ship) = nan;
d10.hl_idb(wh_bad_ship) = nan;
d10.tau_id(wh_bad_ship) = nan;
d10.tau_ida(wh_bad_ship) = nan;
d10.tau_idb(wh_bad_ship) = nan;

d10.hl_cov(wh_bad_ship) = nan;
d10.hl_cov_sds(wh_bad_ship) = nan;
d10.hs_cov(wh_bad_ship) = nan;
d10.hs_cov_sds(wh_bad_ship) = nan;
d10.tau_cov(wh_bad_ship) = nan;
d10.tau_cov_cross(wh_bad_ship) = nan;
d10.wTson_cov(wh_bad_ship) = nan;
d10.wT_cov(wh_bad_ship) = nan; 
d10.wT_cov_sds(wh_bad_ship) = nan; 
d10.wq_cov(wh_bad_ship) = nan;
d10.wq_cov_sds(wh_bad_ship) = nan; 
d10.wu_cov(wh_bad_ship) = nan;
d10.wv_cov(wh_bad_ship) = nan;
d10.wco2_cov(wh_bad_ship) = nan;

% examine stability functions for velocity and temp/humidity structure
% functions
zeta_fake = -100:.1:10;
cuxx = psi_fu(zeta_fake);
ctxx = psi_ft(zeta_fake);

clear jjj; jjj = wh_good_id;     
   
% examine wind speed structure function parameter z/l dependence: gets plotted
zeta_fake_log = [-60 -30 -20 -8 -5 -4 -3 -2 -1 -.7 -.5 -.3 -.2 -.1 -.05 0 .05 .1 1];
nn_zeta = length(zeta_fake_log)-1;
zeta_log_bin = nan(nn_zeta,1); 
cs_plot = nan(nn_zeta,1); 
cnt = nan(nn_zeta,1); 
for i=1:nn_zeta
   clear ii; ii = find(b10.zeta(jjj)>zeta_fake_log(i) & ...
       b10.zeta(jjj)<zeta_fake_log(i+1) & isfinite(d10.Csab(jjj)));
   if isfinite(jjj(ii))
      zeta_log_bin(i) = nanmedian(b10.zeta(jjj(ii)));
      cs_plot(i) = nanmedian(d10.Csab(jjj(ii))./b10.usr(jjj(ii)).^2*zu^.667);
      cnt(i) = length(jjj(ii));
   else
      zeta_log_bin(i) = nan;
      cs_plot(i) = nan;
      cnt(i) = nan;
   end
end

% select ID Hl as best latent heat flux... for now it's method a
hl_id_plot = nan(nt,1);
hl_id_plot(jjj) = d10.hl_id(jjj);
hl_id_plot(hl_id_plot>1000) = nan;

%%% NOTE: for now we use the ab method but really we should compare again
%%% and choose what is best as a research effort.
%%% other way of doing it: avg of ID and cov..
% hlm(jjj) = nanmean(hl_id(jjj), hl_cov(jjj)); 
% maybe b is better... if you use structure functions to compute
% stabilitday... that's what used to be done... but it can create a numerical
% problem. Spectral fit method is better ideallday... but also subject to
% going wrong. The other mean/median method is better. It's reliable. If
% you have a spectrum w/o a -5/3 region, you still get an estimate from
% mean/median method, and tends to be overestimate. Carry both methods
% through. Simon's method hasn't been proven or time tested yet. Don't know
% what problem it's solving. It can vary for q and T, Tsonic noise is high
% so fitting 5/3 slope is difficult. But in tropics, q signal is high so
% fit should be good. 

% wind speed dependence of Hl: gets plotted
u_bin = 0:20; % wind speed bins
hl_id_u = nan(length(u_bin),1);
hl_u = nan(length(u_bin),1); 
dq_u = nan(length(u_bin),1); 
ynn_u = nan(length(u_bin),1);
for i=1:length(u_bin)
    clear ii; ii = find(floor(b10.u10n)==u_bin(i));
    
    clear ppp; ppp = find(b10.sog(ii)<ushp_lim & (b10.rdir(ii)<rdir_hi & b10.rdir(ii)>rdir_lo) &...
       d10.hed_std(ii)<sigh_lim & d10.sog_std(ii)<sigu_lim & d10.vplat_std(ii)<sp2_lim &...
       (sqrt(d10.wvar(ii))./d10.ugw(ii) < 2+0.0015*b10.wspd(ii).^2) & ...
       (sqrt(d10.vvar(ii))./d10.ugu(ii) < 2+0.05*b10.wspd(ii)) & isfinite(hl_id_plot(ii)) & d10.badSon(ii)<badSon_lim);
%    b10.prate(ii)<rain_lim & 
   if isempty(ppp)
        hl_id_u(i) = nan;
        hl_u(i) = nan;
        ynn_u(i) = 0;
        dq_u(i) = nan;
   else
        hl_id_u(i) = nanmedian(hl_id_plot(ii(ppp)));
        hl_u(i) = nanmedian(b10.hl(ii(ppp)));
        ynn_u(i) = length(ppp);
        dq_u(i) = nanmedian(b10.qs(ii(ppp))-b10.qa(ii(ppp)))-nanmean(b10.dq_skin(ii(ppp)));
    end
end
 
%% compute 10min u*, t* and q* from covariance measurements: gets plotted or used
% compare cov and ID results with bulk model
% wu_cov is in the direction of the wind, streamwise, approx the stress
% wv_cov is cross stream, should be approx zero but still has sampling noise
% So the average is squaring noise and adding it...  which is worst at low
% wind with noise is bigger than signal
% usr_cov = (wu_cov.^2 + wv_cov.^2).^(1/4); % this is a common mistake, 
d10.usr_cov = (d10.wu_cov.^2).^(1/4); % wu_cov has neg numbers so need to do it this way for algebra's sake
d10.qsr_cov = -1E-3*d10.wq_cov./d10.usr_cov;
d10.tsr_cov = -d10.wT_cov./d10.usr_cov;
d10.tsr_cov_sds = -d10.wT_cov_sds./d10.usr_cov;
d10.qsr_cov_sds = -1E-3*d10.wq_cov_sds./d10.usr_cov;

clear jjjj; jjjj =  find(good_id == 1 & isfinite(usr_id)); 
   
% binning
[usr_bulk_bin, usr_cov_bin_mean, usr_cov_bin_med, usr_cov_bin_std, nn_cov] = ...
    binave2(b10.usr(jjjj),d10.usr_cov(jjjj),0.05,0,0.75);

[~, tsr_cov_bin_mean, tsr_cov_bin_med, tsr_cov_std, nn_tsr_cov] = ...
    binave2(b10.tsr(jjjj),d10.tsr_cov(jjjj),0.025,-0.15,0.15);

[~, tsr_cov_sds_bin_mean, tsr_cov_sds_bin_med, tsr_cov_sds_std, nn_tsr_cov_sds] = ...
    binave2(b10.tsr(jjjj),d10.tsr_cov_sds(jjjj),0.025,-0.15,0.15);

[~, usr_id_bin_mean, usr_id_bin_med, usr_id_bin_std, nn_usr_id] = ...
    binave2(b10.usr(jjjj),d10.usr_id(jjjj),0.05, 0,0.75);   
 
[tsr_bulk_bin, tsr_id_bin_mean, tsr_id_bin_med, tsr_id_bin_std, nn_tsr_id] = ...
    binave2(b10.tsr(jjjj),d10.tsr_id(jjjj),0.025,-0.15,0.15);

[hs_bulk_bin, hs_id_bin_mean, hs_id_bin_med, hs_id_std, nn_hs_id] = ...
    binave2(b10.hs(jjj),d10.hs_id(jjj),5,-30,30);

[u10n_bin, cd_id_bin_mean, cd_id_bin_med, cd_id_bin_std, cd_id_bin_nn] = ...
    binave2(b10.u10n(jjj),(d10.usr_id(jjj)./b10.u10n(jjj)).^2,2,1,15);


%% ocean warm layer profile (could be checked with updated COARE output) 
% this only works if the warm layer bulk model is run using sea T as input...
% otherwise zw = 0 and t5_no_warm = T from tsg
% from COARE: dt_warm = warming across entire warm layer
%             dt_warm_at_input = warming from surface to input T level

dtz = zeros(nt,round(zsea_ship)+1);
depth_inc=0:round(zsea_ship);
for i=1:round(zsea_ship)+1
    clear ii;
    ii = find(b10.dz_warm>depth_inc(i));
    dtz(ii,i) = b10.dt_warm(ii).*(1-depth_inc(i)./b10.dz_warm(ii));  % warming from mixed layer to z
end
% save these vars for daily averages
d10.dt5_warm = dtz(:,round(zsea_ship)+1); % amount of warming expected at 5 m due to presence of warm layer
d10.t5_no_warm = b10.tsea_s - dtz(:,round(zsea_ship)+1);  % "ML" or 5 m temp: tsg with with 5-m warm layer removed

d10 = orderfields(d10);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% daily and hourly time bases
% some are plotted, some are saved, but should save all in the future

% daily time base
jd_d_bin = floor(b10.jd(1)):ceil(b10.jd(end)); % daily bin edges
jd_d_bin = jd_d_bin'; % daily bin edges
day.jd = jd_d_bin(1:end-1); % just days
day.t = datenum(yr,0,0,0,0,0) + day.jd;

% hourly time base
jd_h_bin = floor(b10.jd(1)):(1/24):ceil(b10.jd(end)); % hourly bin edges
jd_h_bin = jd_h_bin'; % hourly bin edges
hr.jd = jd_h_bin(1:end-1); % just days
hr.t = datenum(yr,0,0,0,0,0) + hr.jd;

%% daily averages
day.hnet = interval_avg_var(b10.jd, b10.hnet, jd_d_bin);
day.lat = interval_avg_var(b10.jd, b10.lat, jd_d_bin);
day.lon = interval_avg_var(b10.jd, b10.lon, jd_d_bin);
day.sw_dn = interval_avg_var(b10.jd, b10.sw_dn, jd_d_bin);
day.sw_dn_clr = interval_avg_var(b10.jd, b10.sw_dn_clr, jd_d_bin);
day.lw_dn = interval_avg_var(b10.jd, b10.lw_dn, jd_d_bin);
day.lw_dn_clr = interval_avg_var(b10.jd, b10.lw_dn_clr, jd_d_bin);
day.prate = interval_avg_var(b10.jd, b10.prate, jd_d_bin);
temp = day.prate;
temp(isnan(temp)) = 0;
day.paccum = cumsum(temp)*24; % 
%     paccum_10 = cumsum(temp)/6;  % 6 X 10 min segments per hour
%     paccum_1  = cumsum(temp)/60; % 60 X 1 min segments per hour

%%     straight average
% could combine b10 and d10 first in the future. That way you could combine
% and see all variables in one structure. However, keeping them separate
% sort of helps by being able to trace which program produced them. b10
% comes from eval_flux.m and fixit.m. These are used to create d10 with
% run_motcorr.m and da_red_et.m ... d10 is added to in da_red_et.m. 


% variables in b10 structure
var_avg_b = fields(b10);
wh_bt = find(strcmp(var_avg_b,'t') == 1);
wh_bjd = find(strcmp(var_avg_b,'jd') == 1);
var_avg_b(wh_bt) = [];
var_avg_b(wh_bjd) = [];

% isolate just the time-based d10 variables
all_var_d = fields(d10);
nd = length(all_var_d);
time_vars_d = ones(nd,1);
d10_c = nan(nd,1);
d10_r = nan(nd,1);
nt_d = length(d10.Tvar);
for i = 1:length(all_var_d)
    eval(['[d10_c(i), d10_r(i)] = size(d10.' all_var_d{i} ');']);
    if d10_c(i) ~= nt_d || d10_r(i) ~= 1
        time_vars_d(i) = 0;
    end
    if strcmp(all_var_d{i},'t') == 1 | strcmp(all_var_d{i},'jd')
        time_vars_d(i) = 0;
    end
end
wh_non_time_vars_d = find(time_vars_d == 0);
var_avg_d = all_var_d;
var_avg_d(wh_non_time_vars_d) = [];
    
%%% combine the 10-min time series first
clear e10;
e10.t = b10.t;
e10.jd = b10.jd;
e10.hnet_cov    = b10.sw_net + b10.lw_net - d10.hs_cov - d10.hl_cov - b10.hrain;
e10.hnet_id     = b10.sw_net + b10.lw_net - d10.hs_id - d10.hl_id - b10.hrain;

for i = 1:length(var_avg_b)
    eval(['e10.' var_avg_b{i} ' = b10.' var_avg_b{i} ';']);
end
for i = 1:length(var_avg_d)
    eval(['e10.' var_avg_d{i} ' = d10.' var_avg_d{i} ';']);
end

%%% perfrom a straight average second.
for i = 1:length(var_avg_b)
    eval(['hr.' var_avg_b{i} ' = interval_avg_var(b10.jd, b10.' var_avg_b{i} ', jd_h_bin);']);
end
for i = 1:length(var_avg_d)
    eval(['hr.' var_avg_d{i} ' = interval_avg_var(d10.jd, d10.' var_avg_d{i} ', jd_h_bin);']);
end

%%  special values, directions, and vectors
 
hr.minute = zeros(length(hr.t),1);
hr.missingSon = interval_sum_var(b10.jd, d10.missingSon, jd_h_bin);
hr.badSon = interval_sum_var(b10.jd, d10.badSon, jd_h_bin);
hr.tilt = interval_avg_dir(d10.jd,d10.tilt,jd_h_bin); 


[hr.cspd, hr.cdir]            =  interval_avg_vect(b10.jd, b10.cspd, b10.cdir, jd_h_bin);
if have_adcp_data == 1
    [hr.cspd_adcp, hr.cdir_adcp]  =  interval_avg_vect(b10.jd, b10.cspd_adcp, b10.cdir_adcp, jd_h_bin);
end
[hr.cspd_spdlog, hr.cdir_spdlog]=  interval_avg_vect(b10.jd, b10.cspd_spdlog, b10.cdir_spdlog, jd_h_bin);
[hr.wspd, hr.wdir]            =  interval_avg_vect(b10.jd, b10.wspd, b10.wdir, jd_h_bin);
[hr.wspd_new, hr.wdir_new]    =  interval_avg_vect(b10.jd, d10.wspd_new, d10.wdir_new, jd_h_bin);
[hr.wspd_s, hr.wdir_s]        =  interval_avg_vect(b10.jd, b10.wspd_s, b10.wdir_s, jd_h_bin);

if have_wxt_data == 1
    [hr.wspd_wxt, hr.wdir_wxt]    =  interval_avg_vect(b10.jd, b10.wspd_wxt, b10.wdir_wxt, jd_h_bin);
    [hr.wspd_sfc, hr.wdir_sfc]    =  interval_avg_vect(b10.jd, b10.wspd_sfc, b10.wdir_sfc, jd_h_bin);
end

%%% check to make sure this is resulting in +/- 180 for all
% rdir_new, rspd_new2, rspd_raw
[hr.rspd, hr.rdir]            =  interval_avg_rvect(b10.jd, b10.rspd, b10.rdir, jd_h_bin);
[hr.rspd_new, hr.rdir_new]    =  interval_avg_rvect(b10.jd, d10.rspd_new, d10.rdir_new, jd_h_bin);
[hr.rspd_s, hr.rdir_s]        =  interval_avg_rvect(b10.jd, b10.rspd_s, b10.rdir_s, jd_h_bin);
if have_wxt_data == 1
    [hr.rspd_wxt, hr.rdir_wxt]    =  interval_avg_rvect(b10.jd, b10.rspd_wxt, b10.rdir_wxt, jd_h_bin);
end

plot_rdir = 0;
if plot_rdir == 1
   figure;
   plot(b10.t, b10.rdir,'x',hr.t, hr.rdir,'o'); 
   legend('10-min','hr');    
   title('rdir check');
end

%% fix hed, cog, sog if needed
% These are equivalent to the ones below, and so are not needed. 
hr.spdlog_s = sqrt(hr.spdlog_u_s.^2 + hr.spdlog_v_s.^2);  % recompute sog from speed components

hr.sog_s = sqrt(hr.sogN_s.^2 + hr.sogE_s.^2);  % recompute sog from speed components
hr.sog = sqrt(hr.sogN.^2 + hr.sogE.^2);  % recompute sog from speed components

hr.cog_s = atan2(hr.sogE_s, hr.sogN_s)*r2d;  % recompute cog from speed components
hr.cog_s = mod(hr.cog_s + 360, 360); % reorient units
hr.cog = atan2(hr.sogE, hr.sogN)*r2d;  % recompute cog from speed components
hr.cog = mod(hr.cog + 360, 360); % reorient units2

hr.hed_s = atan2(hr.hedE_s, hr.hedN_s)*r2d; % recompute avg hed from avg N/E components
hr.hed_s = mod(hr.hed_s + 360, 360); % reorient units    
hr.hed = atan2(hr.hedE, hr.hedN)*r2d; % recompute avg hed from avg N/E components
hr.hed = mod(hr.hed + 360, 360); % reorient units    


%% fix any negative angles (NOT the rdirs... which are now +/- 180 on purpose
% is this necessary? there weren't any bad angles in PISTON 2019
if have_wxt_data == 1
    angles1 = {'wdir';'wdir_s';'wdir_wxt'};
else
    angles1 = {'wdir';'wdir_s'};
end
angles2 = {'cog';'hed'};
for i = 1:length(angles1)
    this = hr.(angles1{i});
    bad_ang = find(this<0);
    if ~isempty(bad_ang)
        disp(['bad angles found for ' angles1{i}]);
        this(bad_ang) = this(bad_ang)+360;
        hr.(angles1{i}) = this;
    end
end
for i = 1:length(angles2)
    this = hr.(angles2{i});
    bad_ang = find(this<0);
    if ~isempty(bad_ang)
        disp(['bad angles found for ' angles2{i}]);
        this(bad_ang) = this(bad_ang)+360;
        hr.(angles2{i}) = this;
    end
end

%% standard deviations... first square all standard deviations, then
% % average, then take square root
hr.rdir_std = sqrt(interval_avg_var(b10.jd, d10.rdir_std.^2, jd_h_bin));         
hr.wspd_std_s = sqrt(interval_avg_var(b10.jd, b10.wspd_std_s.^2, jd_h_bin));  
hr.wdir_std_s = sqrt(interval_avg_var(b10.jd, b10.wdir_std_s.^2, jd_h_bin));     
hr.rspd_std_s = sqrt(interval_avg_var(b10.jd, b10.rspd_std_s.^2, jd_h_bin));  
hr.rdir_std_s = sqrt(interval_avg_var(b10.jd, b10.rdir_std_s.^2, jd_h_bin)); 
hr.sw_dn_std = sqrt(interval_avg_var(b10.jd, b10.sw_dn_std.^2, jd_h_bin));    
hr.lw_dn_std = sqrt(interval_avg_var(b10.jd, b10.lw_dn_std.^2, jd_h_bin));    
hr.sog_std_s = sqrt(interval_avg_var(b10.jd, b10.sog_std_s.^2, jd_h_bin));     
hr.cog_std_s = sqrt(interval_avg_var(b10.jd, b10.cog_std_s.^2, jd_h_bin));         
hr.hed_std_s = sqrt(interval_avg_var(b10.jd, b10.hed_std_s.^2, jd_h_bin));        
hr.sog_std = sqrt(interval_avg_var(b10.jd, d10.sog_std.^2, jd_h_bin));         
hr.cog_std = sqrt(interval_avg_var(b10.jd, d10.cog_std.^2, jd_h_bin));       
hr.hed_std = sqrt(interval_avg_var(b10.jd, d10.hed_std.^2, jd_h_bin));        
hr.uplat_std = sqrt(interval_avg_var(b10.jd, d10.uplat_std.^2, jd_h_bin));
hr.vplat_std = sqrt(interval_avg_var(b10.jd, d10.vplat_std.^2, jd_h_bin));
hr.wplat_std = sqrt(interval_avg_var(b10.jd, d10.wplat_std.^2, jd_h_bin));
hr.shed_std = sqrt(interval_avg_var(b10.jd, d10.shed_std.^2, jd_h_bin));
hr.ched_std = sqrt(interval_avg_var(b10.jd, d10.ched_std.^2, jd_h_bin));
hr.shed_std_s = sqrt(interval_avg_var(b10.jd, b10.shed_std_s.^2, jd_h_bin));
hr.ched_std_s = sqrt(interval_avg_var(b10.jd, b10.ched_std_s.^2, jd_h_bin));
%%% note --> these will all change next time I rerun evalflux and motcorr. 
% hr.spdlog_std_s = sqrt(interval_avg_var(b10.jd, b10.spdlog_std_s.^2, jd_h_bin));         
hr.licor_H2O_std = sqrt(interval_avg_var(b10.jd, d10.licor_H2O_std.^2, jd_h_bin));
hr.licor_qa_std = sqrt(interval_avg_var(b10.jd, d10.licor_qa_std.^2, jd_h_bin));
hr.licor_CO2_std = sqrt(interval_avg_var(b10.jd, d10.licor_CO2_std.^2, jd_h_bin));
hr.licor_Pbox_std = sqrt(interval_avg_var(b10.jd, d10.licor_Pbox_std.^2, jd_h_bin));

%%     special special or recalculations after averaging

temp = hr.prate;
temp(isnan(temp)) = 0;
hr.paccum = cumsum(temp); % already in increments of hours

ref = 2;
B=coare36vnWarm_et(hr.jd, hr.wspd_sfc, zu, hr.ta, zt, hr.rh, zq, hr.psealevel, hr.tsnk, hr.sw_dn, hr.lw_dn, hr.lat, hr.lon, 600, hr.prate, zsnk, hr.ssea_s, nan, nan, ref, ref, ref);
Bs=coare36vnWarm_et(hr.jd, hr.wspd_sfc, zu, hr.ta, zt, hr.rh, zq, hr.psealevel, hr.tsea_s, hr.sw_dn, hr.lw_dn, hr.lat, hr.lon, 600, hr.prate, zsea_ship, hr.ssea_s, nan, nan, ref, ref, ref);
C=coare36vnWarm_et(hr.jd, hr.wspd_s, zu_ship, hr.ta_s, zt_ship, hr.rh_s, zq_ship, hr.psealevel_s, hr.tsea_s, hr.sw_dn_s, hr.lw_dn_s, hr.lat, hr.lon, 600, hr.prate, zsea_ship, hr.ssea_s, nan, nan, ref, ref, ref);

cfields = {'usr';'tau';'hs';'hl';'hb';'hb_son';'hlwebb';'tsr';'qsr';'zo';'zot';'zoq';...
    'cd';'ch';'ce';'l';'zeta';'dt_skin';'dq_skin';'dz_skin';'u2';'ta2';'qa2';...
    'rh2';'u2n';'ta2n';'qa2n';'lw_net';'sw_net';'le';'rhoa';'un';'u10';'u10n';'cdn10';'chn10';'cen10';...
    'hrain';'qs';'erate';'ta10';'ta10n';'qa10';'qa10n';'rh10';'pa10';'rhoa10';'gust';'wc_frac';'edis';...
    'dt_warm';'dz_warm';'dt_warm_to_skin';'du_warm'};

D = B;

wh_bad_snake = find(isnan(hr.tsnk)== 1);

for i = 1:length(cfields)
   D(wh_bad_snake,i) = Bs(wh_bad_snake,i);
end

for i = 1:length(cfields)
    eval(['hr.' cfields{i} '_s = C(:,i);']);
    eval(['hr.' cfields{i} '   = D(:,i);']);
    eval(['hrs.' cfields{i} '   = Bs(:,i);']);
end



%%% this is really noisy. Let the interval averaging take care of this
%%% instead. 
% hr.tskin       = hr.tsnk + hr.dt_warm_to_skin - hr.dt_skin;
% hr.tskin(wh_bad_snake) = b10.tsea_s(wh_bad_snake) + hrs.dt_warm_to_skin(wh_bad_snake) - hrs.dt_skin(wh_bad_snake);
% hr.qskin = qsea_p(hr.tskin,hr.psealevel);
% hr.lw_up                = hr.lw_net - hr.lw_dn;
% hr.lw_up(wh_bad_snake)  = hrs.lw_net(wh_bad_snake) - b10.lw_dn(wh_bad_snake);

%%% recalculate some hourly fields based on new COARE output. 

hr.lw_up       = hr.lw_net - hr.lw_dn;
hr.lw_up_s     = hr.lw_net_s - hr.lw_dn_s;
hr.sw_up       = hr.sw_net - hr.sw_dn;
hr.sw_up_s     = hr.sw_net_s - hr.sw_dn_s;
% hr.hnet        = hr.sw_net + hr.lw_net - hr.hs - hr.hl - hr.hrain;
% hr.hnet_s      = hr.sw_net_s + hr.lw_net_s - hr.hs_s - hr.hl_s - hr.hrain_s;
hr.hnet        = hr.sw_net + hr.lw_net - hr.hs - hr.hl; % ASTRAL_2023 has no rain rate data yet
hr.hnet_s      = hr.sw_net_s + hr.lw_net_s - hr.hs_s - hr.hl_s; % ASTRAL_2023 has no rain rate data yet
hr.hnet_cov    = hr.sw_net + hr.lw_net - hr.hs_cov - hr.hl_cov;
hr.hnet_id     = hr.sw_net + hr.lw_net - hr.hs_id - hr.hl_id;
% hr.hnet_cov    = hr.sw_net + hr.lw_net - hr.hs_cov - hr.hl_cov - hr.hrain;
% hr.hnet_id     = hr.sw_net + hr.lw_net - hr.hs_id - hr.hl_id - hr.hrain;
hr.theta10     = (hr.ta10n+C2K).*(1000./hr.pa10).^(Rgas/cpa);  
hr.theta0      = (hr.tskin+C2K).*(1000./hr.psealevel).^(Rgas/cpa);  
hr.dtheta      = hr.theta0 - hr.theta10;
hr.tsr_son     = hr.tsr + 0.51*(hr.ta+C2K).*hr.qsr;
hr.zeta        = zu./hr.l;

% for some reason the warm layer looks weird at hourly levels... so just
% average 10-min output instead

hr.dt_warm_to_skin = interval_avg_var(b10.jd, b10.dt_warm_to_skin, jd_h_bin);
hr.du_warm = interval_avg_var(b10.jd, b10.du_warm, jd_h_bin);
hr.dt_warm = interval_avg_var(b10.jd, b10.dt_warm, jd_h_bin);
hr.dz_warm = interval_avg_var(b10.jd, b10.dz_warm, jd_h_bin);
hr.dt_warm_to_skin_s = interval_avg_var(b10.jd, b10.dt_warm_to_skin_s, jd_h_bin);
hr.du_warm_s = interval_avg_var(b10.jd, b10.du_warm_s, jd_h_bin);
hr.dt_warm_s = interval_avg_var(b10.jd, b10.dt_warm_s, jd_h_bin);
hr.dz_warm_s = interval_avg_var(b10.jd, b10.dz_warm_s, jd_h_bin);

%% recomputed fluxes and covariances and functions... 
% The averaged structure functions could make for smoother averaged fluxes 
% and stars. These have been tested and show zero improvement or change.

hr2.Cuab = (hr.Cua + hr.Cub)/ 2; % mean of methods a & b
hr2.Cwab = (hr.Cwa + hr.Cwb)/ 2; % mean of methods a & b
hr2.Ctab = (hr.Cta + hr.Ctb)/ 2; % mean of methods a & b
hr2.Cqab = (hr.Cqa + hr.Cqb)/ 2; % mean of methods a & b

clear ii; ii = hr2.Cqab<1e-4 | hr2.Cqab>1; hr.Cqab(ii) = nan;

% avg cu and cw for smoother structure function
hr2.Csab = (hr2.Cuab+(.75*hr2.Cwab))/2;
hr2.Csab(isnan(hr2.Cuab)) = .75*hr2.Cwab(isnan(hr2.Cuab));
hr2.Csab(isnan(hr2.Cwab)) = hr2.Cuab(isnan(hr2.Cwab) == 1);

% hr2.wtv     = -hr.usr.*(hr.tsr+.61.*(hr.ta+C2K).*hr.qsr); % virtual temp covariance. EXACT SAME as straight avg
% hr2.ws      = (9.83./(hr.ta+C2K).*abs(hr2.wtv)*600).^.333; % convective velocity. EXACT SAME as straight avg

% ID stars and fluxes
% convert complex numbers from psi_fu(zetay)
a = psi_fu(hr.zeta);
a(isnan(a)) = nanmedian(a);
hr2.usr_id = sqrt(hr2.Csab.*zu^0.667./a);  
% hr2.tau_id = hr.rhoa.*hr2.usr_id.*hr2.usr_id./hr.gust;  % the bulk method
% includes gustiness but the ID method doesn't need it. taken gustiness
% variance spectra and related it to the stress already.
hr2.tau_id = hr.rhoa.*hr2.usr_id.^2;
hr2.tsr_id_son = sqrt(hr2.Ctab.*zu^0.667./psi_ft(hr.zeta)).*sign(hr.tsr);
hr2.tsr_id = hr2.tsr_id_son-0.51*(hr.ta+C2K).*hr.qsr;
hr2.hs_id = -hr.rhoa*cpa.*hr.tsr_id.*hr2.usr_id;


hr2_zet_q = zq./hr.l;
hr2.qsr_id = sqrt(hr2.Cqab.*zu^.667./psi_ft(hr2_zet_q))*1e-3.*sign(hr.qsr);
clear ii; ii = hr2.qsr_id<-3e-4 | hr2.qsr_id>0; hr2.qsr_id(ii) = nan;
hr2.hl_id = -hr.rhoa.*hr.Le_w.*hr2.qsr_id.*hr2.usr_id + hr.hlwebb;

% cov fluxes

% from motcorr:        
% wT_cov = ( wTson_cov + 0.51*(x.ta+C2K).*x.usr.*x.qsr) ./ (1 + 0.51*x.qa*1E-3);
% hr2.wT_cov = hr.wTson_cov+0.51*(hr.ta+C2K).*hr.usr.*hr.qsr ./ (1 + 0.51*x.qa*1E-3);
% this is basically equivalent to hr.wT_cov but lacks the thresholding/filtering from before
% so deem it unnecessary.

hr2.hs_cov = hr.rhoa*cpa.*hr.wT_cov;
hr2.hs_cov_sds = hr.rhoa*cpa.*hr.wT_cov_sds;
hr2.hl_cov = 1E-3*hr.rhoa.*hr.Le_sw.*hr.wq_cov + hr.hlwebb;
hr2.hl_cov_sds = 1E-3*hr.rhoa.*hr.Le_sw.*hr.wq_cov_sds; % simon's version is already webb corrected

bad_hl_cov_sds = find(isnan(hr.hl_cov_sds) == 1);
hr2.hl_cov_sds(bad_hl_cov_sds) = nan;

hr2.tau_cov = -hr.rhoa.*hr.wu_cov;
hr2.tau_cov_cross = -hr.rhoa.*hr.wv_cov;

hr2 = orderfields(hr2);

%% plots to check hourly data
plot_hr2_checks = 0;
if plot_hr2_checks == 1

figure;
counter = 1;
thefields = fields(hr2);
nc = length(thefields);
for i = 1:4:nc
    clf;
    for j = 1:4
       if (i+j-1) <= nc
               subplot(2,2,j); hold on;
               eval(['var2 = hr2.' thefields{i+j-1} ';']);
               eval(['var1 = hr.' thefields{i+j-1} ';']);
               plot(hr.t, var2,'o');
               plot(hr.t, var1,'x');
               grid on;
               var_name = {strrep(thefields{i+j-1},'_',' ')};
               title(var_name);
               xlim([min(hr.t) max(hr.t)]);
               datetick('x','mm/dd','keeplimits');
               grid on;
               legend('v2','v1','location','southoutside','orientation','horizontal');
       end
    end
   print(graphdevice,[png_path '/check_hr2_' sprintf('%i',counter) '_' cruise graphformat]);
   counter = counter + 1;
end  % for: all vars
end  % if : plotting hr2 checks

%% replace hr2 fields into hr
% since these were deemed to show zero change to these variables, do not 
% change with hr2 fields. 
swap_hr2 = 0;
if swap_hr2 == 1
fhr2 = fields(hr2);
    for i = 1:length(fhr2)
        eval(['hr.' fhr2{i} ' = hr2. ' fhr2{i} ';']);
    end
end

%% fix integers data flags... set to 0 if nan or decimal place after avg-ing
ints = {'good_motion';'good_motion_id';'jplume';'jmanuv';...
    'good_motion_id_licor';'good_motion_licor';...
    'good_qsr_id';'good_tsr_id';'good_usr_id'};

for i = 1:length(ints)
    this = hr.(ints{i});
    bad_int = find(isnan(this) == 1 | mod(this,1) ~= 0);
    if ~isempty(bad_int)
        % could try this to save more data
        % this(bad_int) = round(this(bad_int)); 
        this(bad_int) = 0; % just says anything not perfect is bad
        hr.(ints{i}) = this;
    end
end


%% median hourly hl, hs, stress vs bulk & vs U
hr_u_bin=0:15; % wind bins for both sets of plots / fluxes

%%%%% latent
hr_hl_id_mean_u = nan(length(hr_u_bin),1);
hr_hl_id_med_u = nan(length(hr_u_bin),1);
hr_hl_mean_u = nan(length(hr_u_bin),1);
hr_hl_med_u = nan(length(hr_u_bin),1);
hr_hl_cov_mean_u = nan(length(hr_u_bin),1);
hr_hl_cov_med_u = nan(length(hr_u_bin),1);
hr_nh_u = nan(length(hr_u_bin),1);
% nu = nan(length(u_bin),1);  % just a repeat of u_bin... not needed.

for i=1:length(hr_u_bin)
    ii = find(floor(hr.wspd)==hr_u_bin(i));
    jj = find(isfinite(hr.hl_id(ii)) & isfinite(hr.hl(ii)) );
    if isempty(jj)
        hr_hl_id_mean_u(i) = nan;
        hr_hl_id_med_u(i) = nan;
        hr_hl_mean_u(i) = nan;
        hr_hl_med_u(i) = nan;
        hr_hl_cov_mean_u(i) = nan;
        hr_hl_cov_med_u(i) = nan;
        hr_nh_u(i) = 0;
%        nu(i) = nan;
    else
        hr_hl_id_mean_u(i) = nanmean(hr.hl_id(ii(jj)));
        hr_hl_id_med_u(i) = nanmedian(hr.hl_id(ii(jj)));
        hr_hl_cov_mean_u(i) = nanmean(hr.hl_cov(ii(jj)));
        hr_hl_cov_med_u(i) = nanmedian(hr.hl_cov(ii(jj)));
        hr_hl_mean_u(i) = nanmean(hr.hl(ii(jj)));
        hr_hl_med_u(i) = nanmedian(hr.hl(ii(jj)));
        hr_nh_u(i) = length(jj);
%        nu(i) = nanmean(ywspd(ii(jj)));
    end
end
% 

%%%%% sensible
hr_hs_id_mean_u = nan(length(hr_u_bin),1);
hr_hs_id_med_u = nan(length(hr_u_bin),1);
hr_hs_mean_u = nan(length(hr_u_bin),1);
hr_hs_med_u = nan(length(hr_u_bin),1);
hr_hs_cov_mean_u = nan(length(hr_u_bin),1);
hr_hs_cov_med_u = nan(length(hr_u_bin),1);
hr_ns_u = nan(length(hr_u_bin),1);
% nu = nan(length(u_bin),1);  % just a repeat of u_bin... not needed.

for i=1:length(hr_u_bin)
    ii = find(floor(hr.wspd)==hr_u_bin(i));
    jj = find(isfinite(hr.hs_id(ii)) & isfinite(hr.hs(ii)) );
    if isempty(jj)
        hr_hs_id_mean_u(i) = nan;
        hr_hs_id_med_u(i) = nan;
        hr_hs_mean_u(i) = nan;
        hr_hs_med_u(i) = nan;
        hr_hs_cov_mean_u(i) = nan;
        hr_hs_cov_med_u(i) = nan;
        hr_ns_u(i) = 0;
%        nu(i) = nan;
    else
        hr_hs_id_mean_u(i) = nanmean(hr.hs_id(ii(jj)));
        hr_hs_id_med_u(i) = nanmedian(hr.hs_id(ii(jj)));
        hr_hs_cov_mean_u(i) = nanmean(hr.hs_cov(ii(jj)));
        hr_hs_cov_med_u(i) = nanmedian(hr.hs_cov(ii(jj)));
        hr_hs_mean_u(i) = nanmean(hr.hs(ii(jj)));
        hr_hs_med_u(i) = nanmedian(hr.hs(ii(jj)));
        hr_ns_u(i) = length(jj);
%        nu(i) = nanmean(ywspd(ii(jj)));
    end
end
% 

%%%%% stress

hr_tau_med_u = nan(length(hr_u_bin),1); 
hr_tau_cov_med_u = nan(length(hr_u_bin),1); 
hr_tau_cov_cross_med_u = nan(length(hr_u_bin),1); 
hr_tau_id_med_u = nan(length(hr_u_bin),1); 
hr_tau_mean_u = nan(length(hr_u_bin),1); 
hr_tau_cov_mean_u = nan(length(hr_u_bin),1); 
hr_tau_cov_cross_mean_u = nan(length(hr_u_bin),1); 
hr_tau_id_mean_u = nan(length(hr_u_bin),1); 
hr_wu_med_u = nan(length(hr_u_bin),1); 
hr_wv_med_u = nan(length(hr_u_bin),1); 
hr_nt_u = nan(length(hr_u_bin),1); 
hr_nu_u = nan(length(hr_u_bin),1); 

for i=1:length(hr_u_bin)
    clear ii; ii = find(floor(hr.wspd)==hr_u_bin(i));
    clear ppp; ppp = find(isfinite(hr.tau_cov(ii)) & isfinite(hr.tau_cov_cross(ii)) & ...
        isfinite(hr.tau(ii)) & (hr.rdir(ii)>rdir_lo & hr.rdir(ii)<rdir_hi) & ...
        hr.tilt(ii)<tilt_lim);
    if isempty(ppp)
      hr_tau_med_u(i) = nan;
      hr_tau_cov_med_u(i) = nan;
      hr_tau_cov_cross_med_u(i) = nan;
      hr_tau_id_med_u(i) = nan;
      hr_wu_med_u(i) = nan;
      hr_wv_med_u(i) = nan;
      hr_nt_u(i) = 0;
      hr_nu_u(i) = nan;
      hr_tau_mean_u(i) = nan;
      hr_tau_cov_mean_u(i) = nan;
      hr_tau_cov_cross_mean_u(i) = nan;
      hr_tau_id_mean_u(i) = nan;
    else
      hr_tau_med_u(i) = nanmedian(hr.tau(ii(ppp)));
      hr_tau_cov_med_u(i) = nanmedian(hr.tau_cov(ii(ppp)));
      hr_tau_cov_cross_med_u(i) = nanmedian(hr.tau_cov_cross(ii(ppp)));
      hr_tau_id_med_u(i) = nanmedian(hr.tau_id(ii(ppp)));
      hr_wu_med_u(i) = nanmedian(hr.wu_cov(ii(ppp)));
      hr_wv_med_u(i) = nanmedian(hr.wv_cov(ii(ppp)));
      hr_nt_u(i) = length(ppp);
      hr_tau_mean_u(i) = nanmean(hr.tau(ii(ppp)));
      hr_tau_cov_mean_u(i) = nanmean(hr.tau_cov(ii(ppp)));
      hr_tau_cov_cross_mean_u(i) = nanmean(hr.tau_cov_cross(ii(ppp)));
      hr_tau_id_mean_u(i) = nanmean(hr.tau_id(ii(ppp)));
    end
end

% non-dimensional sigma-W vs. z/l
hr_phi_w_cov = sqrt(hr.wvar)./sqrt(-hr.wu_cov);  % nondim sigma-W from cov ustar
hr_phi_w_b = sqrt(hr.wvar)./hr.usr;              % nondim sigma-W from bulk ustar
hr_aa = hr.zeta>1e-4;      % selectors for stable
hr_bb = hr.zeta<-1e-4;     % selectors for convective
hr_zeta_a = 10.^(-3:0.25:2);            % stable z/l for K&F function
hr_zeta_b = -1*10.^(-3:0.25:2);         % convective z/l for K&F function
% non-dimensional sigma w from Kaimal & Finnigan, 1994, Eq. 1.33
hr_phi_w_af = 1.25*(1+0.2*hr_zeta_a);       % stable
hr_phi_w_bf = 1.25*(1-3*hr_zeta_b).^(1/3);  % convective

%% save all 1-min, 10-min, 60-min, and 1-day file

clear e1 e60 eday;

e60 = hr;
eday = day;

% save everything we changed in d10 (a lot) and d1 (just flags);
save(d10_outfile, 'd10');
save(d1_outfile, 'd1');

% e10 already exists. It is everything in d10 + b10 except the non time
% series fields from d10

%%%% alternatively, save e10 as everything in d10
% % combine b10 and [updated] d10.... everything, including multidimensional arrays! 
% bfields = fields(b10);
% 
% % copy d10 to e10
% e10 = d10;
% % add all fields from b10 to e10;
% for i = 1:length(bfields)
%     eval(['e10.' bfields{i} ' = b10.' bfields{i} ';']);
% end 

% copy d1 to e1
e1 = d1;
% add all fields from b1 to e1;
bfields = fields(b1);
for i = 1:length(bfields)
    eval(['e1.' bfields{i} ' = b1.' bfields{i} ';']);
end 

hr = orderfields(hr);

e1 = orderfields(e1);
e10 = orderfields(e10);
e60 = orderfields(e60);
eday = orderfields(eday);

%%% remove nan time periods at beginning / end due to EEZ
    % for eday, might want to exclude first and last because they are incomplete days
EEZ_1 = find(e1.t < datenum(2023,6,9,12,0,0) | e1.t >= datenum(2023,6,25,0,0,0));
EEZ_10 = find(e10.t < datenum(2023,6,9,12,0,0) | e10.t >= datenum(2023,6,25,0,0,0));
EEZ_60 = find(e60.t < datenum(2023,6,9,12,0,0) | e60.t >= datenum(2023,6,25,0,0,0));
EEZ_day = find(eday.t < datenum(2023,6,9,12,0,0) | eday.t >= datenum(2023,6,25,0,0,0));

fe1 = fields(e1);
fe10 = fields(e10);
fe60 = fields(e60);
fday = fields(day);

for i = 1:length(fe1)
    eval(['e1.' fe1{i} '(EEZ_1) = [];']);
end
for i = 1:length(fe10)
    eval(['e10.' fe10{i} '(EEZ_10) = [];']);
end
for i = 1:length(fe60)
    eval(['e60.' fe60{i} '(EEZ_60) = [];']);
end
for i = 1:length(fday)
    eval(['eday.' fday{i} '(EEZ_day) = [];']);
end

% check for nan time... should not be there
bad_time_1 = find(isnan(e1.t) == 1);
bad_time_10 = find(isnan(e10.t) == 1);
bad_time_60 = find(isnan(e60.t) == 1);
bad_time_day = find(isnan(eday.t) == 1);
if isempty(bad_time_1) == 0
    disp('WARNING -> time in e1 has NaN values, which should be fixed');
elseif isempty(bad_time_10) == 0
    disp('WARNING -> time in e10 has NaN values, which should be fixed');
elseif isempty(bad_time_60) == 0
    disp('WARNING -> time in e60 has NaN values, which should be fixed');
elseif isempty(bad_time_day) == 0
    disp('WARNING -> time in eday has NaN values, which should be fixed');
else
    disp('good news -> time has no NaN values');
end

disp(['  e1 lasts from ' datestr(e1.t(1),0)    ' - ' datestr(e1.t(end),0) ]);
disp([' e10 lasts from ' datestr(e10.t(1),0)   ' - ' datestr(e10.t(end),0) ]);
disp([' e60 lasts from ' datestr(e60.t(1),0)   ' - ' datestr(e60.t(end),0) ]);
disp(['eday lasts from ' datestr(eday.t(1),0)  ' - ' datestr(eday.t(end),0) ]);

%%% save
ename_1 = [e_outdir cruise '_1min_' file_out_version '.mat'];
ename_10 = [e_outdir cruise '_10min_' file_out_version '.mat'];
ename_hr = [e_outdir cruise '_60min_' file_out_version '.mat'];
ename_day = [e_outdir cruise '_daily_' file_out_version '.mat'];

save(ename_1, 'e1'); 
save(ename_10, 'e10'); 
save(ename_hr, 'e60'); 
save(ename_day,'eday'); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
plot_checks = 0;
if plot_checks == 1
%%% now check to see before after of fluxes. 
figure;
counter = 1;
thefields = fields(e60);
nc = length(thefields);
for i = 1:4:nc
    clf;
    for j = 1:4
       if (i+j-1) <= nc
           if strcmp(thefields{i+j-1},'hnet_cov') ~= 1 && ...
                   strcmp(thefields{i+j-1},'hnet_id') ~= 1 && ...
                   strcmp(thefields{i+j-1},'Cuw') ~= 1 && ...
                   strcmp(thefields{i+j-1},'Ctw') ~= 1 && ...
                   strcmp(thefields{i+j-1},'Cqw') ~= 1 
               subplot(2,2,j); hold on;
               eval(['newvar = e60.' thefields{i+j-1} ';']);
               eval(['oldvar = e10.' thefields{i+j-1} ';']);
               plot(e10.t, oldvar,'x');
               plot(e60.t, newvar,'o');
               grid on;
               var_name = {strrep(thefields{i+j-1},'_',' ')};
               title(var_name);
               xlim([min(hr.t) max(hr.t)]);
               datetick('x','DD','keeplimits');
               grid on;
               legend('10-min','hour','location','southoutside','orientation','horizontal');
           end
       end
    end
   print(graphdevice,[png_path '/check_' sprintf('%i',counter) '_' cruise graphformat]);
   counter = counter + 1;
end  % for: all vars
end % if: plotting


%% END and MAKE LEGACY PLOTS
disp(['FINISHED da_red PROCESSING ',cruise]);

plot_it = 1;
if plot_it == 1
     plot_da_red;
end


