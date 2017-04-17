function pass = test_randnfun2trig( pref )

if ( nargin == 0 ) 
    pref = chebfunpref();
end

rng(0)
f = randnfun2trig(.1);
pass(1) = (abs(mean2(f.^2)-1) < .1);
pass(2) = (abs(mean2(f)) < .1);

rng(0)
g = randnfun2trig(.1,[2 4 -1 1]);
pass(3) = abs( f(.5,.5) - g(3.5,.5) ) < 1e-12;

rng(0) 
h = randnfun2trig(.2,[-2 2 0 4]);
pass(4) = abs( f(.5,.5) - h(1,3) ) < 1e-12;

f = randnfun2trig(6);
pass(5) = norm(diff(f),'fro') == 0;


