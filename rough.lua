--- rough

local warp = {0,11,1}
local weft = {1,1,0}
local notes = {}
local twill = {}
local position = 1
local transpose = 0
local grid_size = 64

function init()
  grid_dirty = true -- initialize with a redraw
  grid_redraw()
  paint_grid()
  g:refresh()
end

function grid_redraw()
  g:all(0) -- turn off all the LEDs
  g:refresh() -- refresh the hardware to display the new LED selection
end

function create_twill()
  twill = {}
  for i = 1, grid_size do
    table.insert(twill,math.random(0,1))
  end
end

function paint_grid()
  create_twill()
  grid_redraw()
  for i=1,grid_size do
    if twill[i] == 1 then
      y = i % 8
      x = math.floor(i/8)
      g:led(x,y,15)
    end
  end
  g:refresh()
end

g = grid.connect()

g.key = function(x,y,z)
  if z == 1 then
    paint_grid()
  end
end