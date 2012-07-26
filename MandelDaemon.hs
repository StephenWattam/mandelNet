module Main where

-- required for networking
import Network.Fancy
import System.IO
import System.Exit(exitFailure)
import System(getArgs)

-- required for mandelbroting
import Mandelbrot
import Julia 
import Data.Complex
import Data.Ratio

main :: IO ()
main = do
	-- Read options from command line
	args <- getArgs
	if(length args < 1) then do
	    putStrLn "Please provide a port number to listen on, i.e. # mb 4000"
	    exitFailure
	else do
	    let port = read (args!!0) :: Int
	    let spec = ServerSpec (IPv4 "" port) ReverseName Inline True 128

	    -- Fire up the server and defer
	    _ <- streamServer spec connectionHandler 
	    putStrLn $ "Listening on port " ++ (show port)
	    sleepForever
	


-- Output the hostname of the person connecting
connectionHandler :: Handle -> Address -> IO ()
connectionHandler h client = do
	putStrLn $ "Client connected: " ++ (show client)
	-- Start the service loop
	handleRequests h
	--
	putStrLn $ "+- Disconnecting client: " ++ (show client)
	hClose h
	return ()


-- Handles all requests from a client
handleRequests :: Handle -> IO ()
handleRequests h = do
	do { 
	    -- try processing
	    processInput
	} `catch` \_ -> do{
	    -- close the handle to the broken client and return
	    putStrLn $ "|- Client Dropped.";
	    hClose h;
	    return ()
	}

    -- Assuming the client is fine, try reading and processing the data
    where processInput = do
	    command <- hGetLine h;
	    --putStrLn $ "|- Received: \"" ++ command ++ "\""
	    let response = processCommand command
	    -- handle the response
	    if(response == -1) then do
		putStrLn $ "|- Quitting at user request." -- " ++ command 
		return ()
	    else do
		--putStrLn $ (show response) ++ "."
		hPutStrLn h (show response)
		hFlush h
		handleRequests h


loadDoubleComplex :: [String] -> Int -> Complex Double
loadDoubleComplex w o = (read (w!!o) :: Double) :+ (read (w!!(o+1)) :: Double)


-- Processes the command
processCommand :: String -> Integer
processCommand c = 
	case (w!!0) of
	    "md" -> checklength 4 dpMandelbrot
	    "me" -> checklength 5 epMandelbrot
	    "mp" -> checklength 6 pMandelbrot
	    "j"  -> checklength 6 dpJulia
	    _    -> -1

    where
	w = words c 
	iterations = read (w!!1) :: Integer
	checklength n func = if(length w == n) then (func iterations w) else -1

--me 1000 -1.0 -0.225 0.1
-- Double Precision Mandelbrot
dpMandelbrot :: Integer -> [String] -> Integer
dpMandelbrot iterations w = iterMandelbrot z iterations
    where
	z = loadDoubleComplex w 2

-- Arbitrary precision mandelbrot, input from double precision
epMandelbrot :: Integer -> [String] -> Integer
epMandelbrot iterations (_:_:r:i:e:[]) = iterMandelbrot_precise z iterations
    where
	err = read e :: Double
	rational = read r :: Double
	imaginary = read i :: Double
	z = (approxRational rational err <:+> approxRational imaginary err)
epMandelbrot _ _ = 0

-- Accurate Mandelbrot
pMandelbrot :: Integer -> [String] -> Integer
pMandelbrot iterations (_:_:rnom:rden:inom:iden:[]) = iterMandelbrot_precise ((r1%r2) <:+> (i1%i2)) iterations
    where
	r1 = read rnom :: Integer
	r2 = read rden :: Integer
	i1 = read inom :: Integer
	i2 = read iden :: Integer
pMandelbrot _ _ = 0

-- Double Precision Julia
dpJulia :: Integer -> [String] -> Integer
dpJulia iterations w = iterJulia z c iterations
    where
	z = loadDoubleComplex w 2
	c = loadDoubleComplex w 4

