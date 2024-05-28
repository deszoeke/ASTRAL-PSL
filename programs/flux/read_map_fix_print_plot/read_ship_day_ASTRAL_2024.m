function ship_day = read_ship_day_ASTRAL_2024(path_working_ddd,ddd,yyyy,PosLims,SCS_adj,zp_ship,zq_ship)
%{
Reads hourly ship files at 1-sec interval for one day
returns structure with concatenated columns of each field
should be length of time = 86400 = 24 x 3600. 

The hourly structure should always return a 3600 member 1-sec data array.
Nans will be present when data are not. 

input parameters: path_working_ddd = path to daily data folder
                  ddd = julian date
                  yyyy = year string
                  PosLims = lat/lon limits for filtering position data
%}

fclose all;

% delta = double(1.0/86400);
% last = ddd + 86399*delta;
% jd_ref = ddd:delta:last;	% ref 1 Hz timestamp

jd = sprintf('%03i',ddd);
yr = sprintf('%04i',yyyy);

for hhh = 0:23              % cycle thru 24 hourly files
    hr = sprintf('%02i',hhh);
    dfl = fullfile(path_working_ddd,['scs0' yr(3:4),jd,hr,'_raw.txt']);
%     if exist(dfl,'file')==2
        [ship] = read_ship_ASTRAL_2024(dfl,ddd,hhh,PosLims,SCS_adj,zp_ship,zq_ship);
%     else
%         continue % no data this hour
%     end
    %%% 
    
    %%% only grab field names once. they will be same throughout. 
    if hhh ==0
%       disp('first file');
        ff = fields(ship);
        %%% load all variables
        for j = 1:length(ff)
            %%% grab field from small array and put in big array
            ship_day.(ff{j}) = ship.(ff{j});
        end
    else %% in case of all other hours
%       disp('rest of variables');
        %%% grab and put rest of variables in big array
        for j = 1:length(ff)
            ship_day.(ff{j}) = [ship_day.(ff{j}); ship.(ff{j})];
        end
    end  

end  %% array of all hours

end  %% end function
