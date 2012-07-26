module Mandelbrot (iterMandelbrot, isMandelbrot, iterMandelbrot_precise, isMandelbrot_precise, PreciseComplex, (<:+>))
    where

import Data.Complex
import Data.Ratio


-- Neatly represent complex numbers
type PreciseComplex = (Rational, Rational)
(<:+>) :: Rational -> Rational -> PreciseComplex
(<:+>) r i = (r, i)
-- Add complex numbers SHOULD BE DONE WITH A TYPECLASS INSTANCE
(<+>) :: PreciseComplex -> PreciseComplex -> PreciseComplex 
(<+>) (xx, xi) (yx, yi) = ((xx + yx), (xi + yi))
-- Multiply complex numbers SHOULD BE DONE WITH A TYPECLASS INSTANCE
(<*>) :: PreciseComplex -> PreciseComplex -> PreciseComplex 
(<*>) (xx, xi) (yx, yi) = ((xx*yx) - (abs (xi*yi)), (xx * yi) + (xi * yx))

-- Calculate the mandelbrot iteratively using rational numbers for precision
mandelbrot_precise :: PreciseComplex -> PreciseComplex -> PreciseComplex
mandelbrot_precise z c = (z <*> z) <+> c


{- 
    Returns limit - iterations to converge for the mandelbrot set, point c
-}
iterMandelbrot_precise :: PreciseComplex -> Integer -> Integer
iterMandelbrot_precise c limit = 
	    iterateZ startValue 0
	where	
	    startValue = (0%1) <:+> (0%1)
	    iterateZ z@(zr, zi) iter = 
		if ((zr*zr + zi*zi) > 4) || (iter >= limit) then
		    iter
		else
		    iterateZ (mandelbrot_precise z c) (iter + 1)

{- 
    Tests if a point (x,y) is within the mandelbrot set for a given iteration limit 
-}    
isMandelbrot_precise ::  PreciseComplex -> Integer -> Bool
isMandelbrot_precise c limit = iterMandelbrot_precise c limit > 0 



-- Runs a single iteration of the recurrence relation
mandelbrot :: (RealFloat a) => Complex a -> Complex a -> Complex a
mandelbrot z c = (z * z) + c


{- 
    Returns limit - iterations to converge for the mandelbrot set, point c
-}
iterMandelbrot :: (RealFloat a) => Complex a -> Integer -> Integer
iterMandelbrot c limit = 
	    iterateZ (0.0 :+ 0.0) 0
	where	
	    iterateZ z iter = 
		if ((magnitude z) > 2) || (iter >= limit) then
		    iter
		else
		    iterateZ (mandelbrot z c) (iter + 1)




{- 
    Tests if a point (x,y) is within the mandelbrot set for a given iteration limit 
-}    
isMandelbrot :: (RealFloat a) => Complex a -> Integer -> Bool
isMandelbrot c limit = iterMandelbrot c limit > 0 

