--- twill
-- @oootini

-- fill a table with a small odd sized repeating binary pattern of variable step size - the twill
-- easily generate new twill patterns from norns, control warp, weft, density, scale, etc
-- the twill is laid out out on the grid. Each lit button is a step
-- select a step to edit that note. edit the note in norns
-- set sequence loop braces on the grid
-- control a x0xheart eurorack module from crow

engine.name = 'PolyPerc'

music = require 'musicutil'
beatclock = require 'beatclock'

steps = {}
position = 1
transpose = 0

mode = math.random(#music.SCALES)
scale = music.generate_scale_of_length(60,music.SCALES[mode].name,8)

function init()
  for i=1,16 do
    table.insert(steps,math.random(8))
  end
  grid_redraw()
  clock.run(count)
end

function enc(n,d)
  if n == 1 then
    params:delta("clock_source",d)
  elseif n == 2 then
    params:delta("clock_tempo",d)
  elseif n == 3 then
    mode = util.clamp(mode + d, 1, #music.SCALES)
    scale = music.generate_scale_of_length(60,music.SCALES[mode].name,8)
  end
  redraw()
end

function redraw()
  screen.clear()
  screen.level(15)
  screen.move(0,20)
  screen.text("clock source: "..params:string("clock_source"))
  screen.move(0,30)
  screen.text("bpm: "..params:get("clock_tempo"))
  screen.move(0,40)
  screen.text(music.SCALES[mode].name)
  screen.update()
end

g = grid.connect()

g.key = function(x,y,z)
  if z == 1 then
    steps[x] = 9-y
    grid_redraw()
  end
end

function grid_redraw()
  g:all(0)
  for i=1,16 do
    g:led(i,9-steps[i],i==position and 15 or 4)
  end
  g:refresh()
end

function count()
  while true do
    clock.sync(1/4)
    position = (position % 16) + 1
    engine.hz(music.note_num_to_freq(scale[steps[position]] + transpose))
    grid_redraw()
    redraw() -- for bpm changes on LINK, MIDI, or crow
  end
end

m = midi.connect()
m.event = function(data)
  local d = midi.to_msg(data)
  if d.type == "note_on" then
    transpose = d.note - 60
  end
end