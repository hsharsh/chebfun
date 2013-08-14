function out = checkSingTypes(f)
%CHECKSINGTYPES   Function to check types of exponents in a SINGFUN object.
%
%   The valid types can be 'sing', 'pole', 'branch' or 'none'. If the type 
%   is different than these four strings (ignoring case), an error message
%   is thrown.
%
% See also CLASSIFYEXPONENTS

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.chebfun.org/ for Chebfun information.

%%
out(1) = any(strcmpi(f.singType{1}, {'pole', 'sing', 'branch', 'none'}));
out(2) = any(strcmpi(f.singType{2}, {'pole', 'sing', 'branch', 'none'}));
if ( ~all(out) )
    error( 'CHEBFUN:SINGFUN:checkSingTypes', 'unknown singularity type' );
end

end