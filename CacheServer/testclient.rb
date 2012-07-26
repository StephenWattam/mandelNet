


# Points.
points = []

# bounds
bounds = [-2, -2]
size   = [4,   2]

# samples
samples = [40, 20]


def sample_to_mandel(bounds, samples, size, r, i)
  return (bounds[0] + (r * (size[0].to_f/samples[0].to_f))), (bounds[1] + (i * (size[1].to_f/samples[1].to_f)))
end

  
def mandel_to_sample(bounds, samples, size, r, i)
  #puts "r: #{r} i: #{i}"
  return ((r - bounds[0]).to_f / (size[0].to_f/samples[0].to_f)), ((i - bounds[1]).to_f / (size[1].to_f/samples[1].to_f))
end

def find_nearest_samples(bounds, samples, size, r, i)
  # Precise estimates of the index position
  ir, ii = mandel_to_sample(bounds, samples, size, r, i)
  #puts "IR: #{ir}, II: #{ii}"

  # xmin, xmax, ymin, ymax
  return ir.floor, ir.ceil, ii.floor, ir.ceil
end

def linear_interpolate(bounds, samples, size, r, i)
  # Get indexes on the grid
  irf, irc, iif, iic = find_nearest_samples(bounds, samples, size, r, i)
  #puts "irc: #{irc}, irf: #{irf}"

  # Get estimates as baseline
  irmin, iimin = sample_to_mandel(bounds, samples, size, irf, iif)
  irmax, iimax = sample_to_mandel(bounds, samples, size, irc, iic)
  #puts "irmin: #{irmin}. irmax: #{irmax}"

  #get proportion of interpolation across X, Y
  pr = (r - irmin) / (irmax - irmin)
  pi = (i - iimin) / (iimax - iimin)

  puts "pr: #{pr}, pi: #{pi}"

  # Retrieve values at the index estimates, top left, top right, bottom left, bottom right.
  tl = get_grid_point(bounds, samples, size, irf, iif)
  tr = get_grid_point(bounds, samples, size, irf, iic)
  bl = get_grid_point(bounds, samples, size, irc, iif)
  br = get_grid_point(bounds, samples, size, irc, iic)

  
  a1 = tl + pr*(tr-tl)
  a2 = bl + pr*(br-bl)
  it = a1 + pi*(a2-a1)

  return it
  #px = ptop + u (pbottom - ptop) 

  #return (  ((0.5*((br-bl)+(tr-tl)))*pr) + ((0.5*((tl-bl)+(tr-br)))*pi)  )*0.5

end

def get_grid_point(bounds, samples, size, r, i)
#TODO: add cache here.
  mx, my = sample_to_mandel(bounds, samples, size, r, i)
  mandel(mx, my)
end

#(0..samples[0]).each{|r|
  #(0..samples[1]).each{|i|
    #mr, mi = sample_to_mandel(bounds, samples, size, r, i)
    #it = mandel(mr, mi)
    #puts "r: #{r} #{mandel_to_sample(bounds, samples, size, mr, mi)}, i: #{i}, sm: #{it}"
  #}
#}






require 'socket'


# Config
hostname = "wixi.extremetomato.com"
port = 9985
ITERATIONS=1000

# Connext
$s = TCPSocket.open(hostname, port)

# request
def mandel(x,y,i=ITERATIONS)
  $s.puts "m #{i} #{x} #{y}\n"
  $s.flush
  $s.readline.to_i
end

server = TCPServer.open(5000)  
loop {                         
  c = server.accept       
  continue = true
  
  while(continue) do
    command = c.readline
    params = command.split
    if(params.length < 4 or params[0] != "m") then 
      continue = false
    else
      it = linear_interpolate(bounds, samples, size, params[2].to_f, params[3].to_f)
      it = 1000 if not it.finite?
      c.puts "#{it.to_i}\n"
      continue=true
    end
  end

  c.close
}


$s.close
