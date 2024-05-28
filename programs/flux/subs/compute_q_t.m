function [q_fast, T_fast] = compute_q_t(Ts,W_lic,T_bar,Q_bar,W_bar)
%{
computes high rate q' and T' from raw sonic Ts and Licor H2O mmol/m3

usage: [q_fast, T_fast] = compute_q_t(Ts,W_lic,T_bar,Q_bar,W_bar);

inputs: Ts: 10 Hz sonic temperature, C
        W_lic: 10 Hz Licor H2O number density, mmol/m3
        T_bar: mean T from T/RH sensor, C
        Q_bar: mean specific humidity from T/RH sensor, g/kg
        W_bar: mean H2O number density, mmol/m3

note: the number of elements in W-Bar and T_bar determines the number of
        fast data segments. i.e. length(W_bar)=6 divides fast data into
        6 segments (i.e. 10-min segments for hourly input data)
        W_bar and T_bar must be the same size.

outputs: q_fast: 10 Hz specific humidity, g/kg
         T_fast: 10 Hz temperature, deg C

%}

if length(W_bar) ~= length(T_bar)
    error('compute_q_t: W_bar & T_bar not equal length');
end;
if length(Ts) ~= length(W_lic)
    error('compute_q_t: W_lic & Ts not equal length');
end;

N = length(T_bar);          % number of data segments
Npts = floor(length(Ts)/N);	% points per data segment
if N*Npts ~= length(Ts)
    disp('compute_q_t WARNING: fast array not evenly divisible');
end;

T_bar_K = T_bar + 273.15;	% convert to deg K
Ts_K = Ts + 273.15;         % convert to deg K
q_bar = Q_bar/1000;         % convert to kg/kg
w_bar = W_bar/1000;         % mean H2O number density, moles/m3
w_lic = W_lic/1000;         % 10Hz H2O number density, moles/m3
T_fast = Ts*NaN;            % empty output arrays
q_fast = T_fast;


ii = 1;
for jj=1:N
    % solving two equations with two unknowns via inverse of 2x2 matrix
    % (w'/w) = a*q' + b*T'
    % Ts' = c*q' + d*T'
    % where A=[[a,b],[c,d]], defined below
    a = 1/(q_bar(jj)*(1 + (0.378/0.622)*q_bar(jj)));
    b = -1/T_bar_K(jj);
    c = 0.51*T_bar_K(jj);
    d = 1 + 0.51*q_bar(jj);
    det = a*d - b*c;     % matrix determinant
    % solve [x1,x2] = [A]^-1 [y1,y2]
    q_fast(ii:ii+Npts-1) = (d/det)*(w_lic(ii:ii+Npts-1)/w_bar(jj)) + (-b/det)*Ts_K(ii:ii+Npts-1);
    T_fast(ii:ii+Npts-1) = (-c/det)*(w_lic(ii:ii+Npts-1)/w_bar(jj)) + (a/det)*Ts_K(ii:ii+Npts-1);
    ii = ii + Npts;
end;

q_fast = q_fast*1000;     % output g/kg  and deg C
T_fast = T_fast - 273.15;
