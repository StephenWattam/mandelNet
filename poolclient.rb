# ----------------- Worker pool example


class Worker
  def initialize(server)
    require 'socket'
    @s = TCPSocket.open(server.split(":")[0], server.split(":")[1].to_i)
  end

  # Should be run in a thread.  Performs work until the dispatcher runs out of points.
  def work(drawer)
    while(p = drawer.get_point) do
      x, y = p[0], p[1]
      @s.puts "m #{ITERATIONS} #{x} #{y}\n"
      @s.flush
      iter = @s.readline.to_i
      drawer.plot(p,iter) 
    end
  end

  # Closes the connection to the server
  def close
    @s.close
  end
end


class MandelDrawer
  def initialize(points)
    require 'thread'
    @m = Mutex.new
    @p = points
    @t = [] #threads
  end

  # Gets a single point from the list, and deletes it.  Thread safe.
  def get_point
    p = nil
    @m.synchronize{
      p = @p[0]
      @p.delete_at(0)
    }
    return p
  end

  # Run a worker over every point competitively
  def work
    @w.each{|w|
      @t << Thread.new(w, self){|w, d|
        w.work(d)
      }
    }
  end

  # Wait for threads to complete.
  def wait
    @t.each{|t| t.join}
  end

  # Close all workers' connections to the servers
  def close
    @w.each{|w|
      w.close
    }
  end
   
  # Create and connect the workers to servers 
  def init_workers(servers)
    @w = []
    servers.each{|s|
      @w << Worker.new(s)
    }
  end

  # Some kind of callback.
  def plot(p, i)
    x, y, sw, sh = p[0], p[1], p[2], p[3]

    @m.synchronize{
      puts "#{x},#{y}: #{i}"
    }  

  end
end

class MandelImager < MandelDrawer
  def initialize(points, filename)
    super(points)
    require 'RMagick'
    @i = Magick::Image.new(SX, SY)
  end

  def plot(p, i)
    x, y, sx, sy = p[0], p[1], p[2], p[3]
    
    @m.synchronize{
      puts "#{sx},#{sy}: #{i}"
    } 
    
    #draw.point(sx, sy)
    
    @i.pixel_color(sx, sy, Magick::Pixel.new(i*200, 256, 256, 256))
  end

  def show
    @i.display
  end
end


# Trap the ^C signal and wait for workers to die.
trap("INT"){
  puts "\nShutting down cleanly..."
  $attempting_clean_shutdown = true

  if $d and not $attempting_clean_shutdown then
    $d.clear_points
    $d.wait
    $d.close
    exit
  else
    puts "Goodbye"
    exit
  end
}

# How many iterations to run
ITERATIONS = 1000000
SX = 1024 
SY = 1024 

# build points list
points = []
(0..SX).each{|x|
  mx = (x-(SX/2))/(SX/2.0)
  (0..SY).each{|y|
    my = (y-(SY/2))/(SY/2.0)
    points << [mx, my, x, y]
  }
}

# servers
servers = %w{localhost:4444 localhost:4445 wixi.extremetomato.com:9985 wixi.extremetomato.com:9986 wixi.extremetomato.com:9987 wixi.extremetomato.com:9988}

# Create dispatcher and run task
#$d = MandelDrawer.new(points)
$d = MandelImager.new(points, "mandel.png")
$d.init_workers(servers)
$d.work
$d.wait
$d.close


$d.show
