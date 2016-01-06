function out = ridge_hkb(y,X)
%RIDGE Ridge regression.
%   B1 = RIDGE(Y,X) returns the vector B1 of regression coefficients
%   obtained by performing ridge regression of the response vector Y
%   on the predictors X using the Hoerl, Kennard and Baldwin (1975)
%   estimator for k, k=p*s2/(LSbeta_hat'LSbeta_hat). s2=model variance estimate from
%   least squares model and LSbeta_hat is the least squares estimate of
%   beta.  The design matrix CANNOT contain a column of 1's.  Both the data
%   and the design are demeaned in this process.  Further, the design
%   matrix is scaled so that X'X is a correlation matrix.  
%
%   Note this is not what the ridge.m script does, it scales the design so that each
%   column has mean=0 and sd=1.  Therefore the k values obtained in this
%   script will not give the same result if you were to plug that same k
%   value into ridge.m
% 
%   Note the HKB estimate here is not the same as the HKB estimate in R,
%   in 2 ways.  First, R counts the intercept in the degrees of freedom
%   when calculating s2, but since this isn't done in FSL, I haven't done
%   it here.  I'm assuming a model that starts with demeaned data and
%   design and doesn't model an intercept (demeaning is done within code,
%   so you don't need to do it ahead of time).  The second difference is
%   that R uses (p-2) rather than p in the calculation of k_hkb.  Since the
%   simulation study of Gibbons (1981) used the version with p and it
%   performed well, I have chosen to use it here as well.  It probably
%   doesn't matter much for our purposes since p will be quite large (p=98
%   vs p=100 will produce almost the same k_hkb).
%
%   If Y has n observations, X must be n-by-p (p>0) for consistency.
%
%   [b_hkb,k_hkb]=ridge_hkb(y,X) will produce a vector of parameter estimates, pe,
%   and k_hkb, the HKB estimate for k.  NOTE pe WILL BE IN THE ORIGINAL
%   UNITS.  Since the design is scaled as described above, the units of the
%   parameter estimates from a ridge regression must be rescaled and this is
%   the only way results are reported.  The unscaled version cannot be
%   obtained, since they are typically used for ridge traces, which we are
%   not using.
%
%   Jeanette Mumford Sept, 2007




if nargin < 2,              
    error('stats:ridge:TooFewInputs',...
          'Requires at least two input arguments.');      
end 


% Check that matrix (X) and left hand side (y) have compatible dimensions
[n,p] = size(X);

[n1,collhs] = size(y);
if n~=n1, 
    error('stats:ridge:InputSizeMismatch',...
          'The number of rows in Y must equal the number of rows in X.'); 
end 

if collhs ~= 1, 
    error('stats:ridge:InvalidData','Y must be a column vector.'); 
end

% Remove any missing values
wasnan = (isnan(y) | any(isnan(X),2));
if (any(wasnan))
   y(wasnan) = [];
   X(wasnan,:) = [];
   n = length(y);
end

% Normalize the columns of X so that X'X is a correlation matrix
mx = mean(X);
stdx = std(X,0,1)*sqrt(n-1);

idx = find(abs(stdx) < sqrt(eps(class(stdx)))); 
if any(idx)
  stdx(idx) = 1;
end

MX = mx(ones(n,1),:);
STDX = stdx(ones(n,1),:);
Z = (X - MX) ./ STDX;
if any(idx)
  Z(:,idx) = 1;
end

%demean y
ydm=y-mean(y);

%Compute the hkb estimate of k

bls=pinv(Z)*ydm;
s2_ls=(ydm-Z*bls)'*(ydm-Z*bls)/(n-p);
k_hkb=(p)*s2_ls/(bls'*bls);


% Compute the coefficient estimates

b_hkb=inv(Z'*Z+k_hkb*eye(p))*Z'*(ydm);


%unscale back to original units 
b_hkb = b_hkb./stdx';
bls = bls./stdx';

out.b_hkb=b_hkb;
out.k_hkb=k_hkb;
out.b_ls=bls;
