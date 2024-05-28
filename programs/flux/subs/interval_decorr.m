function [x1_out,mu] = interval_decorr(t1,x1,t2,X)

%{
    Decorrelates high-rate response x1 from predictor
       columns in array X over segments specified by
       bin edges in t2.
    Uses matlab regress function for multiple regression

    inputs:    t1     - N x 1 timestamp vector for x1 and X
               x1     - N x 1 signal response vector
               t2     - K x 1 vector of bin edges
               X      - N x M array for M predictor variables
                          first column should be ones for the constant coef
    outputs:   x1_out - decorrelated response signal
               mu     - (K-1) x (2M) array of correlation coefficients
                          - first M cols are w/respect to x1 (raw)
                          - last M cols are w/respect to x1_out (after decorr)
    
    This code assumes t1,x1 and X have the same number of rows and that
       bin edges in t2 fall within the range of times in t1.

    Adjust bin edges to omit points at the start or end of the time
       series if necessary to exclude N2 pulses or other transients.
%}
x1_out = x1;
[~,cc] = size(X); cc = cc-1; % number of predictor var in X - omit const
zz = length(t2)-1;     % number of segments to process
mu = NaN(zz,2*(cc));  % empty output array for before/after coefs
be = 1:length(t2);     % indices for bin edges

Xin = X;
Xin(:,2:end) = detrend(Xin(:,2:end));

for jj = 1:zz   % for each segment defined by the bin edges
    [~,ii] = min(abs(t1-t2(be(jj))));    % first point in this segment
    kk = find(t1<t2(be(jj)+1),1,'last'); % last point in this segment
    
    % compute mu w/respect to all predictor vars for raw input
    for yy = 1:cc
        CM = cov(detrend(x1(ii:kk)),detrend(X(ii:kk,yy+1)));
        mu(jj,yy) = CM(1,2)/CM(2,2);
    end
    
    % regression coefficients for this seg, 1st coef is constant;
    b = regress1(detrend(x1(ii:kk)),Xin(ii:kk,:));
    for xx = 2:length(b)   % skip constant coef b(1)
        % remove correlation w/respect to predictors X(:,xx)
        x1_out(ii:kk) = x1_out(ii:kk) - b(xx)*Xin(ii:kk,xx);
    end
    
    % recompute mu coefs after decorr
    for yy = 1:cc
        CM = cov(detrend(x1_out(ii:kk)),detrend(X(ii:kk,yy+1)));
        mu(jj,yy+cc) = CM(1,2)/CM(2,2);
    end
end

end

