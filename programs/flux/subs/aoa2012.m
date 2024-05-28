function [u,v,w,aoa] = aoa2012(um,vm,wm)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%      ----------------------------------------------------------------------------------------------------
%      Source code of correction of ultrasonic anemometer angle of attack errors under turbulent conditions
%      ----------------------------------------------------------------------------------------------------
% 
%      License
%         This work is licensed under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 United States License. 
%         http://creativecommons.org/licenses/by-nc-sa/3.0/us/
%         For more information about licensing the software commercially, please contact Taro Nakai at tnakai@iarc.uaf.edu.
%   
%      USAGE
%         To use this subroutine in your MATLAB program,
%         the function file should be included in the search path.
%
%      If the variables are set as;
%
%      aoa       : angle of attack (deg)
%      u, v, w   : true wind vectors (ms-1)
%      um, vm, wm: measured wind vectors (ms-1)
%
%      then the statement of subroutine will be;
%
%      [u, v, w, aoa] = aoa2012(um, vm, wm);
%   
%
%      Author: Taro Nakai
%         International Arctic Research Center, University of Alaska Fairbanks
%         Email: tnakai@iarc.uaf.edu, taro.nakai@gmail.com
%  
%      Last Updated: April 20, 2012 (Original subroutine in C/C++)
%      Translated to MATLAB: March 1, 2013
%
%      This program was tested with MATLAB (R2007a) Ver.7.4.0 in Windows 7 environment.
%   
%      Reference
%         Nakai, T., Shimoyama, K., 2012. Ultrasonic anemometer angle of attack errors under turbulent conditions. Agric. For. Meteorol., 162-163, 14-26.
%         Nakai, T., van der Molen, M.K., Gash, J.H.C., Kodama, Y., 2006. Correction of sonic anemometer angle of attack errors. Agric. For. Meteorol., 136, 19-30.
%   
%      Translated to Matlab: Hiroki Ikawa (hikawa.biomet@gmail.com)
%      International Arctic Research Center, University of Alaska Fairbanks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    [u,v,w,aoa] = aoa_Steffensen(um,vm,wm);

return;

function sinerr = mk_sinerr(x,wd)
    sinerr = ones(size(x))*NaN;

    % Sine correction function phi_sr(alpha, gamma)
    % Eqs. (10), (13), and (14) of Nakai and Shimoyama (submitted)

    a1 = -3.19818998552857E-10;
    a2 = -2.69824417931343E-8;
    a3 = 4.16728613218081E-6;
    a4 = 4.85252964763967E-4;
    a5 = 1.67354200080193E-2;
    b1 = 5.92731123831391E-10;
    b2 = 1.44129103378194E-7;
    b3 = 1.20670183305798E-5;
    b4 = 3.92584527104954E-4;
    b5 = 3.82901759130896E-3;

    I = find(x > 0); 
    x(I) = -1.*x(I);
    wd(I) = wd(I) + 180;

    sinerr = a1 * x.^5 + a2 * x.^4 + a3 * x.^3 + a4 * x.^2 + a5 * x + 1;
    sinerr = sinerr - sin(3 * wd * pi/180).*(b1 * x.^5 + b2 * x.^4 + b3 * x.^3 + b4 * x.^2 + b5 * x);

return;

function coserr = mk_coserr(x,wd)
    coserr = ones(size(x))*NaN;

    % Cosine correction function phi_cr(alpha, gamma)
    % Eqs. (11), (12), (15), and (16) of Nakai and Shimoyama (submitted)

    c1 = -1.20804470033571E-9;
    c2 = -1.58051314507891E-7;
    c3 = -4.95504975706944E-6;
    c4 = 1.60799801968464E-5;
    c5 = 1.28143810766839E-3;
    d1 = 2.2715401644872E-9;
    d2 = 3.85646200219364E-7;
    d3 = 2.03402753902096E-5;
    d4 = 3.94248403622007E-4;
    d5 = 9.18428193641156E-4;

    I = find(x > 0); 
    x(I) = -1.*x(I);
    wd(I) = wd(I) + 180;

    I = find(x < -70); 
    x(I) = -70;

    coserr = c1 * x.^5 + c2 * x.^4 + c3 * x.^3 + c4 * x.^2 + c5 * x + 1;
    coserr = coserr + sin(3 .* wd .* pi./180).*(d1 .* x.^5 + d2 .* x.^4 + d3 .* x.^3 + d4 .* x.^2 + d5 .* x);

return

function gx = mk_gx(x,wd,a)

    % nonlinear equation to solve

    sinerr = mk_sinerr(x, wd);
    coserr = mk_coserr(x, wd);

    gx     = atan( (a.*coserr) ./ sinerr) .* 180 ./ pi;

return;

function x3 = mk_Steffensen(x,wd,a)

% Appendix A of Nakai et al.(2006)
% Iterative solution for true angle of attack

    x0 = x; % first estimate for AoA
    x1 = ones(size(x))*NaN;
    x2 = ones(size(x))*NaN;
    x3 = ones(size(x))*NaN;

    I = find(~isnan(x0));
    while 1
        x1(I) = mk_gx(x0(I), wd(I), a(I));
        x2(I) = mk_gx(x1(I), wd(I), a(I));
        x3(I) = x2(I);	% output value for true AoA when abs(key(I)) < 0.01
        key = x2 - 2 * x1 + x0;

      I = find(abs(key) >= 0.01);

        if size(I,1) == 0 
            break;
        end

        x3(I) = x0(I) - (x1(I) - x0(I)).^2./key(I);
        x0(I) = x3(I);
    end
     
return;

function [u,v,w,aoa] = aoa_Steffensen(um,vm,wm)

ws = sqrt(um.^2 + vm.^2);
aoa = ones(size(um))*NaN;
wd  = ones(size(um))*NaN;

% First guess values for AoA

I  = find(ws == 0 & wm >= 0);  aoa(I) = ones(size(I)) *  90;
I  = find(ws == 0 & wm <  0);  aoa(I) = ones(size(I)) * -90;
I  = find(ws ~= 0);            aoa(I) = atan(wm(I)./ws(I)) .* 180/pi;

% 	Wind direction

I  = find(ws == 0);             wd(I) = 0;
I  = find(ws ~= 0 & vm >=  0);  wd(I) = 180-acos(um(I)./ws(I)).*180./pi;
I  = find(ws ~= 0 & vm <=  0);  wd(I) = 180+acos(um(I)./ws(I)).*180./pi;

% 	Steffensen's method --- iterative solution for true AoA

I      = find(ws ~= 0);
aoa(I) = mk_Steffensen(aoa(I), wd(I), wm(I)./ws(I) );

% 	compute sin and cos errors

sin_err = mk_sinerr(aoa, wd);

cos_err = mk_coserr(aoa, wd);

%   compute corrected wind vectors

I = find(wm == 0); aoa(I) = 0;

u = um ./ cos_err;
v = vm ./ cos_err;
w = wm ./ sin_err;

return; 