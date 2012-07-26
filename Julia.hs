module Julia (iterJulia, isJulia)
    where

import Data.Complex

-- Runs a single iteration of the recurrence relation
julia :: (RealFloat a) => Complex a -> Complex a -> Complex a
julia z c = (z * z) + c


{- 
    Returns limit - iterations to converge for the julia set, point c
-}
iterJulia :: (RealFloat a) => Complex a -> Complex a -> Integer -> Integer
iterJulia z c limit = 
	    iterateZ z 0
	where	
	    iterateZ z iter = 
		if ((magnitude z) > 2) || (iter > limit) then
		    limit - iter
		else
		    iterateZ (julia z c) (iter + 1)




{- 
    Tests if a point (x,y) is within the julia set for a given iteration limit 
-}    
isJulia :: (RealFloat a) => Complex a -> Complex a -> Integer -> Bool
isJulia z c limit = iterJulia z c limit > 0 

