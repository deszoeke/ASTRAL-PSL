function mot = read_motion_PISTON_MISOBOB_2019(dfl,ddd,hhh)
%{
reads mot file specified by dfl and returns array with the
following columns.

1   jd_ref      10 Hz timestamp
2   accx        x axis acceleration, m/s
3   accy        y axis acceleration, m/s
4   accz        z axis acceleration, m/s
5   ratex       x axis rotation rate, rad/s
6   ratey       y axis rotation rate, rad/s
7   ratez       z axis rotation rate, rad/s

input parameters: dfl = string path to mot file
                  ddd = julian date
                  hhh = hour

mot file format:
0000623 0.007414387,0.0370543,-0.01486218,0.1320339,0.1149606,-3.584933,0
         rate x       ratey      rate z     accx      accy       accz
In MotPak coordinates, y is bow-stern, x is port-stbd.  We swap
this assignment in the code below.

%}

%% reference timestamp
start = (ddd+hhh/24);
delta = double(1.0/864000);
last = start + 35999*delta;
tref = start:delta:last;

%% read data for MotionPak if file exists, if not return NaNs
if exist(dfl,'file')==2
    %% read file
    disp(['Reading mot file for hour ',int2str(hhh)]);
    flist = fopen(dfl,'r');
    temp = {};    % cell array will hold one line of data, as read from file
    z = [];       % destination matrix for data read from file
    while ~feof(flist)
        try
            % temp will be 1x9 cell array, cells will be ~36000x1 arrays
            temp = textscan(flist,'%2f%2f%3f %f %f %f %f %f %f %*[^\n]','delimiter', ', ','headerlines', 1,'emptyvalue',NaN);
            z = [z cell2mat(temp)'];  % 9x~36000 array
        catch
            for ii=1:9      % length of last cell reflects missing values from any/all fields
                if length(temp{1,ii})~=length(temp{1,9})
                    temp{1,ii}(length(temp{1,9})+1) = [];  %truncate length of all cells to length(temp{1,9})
                end
            end
            if ~isempty(temp{1,1})
                z = [z cell2mat(temp)'];  % dim 2 will be < 36000 here
            end
        end
    end
    fclose(flist);
    tmotion =  ddd + (hhh + (z(1,:)+(z(2,:)+z(3,:)/1000)/60)/60)/24;

    %% apply calibration constants & swap axes/change sign as needed
    %  Change signs and swap axes as necessary such that:
    %  +X is toward bow
    %  +Y is toward port
    %  +Z is up
    %  +rotation about the x-axis is port up (phi = roll)
    %  +rotation about the y-axis is bow down (theta = pitch)
    %  +rotation about the z-axis is bow to port (psi)

    % Sundstrand / Systron Donner combined system
    % calibration for Sundstrand rate meters and Systron accelerometers:
    % accx = (+z(7,:))/3.9969293*9.80;          % forward is positive
    % accy = (-z(8,:))/3.9604125*9.80;          % to port is positive
    % accz = (-z(9,:))/3.58409*9.80;            % up is positive
    %
    % ratex = (+z(5,:))/0.02502/180*pi;         % port up is positive phi
    % ratey = (-z(4,:))/0.02494/180*pi;         % bow down is positive theta
    % ratez = (-z(6,:))/0.02503/180*pi;         % bow to port is positive psi (right-handed)
    % Note: rate calib. is ~1/(100deg/s / 2.5Vdc) = 1/40 = 0.025

    % MotionPak - DB connector mounted facing bow.
    % Horizontal axes reassigned in this code: MotPak X = accy/ratey, MotPak Y = accx/ratex
    accx = (+z(8,:)+0)./3.7756.*9.80;       % forward is positive - MotPak Y channel
    accy = (+z(7,:)+0)./3.8215.*9.80;       % to port is positive - MotPak X channel
    accz = (-z(9,:)+0)./3.7005.*9.80;       % up is positive

    ratex = (+z(5,:)+0)/0.025/180*pi;       % port up is positive phi - MotPak Y channel
    ratey = (+z(4,:)+0)/0.025/180*pi;       % bow down is positive theta - MotPak X channel
    ratez = (-z(6,:)+0)/0.025023/180*pi;	% bow to port is positive psi (right-handed)

    %% compute gravity
    G = sqrt(mean(accx)^2+mean(accy)^2+mean(accz)^2);
    disp(['*** Gravity MotPak = ', num2str(G,'%6.5f')]);

    %% Format output to exactly 10 Hz
    mot = NaN(36000,7);
    mot(:,1) = tref;

    [~,zz,~] = unique(tmotion);
    mot(:,2) = interp1(tmotion(zz),accx(zz),tref,'linear','extrap');
    mot(:,3) = interp1(tmotion(zz),accy(zz),tref,'linear','extrap');
    mot(:,4) = interp1(tmotion(zz),accz(zz),tref,'linear','extrap');
    mot(:,5) = interp1(tmotion(zz),ratex(zz),tref,'linear','extrap');
    mot(:,6) = interp1(tmotion(zz),ratey(zz),tref,'linear','extrap');
    mot(:,7) = interp1(tmotion(zz),ratez(zz),tref,'linear','extrap');

    % fill in NaNs with nearest neighbor
    mot(:,2) = replace_NaN_nearest_neighbor(mot(:,2));
    mot(:,3) = replace_NaN_nearest_neighbor(mot(:,3));
    mot(:,4) = replace_NaN_nearest_neighbor(mot(:,4));
    mot(:,5) = replace_NaN_nearest_neighbor(mot(:,5));
    mot(:,6) = replace_NaN_nearest_neighbor(mot(:,6));
    mot(:,7) = replace_NaN_nearest_neighbor(mot(:,7));

else
    mot = NaN(36000,7);
    mot(:,1) = tref';
end

ii = 3000:3400;
dd = sprintf('%03i',ddd);
hh = sprintf('%02i',hhh);
secs = mod(mot(:,1),1)*86400 - hhh*3600;

end
