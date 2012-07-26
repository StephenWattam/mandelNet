require './record_store.rb'

class Grid

  def initialize(size)
    @size = size
  end

  
    return from + ((@size/(@num_points+1.0)) * (n+1.0))
  end
end



#x = Grid.new(0,0,4,60000,)
#x.populate_points
#x.summarily_complete_all_points

##x.completed_points.each{|p|
  ##puts p.get_data.join(", ")
##}
#x.save
#x.close


#puts "\n === Loading === \n\n"
#y = Grid.new(0,0,4,60000, nil, true)
##y.completed_points.each{|p|
  ##puts p.get_data.join(", ")
##}

