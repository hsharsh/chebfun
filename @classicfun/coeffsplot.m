function varargout = coeffsplot(f, varargin)
%COEFFSPLOT    Display Chebyshev coefficients graphically.
%   COEFFSPLOT(F) assumes that the ONEFUN of F is based on Chebyshev technology.
%   If not, the method is expected to throw an error. The method plots the
%   Chebyshev coefficients of the ONEFUN of a CLASSICFUN F on a semilogy scale.
%   A horizontal line at the EPSLEVEL of F.ONEFUN is also plotted. If F is an
%   array-valued CLASSICFUN then a curve is plotted for each component (column)
%   of F.
%
%   COEFFSPLOT(F, S) allows further plotting options, such as linestyle,
%   linecolor, etc, in the standard MATLAB manner. If S contains a string
%   'LOGLOG', the coefficients will be displayed on a log-log scale. If S
%   contains a string 'NOEPSLEVEL', the EPSLEVEL is not plotted.
%
%   H = COEFFSPLOT(F) returns a column vector of handles to lineseries
%   objects. The final entry is that of the EPSLEVEL plot.
%
%   This method is mainly aimed at Chebfun developers.
%
% See also CHEBCOEFFS, PLOT.

% Copyright 2014 by The University of Oxford and The Chebfun Developers.
% See http://www.chebfun.org/ for Chebfun information.

% Deal with an empty input:
if ( isempty(f) )
    if ( nargout == 1 )
        [varargout{1:nargout}] = plot([]);
    end
    return
end

% Call COEFFSPLOT() on the ONEFUN of F.
[varargout{1:nargout}] = coeffsplot(f.onefun, varargin{:});

end
