#!/bin/env ruby

# What to render
ITERATIONS = 1_000_000
ORIGIN = [-2,-2]
SIZE = 4

# How the renderer progresses
SEEDS = (4..32).to_a
GENFUNC = lambda{|x| return 2**x }

# servers
servers = []
#servers += %w{wixi.extremetomato.com:9985 wixi.extremetomato.com:9986 wixi.extremetomato.com:9987 wixi.extremetomato.com:9988}
servers += %w{194.80.34.178:4000 194.80.34.178:4001 194.80.34.178:4002 194.80.34.178:4003 194.80.34.178:4004 194.80.34.178:4005 194.80.34.178:4006 194.80.34.178:4007}
#servers += %w{148.88.227.243:4000 148.88.227.243:4001 148.88.227.243:4002 148.88.227.243:4003}





# Create dispatcher and run task
require './grid.rb'
require './poolclient.rb'
SEEDS.each{|seed|
  points = GENFUNC.call(seed)

  puts "Constructing grid with #{points} points."
  # Construct a new grid
  g = Grid.new(ORIGIN[0],ORIGIN[1],SIZE,points)
  g.populate_points

  puts "Sampling mandelbrot set for #{points} points."
  # Construct something to get the points.
  d = MandelGridSatisfier.new(g)
  d.init_workers(servers)
  d.work
  d.wait
  d.close

  puts "Saving grid for #{points} points."
  d.save_grid

}


puts "Done."
