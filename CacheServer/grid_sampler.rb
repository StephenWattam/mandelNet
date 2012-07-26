  
class GridSampler
  def initialize(dir)
    @dir = dir
  end

  # Skip last n grids, assuming they are being worked on by servers
  def load_grids(skip=1)
    Dir.foreach(@dir){|file|
      if(file =~ /n([0-9\-]+)_r([0-9\-]+)_i([0-9\-]+)_s([0-9\-]+)/)
        puts file.to_s
      end

    }
  end
end

x = GridSampler.new("data")
x.load_grids
