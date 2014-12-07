function A = changeTech(A, newtech)
%CHANGETTECH   Convert the entries of a CHEBMATRIX to another TECH.
%
% CHANGETECH(A, NEWTECH) converts the entries of a CHEBMATRIX A to another TECH
% NEWTECH.
%
% See also CHEBFUN/CHANGETECH.

% Copyright 2014 by The University of Oxford and The Chebfun Developers.
% See http://www.chebfun.org/ for Chebfun information.

% Empty case.
if ( isempty(A) )
    return
end

% CHANGETECH of a CHEBMATRIX with inf x inf block(s) is not supported.
s = cellfun(@(b) min(size(b)), A.blocks);
if ( ~all(isfinite(s(:))) )
    error('CHEBFUN:CHEBMATRIX:changeTech:notSupported', ...
       ['CHANGETECH of a CHEBMATRIX with inf x inf block(s)', ... 
        ' is not supported.']);
end

% Convert if necessary, using CHEBFUN/CHANGETECH.
A.blocks = cellfun(@(v) changeFunction(v, newtech), ...
	A.blocks, 'uniformOutput', false);

end

function f = changeFunction(f, newTech)
% CHANGEFUNCTION   Calls chebfun/changeTech if input argument is a CHEBFUN, does
%                  nothing if input is a scalar.
if ( isa(f, 'chebfun') )
    f = chebfun.changeTech(f, newTech);
end

end