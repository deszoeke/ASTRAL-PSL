function [u, sn, ln, c, t, h, i, l, m]= assign_nc_info(the_fields, ...
    nfields, ins, ins_ship)
%%% see https://cfconventions.org/Data/cf-standard-names/74/build/cf-standard-name-table.html
%%% function to assign units, standard_name, long_names and comments to the variables of cruise data
%%% if a standard_name or comment or long name doesn't exist or isn't
%%% needed, save here as '' but then don't add it to the netcdf file. Best
%%% to exclude it rather than add an empty attribute

% NOTE: '_' underscores will automatically be changed to ' ' spaces at the
% end of the program. okay to leave them in these spaces for now. 

ii = {'ins_rain';'loc_rain';'zrain';...
'ins_sw1';'ins_sw2';'ins_lw1';'ins_lw2';'loc_rad';'zrad';...
'ins_t';'loc_t';'zt';...
'ins_q';'loc_q';'zq';...
'ins_p';'loc_p';'zp';...
'ins_u';'loc_u';'zu';...
'ins_lic';'loc_lic';'zlic';...
'ins_snk';'loc_snk';'zsnk';...
'ins_wxt';'loc_wxt';'zwxt';...
'ins_rosr';'loc_rosr';'zrosr';...
'ins_motion';'loc_motion';'zmotion';... 
'ins_gps';'loc_gps';'zgps';...
'ins_wave';'loc_wave';'zwave'};

ii_ship = {'ins_rain_ship';'loc_rain_ship';'zrain_ship';...
'ins_sw_ship';'ins_lw_ship';'loc_rad_ship';'zrad_ship';...
'ins_t_ship';'loc_t_ship';'zt_ship';...
'ins_q_ship';'loc_q_ship';'zq_ship';...
'ins_p_ship';'loc_p_ship';'zp_ship';...
'ins_u_ship';'loc_u_ship';'zu_ship';...
'ins_u2_ship';'loc_u2_ship';'zu2_ship';...
'ins_u3_ship';'loc_u3_ship';'zu3_ship';...
'ins_sea_ship';'loc_sea_ship';'zsea_ship';...
'ins_spdlog_ship';'loc_spdlog_ship';'zspdlog_ship'};

for a = 1:length(ii)
    eval([ii{a} ' = ins{a};'])
end

for a = 1:length(ii_ship)
    eval([ii_ship{a} ' = ins_ship{a};'])
end


u = cell(nfields,1);     
sn = cell(nfields,1);     
ln = cell(nfields,1);     
c = cell(nfields,1);    
t = cell(nfields,1);    
i = cell(nfields,1);    
h = cell(nfields,1);    
l = cell(nfields,1);    
m = cell(nfields,1);

%% long info

% time has to be taken care of manually

% more variables from evalflux, fixit, runmotcorr, and da_red

% evalflux:
% tsr_son
% coare output from ship?
% spd_log_u
% spd_log_v
% spd_log
% sogE, sogN, hedE, hedN, pitch or roll, 
% licor_AGC, licor_rhoa_dry, licor_qa, licor_qa_dry, licor_H20, licor_H2O_MR, 
% licor_Tbox, licor_Pbox, licor_CO2, licor_CO2_MR, licor_rh
% dtheta
% pair
% pair_s
% paccum, paccum_s, paccum_wxt
% pa_wxt, psealevel_wxt, rh_wxt, prate_wxt, paccum_wxt, wspd_wxt, wdir_wxt, rspd_wxt, rdir_wxt
% Ta_wxt, qa_wxt, rhoa_wxt, rUn_wxt, rUw_wxt
% CO2

% motcorr:
%         %%% new vars calculated in this program at 1 and 10 min
%         new_vars_both = {'uplat_std';'vplat_std';'wplat_std';...
%         'sog_min';'hed_min';'cog_min';'sog_max';'hed_max';'cog_max';...
%         'sog_std';'hed_std';'cog_std';'shed_std';'ched_std';...
%         'rdir_std';'uvar';'vvar';'wvar';'Tvar'};
%                     
%         %%% new vars calculated only at 10-min, which we can interpolate to
%         %%% 1-min in next program
%         new_vars_10 = {'tilt';'azm';...
%         'wu_cov';'wv_cov';'wq_cov';'wT_cov';'wTson_cov';'wq_cov_sds';'wT_cov_sds';'wCO2_cov';...
%         'missingSon';'badSon';'Tson_noise';'Tson_std';...
%         'usr_ida';'usr_idb';'tsr_ida';'tsr_idb';'qsr_ida';'qsr_idb';'L_ida';'L_idb';...
%         'hs_cov';'hs_cov_sds';'hl_cov';'hl_cov_sds';...
%         'Cua';'Cub';'Cwa';'Cwb';'Cta';'Ctb';'Cqa';'Cqb';...
%         'Fx';'Pu';'Pv';'Pw';'Pt';'Pq';'Cuw';'Cvw';'Ctw';'Cqw';'mu';'mu_q';'lag';...
%         'Un';'Ue';'rspd_new';'rspd_raw';'rdir_new';...
%         'wspd_new';'wdir_new';'ubar';'vbar';'wbar';'Tbar';...
%         'tau_cov';'tau_cov_cross';'tau_ida';'tau_idb';...
%         'hs_ida';'hs_idb';'hl_ida';'hl_idb';...
%         'good_motion';'good_motion_licor';'good_motion_id';'good_motion_id_licor';...
%         'wtv';'ws';'ug';'ugw';'ugu';'Le_w';'Le_sw';...
%         'licor_H2O_std';'licor_Pbox_std';'licor_CO2_std';'licor_qa_std';...
%         };
%              

%%%%%

u(ismember(the_fields,'year'))={'year'};
sn(ismember(the_fields,'year'))={''};
ln(ismember(the_fields,'year'))={'year'};
c(ismember(the_fields,'year'))={''};
t(ismember(the_fields,'year'))={'coordinate'};
h(ismember(the_fields,'year'))={''};
i(ismember(the_fields,'year'))={''};
l(ismember(the_fields,'year'))={''};
m(ismember(the_fields,'year'))={''};

u(ismember(the_fields,'month'))={'month'};
sn(ismember(the_fields,'month'))={''};
ln(ismember(the_fields,'month'))={'month'};
c(ismember(the_fields,'month'))={''};
t(ismember(the_fields,'month'))={'coordinate'};
h(ismember(the_fields,'month'))={''};
i(ismember(the_fields,'month'))={''};
l(ismember(the_fields,'month'))={''};
m(ismember(the_fields,'month'))={''};

u(ismember(the_fields,'day'))={'day'};
sn(ismember(the_fields,'day'))={''};
ln(ismember(the_fields,'day'))={'day'};
c(ismember(the_fields,'day'))={''};
t(ismember(the_fields,'day'))={'coordinate'};
h(ismember(the_fields,'day'))={''};
i(ismember(the_fields,'day'))={''};
l(ismember(the_fields,'day'))={''};
m(ismember(the_fields,'day'))={''};

u(ismember(the_fields,'hour'))={'UTC'};
sn(ismember(the_fields,'hour'))={''};
ln(ismember(the_fields,'hour'))={'hour'};
c(ismember(the_fields,'hour'))={''};
t(ismember(the_fields,'hour'))={'coordinate'};
h(ismember(the_fields,'hour'))={''};
i(ismember(the_fields,'hour'))={''};
l(ismember(the_fields,'hour'))={''};
m(ismember(the_fields,'hour'))={''};

u(ismember(the_fields,'minute'))={'UTC'};
sn(ismember(the_fields,'minute'))={''};
ln(ismember(the_fields,'minute'))={'minute'};
c(ismember(the_fields,'minute'))={''};
t(ismember(the_fields,'minute'))={'coordinate'};
h(ismember(the_fields,'minute'))={''};
i(ismember(the_fields,'minute'))={''};
l(ismember(the_fields,'minute'))={''};
m(ismember(the_fields,'minute'))={''};

u(ismember(the_fields,'lat'))={'degree_north'};
sn(ismember(the_fields,'lat'))={'latitude'};
ln(ismember(the_fields,'lat'))={'latitude'};
c(ismember(the_fields,'lat'))={''};
t(ismember(the_fields,'lat'))={'coordinate'};
h(ismember(the_fields,'lat'))={''};
i(ismember(the_fields,'lat'))={ins_gps};
l(ismember(the_fields,'lat'))={loc_gps};
m(ismember(the_fields,'lat'))={''};

u(ismember(the_fields,'lon'))={'degree_east'};
sn(ismember(the_fields,'lon'))={'longitude'};
ln(ismember(the_fields,'lon'))={'longitude'};
c(ismember(the_fields,'lon'))={''};
t(ismember(the_fields,'lon'))={'coordinate'};
h(ismember(the_fields,'lon'))={''};
i(ismember(the_fields,'lon'))={ins_gps};
l(ismember(the_fields,'lon'))={loc_gps};
m(ismember(the_fields,'lon'))={''};

u(ismember(the_fields,'cog'))={'degree'};
sn(ismember(the_fields,'cog'))={'platform_course'};
ln(ismember(the_fields,'cog'))={'course-over-ground'};
c(ismember(the_fields,'cog'))={''};
t(ismember(the_fields,'cog'))={'physicalMeasurement'};
h(ismember(the_fields,'cog'))={''};
i(ismember(the_fields,'cog'))={ins_gps};
l(ismember(the_fields,'cog'))={loc_gps};
m(ismember(the_fields,'cog'))={''};

u(ismember(the_fields,'sog'))={'m/s'};
sn(ismember(the_fields,'sog'))={'platform_speed_wrt_ground'};
ln(ismember(the_fields,'sog'))={'speed-over-ground'};
c(ismember(the_fields,'sog'))={''};
t(ismember(the_fields,'sog'))={'physicalMeasurement'};
h(ismember(the_fields,'sog'))={''};
i(ismember(the_fields,'sog'))={ins_gps};
l(ismember(the_fields,'sog'))={loc_gps};
m(ismember(the_fields,'sog'))={''};

u(ismember(the_fields,'heading'))={'degree'};
sn(ismember(the_fields,'heading'))={'platform_orientation'};
ln(ismember(the_fields,'heading'))={'heading'};
c(ismember(the_fields,'heading'))={''};
t(ismember(the_fields,'heading'))={'physicalMeasurement'};
h(ismember(the_fields,'heading'))={''};
i(ismember(the_fields,'heading'))={ins_gps};
l(ismember(the_fields,'heading'))={loc_gps};
m(ismember(the_fields,'heading'))={''};

u(ismember(the_fields,'flag_bad_ship'))={'1'};
sn(ismember(the_fields,'flag_bad_ship'))={''};
ln(ismember(the_fields,'flag_bad_ship'))={'flag 1 = ship maneuvering = questionable state variables and fluxes'};
c(ismember(the_fields,'flag_bad_ship'))={['0 = good, 1 = use with caution. Use to exclude questionable '...
    'state variables and bulk fluxes when ship was doing a maneuver (quick changes '...
    'in direction, speed, or platform motion). This could have impacted state variables '...
    'and bulk fluxes to some extent due to quickly changing conditions past sensors and/or flow distortion.']};
t(ismember(the_fields,'flag_bad_ship'))={'qualityInformation'};
h(ismember(the_fields,'flag_bad_ship'))={''};
i(ismember(the_fields,'flag_bad_ship'))={ins_gps};
l(ismember(the_fields,'flag_bad_ship'))={loc_gps};
m(ismember(the_fields,'flag_bad_ship'))={['past experience and examination of data suggest '...
    'these flags are necessary for screening and excluding bad flux and state variable data']};


u(ismember(the_fields,'jplume'))={'1'};
sn(ismember(the_fields,'jplume'))={''};
ln(ismember(the_fields,'jplume'))={'flag 1 = ship plume might be in path of sensors = questionable state variables and fluxes'};
c(ismember(the_fields,'jplume'))={['0 = good, 1 = use with caution. Use to exclude questionable '...
    'state variables and bulk fluxes when ship plume was in the path of the sensors. This could have impacted state variables '...
    'and bulk fluxes to some extent due to not having fresh air blowing into the sensors.']};
t(ismember(the_fields,'jplume'))={'qualityInformation'};
h(ismember(the_fields,'jplume'))={''};
i(ismember(the_fields,'jplume'))={ins_gps};
l(ismember(the_fields,'jplume'))={loc_gps};
m(ismember(the_fields,'jplume'))={['past experience and examination of data suggest '...
    'these flags are necessary for screening and excluding bad flux and state variable data']};

u(ismember(the_fields,'jmanuv'))={'1'};
sn(ismember(the_fields,'jmanuv'))={''};
ln(ismember(the_fields,'jmanuv'))={'flag 1 = ship maneuvering = questionable state variables and fluxes'};
c(ismember(the_fields,'jmanuv'))={['0 = good, 1 = use with caution. Use to exclude questionable '...
    'state variables and bulk fluxes when ship was doing a maneuver (quick changes '...
    'in direction, speed, or platform motion). This could have impacted state variables '...
    'and bulk fluxes to some extent due to quickly changing conditions past sensors and/or flow distortion.']};
t(ismember(the_fields,'jmanuv'))={'qualityInformation'};
h(ismember(the_fields,'jmanuv'))={''};
i(ismember(the_fields,'jmanuv'))={ins_gps};
l(ismember(the_fields,'jmanuv'))={loc_gps};
m(ismember(the_fields,'jmanuv'))={['past experience and examination of data suggest '...
    'these flags are necessary for screening and excluding bad flux and state variable data']};


u(ismember(the_fields,'flag_bad_bulk'))={'1'};
sn(ismember(the_fields,'flag_bad_bulk'))={''};
ln(ismember(the_fields,'flag_bad_bulk'))={'flag 1 = wind from aft = questionable state variables and bulk fluxes'};
c(ismember(the_fields,'flag_bad_bulk'))={['0 = good, 1 = use with caution. Use to exclude questionable state '...
    'variables and bulk fluxes when wind came from aft: |rdir| > 140 deg. This could have impacted ' ...
    'state variables and fluxes to some extent due to deck heating and flow distortion. The state variables and COARE bulk algorithm ' ...
    'output is likely okay to use but cannot be guaranteed to have the highest quality. ']};
t(ismember(the_fields,'flag_bad_bulk'))={'qualityInformation'};
h(ismember(the_fields,'flag_bad_bulk'))={''};
i(ismember(the_fields,'flag_bad_bulk'))={ins_u};
l(ismember(the_fields,'flag_bad_bulk'))={loc_u};
m(ismember(the_fields,'flag_bad_bulk'))={['past experience and examination of data suggest '...
    'these flags are necessary for screening and excluding bad bulk flux and state variable data ']};

u(ismember(the_fields,'flag_wspd'))={'1'};
sn(ismember(the_fields,'flag_bad_direct'))={''};
ln(ismember(the_fields,'flag_bad_direct'))={'flag 1 = bad direct (covariance) and inertial dissipation fluxes'};
c(ismember(the_fields,'flag_bad_direct'))={['0 = good, 1 = bad. Use to exclude bad '...
    'eddy covariance (direct) and inertial dissipation flux data. Do not use these '...
    'fluxes when flag = 1. When wind was not blowing directly into bow sensors, '...
    'meaning that |rdir| > 90 deg plus other ship motion related standard deviations '...
    'and rain rate were too high such that these conditions degraded all eddy '...
    'covariance and inertial dissipation fluxes']};
t(ismember(the_fields,'flag_bad_direct'))={'qualityInformation'};
h(ismember(the_fields,'flag_bad_direct'))={''};
i(ismember(the_fields,'flag_bad_direct'))={ins_u};
l(ismember(the_fields,'flag_bad_direct'))={loc_u};
m(ismember(the_fields,'flag_bad_direct'))={['past experience and examination of data suggest '...
    'these flags are necessary for screening and excluding bad covariance and inertial dissipation fluxes']};

u(ismember(the_fields,'flag_wspd'))={'1'};
sn(ismember(the_fields,'flag_wspd'))={''};
ln(ismember(the_fields,'flag_wspd'))={'flag 1 = data have been corrected with second aft sensor for wind directions from aft'};
c(ismember(the_fields,'flag_wspd'))={['0 = original quality controlled data, 1 = corrected with second aft sensor for wind directions from aft']};
t(ismember(the_fields,'flag_wspd'))={'qualityInformation'};
h(ismember(the_fields,'flag_wspd'))={''};
i(ismember(the_fields,'flag_wspd'))={ins_u};
l(ismember(the_fields,'flag_wspd'))={loc_u};
m(ismember(the_fields,'flag_wspd'))={['past experience and examination of data suggest '...
    'wind data need to be corrected with secondary aft sensor when wind direction is from aft']};

u(ismember(the_fields,'flag_tair'))={'1'};
sn(ismember(the_fields,'flag_tair'))={''};
ln(ismember(the_fields,'flag_tair'))={'flag 1 = data have been corrected with second aft sensor for wind directions from aft'};
c(ismember(the_fields,'flag_tair'))={['0 = original quality controlled data, 1 = corrected with second aft sensor for wind directions from aft']};
t(ismember(the_fields,'flag_tair'))={'qualityInformation'};
h(ismember(the_fields,'flag_tair'))={''};
i(ismember(the_fields,'flag_tair'))={ins_u};
l(ismember(the_fields,'flag_tair'))={loc_u};
m(ismember(the_fields,'flag_tair'))={['past experience and examination of data suggest '...
    'wind data need to be corrected with secondary aft sensor when wind direction is from aft']};




u(ismember(the_fields,'tair'))={'degree_Celsius'};
sn(ismember(the_fields,'tair'))={'air_temperature'};
ln(ismember(the_fields,'tair'))={['NOAA ' sprintf('%5.2f', zt) ' m air_temperature']};
c(ismember(the_fields,'tair'))={''};
t(ismember(the_fields,'tair'))={'physicalMeasurement'};
h(ismember(the_fields,'tair'))={zt};
i(ismember(the_fields,'tair'))={ins_t};
l(ismember(the_fields,'tair'))={loc_t};
m(ismember(the_fields,'tair'))={''};

u(ismember(the_fields,'tair_2'))={'degree_Celsius'};
sn(ismember(the_fields,'tair_2'))={'air_temperature'};
ln(ismember(the_fields,'tair_2'))={'NOAA 2 m air_temperature'};
c(ismember(the_fields,'tair_2'))={''};
t(ismember(the_fields,'tair_2'))={'modelResult'};
h(ismember(the_fields,'tair_2'))={2};
i(ismember(the_fields,'tair_2'))={ins_t};
l(ismember(the_fields,'tair_2'))={loc_t};
m(ismember(the_fields,'tair_2'))={'COARE 3.6, height adjusted'};

u(ismember(the_fields,'tair_2n'))={'degree_Celsius'};
sn(ismember(the_fields,'tair_2n'))={'air_temperature'};
ln(ismember(the_fields,'tair_2n'))={'NOAA 2 m air_temperature adjusted for neutral stability'};
c(ismember(the_fields,'tair_2n'))={''};
t(ismember(the_fields,'tair_2n'))={'modelResult'};
h(ismember(the_fields,'tair_2n'))={2};
i(ismember(the_fields,'tair_2n'))={ins_t};
l(ismember(the_fields,'tair_2n'))={loc_t};
m(ismember(the_fields,'tair_2n'))={'COARE 3.6, height adjusted'};

u(ismember(the_fields,'tair_10'))={'degree_Celsius'};
sn(ismember(the_fields,'tair_10'))={'air_temperature'};
ln(ismember(the_fields,'tair_10'))={'NOAA 10 m air_temperature'};
c(ismember(the_fields,'tair_10'))={''};
t(ismember(the_fields,'tair_10'))={'modelResult'};
h(ismember(the_fields,'tair_10'))={10};
i(ismember(the_fields,'tair_10'))={ins_t};
l(ismember(the_fields,'tair_10'))={loc_t};
m(ismember(the_fields,'tair_10'))={'COARE 3.6, height adjusted'};

u(ismember(the_fields,'tair_10n'))={'degree_Celsius'};
sn(ismember(the_fields,'tair_10n'))={'air_temperature'};
ln(ismember(the_fields,'tair_10n'))={'NOAA 10 m neutral air_temperature'};
c(ismember(the_fields,'tair_10n'))={''};
t(ismember(the_fields,'tair_10n'))={'modelResult'};
h(ismember(the_fields,'tair_10n'))={10};
i(ismember(the_fields,'tair_10n'))={ins_t};
l(ismember(the_fields,'tair_10n'))={loc_t};
m(ismember(the_fields,'tair_10n'))={'COARE 3.6, height adjusted, adusted for neutral stability'};

u(ismember(the_fields,'tair_ship'))={'degree_Celsius'};
sn(ismember(the_fields,'tair_ship'))={'air_temperature'};
ln(ismember(the_fields,'tair_ship'))={['ship ' sprintf('%5.2f', zt_ship) ' m air_temperature']};
c(ismember(the_fields,'tair_ship'))={''};
t(ismember(the_fields,'tair_ship'))={'physicalMeasurement'};
h(ismember(the_fields,'tair_ship'))={zt_ship};
i(ismember(the_fields,'tair_ship'))={ins_t_ship};
l(ismember(the_fields,'tair_ship'))={loc_t_ship};
m(ismember(the_fields,'tair_ship'))={''};

u(ismember(the_fields,'rhair'))={'%'};
sn(ismember(the_fields,'rhair'))={'relative_humidity'};
ln(ismember(the_fields,'rhair'))={['NOAA ' sprintf('%5.2f', zq) ' m relative_humidity']};
c(ismember(the_fields,'rhair'))={''};
t(ismember(the_fields,'rhair'))={'physicalMeasurement'};
h(ismember(the_fields,'rhair'))={zq};
i(ismember(the_fields,'rhair'))={ins_q};
l(ismember(the_fields,'rhair'))={loc_q};
m(ismember(the_fields,'rhair'))={''};

u(ismember(the_fields,'rhair_2'))={'%'};
sn(ismember(the_fields,'rhair_2'))={'relative_humidity'};
ln(ismember(the_fields,'rhair_2'))={'NOAA 2 m relative_humidity'};
c(ismember(the_fields,'rhair_2'))={''};
t(ismember(the_fields,'rhair_2'))={'modelResult'};
h(ismember(the_fields,'rhair_2'))={2};
i(ismember(the_fields,'rhair_2'))={ins_q};
l(ismember(the_fields,'rhair_2'))={loc_q};
m(ismember(the_fields,'rhair_2'))={'COARE 3.6, height adjusted'};

u(ismember(the_fields,'rhair_10'))={'%'};
sn(ismember(the_fields,'rhair_10'))={'relative_humidity'};
ln(ismember(the_fields,'rhair_10'))={'NOAA 10 m relative_humidity'};
c(ismember(the_fields,'rhair_10'))={''};
t(ismember(the_fields,'rhair_10'))={'modelResult'};
h(ismember(the_fields,'rhair_10'))={10};
i(ismember(the_fields,'rhair_10'))={ins_q};
l(ismember(the_fields,'rhair_10'))={loc_q};
m(ismember(the_fields,'rhair_10'))={'COARE 3.6, height adjusted'};

u(ismember(the_fields,'rhair_ship'))={'%'};
sn(ismember(the_fields,'rhair_ship'))={'relative_humidity'};
ln(ismember(the_fields,'rhair_ship'))={['ship ' sprintf('%5.2f', zq_ship) ' m relative_humidity']};
c(ismember(the_fields,'rhair_ship'))={''};
t(ismember(the_fields,'rhair_ship'))={'physicalMeasurement'};
h(ismember(the_fields,'rhair_ship'))={zq_ship};
i(ismember(the_fields,'rhair_ship'))={ins_q_ship};
l(ismember(the_fields,'rhair_ship'))={loc_q_ship};
m(ismember(the_fields,'rhair_ship'))={''};

u(ismember(the_fields,'qair'))={'g/kg'};
sn(ismember(the_fields,'qair'))={'specific_humidity'};
ln(ismember(the_fields,'qair'))={['NOAA ' sprintf('%5.2f', zq) ' m air specific humidity']};
c(ismember(the_fields,'qair'))={''};
t(ismember(the_fields,'qair'))={'physicalMeasurement'};
h(ismember(the_fields,'qair'))={zq};
i(ismember(the_fields,'qair'))={ins_q};
l(ismember(the_fields,'qair'))={loc_q};
m(ismember(the_fields,'qair'))={''};

u(ismember(the_fields,'qair_2'))={'g/kg'};
sn(ismember(the_fields,'qair_2'))={'specific_humidity'};
ln(ismember(the_fields,'qair_2'))={'NOAA 2 m air specific humidity'};
c(ismember(the_fields,'qair_2'))={''};
t(ismember(the_fields,'qair_2'))={'modelResult'};
h(ismember(the_fields,'qair_2'))={2};
i(ismember(the_fields,'qair_2'))={ins_q};
l(ismember(the_fields,'qair_2'))={loc_q};
m(ismember(the_fields,'qair_2'))={'COARE 3.6, height adjusted'};

u(ismember(the_fields,'qair_2n'))={'g/kg'};
sn(ismember(the_fields,'qair_2n'))={'specific_humidity'};
ln(ismember(the_fields,'qair_2n'))={'NOAA 2 m air specific humidity adjusted for neutral stability'};
c(ismember(the_fields,'qair_2n'))={''};
t(ismember(the_fields,'qair_2n'))={'modelResult'};
h(ismember(the_fields,'qair_2n'))={2};
i(ismember(the_fields,'qair_2n'))={ins_q};
l(ismember(the_fields,'qair_2n'))={loc_q};
m(ismember(the_fields,'qair_2n'))={'COARE 3.6, height adjusted'};


u(ismember(the_fields,'qair_10'))={'g/kg'};
sn(ismember(the_fields,'qair_10'))={'specific_humidity'};
ln(ismember(the_fields,'qair_10'))={'NOAA 10 m air specific humidity'};
c(ismember(the_fields,'qair_10'))={''};
t(ismember(the_fields,'qair_10'))={'modelResult'};
h(ismember(the_fields,'qair_10'))={10};
i(ismember(the_fields,'qair_10'))={ins_q};
l(ismember(the_fields,'qair_10'))={loc_q};
m(ismember(the_fields,'qair_10'))={'COARE 3.6, height adjusted'};

u(ismember(the_fields,'qair_10n'))={'g/kg'};
sn(ismember(the_fields,'qair_10n'))={'specific_humidity'};
ln(ismember(the_fields,'qair_10n'))={'NOAA 10 m neutral specific_humidity'};
c(ismember(the_fields,'qair_10n'))={''};
t(ismember(the_fields,'qair_10n'))={'modelResult'};
h(ismember(the_fields,'qair_10n'))={10};
i(ismember(the_fields,'qair_10n'))={ins_q};
l(ismember(the_fields,'qair_10n'))={loc_q};
m(ismember(the_fields,'qair_10n'))={'COARE 3.6, height adjusted, adjusted for neutral stability'};

u(ismember(the_fields,'qair_ship'))={'g/kg'};
sn(ismember(the_fields,'qair_ship'))={'specific_humidity'};
ln(ismember(the_fields,'qair_ship'))={['ship ' sprintf('%5.2f', zq_ship) ' m air specific humidity']};
c(ismember(the_fields,'qair_ship'))={''};
t(ismember(the_fields,'qair_ship'))={'physicalMeasurement'};
h(ismember(the_fields,'qair_ship'))={zq_ship};
i(ismember(the_fields,'qair_ship'))={ins_q_ship};
l(ismember(the_fields,'qair_ship'))={loc_q_ship};
m(ismember(the_fields,'qair_ship'))={''};

u(ismember(the_fields,'qair_lic'))={'g/kg'};
sn(ismember(the_fields,'qair_lic'))={'specific_humidity'};
ln(ismember(the_fields,'qair_lic'))={['NOAA licor ' sprintf('%5.2f', zlic) ' m air specific humidity']};
c(ismember(the_fields,'qair_lic'))={''};
t(ismember(the_fields,'qair_lic'))={'physicalMeasurement'};
h(ismember(the_fields,'qair_lic'))={zq};
i(ismember(the_fields,'qair_lic'))={ins_lic};
l(ismember(the_fields,'qair_lic'))={loc_lic};
m(ismember(the_fields,'qair_lic'))={''};

u(ismember(the_fields,'qair_std_lic'))={'g/kg'};
sn(ismember(the_fields,'qair_std_lic'))={''};
ln(ismember(the_fields,'qair_std_lic'))={['standard deviation of NOAA licor ' sprintf('%5.2f', zlic) ' m air specific humidity']};
c(ismember(the_fields,'qair_std_lic'))={''};
t(ismember(the_fields,'qair_std_lic'))={'physicalMeasurement'};
h(ismember(the_fields,'qair_std_lic'))={zq};
i(ismember(the_fields,'qair_std_lic'))={ins_lic};
l(ismember(the_fields,'qair_std_lic'))={loc_lic};
m(ismember(the_fields,'qair_std_lic'))={''};

u(ismember(the_fields,'co2_lic'))={'micromol/mol'};
sn(ismember(the_fields,'co2_lic'))={'specific_humidity'};
ln(ismember(the_fields,'co2_lic'))={['NOAA licor ' sprintf('%5.2f', zlic) ' m air CO2 concentration']};
c(ismember(the_fields,'co2_lic'))={''};
t(ismember(the_fields,'co2_lic'))={'physicalMeasurement'};
h(ismember(the_fields,'co2_lic'))={zq};
i(ismember(the_fields,'co2_lic'))={ins_lic};
l(ismember(the_fields,'co2_lic'))={loc_lic};
m(ismember(the_fields,'co2_lic'))={''};

u(ismember(the_fields,'co2_std_lic'))={'micromol/mol'};
sn(ismember(the_fields,'co2_std_lic'))={''};
ln(ismember(the_fields,'co2_std_lic'))={['standard deviation of NOAA licor ' sprintf('%5.2f', zlic) ' m air CO2 concentration']};
c(ismember(the_fields,'co2_std_lic'))={''};
t(ismember(the_fields,'co2_std_lic'))={'physicalMeasurement'};
h(ismember(the_fields,'co2_std_lic'))={zq};
i(ismember(the_fields,'co2_std_lic'))={ins_lic};
l(ismember(the_fields,'co2_std_lic'))={loc_lic};
m(ismember(the_fields,'co2_std_lic'))={''};

u(ismember(the_fields,'rhoair'))={'kg/m3'};
sn(ismember(the_fields,'rhoair'))={'air_density'};
ln(ismember(the_fields,'rhoair'))={['NOAA ' sprintf('%5.2f', zt) ' m air density']};
c(ismember(the_fields,'rhoair'))={''};
t(ismember(the_fields,'rhoair'))={'physicalMeasurement'};
h(ismember(the_fields,'rhoair'))={zt};
i(ismember(the_fields,'rhoair'))={''};
l(ismember(the_fields,'rhoair'))={''};
m(ismember(the_fields,'rhoair'))={'from T, q, p'};

u(ismember(the_fields,'rhoair_10'))={'kg/m3'};
sn(ismember(the_fields,'rhoair_10'))={'air_density'};
ln(ismember(the_fields,'rhoair_10'))={'NOAA air density adjusted to 10 m height'};
c(ismember(the_fields,'rhoair_10'))={''};
t(ismember(the_fields,'rhoair_10'))={'modelResult'};
h(ismember(the_fields,'rhoair_10'))={10};
i(ismember(the_fields,'rhoair_10'))={''};
l(ismember(the_fields,'rhoair_10'))={''};
m(ismember(the_fields,'rhoair_10'))={'COARE 3.6, height adjusted'};

u(ismember(the_fields,'rhoair_ship'))={'kg/m3'};
sn(ismember(the_fields,'rhoair_ship'))={'air_density'};
ln(ismember(the_fields,'rhoair_ship'))={['ship ' sprintf('%5.2f', zt_ship) ' m air density']};
c(ismember(the_fields,'rhoair_ship'))={''};
t(ismember(the_fields,'rhoair_ship'))={'physicalMeasurement'};
h(ismember(the_fields,'rhoair_ship'))={zt_ship};
i(ismember(the_fields,'rhoair_ship'))={''};
l(ismember(the_fields,'rhoair_ship'))={''};
m(ismember(the_fields,'rhoair_ship'))={'from ship T, q, p'};

u(ismember(the_fields,'prate'))={'mm/hr'};
sn(ismember(the_fields,'prate'))={'rainfall_rate'};
ln(ismember(the_fields,'prate'))={'rainfall_rate from NOAA optical gauge'};
c(ismember(the_fields,'prate'))={''};
t(ismember(the_fields,'prate'))={'physicalMeasurement'};
h(ismember(the_fields,'prate'))={zrain};
i(ismember(the_fields,'prate'))={ins_rain};
l(ismember(the_fields,'prate'))={loc_rain};
m(ismember(the_fields,'prate'))={''};

u(ismember(the_fields,'paccum'))={'mm'};
sn(ismember(the_fields,'paccum'))={'thickness_of_rainfall_amount'};
ln(ismember(the_fields,'paccum'))={'rainfall accumulation from NOAA optical gauge'};
c(ismember(the_fields,'paccum'))={''};
t(ismember(the_fields,'paccum'))={'physicalMeasurement'};
h(ismember(the_fields,'paccum'))={zrain};
i(ismember(the_fields,'paccum'))={ins_rain};
l(ismember(the_fields,'paccum'))={loc_rain};
m(ismember(the_fields,'paccum'))={''};

u(ismember(the_fields,'pair_10'))={'mbar'};
sn(ismember(the_fields,'pair_10'))={'air_pressure'};
ln(ismember(the_fields,'pair_10'))={'NOAA atmospheric pressure adjusted to 10 m height'};
c(ismember(the_fields,'pair_10'))={'to adjust heights: P_z=(psealevel - (0.125*z)'};
t(ismember(the_fields,'pair_10'))={'modelResult'};
h(ismember(the_fields,'pair_10'))={0};
i(ismember(the_fields,'pair_10'))={ins_p};
l(ismember(the_fields,'pair_10'))={loc_p};
m(ismember(the_fields,'pair_10'))={'height adjustment, to change use P_z=(psealevel - (0.125*z)'};

u(ismember(the_fields,'psealevel'))={'mbar'};
sn(ismember(the_fields,'psealevel'))={'air_pressure_at_mean_sea_level'};
ln(ismember(the_fields,'psealevel'))={'NOAA sea level atmospheric pressure'};
c(ismember(the_fields,'psealevel'))={'to adjust heights: P_z=(psealevel - (0.125*z)'};
t(ismember(the_fields,'psealevel'))={'modelResult'};
h(ismember(the_fields,'psealevel'))={0};
i(ismember(the_fields,'psealevel'))={ins_p};
l(ismember(the_fields,'psealevel'))={loc_p};
m(ismember(the_fields,'psealevel'))={'height adjustment, to change use P_z=(psealevel - (0.125*z)'};

u(ismember(the_fields,'psealevel_ship'))={'mbar'};
sn(ismember(the_fields,'psealevel_ship'))={'air_pressure_at_mean_sea_level'};
ln(ismember(the_fields,'psealevel_ship'))={'ship sea level atmospheric pressure'};
c(ismember(the_fields,'psealevel_ship'))={''};
t(ismember(the_fields,'psealevel_ship'))={'modelResult'};
h(ismember(the_fields,'psealevel_ship'))={0};
i(ismember(the_fields,'psealevel_ship'))={ins_p_ship};
l(ismember(the_fields,'psealevel_ship'))={loc_p_ship};
m(ismember(the_fields,'psealevel_ship'))={'height adjustment, to change use P_z=(psealevel - (0.125*z)'};

u(ismember(the_fields,'rdir'))={'degree'};
sn(ismember(the_fields,'rdir'))={'wind_to_direction'};
ln(ismember(the_fields,'rdir'))={['NOAA ' sprintf('%5.2f', zu) ' m relative wind direction']};
c(ismember(the_fields,'rdir'))={['0 means relative or apparent wind was incoming directly to bow of ship. '...
    'To convert from +/- 180 to 0-360 positive-to-north earth coordinates: '...
    'rdir2(rdir2<0)=rdir2(rdir2<0)+360;']};
t(ismember(the_fields,'rdir'))={'physicalMeasurement'};
h(ismember(the_fields,'rdir'))={zu};
i(ismember(the_fields,'rdir'))={ins_u};
l(ismember(the_fields,'rdir'))={loc_u};
m(ismember(the_fields,'rdir'))={'does not account for current velocity'};

u(ismember(the_fields,'rspd'))={'m/s'};
sn(ismember(the_fields,'rspd'))={'wind_speed'};
ln(ismember(the_fields,'rspd'))={['NOAA ' sprintf('%5.2f', zu) ' m relative wind speed']};
c(ismember(the_fields,'rspd'))={''};
t(ismember(the_fields,'rspd'))={'physicalMeasurement'};
h(ismember(the_fields,'rspd'))={zu};
i(ismember(the_fields,'rspd'))={ins_u};
l(ismember(the_fields,'rspd'))={loc_u};
m(ismember(the_fields,'rspd'))={'does not account for current velocity'};

u(ismember(the_fields,'wdir'))={'degree'};
sn(ismember(the_fields,'wdir'))={'wind_from_direction'};
ln(ismember(the_fields,'wdir'))={['NOAA ' sprintf('%5.2f', zu) ' m true wind direction']};
c(ismember(the_fields,'wdir'))={'meteorological convention from'};
t(ismember(the_fields,'wdir'))={'physicalMeasurement'};
h(ismember(the_fields,'wdir'))={zu};
i(ismember(the_fields,'wdir'))={ins_u};
l(ismember(the_fields,'wdir'))={loc_u};
m(ismember(the_fields,'wdir'))={'does not account for current velocity'};

u(ismember(the_fields,'wdir_ship'))={'degree'};
sn(ismember(the_fields,'wdir_ship'))={'wind_from_direction'};
ln(ismember(the_fields,'wdir_ship'))={['ship ' sprintf('%5.2f', zu_ship) ' m true wind direction']};
c(ismember(the_fields,'wdir_ship'))={'meteorological convention from'};
t(ismember(the_fields,'wdir_ship'))={'physicalMeasurement'};
h(ismember(the_fields,'wdir_ship'))={zu_ship};
i(ismember(the_fields,'wdir_ship'))={ins_u_ship};
l(ismember(the_fields,'wdir_ship'))={loc_u_ship};
m(ismember(the_fields,'wdir_ship'))={'does not account for current velocity'};

u(ismember(the_fields,'wdir_sfc'))={'degree'};
sn(ismember(the_fields,'wdir_sfc'))={'wind_from_direction'};
ln(ismember(the_fields,'wdir_sfc'))={['NOAA ' sprintf('%5.2f', zu) ' m true wind water-relative wind direction']};
c(ismember(the_fields,'wdir_sfc'))={'meteorological convention from'};
t(ismember(the_fields,'wdir_sfc'))={'physicalMeasurement'};
h(ismember(the_fields,'wdir_sfc'))={zu};
i(ismember(the_fields,'wdir_sfc'))={ins_u};
l(ismember(the_fields,'wdir_sfc'))={loc_u};
m(ismember(the_fields,'wdir_sfc'))={'accounts for current velocity'};

u(ismember(the_fields,'wspd'))={'m/s'};
sn(ismember(the_fields,'wspd'))={'wind_speed'};
ln(ismember(the_fields,'wspd'))={['NOAA ' sprintf('%5.2f', zu) ' m true wind_speed']};
c(ismember(the_fields,'wspd'))={''}; 
t(ismember(the_fields,'wspd'))={'physicalMeasurement'};
h(ismember(the_fields,'wspd'))={zu};
i(ismember(the_fields,'wspd'))={ins_u};
l(ismember(the_fields,'wspd'))={loc_u};
m(ismember(the_fields,'wspd'))={'does not account for current velocity'};

u(ismember(the_fields,'wspd_ship'))={'m/s'};
sn(ismember(the_fields,'wspd_ship'))={'wind_speed'};
ln(ismember(the_fields,'wspd_ship'))={['ship ' sprintf('%5.2f', zu_ship) ' m true wind_speed']};
c(ismember(the_fields,'wspd_ship'))={''};
t(ismember(the_fields,'wspd_ship'))={'physicalMeasurement'};
h(ismember(the_fields,'wspd_ship'))={zu_ship};
i(ismember(the_fields,'wspd_ship'))={ins_u_ship};
l(ismember(the_fields,'wspd_ship'))={loc_u_ship};
m(ismember(the_fields,'wspd_ship'))={'does not account for current velocity'};

u(ismember(the_fields,'wspd_sfc'))={'m/s'};
sn(ismember(the_fields,'wspd_sfc'))={'wind_speed'};
ln(ismember(the_fields,'wspd_sfc'))={['NOAA ' sprintf('%5.2f', zu) ' m true water-relative wind_speed']};
c(ismember(the_fields,'wspd_sfc'))={zu};
t(ismember(the_fields,'wspd_sfc'))={'modelResult'};
h(ismember(the_fields,'wspd_sfc'))={zu};
i(ismember(the_fields,'wspd_sfc'))={ins_u};
l(ismember(the_fields,'wspd_sfc'))={loc_u};
m(ismember(the_fields,'wspd_sfc'))={'accounts for current velocity'};

u(ismember(the_fields,'wspd_10n'))={'m/s'};
sn(ismember(the_fields,'wspd_10n'))={'wind_speed'};
ln(ismember(the_fields,'wspd_10n'))={'NOAA 10 m true water-relative neutral wind_speed'};
c(ismember(the_fields,'wspd_10n'))={''};
t(ismember(the_fields,'wspd_10n'))={'modelResult'};
h(ismember(the_fields,'wspd_10n'))={10};
i(ismember(the_fields,'wspd_10n'))={ins_u};
l(ismember(the_fields,'wspd_10n'))={loc_u};
m(ismember(the_fields,'wspd_10n'))={['COARE 3.6, adjusted for neutral stability and height, accounts for current velocity']};

u(ismember(the_fields,'wspd_10'))={'m/s'};
sn(ismember(the_fields,'wspd_10'))={'wind_speed'};
ln(ismember(the_fields,'wspd_10'))={'NOAA 10 m true water-relative wind_speed'};
c(ismember(the_fields,'wspd_10'))={''};
t(ismember(the_fields,'wspd_10'))={'modelResult'};
h(ismember(the_fields,'wspd_10'))={10};
i(ismember(the_fields,'wspd_10'))={ins_u};
l(ismember(the_fields,'wspd_10'))={loc_u};
m(ismember(the_fields,'wspd_10'))={'COARE 3.6, accounts for current velocity, height adjusted'};

u(ismember(the_fields,'wspd_2n'))={'m/s'};
sn(ismember(the_fields,'wspd_2n'))={'wind_speed'};
ln(ismember(the_fields,'wspd_2n'))={'NOAA 2 m true water-relative neutral wind_speed'};
c(ismember(the_fields,'wspd_2n'))={''};
t(ismember(the_fields,'wspd_2n'))={'modelResult'};
h(ismember(the_fields,'wspd_2n'))={10};
i(ismember(the_fields,'wspd_2n'))={ins_u};
l(ismember(the_fields,'wspd_2n'))={loc_u};
m(ismember(the_fields,'wspd_2n'))={['COARE 3.6, adjusted for neutral stability and height, accounts for current velocity']};

u(ismember(the_fields,'wspd_2'))={'m/s'};
sn(ismember(the_fields,'wspd_2'))={'wind_speed'};
ln(ismember(the_fields,'wspd_2'))={'NOAA 2 m true water-relative wind_speed'};
c(ismember(the_fields,'wspd_2'))={''};
t(ismember(the_fields,'wspd_2'))={'modelResult'};
h(ismember(the_fields,'wspd_2'))={10};
i(ismember(the_fields,'wspd_2'))={ins_u};
l(ismember(the_fields,'wspd_2'))={loc_u};
m(ismember(the_fields,'wspd_2'))={'COARE 3.6, accounts for current velocity, height adjusted'};


u(ismember(the_fields,'u'))={'m/s'};
sn(ismember(the_fields,'u'))={'eastward_wind'};
ln(ismember(the_fields,'u'))={['zonal W-to_E component ' sprintf('%5.2f', zu) ' m true wind']};
c(ismember(the_fields,'u'))={'meteorological convention from, positive to east'};
t(ismember(the_fields,'u'))={'physicalMeasurement'};
h(ismember(the_fields,'u'))={zu};
i(ismember(the_fields,'u'))={ins_u};
l(ismember(the_fields,'u'))={loc_u};
m(ismember(the_fields,'u'))={'from wspd and wdir, does not account for current velocity'};

u(ismember(the_fields,'v'))={'m/s'};
sn(ismember(the_fields,'v'))={'northward_wind'};
ln(ismember(the_fields,'v'))={['meridional S-to-N component ' sprintf('%5.2f', zu) ' m true wind']};
c(ismember(the_fields,'v'))={'meteorological convention from, positive to north'};
t(ismember(the_fields,'v'))={'physicalMeasurement'};
h(ismember(the_fields,'v'))={zu};
i(ismember(the_fields,'v'))={ins_u};
l(ismember(the_fields,'v'))={loc_u};
m(ismember(the_fields,'v'))={'from wspd and wdir, does not account for current velocity'};

u(ismember(the_fields,'u_sfc'))={'m/s'};
sn(ismember(the_fields,'u_sfc'))={'eastward_wind'};
ln(ismember(the_fields,'u_sfc'))={['zonal W-to_E component ' sprintf('%5.2f', zu) ' m true water-relative wind']};
c(ismember(the_fields,'u_sfc'))={'meteorological convention from, positive to east'};
t(ismember(the_fields,'u_sfc'))={'modelResult'};
h(ismember(the_fields,'u_sfc'))={zu};
i(ismember(the_fields,'u_sfc'))={ins_u};
l(ismember(the_fields,'u_sfc'))={loc_u};
m(ismember(the_fields,'u_sfc'))={'from wspd_sfc and wdir_sfc, accounts for current velocity'};

u(ismember(the_fields,'v_sfc'))={'m/s'};
sn(ismember(the_fields,'v_sfc'))={'northward_wind'};
ln(ismember(the_fields,'v_sfc'))={['meridional S-to-N component ' sprintf('%5.2f', zu) ' m  true water-relative wind']};
c(ismember(the_fields,'v_sfc'))={'meteorological convention from, positive to north'};
t(ismember(the_fields,'v_sfc'))={'modelResult'};
h(ismember(the_fields,'v_sfc'))={zu};
i(ismember(the_fields,'v_sfc'))={ins_u};
l(ismember(the_fields,'v_sfc'))={loc_u};
m(ismember(the_fields,'v_sfc'))={'from wspd_sfc and wdir_sfc, accounts for current velocity'};

u(ismember(the_fields,'u_10n'))={'m/s'};
sn(ismember(the_fields,'u_10n'))={'eastward_wind'};
ln(ismember(the_fields,'u_10n'))={'zonal W-to_E component 10 m true neutral water-relative wind'};
c(ismember(the_fields,'u_10n'))={'meteorological convention from, positive to east'};
t(ismember(the_fields,'u_10n'))={'modelResult'};
h(ismember(the_fields,'u_10n'))={10};
i(ismember(the_fields,'u_10n'))={ins_u};
l(ismember(the_fields,'u_10n'))={loc_u};
m(ismember(the_fields,'u_10n'))={['from wspd_10n and wdir, accounts for current velocity, adjusted for neutral stability and height']};

u(ismember(the_fields,'v_10n'))={'m/s'};
sn(ismember(the_fields,'v_10n'))={'northward_wind'};
ln(ismember(the_fields,'v_10n'))={'meridional S-to-N component 10 m true neutral water-relative wind '};
c(ismember(the_fields,'v_10n'))={'meteorological convention from, positive to north'};
t(ismember(the_fields,'v_10n'))={'physicalMeasurement'};
h(ismember(the_fields,'v_10n'))={10};
i(ismember(the_fields,'v_10n'))={ins_u};
l(ismember(the_fields,'v_10n'))={loc_u};
m(ismember(the_fields,'v_10n'))={'from wspd_10n and wdir, accounts for current velocity, adjusted for neutral stability and height'};

u(ismember(the_fields,'tskin'))={'degree_Celsius'};
sn(ismember(the_fields,'tskin'))={'sea_surface_skin_temperature'};
ln(ismember(the_fields,'tskin'))={'sea_surface_skin_temperature  '};
c(ismember(the_fields,'tskin'))={''};
t(ismember(the_fields,'tskin'))={'modelResult'};
h(ismember(the_fields,'tskin'))={0};
i(ismember(the_fields,'tskin'))={ins_snk};
l(ismember(the_fields,'tskin'))={loc_snk};
m(ismember(the_fields,'tskin'))={'COARE 3.6: tskin = tsea - dt_skin + dt_warm_to_skin'};

u(ismember(the_fields,'qskin'))={'g/kg'};
sn(ismember(the_fields,'qskin'))={''};
ln(ismember(the_fields,'qskin'))={'sea surface skin saturation specific humidity'};
c(ismember(the_fields,'qskin'))={''};
t(ismember(the_fields,'qskin'))={'modelResult'};
h(ismember(the_fields,'qskin'))={0};
i(ismember(the_fields,'qskin'))={ins_snk};
l(ismember(the_fields,'qskin'))={loc_snk};
m(ismember(the_fields,'qskin'))={'COARE 3.6 not including wave input'};

u(ismember(the_fields,'tsea'))={'degree_Celsius'};
sn(ismember(the_fields,'tsea'))={'sea_water_temperature'};
ln(ismember(the_fields,'tsea'))={[sprintf('%4.2f',zsnk) ' depth sea_water_temperature']};
c(ismember(the_fields,'tsea'))={''};
t(ismember(the_fields,'tsea'))={'physicalMeasurement'};
h(ismember(the_fields,'tsea'))={-1*zsnk};
i(ismember(the_fields,'tsea'))={ins_snk};
l(ismember(the_fields,'tsea'))={loc_snk};
m(ismember(the_fields,'tsea'))={'corrected -0.19 to account for data logger type so that coare tskin using tsea as input matches ROSR tskin'};

u(ismember(the_fields,'qsea'))={'degree_Celsius'};
sn(ismember(the_fields,'qsea'))={''};
ln(ismember(the_fields,'qsea'))={[sprintf('%4.2f',zsnk) ' depth sea_water_saturation specific humidity']};
c(ismember(the_fields,'qsea'))={''};
t(ismember(the_fields,'qsea'))={'modelResult'};
h(ismember(the_fields,'qsea'))={-1*zsnk};
i(ismember(the_fields,'qsea'))={ins_snk};
l(ismember(the_fields,'qsea'))={loc_snk};
m(ismember(the_fields,'qsea'))={['COARE 3.6 not including wave input']};


u(ismember(the_fields,'tsea_ship'))={'degree_Celsius'};
sn(ismember(the_fields,'tsea_ship'))={'sea_water_temperature'};
ln(ismember(the_fields,'tsea_ship'))={[sprintf('%4.2f',zsea_ship) ' depth sea_water_temperature']};
c(ismember(the_fields,'tsea_ship'))={''};
t(ismember(the_fields,'tsea_ship'))={'physicalMeasurement'};
h(ismember(the_fields,'tsea_ship'))={-1*zsea_ship};
i(ismember(the_fields,'tsea_ship'))={ins_sea_ship};
l(ismember(the_fields,'tsea_ship'))={loc_sea_ship};
m(ismember(the_fields,'tsea_ship'))={''};

u(ismember(the_fields,'tsea_in_ship'))={'degree_Celsius'};
sn(ismember(the_fields,'tsea_in_ship'))={'sea_water_temperature'};
ln(ismember(the_fields,'tsea_in_ship'))={[sprintf('%4.2f',zsea_ship) ' intake depth sea_water_temperature']};
c(ismember(the_fields,'tsea_in_ship'))={''};
t(ismember(the_fields,'tsea_in_ship'))={'physicalMeasurement'};
h(ismember(the_fields,'tsea_in_ship'))={-1*zsea_ship};
i(ismember(the_fields,'tsea_in_ship'))={ins_sea_ship};
l(ismember(the_fields,'tsea_in_ship'))={loc_sea_ship};
m(ismember(the_fields,'tsea_in_ship'))={''};

u(ismember(the_fields,'ssea_ship'))={'psu'};
sn(ismember(the_fields,'ssea_ship'))={'sea_water_salinity'};
ln(ismember(the_fields,'ssea_ship'))={[sprintf('%4.2f',zsea_ship) ' depth sea_water_salinity']};
c(ismember(the_fields,'ssea_ship'))={''};
t(ismember(the_fields,'ssea_ship'))={'physicalMeasurement'};
h(ismember(the_fields,'ssea_ship'))={-1*zsea_ship};
i(ismember(the_fields,'ssea_ship'))={ins_sea_ship};
l(ismember(the_fields,'ssea_ship'))={loc_sea_ship};
m(ismember(the_fields,'ssea_ship'))={['']};

u(ismember(the_fields,'qsea_ship'))={'g/kg'};
sn(ismember(the_fields,'qsea_ship'))={''};
ln(ismember(the_fields,'qsea_ship'))={[sprintf('%4.2f',zsea_ship) ' depth sea_water_saturation specific humidity']};
c(ismember(the_fields,'qsea_ship'))={''};
t(ismember(the_fields,'qsea_ship'))={'physicalMeasurement'};
h(ismember(the_fields,'qsea_ship'))={-1*zsea_ship};
i(ismember(the_fields,'qsea_ship'))={ins_sea_ship};
l(ismember(the_fields,'qsea_ship'))={loc_sea_ship};
m(ismember(the_fields,'qsea_ship'))={'COARE 3.6 not including wave input'};

u(ismember(the_fields,'dt_skin'))={'degree_Celsius'};
sn(ismember(the_fields,'dt_skin'))={''};
ln(ismember(the_fields,'dt_skin'))={['modeled temperature difference between '...
    'the base of the cool skin layer (subskin or bulk T) and the skin surface']};
c(ismember(the_fields,'dt_skin'))={'positive value means skin T is cooler than subskin T'};
t(ismember(the_fields,'dt_skin'))={'modelResult'};
h(ismember(the_fields,'dt_skin'))={''};
i(ismember(the_fields,'dt_skin'))={''};
l(ismember(the_fields,'dt_skin'))={''};
m(ismember(the_fields,'dt_skin'))={'COARE 3.6 not including wave input'};

u(ismember(the_fields,'dz_skin'))={'m'};
sn(ismember(the_fields,'dz_skin'))={''};
ln(ismember(the_fields,'dz_skin'))={'modeled depth or thickness for cool skin layer below the skin surface'};
c(ismember(the_fields,'dz_skin'))={''};
t(ismember(the_fields,'dz_skin'))={'modelResult'};
h(ismember(the_fields,'dz_skin'))={''};
i(ismember(the_fields,'dz_skin'))={''};
l(ismember(the_fields,'dz_skin'))={''};
m(ismember(the_fields,'dz_skin'))={'COARE 3.6 not including wave input'};

u(ismember(the_fields,'dt_warm'))={'degree_Celsius'};
sn(ismember(the_fields,'dt_warm'))={''};
ln(ismember(the_fields,'dt_warm'))={['modeled temperature difference between '...
    'base of entire warm layer and skin surface']};
c(ismember(the_fields,'dt_warm'))={['positive value means skin T is warmer '...
    'than T at base of warm layer']};
t(ismember(the_fields,'dt_warm'))={'modelResult'};
h(ismember(the_fields,'dt_warm'))={''};
i(ismember(the_fields,'dt_warm'))={''};
l(ismember(the_fields,'dt_warm'))={''};
m(ismember(the_fields,'dt_warm'))={'COARE 3.6 not including wave input'};

u(ismember(the_fields,'dz_warm'))={'m'};
sn(ismember(the_fields,'dz_warm'))={''};
ln(ismember(the_fields,'dz_warm'))={['modeled depth or thickness of entire '...
    'warm layer below the skin surface']};
c(ismember(the_fields,'dz_warm'))={''};
t(ismember(the_fields,'dz_warm'))={'modelResult'};
h(ismember(the_fields,'dz_warm'))={''};
i(ismember(the_fields,'dz_warm'))={''};
l(ismember(the_fields,'dz_warm'))={''};
m(ismember(the_fields,'dz_warm'))={'COARE 3.6 not including wave input'};

u(ismember(the_fields,'dt_warm_to_skin'))={'degree_Celsius'};
sn(ismember(the_fields,'dt_warm_to_skin'))={''};
ln(ismember(the_fields,'dt_warm_to_skin'))={['modeled temperature difference between '...
    'the subsurface measurement depth used as input to COARE and the skin surface']};
c(ismember(the_fields,'dt_warm_to_skin'))={['positive value means skin T is warmer '...
    'than T at the subsurface measurement depth used as input to COARE']};
t(ismember(the_fields,'dt_warm_to_skin'))={'modelResult'};
h(ismember(the_fields,'dt_warm_to_skin'))={''};
i(ismember(the_fields,'dt_warm_to_skin'))={''};
l(ismember(the_fields,'dt_warm_to_skin'))={''};
m(ismember(the_fields,'dt_warm_to_skin'))={'COARE 3.6 not including wave input'};

u(ismember(the_fields,'cspd'))={'m/s'};
sn(ismember(the_fields,'cspd'))={''};
ln(ismember(the_fields,'cspd'))={'mean 0-7 m ocean current speed'};
c(ismember(the_fields,'cspd'))={''};
t(ismember(the_fields,'cspd'))={'physicalMeasurement'};
h(ismember(the_fields,'cspd'))={0};
i(ismember(the_fields,'cspd'))={ins_spdlog_ship};
l(ismember(the_fields,'cspd'))={loc_spdlog_ship};
m(ismember(the_fields,'cspd'))={['residual based on ship speed log, cog, '...
    'sog, and heading; very similar to ADCP currents below ship']};

u(ismember(the_fields,'cdir'))={'degree'};
sn(ismember(the_fields,'cdir'))={'sea_water_velocity_to_direction'};
ln(ismember(the_fields,'cdir'))={'mean near-surface (0-7 m) current direction'};
c(ismember(the_fields,'cdir'))={'meteorological direction from'};
t(ismember(the_fields,'cdir'))={'physicalMeasurement'};
h(ismember(the_fields,'cdir'))={0};
i(ismember(the_fields,'cdir'))={ins_spdlog_ship};
l(ismember(the_fields,'cdir'))={loc_spdlog_ship};
m(ismember(the_fields,'cdir'))={['residual based on ship speed log, cog, '...
    'sog, and heading; very similar to ADCP currents below ship']};

u(ismember(the_fields,'wave_sigheight'))={'m'};
sn(ismember(the_fields,'wave_sigheight'))={'sea_surface_wave_significant_height'};
ln(ismember(the_fields,'wave_sigheight'))={'significant wave height'};
c(ismember(the_fields,'wave_sigheight'))={''};
t(ismember(the_fields,'wave_sigheight'))={'physicalMeasurement'};
h(ismember(the_fields,'wave_sigheight'))={0};
i(ismember(the_fields,'wave_sigheight'))={''};
l(ismember(the_fields,'wave_sigheight'))={''};
i(ismember(the_fields,'wave_sigheight'))={ins_wave};
l(ismember(the_fields,'wave_sigheight'))={loc_wave};
m(ismember(the_fields,'wave_sigheight'))={''};


u(ismember(the_fields,'wave_phasespd'))={'m/s'};
sn(ismember(the_fields,'wave_phasespd'))={''};
ln(ismember(the_fields,'wave_phasespd'))={'wave phase speed for spectral peak'};
c(ismember(the_fields,'wave_phasespd'))={''};
t(ismember(the_fields,'wave_phasespd'))={'physicalMeasurement'};
h(ismember(the_fields,'wave_phasespd'))={0};
i(ismember(the_fields,'wave_phasespd'))={ins_wave};
l(ismember(the_fields,'wave_phasespd'))={loc_wave};
m(ismember(the_fields,'wave_phasespd'))={'mean speed at spectral peak of measured wave spectrum'};

u(ismember(the_fields,'wave_period'))={'per s'};
sn(ismember(the_fields,'wave_period'))={''};
ln(ismember(the_fields,'wave_period'))={'wave period for spectral peak'};
c(ismember(the_fields,'wave_period'))={''};
t(ismember(the_fields,'wave_period'))={'physicalMeasurement'};
h(ismember(the_fields,'wave_period'))={0};
i(ismember(the_fields,'wave_period'))={ins_wave};
l(ismember(the_fields,'wave_period'))={loc_wave};
m(ismember(the_fields,'wave_period'))={'mean period at spectral peak of measured wave spectrum'};

u(ismember(the_fields,'wave_edis'))={'W/m^2'};
sn(ismember(the_fields,'wave_edis'))={''};
ln(ismember(the_fields,'wave_edis'))={'energy dissipated by wave breaking'};
c(ismember(the_fields,'wave_edis'))={''};
t(ismember(the_fields,'wave_edis'))={'modelResult'};
h(ismember(the_fields,'wave_edis'))={0};
i(ismember(the_fields,'wave_edis'))={''};
l(ismember(the_fields,'wave_edis'))={''};
m(ismember(the_fields,'wave_edis'))={'COARE 3.6 not including wave input'};

u(ismember(the_fields,'wave_whitecap_frac'))={'1'};
sn(ismember(the_fields,'wave_whitecap_frac'))={''};
ln(ismember(the_fields,'wave_whitecap_frac'))={'white cap fractional area or time'};
c(ismember(the_fields,'wave_whitecap_frac'))={''};
t(ismember(the_fields,'wave_whitecap_frac'))={'modelResult'};
h(ismember(the_fields,'wave_whitecap_frac'))={0};
i(ismember(the_fields,'wave_whitecap_frac'))={''};
l(ismember(the_fields,'wave_whitecap_frac'))={''};
m(ismember(the_fields,'wave_whitecap_frac'))={'COARE 3.6 not including wave input'};

u(ismember(the_fields,'sw_down'))={'W/m^2'};
sn(ismember(the_fields,'sw_down'))={'downwelling_shortwave_flux_in_air'};
ln(ismember(the_fields,'sw_down'))={'NOAA downwelling_shortwave_flux'};
c(ismember(the_fields,'sw_down'))={'positive into ocean'};
t(ismember(the_fields,'sw_down'))={'physicalMeasurement'};
h(ismember(the_fields,'sw_down'))={zrad};
i(ismember(the_fields,'sw_down'))={[ins_sw1 ' and ' ins_sw2]};
l(ismember(the_fields,'sw_down'))={loc_rad};
m(ismember(the_fields,'sw_down'))={'average of data from both radiometers'};

u(ismember(the_fields,'sw_down_ship'))={'W/m^2'};
sn(ismember(the_fields,'sw_down_ship'))={'downwelling_shortwave_flux'};
ln(ismember(the_fields,'sw_down_ship'))={'ship downwelling_shortwave_flux'};
c(ismember(the_fields,'sw_down_ship'))={'positive into ocean'};
t(ismember(the_fields,'sw_down_ship'))={'physicalMeasurement'};
h(ismember(the_fields,'sw_down_ship'))={zrad_ship};
i(ismember(the_fields,'sw_down_ship'))={ins_sw_ship};
l(ismember(the_fields,'sw_down_ship'))={loc_rad_ship};
m(ismember(the_fields,'sw_down_ship'))={''};

u(ismember(the_fields,'sw_down_clear'))={'W/m^2'};
sn(ismember(the_fields,'sw_down_clear'))={''};
ln(ismember(the_fields,'sw_down_clear'))={'NOAA downwelling_clear_sky_shortwave_flux'};
c(ismember(the_fields,'sw_down_clear'))={'positive into ocean'};
t(ismember(the_fields,'sw_down_clear'))={'modelResult'};
h(ismember(the_fields,'sw_down_clear'))={zrad};
i(ismember(the_fields,'sw_down_clear'))={[ins_sw1 ', ' ins_sw2 ', ' ins_q]};
l(ismember(the_fields,'sw_down_clear'))={loc_rad};
m(ismember(the_fields,'sw_down_clear'))={['clear sky model based on '...
    'date, time, location, aerosol loading, water vapor content, and that assumes '...
    'clear sky without clouds']};

u(ismember(the_fields,'sw_up'))={'W/m^2'};
sn(ismember(the_fields,'sw_up'))={'upwelling_shortwave_flux_in_air'};
ln(ismember(the_fields,'sw_up'))={'NOAA upwelling_shortwave_flux'};
c(ismember(the_fields,'sw_up'))={'positive into ocean'};
t(ismember(the_fields,'sw_up'))={'modelResult'};
h(ismember(the_fields,'sw_up'))={zrad};
i(ismember(the_fields,'sw_up'))={[ins_sw1 ' and ' ins_sw2]};
l(ismember(the_fields,'sw_up'))={loc_rad};
m(ismember(the_fields,'sw_up'))={'albedo model accounting for time, date, lat, lon, zenith angle'};

u(ismember(the_fields,'sw_up_ship'))={'W/m^2'};
sn(ismember(the_fields,'sw_up_ship'))={'upwelling_shortwave_flux_in_air'};
ln(ismember(the_fields,'sw_up_ship'))={'ship upwelling_shortwave_flux'};
c(ismember(the_fields,'sw_up_ship'))={'positive into ocean'};
t(ismember(the_fields,'sw_up_ship'))={'modelResult'};
h(ismember(the_fields,'sw_up_ship'))={zrad_ship};
i(ismember(the_fields,'sw_up_ship'))={ins_sw_ship};
l(ismember(the_fields,'sw_up_ship'))={loc_rad_ship};
m(ismember(the_fields,'sw_up_ship'))={'albedo model accounting for time, date, lat, lon, zenith angle'};

u(ismember(the_fields,'lw_down'))={'W/m^2'};
sn(ismember(the_fields,'lw_down'))={'downwelling_longwave_flux_in_air'};
ln(ismember(the_fields,'lw_down'))={'NOAA downwelling_longwave_flux'};
c(ismember(the_fields,'lw_down'))={'positive into ocean'};
t(ismember(the_fields,'lw_down'))={'physicalMeasurement'};
h(ismember(the_fields,'lw_down'))={zrad};
i(ismember(the_fields,'lw_down'))={[ins_lw1 ' and ' ins_lw2]};
l(ismember(the_fields,'lw_down'))={loc_rad};
m(ismember(the_fields,'lw_down'))={['average of data from both radiometers '...
    'after corrections to case and dome temps']};

u(ismember(the_fields,'lw_down_ship'))={'W/m^2'};
sn(ismember(the_fields,'lw_down_ship'))={'downwelling_longwave_flux_in_air'};
ln(ismember(the_fields,'lw_down_ship'))={'ship downwelling_longwave_flux'};
c(ismember(the_fields,'lw_down_ship'))={'positive into ocean'};
t(ismember(the_fields,'lw_down_ship'))={'physicalMeasurement'};
h(ismember(the_fields,'lw_down_ship'))={zrad_ship};
i(ismember(the_fields,'lw_down_ship'))={ins_lw_ship};
l(ismember(the_fields,'lw_down_ship'))={loc_rad_ship};
m(ismember(the_fields,'lw_down_ship'))={''};

u(ismember(the_fields,'lw_down_clear'))={'W/m^2'};
sn(ismember(the_fields,'lw_down_clear'))={''};
ln(ismember(the_fields,'lw_down_clear'))={'NOAA downwelling_clear_sky_longwave_flux'};
c(ismember(the_fields,'lw_down_clear'))={'positive into ocean'};
t(ismember(the_fields,'lw_down_clear'))={'modelResult'};
h(ismember(the_fields,'lw_down_clear'))={zrad};
i(ismember(the_fields,'lw_down_clear'))={[ins_lw1 ', ' ins_lw2 ', ' ins_q]};
l(ismember(the_fields,'lw_down_clear'))={loc_rad};
m(ismember(the_fields,'lw_down_clear'))={'clear sky model based on lat, lon, qair, tair assuming clear sky with no clouds'};

u(ismember(the_fields,'lw_up'))={'W/m^2'};
sn(ismember(the_fields,'lw_up'))={'upwelling_longwave_flux_in_air'};
ln(ismember(the_fields,'lw_up'))={'NOAA upwelling_longwave_flux'};
c(ismember(the_fields,'lw_up'))={'positive into ocean'};
t(ismember(the_fields,'lw_up'))={'modelResult'};
h(ismember(the_fields,'lw_up'))={zrad};
i(ismember(the_fields,'lw_up'))={[ins_lw1 ' and ' ins_lw2]};
l(ismember(the_fields,'lw_up'))={loc_rad};
m(ismember(the_fields,'lw_up'))={'COARE 3.6 not including wave input'};

u(ismember(the_fields,'lw_up_ship'))={'W/m^2'};
sn(ismember(the_fields,'lw_up_ship'))={'upwelling_longwave_flux_in_air'};
ln(ismember(the_fields,'lw_up_ship'))={'ship upwelling_longwave_flux'};
c(ismember(the_fields,'lw_up_ship'))={'positive into ocean'};
t(ismember(the_fields,'lw_up_ship'))={'modelResult'};
h(ismember(the_fields,'lw_up_ship'))={zrad_ship};
i(ismember(the_fields,'lw_up_ship'))={ins_lw_ship};
l(ismember(the_fields,'lw_up_ship'))={loc_rad_ship};
m(ismember(the_fields,'lw_up_ship'))={'COARE 3.6 not including wave input'};

%%%% for fluxes

u(ismember(the_fields,'hnet'))={'W/m^2'};
sn(ismember(the_fields,'hnet'))={'downward_heat_flux_in_air'};
ln(ismember(the_fields,'hnet'))={'bulk downward_net heat_flux'};
c(ismember(the_fields,'hnet'))={'positive into ocean; hnet > 0 is heating the ocean'};
t(ismember(the_fields,'hnet'))={'modelResult'};
h(ismember(the_fields,'hnet'))={0};
i(ismember(the_fields,'hnet'))={''};
l(ismember(the_fields,'hnet'))={''};
m(ismember(the_fields,'hnet'))={['COARE 3.6: hnet = sw_up + sw_down + '...
    'lw_up + lw_down + hl_bulk + hs_bulk + hrain']};

u(ismember(the_fields,'hb_bulk'))={'W/m^2'};
sn(ismember(the_fields,'hb_bulk'))={''};
ln(ismember(the_fields,'hb_bulk'))={'bulk surface upward buoyancy flux'};
c(ismember(the_fields,'hb_bulk'))={'positive generating buoyancy (turbulence) in the atmosphere'};
t(ismember(the_fields,'hb_bulk'))={'modelResult'};
h(ismember(the_fields,'hb_bulk'))={0};
i(ismember(the_fields,'hb_bulk'))={''};
l(ismember(the_fields,'hb_bulk'))={''};
m(ismember(the_fields,'hb_bulk'))={'COARE 3.6 not including wave input'};

u(ismember(the_fields,'hs_bulk'))={'W/m^2'};
sn(ismember(the_fields,'hs_bulk'))={'surface_downward_sensible_heat_flux'};
ln(ismember(the_fields,'hs_bulk'))={'bulk surface_downward_sensible_heat_flux'};
c(ismember(the_fields,'hs_bulk'))={'positive into ocean'};
t(ismember(the_fields,'hs_bulk'))={'modelResult'};
h(ismember(the_fields,'hs_bulk'))={0};
i(ismember(the_fields,'hs_bulk'))={''};
l(ismember(the_fields,'hs_bulk'))={''};
m(ismember(the_fields,'hs_bulk'))={'COARE 3.6 not including wave input'};

u(ismember(the_fields,'hs_cov'))={'W/m^2'};
sn(ismember(the_fields,'hs_cov'))={'surface_downward_sensible_heat_flux'};
ln(ismember(the_fields,'hs_cov'))={'covariance surface_downward_sensible_heat_flux'};
c(ismember(the_fields,'hs_cov'))={'positive into ocean'};
t(ismember(the_fields,'hs_cov'))={'modelResult'};
h(ismember(the_fields,'hs_cov'))={0};
i(ismember(the_fields,'hs_cov'))={''};
l(ismember(the_fields,'hs_cov'))={''};
m(ismember(the_fields,'hs_cov'))={'eddy covariance'};

u(ismember(the_fields,'hs_id'))={'W/m^2'};
sn(ismember(the_fields,'hs_id'))={'surface_downward_sensible_heat_flux'};
ln(ismember(the_fields,'hs_id'))={'inertial dissipation surface_downward_sensible_heat_flux'};
c(ismember(the_fields,'hs_id'))={'positive into ocean'};
t(ismember(the_fields,'hs_id'))={'modelResult'};
h(ismember(the_fields,'hs_id'))={0};
i(ismember(the_fields,'hs_id'))={''};
l(ismember(the_fields,'hs_id'))={''};
m(ismember(the_fields,'hs_id'))={'inertial dissipation'};

u(ismember(the_fields,'hl_bulk'))={'W/m^2'};
sn(ismember(the_fields,'hl_bulk'))={'surface_downward_latent_heat_flux'};
ln(ismember(the_fields,'hl_bulk'))={'bulk surface_downward_latent_heat_flux'};
c(ismember(the_fields,'hl_bulk'))={'positive into ocean'};
t(ismember(the_fields,'hl_bulk'))={'modelResult'};
h(ismember(the_fields,'hl_bulk'))={0};
i(ismember(the_fields,'hl_bulk'))={''};
l(ismember(the_fields,'hl_bulk'))={''};
m(ismember(the_fields,'hl_bulk'))={'COARE 3.6 not including wave input'};

u(ismember(the_fields,'hl_cov'))={'W/m^2'};
sn(ismember(the_fields,'hl_cov'))={'surface_downward_latent_heat_flux'};
ln(ismember(the_fields,'hl_cov'))={'covariance surface_downward_latent_heat_flux'};
c(ismember(the_fields,'hl_cov'))={'positive into ocean'};
t(ismember(the_fields,'hl_cov'))={'modelResult'};
h(ismember(the_fields,'hl_cov'))={0};
i(ismember(the_fields,'hl_cov'))={''};
l(ismember(the_fields,'hl_cov'))={''};
m(ismember(the_fields,'hl_cov'))={'eddy covariance'};

u(ismember(the_fields,'hl_id'))={'W/m^2'};
sn(ismember(the_fields,'hl_id'))={'surface_downward_latent_heat_flux'};
ln(ismember(the_fields,'hl_id'))={'inertial dissipation surface_downward_latent_heat_flux'};
c(ismember(the_fields,'hl_id'))={'positive into ocean'};
t(ismember(the_fields,'hl_id'))={'modelResult'};
h(ismember(the_fields,'hl_id'))={0};
i(ismember(the_fields,'hl_id'))={''};
l(ismember(the_fields,'hl_id'))={''};
m(ismember(the_fields,'hl_id'))={'inertial dissipation'};

u(ismember(the_fields,'hl_webb'))={'W/m^2'};
sn(ismember(the_fields,'hl_webb'))={''};
ln(ismember(the_fields,'hl_webb'))={'bulk webb correction already added to all latent heat flux values'};
c(ismember(the_fields,'hl_webb'))={'positive into ocean'};
t(ismember(the_fields,'hl_webb'))={'modelResult'};
h(ismember(the_fields,'hl_webb'))={0};
i(ismember(the_fields,'hl_webb'))={''};
l(ismember(the_fields,'hl_webb'))={''};
m(ismember(the_fields,'hl_webb'))={'COARE 3.6 not including wave input'};

u(ismember(the_fields,'hrain'))={'W/m^2'};
sn(ismember(the_fields,'hrain'))={'temperature_flux_due_to_rainfall_expressed_as_heat_flux_into_sea_water'};
ln(ismember(the_fields,'hrain'))={'bulk rain heat flux'};
c(ismember(the_fields,'hrain'))={'positive into ocean'};
t(ismember(the_fields,'hrain'))={'modelResult'};
h(ismember(the_fields,'hrain'))={0};
i(ismember(the_fields,'hrain'))={''};
l(ismember(the_fields,'hrain'))={''};
m(ismember(the_fields,'hrain'))={'COARE 3.6 not including wave input'};

u(ismember(the_fields,'tau_bulk'))={'N/m^2'};
sn(ismember(the_fields,'tau_bulk'))={'magnitude_of_surface_downward_stress'};
ln(ismember(the_fields,'tau_bulk'))={'bulk magnitude_of_surface_downward_stress assuming stress is all in the direction of the wind, i.e. streamwise stress'};
c(ismember(the_fields,'tau_bulk'))={''};
t(ismember(the_fields,'tau_bulk'))={'modelResult'};
h(ismember(the_fields,'tau_bulk'))={0};
i(ismember(the_fields,'tau_bulk'))={''};
l(ismember(the_fields,'tau_bulk'))={''};
m(ismember(the_fields,'tau_bulk'))={'COARE 3.6 not including wave input'};

u(ismember(the_fields,'tau_bulk_u'))={'N/m^2'};
sn(ismember(the_fields,'tau_bulk_u'))={''};
ln(ismember(the_fields,'tau_bulk_u'))={'bulk streamwise stress zonal W-to_E component'};
c(ismember(the_fields,'tau_bulk_u'))={'meteorological convention from, positive to east'};
t(ismember(the_fields,'tau_bulk_u'))={'modelResult'};
h(ismember(the_fields,'tau_bulk_u'))={0};
i(ismember(the_fields,'tau_bulk_u'))={''};
l(ismember(the_fields,'tau_bulk_u'))={''};
m(ismember(the_fields,'tau_bulk_u'))={'COARE 3.6 not including wave input'};

u(ismember(the_fields,'tau_bulk_v'))={'N/m^2'};
sn(ismember(the_fields,'tau_bulk_v'))={''};
ln(ismember(the_fields,'tau_bulk_v'))={'bulk streamwise stress meridional S-to-N component'};
c(ismember(the_fields,'tau_bulk_v'))={'meteorological convention from, positive to north'};
t(ismember(the_fields,'tau_bulk_v'))={'modelResult'};
h(ismember(the_fields,'tau_bulk_v'))={0};
i(ismember(the_fields,'tau_bulk_v'))={''};
l(ismember(the_fields,'tau_bulk_v'))={''};
m(ismember(the_fields,'tau_bulk_v'))={'COARE 3.6 not including wave input'};

u(ismember(the_fields,'tau_cov'))={'N/m^2'};
sn(ismember(the_fields,'tau_cov'))={'magnitude_of_surface_downward_stress'};
ln(ismember(the_fields,'tau_cov'))={'covariance streamwise magnitude_of_surface_downward_stress'};
c(ismember(the_fields,'tau_cov'))={'component of stress aligned with wind'};
t(ismember(the_fields,'tau_cov'))={'modelResult'};
h(ismember(the_fields,'tau_cov'))={0};
i(ismember(the_fields,'tau_cov'))={ins_u};
l(ismember(the_fields,'tau_cov'))={loc_u};
m(ismember(the_fields,'tau_cov'))={'eddy covariance'};

u(ismember(the_fields,'tau_cov_cross'))={'N/m^2'};
sn(ismember(the_fields,'tau_cov_cross'))={'magnitude_of_surface_downward_stress'};
ln(ismember(the_fields,'tau_cov_cross'))={'covariance crossstream magnitude_of_surface_downward_stress'};
c(ismember(the_fields,'tau_cov_cross'))={'component of stress not aligned with wind, positive to right of wind'};
t(ismember(the_fields,'tau_cov_cross'))={'modelResult'};
h(ismember(the_fields,'tau_cov_cross'))={0};
i(ismember(the_fields,'tau_cov_cross'))={ins_u};
l(ismember(the_fields,'tau_cov_cross'))={loc_u};
m(ismember(the_fields,'tau_cov_cross'))={'eddy covariance'};

u(ismember(the_fields,'tau_id'))={'N/m^2'};
sn(ismember(the_fields,'tau_id'))={'magnitude_of_surface_downward_stress'};
ln(ismember(the_fields,'tau_id'))={'inertial dissipation magnitude_of_surface_downward_stress'};
c(ismember(the_fields,'tau_id'))={''};
t(ismember(the_fields,'tau_id'))={'modelResult'};
h(ismember(the_fields,'tau_id'))={0};
i(ismember(the_fields,'tau_id'))={ins_u};
l(ismember(the_fields,'tau_id'))={loc_u};
m(ismember(the_fields,'tau_id'))={'inertial dissipation'};

u(ismember(the_fields,'tilt'))={'degree'};
sn(ismember(the_fields,'tilt'))={''};
ln(ismember(the_fields,'tilt'))={'mean tilt angle of wind into sonic anemometer'};
c(ismember(the_fields,'tilt'))={''};
t(ismember(the_fields,'tilt'))={'physicalMeasurement'};
h(ismember(the_fields,'tilt'))={zu};
i(ismember(the_fields,'tilt'))={ins_u};
l(ismember(the_fields,'tilt'))={loc_u};
m(ismember(the_fields,'tilt'))={''};

u(ismember(the_fields,'mo_length'))={'m'};
sn(ismember(the_fields,'mo_length'))={''};
ln(ismember(the_fields,'mo_length'))={'Monin-Obukhov length scale'};
c(ismember(the_fields,'mo_length'))={''};
t(ismember(the_fields,'mo_length'))={'modelResult'};
h(ismember(the_fields,'mo_length'))={''};
i(ismember(the_fields,'mo_length'))={''};
l(ismember(the_fields,'mo_length'))={''};
m(ismember(the_fields,'mo_length'))={'COARE 3.6 not including wave input'};

u(ismember(the_fields,'qstar'))={'kg/kg'};
sn(ismember(the_fields,'qstar'))={''};
ln(ismember(the_fields,'qstar'))={'bulk air specific humidity scaling parameter'};
c(ismember(the_fields,'qstar'))={''};
t(ismember(the_fields,'qstar'))={'modelResult'};
h(ismember(the_fields,'qstar'))={0};
i(ismember(the_fields,'qstar'))={''};
l(ismember(the_fields,'qstar'))={''};
m(ismember(the_fields,'qstar'))={'COARE 3.6 not including wave input'};

u(ismember(the_fields,'tstar'))={'Kelvin'};
sn(ismember(the_fields,'tstar'))={''};
ln(ismember(the_fields,'tstar'))={'bulk air temperature scaling parameter'};
c(ismember(the_fields,'tstar'))={''};
t(ismember(the_fields,'tstar'))={'modelResult'};
h(ismember(the_fields,'tstar'))={0};
i(ismember(the_fields,'tstar'))={''};
l(ismember(the_fields,'tstar'))={''};
m(ismember(the_fields,'tstar'))={'COARE 3.6 not including wave input'};

u(ismember(the_fields,'ustar'))={'m/s'};
sn(ismember(the_fields,'ustar'))={''};
ln(ismember(the_fields,'ustar'))={'bulk friction velocity that includes gustiness'};
c(ismember(the_fields,'ustar'))={''};
t(ismember(the_fields,'ustar'))={'modelResult'};
h(ismember(the_fields,'ustar'))={0};
i(ismember(the_fields,'ustar'))={''};
l(ismember(the_fields,'ustar'))={''};
m(ismember(the_fields,'ustar'))={'COARE 3.6 not including wave input'};

u(ismember(the_fields,'cd'))={''};
sn(ismember(the_fields,'cd'))={'surface_drag_coefficient_for_momentum_in_air'};
ln(ismember(the_fields,'cd'))={'surface_drag_coefficient_for_momentum'};
c(ismember(the_fields,'cd'))={''};
t(ismember(the_fields,'cd'))={'modelResult'};
h(ismember(the_fields,'cd'))={0};
i(ismember(the_fields,'cd'))={''};
l(ismember(the_fields,'cd'))={''};
m(ismember(the_fields,'cd'))={'COARE 3.6 not including wave input'};

u(ismember(the_fields,'ce'))={''};
sn(ismember(the_fields,'ce'))={''};
ln(ismember(the_fields,'ce'))={'latent heat transfer coefficient Dalton number'};
c(ismember(the_fields,'ce'))={''};
t(ismember(the_fields,'ce'))={'modelResult'};
h(ismember(the_fields,'ce'))={0};
i(ismember(the_fields,'ce'))={''};
l(ismember(the_fields,'ce'))={''};
m(ismember(the_fields,'ce'))={'COARE 3.6 not including wave input'};

u(ismember(the_fields,'ch'))={''};
sn(ismember(the_fields,'ch'))={''};
ln(ismember(the_fields,'ch'))={'sensible heat transfer coefficient Stanton number'};
c(ismember(the_fields,'ch'))={''};
t(ismember(the_fields,'ch'))={'modelResult'};
h(ismember(the_fields,'ch'))={0};
i(ismember(the_fields,'ch'))={''};
l(ismember(the_fields,'ch'))={''};
m(ismember(the_fields,'ch'))={'COARE 3.6 not including wave input'};

u(ismember(the_fields,'cdn10'))={''};
sn(ismember(the_fields,'cdn10'))={'surface_drag_coefficient_for_momentum_in_air'};
ln(ismember(the_fields,'cdn10'))={['neutral stability surface_drag_coefficient_for_momentum '...
    'adjusted to 10 m height']};
c(ismember(the_fields,'cdn10'))={''};
t(ismember(the_fields,'cdn10'))={'modelResult'};
h(ismember(the_fields,'cdn10'))={10};
i(ismember(the_fields,'cdn10'))={''};
l(ismember(the_fields,'cdn10'))={''};
m(ismember(the_fields,'cdn10'))={'COARE 3.6 not including wave input'};

u(ismember(the_fields,'cen10'))={''};
sn(ismember(the_fields,'cen10'))={''};
ln(ismember(the_fields,'cen10'))={['neutral stability latent heat transfer coefficient '...
    'Dalton number adjusted to 10 m height']};
c(ismember(the_fields,'cen10'))={''};
t(ismember(the_fields,'cen10'))={'modelResult'};
h(ismember(the_fields,'cen10'))={10};
i(ismember(the_fields,'cen10'))={''};
l(ismember(the_fields,'cen10'))={''};
m(ismember(the_fields,'cen10'))={'COARE 3.6 not including wave input'};

u(ismember(the_fields,'chn10'))={''};
sn(ismember(the_fields,'chn10'))={''};
ln(ismember(the_fields,'chn10'))={['neutral stability sensible heat transfer coefficient '...
    'Stanton number adjusted to 10 m height']};
c(ismember(the_fields,'chn10'))={''};
t(ismember(the_fields,'chn10'))={'modelResult'};
h(ismember(the_fields,'chn10'))={10};
i(ismember(the_fields,'chn10'))={''};
l(ismember(the_fields,'chn10'))={''};
m(ismember(the_fields,'chn10'))={'COARE 3.6 not including wave input'};

u(ismember(the_fields,'erate'))={'mm/hr'};
sn(ismember(the_fields,'erate'))={'evaporation_rate'}; % check
ln(ismember(the_fields,'erate'))={'evaporation_rate'};
c(ismember(the_fields,'erate'))={''};
t(ismember(the_fields,'erate'))={'modelResult'};
h(ismember(the_fields,'erate'))={0};
i(ismember(the_fields,'erate'))={''};
l(ismember(the_fields,'erate'))={''};
m(ismember(the_fields,'erate'))={'COARE 3.6 not including wave input'};

u(ismember(the_fields,'rough_u'))={'m'};
sn(ismember(the_fields,'rough_u'))={'surface_roughness_length_for_momentum_in_air'};
ln(ismember(the_fields,'rough_u'))={'surface_roughness_length_for_momentum'};
c(ismember(the_fields,'rough_u'))={''};
t(ismember(the_fields,'rough_u'))={'modelResult'};
h(ismember(the_fields,'rough_u'))={''};
i(ismember(the_fields,'rough_u'))={''};
l(ismember(the_fields,'rough_u'))={''};
m(ismember(the_fields,'rough_u'))={'COARE 3.6 not including wave input'};

u(ismember(the_fields,'rough_t'))={'m'};
sn(ismember(the_fields,'rough_t'))={'surface_roughness_length_for_heat_in_air'};
ln(ismember(the_fields,'rough_t'))={'surface_roughness_length_for_heat'};
c(ismember(the_fields,'rough_t'))={''};
t(ismember(the_fields,'rough_t'))={'modelResult'};
h(ismember(the_fields,'rough_t'))={''};
i(ismember(the_fields,'rough_t'))={''};
l(ismember(the_fields,'rough_t'))={''};
m(ismember(the_fields,'rough_t'))={'COARE 3.6 not including wave input'};

u(ismember(the_fields,'rough_q'))={'m'};
sn(ismember(the_fields,'rough_q'))={''};
ln(ismember(the_fields,'rough_q'))={'surface roughness length for humidity in air'};
c(ismember(the_fields,'rough_q'))={''};
t(ismember(the_fields,'rough_q'))={'modelResult'};
h(ismember(the_fields,'rough_q'))={0};
i(ismember(the_fields,'rough_q'))={''};
l(ismember(the_fields,'rough_q'))={''};
m(ismember(the_fields,'rough_q'))={'COARE 3.6 not including wave input'};

u(ismember(the_fields,'gust'))={'m/s'};
sn(ismember(the_fields,'gust'))={'wind_speed_of_gust'};
ln(ismember(the_fields,'gust'))={'wind_speed_of_gust or gustiness factor'};
c(ismember(the_fields,'gust'))={''};
t(ismember(the_fields,'gust'))={'modelResult'};
h(ismember(the_fields,'gust'))={0};
i(ismember(the_fields,'gust'))={''};
l(ismember(the_fields,'gust'))={''};
m(ismember(the_fields,'gust'))={'COARE 3.6 not including wave input'};

u(ismember(the_fields,'cu'))={'m2/s2'};
sn(ismember(the_fields,'cu'))={''};
ln(ismember(the_fields,'cu'))={'cu^2 structure function parameter'};
c(ismember(the_fields,'cu'))={''};
t(ismember(the_fields,'cu'))={'modelResult'};
h(ismember(the_fields,'cu'))={zu};
i(ismember(the_fields,'cu'))={ins_u};
l(ismember(the_fields,'cu'))={''};
m(ismember(the_fields,'cu'))={''};

u(ismember(the_fields,'cw'))={'m2/s2'};
sn(ismember(the_fields,'cw'))={''};
ln(ismember(the_fields,'cw'))={'cw^2 structure function parameter'};
c(ismember(the_fields,'cw'))={''};
t(ismember(the_fields,'cw'))={'modelResult'};
h(ismember(the_fields,'cw'))={zu};
i(ismember(the_fields,'cw'))={ins_u};
l(ismember(the_fields,'cw'))={''};
m(ismember(the_fields,'cw'))={''};

u(ismember(the_fields,'cq'))={'g2/kg2'};
sn(ismember(the_fields,'cq'))={''};
ln(ismember(the_fields,'cq'))={'cq^2 structure function parameter'};
c(ismember(the_fields,'cq'))={''};
t(ismember(the_fields,'cq'))={'modelResult'};
h(ismember(the_fields,'cq'))={zlic};
i(ismember(the_fields,'cq'))={ins_lic};
l(ismember(the_fields,'cq'))={''};
m(ismember(the_fields,'cq'))={''};

u(ismember(the_fields,'ct'))={'K^2'};
sn(ismember(the_fields,'ct'))={''};
ln(ismember(the_fields,'ct'))={'ct^2 structure function parameter'};
c(ismember(the_fields,'ct'))={''};
t(ismember(the_fields,'ct'))={'modelResult'};
h(ismember(the_fields,'ct'))={zu};
i(ismember(the_fields,'ct'))={ins_u};
l(ismember(the_fields,'ct'))={''};
m(ismember(the_fields,'ct'))={''};


u(ismember(the_fields,'uvar'))={'m2/s2'};
sn(ismember(the_fields,'uvar'))={''};
ln(ismember(the_fields,'uvar'))={'variance of u, 10 Hz streamwise wind speed'};
c(ismember(the_fields,'uvar'))={''};
t(ismember(the_fields,'uvar'))={'physicalMeasurement'};
h(ismember(the_fields,'uvar'))={zu};
i(ismember(the_fields,'uvar'))={ins_u};
l(ismember(the_fields,'uvar'))={''};
m(ismember(the_fields,'uvar'))={''};

u(ismember(the_fields,'vvar'))={'m2/s2'};
sn(ismember(the_fields,'vvar'))={''};
ln(ismember(the_fields,'vvar'))={'variance of v, 10 Hz cross-stream wind speed'};
c(ismember(the_fields,'vvar'))={''};
t(ismember(the_fields,'vvar'))={'physicalMeasurement'};
h(ismember(the_fields,'vvar'))={zu};
i(ismember(the_fields,'vvar'))={ins_u};
l(ismember(the_fields,'vvar'))={''};
m(ismember(the_fields,'vvar'))={''};

u(ismember(the_fields,'wvar'))={'m2/s2'};
sn(ismember(the_fields,'wvar'))={''};
ln(ismember(the_fields,'wvar'))={'variance of w, 10 Hz upward wind speed'};
c(ismember(the_fields,'wvar'))={''};
t(ismember(the_fields,'wvar'))={'physicalMeasurement'};
h(ismember(the_fields,'wvar'))={zu};
i(ismember(the_fields,'wvar'))={ins_u};
l(ismember(the_fields,'wvar'))={''};
m(ismember(the_fields,'wvar'))={''};

u(ismember(the_fields,'tvar'))={'K^2'};
sn(ismember(the_fields,'tvar'))={''};
ln(ismember(the_fields,'tvar'))={'variance of T, 10 Hz temperature'};
c(ismember(the_fields,'tvar'))={''};
t(ismember(the_fields,'tvar'))={'physicalMeasurement'};
h(ismember(the_fields,'tvar'))={zu};
i(ismember(the_fields,'tvar'))={ins_u};
l(ismember(the_fields,'tvar'))={''};
m(ismember(the_fields,'tvar'))={''};

u(ismember(the_fields,'qvar'))={'g2/kg2'};
sn(ismember(the_fields,'qvar'))={''};
ln(ismember(the_fields,'qvar'))={'variance of q, 10 Hz specific humidity'};
c(ismember(the_fields,'qvar'))={''};
t(ismember(the_fields,'qvar'))={'physicalMeasurement'};
h(ismember(the_fields,'qvar'))={zlic};
i(ismember(the_fields,'qvar'))={ins_lic};
l(ismember(the_fields,'qvar'))={''};
m(ismember(the_fields,'qvar'))={''};

%%% replace _ with space in long names
for a = 1:length(ln)
    ln(a) = {strrep(char(ln{a}),'_',' ')};
end
