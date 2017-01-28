function [f, p] = nufft( c, x, omega, type)
% CHEBFUN.NUFFT   Nonuniform fast Fourier transform
%
% [F, P] = CHEBFUN.NUFFT( C ) is the same as fft( C ). C must be a column
% vector. F = P(C) is a planned version of the fast transform. 
%
% F = CHEBFUN.NUFFT( C, X ) is a nonuniform fast Fourier transform of type
% 2, which computes the following sums in quasi-optimal complexity:
%
%       F_j = \sum_{k=0}^{N-1} C(K)*exp(-2*pi*1i*X(j)*k/N), 0<=j<=N-1.
%
% C and X must be column vectors of the same length.
%
% F = CHEBFUN.NUFFT( C, X, 2 ) is the same as CHEBFUN.NUFFT( C, X ).
%
% F = CHEBFUN.NUFFT( C, OMEGA, 1 ) is a nonuniform fast Fourier transform
% of type 1, which computes the following sums in quasi-optimal complexity:
%
%       F_j = \sum_{k=0}^{N-1} C(K)*exp(-2*pi*1i*j*OMEGA(k)/N), 0<=j<=N-1.
%
% F = CHEBFUN.NUFFT( C, X, OMEGA ) is a nonuniform fast Fourier transform
% of type 3, which computes the following sums in quasi-optimal complexity:
%
%       F_j = \sum_{k=0}^{N-1} C(K)*exp(-2*pi*1i*X(j)*OMEGA(k)/N), 0<=j<=N-1.
%
% F = CHEBFUN.NUFFT( C, X, 1, TOL), F = CHEBFUN.NUFFT(C, OMEGA, 2, TOL),
% and F = CHEBFUN.NUFFT( C, X, OMEGA, TOL ) are the same as above but with
% a tolerance of TOL. By default, TOL = eps.
%
% See also chebfun.inufft and chebfun.ndct. 

% Copyright 2017 by The University of Oxford and The Chebfun Developers.
% See http://www.chebfun.org/ for Chebfun information.

%%% DEVELOPER'S NOTE %%%
% The algorithm in this MATLAB script is based on the paper:
%
% [1] D. Ruiz--Antoln and A. Townsend, "A nonuniform fast Fourier transform
% based on low rank approximation", in preparation, 2016.
%
% This paper related the NUFFT to a FFT by low rank approximation.

if ( nargin == 1 )
    p = @(c) fft(c);
    f = p(c);
elseif ( nargin == 2 )
    % default to type 2 nufft
    [f, p] = nufft2( c, x, eps );
elseif ( nargin == 3 )
    type = omega;
    if ( numel(type) == 1 )
        if ( type == 1 )
            [f, p] = nufft1( c, x, eps);
        elseif ( type == 2 )
            [f, p] = nufft2( c, x, eps);
        elseif ( type<1 && type>0 && numel(c)>1 )
            tol = type;
            [f, p] = nufft1( c, x, tol);
        elseif ( numel(c) == 1 )
            [f, p] = nufft3( c, x, type, eps);
        else
            error('CHEBFUN::NUFFT::TYPE','Unrecognised NUFFT type.');
        end
    elseif ( numel(type) == size(c,1) )
        % NUFFT-III: 
        [f, p] = nufft3( c, x, omega, eps);
    else
        error('CHEBFUN::NUFFT::SYNTAX','Unrecognised number of arguments to NUFFT.')
    end
elseif ( nargin == 4 )
    if ( type == 3 )
        [f, p] = nufft3( c, x, omega, eps);
    end
end
end

function [f, p] = nufft1( c, omega, tol )
% NUFFT1   Compute the nonuniform FFT of type 1
% This is equivalent to tilde{F}_1*c, where we write
%          tilde{F}_1*c = \tilde{F}_2^T*c.

N = size(omega,1);
[~, t, gam] = FindAlgorithmicParameters( omega/N );
K = ceil(5*gam*exp(lambertw(log(10/tol)/gam/7)));
[u, v] = constructAK( omega/N, (0:N-1)', K );
In = speye( N );
p = @(c) sum( v.*(N*conj( ifft( full( In(:,t)*conj( repmat(c,1,K).*u )  ), [], 1) ) ), 2);
f = p(c); 
end

function [f, p] = nufft2( c, x, tol )
% NUFFT2  Compute the nonuniform FFT of type 2
% This is equivalent to tilde{F}_2*c. We write
%
%          tilde{F}_2*c \approx (A_K.*F)*c,
%
% where A_K is a rank K matrix and F is the DFT matrix.

[~, t, gam] = FindAlgorithmicParameters( x );
K = ceil(5*gam*exp(lambertw(log(10/tol)/gam/7)));
[u, v] = constructAK( x, (0:size(x,1)-1)', K );
In = speye(size(c,1));
p = @(c) sum(u.*(In(t,:)*fft( repmat(c,1,K).*v,[],1 )),2);
f = p(c);
end

function [f, p] = nufft3( c, x, omega, tol)
% NUFFT3   Compute the nonuniform FFT of type 3.
% This is equivalent to tilde{F}_3*c. 

N = size(x, 1); 
[s, t, gam] = FindAlgorithmicParameters( x );
K = ceil(5*gam*exp(lambertw(log(10/tol)/gam/7)));
t_vec = t - 1; 

% Construct low rank approximation to A.*B, see [1]: 
[u, v] = constructAK( x, omega, K );
On = ones(N,1);
D1 = repmat((On-(s-t_vec)/N),1,K);
D2 = repmat((s-t_vec)/N, 1, K);
D3 = repmat(exp(-2*pi*1i*omega),1,K);
u = [D1.*u D2.*u];
v = [ v D3.*v];

In = speye( N ); 
% Call NUFFT-I, plan it for efficiency: 
[f, p1] = nufft1( v(:,1).*c, omega, eps );
f = u(:,1).*(In(t,:)*f);
for s = 2:size(u,2) 
    f = f + u(:,s).*full(In(t,:)*p1(v(:,s).*c));
end

% TODO: 
% Add planning capability to NUFFT-III. 
p = [];
end

function [s, t, gam] = FindAlgorithmicParameters( x )
% Find algorithmic parameters.
%
%  s/N = closest equispaced gridpoint to x
%  t/N = closest equispaced FFT sample to x
%  gam = perturbation parameter

N = size(x, 1);
s = round(N*x);
t = mod(s, N) + 1;
gam = norm( N*x - s, inf);
end

function [u, v] = constructAK( x, omega, K )
% Construct a low rank approximation to
%
%     A_{jk} = exp(-2*pi*1i*(x-s_j/N)*k), 0<=j,k<=N-1,
%
% where |x_j-j/N|<= gam <=1/2.  See [1].

N = size(x, 1);
[s, ~, gam] = FindAlgorithmicParameters( x );
er = N*x - s;
scl = exp(-1i*pi*er);
u = repmat(scl,1,K).*(ChebP(K-1,er/gam)*Bessel_cfs(K, gam));
v = ChebP(K-1, 2*omega/N - 1);
end

function cfs = Bessel_cfs(K, gam)
% The bivarate Chebyshev coefficients for the function f(x,y) = exp(-i*x.*y)
% on the domain [-gam, gam]x[0,2*pi] are given by Lemma A.2 of Townsend's
% DPhil thesis.
arg = -gam*pi/2;
[pp,qq] = meshgrid(0:K-1);
cfs = 4*(1i).^qq.*besselj((pp+qq)/2,arg).*besselj((qq-pp)/2, arg);
cfs(2:2:end,1:2:end) = 0;
cfs(1:2:end,2:2:end) = 0;
cfs(1,:) = cfs(1,:)/2;
cfs(:,1) = cfs(:,1)/2;
end

function T = ChebP( n, x )
% Evaluate Chebyshev polynomials of degree 0,...,n at points in x. Use the
% three-term recurrence relation:
N = size(x, 1);
T = zeros(N, n+1);
T(:,1) = 1;
T(:,2) = x;
twoX = 2*x;
for k = 2:n
    T(:,k+1) = twoX.*T(:,k) - T(:,k-1);
end
end