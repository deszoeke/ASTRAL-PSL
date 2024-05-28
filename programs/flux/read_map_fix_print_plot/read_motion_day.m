function motm = read_motion_day(path_working_ddd,ddd,yyyy)
%{
Reads hourly motion files for one day
Loops through 24 hours, calling read_motion for each hour
Raw 10Hz data is averaged to 1Hz output

Inputs: path_working_ddd: path to daily folder containing hourly files
        ddd: day-of-year variable
        yyyy: year string

Output: motm: 86400 x 7 array of 1-Hz avg motion data
        Returns NaN for data gaps.

    1   jd_ref      10 Hz timestamp
    2   accx        x axis acceleration, m/s
    3   accy        y axis acceleration, m/s
    4   accz        z axis acceleration, m/s
    5   ratex       x axis rotation rate, rad/s
    6   ratey       y axis rotation rate, rad/s
    7   ratez       z axis rotation rate, rad/s
%}

fclose all;

motm = zeros(86400,7)*NaN;
delta = double(1.0/86400);
last = ddd + 86400*delta;
jd_ref = ddd:delta:last;	% ref 1 Hz timestamp
motm(:,1) = jd_ref(1:end-1)';
jd = sprintf('%03i',ddd);

for hhh = 0:23              % cycle thru 24 hourly motm files
    hr = sprintf('%02i',hhh);
    dfl = fullfile(path_working_ddd,['mot0' yyyy(3:4),jd,hr,'_raw.txt']);
    mot = read_motion_check(dfl,ddd,hhh);
    jdmot = mot(:,1);

    % average this hour's data into 1Hz motm array
    start = ddd + hhh/24.0; % jd start time this hour
    diff = jd_ref - start;  % look for closest time stamp to start
    [~,ii] = min(abs(diff));
    temp = interval_avg(jdmot, mot(:,2:7), jd_ref(ii:ii+3600)');
    motm(ii:ii+3599,2:7) = temp(:,2:7);
end
