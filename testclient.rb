require 'socket'


# Config
hostname = "wixi.extremetomato.com"
port = 4000 
ITERATIONS=20

# Connext
$s = TCPSocket.open(hostname, port)

# request
def mandel(x,y,i=ITERATIONS)
  $s.puts "me #{i} #{x} #{y} 0.1\n"
  $s.flush
  $s.readline.to_i
end


# Run the points
(0..640).each{|x|
  mx = (x-320)/320.0
  (0..240).each{|y|
    my = (y-120)/120.0
    result = mandel(mx, my)
    puts "mx: #{mx}, my: #{my}, mandel: #{result}"
  }
}


# disconnect
$s.close


